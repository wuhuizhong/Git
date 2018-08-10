--------------------------------------------------------
--  文件已创建 - 星期三-七月-18-2018   
--------------------------------------------------------
--------------------------------------------------------
--  DDL for View V_REVIEWE_SOLUTION_ITEM
--------------------------------------------------------

  CREATE OR REPLACE FORCE VIEW "ZLRECIPE"."V_REVIEWE_SOLUTION_ITEM" ("SOLUTION_ITEM", "ITEM_FIELD_NAME", "ITEM_TYPE", "ITEM_TABLE_NAME") AS 
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
