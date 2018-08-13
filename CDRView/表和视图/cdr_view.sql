--------------------------------------------------------
--  �ļ��Ѵ��� - ����һ-����-13-2018   
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

   COMMENT ON COLUMN "ZLCDR"."V_EMR_DATASET"."EMR_DATASET_CLASS_SIGN" IS '���ݼ������ʶ|0-���ݼ�;1-����';
   COMMENT ON COLUMN "ZLCDR"."V_EMR_DATASET"."EMR_DATASET_CODE" IS 'EMR���ݼ�����';
   COMMENT ON COLUMN "ZLCDR"."V_EMR_DATASET"."EMR_DATASET_NAME" IS 'EMR���ݼ�����';
   COMMENT ON COLUMN "ZLCDR"."V_EMR_DATASET"."EMR_DATASET_TYPE" IS 'EMR���ݼ�����|1-���ݼ�����;2-���ݼ��Ӽ�';
   COMMENT ON COLUMN "ZLCDR"."V_EMR_DATASET"."EMR_DATASET_USE_SIGN" IS 'EMR���ݼ�����ʹ��״̬|0-��ͣ��;1-������';
   COMMENT ON TABLE "ZLCDR"."V_EMR_DATASET"  IS '��������ֵ��'
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

   COMMENT ON COLUMN "ZLCDR"."V_EXAMINE_DATASET"."EMR_DATASET_CLASS_SIGN" IS '���ݼ������ʶ|0-���ݼ�;1-����';
   COMMENT ON COLUMN "ZLCDR"."V_EXAMINE_DATASET"."EMR_DATASET_CODE" IS 'EMR���ݼ�����';
   COMMENT ON COLUMN "ZLCDR"."V_EXAMINE_DATASET"."EMR_DATASET_NAME" IS 'EMR���ݼ�����';
   COMMENT ON COLUMN "ZLCDR"."V_EXAMINE_DATASET"."EMR_DATASET_TYPE" IS 'EMR���ݼ�����|1-���ݼ�����;2-���ݼ��Ӽ�';
   COMMENT ON COLUMN "ZLCDR"."V_EXAMINE_DATASET"."EMR_DATASET_USE_SIGN" IS 'EMR���ݼ�����ʹ��״̬|0-��ͣ��;1-������';
   COMMENT ON TABLE "ZLCDR"."V_EXAMINE_DATASET"  IS '��鱨�����ֵ��'
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
  select 1 as code ,   '��ҽ�������' as name from dual
union all
select 2 as code ,   '��ҽ��Ժ���' as name from dual
union all
select 3 as code ,   '��ҽ��Ժ���' as name from dual
union all
select 5 as code ,   'Ժ�ڸ�Ⱦ' as name from dual
union all
select 6 as code ,   '�������' as name from dual
union all
select 7 as code ,   '�����ж���' as name from dual
union all
select 8 as code ,   '��ǰ���' as name from dual
union all
select 9 as code ,   '�������' as name from dual
union all
select 10 as code ,   '����֢' as name from dual
union all
select 11 as code ,   '��ҽ�������' as name from dual
union all
select 12 as code ,   '��ҽ��Ժ���' as name from dual
union all
select 13 as code ,   '��ҽ��Ժ���' as name from dual
union all
select 21 as code ,   '��ԭѧ���' as name from dual
union all
select 22 as code ,   'Ӱ��ѧ���' as name from dual
;

   COMMENT ON COLUMN "ZLCDR"."V_LOV_DIAG_TYPE"."CODE" IS '����������|1-��ҽ�������;2-��ҽ��Ժ���;3-��ҽ��Ժ���;5-Ժ�ڸ�Ⱦ;6-�������;7-�����ж���,8-��ǰ���;9-�������;10-����֢;11-��ҽ�������;12-��ҽ��Ժ���;13-��ҽ��Ժ���;21-��ԭѧ���;22-Ӱ��ѧ���';
   COMMENT ON COLUMN "ZLCDR"."V_LOV_DIAG_TYPE"."NAME" IS '����������';
   COMMENT ON TABLE "ZLCDR"."V_LOV_DIAG_TYPE"  IS '�������ֵ��'
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
                       Algc_Hist_Sign Varchar2(10) Path 'algc_hist_sign',     --������־
                       Algc_Sour_Dese Varchar2(500) Path 'algc_sour_desc',    --����Դ����
                       Algc_Ans Varchar(1000) Path 'algc_ans',                --������Ӧ
                       Algc_Recoder Varchar2(200) Path 'algc_recoder',        --������¼��
                       Algc_Rec_Time Varchar2(20) Path 'algc_rec_time',       --������¼ʱ��
                       Algc_Ans_Time Varchar2(20) Path 'algc_ans_time') x     --����ʱ��
 Where a.Emr_Dataset_Name = pkg_constant.EMR_DATASET_NAME()
   And a.Pat_Emr_Id = b.Pat_Emr_Id
   And x.Algc_Hist_Sign = 'true'
;

   COMMENT ON COLUMN "ZLCDR"."V_PAT_ALGC_INFO"."PVID" IS '���߾�����ϢID|';
   COMMENT ON COLUMN "ZLCDR"."V_PAT_ALGC_INFO"."ALGC_SOUR_DESE" IS '����Դ����|';
   COMMENT ON COLUMN "ZLCDR"."V_PAT_ALGC_INFO"."ALGC_ANS" IS '������Ӧ|';
   COMMENT ON COLUMN "ZLCDR"."V_PAT_ALGC_INFO"."ALGC_RECODER" IS '������¼��|';
   COMMENT ON COLUMN "ZLCDR"."V_PAT_ALGC_INFO"."ALGC_REC_TIME" IS '������¼ʱ��|';
   COMMENT ON COLUMN "ZLCDR"."V_PAT_ALGC_INFO"."ALGC_ANS_TIME" IS '����ʱ��|';
   COMMENT ON TABLE "ZLCDR"."V_PAT_ALGC_INFO"  IS '���߹�����¼'
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

   COMMENT ON COLUMN "ZLCDR"."V_PAT_DIAG"."PAT_DIAG_ID" IS '�������ID|';
   COMMENT ON COLUMN "ZLCDR"."V_PAT_DIAG"."APPSYS_ID" IS 'Ӧ��ϵͳID|';
   COMMENT ON COLUMN "ZLCDR"."V_PAT_DIAG"."PVID" IS '���߾�����ϢID|';
   COMMENT ON COLUMN "ZLCDR"."V_PAT_DIAG"."PID" IS '����ID|';
   COMMENT ON COLUMN "ZLCDR"."V_PAT_DIAG"."PAT_DIAG_SNO" IS '�������˳��|';
   COMMENT ON COLUMN "ZLCDR"."V_PAT_DIAG"."PAT_DIAG_TYPE" IS '����������|1-��ҽ�������;2-��ҽ��Ժ���;3-��ҽ��Ժ���;5-Ժ�ڸ�Ⱦ;6-�������;7-�����ж���,8-��ǰ���;9-�������;10-����֢;11-��ҽ�������;12-��ҽ��Ժ���;13-��ҽ��Ժ���;21-��ԭѧ���;22-Ӱ��ѧ���';
   COMMENT ON COLUMN "ZLCDR"."V_PAT_DIAG"."PAT_DIAG_TYPE_NAME" IS '�����������';
   COMMENT ON COLUMN "ZLCDR"."V_PAT_DIAG"."DIAG_NAME" IS '�������|';
   COMMENT ON COLUMN "ZLCDR"."V_PAT_DIAG"."DIAG_CODE" IS '��ϱ���|';
   COMMENT ON COLUMN "ZLCDR"."V_PAT_DIAG"."PAT_DIAG_DESC" IS '�����������|';
   COMMENT ON COLUMN "ZLCDR"."V_PAT_DIAG"."DIAG_STATUS_NAME" IS '���״̬����|CV05.01.002';
   COMMENT ON COLUMN "ZLCDR"."V_PAT_DIAG"."PAT_DIAG_RECORD_TIME" IS '������ϼ�¼ʱ��|';
   COMMENT ON COLUMN "ZLCDR"."V_PAT_DIAG"."PAT_DIAG_RECODER" IS '������ϼ�¼��|';
   COMMENT ON TABLE "ZLCDR"."V_PAT_DIAG"  IS '���������Ϣ|'
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
       x.Order_Item ||' ����'||x.Odd_Rcpdtl_Once_Qunt||x.Drug_Once_Dosa_Unit as Order_Item,
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
                       Order_Plan_Start_Time Varchar2(20) Path 'order_plan_start_time',           --ҽ���ƻ���ʼ����ʱ��
                       Order_Plan_End_Time Varchar2(20) Path 'order_plan_end_time',               --ҽ���ƻ���������ʱ��
                       Order_Item_Type_Name Varchar2(20) Path 'order_item_type_name',             --ҽ����Ŀ����
                       Order_Type_Name Varchar2(20) Path 'order_type_name',                       --ҽ���������
                       Order_Item Varchar2(200) Path 'order_item',                                --ҽ����Ŀ����
                       Citem_Name Varchar2(200) Path 'citem_name',                                --������Ŀ����
                       Odd_Rcpdtl_Once_Qunt Varchar2(10) Path 'odd_rcpdtl_once_qunt',             --��������
                       Odd_Rcpdtl_Total_Qunt Varchar2(10) Path 'odd_rcpdtl_total_qunt',           --�ܸ�����
                       Drug_Freq_Name Varchar2(200) Path 'drug_freq_name',                        --ҩ��ʹ��Ƶ������
                       Drug_Method_Name Varchar2(50) Path 'drug_method_name',                     --ҩ��ʹ��;������
                       Drug_Once_Dosa_Unit Varchar2(10) Path 'drug_once_dosa_unit',               --ҩ��ʹ�ü�����λ
                       Antibiotic Varchar2(2) Path 'antibiotic',                                  --������
                       Toxi_Clas Varchar2(10) Path 'toxi_clas',                                   --�������
                       Order_Note Varchar2(200) Path 'order_note',                                --ҽ����ע��Ϣ
                       Order_Exe_Status Varchar2(50) Path 'order_exe_status',                     --ҽ��ִ��״̬
                       Order_Place_Time Varchar2(20) Path 'order_place_time',                     --ҽ��������������
                       Order_Plcdept Varchar2(100) Path 'order_plcdept',                          --ҽ����������
                       Order_Placer_Sig Varchar2(100) Path 'order_placer_sig') x                  --ҽ��������ǩ��
Where a.Pat_Emr_Id = b.Pat_Emr_Id
  And (a.Emr_Dataset_Name=pkg_constant.INORDER_DATASET_CODE()
  or a.Emr_Dataset_Name=pkg_constant.outorder_dataset_code())
  and x.Order_Item_Type_Name=pkg_constant.Order_Item_Type_Name()
;

   COMMENT ON COLUMN "ZLCDR"."V_PAT_DRUG_INFO"."PVID" IS '���߾�����ϢID';
   COMMENT ON COLUMN "ZLCDR"."V_PAT_DRUG_INFO"."ORDER_START_TIME" IS 'ҽ���ƻ���ʼ����ʱ��|';
   COMMENT ON COLUMN "ZLCDR"."V_PAT_DRUG_INFO"."ORDER_END_TIME" IS 'ҽ���ƻ���������ʱ��|';
   COMMENT ON COLUMN "ZLCDR"."V_PAT_DRUG_INFO"."ORDER_ITEM_TYPE_NAME" IS 'ҽ����Ŀ����|';
   COMMENT ON COLUMN "ZLCDR"."V_PAT_DRUG_INFO"."ORDER_TYPE_NAME" IS 'ҽ���������|';
   COMMENT ON COLUMN "ZLCDR"."V_PAT_DRUG_INFO"."ORDER_ITEM" IS 'ҽ����Ŀ����|';
   COMMENT ON COLUMN "ZLCDR"."V_PAT_DRUG_INFO"."CITEM_NAME" IS '������Ŀ����|';
   COMMENT ON COLUMN "ZLCDR"."V_PAT_DRUG_INFO"."ODD_RCPDTL_ONCE_QUNT" IS '��������|';
   COMMENT ON COLUMN "ZLCDR"."V_PAT_DRUG_INFO"."ODD_RCPDTL_TOTAL_QUNT" IS '�ܸ�����|';
   COMMENT ON COLUMN "ZLCDR"."V_PAT_DRUG_INFO"."DRUG_FREQ_NAME" IS 'ҩ��ʹ��Ƶ������|';
   COMMENT ON COLUMN "ZLCDR"."V_PAT_DRUG_INFO"."DRUG_METHOD_NAME" IS 'ҩ��ʹ��;������|';
   COMMENT ON COLUMN "ZLCDR"."V_PAT_DRUG_INFO"."DRUG_ONCE_DOSA_UNIT" IS 'ҩ��ʹ�ü�����λ|';
   COMMENT ON COLUMN "ZLCDR"."V_PAT_DRUG_INFO"."ANTIBIOTIC" IS '������|';
   COMMENT ON COLUMN "ZLCDR"."V_PAT_DRUG_INFO"."TOXI_CLAS" IS '�������|';
   COMMENT ON COLUMN "ZLCDR"."V_PAT_DRUG_INFO"."ORDER_NOTE" IS 'ҽ����ע��Ϣ|';
   COMMENT ON COLUMN "ZLCDR"."V_PAT_DRUG_INFO"."ORDER_EXE_STATUS" IS 'ҽ��ִ��״̬|';
   COMMENT ON COLUMN "ZLCDR"."V_PAT_DRUG_INFO"."ORDER_PLACE_TIME" IS 'ҽ��������������|';
   COMMENT ON COLUMN "ZLCDR"."V_PAT_DRUG_INFO"."ORDER_PLCDEPT" IS 'ҽ����������|';
   COMMENT ON COLUMN "ZLCDR"."V_PAT_DRUG_INFO"."ORDER_PLACER" IS 'ҽ��������ǩ��|';
   COMMENT ON TABLE "ZLCDR"."V_PAT_DRUG_INFO"  IS '������ҩ��Ϣ'
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

   COMMENT ON COLUMN "ZLCDR"."V_PAT_EMR"."PVID" IS '���߾�����ϢID|';
   COMMENT ON COLUMN "ZLCDR"."V_PAT_EMR"."APPSYS_LNK_EMR_ID" IS 'Ӧ��ϵͳ����EMR_ID|�洢�ϼ��ĵ���ID';
   COMMENT ON COLUMN "ZLCDR"."V_PAT_EMR"."APPSYS_EMR_ID" IS 'Ӧ��ϵͳEMR_ID|';
   COMMENT ON COLUMN "ZLCDR"."V_PAT_EMR"."APPSYS_ID" IS 'Ӧ��ϵͳID|';
   COMMENT ON COLUMN "ZLCDR"."V_PAT_EMR"."PAT_EMR_ID" IS '����EMR_ID|';
   COMMENT ON COLUMN "ZLCDR"."V_PAT_EMR"."EMR_DATASET_NAME" IS 'EMR���ݼ�����|';
   COMMENT ON COLUMN "ZLCDR"."V_PAT_EMR"."EMR_DATASET_CODE" IS 'EMR���ݼ�����|';
   COMMENT ON COLUMN "ZLCDR"."V_PAT_EMR"."APPSYS_EMR_ANTETYPE_ID" IS 'Ӧ��ϵͳemrԭ��id|';
   COMMENT ON COLUMN "ZLCDR"."V_PAT_EMR"."EMR_CREATE_TIME" IS 'emr����ʱ��|';
   COMMENT ON TABLE "ZLCDR"."V_PAT_EMR"  IS '���߲���'
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
                       exam_item_name Varchar2(500) Path 'exam_item_name'    --��鱨������
                       ) x
         Where
         a.pat_emr_id=c.pat_emr_id and
         a.emr_dataset_code=b.emr_dataset_code
;

   COMMENT ON COLUMN "ZLCDR"."V_PAT_EXAMINE"."PVID" IS '���߾�����ϢID|';
   COMMENT ON COLUMN "ZLCDR"."V_PAT_EXAMINE"."APPSYS_LNK_EMR_ID" IS 'Ӧ��ϵͳ����EMR_ID|�洢�ϼ��ĵ���ID';
   COMMENT ON COLUMN "ZLCDR"."V_PAT_EXAMINE"."APPSYS_EMR_ID" IS 'Ӧ��ϵͳEMR_ID|';
   COMMENT ON COLUMN "ZLCDR"."V_PAT_EXAMINE"."APPSYS_ID" IS 'Ӧ��ϵͳID|';
   COMMENT ON COLUMN "ZLCDR"."V_PAT_EXAMINE"."PAT_EMR_ID" IS '����EMR_ID|';
   COMMENT ON COLUMN "ZLCDR"."V_PAT_EXAMINE"."EMR_DATASET_NAME" IS 'EMR���ݼ�����|';
   COMMENT ON COLUMN "ZLCDR"."V_PAT_EXAMINE"."EMR_DATASET_CODE" IS 'EMR���ݼ�����|';
   COMMENT ON COLUMN "ZLCDR"."V_PAT_EXAMINE"."APPSYS_EMR_ANTETYPE_ID" IS 'Ӧ��ϵͳemrԭ��id|';
   COMMENT ON COLUMN "ZLCDR"."V_PAT_EXAMINE"."EMR_CREATE_TIME" IS 'emr����ʱ��|';
   COMMENT ON COLUMN "ZLCDR"."V_PAT_EXAMINE"."EXAM_ITEM_NAME" IS '��鱨������|';
   COMMENT ON TABLE "ZLCDR"."V_PAT_EXAMINE"  IS '���߼��'
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

   COMMENT ON COLUMN "ZLCDR"."V_PAT_INFO"."PID" IS '����ID|';
   COMMENT ON COLUMN "ZLCDR"."V_PAT_INFO"."PAT_NAME" IS '��������|';
   COMMENT ON COLUMN "ZLCDR"."V_PAT_INFO"."PAT_SEX_NAME" IS '�����Ա�����|';
   COMMENT ON COLUMN "ZLCDR"."V_PAT_INFO"."PAT_BRSDATE" IS '���߳�������|';
   COMMENT ON COLUMN "ZLCDR"."V_PAT_INFO"."COUNTRY_NAME" IS '��������|';
   COMMENT ON COLUMN "ZLCDR"."V_PAT_INFO"."NTVPLC_NAME" IS '��������|';
   COMMENT ON COLUMN "ZLCDR"."V_PAT_INFO"."NATION_NAME" IS '��������|';
   COMMENT ON COLUMN "ZLCDR"."V_PAT_INFO"."EDU_NAME" IS 'ѧ������|';
   COMMENT ON COLUMN "ZLCDR"."V_PAT_INFO"."OCPT_NAME" IS 'ְҵ����|';
   COMMENT ON COLUMN "ZLCDR"."V_PAT_INFO"."ABO_BLD_NAME" IS 'ABOѪ������|';
   COMMENT ON COLUMN "ZLCDR"."V_PAT_INFO"."RH_BLD_NAME" IS 'RHѪ������|';
   COMMENT ON COLUMN "ZLCDR"."V_PAT_INFO"."INSURE_NAME" IS 'ҽ�Ʊ����������|';
   COMMENT ON COLUMN "ZLCDR"."V_PAT_INFO"."HEALTH_CARD_NO" IS '��������|';
   COMMENT ON TABLE "ZLCDR"."V_PAT_INFO"  IS '������Ϣ'
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
                       lab_item_name Varchar2(500) Path 'lab_item_name'    --���鱨������
                       ) x
         Where
         a.pat_emr_id=c.pat_emr_id and
         a.emr_dataset_code=b.emr_dataset_code
;

   COMMENT ON COLUMN "ZLCDR"."V_PAT_LIS"."PVID" IS '���߾�����ϢID|';
   COMMENT ON COLUMN "ZLCDR"."V_PAT_LIS"."APPSYS_LNK_EMR_ID" IS 'Ӧ��ϵͳ����EMR_ID|�洢�ϼ��ĵ���ID';
   COMMENT ON COLUMN "ZLCDR"."V_PAT_LIS"."APPSYS_EMR_ID" IS 'Ӧ��ϵͳEMR_ID|';
   COMMENT ON COLUMN "ZLCDR"."V_PAT_LIS"."APPSYS_ID" IS 'Ӧ��ϵͳID|';
   COMMENT ON COLUMN "ZLCDR"."V_PAT_LIS"."PAT_EMR_ID" IS '����EMR_ID|';
   COMMENT ON COLUMN "ZLCDR"."V_PAT_LIS"."EMR_DATASET_NAME" IS 'EMR���ݼ�����|';
   COMMENT ON COLUMN "ZLCDR"."V_PAT_LIS"."EMR_DATASET_CODE" IS 'EMR���ݼ�����|';
   COMMENT ON COLUMN "ZLCDR"."V_PAT_LIS"."APPSYS_EMR_ANTETYPE_ID" IS 'Ӧ��ϵͳemrԭ��id|';
   COMMENT ON COLUMN "ZLCDR"."V_PAT_LIS"."EMR_CREATE_TIME" IS 'emr����ʱ��|';
   COMMENT ON COLUMN "ZLCDR"."V_PAT_LIS"."LAB_ITEM_NAME" IS '���鱨������|';
   COMMENT ON TABLE "ZLCDR"."V_PAT_LIS"  IS '���߼���'
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
       x.Order_Item ||' ����'||x.Odd_Rcpdtl_Once_Qunt||x.Drug_Once_Dosa_Unit as Order_Item,
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
                       Order_Plan_Start_Time Varchar2(20) Path 'order_plan_start_time',           --ҽ���ƻ���ʼ����ʱ��
                       Order_Plan_End_Time Varchar2(20) Path 'order_plan_end_time',               --ҽ���ƻ���������ʱ��
                       Order_Item_Type_Name Varchar2(20) Path 'order_item_type_name',             --ҽ����Ŀ����
                       Order_Type_Name Varchar2(20) Path 'order_type_name',                       --ҽ���������
                       Order_Item Varchar2(200) Path 'order_item',                                --ҽ����Ŀ����
                       Citem_Name Varchar2(200) Path 'citem_name',                                --������Ŀ����
                       Odd_Rcpdtl_Once_Qunt Varchar2(10) Path 'odd_rcpdtl_once_qunt',             --��������
                       Odd_Rcpdtl_Total_Qunt Varchar2(10) Path 'odd_rcpdtl_total_qunt',           --�ܸ�����
                       Drug_Freq_Name Varchar2(200) Path 'drug_freq_name',                        --ҩ��ʹ��Ƶ������
                       Drug_Method_Name Varchar2(50) Path 'drug_method_name',                     --ҩ��ʹ��;������
                       Drug_Once_Dosa_Unit Varchar2(10) Path 'drug_once_dosa_unit',               --ҩ��ʹ�ü�����λ
                       Antibiotic Varchar2(2) Path 'antibiotic',                                  --������
                       Toxi_Clas Varchar2(10) Path 'toxi_clas',                                   --�������
                       Order_Note Varchar2(200) Path 'order_note',                                --ҽ����ע��Ϣ
                       Order_Exe_Status Varchar2(50) Path 'order_exe_status',                     --ҽ��ִ��״̬
                       Order_Place_Time Varchar2(20) Path 'order_place_time',                     --ҽ��������������
                       Order_Plcdept Varchar2(100) Path 'order_plcdept',                          --ҽ����������
                       Order_Placer_Sig Varchar2(100) Path 'order_placer_sig') x                  --ҽ��������ǩ��
Where a.Pat_Emr_Id = b.Pat_Emr_Id
  And (a.Emr_Dataset_Name=pkg_constant.INORDER_DATASET_CODE()
  or a.Emr_Dataset_Name=pkg_constant.outorder_dataset_code())
;

   COMMENT ON COLUMN "ZLCDR"."V_PAT_ORDER"."PVID" IS '���߾�����ϢID';
   COMMENT ON COLUMN "ZLCDR"."V_PAT_ORDER"."ORDER_START_TIME" IS 'ҽ���ƻ���ʼ����ʱ��|';
   COMMENT ON COLUMN "ZLCDR"."V_PAT_ORDER"."ORDER_END_TIME" IS 'ҽ���ƻ���������ʱ��|';
   COMMENT ON COLUMN "ZLCDR"."V_PAT_ORDER"."ORDER_ITEM_TYPE_NAME" IS 'ҽ����Ŀ����|';
   COMMENT ON COLUMN "ZLCDR"."V_PAT_ORDER"."ORDER_TYPE_NAME" IS 'ҽ���������|';
   COMMENT ON COLUMN "ZLCDR"."V_PAT_ORDER"."ORDER_ITEM" IS 'ҽ����Ŀ����|';
   COMMENT ON COLUMN "ZLCDR"."V_PAT_ORDER"."CITEM_NAME" IS '������Ŀ����|';
   COMMENT ON COLUMN "ZLCDR"."V_PAT_ORDER"."ODD_RCPDTL_ONCE_QUNT" IS '��������|';
   COMMENT ON COLUMN "ZLCDR"."V_PAT_ORDER"."ODD_RCPDTL_TOTAL_QUNT" IS '�ܸ�����|';
   COMMENT ON COLUMN "ZLCDR"."V_PAT_ORDER"."DRUG_FREQ_NAME" IS 'ҩ��ʹ��Ƶ������|';
   COMMENT ON COLUMN "ZLCDR"."V_PAT_ORDER"."DRUG_METHOD_NAME" IS 'ҩ��ʹ��;������|';
   COMMENT ON COLUMN "ZLCDR"."V_PAT_ORDER"."DRUG_ONCE_DOSA_UNIT" IS 'ҩ��ʹ�ü�����λ|';
   COMMENT ON COLUMN "ZLCDR"."V_PAT_ORDER"."ANTIBIOTIC" IS '������|';
   COMMENT ON COLUMN "ZLCDR"."V_PAT_ORDER"."TOXI_CLAS" IS '�������|';
   COMMENT ON COLUMN "ZLCDR"."V_PAT_ORDER"."ORDER_NOTE" IS 'ҽ����ע��Ϣ|';
   COMMENT ON COLUMN "ZLCDR"."V_PAT_ORDER"."ORDER_EXE_STATUS" IS 'ҽ��ִ��״̬|';
   COMMENT ON COLUMN "ZLCDR"."V_PAT_ORDER"."ORDER_PLACE_TIME" IS 'ҽ��������������|';
   COMMENT ON COLUMN "ZLCDR"."V_PAT_ORDER"."ORDER_PLCDEPT" IS 'ҽ����������|';
   COMMENT ON COLUMN "ZLCDR"."V_PAT_ORDER"."ORDER_PLACER" IS 'ҽ��������ǩ��|';
   COMMENT ON TABLE "ZLCDR"."V_PAT_ORDER"  IS '����ҽ����Ϣ'
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
       decode(t.pat_visit_status,1,'�ѽ���',2,'�����') pat_visit_status
  from CDR.PAT_VISIT_INFO t
;

   COMMENT ON COLUMN "ZLCDR"."V_PAT_VISIT_INFO"."PVID" IS '���߾�����ϢID|';
   COMMENT ON COLUMN "ZLCDR"."V_PAT_VISIT_INFO"."PID" IS '����ID|';
   COMMENT ON COLUMN "ZLCDR"."V_PAT_VISIT_INFO"."PAT_NAME" IS '��������|';
   COMMENT ON COLUMN "ZLCDR"."V_PAT_VISIT_INFO"."PAT_SEX_NAME" IS '�����Ա�����|';
   COMMENT ON COLUMN "ZLCDR"."V_PAT_VISIT_INFO"."PAT_AGE" IS '��������|';
   COMMENT ON COLUMN "ZLCDR"."V_PAT_VISIT_INFO"."PAT_VISIT_TYPE_NAME" IS '���߾�����������|';
   COMMENT ON COLUMN "ZLCDR"."V_PAT_VISIT_INFO"."PAT_VISIT_DATE" IS '���߾���ʱ��|';
   COMMENT ON COLUMN "ZLCDR"."V_PAT_VISIT_INFO"."OUTPNO" IS '�����|';
   COMMENT ON COLUMN "ZLCDR"."V_PAT_VISIT_INFO"."INPNO" IS 'סԺ��|';
   COMMENT ON COLUMN "ZLCDR"."V_PAT_VISIT_INFO"."PAT_ADTA_METHOD_NAME" IS '������Ժ;������|';
   COMMENT ON COLUMN "ZLCDR"."V_PAT_VISIT_INFO"."PAT_VISIT_DEPT" IS '���߾����������|';
   COMMENT ON COLUMN "ZLCDR"."V_PAT_VISIT_INFO"."PAT_VISIT_DR" IS '���߽���ҽ��|';
   COMMENT ON COLUMN "ZLCDR"."V_PAT_VISIT_INFO"."PAT_VISIT_WARD" IS '���߾��ﲡ������|';
   COMMENT ON COLUMN "ZLCDR"."V_PAT_VISIT_INFO"."PAT_VISIT_PNURS" IS '���λ�ʿ����|';
   COMMENT ON COLUMN "ZLCDR"."V_PAT_VISIT_INFO"."PAT_VISIT_START_DATE" IS '���߾��￪ʼʱ��|';
   COMMENT ON COLUMN "ZLCDR"."V_PAT_VISIT_INFO"."PAT_VISIT_END_DATE" IS '���߾������ʱ��|';
   COMMENT ON COLUMN "ZLCDR"."V_PAT_VISIT_INFO"."PAT_VISIT_STATUS" IS '���߾���״̬|1-�ѽ���;2-�����';
   COMMENT ON TABLE "ZLCDR"."V_PAT_VISIT_INFO"  IS '���߾�����Ϣ'
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
                       Occur_Time Varchar2(20) Path 'occur_time',                   --����ʱ��
                       Item_Name Varchar2(20) Path 'item_name',                     --��Ŀ����
                       Record_Content Varchar2(20) Path 'record_content',           --��¼����
                       Item_Unit Varchar2(20) Path 'item_unit',                     --��Ŀ��λ
                       Recorder Varchar2(100) Path 'recoder',                       --��¼��
                       Record_Time Varchar2(20) Path 'record_time',                 --��¼ʱ��
                       Result_Exp Varchar2(100) Path 'record_exp') x                --���˵��
  Where a.Emr_Dataset_Name = '��������������¼'
    and a.pat_emr_id = b.pat_emr_id
;

   COMMENT ON COLUMN "ZLCDR"."V_PAT_VITAL_SIGN"."PVID" IS '���߾�����ϢID';
   COMMENT ON COLUMN "ZLCDR"."V_PAT_VITAL_SIGN"."OCCUR_TIME" IS '����ʱ��|';
   COMMENT ON COLUMN "ZLCDR"."V_PAT_VITAL_SIGN"."ITEM_NAME" IS '��Ŀ����|';
   COMMENT ON COLUMN "ZLCDR"."V_PAT_VITAL_SIGN"."RECORD_CONTENT" IS '��¼����|';
   COMMENT ON COLUMN "ZLCDR"."V_PAT_VITAL_SIGN"."ITEM_UNIT" IS '��Ŀ��λ|';
   COMMENT ON COLUMN "ZLCDR"."V_PAT_VITAL_SIGN"."RESULT_EXP" IS '���˵��|';
   COMMENT ON COLUMN "ZLCDR"."V_PAT_VITAL_SIGN"."RECORDER" IS '��¼��|';
   COMMENT ON COLUMN "ZLCDR"."V_PAT_VITAL_SIGN"."RECORD_TIME" IS '��¼ʱ��|';
   COMMENT ON TABLE "ZLCDR"."V_PAT_VITAL_SIGN"  IS '��������'
;
