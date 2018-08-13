--------------------------------------------------------
--  文件已创建 - 星期一-八月-13-2018   
--------------------------------------------------------
--------------------------------------------------------
--  DDL for View V_ENVR_STATUS
--------------------------------------------------------

  CREATE OR REPLACE FORCE EDITIONABLE VIEW "PATSTATUS"."V_ENVR_STATUS" ("ENVR_ID", "ENVR_NAME", "STATUS_NAME", "TYPE_NAME", "STATUS_ID", "STATUS_PROP") AS 
  select e.envr_id,e.envr_name,s.status_name,t.type_name ,S.Status_Id,S.Status_Prop
from ENVR_LIST e,ENVR_STATUS_VS v,STATUS_LIST s,STATUS_TYPE t
where e.enable_sign=1 and v.envr_id=e.envr_id and s.status_id=v.status_id and t.type_id=s.type_id and s.enable_sign=1 order by v.sn

;
