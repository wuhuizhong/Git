CREATE OR REPLACE package pkg_constant as

--CDR数据集中的病历文档编码
V_EMR_DATASET_CODE CONSTANT varchar2(4000) :='ZLEMR.02,ZLEMR.03,ZLEMR.34,ZLEMR.35,ZLEMR.36,ZLEMR.37,ZLEMR.38,ZLEMR.39,ZLEMR.40,
ZLEMR.41,ZLEMR.42,ZLEMR.43,ZLEMR.44,ZLEMR.45,ZLEMR.46,ZLEMR.47,ZLEMR.48,ZLEMR.49,ZLEMR.50,ZLEMR.51,ZLEMR.53';
FUNCTION EMR_DATASET_CODE RETURN varchar2;
--CDR数据集中的检验报告编码
V_LIS_DATASET_CODE CONSTANT varchar2(4000) :='ZLEMR.07';
FUNCTION LIS_DATASET_CODE RETURN varchar2;
--CDR数据集中的检查报告编码
V_EXAMINE_DATASET_CODE CONSTANT varchar2(4000) :='ZLEMR.06';
FUNCTION EXAMINE_DATASET_CODE RETURN varchar2;
--住院医嘱数据集编码
V_INORDER_DATASET_CODE CONSTANT varchar2(50):='住院医嘱';
FUNCTION INORDER_DATASET_CODE RETURN varchar2;
--门诊医嘱数据集编码
V_OUTORDER_DATASET_CODE CONSTANT varchar2(50):='门（急）诊病历';
FUNCTION OUTORDER_DATASET_CODE RETURN varchar2;
--CDR数据集中的病历文档名称
V_EMR_DATASET_NAME CONSTANT varchar2(50):='病历概要';
FUNCTION EMR_DATASET_NAME RETURN varchar2;
--病人药品类医嘱
V_drug_Order CONSTANT varchar2(50):='药品类医嘱';
FUNCTION Drug_Order RETURN varchar2;
--病人除药品类医嘱、检验类医嘱、检查类医嘱之外的其他医嘱
V_other_Order CONSTANT varchar2(50):='药品类医嘱,检查类医嘱,检验类医嘱';
FUNCTION Other_Order RETURN varchar2;
end pkg_constant;

/


CREATE OR REPLACE package body pkg_constant as

--CDR数据集中的病历文档编码
FUNCTION EMR_DATASET_CODE RETURN varchar2 is
begin
	return V_EMR_DATASET_CODE;
end EMR_DATASET_CODE;
--CDR数据集中的检验报告编码
FUNCTION LIS_DATASET_CODE RETURN varchar2 is
begin
	return V_LIS_DATASET_CODE;
end LIS_DATASET_CODE;
--CDR数据集中的检查报告编码
FUNCTION EXAMINE_DATASET_CODE RETURN varchar2 is
begin
	return V_EXAMINE_DATASET_CODE;
end EXAMINE_DATASET_CODE;
--住院医嘱数据集编码
FUNCTION INORDER_DATASET_CODE RETURN varchar2 is
begin
	return V_INORDER_DATASET_CODE;
end INORDER_DATASET_CODE;
--门诊医嘱数据集编码
FUNCTION OUTORDER_DATASET_CODE RETURN varchar2 is
begin
	return V_OUTORDER_DATASET_CODE;
end OUTORDER_DATASET_CODE;
--CDR数据集中的病历文档名称
FUNCTION EMR_DATASET_NAME RETURN varchar2 is
begin
	return V_EMR_DATASET_NAME;
end EMR_DATASET_NAME;
--病人药品类医嘱
FUNCTION Drug_Order RETURN varchar2 is
begin
	return V_drug_Order;
end Drug_Order;
----病人除药品类医嘱、检验类医嘱、检查类医嘱之外的其他医嘱
FUNCTION Other_Order RETURN varchar2 is
begin
	return V_other_Order;
end Other_Order;

end pkg_constant;

/
