CREATE OR REPLACE Package Pkg_Status_Manage Is
  ----------------
  --״̬�������--
  ----------------
  --����״̬����
  Procedure Save_Status_Type(Input_In In Clob);
  --����״̬��λ
  Procedure Save_Status_Parts(Input_In In Clob);
  --����Ĭ�ϲ�λ
  Procedure Save_Default_Parts(Input_In In Clob);
  --ɾ��״̬��λ
  Procedure Del_Status_Parts(Input_In In Clob);
  --����״̬Ŀ¼
  Procedure Save_Status_List(Input_In In Clob);
  --ɾ��״̬Ŀ¼
  Procedure Del_Status_List(Input_In In Clob);
  --��������״̬
  Procedure Save_Status_Reject(Input_In In Clob);
  --ȡ������״̬
  Procedure Del_Status_Reject(Input_In In Clob);
  --����״̬����
  Procedure Save_Status_Cnds(Input_In In Clob);
  --ȡ��״̬����
  Procedure Del_Status_Cnds(Input_In In Clob);
  --����״̬��ϵ
  Procedure Save_Status_Relation(Input_In In Clob);
  --ȡ��״̬��ϵ
  Procedure Del_Status_Relation(Input_In In Clob);
  --���泡������
  Procedure Save_Envr_List(Input_In In Clob);
  --���泡��״̬
  Procedure Save_Envr_Status(Input_In In Clob);
  --ȡ������״̬
  Procedure Del_Envr_Status(Input_In In Clob);
End;

/


CREATE OR REPLACE Package Body Pkg_Status_Manage Is
  ----------------
  --״̬�������--
  ----------------
  Procedure Save_Status_Type(Input_In In Clob) Is
    --ͷע�Ϳ�ʼ-----------------------------------------------------------------------------------------
    --�������ƣ�����״̬����
    --����˵��������״̬����
    --���˵����jsonʾ��{"type_info":[{"type_id":"","type_name":"","modify_time":"","modifier":"","modifier_id":""}]}
    --����˵����
    --��д�ߣ�������
    --��дʱ�䣺2018-7-20
    --�汾��¼��1
    --ͷע�ͽ���-----------------------------------------------------------------------------------------
  Begin
    For r_Type In (Select Type_Id, Type_Name, Modify_Time, Modifier, Modifier_Id
                   From Json_Table(Input_In, '$.type_info[*]' Columns Type_Id Varchar2(36) Path '$."type_id"',
                                    Type_Name Varchar2(100) Path '$."type_name"',
                                    Modify_Time Varchar2(100) Path '$."modify_time"',
                                    Modifier Varchar2(100) Path '$."modifier"',
                                    Modifier_Id Varchar2(36) Path '$."modifier_id"')) Loop
      If r_Type.Type_Id Is Null Then
        Insert Into Status_Type
          (Type_Id, Type_Name, Last_Modifier, Last_Modifier_Id, Last_Modify_Time)
          Select Sys_Guid(), r_Type.Type_Name, r_Type.Modifier, r_Type.Modifier_Id,
                 Decode(r_Type.Modify_Time, Null, Sysdate, To_Date(r_Type.Modify_Time, 'yyyy-mm-dd hh24:mi:ss'))
          From Dual;
      Else
        Update Status_Type A
        Set a.Type_Name = r_Type.Type_Name, a.Last_Modifier = r_Type.Modifier, a.Last_Modifier_Id = r_Type.Modifier_Id,
            a.Last_Modify_Time = Decode(r_Type.Modify_Time, Null, Sysdate,
                                         To_Date(r_Type.Modify_Time, 'yyyy-mm-dd hh24:mi:ss'))
        Where a.Type_Id = r_Type.Type_Id;
      End If;
    End Loop;
  End;

  Procedure Save_Status_Parts(Input_In In Clob) Is
    --ͷע�Ϳ�ʼ-----------------------------------------------------------------------------------------
    --�������ƣ�����״̬��λ
    --����˵��������״̬��λ(��λĿ¼���ϵ)
    --���˵����jsonʾ��{"status_info":[{"status_id":"","modify_time":"","modifier":"","modifier_id":""}],
    --                   "parts_info":[{"parts_id":"","parts_name":"",""default:""}]}
    --����˵����
    --��д�ߣ�������
    --��дʱ�䣺2018-7-20
    --�汾��¼��1
    --ͷע�ͽ���-----------------------------------------------------------------------------------------
    v_Parts_Id  Varchar2(36);
    v_Status_Id Varchar2(36);
  Begin
    For r_Status In (Select Status_Id, Modify_Time, Modifier, Modifier_Id
                     From Json_Table(Input_In, '$.status_info[*]' Columns Status_Id Varchar2(36) Path '$."status_id"',
                                      Modify_Time Varchar2(100) Path '$."modify_time"',
                                      Modifier Varchar2(100) Path '$."modifier"',
                                      Modifier_Id Varchar2(36) Path '$."modifier_id"')) Loop
      v_Status_Id := r_Status.Status_Id;
      Update Status_List A
      Set a.Last_Modifier = r_Status.Modifier, a.Last_Modifier_Id = r_Status.Modifier_Id,
          a.Last_Modify_Time = Decode(r_Status.Modify_Time, Null, Sysdate,
                                       To_Date(r_Status.Modify_Time, 'yyyy-mm-dd hh24:mi:ss'))
      Where a.Status_Id = v_Status_Id;
    End Loop;
    For r_Parts In (Select Parts_Id, Parts_Name, Default_Sign
                    From Json_Table(Input_In, '$.parts_info[*]' Columns Parts_Id Varchar2(36) Path '$."parts_id"',
                                     Parts_Name Varchar2(100) Path '$."parts_name"',
                                     Default_Sign Number(1) Path '$."default"')) Loop
      If r_Parts.Parts_Id Is Null Then
        v_Parts_Id := Sys_Guid();
        Insert Into Parts_List
          (Parts_Id, Parts_Name)
          Select v_Parts_Id, r_Parts.Parts_Name From Dual;
        Insert Into Status_Parts_Vs
          (Status_Id, Parts_Id, Default_Sign)
          Select v_Status_Id, v_Parts_Id, Nvl(r_Parts.Default_Sign, 0) From Dual;
      Else
        Insert Into Status_Parts_Vs
          (Status_Id, Parts_Id, Default_Sign)
          Select v_Status_Id, r_Parts.Parts_Id, Nvl(r_Parts.Default_Sign, 0) From Dual;
      End If;
    End Loop;
  End;

  Procedure Save_Default_Parts(Input_In In Clob) Is
    --ͷע�Ϳ�ʼ-----------------------------------------------------------------------------------------
    --�������ƣ�����Ĭ�ϲ�λ
    --����˵��������Ĭ�ϲ�λ
    --���˵����jsonʾ��{"status_info":[{"status_id":"","modify_time":"","modifier":"","modifier_id":""}],
    --                   "parts_info":[{"parts_id":"","parts_name":"",""default:""}]}
    --����˵����
    --��д�ߣ�������
    --��дʱ�䣺2018-7-30
    --�汾��¼��1
    --ͷע�ͽ���-----------------------------------------------------------------------------------------
    v_Status_Id Varchar2(36);
  Begin
    For r_Status In (Select Status_Id, Modify_Time, Modifier, Modifier_Id
                     From Json_Table(Input_In, '$.status_info[*]' Columns Status_Id Varchar2(36) Path '$."status_id"',
                                      Modify_Time Varchar2(100) Path '$."modify_time"',
                                      Modifier Varchar2(100) Path '$."modifier"',
                                      Modifier_Id Varchar2(36) Path '$."modifier_id"')) Loop
      v_Status_Id := r_Status.Status_Id;
      Update Status_List A
      Set a.Last_Modifier = r_Status.Modifier, a.Last_Modifier_Id = r_Status.Modifier_Id,
          a.Last_Modify_Time = Decode(r_Status.Modify_Time, Null, Sysdate,
                                       To_Date(r_Status.Modify_Time, 'yyyy-mm-dd hh24:mi:ss'))
      Where a.Status_Id = v_Status_Id;
    End Loop;
    For r_Parts In (Select Parts_Id, Parts_Name, Default_Sign
                    From Json_Table(Input_In, '$.parts_info[*]' Columns Parts_Id Varchar2(36) Path '$."parts_id"',
                                     Parts_Name Varchar2(100) Path '$."parts_name"',
                                     Default_Sign Number(1) Path '$."default"')) Loop
      If r_Parts.Default_Sign = 1 Then
        Update Status_Parts_Vs A Set a.Default_Sign = 0 Where a.Status_Id = v_Status_Id;
      End If;
      Update Status_Parts_Vs A
      Set a.Default_Sign = Nvl(r_Parts.Default_Sign, 0)
      Where a.Status_Id = v_Status_Id And a.Parts_Id = r_Parts.Parts_Id;
    
    End Loop;
  End;

  Procedure Del_Status_Parts(Input_In In Clob) Is
    --ͷע�Ϳ�ʼ-----------------------------------------------------------------------------------------
    --�������ƣ�ɾ��״̬��λ
    --����˵����ɾ��״̬��λ
    --���˵����jsonʾ��{"status_info":[{"status_id":"","modify_time":"","modifier":"","modifier_id":""}],
    --                   "parts_info":[{"parts_id":""}]}
    --����˵����
    --��д�ߣ�������
    --��дʱ�䣺2018-7-20
    --�汾��¼��1
    --ͷע�ͽ���-----------------------------------------------------------------------------------------
    v_Status_Id Varchar2(36);
  Begin
    For r_Status In (Select Status_Id, Modify_Time, Modifier, Modifier_Id
                     From Json_Table(Input_In, '$.status_info[*]' Columns Status_Id Varchar2(36) Path '$."status_id"',
                                      Modify_Time Varchar2(100) Path '$."modify_time"',
                                      Modifier Varchar2(100) Path '$."modifier"',
                                      Modifier_Id Varchar2(36) Path '$."modifier_id"')) Loop
      v_Status_Id := r_Status.Status_Id;
      Update Status_List A
      Set a.Last_Modifier = r_Status.Modifier, a.Last_Modifier_Id = r_Status.Modifier_Id,
          a.Last_Modify_Time = Decode(r_Status.Modify_Time, Null, Sysdate,
                                       To_Date(r_Status.Modify_Time, 'yyyy-mm-dd hh24:mi:ss'))
      Where a.Status_Id = v_Status_Id;
    End Loop;
    For r_Parts In (Select Parts_Id
                    From Json_Table(Input_In, '$.parts_info[*]' Columns Parts_Id Varchar2(36) Path '$."parts_id"')) Loop
      Delete From Status_Parts_Vs Where Status_Id = v_Status_Id And Parts_Id = r_Parts.Parts_Id;
    End Loop;
  End;

  Procedure Save_Status_List(Input_In In Clob) Is
    --ͷע�Ϳ�ʼ-----------------------------------------------------------------------------------------
    --�������ƣ�����״̬Ŀ¼
    --����˵��������״̬Ŀ¼
    --���˵����jsonʾ��{"status_info":[{"status_id":"","status_type_id":"","status_name":"","status_prop":"","stdd_id":"",""modifier:"","modifier_id":"","modify_time":"","enable_sign":""}]}
    --����˵����
    --��д�ߣ�������
    --��дʱ�䣺2018-7-20
    --�汾��¼��1
    --ͷע�ͽ���-----------------------------------------------------------------------------------------
  Begin
    For r_Status In (Select Status_Id, Modify_Time, Modifier, Modifier_Id, Status_Type_Id, Status_Name, Status_Prop,
                            Stdd_Id, Enable_Sign
                     From Json_Table(Input_In, '$.status_info[*]' Columns Status_Id Varchar2(36) Path '$."status_id"',
                                      Status_Type_Id Varchar2(36) Path '$."status_type_id"',
                                      Status_Name Varchar2(100) Path '$."status_name"',
                                      Status_Prop Number(1) Path '$."status_prop"', Stdd_Id Varchar2(36) Path '$."stdd_id"',
                                      Modify_Time Varchar2(100) Path '$."modify_time"',
                                      Modifier Varchar2(100) Path '$."modifier"',
                                      Modifier_Id Varchar2(36) Path '$."modifier_id"',
                                      Enable_Sign Number(1) Path '$."enable_sign"')) Loop
      If r_Status.Status_Id Is Null Then
        --����
        Insert Into Status_List
          (Status_Id, Type_Id, Status_Name, Enable_Sign, Status_Prop, Stdd_Id, Last_Modifier, Last_Modifier_Id,
           Last_Modify_Time)
          Select Sys_Guid(), r_Status.Status_Type_Id, r_Status.Status_Name, r_Status.Enable_Sign, r_Status.Status_Prop,
                 r_Status.Stdd_Id, r_Status.Modifier, r_Status.Modifier_Id,
                 Decode(r_Status.Modify_Time, Null, Sysdate, To_Date(r_Status.Modify_Time, 'yyyy-mm-dd hh24:mi:ss'))
          From Dual;
      Else
        --�޸�
        Update Status_List A
        Set a.Type_Id = r_Status.Status_Type_Id, a.Status_Name = r_Status.Status_Name,
            a.Status_Prop = r_Status.Status_Prop, a.Stdd_Id = r_Status.Stdd_Id, a.Last_Modifier = r_Status.Modifier,
            a.Last_Modifier_Id = r_Status.Modifier_Id,
            a.Last_Modify_Time = Decode(r_Status.Modify_Time, Null, Sysdate,
                                         To_Date(r_Status.Modify_Time, 'yyyy-mm-dd hh24:mi:ss')),
            a.Enable_Sign = r_Status.Enable_Sign
        Where a.Status_Id = r_Status.Status_Id;
      End If;
    End Loop;
  End;

  Procedure Del_Status_List(Input_In In Clob) Is
    --ͷע�Ϳ�ʼ-----------------------------------------------------------------------------------------
    --�������ƣ�ɾ��״̬Ŀ¼
    --����˵����ɾ��״̬Ŀ¼
    --���˵����jsonʾ��{"status_info":[{"status_id":""}]}
    --����˵����
    --��д�ߣ�������
    --��дʱ�䣺2018-7-20
    --�汾��¼��1
    --ͷע�ͽ���-----------------------------------------------------------------------------------------
    n_Exists Number(1);
  Begin
    For r_Status In (Select Status_Id
                     From Json_Table(Input_In, '$.status_info[*]' Columns Status_Id Varchar2(36) Path '$."status_id"')) Loop
      Select Max(1) Into n_Exists From Pat_Status_Detail A Where a.Status_Id = r_Status.Status_Id;
      If Nvl(n_Exists, 0) <> 0 Then
        Raise_Application_Error(-20100, 'ѡ���״̬�Ѿ���ʹ��,�޷�ɾ����');
      End If;
      Delete From Status_List A Where a.Status_Id = r_Status.Status_Id;
    End Loop;
  End;

  Procedure Save_Status_Reject(Input_In In Clob) Is
    --ͷע�Ϳ�ʼ-----------------------------------------------------------------------------------------
    --�������ƣ���������״̬
    --����˵������������״̬
    --���˵����jsonʾ��{"status_info":[{"status_id":"","modify_time":"","modifier":"","modifier_id":""}],
    --                   "reject_info":[{"reject_id":""}]}
    --����˵����
    --��д�ߣ�������
    --��дʱ�䣺2018-7-20
    --�汾��¼��1
    --ͷע�ͽ���-----------------------------------------------------------------------------------------
    v_Status_Id Varchar2(36);
  Begin
    For r_Status In (Select Status_Id, Modify_Time, Modifier, Modifier_Id
                     From Json_Table(Input_In, '$.status_info[*]' Columns Status_Id Varchar2(36) Path '$."status_id"',
                                      Modify_Time Varchar2(100) Path '$."modify_time"',
                                      Modifier Varchar2(100) Path '$."modifier"',
                                      Modifier_Id Varchar2(36) Path '$."modifier_id"')) Loop
      v_Status_Id := r_Status.Status_Id;
      Update Status_List A
      Set a.Last_Modifier = r_Status.Modifier, a.Last_Modifier_Id = r_Status.Modifier_Id,
          a.Last_Modify_Time = Decode(r_Status.Modify_Time, Null, Sysdate,
                                       To_Date(r_Status.Modify_Time, 'yyyy-mm-dd hh24:mi:ss'))
      Where a.Status_Id = v_Status_Id;
    End Loop;
    For r_Reject In (Select Reject_Id
                     From Json_Table(Input_In, '$.reject_info[*]' Columns Reject_Id Varchar2(36) Path '$."reject_id"')) Loop
      Insert Into Reject_Status
        (Status_Id, Reject_Status_Id)
        Select v_Status_Id, r_Reject.Reject_Id From Dual;
    End Loop;
  End;

  Procedure Del_Status_Reject(Input_In In Clob) Is
    --ͷע�Ϳ�ʼ-----------------------------------------------------------------------------------------
    --�������ƣ�ȡ������״̬
    --����˵����ȡ������״̬
    --���˵����jsonʾ��{"status_info":[{"status_id":"","modify_time":"","modifier":"","modifier_id":""}],
    --                   "reject_info":[{"reject_id":""}]}
    --����˵����
    --��д�ߣ�������
    --��дʱ�䣺2018-7-20
    --�汾��¼��1
    --ͷע�ͽ���-----------------------------------------------------------------------------------------
    v_Status_Id Varchar2(36);
  Begin
    For r_Status In (Select Status_Id, Modify_Time, Modifier, Modifier_Id
                     From Json_Table(Input_In, '$.status_info[*]' Columns Status_Id Varchar2(36) Path '$."status_id"',
                                      Modify_Time Varchar2(100) Path '$."modify_time"',
                                      Modifier Varchar2(100) Path '$."modifier"',
                                      Modifier_Id Varchar2(36) Path '$."modifier_id"')) Loop
      v_Status_Id := r_Status.Status_Id;
      Update Status_List A
      Set a.Last_Modifier = r_Status.Modifier, a.Last_Modifier_Id = r_Status.Modifier_Id,
          a.Last_Modify_Time = Decode(r_Status.Modify_Time, Null, Sysdate,
                                       To_Date(r_Status.Modify_Time, 'yyyy-mm-dd hh24:mi:ss'))
      Where a.Status_Id = v_Status_Id;
    End Loop;
    For r_Reject In (Select Reject_Id
                     From Json_Table(Input_In, '$.reject_info[*]' Columns Reject_Id Varchar2(36) Path '$."reject_id"')) Loop
      Delete From Reject_Status A Where a.Status_Id = v_Status_Id And a.Reject_Status_Id = r_Reject.Reject_Id;
    End Loop;
  End;

  Procedure Save_Status_Cnds(Input_In In Clob) Is
    --ͷע�Ϳ�ʼ-----------------------------------------------------------------------------------------
    --�������ƣ�����״̬����
    --����˵��������״̬����
    --���˵����jsonʾ��{"status_info":[{"status_id":"","modify_time":"","modifier":"","modifier_id":""}],
    --                   "cnds_info":[{"cnds_type":"","cnds_value":""}]}
    --����˵����
    --��д�ߣ�������
    --��дʱ�䣺2018-7-20
    --�汾��¼��1
    --ͷע�ͽ���-----------------------------------------------------------------------------------------
    v_Status_Id Varchar2(36);
  Begin
    For r_Status In (Select Status_Id, Modify_Time, Modifier, Modifier_Id
                     From Json_Table(Input_In, '$.status_info[*]' Columns Status_Id Varchar2(36) Path '$."status_id"',
                                      Modify_Time Varchar2(100) Path '$."modify_time"',
                                      Modifier Varchar2(100) Path '$."modifier"',
                                      Modifier_Id Varchar2(36) Path '$."modifier_id"')) Loop
      v_Status_Id := r_Status.Status_Id;
      Update Status_List A
      Set a.Last_Modifier = r_Status.Modifier, a.Last_Modifier_Id = r_Status.Modifier_Id,
          a.Last_Modify_Time = Decode(r_Status.Modify_Time, Null, Sysdate,
                                       To_Date(r_Status.Modify_Time, 'yyyy-mm-dd hh24:mi:ss'))
      Where a.Status_Id = v_Status_Id;
    End Loop;
    For r_Cnds In (Select Cnds_Type, Cnds_Value
                   From Json_Table(Input_In, '$.cnds_info[*]' Columns Cnds_Type Number(1) Path '$."cnds_type"',
                                    Cnds_Value Varchar2(100) Path '$."cnds_value"')) Loop
      Insert Into Status_Cnds
        (Cnds_Id, Status_Id, Cnds_Type, Cnds_Value)
        Select Sys_Guid(), v_Status_Id, r_Cnds.Cnds_Type, r_Cnds.Cnds_Value From Dual;
    End Loop;
  End;

  Procedure Del_Status_Cnds(Input_In In Clob) Is
    --ͷע�Ϳ�ʼ-----------------------------------------------------------------------------------------
    --�������ƣ�ȡ��״̬����
    --����˵����ȡ��״̬����
    --���˵����jsonʾ��{"status_info":[{"status_id":"","modify_time":"","modifier":"","modifier_id":""}],
    --                   "cnds_info":[{"cnds_id":""}]}
    --����˵����
    --��д�ߣ�������
    --��дʱ�䣺2018-7-20
    --�汾��¼��1
    --ͷע�ͽ���-----------------------------------------------------------------------------------------
  Begin
    For r_Status In (Select Status_Id, Modify_Time, Modifier, Modifier_Id
                     From Json_Table(Input_In, '$.status_info[*]' Columns Status_Id Varchar2(36) Path '$."status_id"',
                                      Modify_Time Varchar2(100) Path '$."modify_time"',
                                      Modifier Varchar2(100) Path '$."modifier"',
                                      Modifier_Id Varchar2(36) Path '$."modifier_id"')) Loop
      Update Status_List A
      Set a.Last_Modifier = r_Status.Modifier, a.Last_Modifier_Id = r_Status.Modifier_Id,
          a.Last_Modify_Time = Decode(r_Status.Modify_Time, Null, Sysdate,
                                       To_Date(r_Status.Modify_Time, 'yyyy-mm-dd hh24:mi:ss'))
      Where a.Status_Id = r_Status.Status_Id;
    End Loop;
    For r_Cnds In (Select Cnds_Id
                   From Json_Table(Input_In, '$.cnds_info[*]' Columns Cnds_Id Varchar2(36) Path '$."cnds_id"')) Loop
      Delete From Status_Cnds A Where a.Cnds_Id = r_Cnds.Cnds_Id;
    End Loop;
  End;

  Procedure Save_Status_Relation(Input_In In Clob) Is
    --ͷע�Ϳ�ʼ-----------------------------------------------------------------------------------------
    --�������ƣ�����״̬��ϵ
    --����˵��������״̬��ϵ
    --���˵����jsonʾ��{"status_info":[{"status_id":"","modify_time":"","modifier":"","modifier_id":""}],
    --                   "relation_info":[{"parent_status_id":""}]}
    --����˵����
    --��д�ߣ�������
    --��дʱ�䣺2018-7-20
    --�汾��¼��1
    --ͷע�ͽ���-----------------------------------------------------------------------------------------
    v_Status_Id Varchar2(36);
  Begin
    For r_Status In (Select Status_Id, Modify_Time, Modifier, Modifier_Id
                     From Json_Table(Input_In, '$.status_info[*]' Columns Status_Id Varchar2(36) Path '$."status_id"',
                                      Modify_Time Varchar2(100) Path '$."modify_time"',
                                      Modifier Varchar2(100) Path '$."modifier"',
                                      Modifier_Id Varchar2(36) Path '$."modifier_id"')) Loop
      v_Status_Id := r_Status.Status_Id;
      Update Status_List A
      Set a.Last_Modifier = r_Status.Modifier, a.Last_Modifier_Id = r_Status.Modifier_Id,
          a.Last_Modify_Time = Decode(r_Status.Modify_Time, Null, Sysdate,
                                       To_Date(r_Status.Modify_Time, 'yyyy-mm-dd hh24:mi:ss'))
      Where a.Status_Id = v_Status_Id;
    End Loop;
    For r_Relation In (Select Parent_Status_Id
                       From Json_Table(Input_In,
                                        '$.relation_info[*]' Columns Parent_Status_Id Varchar2(36) Path
                                         '$."parent_status_id"')) Loop
      Insert Into Status_Relation
        (Status_Id, Parent_Status_Id)
        Select v_Status_Id, r_Relation.Parent_Status_Id From Dual;
    End Loop;
  End;

  Procedure Del_Status_Relation(Input_In In Clob) Is
    --ͷע�Ϳ�ʼ-----------------------------------------------------------------------------------------
    --�������ƣ�ȡ��״̬��ϵ
    --����˵����ȡ��״̬��ϵ
    --���˵����jsonʾ��{"status_info":[{"status_id":"","modify_time":"","modifier":"","modifier_id":""}],
    --                   "relation_info":[{"parent_status_id":""}]}
    --����˵����
    --��д�ߣ�������
    --��дʱ�䣺2018-7-20
    --�汾��¼��1
    --ͷע�ͽ���-----------------------------------------------------------------------------------------
    v_Status_Id Varchar2(36);
  Begin
    For r_Status In (Select Status_Id, Modify_Time, Modifier, Modifier_Id
                     From Json_Table(Input_In, '$.status_info[*]' Columns Status_Id Varchar2(36) Path '$."status_id"',
                                      Modify_Time Varchar2(100) Path '$."modify_time"',
                                      Modifier Varchar2(100) Path '$."modifier"',
                                      Modifier_Id Varchar2(36) Path '$."modifier_id"')) Loop
      v_Status_Id := r_Status.Status_Id;
      Update Status_List A
      Set a.Last_Modifier = r_Status.Modifier, a.Last_Modifier_Id = r_Status.Modifier_Id,
          a.Last_Modify_Time = Decode(r_Status.Modify_Time, Null, Sysdate,
                                       To_Date(r_Status.Modify_Time, 'yyyy-mm-dd hh24:mi:ss'))
      Where a.Status_Id = v_Status_Id;
    End Loop;
    For r_Relation In (Select Parent_Status_Id
                       From Json_Table(Input_In,
                                        '$.relation_info[*]' Columns Parent_Status_Id Varchar2(36) Path
                                         '$."parent_status_id"')) Loop
      Delete From Status_Relation A
      Where a.Status_Id = v_Status_Id And a.Parent_Status_Id = r_Relation.Parent_Status_Id;
    End Loop;
  End;

  Procedure Save_Envr_List(Input_In In Clob) Is
    --ͷע�Ϳ�ʼ-----------------------------------------------------------------------------------------
    --�������ƣ����泡����Ϣ
    --����˵�������泡����Ϣ
    --���˵����jsonʾ��{"envr_info":[{"envr_id":"","modifier":"","modifier_id":"","modify_time":"","enable_sign":""}]}
    --����˵����
    --��д�ߣ�������
    --��дʱ�䣺2018-7-20
    --�汾��¼��1
    --ͷע�ͽ���-----------------------------------------------------------------------------------------
    v_Envr_Id Varchar2(36);
  Begin
    For r_Envr In (Select Envr_Id, Modifier, Modifier_Id, Modify_Time, Enable_Sign
                   From Json_Table(Input_In, '$.envr_info[*]' Columns Envr_Id Varchar2(36) Path '$."envr_id"',
                                    Modifier_Id Varchar2(36) Path '$."modifier_id"',
                                    Modifier Varchar2(100) Path '$."modifier"',
                                    Modify_Time Varchar2(100) Path '$."modify_time"',
                                    Enable_Sign Varchar2(100) Path '$."enable_sign"')) Loop
      v_Envr_Id := r_Envr.Envr_Id;
      Update Envr_List A
      Set a.Last_Modifier = r_Envr.Modifier, a.Last_Modifier_Id = r_Envr.Modifier_Id,
          a.Last_Modify_Time = Decode(r_Envr.Modify_Time, Null, Sysdate,
                                       To_Date(r_Envr.Modify_Time, 'yyyy-mm-dd hh24:mi:ss')),
          a.Enable_Sign = r_Envr.Enable_Sign
      Where a.Envr_Id = v_Envr_Id;
    End Loop;
  End;

  Procedure Save_Envr_Status(Input_In In Clob) Is
    --ͷע�Ϳ�ʼ-----------------------------------------------------------------------------------------
    --�������ƣ����泡��״̬
    --����˵�������泡��״̬
    --���˵����jsonʾ��{"envr_info":[{"envr_id":"","modifier":"","modifier_id":"","modify_time":""}],
    --                   "status_info":[{"status_id":"","sn":""}]}
    --����˵����
    --��д�ߣ�������
    --��дʱ�䣺2018-7-24
    --�汾��¼��1
    --ͷע�ͽ���-----------------------------------------------------------------------------------------
    v_Envr_Id Varchar2(36);
  Begin
    For r_Envr In (Select Envr_Id, Modifier, Modifier_Id, Modify_Time
                   From Json_Table(Input_In, '$.envr_info[*]' Columns Envr_Id Varchar2(36) Path '$."envr_id"',
                                    Modifier_Id Varchar2(36) Path '$."modifier_id"',
                                    Modifier Varchar2(100) Path '$."modifier"',
                                    Modify_Time Varchar2(100) Path '$."modify_time"')) Loop
      v_Envr_Id := r_Envr.Envr_Id;
      Update Envr_List A
      Set a.Last_Modifier = r_Envr.Modifier, a.Last_Modifier_Id = r_Envr.Modifier_Id,
          a.Last_Modify_Time = Decode(r_Envr.Modify_Time, Null, Sysdate,
                                       To_Date(r_Envr.Modify_Time, 'yyyy-mm-dd hh24:mi:ss'))
      Where a.Envr_Id = v_Envr_Id;
    End Loop;
    For r_Status In (Select Status_Id, Sn
                     From Json_Table(Input_In, '$.status_info[*]' Columns Status_Id Varchar2(36) Path '$."status_id"',
                                      Sn Number(3) Path '$."sn"')) Loop
      Insert Into Envr_Status_Vs
        (Envr_Id, Status_Id, Sn)
        Select v_Envr_Id, r_Status.Status_Id, r_Status.Sn From Dual;
    End Loop;
  End;

  Procedure Del_Envr_Status(Input_In In Clob) Is
    --ͷע�Ϳ�ʼ-----------------------------------------------------------------------------------------
    --�������ƣ�ȡ������״̬
    --����˵����ȡ������״̬
    --���˵����jsonʾ��{"envr_info":[{"envr_id":"","modifier":"","modifier_id":"","modify_time":""}],
    --                   "status_info":[{"status_id":""}]}
    --����˵����
    --��д�ߣ�������
    --��дʱ�䣺2018-7-24
    --�汾��¼��1
    --ͷע�ͽ���-----------------------------------------------------------------------------------------
    v_Envr_Id Varchar2(36);
  Begin
    For r_Envr In (Select Envr_Id, Modifier, Modifier_Id, Modify_Time
                   From Json_Table(Input_In, '$.envr_info[*]' Columns Envr_Id Varchar2(36) Path '$."envr_id"',
                                    Modifier_Id Varchar2(36) Path '$."modifier_id"',
                                    Modifier Varchar2(100) Path '$."modifier"',
                                    Modify_Time Varchar2(100) Path '$."modify_time"')) Loop
      v_Envr_Id := r_Envr.Envr_Id;
      Update Envr_List A
      Set a.Last_Modifier = r_Envr.Modifier, a.Last_Modifier_Id = r_Envr.Modifier_Id,
          a.Last_Modify_Time = Decode(r_Envr.Modify_Time, Null, Sysdate,
                                       To_Date(r_Envr.Modify_Time, 'yyyy-mm-dd hh24:mi:ss'))
      Where a.Envr_Id = v_Envr_Id;
    End Loop;
    For r_Status In (Select Status_Id
                     From Json_Table(Input_In, '$.status_info[*]' Columns Status_Id Varchar2(36) Path '$."status_id"')) Loop
      Delete From Envr_Status_Vs A Where a.Envr_Id = v_Envr_Id And a.Status_Id = r_Status.Status_Id;
    End Loop;
  End;

End;

/
