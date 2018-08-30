CREATE OR REPLACE Package Pkg_Status_Record Is
  ----------------
  --状态记录服务--
  ----------------
  --记录时获取要显示状态
  Procedure Get_Input_Status
  (
    Input_In   In Clob,
    Output_Out Out Sys_Refcursor
  );
  --保存状态记录
  Procedure Save_Status_Record(Input_In In Clob);
  --保存状态记录(反向问诊)
  Procedure Save_Status_Record_Forquery(Input_In In Clob);
  Procedure Get_Pat_Info
  (
    Pid_In        In Varchar2,
    Visit_Type_In In Number,
    Pvid_In       In Varchar2,
    Pinfo_Out     Out Sys_Refcursor
  );
End;

/


CREATE OR REPLACE Package Body Pkg_Status_Record Is
  ----------------
  --状态记录服务--
  ----------------
  Procedure Get_Input_Status
  --头注释开始-----------------------------------------------------------------------------------------
    --方法名称：场景记录时获取默认状态
    --功能说明：场景记录时获取默认状态
    --入参说明：json示例{"pati_info":[{"pid":"","sex":"","birth":"","pvid":"","visit_type":"","envr_id":"","marry_cnds":"","visit_dept":""}]}
    --出参说明：游标变量:Status_Id, Status_Name, Type_Id, Status_Prop, Status_Situation,
    --                   Status_Begin_Date, Status_End_Date, Related_Parts_Id, Related_Parts_Name
    --                   Gender_Cnds, Dept_Cnds, Age_Cnds, Marriage_Cnds
    --编写者：刘尔旋
    --编写时间：2018-7-24
    --版本记录：1
    --头注释结束-----------------------------------------------------------------------------------------
  (
    Input_In   In Clob,
    Output_Out Out Sys_Refcursor
  ) Is
  Begin
    For r_Pati In (Select Pid, Sex, Birth, Pvid, Visit_Type, Envr_Id, Marry_Cnds, Visit_Dept
                   From Json_Table(Input_In, '$.rec_info[*]' Columns Pid Varchar2(36) Path '$."pid"',
                                    Sex Varchar2(10) Path '$."sex"', Birth Varchar2(100) Path '$."birth"',
                                    Pvid Varchar2(36) Path '$."pvid"', Visit_Type Number(1) Path '$."visit_type"',
                                    Envr_Id Varchar2(36) Path '$."envr_id"', Marry_Cnds Varchar2(100) Path '$."marry_cnds"',
                                    Visit_Dept Varchar2(100) Path '$."visit_dept"')) Loop
      Open Output_Out For
      --取场景设置的状态
        Select b.Status_Id, b.Status_Name, b.Type_Id, b.Status_Prop, c.Status_Situation As Status_Situation,
               c.Status_Begin_Date As Status_Begin_Date, c.Status_End_Date As Status_End_Date,
               c.Related_Parts_Id As Related_Parts_Id, c.Related_Parts As Related_Parts_Name,
               Listagg(Dg.Cnds_Value, '|') Within Group(Order By Dg.Cnds_Value) As Gender_Cnds,
               Listagg(Dd.Cnds_Value, '|') Within Group(Order By Dd.Cnds_Value) As Dept_Cnds,
               Listagg(Da.Cnds_Value, '|') Within Group(Order By Da.Cnds_Value) As Age_Cnds,
               Listagg(Dm.Cnds_Value, '|') Within Group(Order By Dm.Cnds_Value) As Marriage_Cnds
        From Envr_Status_Vs A, Status_List B, Pat_Status C, Status_Cnds Dg, Status_Cnds Dd, Status_Cnds Da,
             Status_Cnds Dm
        Where a.Envr_Id = r_Pati.Envr_Id And a.Status_Id = b.Status_Id And b.Enable_Sign = 1 And c.Pid(+) = r_Pati.Pid And
              c.Status_Id(+) = b.Status_Id And c.Status_Situation(+) <> 3 And Dg.Cnds_Type(+) = 1 And
              Dg.Status_Id(+) = b.Status_Id And Dd.Cnds_Type(+) = 2 And Dd.Status_Id(+) = b.Status_Id And
              Da.Cnds_Type(+) = 3 And Da.Status_Id(+) = b.Status_Id And Dm.Cnds_Type(+) = 4 And
              Dm.Status_Id(+) = b.Status_Id
        Group By b.Status_Id, b.Status_Name, b.Type_Id, b.Status_Prop, c.Status_Situation, c.Status_Begin_Date,
                 c.Status_End_Date, c.Related_Parts_Id, c.Related_Parts
        Union All
        --取场景设置中不存在的状态
        Select b.Status_Id, b.Status_Name, b.Type_Id, b.Status_Prop, c.Status_Situation As Status_Situation,
               c.Status_Begin_Date As Status_Begin_Date, c.Status_End_Date As Status_End_Date,
               c.Related_Parts_Id As Related_Parts_Id, c.Related_Parts As Related_Parts_Name,
               Listagg(Dg.Cnds_Value, '|') Within Group(Order By Dg.Cnds_Value) As Gender_Cnds,
               Listagg(Dd.Cnds_Value, '|') Within Group(Order By Dd.Cnds_Value) As Dept_Cnds,
               Listagg(Da.Cnds_Value, '|') Within Group(Order By Da.Cnds_Value) As Age_Cnds,
               Listagg(Dm.Cnds_Value, '|') Within Group(Order By Dm.Cnds_Value) As Marriage_Cnds
        From Status_List B, Pat_Status C, Status_Cnds Dg, Status_Cnds Dd, Status_Cnds Da, Status_Cnds Dm
        Where b.Enable_Sign = 1 And c.Pid = r_Pati.Pid And c.Status_Id = b.Status_Id And c.Status_Situation <> 3 And
              Not Exists (Select 1 From Envr_Status_Vs Where Status_Id = b.Status_Id And Envr_Id = r_Pati.Envr_Id) And
              Dg.Cnds_Type(+) = 1 And Dg.Status_Id(+) = b.Status_Id And Dd.Cnds_Type(+) = 2 And
              Dd.Status_Id(+) = b.Status_Id And Da.Cnds_Type(+) = 3 And Da.Status_Id(+) = b.Status_Id And
              Dm.Cnds_Type(+) = 4 And Dm.Status_Id(+) = b.Status_Id
        Group By b.Status_Id, b.Status_Name, b.Type_Id, b.Status_Prop, c.Status_Situation, c.Status_Begin_Date,
                 c.Status_End_Date, c.Related_Parts_Id, c.Related_Parts;
    
    End Loop;
  End Get_Input_Status;

  Procedure Save_Status_Record(Input_In In Clob) Is
    --头注释开始-----------------------------------------------------------------------------------------
    --方法名称：保存状态记录(业务数据)
    --功能说明：保存状态记录(业务数据)
    --入参说明：json示例
    /*
    {"rec_info":[{"pid":"","name":"","sex":"","birth":"","age":"","pvid":"","visit_type":"","envr_id":"","visit_identifier":"","visit_time":""
    ,"marry_cnds":"","visit_dept":"","visit_doc":"","rec_time":"","recorder":"","recorder_id":""}]
    ,"rec_detail":[{"status_id":"","status_situation":"","begin_time":"","end_time":"","status_parts_id":""}]}
    */
    --出参说明：
    --编写者：刘尔旋
    --编写时间：2018-7-24
    --版本记录：1
    --头注释结束-----------------------------------------------------------------------------------------
    v_Rec_Id     Varchar2(36);
    v_Parts_Name Varchar2(100);
    v_Detail_Id  Varchar2(36);
  Begin
    v_Rec_Id := Sys_Guid();
    --insert into PATI_INFO_TEMP(PID,JSON_CONTENT) values (9999,input_in);
    For r_Basic In (Select Pid, Pat_Name, Sex, Birth, Age, Pvid, Visit_Type, Envr_Id, Visit_Time, Visit_Identifier,
                           Marry_Cnds, Visit_Dept, Visit_Doc, Rec_Time, Recorder, Recorder_Id
                    From Json_Table(Input_In, '$.rec_info[*]' Columns Pid Varchar2(36) Path '$."pid"',
                                     Pat_Name Varchar2(100) Path '$."name"', Sex Varchar2(10) Path '$."sex"',
                                     Birth Varchar2(100) Path '$."birth"', Age Varchar2(20) Path '$."age"',
                                     Pvid Varchar2(36) Path '$."pvid"', Visit_Type Number(1) Path '$."visit_type"',
                                     Envr_Id Varchar2(36) Path '$."envr_id"',
                                     Visit_Time Varchar2(100) Path '$."visit_time"',
                                     Visit_Identifier Varchar2(36) Path '$."visit_identifier"',
                                     Marry_Cnds Varchar2(100) Path '$."marry_cnds"',
                                     Visit_Dept Varchar2(100) Path '$."visit_dept"',
                                     Visit_Doc Varchar2(100) Path '$."visit_doc"',
                                     Rec_Time Varchar2(100) Path '$."rec_time"', Recorder Varchar2(100) Path '$."recorder"',
                                     Recorder_Id Varchar2(36) Path '$."recorder_id"')) Loop
      --写入患者状态记录
      Insert Into Pat_Status_Rec
        (Rec_Id, Pid, Pat_Name, Pat_Sex, Birth_Date, Age, Envr_Id, Visit_Type, Pvid, Visit_Time, Visit_Identifier,
         Marry_Cnds, Visit_Dept, Visit_Doc, Rec_Time, Recorder_Id, Recorder)
        Select v_Rec_Id, r_Basic.Pid, r_Basic.Pat_Name, r_Basic.Sex,
               Decode(r_Basic.Birth, Null, Null, To_Date(r_Basic.Birth, 'yyyy-mm-dd hh24:mi:ss')), r_Basic.Age,
               r_Basic.Envr_Id, r_Basic.Visit_Type, r_Basic.Pvid,
               Decode(r_Basic.Visit_Time, Null, Null, To_Date(r_Basic.Visit_Time, 'yyyy-mm-dd hh24:mi:ss')),
               r_Basic.Visit_Identifier, r_Basic.Marry_Cnds, r_Basic.Visit_Dept, r_Basic.Visit_Doc,
               Decode(r_Basic.Rec_Time, Null, Sysdate, To_Date(r_Basic.Rec_Time, 'yyyy-mm-dd hh24:mi:ss')),
               r_Basic.Recorder_Id,
               Utl_Raw.Cast_To_Varchar2(Utl_Encode.Base64_Decode(Utl_Raw.Cast_To_Raw(r_Basic.Recorder)))
        From Dual;
    
      For r_Detail In (Select Status_Id, Status_Situation, Begin_Time, End_Time, Status_Parts_Id
                       From Json_Table(Input_In, '$.rec_detail[*]' Columns Status_Id Varchar2(36) Path '$."status_id"',
                                        Status_Situation Number(1) Path '$."status_situation"',
                                        Begin_Time Varchar2(100) Path '$."begin_time"',
                                        End_Time Varchar2(100) Path '$."end_time"',
                                        Status_Parts_Id Varchar2(36) Path '$."status_parts_id"')) Loop
        If r_Detail.Status_Situation Is Not Null Then
          --写入患者状态明细
          Select Max(b.Parts_Name) Into v_Parts_Name From Parts_List B Where b.Parts_Id = r_Detail.Status_Parts_Id;
          v_Detail_Id := Sys_Guid();
          Insert Into Pat_Status_Detail
            (Detail_Id, Status_Id, Rec_Id, Status_Name, Status_Situation, Status_Begin_Date, Status_End_Date,
             Related_Parts_Id, Related_Parts)
            Select v_Detail_Id, r_Detail.Status_Id, v_Rec_Id, a.Status_Name, r_Detail.Status_Situation,
                   Decode(r_Detail.Begin_Time, Null, Null, To_Date(r_Detail.Begin_Time, 'yyyy-mm-dd hh24:mi:ss')),
                   Decode(r_Detail.End_Time, Null, Null, To_Date(r_Detail.End_Time, 'yyyy-mm-dd hh24:mi:ss')),
                   r_Detail.Status_Parts_Id, v_Parts_Name
            From Status_List A
            Where a.Status_Id = r_Detail.Status_Id;
        
          --更新患者状态
          --1.删除当次就诊的有效/复发/无效状态
          --2.插入新的状态记录
          If r_Detail.Status_Parts_Id Is Null Then
            Delete From Pat_Status A
            Where a.Pid = r_Basic.Pid And a.Status_Id = r_Detail.Status_Id And a.Related_Parts_Id Is Null And
                  a.Status_Situation In (1, 2, 3);
          Else
            Delete From Pat_Status A
            Where a.Pid = r_Basic.Pid And a.Status_Id = r_Detail.Status_Id And
                  a.Related_Parts_Id = r_Detail.Status_Parts_Id And a.Status_Situation In (1, 2, 3);
          End If;
        
          Insert Into Pat_Status
            (Pat_Status_Id, Pid, Status_Id, Status_Name, Status_Prop, Status_Situation, Status_Begin_Date,
             Status_End_Date, Related_Parts_Id, Related_Parts, Last_Detail_Id)
            Select Sys_Guid(), r_Basic.Pid, r_Detail.Status_Id, a.Status_Name, a.Status_Prop, r_Detail.Status_Situation,
                   Decode(r_Detail.Begin_Time, Null, Null, To_Date(r_Detail.Begin_Time, 'yyyy-mm-dd hh24:mi:ss')),
                   Decode(r_Detail.End_Time, Null, Null, To_Date(r_Detail.End_Time, 'yyyy-mm-dd hh24:mi:ss')),
                   r_Detail.Status_Parts_Id, v_Parts_Name, v_Detail_Id
            From Status_List A
            Where a.Status_Id = r_Detail.Status_Id;
        End If;
      End Loop;
    End Loop;
  End Save_Status_Record;

  Procedure Save_Status_Record_Forquery(Input_In In Clob) Is
    --头注释开始-----------------------------------------------------------------------------------------
    --方法名称：保存状态记录(反向问诊调用)
    --功能说明：保存状态记录(反向问诊调用)
    --入参说明：json示例
    /*
    {"rec_info":[{"pid":"","name":"","sex":"","birth":"","age":"","pvid":"","visit_type":"","envr_id":"","visit_identifier":"","visit_time":""
    ,"marry_cnds":"","visit_dept":"","visit_doc":"","rec_time":"","recorder":"","recorder_id":""}]
    ,"rec_detail":[{"status_id":"","status_name":"","status_situation":""}]}
    */
    --出参说明：
    --编写者：刘尔旋
    --编写时间：2018-7-24
    --版本记录：1
    --头注释结束-----------------------------------------------------------------------------------------
    v_Rec_Id    Varchar2(36);
    v_Detail_Id Varchar2(36);
    v_Status_Id Varchar2(36);
  Begin
    v_Rec_Id := Sys_Guid();
    For r_Basic In (Select Pid, Pat_Name, Sex, Birth, Age, Pvid, Visit_Type, Envr_Id, Visit_Time, Visit_Identifier,
                           Marry_Cnds, Visit_Dept, Visit_Doc, Rec_Time, Recorder, Recorder_Id
                    From Json_Table(Input_In, '$.rec_info[*]' Columns Pid Varchar2(36) Path '$."pid"',
                                     Pat_Name Varchar2(100) Path '$."name"', Sex Varchar2(10) Path '$."sex"',
                                     Birth Varchar2(100) Path '$."birth"', Age Varchar2(20) Path '$."age"',
                                     Pvid Varchar2(36) Path '$."pvid"', Visit_Type Number(1) Path '$."visit_type"',
                                     Envr_Id Varchar2(36) Path '$."envr_id"',
                                     Visit_Time Varchar2(100) Path '$."visit_time"',
                                     Visit_Identifier Varchar2(36) Path '$."visit_identifier"',
                                     Marry_Cnds Varchar2(100) Path '$."marry_cnds"',
                                     Visit_Dept Varchar2(100) Path '$."visit_dept"',
                                     Visit_Doc Varchar2(100) Path '$."visit_doc"',
                                     Rec_Time Varchar2(100) Path '$."rec_time"', Recorder Varchar2(100) Path '$."recorder"',
                                     Recorder_Id Varchar2(36) Path '$."recorder_id"')) Loop
      --写入患者状态记录
      Insert Into Pat_Status_Rec
        (Rec_Id, Pid, Pat_Name, Pat_Sex, Birth_Date, Age, Envr_Id, Visit_Type, Pvid, Visit_Time, Visit_Identifier,
         Marry_Cnds, Visit_Dept, Visit_Doc, Rec_Time, Recorder_Id, Recorder)
        Select v_Rec_Id, r_Basic.Pid, r_Basic.Pat_Name, r_Basic.Sex,
               Decode(r_Basic.Birth, Null, Null, To_Date(r_Basic.Birth, 'yyyy-mm-dd hh24:mi:ss')), r_Basic.Age,
               r_Basic.Envr_Id, r_Basic.Visit_Type, r_Basic.Pvid,
               Decode(r_Basic.Visit_Time, Null, Null, To_Date(r_Basic.Visit_Time, 'yyyy-mm-dd hh24:mi:ss')),
               r_Basic.Visit_Identifier, r_Basic.Marry_Cnds, r_Basic.Visit_Dept, r_Basic.Visit_Doc,
               Decode(r_Basic.Rec_Time, Null, Sysdate, To_Date(r_Basic.Rec_Time, 'yyyy-mm-dd hh24:mi:ss')),
               r_Basic.Recorder_Id, r_Basic.Recorder
        From Dual;
    
      For r_Detail In (Select Status_Id, Status_Situation, Status_Name
                       From Json_Table(Input_In, '$.rec_detail[*]' Columns Status_Id Varchar2(36) Path '$."status_id"',
                                        Status_Name Varchar2(100) Path '$."status_name"',
                                        Status_Situation Number(1) Path '$."status_situation"')) Loop
        If r_Detail.Status_Situation Is Not Null Then
          v_Status_Id := r_Detail.Status_Id;
          If v_Status_Id Is Null Then
            Select Max(a.Status_Id) Into v_Status_Id From Status_List A Where a.Status_Name = r_Detail.Status_Name;
          End If;
          If v_Status_Id Is Not Null Then
            --写入患者状态明细
            v_Detail_Id := Sys_Guid();
            Insert Into Pat_Status_Detail
              (Detail_Id, Status_Id, Rec_Id, Status_Name, Status_Situation)
              Select v_Detail_Id, v_Status_Id, v_Rec_Id, r_Detail.Status_Name, r_Detail.Status_Situation From Dual;
          
            --更新患者状态
            --1.删除当次就诊的有效/复发/无效状态
            --2.插入新的状态记录
            Delete From Pat_Status A
            Where a.Pid = r_Basic.Pid And a.Status_Id = v_Status_Id And a.Related_Parts_Id Is Null And
                  a.Status_Situation In (1, 2, 3);
          
            Insert Into Pat_Status
              (Pat_Status_Id, Pid, Status_Id, Status_Name, Status_Prop, Status_Situation, Last_Detail_Id)
              Select Sys_Guid(), r_Basic.Pid, v_Status_Id, a.Status_Name, a.Status_Prop, r_Detail.Status_Situation,
                     v_Detail_Id
              From Status_List A
              Where a.Status_Id = v_Status_Id;
          End If;
        End If;
      End Loop;
    End Loop;
  End Save_Status_Record_Forquery;

  Procedure Get_Pat_Info
  (
    Pid_In        In Varchar2,
    Visit_Type_In In Number,
    Pvid_In       In Varchar2,
    Pinfo_Out     Out Sys_Refcursor
  ) Is
    --头注释开始-----------------------------------------------------------------------------------------
    --方法名称：获取病人信息
    --功能说明：获取病人信息
    --入参说明：Pid_In=病人ID,Visit_Type_In=就诊类型1为门诊2位住院,Pvid_In=门诊为挂号单号，住院为主页ID
    --出参说明：游标示例:病人ID,姓名,性别,出生日期,年龄,就诊时间,挂号单号,就诊标识号,婚姻状况,就诊科室
    --编写者：罗虹
    --编写时间：2018-7-25
    --版本记录：1
    --头注释结束-----------------------------------------------------------------------------------------  
  Begin
    If Visit_Type_In = 1 Then
      --门诊
      Open Pinfo_Out For
        Select a.病人id, a.姓名, a.性别, b.出生日期, a.年龄, a.发生时间 As 就诊时间, a.No As 挂号单号, a.门诊号 As 就诊标识号, b.婚姻状况, c.名称 As 就诊科室
        From 病人挂号记录@To_Zlhis A, 病人信息@To_Zlhis B, 部门表@To_Zlhis C
        Where a.执行部门id = c.Id And a.病人id = Pid_In And a.No = Pvid_In And a.记录状态 In (1, 3) And a.病人id = b.病人id;
    Elsif Visit_Type_In = 2 Then
      --住院
      Open Pinfo_Out For
        Select a.病人id, a.姓名, a.性别, b.出生日期, a.年龄, a.入院日期 As 就诊时间, Null As 挂号单号, a.住院号 As 就诊标识号, b.婚姻状况, c.名称 As 就诊科室
        From 病案主页@To_Zlhis A, 病人信息@To_Zlhis B, 部门表@To_Zlhis C
        Where a.入院科室id = c.Id And a.病人id = Pid_In And a.主页id = Pvid_In And a.病人id = b.病人id;
    End If;
  End Get_Pat_Info;
End;

/
