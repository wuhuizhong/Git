--------------------------------------------------------
--  文件已创建 - 星期三-八月-29-2018   
--------------------------------------------------------
--------------------------------------------------------
--  DDL for View V_ITEM_TYPE
--------------------------------------------------------

  CREATE OR REPLACE FORCE EDITIONABLE VIEW "ZLRECIPE"."V_ITEM_TYPE" ("CODE", "ITEM_TYPE") AS 
  select 1 code, '区域' as item_type  from dual
union all
select 2 code, '页内嵌等代码' as item_type  from dual
union all
select 3 code, '动态操作' as item_type  from dual
union all
select 4 code, '页项' as item_type  from dual
;

   COMMENT ON COLUMN "ZLRECIPE"."V_ITEM_TYPE"."ITEM_TYPE" IS '项目类型|1-区域,2-页内嵌等代码,3-动态操作,4-页项';
   COMMENT ON TABLE "ZLRECIPE"."V_ITEM_TYPE"  IS '用于sql检查|项目类型'
;
--------------------------------------------------------
--  DDL for View V_PAGE_REGIONS
--------------------------------------------------------

  CREATE OR REPLACE FORCE EDITIONABLE VIEW "ZLRECIPE"."V_PAGE_REGIONS" ("WORKSPACE", "APPLICATION_ID", "APPLICATION_NAME", "PAGE_ID", "PAGE_NAME", "NAME", "CODE", "SOURCE") AS 
  select
 a.workspace,
 a.application_id,
 a.application_name,
 a.page_id,
 a.page_name,
 '区域|'||a.REGION_NAME  name,
  1 as code,
a.REGION_SOURCE  SOURCE
from
apex_application_page_regions a
where
a.workspace='ZLAPEXDEV'
and region_source is not null
union all
---页相关代码
select
workspace,
application_id,
application_name,
page_id,
page_name,
'页内嵌等代码|' name,
2 AS CODE,
'全局变量声明|'||javascript_code||',加载页时执行|'||javascript_code_onload ||',内嵌|'||INLINE_CSS SOURCE
from APEX_APPLICATION_PAGES
where workspace='ZLAPEXDEV'
  and (javascript_code is not null or javascript_code_onload is not null or INLINE_CSS is not null )
union all
---动态操作的操作
select
a.workspace,
a.application_id,
a.application_name,
a.page_id,
a.page_name,
'动态操作|'||a.dynamic_action_name name,
3 AS CODE,
to_clob(a.attribute_01||'|'||a.attribute_02||a.attribute_03||a.attribute_04||a.attribute_05||a.attribute_06||a.attribute_07||a.attribute_08) as SOURCE
from APEX_APPLICATION_PAGE_DA_ACTS a
where a.workspace='ZLAPEXDEV'
and (a.action_code='NATIVE_SET_VALUE' or a.action_code='NATIVE_JAVASCRIPT_CODE' or a.action_code='NATIVE_EXECUTE_PLSQL_CODE')
-- 页面的项 APEX_APPLICATION_PAGE_ITEMS
-- item_source  ,item_source_type 类型
union all
select
 a.workspace,
 a.application_id,
 a.application_name,
 a.page_id,
 a.page_name,
 '项名'||a.item_name name,
  4 AS CODE,
 to_clob(a.item_source) source
from APEX_APPLICATION_PAGE_ITEMS a
where a.workspace='ZLAPEXDEV'
  and a.item_source is not null
  and (a.item_source_type='PL/SQL Function Body' or a.item_source_type='SQL Query (return single value)')

;
--------------------------------------------------------
--  DDL for View V_PHARMACIST_JOB
--------------------------------------------------------

  CREATE OR REPLACE FORCE EDITIONABLE VIEW "ZLRECIPE"."V_PHARMACIST_JOB" ("ID", "姓名", "用户名", "专业技术职务", "JOB_CODE") AS 
  select a.id,a.姓名,c.用户名,A.专业技术职务,decode(A.专业技术职务,'药师',1,'主管药师',2,'副主任药师',3,'主任药师',4) job_code from 人员表@to_zlhis a,人员性质说明@to_zlhis b,上机人员表@to_zlhis c
    where a.id=b.人员id
      and b.人员性质='药房发药人'
      and a.撤档时间>sysdate
      and a.id=c.人员id
      and instr('药师,主管药师,副主任药师,主任药师',A.专业技术职务)>0
;

   COMMENT ON COLUMN "ZLRECIPE"."V_PHARMACIST_JOB"."ID" IS '人员ID';
   COMMENT ON COLUMN "ZLRECIPE"."V_PHARMACIST_JOB"."姓名" IS '人员姓名';
   COMMENT ON COLUMN "ZLRECIPE"."V_PHARMACIST_JOB"."用户名" IS '药师账号|来源于上机人员表的用户名';
   COMMENT ON COLUMN "ZLRECIPE"."V_PHARMACIST_JOB"."专业技术职务" IS '专业技术职务';
   COMMENT ON COLUMN "ZLRECIPE"."V_PHARMACIST_JOB"."JOB_CODE" IS '专业技术职务编码|1-药师,2-主管药师,3-副主任药师,4-主任药师';
   COMMENT ON TABLE "ZLRECIPE"."V_PHARMACIST_JOB"  IS '人员表中抽取药师|'
;
--------------------------------------------------------
--  DDL for View V_REVIEWE_RESULT
--------------------------------------------------------

  CREATE OR REPLACE FORCE EDITIONABLE VIEW "ZLRECIPE"."V_REVIEWE_RESULT" ("RESULT_CODE", "RESULT_NAME") AS 
  select -2 as result_code , '接收未处理' as result_name from dual
union all
select -1 as result_code , '未通过' as result_name from dual
union all
select 0 as result_code , '待审' as result_name from dual
union all
select 1 as result_code , '通过' as result_name from dual
union all
select 2 as result_code , '审核中' as result_name from dual
union all
select 20 as result_code , '无需审核' as result_name from dual
union all
select 21 as result_code , '无药师上岗自动通过' as result_name from dual
union all
select 22 as result_code , '超时自动通过' as result_name from dual
union all
select 23 as result_code , '未上班无需审核' as result_name from dual
;

   COMMENT ON COLUMN "ZLRECIPE"."V_REVIEWE_RESULT"."RESULT_CODE" IS '状态编码|-2-接收未处理,-1-未通过,0-待审,1-通过,2-审核中,20-无需审核,21-无药师上岗自动通过,22-超时自动通过,23-未上班无需审核';
   COMMENT ON COLUMN "ZLRECIPE"."V_REVIEWE_RESULT"."RESULT_NAME" IS '状态名称';
   COMMENT ON TABLE "ZLRECIPE"."V_REVIEWE_RESULT"  IS '处方审核状态|'
;
--------------------------------------------------------
--  DDL for View V_REVIEWE_SOLUTION_ITEM
--------------------------------------------------------

  CREATE OR REPLACE FORCE EDITIONABLE VIEW "ZLRECIPE"."V_REVIEWE_SOLUTION_ITEM" ("SOLUTION_ITEM", "ITEM_FIELD_NAME", "ITEM_TYPE", "ITEM_TABLE_NAME") AS 
  Select '医师职称' As Solution_Item, 'recipe_dr_title' As Item_Field_Name, '处方' As Item_Type, 'reviewe_recipes' As Item_Table_Name From dual
Union All 
Select '处方诊断' As Solution_Item, 'recipe_diag' As Item_Field_Name, '处方' As Item_Type, 'reviewe_recipes' As Item_Table_Name From dual
Union All 
Select '医生抗菌药物等级' As Solution_Item, 'dr_anti_level' As Item_Field_Name, '处方' As Item_Type, 'reviewe_recipes' As Item_Table_Name From dual
Union All 
Select '药品通用名称' As Solution_Item, 'drug_generic_name' As Item_Field_Name, '处方' As Item_Type, 'reviewe_recipes' As Item_Table_Name From dual
Union All 
Select '药品剂型' As Solution_Item, 'drug_form' As Item_Field_Name, '处方' As Item_Type, 'reviewe_recipes' As Item_Table_Name From dual
Union All 
Select '给药途径' As Solution_Item, 'drug_route' As Item_Field_Name, '处方' As Item_Type, 'reviewe_recipes' As Item_Table_Name From dual
Union All 
Select '毒理分类' As Solution_Item, 'drug_toxicity' As Item_Field_Name, '处方' As Item_Type, 'reviewe_recipes' As Item_Table_Name From dual
Union All 
Select '抗菌药物等级' As Solution_Item, 'drug_anti_level' As Item_Field_Name, '处方' As Item_Type, 'reviewe_recipes' As Item_Table_Name From dual
Union All 
Select '抗菌药物用药目的' As Solution_Item, 'anti_drug_reason' As Item_Field_Name, '处方' As Item_Type, 'reviewe_recipes' As Item_Table_Name From dual
Union All 
Select '病生理情况' As Solution_Item, 'p_phys' As Item_Field_Name, '病人' As Item_Type, 'recipe_patient_info' As Item_Table_Name From dual
Union All 
Select '禁忌等级' As Solution_Item, 'drug_contra_level' As Item_Field_Name, '处方' As Item_Type, 'reviewe_recipes' As Item_Table_Name From dual
Union All 
Select '禁忌类型' As Solution_Item, 'drug_contra_type' As Item_Field_Name, '处方' As Item_Type, 'reviewe_recipes' As Item_Table_Name From dual

;
