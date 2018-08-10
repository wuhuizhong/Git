--------------------------------------------------------
--  文件已创建 - 星期二-七月-24-2018   
--------------------------------------------------------
--------------------------------------------------------
--  DDL for Procedure PARAMETER_SETTING
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "ZLRECIPE"."PARAMETER_SETTING" 
-- 传入当前操作人员 code 、各个参数的值
-- 准备实现，前台传入为空则不修改，
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
v_当前时间 date;

v_合理用药 varchar2(500);
v_审方服务 varchar2(500);
v_上午上班 varchar2(500);
v_上午下班 varchar2(500);
v_下午上班 varchar2(500);
v_下午下班 varchar2(500);
v_超时时长 varchar2(500);
Begin 
  v_当前时间:=sysdate;
  SELECT max(USER_NAME) INTO V_USER_NAME FROM RECIPE_USER WHERE  USER_CODE=USER_CODE_IN;
  --查询当前数据库各参数的值
  select max(para_value) into v_合理用药 from recipe_reviewe_para where PARA_NAME = '合理用药服务器';
  select max(para_value) into v_审方服务 from recipe_reviewe_para where PARA_NAME = '审方服务器地址';
  select max(para_value) into v_上午上班 from recipe_reviewe_para where PARA_NAME = '上午上班时间';
  select max(para_value) into v_上午下班 from recipe_reviewe_para where PARA_NAME = '上午下班时间';
  select max(para_value) into v_下午上班 from recipe_reviewe_para where PARA_NAME = '下午上班时间';
  select max(para_value) into v_下午下班 from recipe_reviewe_para where PARA_NAME = '下午下班时间';
  select max(para_value) into v_超时时长 from recipe_reviewe_para where PARA_NAME = '超时自动通过间隔时长';
  
  -- 修改 合理用药服务器
  if ZLKBC_SERVER_IN <> v_合理用药 then
  UPDATE recipe_reviewe_para
     SET para_value     = ZLKBC_SERVER_IN,
         LAST_EDITOR    = V_USER_NAME,
         LAST_EDIT_ITME = v_当前时间
   where PARA_NAME = '合理用药服务器';
   end if ;
  --修改 审方服务器地址
  if ZLRECIPE_ADDRESS_IN <> v_审方服务 then
  UPDATE recipe_reviewe_para
     SET para_value     = ZLRECIPE_ADDRESS_IN, 
         LAST_EDITOR    = V_USER_NAME,
         LAST_EDIT_ITME = v_当前时间
   where PARA_NAME = '审方服务器地址';
   end if;
  --修改 上午上班时间
  if AM_BUSINESS_HOURS_IN <> v_上午上班 then
  UPDATE recipe_reviewe_para
     SET para_value     = AM_BUSINESS_HOURS_IN,
         LAST_EDITOR    = V_USER_NAME,
         LAST_EDIT_ITME = v_当前时间
   where PARA_NAME = '上午上班时间';
   end if;
  --修改 上午下班时间
  if AM_CLOSING_TIME_IN <> v_上午下班 then
  UPDATE recipe_reviewe_para
     SET para_value     = AM_CLOSING_TIME_IN,
         LAST_EDITOR    = V_USER_NAME,
         LAST_EDIT_ITME = v_当前时间
   where PARA_NAME = '上午下班时间';
   end if;
  --修改 下午上班时间
  if PM_BUSINESS_HOURS_IN <> v_下午上班 then
  UPDATE recipe_reviewe_para
     SET para_value     = PM_BUSINESS_HOURS_IN,
         LAST_EDITOR    = V_USER_NAME,
         LAST_EDIT_ITME = v_当前时间
   where PARA_NAME = '下午上班时间';
   end if;
  --修改 下午下班时间
  if PM_CLOSING_TIME_IN <> v_下午下班 then
  UPDATE recipe_reviewe_para
     SET para_value     = PM_CLOSING_TIME_IN,
         LAST_EDITOR    = V_USER_NAME,
         LAST_EDIT_ITME = v_当前时间
   where PARA_NAME = '下午下班时间';
   end if;
  --修改 超时自动通过间隔时长
  if OVERTIME_DURATION_IN <> v_超时时长 then
  UPDATE recipe_reviewe_para
     SET para_value     = OVERTIME_DURATION_IN,
         LAST_EDITOR    = V_USER_NAME,
         LAST_EDIT_ITME = v_当前时间
   where PARA_NAME = '超时自动通过间隔时长';
 end if;
 
Exception
  When Others Then
    null;
    --zl_ErrorCenter(SQLCode, SQLErrM);
End parameter_setting;

        
       

/
