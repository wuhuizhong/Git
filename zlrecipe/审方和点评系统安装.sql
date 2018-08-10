
--注意：必须先安装APEX、ORDS
--用Sys身份登录
--创建表空间
@@ZLR_REVIEWE.sql;
--创建用户
@@zlrecipe_create_user.sql;
--创建表
@@zlrecipe_table.sql;

--创建序列
@@zlrecipe_sequence.sql;

--创建视图
@@zlrrecipe_view.sql;

--插入初始数据

--ADMIN用户

@@初始数据/zlrecipe_admin_user.sql;
--参数
@@初始数据/zlrecipe_para.sql;
--审方不通过理由
@@初始数据/zlrecipe_no_pass_reason.sql;

--方案明细
delete ZLRECIPE.REVIEWE_SOLUTION;
delete ZLRECIPE.REVIEWE_SOLUTION_DETAIL;

@@初始数据/zlrecipe_solution.sql;
@@初始数据/zlrecipe_solution_detail.sql;

commit;
--安装程序包
--基础程序包
@@程序包/APEXIR_XLSX_PKG.sql;
@@程序包/AS_ZIP.sql;
@@程序包/FTP.sql;
@@程序包/IR_TO_MSEXCEL.sql;
@@程序包/IR_TO_XLSX.sql;
@@程序包/WS_NOTIFY_API.sql;

--审方判断方案
@@程序包/zlrecipe_REVIEWE_SOLUTION_RUN.sql;

--点评程序包
@@程序包/PKG_RECIPE_COMMENT.sql;
--审方程序包
@@程序包/PKG_RECIPE_REVIEWE.sql;


--RESTFul服务
--@@zlrecipe_restful.sql
