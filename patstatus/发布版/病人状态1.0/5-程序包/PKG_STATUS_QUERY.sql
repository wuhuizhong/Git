CREATE OR REPLACE Package Pkg_Status_Query Is
  ----------------
  --״̬��ѯ����--
  ----------------
  --״̬Ŀ¼��ѯ
  Procedure Get_Status_List
  (
    Type_In    In Varchar2 := Null,
    Output_Out Out Sys_Refcursor
  );
  --����Ŀ¼��ѯ
  Procedure Get_Envr_List(Output_Out Out Sys_Refcursor);
  --����״̬��ѯ
  Procedure Get_Pat_Status
  (
    Pati_Id_In In Varchar2,
    Output_Out Out Sys_Refcursor
  );
End;

/


CREATE OR REPLACE Package Body Pkg_Status_Query Is
  ----------------
  --״̬��ѯ����--
  ----------------
  Procedure Get_Status_List
  --ͷע�Ϳ�ʼ-----------------------------------------------------------------------------------------
    --�������ƣ�״̬Ŀ¼��ѯ
    --����˵����״̬Ŀ¼��ѯ
    --���˵����status_type_id״̬����ID
    --����˵�����α�ʾ��:Type_Name, Status_Id, Status_Name
    --��д�ߣ�������
    --��дʱ�䣺2018-7-24
    --�汾��¼��1
    --ͷע�ͽ���-----------------------------------------------------------------------------------------
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
    --����ʽ����ʱ������JSON
    Apex_Json.Open_Object;
    Apex_Json.Write('status_list', Output_Out);
    Apex_Json.Close_Object;
  End;

  Procedure Get_Envr_List
  --ͷע�Ϳ�ʼ-----------------------------------------------------------------------------------------
    --�������ƣ�����Ŀ¼��ѯ
    --����˵��������Ŀ¼��ѯ
    --���˵��:
    --����˵�����α�ʾ��:Envr_Id, Envr_Name, Envr_Desc
    --��д�ߣ�������
    --��дʱ�䣺2018-7-24
    --�汾��¼��1
    --ͷע�ͽ���-----------------------------------------------------------------------------------------
  (Output_Out Out Sys_Refcursor) Is
  Begin
    Open Output_Out For
      Select a.Envr_Id, a.Envr_Name, a.Envr_Desc From Envr_List A Where a.Enable_Sign = 1;
    --����ʽ����ʱ������JSON
    Apex_Json.Open_Object;
    Apex_Json.Write('envr_list', Output_Out);
    Apex_Json.Close_Object;
  End;

  Procedure Get_Pat_Status
  --ͷע�Ϳ�ʼ-----------------------------------------------------------------------------------------
    --�������ƣ�����״̬��ѯ
    --����˵��������״̬��ѯ
    --���˵��: ����ID
    --����˵�����α�ʾ��:Status_Id, Status_Name, Status_Situation, Status_Begin_Date, Status_End_Date,
    --                   Related_Parts_Id, Related_Parts
    --��д�ߣ�������
    --��дʱ�䣺2018-7-24
    --�汾��¼��1
    --ͷע�ͽ���-----------------------------------------------------------------------------------------
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
  
    --����ʽ����ʱ������JSON
    Apex_Json.Open_Object;
    Apex_Json.Write('patient_status', Output_Out);
    Apex_Json.Close_Object;
  End;

End;

/
