--------------------------------------------------------
--  �ļ��Ѵ��� - ���ڶ�-����-24-2018   
--------------------------------------------------------
--------------------------------------------------------
--  DDL for Procedure PARAMETER_SETTING
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "ZLRECIPE"."PARAMETER_SETTING" 
-- ���뵱ǰ������Ա code ������������ֵ
-- ׼��ʵ�֣�ǰ̨����Ϊ�����޸ģ�
(
 ZLKBC_SERVER_IN in varchar2,
 ZLRECIPE_ADDRESS_IN IN VARCHAR2,
 AM_BUSINESS_HOURS_IN IN VARCHAR2,
 AM_CLOSING_TIME_IN IN VARCHAR2,
 PM_BUSINESS_HOURS_IN IN VARCHAR2,
 PM_CLOSING_TIME_IN IN VARCHAR2,
 OVERTIME_DURATION_IN IN VARCHAR2,
 --DEPT_STATUS number,
 USER_CODE_IN in varchar2
)
is
V_USER_NAME varchar2(500);
v_��ǰʱ�� date;

v_������ҩ varchar2(500);
v_�󷽷��� varchar2(500);
v_�����ϰ� varchar2(500);
v_�����°� varchar2(500);
v_�����ϰ� varchar2(500);
v_�����°� varchar2(500);
v_��ʱʱ�� varchar2(500);
Begin 
  v_��ǰʱ��:=sysdate;
  SELECT max(USER_NAME) INTO V_USER_NAME FROM RECIPE_USER WHERE  USER_CODE=USER_CODE_IN;
  --��ѯ��ǰ���ݿ��������ֵ
  select max(para_value) into v_������ҩ from recipe_reviewe_para where PARA_NAME = '������ҩ������';
  select max(para_value) into v_�󷽷��� from recipe_reviewe_para where PARA_NAME = '�󷽷�������ַ';
  select max(para_value) into v_�����ϰ� from recipe_reviewe_para where PARA_NAME = '�����ϰ�ʱ��';
  select max(para_value) into v_�����°� from recipe_reviewe_para where PARA_NAME = '�����°�ʱ��';
  select max(para_value) into v_�����ϰ� from recipe_reviewe_para where PARA_NAME = '�����ϰ�ʱ��';
  select max(para_value) into v_�����°� from recipe_reviewe_para where PARA_NAME = '�����°�ʱ��';
  select max(para_value) into v_��ʱʱ�� from recipe_reviewe_para where PARA_NAME = '��ʱ�Զ�ͨ�����ʱ��';
  
  -- �޸� ������ҩ������
  if ZLKBC_SERVER_IN <> v_������ҩ then
  UPDATE recipe_reviewe_para
     SET para_value     = ZLKBC_SERVER_IN,
         LAST_EDITOR    = V_USER_NAME,
         LAST_EDIT_ITME = v_��ǰʱ��
   where PARA_NAME = '������ҩ������';
   end if ;
  --�޸� �󷽷�������ַ
  if ZLRECIPE_ADDRESS_IN <> v_�󷽷��� then
  UPDATE recipe_reviewe_para
     SET para_value     = ZLRECIPE_ADDRESS_IN, 
         LAST_EDITOR    = V_USER_NAME,
         LAST_EDIT_ITME = v_��ǰʱ��
   where PARA_NAME = '�󷽷�������ַ';
   end if;
  --�޸� �����ϰ�ʱ��
  if AM_BUSINESS_HOURS_IN <> v_�����ϰ� then
  UPDATE recipe_reviewe_para
     SET para_value     = AM_BUSINESS_HOURS_IN,
         LAST_EDITOR    = V_USER_NAME,
         LAST_EDIT_ITME = v_��ǰʱ��
   where PARA_NAME = '�����ϰ�ʱ��';
   end if;
  --�޸� �����°�ʱ��
  if AM_CLOSING_TIME_IN <> v_�����°� then
  UPDATE recipe_reviewe_para
     SET para_value     = AM_CLOSING_TIME_IN,
         LAST_EDITOR    = V_USER_NAME,
         LAST_EDIT_ITME = v_��ǰʱ��
   where PARA_NAME = '�����°�ʱ��';
   end if;
  --�޸� �����ϰ�ʱ��
  if PM_BUSINESS_HOURS_IN <> v_�����ϰ� then
  UPDATE recipe_reviewe_para
     SET para_value     = PM_BUSINESS_HOURS_IN,
         LAST_EDITOR    = V_USER_NAME,
         LAST_EDIT_ITME = v_��ǰʱ��
   where PARA_NAME = '�����ϰ�ʱ��';
   end if;
  --�޸� �����°�ʱ��
  if PM_CLOSING_TIME_IN <> v_�����°� then
  UPDATE recipe_reviewe_para
     SET para_value     = PM_CLOSING_TIME_IN,
         LAST_EDITOR    = V_USER_NAME,
         LAST_EDIT_ITME = v_��ǰʱ��
   where PARA_NAME = '�����°�ʱ��';
   end if;
  --�޸� ��ʱ�Զ�ͨ�����ʱ��
  if OVERTIME_DURATION_IN <> v_��ʱʱ�� then
  UPDATE recipe_reviewe_para
     SET para_value     = OVERTIME_DURATION_IN,
         LAST_EDITOR    = V_USER_NAME,
         LAST_EDIT_ITME = v_��ǰʱ��
   where PARA_NAME = '��ʱ�Զ�ͨ�����ʱ��';
 end if;
 
Exception
  When Others Then
    null;
    --zl_ErrorCenter(SQLCode, SQLErrM);
End parameter_setting;

        
       

/
