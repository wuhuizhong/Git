--------------------------------------------------------
--  文件已创建 - 星期一-八月-13-2018   
--------------------------------------------------------
--------------------------------------------------------
--  DDL for View V_EMR_DATASET
--------------------------------------------------------

  CREATE OR REPLACE FORCE VIEW "ZLCDR"."V_EMR_DATASET" ("EMR_DATASET_CLASS_SIGN", "EMR_DATASET_CODE", "EMR_DATASET_NAME", "EMR_DATASET_TYPE", "EMR_DATASET_USE_SIGN") AS 
  select t.emr_dataset_class_sign,t.emr_dataset_code,t.emr_dataset_name,
t.emr_dataset_type,t.emr_dataset_use_sign
from CDR.emr_dataset t
where
t.Emr_Dataset_Code<>'ZLEMR' AND
instr(pkg_constant.EMR_DATASET_CODE(),t.Emr_Dataset_Code)>0
;

   COMMENT ON COLUMN "ZLCDR"."V_EMR_DATASET"."EMR_DATASET_CLASS_SIGN" IS '数据集分类标识|0-数据集;1-分类';
   COMMENT ON COLUMN "ZLCDR"."V_EMR_DATASET"."EMR_DATASET_CODE" IS 'EMR数据集编码';
   COMMENT ON COLUMN "ZLCDR"."V_EMR_DATASET"."EMR_DATASET_NAME" IS 'EMR数据集名称';
   COMMENT ON COLUMN "ZLCDR"."V_EMR_DATASET"."EMR_DATASET_TYPE" IS 'EMR数据集类型|1-数据集集合;2-数据集子集';
   COMMENT ON COLUMN "ZLCDR"."V_EMR_DATASET"."EMR_DATASET_USE_SIGN" IS 'EMR数据集类型使用状态|0-已停用;1-已启用';
   COMMENT ON TABLE "ZLCDR"."V_EMR_DATASET"  IS '病历编码值域'
;
--------------------------------------------------------
--  DDL for View V_EXAMINE_DATASET
--------------------------------------------------------

  CREATE OR REPLACE FORCE VIEW "ZLCDR"."V_EXAMINE_DATASET" ("EMR_DATASET_CLASS_SIGN", "EMR_DATASET_CODE", "EMR_DATASET_NAME", "EMR_DATASET_TYPE", "EMR_DATASET_USE_SIGN") AS 
  select t.emr_dataset_class_sign,t.emr_dataset_code,t.emr_dataset_name,
t.emr_dataset_type,t.emr_dataset_use_sign
from CDR.emr_dataset t
where
t.Emr_Dataset_Code<>'ZLEMR' AND
instr(pkg_constant.examine_DATASET_CODE(),t.Emr_Dataset_Code)>0
;

   COMMENT ON COLUMN "ZLCDR"."V_EXAMINE_DATASET"."EMR_DATASET_CLASS_SIGN" IS '数据集分类标识|0-数据集;1-分类';
   COMMENT ON COLUMN "ZLCDR"."V_EXAMINE_DATASET"."EMR_DATASET_CODE" IS 'EMR数据集编码';
   COMMENT ON COLUMN "ZLCDR"."V_EXAMINE_DATASET"."EMR_DATASET_NAME" IS 'EMR数据集名称';
   COMMENT ON COLUMN "ZLCDR"."V_EXAMINE_DATASET"."EMR_DATASET_TYPE" IS 'EMR数据集类型|1-数据集集合;2-数据集子集';
   COMMENT ON COLUMN "ZLCDR"."V_EXAMINE_DATASET"."EMR_DATASET_USE_SIGN" IS 'EMR数据集类型使用状态|0-已停用;1-已启用';
   COMMENT ON TABLE "ZLCDR"."V_EXAMINE_DATASET"  IS '检查报告编码值域'
;
--------------------------------------------------------
--  DDL for View V_LIS_DATASET
--------------------------------------------------------

  CREATE OR REPLACE FORCE VIEW "ZLCDR"."V_LIS_DATASET" ("EMR_DATASET_CLASS_SIGN", "EMR_DATASET_CODE", "EMR_DATASET_NAME", "EMR_DATASET_TYPE", "EMR_DATASET_USE_SIGN") AS 
  select t.emr_dataset_class_sign,t.emr_dataset_code,t.emr_dataset_name,
t.emr_dataset_type,t.emr_dataset_use_sign
from CDR.emr_dataset t
where
t.Emr_Dataset_Code<>'ZLEMR' AND
instr(pkg_constant.LIS_DATASET_CODE(),t.Emr_Dataset_Code)>0

;
--------------------------------------------------------
--  DDL for View V_LOV_DIAG_TYPE
--------------------------------------------------------

  CREATE OR REPLACE FORCE VIEW "ZLCDR"."V_LOV_DIAG_TYPE" ("CODE", "NAME") AS 
  select 1 as code ,   '西医门诊诊断' as name from dual
union all
select 2 as code ,   '西医入院诊断' as name from dual
union all
select 3 as code ,   '西医出院诊断' as name from dual
union all
select 5 as code ,   '院内感染' as name from dual
union all
select 6 as code ,   '病理诊断' as name from dual
union all
select 7 as code ,   '损伤中毒码' as name from dual
union all
select 8 as code ,   '术前诊断' as name from dual
union all
select 9 as code ,   '术后诊断' as name from dual
union all
select 10 as code ,   '并发症' as name from dual
union all
select 11 as code ,   '中医门诊诊断' as name from dual
union all
select 12 as code ,   '中医入院诊断' as name from dual
union all
select 13 as code ,   '中医出院诊断' as name from dual
union all
select 21 as code ,   '病原学诊断' as name from dual
union all
select 22 as code ,   '影像学诊断' as name from dual
;

   COMMENT ON COLUMN "ZLCDR"."V_LOV_DIAG_TYPE"."CODE" IS '患者诊断类别|1-西医门诊诊断;2-西医入院诊断;3-西医出院诊断;5-院内感染;6-病理诊断;7-损伤中毒码,8-术前诊断;9-术后诊断;10-并发症;11-中医门诊诊断;12-中医入院诊断;13-中医出院诊断;21-病原学诊断;22-影像学诊断';
   COMMENT ON COLUMN "ZLCDR"."V_LOV_DIAG_TYPE"."NAME" IS '诊断类别名称';
   COMMENT ON TABLE "ZLCDR"."V_LOV_DIAG_TYPE"  IS '诊断类型值域'
;
--------------------------------------------------------
--  DDL for View V_PAT_ALGC_INFO
--------------------------------------------------------

  CREATE OR REPLACE FORCE VIEW "ZLCDR"."V_PAT_ALGC_INFO" ("PVID", "ALGC_SOUR_DESE", "ALGC_ANS", "ALGC_RECODER", "ALGC_REC_TIME", "ALGC_ANS_TIME") AS 
  Select distinct a.pvid, x.Algc_Sour_Dese, x.Algc_Ans, x.Algc_Recoder, to_Date(x.Algc_Rec_Time,'YYYY-MM-DD HH24:MI:SS') As Algc_Rec_Time,
       to_Date(x.Algc_Ans_Time,'YYYY-MM-DD HH24:MI:SS') As Algc_Ans_Time
  From cdr.Pat_Emr a, cdr.Pat_Emr_Content b,
       Xmltable('//algc_info' Passing b.Pat_Emr_Content
                Columns
                       Algc_Hist_Sign Varchar2(10) Path 'algc_hist_sign',     --过敏标志
                       Algc_Sour_Dese Varchar2(500) Path 'algc_sour_desc',    --过敏源描述
                       Algc_Ans Varchar(1000) Path 'algc_ans',                --过敏反应
                       Algc_Recoder Varchar2(200) Path 'algc_recoder',        --过敏记录人
                       Algc_Rec_Time Varchar2(20) Path 'algc_rec_time',       --过敏记录时间
                       Algc_Ans_Time Varchar2(20) Path 'algc_ans_time') x     --过敏时间
 Where a.Emr_Dataset_Name = pkg_constant.EMR_DATASET_NAME()
   And a.Pat_Emr_Id = b.Pat_Emr_Id
   And x.Algc_Hist_Sign = 'true'
;

   COMMENT ON COLUMN "ZLCDR"."V_PAT_ALGC_INFO"."PVID" IS '患者就诊信息ID|';
   COMMENT ON COLUMN "ZLCDR"."V_PAT_ALGC_INFO"."ALGC_SOUR_DESE" IS '过敏源描述|';
   COMMENT ON COLUMN "ZLCDR"."V_PAT_ALGC_INFO"."ALGC_ANS" IS '过敏反应|';
   COMMENT ON COLUMN "ZLCDR"."V_PAT_ALGC_INFO"."ALGC_RECODER" IS '过敏记录人|';
   COMMENT ON COLUMN "ZLCDR"."V_PAT_ALGC_INFO"."ALGC_REC_TIME" IS '过敏记录时间|';
   COMMENT ON COLUMN "ZLCDR"."V_PAT_ALGC_INFO"."ALGC_ANS_TIME" IS '过敏时间|';
   COMMENT ON TABLE "ZLCDR"."V_PAT_ALGC_INFO"  IS '患者过敏记录'
;
--------------------------------------------------------
--  DDL for View V_PAT_DIAG
--------------------------------------------------------

  CREATE OR REPLACE FORCE VIEW "ZLCDR"."V_PAT_DIAG" ("PAT_DIAG_ID", "APPSYS_ID", "PVID", "PID", "PAT_DIAG_SNO", "PAT_DIAG_TYPE", "PAT_DIAG_TYPE_NAME", "DIAG_NAME", "DIAG_CODE", "PAT_DIAG_DESC", "DIAG_STATUS_NAME", "PAT_DIAG_RECORD_TIME", "PAT_DIAG_RECODER") AS 
  select
t.pat_diag_id,
t.appsys_id,
t.pvid,t.pid,
t.pat_diag_sno,
t.pat_diag_type,
a.name as pat_diag_type_name,
t.diag_name,
t.diag_code,
decode(t.pat_diag_desc,'',decode(t.diag_code||t.diag_name,'',null,'('||t.diag_code||')'||t.diag_name),t.pat_diag_desc)  as pat_diag_desc,
t.diag_status_name,t.pat_diag_record_time,t.pat_diag_recoder from CDR.PAT_DIAG_INFO t ,zlcdr.V_LOV_DIAG_TYPE A
WHERE T.PAT_DIAG_TYPE=A.CODE
;

   COMMENT ON COLUMN "ZLCDR"."V_PAT_DIAG"."PAT_DIAG_ID" IS '患者诊断ID|';
   COMMENT ON COLUMN "ZLCDR"."V_PAT_DIAG"."APPSYS_ID" IS '应用系统ID|';
   COMMENT ON COLUMN "ZLCDR"."V_PAT_DIAG"."PVID" IS '患者就诊信息ID|';
   COMMENT ON COLUMN "ZLCDR"."V_PAT_DIAG"."PID" IS '患者ID|';
   COMMENT ON COLUMN "ZLCDR"."V_PAT_DIAG"."PAT_DIAG_SNO" IS '患者诊断顺序|';
   COMMENT ON COLUMN "ZLCDR"."V_PAT_DIAG"."PAT_DIAG_TYPE" IS '患者诊断类别|1-西医门诊诊断;2-西医入院诊断;3-西医出院诊断;5-院内感染;6-病理诊断;7-损伤中毒码,8-术前诊断;9-术后诊断;10-并发症;11-中医门诊诊断;12-中医入院诊断;13-中医出院诊断;21-病原学诊断;22-影像学诊断';
   COMMENT ON COLUMN "ZLCDR"."V_PAT_DIAG"."PAT_DIAG_TYPE_NAME" IS '诊断类型名称';
   COMMENT ON COLUMN "ZLCDR"."V_PAT_DIAG"."DIAG_NAME" IS '诊断名称|';
   COMMENT ON COLUMN "ZLCDR"."V_PAT_DIAG"."DIAG_CODE" IS '诊断编码|';
   COMMENT ON COLUMN "ZLCDR"."V_PAT_DIAG"."PAT_DIAG_DESC" IS '患者诊断描述|';
   COMMENT ON COLUMN "ZLCDR"."V_PAT_DIAG"."DIAG_STATUS_NAME" IS '诊断状态名称|CV05.01.002';
   COMMENT ON COLUMN "ZLCDR"."V_PAT_DIAG"."PAT_DIAG_RECORD_TIME" IS '患者诊断记录时间|';
   COMMENT ON COLUMN "ZLCDR"."V_PAT_DIAG"."PAT_DIAG_RECODER" IS '患者诊断记录人|';
   COMMENT ON TABLE "ZLCDR"."V_PAT_DIAG"  IS '患者诊断信息|'
;
--------------------------------------------------------
--  DDL for View V_PAT_DRUG_INFO
--------------------------------------------------------

  CREATE OR REPLACE FORCE VIEW "ZLCDR"."V_PAT_DRUG_INFO" ("PVID", "ORDER_START_TIME", "ORDER_END_TIME", "ORDER_ITEM_TYPE_NAME", "ORDER_TYPE_NAME", "ORDER_ITEM", "CITEM_NAME", "ODD_RCPDTL_ONCE_QUNT", "ODD_RCPDTL_TOTAL_QUNT", "DRUG_FREQ_NAME", "DRUG_METHOD_NAME", "DRUG_ONCE_DOSA_UNIT", "ANTIBIOTIC", "TOXI_CLAS", "ORDER_NOTE", "ORDER_EXE_STATUS", "ORDER_PLACE_TIME", "ORDER_PLCDEPT", "ORDER_PLACER") AS 
  Select a.Pvid,
       To_Date(x.Order_Plan_Start_Time, 'YYYY-MM-DD HH24:MI:SS') As Order_Start_Time,
       To_Date(x.Order_Plan_End_Time, 'YYYY-MM-DD HH24:MI:SS') As Order_End_Time,
       x.Order_Item_Type_Name,
       x.Order_Type_Name,
       x.Order_Item ||' 单次'||x.Odd_Rcpdtl_Once_Qunt||x.Drug_Once_Dosa_Unit as Order_Item,
       x.Citem_Name,
       x.Odd_Rcpdtl_Once_Qunt,
       x.Odd_Rcpdtl_Total_Qunt,
       x.Drug_Freq_Name,
       x.Drug_Method_Name,
       x.Drug_Once_Dosa_Unit,
       x.Antibiotic,
       x.Toxi_Clas,
       x.Order_Note,
       x.Order_Exe_Status,
       To_Date(x.Order_Place_Time, 'YYYY-MM-DD HH24:MI:SS') As Order_Place_Time,
       x.Order_Plcdept ,
       x.Order_Placer_Sig As Order_Placer
  From cdr.Pat_Emr a, cdr.Pat_Emr_Content b,
       Xmltable('//order_info' Passing b.Pat_Emr_Content
                Columns
                       Order_Plan_Start_Time Varchar2(20) Path 'order_plan_start_time',           --医嘱计划开始日期时间
                       Order_Plan_End_Time Varchar2(20) Path 'order_plan_end_time',               --医嘱计划结束日期时间
                       Order_Item_Type_Name Varchar2(20) Path 'order_item_type_name',             --医嘱项目内容
                       Order_Type_Name Varchar2(20) Path 'order_type_name',                       --医嘱类别名称
                       Order_Item Varchar2(200) Path 'order_item',                                --医嘱项目内容
                       Citem_Name Varchar2(200) Path 'citem_name',                                --诊疗项目名称
                       Odd_Rcpdtl_Once_Qunt Varchar2(10) Path 'odd_rcpdtl_once_qunt',             --单次用量
                       Odd_Rcpdtl_Total_Qunt Varchar2(10) Path 'odd_rcpdtl_total_qunt',           --总给予量
                       Drug_Freq_Name Varchar2(200) Path 'drug_freq_name',                        --药物使用频次名称
                       Drug_Method_Name Varchar2(50) Path 'drug_method_name',                     --药物使用途径名称
                       Drug_Once_Dosa_Unit Varchar2(10) Path 'drug_once_dosa_unit',               --药物使用剂量单位
                       Antibiotic Varchar2(2) Path 'antibiotic',                                  --抗生素
                       Toxi_Clas Varchar2(10) Path 'toxi_clas',                                   --毒理分类
                       Order_Note Varchar2(200) Path 'order_note',                                --医嘱备注信息
                       Order_Exe_Status Varchar2(50) Path 'order_exe_status',                     --医嘱执行状态
                       Order_Place_Time Varchar2(20) Path 'order_place_time',                     --医嘱开立日期日期
                       Order_Plcdept Varchar2(100) Path 'order_plcdept',                          --医嘱开立科室
                       Order_Placer_Sig Varchar2(100) Path 'order_placer_sig') x                  --医嘱开立者签名
Where a.Pat_Emr_Id = b.Pat_Emr_Id
  And (a.Emr_Dataset_Name=pkg_constant.INORDER_DATASET_CODE()
  or a.Emr_Dataset_Name=pkg_constant.outorder_dataset_code())
  and x.Order_Item_Type_Name=pkg_constant.Order_Item_Type_Name()
;

   COMMENT ON COLUMN "ZLCDR"."V_PAT_DRUG_INFO"."PVID" IS '患者就诊信息ID';
   COMMENT ON COLUMN "ZLCDR"."V_PAT_DRUG_INFO"."ORDER_START_TIME" IS '医嘱计划开始日期时间|';
   COMMENT ON COLUMN "ZLCDR"."V_PAT_DRUG_INFO"."ORDER_END_TIME" IS '医嘱计划结束日期时间|';
   COMMENT ON COLUMN "ZLCDR"."V_PAT_DRUG_INFO"."ORDER_ITEM_TYPE_NAME" IS '医嘱项目内容|';
   COMMENT ON COLUMN "ZLCDR"."V_PAT_DRUG_INFO"."ORDER_TYPE_NAME" IS '医嘱类别名称|';
   COMMENT ON COLUMN "ZLCDR"."V_PAT_DRUG_INFO"."ORDER_ITEM" IS '医嘱项目内容|';
   COMMENT ON COLUMN "ZLCDR"."V_PAT_DRUG_INFO"."CITEM_NAME" IS '诊疗项目名称|';
   COMMENT ON COLUMN "ZLCDR"."V_PAT_DRUG_INFO"."ODD_RCPDTL_ONCE_QUNT" IS '单次用量|';
   COMMENT ON COLUMN "ZLCDR"."V_PAT_DRUG_INFO"."ODD_RCPDTL_TOTAL_QUNT" IS '总给予量|';
   COMMENT ON COLUMN "ZLCDR"."V_PAT_DRUG_INFO"."DRUG_FREQ_NAME" IS '药物使用频次名称|';
   COMMENT ON COLUMN "ZLCDR"."V_PAT_DRUG_INFO"."DRUG_METHOD_NAME" IS '药物使用途径名称|';
   COMMENT ON COLUMN "ZLCDR"."V_PAT_DRUG_INFO"."DRUG_ONCE_DOSA_UNIT" IS '药物使用剂量单位|';
   COMMENT ON COLUMN "ZLCDR"."V_PAT_DRUG_INFO"."ANTIBIOTIC" IS '抗生素|';
   COMMENT ON COLUMN "ZLCDR"."V_PAT_DRUG_INFO"."TOXI_CLAS" IS '毒理分类|';
   COMMENT ON COLUMN "ZLCDR"."V_PAT_DRUG_INFO"."ORDER_NOTE" IS '医嘱备注信息|';
   COMMENT ON COLUMN "ZLCDR"."V_PAT_DRUG_INFO"."ORDER_EXE_STATUS" IS '医嘱执行状态|';
   COMMENT ON COLUMN "ZLCDR"."V_PAT_DRUG_INFO"."ORDER_PLACE_TIME" IS '医嘱开立日期日期|';
   COMMENT ON COLUMN "ZLCDR"."V_PAT_DRUG_INFO"."ORDER_PLCDEPT" IS '医嘱开立科室|';
   COMMENT ON COLUMN "ZLCDR"."V_PAT_DRUG_INFO"."ORDER_PLACER" IS '医嘱开立者签名|';
   COMMENT ON TABLE "ZLCDR"."V_PAT_DRUG_INFO"  IS '患者用药信息'
;
--------------------------------------------------------
--  DDL for View V_PAT_EMR
--------------------------------------------------------

  CREATE OR REPLACE FORCE VIEW "ZLCDR"."V_PAT_EMR" ("PVID", "APPSYS_LNK_EMR_ID", "APPSYS_EMR_ID", "APPSYS_ID", "PAT_EMR_ID", "EMR_DATASET_NAME", "EMR_DATASET_CODE", "APPSYS_EMR_ANTETYPE_ID", "EMR_CREATE_TIME") AS 
  Select a.Pvid,
a.Appsys_Lnk_Emr_Id,
a.Appsys_Emr_Id,
a.appsys_id,
       a.Pat_Emr_Id,
       a.Emr_Dataset_Name,
       a.Emr_Dataset_Code,
       a.appsys_emr_antetype_id,
       a.Emr_Create_Time
  From  cdr.pat_emr a,v_emr_dataset b
         Where
         a.emr_dataset_code=b.emr_dataset_code
           order by b.emr_dataset_code
;

   COMMENT ON COLUMN "ZLCDR"."V_PAT_EMR"."PVID" IS '患者就诊信息ID|';
   COMMENT ON COLUMN "ZLCDR"."V_PAT_EMR"."APPSYS_LNK_EMR_ID" IS '应用系统关联EMR_ID|存储上级文档的ID';
   COMMENT ON COLUMN "ZLCDR"."V_PAT_EMR"."APPSYS_EMR_ID" IS '应用系统EMR_ID|';
   COMMENT ON COLUMN "ZLCDR"."V_PAT_EMR"."APPSYS_ID" IS '应用系统ID|';
   COMMENT ON COLUMN "ZLCDR"."V_PAT_EMR"."PAT_EMR_ID" IS '患者EMR_ID|';
   COMMENT ON COLUMN "ZLCDR"."V_PAT_EMR"."EMR_DATASET_NAME" IS 'EMR数据集名称|';
   COMMENT ON COLUMN "ZLCDR"."V_PAT_EMR"."EMR_DATASET_CODE" IS 'EMR数据集编码|';
   COMMENT ON COLUMN "ZLCDR"."V_PAT_EMR"."APPSYS_EMR_ANTETYPE_ID" IS '应用系统emr原型id|';
   COMMENT ON COLUMN "ZLCDR"."V_PAT_EMR"."EMR_CREATE_TIME" IS 'emr创建时间|';
   COMMENT ON TABLE "ZLCDR"."V_PAT_EMR"  IS '患者病历'
;
--------------------------------------------------------
--  DDL for View V_PAT_EXAMINE
--------------------------------------------------------

  CREATE OR REPLACE FORCE VIEW "ZLCDR"."V_PAT_EXAMINE" ("PVID", "APPSYS_LNK_EMR_ID", "APPSYS_EMR_ID", "APPSYS_ID", "PAT_EMR_ID", "EMR_DATASET_NAME", "EMR_DATASET_CODE", "APPSYS_EMR_ANTETYPE_ID", "EMR_CREATE_TIME", "EXAM_ITEM_NAME") AS 
  Select a.Pvid,
a.Appsys_Lnk_Emr_Id,
a.Appsys_Emr_Id,
a.appsys_id,
       a.Pat_Emr_Id,
       a.Emr_Dataset_Name,
       a.Emr_Dataset_Code,
       a.appsys_emr_antetype_id,
       a.Emr_Create_Time,
       x.exam_item_name
  From  cdr.pat_emr a,v_examine_dataset b, cdr.pat_emr_content c,
    xmltable('/ZLEMR' Passing c.Pat_Emr_Content
                Columns
                       exam_item_name Varchar2(500) Path 'exam_item_name'    --检查报告名称
                       ) x
         Where
         a.pat_emr_id=c.pat_emr_id and
         a.emr_dataset_code=b.emr_dataset_code
;

   COMMENT ON COLUMN "ZLCDR"."V_PAT_EXAMINE"."PVID" IS '患者就诊信息ID|';
   COMMENT ON COLUMN "ZLCDR"."V_PAT_EXAMINE"."APPSYS_LNK_EMR_ID" IS '应用系统关联EMR_ID|存储上级文档的ID';
   COMMENT ON COLUMN "ZLCDR"."V_PAT_EXAMINE"."APPSYS_EMR_ID" IS '应用系统EMR_ID|';
   COMMENT ON COLUMN "ZLCDR"."V_PAT_EXAMINE"."APPSYS_ID" IS '应用系统ID|';
   COMMENT ON COLUMN "ZLCDR"."V_PAT_EXAMINE"."PAT_EMR_ID" IS '患者EMR_ID|';
   COMMENT ON COLUMN "ZLCDR"."V_PAT_EXAMINE"."EMR_DATASET_NAME" IS 'EMR数据集名称|';
   COMMENT ON COLUMN "ZLCDR"."V_PAT_EXAMINE"."EMR_DATASET_CODE" IS 'EMR数据集编码|';
   COMMENT ON COLUMN "ZLCDR"."V_PAT_EXAMINE"."APPSYS_EMR_ANTETYPE_ID" IS '应用系统emr原型id|';
   COMMENT ON COLUMN "ZLCDR"."V_PAT_EXAMINE"."EMR_CREATE_TIME" IS 'emr创建时间|';
   COMMENT ON COLUMN "ZLCDR"."V_PAT_EXAMINE"."EXAM_ITEM_NAME" IS '检查报告名称|';
   COMMENT ON TABLE "ZLCDR"."V_PAT_EXAMINE"  IS '患者检查'
;
--------------------------------------------------------
--  DDL for View V_PAT_INFO
--------------------------------------------------------

  CREATE OR REPLACE FORCE VIEW "ZLCDR"."V_PAT_INFO" ("PID", "PAT_NAME", "PAT_SEX_NAME", "PAT_BRSDATE", "COUNTRY_NAME", "NTVPLC_NAME", "NATION_NAME", "EDU_NAME", "OCPT_NAME", "ABO_BLD_NAME", "RH_BLD_NAME", "INSURE_NAME", "HEALTH_CARD_NO") AS 
  select
         b.pid,
         b.pat_name,
         b.pat_sex_name,
         b.pat_brsdate,
         b.country_name,
         b.ntvplc_name,
         b.nation_name,
         b.edu_name,
         b.ocpt_name,
         b.abo_bld_name,
         b.rh_bld_name,
         b.insure_name,
         b.health_card_no
    from empi.pat_info b
;

   COMMENT ON COLUMN "ZLCDR"."V_PAT_INFO"."PID" IS '患者ID|';
   COMMENT ON COLUMN "ZLCDR"."V_PAT_INFO"."PAT_NAME" IS '患者姓名|';
   COMMENT ON COLUMN "ZLCDR"."V_PAT_INFO"."PAT_SEX_NAME" IS '患者性别名称|';
   COMMENT ON COLUMN "ZLCDR"."V_PAT_INFO"."PAT_BRSDATE" IS '患者出生日期|';
   COMMENT ON COLUMN "ZLCDR"."V_PAT_INFO"."COUNTRY_NAME" IS '国籍名称|';
   COMMENT ON COLUMN "ZLCDR"."V_PAT_INFO"."NTVPLC_NAME" IS '籍贯名称|';
   COMMENT ON COLUMN "ZLCDR"."V_PAT_INFO"."NATION_NAME" IS '民族名称|';
   COMMENT ON COLUMN "ZLCDR"."V_PAT_INFO"."EDU_NAME" IS '学历名称|';
   COMMENT ON COLUMN "ZLCDR"."V_PAT_INFO"."OCPT_NAME" IS '职业名称|';
   COMMENT ON COLUMN "ZLCDR"."V_PAT_INFO"."ABO_BLD_NAME" IS 'ABO血型名称|';
   COMMENT ON COLUMN "ZLCDR"."V_PAT_INFO"."RH_BLD_NAME" IS 'RH血型名称|';
   COMMENT ON COLUMN "ZLCDR"."V_PAT_INFO"."INSURE_NAME" IS '医疗保险类别名称|';
   COMMENT ON COLUMN "ZLCDR"."V_PAT_INFO"."HEALTH_CARD_NO" IS '健康卡号|';
   COMMENT ON TABLE "ZLCDR"."V_PAT_INFO"  IS '患者信息'
;
--------------------------------------------------------
--  DDL for View V_PAT_LIS
--------------------------------------------------------

  CREATE OR REPLACE FORCE VIEW "ZLCDR"."V_PAT_LIS" ("PVID", "APPSYS_LNK_EMR_ID", "APPSYS_EMR_ID", "APPSYS_ID", "PAT_EMR_ID", "EMR_DATASET_NAME", "EMR_DATASET_CODE", "APPSYS_EMR_ANTETYPE_ID", "EMR_CREATE_TIME", "LAB_ITEM_NAME") AS 
  Select a.Pvid,
a.Appsys_Lnk_Emr_Id,
a.Appsys_Emr_Id,
a.appsys_id,
       a.Pat_Emr_Id,
       a.Emr_Dataset_Name,
       a.Emr_Dataset_Code,
       a.appsys_emr_antetype_id,
       a.Emr_Create_Time,
       x.lab_item_name
  From  cdr.pat_emr a,v_lis_dataset b, cdr.pat_emr_content c,
    xmltable('/ZLEMR' Passing c.Pat_Emr_Content
                Columns
                       lab_item_name Varchar2(500) Path 'lab_item_name'    --检验报告名称
                       ) x
         Where
         a.pat_emr_id=c.pat_emr_id and
         a.emr_dataset_code=b.emr_dataset_code
;

   COMMENT ON COLUMN "ZLCDR"."V_PAT_LIS"."PVID" IS '患者就诊信息ID|';
   COMMENT ON COLUMN "ZLCDR"."V_PAT_LIS"."APPSYS_LNK_EMR_ID" IS '应用系统关联EMR_ID|存储上级文档的ID';
   COMMENT ON COLUMN "ZLCDR"."V_PAT_LIS"."APPSYS_EMR_ID" IS '应用系统EMR_ID|';
   COMMENT ON COLUMN "ZLCDR"."V_PAT_LIS"."APPSYS_ID" IS '应用系统ID|';
   COMMENT ON COLUMN "ZLCDR"."V_PAT_LIS"."PAT_EMR_ID" IS '患者EMR_ID|';
   COMMENT ON COLUMN "ZLCDR"."V_PAT_LIS"."EMR_DATASET_NAME" IS 'EMR数据集名称|';
   COMMENT ON COLUMN "ZLCDR"."V_PAT_LIS"."EMR_DATASET_CODE" IS 'EMR数据集编码|';
   COMMENT ON COLUMN "ZLCDR"."V_PAT_LIS"."APPSYS_EMR_ANTETYPE_ID" IS '应用系统emr原型id|';
   COMMENT ON COLUMN "ZLCDR"."V_PAT_LIS"."EMR_CREATE_TIME" IS 'emr创建时间|';
   COMMENT ON COLUMN "ZLCDR"."V_PAT_LIS"."LAB_ITEM_NAME" IS '检验报告名称|';
   COMMENT ON TABLE "ZLCDR"."V_PAT_LIS"  IS '患者检验'
;
--------------------------------------------------------
--  DDL for View V_PAT_ORDER
--------------------------------------------------------

  CREATE OR REPLACE FORCE VIEW "ZLCDR"."V_PAT_ORDER" ("PVID", "ORDER_START_TIME", "ORDER_END_TIME", "ORDER_ITEM_TYPE_NAME", "ORDER_TYPE_NAME", "ORDER_ITEM", "CITEM_NAME", "ODD_RCPDTL_ONCE_QUNT", "ODD_RCPDTL_TOTAL_QUNT", "DRUG_FREQ_NAME", "DRUG_METHOD_NAME", "DRUG_ONCE_DOSA_UNIT", "ANTIBIOTIC", "TOXI_CLAS", "ORDER_NOTE", "ORDER_EXE_STATUS", "ORDER_PLACE_TIME", "ORDER_PLCDEPT", "ORDER_PLACER") AS 
  Select a.Pvid,
       To_Date(x.Order_Plan_Start_Time, 'YYYY-MM-DD HH24:MI:SS') As Order_Start_Time,
       To_Date(x.Order_Plan_End_Time, 'YYYY-MM-DD HH24:MI:SS') As Order_End_Time,
       x.Order_Item_Type_Name,
       x.Order_Type_Name,
       x.Order_Item ||' 单次'||x.Odd_Rcpdtl_Once_Qunt||x.Drug_Once_Dosa_Unit as Order_Item,
       x.Citem_Name,
       x.Odd_Rcpdtl_Once_Qunt,
       x.Odd_Rcpdtl_Total_Qunt,
       x.Drug_Freq_Name,
       x.Drug_Method_Name,
       x.Drug_Once_Dosa_Unit,
       x.Antibiotic,
       x.Toxi_Clas,
       x.Order_Note,
       x.Order_Exe_Status,
       To_Date(x.Order_Place_Time, 'YYYY-MM-DD HH24:MI:SS') As Order_Place_Time,
       x.Order_Plcdept ,
       x.Order_Placer_Sig As Order_Placer
  From cdr.Pat_Emr a, cdr.Pat_Emr_Content b,
       Xmltable('//order_info' Passing b.Pat_Emr_Content
                Columns
                       Order_Plan_Start_Time Varchar2(20) Path 'order_plan_start_time',           --医嘱计划开始日期时间
                       Order_Plan_End_Time Varchar2(20) Path 'order_plan_end_time',               --医嘱计划结束日期时间
                       Order_Item_Type_Name Varchar2(20) Path 'order_item_type_name',             --医嘱项目内容
                       Order_Type_Name Varchar2(20) Path 'order_type_name',                       --医嘱类别名称
                       Order_Item Varchar2(200) Path 'order_item',                                --医嘱项目内容
                       Citem_Name Varchar2(200) Path 'citem_name',                                --诊疗项目名称
                       Odd_Rcpdtl_Once_Qunt Varchar2(10) Path 'odd_rcpdtl_once_qunt',             --单次用量
                       Odd_Rcpdtl_Total_Qunt Varchar2(10) Path 'odd_rcpdtl_total_qunt',           --总给予量
                       Drug_Freq_Name Varchar2(200) Path 'drug_freq_name',                        --药物使用频次名称
                       Drug_Method_Name Varchar2(50) Path 'drug_method_name',                     --药物使用途径名称
                       Drug_Once_Dosa_Unit Varchar2(10) Path 'drug_once_dosa_unit',               --药物使用剂量单位
                       Antibiotic Varchar2(2) Path 'antibiotic',                                  --抗生素
                       Toxi_Clas Varchar2(10) Path 'toxi_clas',                                   --毒理分类
                       Order_Note Varchar2(200) Path 'order_note',                                --医嘱备注信息
                       Order_Exe_Status Varchar2(50) Path 'order_exe_status',                     --医嘱执行状态
                       Order_Place_Time Varchar2(20) Path 'order_place_time',                     --医嘱开立日期日期
                       Order_Plcdept Varchar2(100) Path 'order_plcdept',                          --医嘱开立科室
                       Order_Placer_Sig Varchar2(100) Path 'order_placer_sig') x                  --医嘱开立者签名
Where a.Pat_Emr_Id = b.Pat_Emr_Id
  And (a.Emr_Dataset_Name=pkg_constant.INORDER_DATASET_CODE()
  or a.Emr_Dataset_Name=pkg_constant.outorder_dataset_code())
;

   COMMENT ON COLUMN "ZLCDR"."V_PAT_ORDER"."PVID" IS '患者就诊信息ID';
   COMMENT ON COLUMN "ZLCDR"."V_PAT_ORDER"."ORDER_START_TIME" IS '医嘱计划开始日期时间|';
   COMMENT ON COLUMN "ZLCDR"."V_PAT_ORDER"."ORDER_END_TIME" IS '医嘱计划结束日期时间|';
   COMMENT ON COLUMN "ZLCDR"."V_PAT_ORDER"."ORDER_ITEM_TYPE_NAME" IS '医嘱项目内容|';
   COMMENT ON COLUMN "ZLCDR"."V_PAT_ORDER"."ORDER_TYPE_NAME" IS '医嘱类别名称|';
   COMMENT ON COLUMN "ZLCDR"."V_PAT_ORDER"."ORDER_ITEM" IS '医嘱项目内容|';
   COMMENT ON COLUMN "ZLCDR"."V_PAT_ORDER"."CITEM_NAME" IS '诊疗项目名称|';
   COMMENT ON COLUMN "ZLCDR"."V_PAT_ORDER"."ODD_RCPDTL_ONCE_QUNT" IS '单次用量|';
   COMMENT ON COLUMN "ZLCDR"."V_PAT_ORDER"."ODD_RCPDTL_TOTAL_QUNT" IS '总给予量|';
   COMMENT ON COLUMN "ZLCDR"."V_PAT_ORDER"."DRUG_FREQ_NAME" IS '药物使用频次名称|';
   COMMENT ON COLUMN "ZLCDR"."V_PAT_ORDER"."DRUG_METHOD_NAME" IS '药物使用途径名称|';
   COMMENT ON COLUMN "ZLCDR"."V_PAT_ORDER"."DRUG_ONCE_DOSA_UNIT" IS '药物使用剂量单位|';
   COMMENT ON COLUMN "ZLCDR"."V_PAT_ORDER"."ANTIBIOTIC" IS '抗生素|';
   COMMENT ON COLUMN "ZLCDR"."V_PAT_ORDER"."TOXI_CLAS" IS '毒理分类|';
   COMMENT ON COLUMN "ZLCDR"."V_PAT_ORDER"."ORDER_NOTE" IS '医嘱备注信息|';
   COMMENT ON COLUMN "ZLCDR"."V_PAT_ORDER"."ORDER_EXE_STATUS" IS '医嘱执行状态|';
   COMMENT ON COLUMN "ZLCDR"."V_PAT_ORDER"."ORDER_PLACE_TIME" IS '医嘱开立日期日期|';
   COMMENT ON COLUMN "ZLCDR"."V_PAT_ORDER"."ORDER_PLCDEPT" IS '医嘱开立科室|';
   COMMENT ON COLUMN "ZLCDR"."V_PAT_ORDER"."ORDER_PLACER" IS '医嘱开立者签名|';
   COMMENT ON TABLE "ZLCDR"."V_PAT_ORDER"  IS '病人医嘱信息'
;
--------------------------------------------------------
--  DDL for View V_PAT_VISIT_INFO
--------------------------------------------------------

  CREATE OR REPLACE FORCE VIEW "ZLCDR"."V_PAT_VISIT_INFO" ("PVID", "PID", "PAT_NAME", "PAT_SEX_NAME", "PAT_AGE", "PAT_VISIT_TYPE_NAME", "PAT_VISIT_DATE", "OUTPNO", "INPNO", "PAT_ADTA_METHOD_NAME", "PAT_VISIT_DEPT", "PAT_VISIT_DR", "PAT_VISIT_WARD", "PAT_VISIT_PNURS", "PAT_VISIT_START_DATE", "PAT_VISIT_END_DATE", "PAT_VISIT_STATUS") AS 
  select t.pvid,
       t.pid,
       t.pat_name,
       t.pat_sex_name,
       t.pat_age,
       t.pat_visit_type_name,
       t.pat_visit_date,
       t.outpno,
       t.inpno,
       t.pat_adta_method_name,
       t.pat_visit_dept,
       t.pat_visit_dr,
       t.pat_visit_ward,
       t.pat_visit_pnurs,
       t.pat_visit_start_date,
       t.pat_visit_end_date,
       decode(t.pat_visit_status,1,'已接诊',2,'已完成') pat_visit_status
  from CDR.PAT_VISIT_INFO t
;

   COMMENT ON COLUMN "ZLCDR"."V_PAT_VISIT_INFO"."PVID" IS '患者就诊信息ID|';
   COMMENT ON COLUMN "ZLCDR"."V_PAT_VISIT_INFO"."PID" IS '患者ID|';
   COMMENT ON COLUMN "ZLCDR"."V_PAT_VISIT_INFO"."PAT_NAME" IS '患者姓名|';
   COMMENT ON COLUMN "ZLCDR"."V_PAT_VISIT_INFO"."PAT_SEX_NAME" IS '患者性别名称|';
   COMMENT ON COLUMN "ZLCDR"."V_PAT_VISIT_INFO"."PAT_AGE" IS '患者年龄|';
   COMMENT ON COLUMN "ZLCDR"."V_PAT_VISIT_INFO"."PAT_VISIT_TYPE_NAME" IS '患者就诊类型名称|';
   COMMENT ON COLUMN "ZLCDR"."V_PAT_VISIT_INFO"."PAT_VISIT_DATE" IS '患者就诊时间|';
   COMMENT ON COLUMN "ZLCDR"."V_PAT_VISIT_INFO"."OUTPNO" IS '门诊号|';
   COMMENT ON COLUMN "ZLCDR"."V_PAT_VISIT_INFO"."INPNO" IS '住院号|';
   COMMENT ON COLUMN "ZLCDR"."V_PAT_VISIT_INFO"."PAT_ADTA_METHOD_NAME" IS '患者入院途径名称|';
   COMMENT ON COLUMN "ZLCDR"."V_PAT_VISIT_INFO"."PAT_VISIT_DEPT" IS '患者就诊科室名称|';
   COMMENT ON COLUMN "ZLCDR"."V_PAT_VISIT_INFO"."PAT_VISIT_DR" IS '患者接诊医生|';
   COMMENT ON COLUMN "ZLCDR"."V_PAT_VISIT_INFO"."PAT_VISIT_WARD" IS '患者就诊病区名称|';
   COMMENT ON COLUMN "ZLCDR"."V_PAT_VISIT_INFO"."PAT_VISIT_PNURS" IS '责任护士名称|';
   COMMENT ON COLUMN "ZLCDR"."V_PAT_VISIT_INFO"."PAT_VISIT_START_DATE" IS '患者就诊开始时间|';
   COMMENT ON COLUMN "ZLCDR"."V_PAT_VISIT_INFO"."PAT_VISIT_END_DATE" IS '患者就诊结束时间|';
   COMMENT ON COLUMN "ZLCDR"."V_PAT_VISIT_INFO"."PAT_VISIT_STATUS" IS '患者就诊状态|1-已接诊;2-已完成';
   COMMENT ON TABLE "ZLCDR"."V_PAT_VISIT_INFO"  IS '患者就诊信息'
;
--------------------------------------------------------
--  DDL for View V_PAT_VITAL_SIGN
--------------------------------------------------------

  CREATE OR REPLACE FORCE VIEW "ZLCDR"."V_PAT_VITAL_SIGN" ("PVID", "OCCUR_TIME", "ITEM_NAME", "RECORD_CONTENT", "ITEM_UNIT", "RESULT_EXP", "RECORDER", "RECORD_TIME") AS 
  Select a.pvid,
       To_Date(x.Occur_Time, 'YYYY-MM-DD HH24:MI:SS') As Occur_Time,
       x.Item_Name,
       x.Record_Content,
       x.Item_Unit,
       x.Result_Exp,
       x.Recorder,
       To_Date(x.Record_Time, 'YYYY-MM-DD HH24:MI:SS') As Record_Time
  From cdr.pat_emr a, cdr.pat_emr_content b,
       Xmltable('//vital_detail' Passing b.pat_emr_content
                Columns
                       Occur_Time Varchar2(20) Path 'occur_time',                   --发生时间
                       Item_Name Varchar2(20) Path 'item_name',                     --项目名称
                       Record_Content Varchar2(20) Path 'record_content',           --记录内容
                       Item_Unit Varchar2(20) Path 'item_unit',                     --项目单位
                       Recorder Varchar2(100) Path 'recoder',                       --记录人
                       Record_Time Varchar2(20) Path 'record_time',                 --记录时间
                       Result_Exp Varchar2(100) Path 'record_exp') x                --结果说明
  Where a.Emr_Dataset_Name = '生命体征测量记录'
    and a.pat_emr_id = b.pat_emr_id
;

   COMMENT ON COLUMN "ZLCDR"."V_PAT_VITAL_SIGN"."PVID" IS '患者就诊信息ID';
   COMMENT ON COLUMN "ZLCDR"."V_PAT_VITAL_SIGN"."OCCUR_TIME" IS '发生时间|';
   COMMENT ON COLUMN "ZLCDR"."V_PAT_VITAL_SIGN"."ITEM_NAME" IS '项目名称|';
   COMMENT ON COLUMN "ZLCDR"."V_PAT_VITAL_SIGN"."RECORD_CONTENT" IS '记录内容|';
   COMMENT ON COLUMN "ZLCDR"."V_PAT_VITAL_SIGN"."ITEM_UNIT" IS '项目单位|';
   COMMENT ON COLUMN "ZLCDR"."V_PAT_VITAL_SIGN"."RESULT_EXP" IS '结果说明|';
   COMMENT ON COLUMN "ZLCDR"."V_PAT_VITAL_SIGN"."RECORDER" IS '记录人|';
   COMMENT ON COLUMN "ZLCDR"."V_PAT_VITAL_SIGN"."RECORD_TIME" IS '记录时间|';
   COMMENT ON TABLE "ZLCDR"."V_PAT_VITAL_SIGN"  IS '生命体征'
;
