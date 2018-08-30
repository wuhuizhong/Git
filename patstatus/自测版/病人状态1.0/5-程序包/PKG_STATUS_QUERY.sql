CREATE OR REPLACE Package Pkg_Status_Query Is
  ----------------
  --状态查询服务--
  ----------------
  --状态目录查询
  Procedure Get_Status_List
  (
    Type_In    In Varchar2 := Null,
    Output_Out Out Sys_Refcursor
  );
  --场景目录查询
  Procedure Get_Envr_List(Output_Out Out Sys_Refcursor);
  --病人状态查询
  Procedure Get_Pat_Status
  (
    Pati_Id_In In Varchar2,
    Output_Out Out Sys_Refcursor
  );
End;

/


CREATE OR REPLACE Package Body Pkg_Status_Query Is
  ----------------
  --状态查询服务--
  ----------------
  Procedure Get_Status_List
  --头注释开始-----------------------------------------------------------------------------------------
    --方法名称：状态目录查询
    --功能说明：状态目录查询
    --入参说明：status_type_id状态类型ID
    --出参说明：游标示例:Type_Name, Status_Id, Status_Name
    --编写者：刘尔旋
    --编写时间：2018-7-24
    --版本记录：1
    --头注释结束-----------------------------------------------------------------------------------------
  (
    Type_In    In Varchar2 := Null,
    Output_Out Out Sys_Refcursor
  ) Is
  Begin
    If Type_In Is Null Then
      Open Output_Out For
        Select b.Type_Name, a.Status_Id, a.Status_Name
        From Status_List A, Status_Type B
        Where a.Enable_Sign = 1 And a.Type_Id = b.Type_Id And a.Enable_Sign = 1;
    Else
      Open Output_Out For
        Select b.Type_Name, a.Status_Id, a.Status_Name
        From Status_List A, Status_Type B
        Where a.Enable_Sign = 1 And a.Type_Id = b.Type_Id And a.Type_Id = Type_In And a.Enable_Sign = 1;
    End If;
    --服务方式调用时，返回JSON
    Apex_Json.Open_Object;
    Apex_Json.Write('status_list', Output_Out);
    Apex_Json.Close_Object;
  End;

  Procedure Get_Envr_List
  --头注释开始-----------------------------------------------------------------------------------------
    --方法名称：场景目录查询
    --功能说明：场景目录查询
    --入参说明:
    --出参说明：游标示例:Envr_Id, Envr_Name, Envr_Desc
    --编写者：刘尔旋
    --编写时间：2018-7-24
    --版本记录：1
    --头注释结束-----------------------------------------------------------------------------------------
  (Output_Out Out Sys_Refcursor) Is
  Begin
    Open Output_Out For
      Select a.Envr_Id, a.Envr_Name, a.Envr_Desc From Envr_List A Where a.Enable_Sign = 1;
    --服务方式调用时，返回JSON
    Apex_Json.Open_Object;
    Apex_Json.Write('envr_list', Output_Out);
    Apex_Json.Close_Object;
  End;

  Procedure Get_Pat_Status
  --头注释开始-----------------------------------------------------------------------------------------
    --方法名称：病人状态查询
    --功能说明：病人状态查询
    --入参说明: 病人ID
    --出参说明：游标示例:Status_Id, Status_Name, Status_Situation, Status_Begin_Date, Status_End_Date,
    --                   Related_Parts_Id, Related_Parts
    --编写者：刘尔旋
    --编写时间：2018-7-24
    --版本记录：1
    --头注释结束-----------------------------------------------------------------------------------------
  (
    Pati_Id_In In Varchar2,
    Output_Out Out Sys_Refcursor
  ) Is
  Begin
    Open Output_Out For
      Select a.Status_Id, a.Status_Name, a.Status_Situation, a.Status_Begin_Date, a.Status_End_Date, a.Related_Parts_Id,
             a.Related_Parts
      From Pat_Status A, Status_List B
      Where a.Pid = Pati_Id_In And a.Status_Id = b.Status_Id And
            (b.Status_Prop In (1, 2) Or (b.Status_Prop = 3 And Sysdate Between Nvl(a.Status_Begin_Date, Sysdate) And
            Nvl(a.Status_End_Date, Sysdate)));
  
    --服务方式调用时，返回JSON
    Apex_Json.Open_Object;
    Apex_Json.Write('patient_status', Output_Out);
    Apex_Json.Close_Object;
  End;

End;

/
