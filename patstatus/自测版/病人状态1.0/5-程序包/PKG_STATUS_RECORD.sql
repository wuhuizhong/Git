CREATE OR REPLACE Package Pkg_Status_Record Is
  ----------------
  --״̬��¼����--
  ----------------
  --��¼ʱ��ȡҪ��ʾ״̬
  Procedure Get_Input_Status
  (
    Input_In   In Clob,
    Output_Out Out Sys_Refcursor
  );
  --����״̬��¼
  Procedure Save_Status_Record(Input_In In Clob);
  --����״̬��¼(��������)
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
  --״̬��¼����--
  ----------------
  Procedure Get_Input_Status
  --ͷע�Ϳ�ʼ-----------------------------------------------------------------------------------------
    --�������ƣ�������¼ʱ��ȡĬ��״̬
    --����˵����������¼ʱ��ȡĬ��״̬
    --���˵����jsonʾ��{"pati_info":[{"pid":"","sex":"","birth":"","pvid":"","visit_type":"","envr_id":"","marry_cnds":"","visit_dept":""}]}
    --����˵�����α����:Status_Id, Status_Name, Type_Id, Status_Prop, Status_Situation,
    --                   Status_Begin_Date, Status_End_Date, Related_Parts_Id, Related_Parts_Name
    --                   Gender_Cnds, Dept_Cnds, Age_Cnds, Marriage_Cnds
    --��д�ߣ�������
    --��дʱ�䣺2018-7-24
    --�汾��¼��1
    --ͷע�ͽ���-----------------------------------------------------------------------------------------
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
      --ȡ�������õ�״̬
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
        --ȡ���������в����ڵ�״̬
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
    --ͷע�Ϳ�ʼ-----------------------------------------------------------------------------------------
    --�������ƣ�����״̬��¼(ҵ������)
    --����˵��������״̬��¼(ҵ������)
    --���˵����jsonʾ��
    /*
    {"rec_info":[{"pid":"","name":"","sex":"","birth":"","age":"","pvid":"","visit_type":"","envr_id":"","visit_identifier":"","visit_time":""
    ,"marry_cnds":"","visit_dept":"","visit_doc":"","rec_time":"","recorder":"","recorder_id":""}]
    ,"rec_detail":[{"status_id":"","status_situation":"","begin_time":"","end_time":"","status_parts_id":""}]}
    */
    --����˵����
    --��д�ߣ�������
    --��дʱ�䣺2018-7-24
    --�汾��¼��1
    --ͷע�ͽ���-----------------------------------------------------------------------------------------
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
      --д�뻼��״̬��¼
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
          --д�뻼��״̬��ϸ
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
        
          --���»���״̬
          --1.ɾ�����ξ������Ч/����/��Ч״̬
          --2.�����µ�״̬��¼
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
    --ͷע�Ϳ�ʼ-----------------------------------------------------------------------------------------
    --�������ƣ�����״̬��¼(�����������)
    --����˵��������״̬��¼(�����������)
    --���˵����jsonʾ��
    /*
    {"rec_info":[{"pid":"","name":"","sex":"","birth":"","age":"","pvid":"","visit_type":"","envr_id":"","visit_identifier":"","visit_time":""
    ,"marry_cnds":"","visit_dept":"","visit_doc":"","rec_time":"","recorder":"","recorder_id":""}]
    ,"rec_detail":[{"status_id":"","status_name":"","status_situation":""}]}
    */
    --����˵����
    --��д�ߣ�������
    --��дʱ�䣺2018-7-24
    --�汾��¼��1
    --ͷע�ͽ���-----------------------------------------------------------------------------------------
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
      --д�뻼��״̬��¼
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
            --д�뻼��״̬��ϸ
            v_Detail_Id := Sys_Guid();
            Insert Into Pat_Status_Detail
              (Detail_Id, Status_Id, Rec_Id, Status_Name, Status_Situation)
              Select v_Detail_Id, v_Status_Id, v_Rec_Id, r_Detail.Status_Name, r_Detail.Status_Situation From Dual;
          
            --���»���״̬
            --1.ɾ�����ξ������Ч/����/��Ч״̬
            --2.�����µ�״̬��¼
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
    --ͷע�Ϳ�ʼ-----------------------------------------------------------------------------------------
    --�������ƣ���ȡ������Ϣ
    --����˵������ȡ������Ϣ
    --���˵����Pid_In=����ID,Visit_Type_In=��������1Ϊ����2λסԺ,Pvid_In=����Ϊ�Һŵ��ţ�סԺΪ��ҳID
    --����˵�����α�ʾ��:����ID,����,�Ա�,��������,����,����ʱ��,�Һŵ���,�����ʶ��,����״��,�������
    --��д�ߣ��޺�
    --��дʱ�䣺2018-7-25
    --�汾��¼��1
    --ͷע�ͽ���-----------------------------------------------------------------------------------------  
  Begin
    If Visit_Type_In = 1 Then
      --����
      Open Pinfo_Out For
        Select a.����id, a.����, a.�Ա�, b.��������, a.����, a.����ʱ�� As ����ʱ��, a.No As �Һŵ���, a.����� As �����ʶ��, b.����״��, c.���� As �������
        From ���˹Һż�¼@To_Zlhis A, ������Ϣ@To_Zlhis B, ���ű�@To_Zlhis C
        Where a.ִ�в���id = c.Id And a.����id = Pid_In And a.No = Pvid_In And a.��¼״̬ In (1, 3) And a.����id = b.����id;
    Elsif Visit_Type_In = 2 Then
      --סԺ
      Open Pinfo_Out For
        Select a.����id, a.����, a.�Ա�, b.��������, a.����, a.��Ժ���� As ����ʱ��, Null As �Һŵ���, a.סԺ�� As �����ʶ��, b.����״��, c.���� As �������
        From ������ҳ@To_Zlhis A, ������Ϣ@To_Zlhis B, ���ű�@To_Zlhis C
        Where a.��Ժ����id = c.Id And a.����id = Pid_In And a.��ҳid = Pvid_In And a.����id = b.����id;
    End If;
  End Get_Pat_Info;
End;

/
