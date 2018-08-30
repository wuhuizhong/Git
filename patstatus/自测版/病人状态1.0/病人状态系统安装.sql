
--注意：必须先安装APEX、ORDS
--用Sys身份登录
--创建表空间
@@1-创建表空间和用户/zl_patient_status.sql;
--创建用户
@@1-创建表空间和用户/zl_patient_status_user.sql;
--创建DBLINK
@@2-登录patstatus创建DBLINK/patstatus_dblink.sql;

--3-创建表和视图、序列、索引
@@3-创建表和视图、序列、索引/创建表和视图_序列_索引.sql;


--插入初始数据

--科室字典
@@4-初始数据/DICT_DEPT.sql;
--性别字典
@@4-初始数据/DICT_GENDER.sql;
--婚姻字典
@@4-初始数据/DICT_MARRIAGE.sql;
--场景列表
@@4-初始数据/ENVR_LIST.sql;
--状态类型
@@4-初始数据/STATUS_TYPE.sql;

commit;

--安装程序包

--状态管理服务
@@5-程序包/PKG_STATUS_MANAGE.sql;

--状态查询服务
@@5-程序包/PKG_STATUS_QUERY.sql;

--状态记录服务
@@5-程序包/PKG_STATUS_RECORD.sql;

--REST服务
--@@6-REST服务/patstatus_service.sql;


