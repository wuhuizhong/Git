--------------------------------------------------------
--  文件已创建 - 星期四-八月-30-2018   
--------------------------------------------------------
REM INSERTING into PATSTATUS.ENVR_LIST
SET DEFINE OFF;
Insert into PATSTATUS.ENVR_LIST (ENVR_ID,ENVR_NAME,ENVR_DESC,ENABLE_SIGN,LAST_MODIFIER,LAST_MODIFIER_ID,LAST_MODIFY_TIME) values ('10','门诊医生记录','门诊医生工作站调用进行的病人状态记录',1,'Admin',null,to_date('23-8月 -18','DD-MON-RR'));
Insert into PATSTATUS.ENVR_LIST (ENVR_ID,ENVR_NAME,ENVR_DESC,ENABLE_SIGN,LAST_MODIFIER,LAST_MODIFIER_ID,LAST_MODIFY_TIME) values ('11','住院医生记录','住院医生工作站调用进行的病人状态记录',1,'Admin',null,to_date('23-8月 -18','DD-MON-RR'));
Insert into PATSTATUS.ENVR_LIST (ENVR_ID,ENVR_NAME,ENVR_DESC,ENABLE_SIGN,LAST_MODIFIER,LAST_MODIFIER_ID,LAST_MODIFY_TIME) values ('1','住院入院','住院病人入院时进行的病人状态记录',1,null,null,to_date('31-7月 -18','DD-MON-RR'));
Insert into PATSTATUS.ENVR_LIST (ENVR_ID,ENVR_NAME,ENVR_DESC,ENABLE_SIGN,LAST_MODIFIER,LAST_MODIFIER_ID,LAST_MODIFY_TIME) values ('2','门诊就诊','门诊医生站在接诊门诊病人时,进行的病人状态记录',1,null,null,to_date('31-7月 -18','DD-MON-RR'));
