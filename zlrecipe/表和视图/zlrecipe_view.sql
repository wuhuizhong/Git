--------------------------------------------------------
--  �ļ��Ѵ��� - ������-����-18-2018   
--------------------------------------------------------
--------------------------------------------------------
--  DDL for View V_REVIEWE_SOLUTION_ITEM
--------------------------------------------------------

  CREATE OR REPLACE FORCE VIEW "ZLRECIPE"."V_REVIEWE_SOLUTION_ITEM" ("SOLUTION_ITEM", "ITEM_FIELD_NAME", "ITEM_TYPE", "ITEM_TABLE_NAME") AS 
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
