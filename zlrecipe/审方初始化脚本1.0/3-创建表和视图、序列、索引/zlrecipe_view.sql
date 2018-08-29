--------------------------------------------------------
--  �ļ��Ѵ��� - ������-����-29-2018   
--------------------------------------------------------
--------------------------------------------------------
--  DDL for View V_ITEM_TYPE
--------------------------------------------------------

  CREATE OR REPLACE FORCE EDITIONABLE VIEW "ZLRECIPE"."V_ITEM_TYPE" ("CODE", "ITEM_TYPE") AS 
  select 1 code, '����' as item_type  from dual
union all
select 2 code, 'ҳ��Ƕ�ȴ���' as item_type  from dual
union all
select 3 code, '��̬����' as item_type  from dual
union all
select 4 code, 'ҳ��' as item_type  from dual
;

   COMMENT ON COLUMN "ZLRECIPE"."V_ITEM_TYPE"."ITEM_TYPE" IS '��Ŀ����|1-����,2-ҳ��Ƕ�ȴ���,3-��̬����,4-ҳ��';
   COMMENT ON TABLE "ZLRECIPE"."V_ITEM_TYPE"  IS '����sql���|��Ŀ����'
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
 '����|'||a.REGION_NAME  name,
  1 as code,
a.REGION_SOURCE  SOURCE
from
apex_application_page_regions a
where
a.workspace='ZLAPEXDEV'
and region_source is not null
union all
---ҳ��ش���
select
workspace,
application_id,
application_name,
page_id,
page_name,
'ҳ��Ƕ�ȴ���|' name,
2 AS CODE,
'ȫ�ֱ�������|'||javascript_code||',����ҳʱִ��|'||javascript_code_onload ||',��Ƕ|'||INLINE_CSS SOURCE
from APEX_APPLICATION_PAGES
where workspace='ZLAPEXDEV'
  and (javascript_code is not null or javascript_code_onload is not null or INLINE_CSS is not null )
union all
---��̬�����Ĳ���
select
a.workspace,
a.application_id,
a.application_name,
a.page_id,
a.page_name,
'��̬����|'||a.dynamic_action_name name,
3 AS CODE,
to_clob(a.attribute_01||'|'||a.attribute_02||a.attribute_03||a.attribute_04||a.attribute_05||a.attribute_06||a.attribute_07||a.attribute_08) as SOURCE
from APEX_APPLICATION_PAGE_DA_ACTS a
where a.workspace='ZLAPEXDEV'
and (a.action_code='NATIVE_SET_VALUE' or a.action_code='NATIVE_JAVASCRIPT_CODE' or a.action_code='NATIVE_EXECUTE_PLSQL_CODE')
-- ҳ����� APEX_APPLICATION_PAGE_ITEMS
-- item_source  ,item_source_type ����
union all
select
 a.workspace,
 a.application_id,
 a.application_name,
 a.page_id,
 a.page_name,
 '����'||a.item_name name,
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

  CREATE OR REPLACE FORCE EDITIONABLE VIEW "ZLRECIPE"."V_PHARMACIST_JOB" ("ID", "����", "�û���", "רҵ����ְ��", "JOB_CODE") AS 
  select a.id,a.����,c.�û���,A.רҵ����ְ��,decode(A.רҵ����ְ��,'ҩʦ',1,'����ҩʦ',2,'������ҩʦ',3,'����ҩʦ',4) job_code from ��Ա��@to_zlhis a,��Ա����˵��@to_zlhis b,�ϻ���Ա��@to_zlhis c
    where a.id=b.��Աid
      and b.��Ա����='ҩ����ҩ��'
      and a.����ʱ��>sysdate
      and a.id=c.��Աid
      and instr('ҩʦ,����ҩʦ,������ҩʦ,����ҩʦ',A.רҵ����ְ��)>0
;

   COMMENT ON COLUMN "ZLRECIPE"."V_PHARMACIST_JOB"."ID" IS '��ԱID';
   COMMENT ON COLUMN "ZLRECIPE"."V_PHARMACIST_JOB"."����" IS '��Ա����';
   COMMENT ON COLUMN "ZLRECIPE"."V_PHARMACIST_JOB"."�û���" IS 'ҩʦ�˺�|��Դ���ϻ���Ա����û���';
   COMMENT ON COLUMN "ZLRECIPE"."V_PHARMACIST_JOB"."רҵ����ְ��" IS 'רҵ����ְ��';
   COMMENT ON COLUMN "ZLRECIPE"."V_PHARMACIST_JOB"."JOB_CODE" IS 'רҵ����ְ�����|1-ҩʦ,2-����ҩʦ,3-������ҩʦ,4-����ҩʦ';
   COMMENT ON TABLE "ZLRECIPE"."V_PHARMACIST_JOB"  IS '��Ա���г�ȡҩʦ|'
;
--------------------------------------------------------
--  DDL for View V_REVIEWE_RESULT
--------------------------------------------------------

  CREATE OR REPLACE FORCE EDITIONABLE VIEW "ZLRECIPE"."V_REVIEWE_RESULT" ("RESULT_CODE", "RESULT_NAME") AS 
  select -2 as result_code , '����δ����' as result_name from dual
union all
select -1 as result_code , 'δͨ��' as result_name from dual
union all
select 0 as result_code , '����' as result_name from dual
union all
select 1 as result_code , 'ͨ��' as result_name from dual
union all
select 2 as result_code , '�����' as result_name from dual
union all
select 20 as result_code , '�������' as result_name from dual
union all
select 21 as result_code , '��ҩʦ�ϸ��Զ�ͨ��' as result_name from dual
union all
select 22 as result_code , '��ʱ�Զ�ͨ��' as result_name from dual
union all
select 23 as result_code , 'δ�ϰ��������' as result_name from dual
;

   COMMENT ON COLUMN "ZLRECIPE"."V_REVIEWE_RESULT"."RESULT_CODE" IS '״̬����|-2-����δ����,-1-δͨ��,0-����,1-ͨ��,2-�����,20-�������,21-��ҩʦ�ϸ��Զ�ͨ��,22-��ʱ�Զ�ͨ��,23-δ�ϰ��������';
   COMMENT ON COLUMN "ZLRECIPE"."V_REVIEWE_RESULT"."RESULT_NAME" IS '״̬����';
   COMMENT ON TABLE "ZLRECIPE"."V_REVIEWE_RESULT"  IS '�������״̬|'
;
--------------------------------------------------------
--  DDL for View V_REVIEWE_SOLUTION_ITEM
--------------------------------------------------------

  CREATE OR REPLACE FORCE EDITIONABLE VIEW "ZLRECIPE"."V_REVIEWE_SOLUTION_ITEM" ("SOLUTION_ITEM", "ITEM_FIELD_NAME", "ITEM_TYPE", "ITEM_TABLE_NAME") AS 
  Select 'ҽʦְ��' As Solution_Item, 'recipe_dr_title' As Item_Field_Name, '����' As Item_Type, 'reviewe_recipes' As Item_Table_Name From dual
Union All 
Select '�������' As Solution_Item, 'recipe_diag' As Item_Field_Name, '����' As Item_Type, 'reviewe_recipes' As Item_Table_Name From dual
Union All 
Select 'ҽ������ҩ��ȼ�' As Solution_Item, 'dr_anti_level' As Item_Field_Name, '����' As Item_Type, 'reviewe_recipes' As Item_Table_Name From dual
Union All 
Select 'ҩƷͨ������' As Solution_Item, 'drug_generic_name' As Item_Field_Name, '����' As Item_Type, 'reviewe_recipes' As Item_Table_Name From dual
Union All 
Select 'ҩƷ����' As Solution_Item, 'drug_form' As Item_Field_Name, '����' As Item_Type, 'reviewe_recipes' As Item_Table_Name From dual
Union All 
Select '��ҩ;��' As Solution_Item, 'drug_route' As Item_Field_Name, '����' As Item_Type, 'reviewe_recipes' As Item_Table_Name From dual
Union All 
Select '�������' As Solution_Item, 'drug_toxicity' As Item_Field_Name, '����' As Item_Type, 'reviewe_recipes' As Item_Table_Name From dual
Union All 
Select '����ҩ��ȼ�' As Solution_Item, 'drug_anti_level' As Item_Field_Name, '����' As Item_Type, 'reviewe_recipes' As Item_Table_Name From dual
Union All 
Select '����ҩ����ҩĿ��' As Solution_Item, 'anti_drug_reason' As Item_Field_Name, '����' As Item_Type, 'reviewe_recipes' As Item_Table_Name From dual
Union All 
Select '���������' As Solution_Item, 'p_phys' As Item_Field_Name, '����' As Item_Type, 'recipe_patient_info' As Item_Table_Name From dual
Union All 
Select '���ɵȼ�' As Solution_Item, 'drug_contra_level' As Item_Field_Name, '����' As Item_Type, 'reviewe_recipes' As Item_Table_Name From dual
Union All 
Select '��������' As Solution_Item, 'drug_contra_type' As Item_Field_Name, '����' As Item_Type, 'reviewe_recipes' As Item_Table_Name From dual

;
