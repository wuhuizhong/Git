
--注意：必须先安装APEX、ORDS
--用Sys身份登录
--创建表空间
@@1-创建表空间和用户/ZLR_REVIEWE.sql;
--创建用户
@@1-创建表空间和用户/zlrecipe_create_user.sql;
--创建DBLINK
@@2-登录ZLRECIPE创建DBLINK/zlrecipe_dblink.sql;

--3-创建表和视图、序列、索引
@@3-创建表和视图、序列、索引/table_view_sequence_index.sql;


--插入初始数据

--ADMIN用户
@@4-初始数据/zlrecipe_admin_user.sql;
--参数
@@4-初始数据/zlrecipe_para.sql;
--审方不通过理由
@@4-初始数据/zlrecipe_no_pass_reason.sql;
--拼音
@@4-初始数据/ZLPINYIN.sql;
--点评问题项目
@@4-初始数据/ZLRECIPE_COMMENT_ITEM.sql;
--审核方案
@@4-初始数据/zlrecipe_solution.sql;
--审核方案明细
@@4-初始数据/zlrecipe_solution_detail.sql;

commit;

--安装程序包
--基础程序包
@@5-程序包/APEXIR_XLSX_PKG.sql;
@@5-程序包/AS_ZIP.sql;
@@5-程序包/FTP.sql;
@@5-程序包/IR_TO_MSEXCEL.sql;
@@5-程序包/IR_TO_XLSX.sql;
@@5-程序包/WS_NOTIFY_API.sql;

--点评程序包
@@5-程序包/PKG_RECIPE_COMMENT.sql;
--审方程序包
@@5-程序包/PKG_RECIPE_REVIEWE.sql;

--审方判断方案、过程函数
@@程序包/过程函数.sql;


--服务
--@@6-REST服务/recipe_service.sql;

--创建JOB
--@@7-创建JOB/create_job.sql;
