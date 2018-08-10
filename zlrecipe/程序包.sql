--------------------------------------------------------
--  �ļ��Ѵ��� - ���ڶ�-����-24-2018   
--------------------------------------------------------
--------------------------------------------------------
--  DDL for Procedure REVIEWE_SOLUTION_RUN
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "ZLRECIPE"."REVIEWE_SOLUTION_RUN" (
	ORDER_IDS_IN      IN CLOB
	,PID_IN            IN NUMBER
	,PVID_IN           IN NUMBER
	,REVIEWE_DATE_IN   IN VARCHAR2 := TO_CHAR(
		SYSDATE
		,'yyyymmdd'
	)
) IS
  --ͷע�Ϳ�ʼ-----------------------------------------------------------------------------------------
  --�������ƣ���˷�������
  --����˵����ͨ����˷�������,ѡ����Ҫ��˵Ĵ���������󴦷����������Զ�ͨ��
  --���˵����order_ids_in:�������ҽ��id,reviewe_date ������ڣ�ȱʡΪ���죬���ڿ�������ʱ���ӻ�ȡҽ�������л������
  --����˵����
  --�� д �ߣ��޺�
  --��дʱ�䣺2018-06-08
  --�汾��¼���汾��+ʱ��+�޸���+�޸���������
  --ͷע�ͽ���-----------------------------------------------------------------------------------------
	V_CND                 CLOB;
	V_QUOTE               VARCHAR2(1);--������
	V_REVIEWE_DATE        VARCHAR2(8);--��������
	V_SOLUTION_CND        CLOB;
	V_SQL                 CLOB;
	V_SOLUTION_TMP_CND    VARCHAR2(4000);--һ��������������
	D_START               TIMESTAMP;--��ʼ����ʱ��
	D_FINISH              TIMESTAMP;--��������ʱ��
	N_REVIEWE_RECORDS     NUMBER(18);--��Ҫ��˵�ҽ����¼��
	N_NOREVIEWE_RECORDS   NUMBER(18);--����Ҫ��˵�ҽ����¼��
	V_ORDER_IDS_IN        CLOB;
  --�жϹ�����ر���
  /*v_�Զ�ʱ���� RECIPE_REVIEWE_PARA.PARA_VALUE%type;*/
	N_�Ƿ��ϸ�                NUMBER(18);
	V_�����ϰ�ʱ��              REVIEWE_RECIPES.RECIPE_TIME%TYPE;
	V_�����°�ʱ��              REVIEWE_RECIPES.RECIPE_TIME%TYPE;
	V_�����ϰ�ʱ��              REVIEWE_RECIPES.RECIPE_TIME%TYPE;
	V_�����°�ʱ��              REVIEWE_RECIPES.RECIPE_TIME%TYPE;
	V_���״̬                NUMBER;
	V_�������״̬              NUMBER;
	N_�Ƿ�����                NUMBER(18);
	N_PID                 NUMBER(18);
	N_PVID                NUMBER(18);
	N_PATIENT_TYPE        NUMBER(18);
	
--��Ӧ"����"��������ѡ�ǣ����Ϊ����������ʽ instr(�ֶ�,'����ֵ1')>0	or instr(�ֶ�,'����ֵ2')>0	
	FUNCTION GET_HAS_CND (
		FIELD_NAME_IN   IN VARCHAR2
		,ITEM_VALUE_IN   IN VARCHAR2
	) RETURN VARCHAR2 IS
		V_CND               VARCHAR2(30000);
		V_QUOTE             VARCHAR2(10);
		V_TEMP_ITEM_VALUE   VARCHAR2(30000);
		V_TEMP              VARCHAR2(4000);
		V_DELIMITER         VARCHAR2(1);
	BEGIN
		V_QUOTE             := CHR(39);
		V_DELIMITER         := ':'; --����ֵ֮����:�ָ�
		V_TEMP_ITEM_VALUE   := ITEM_VALUE_IN;
		IF INSTR(
				ITEM_VALUE_IN
				,V_DELIMITER
			) > 0 THEN
			FOR I IN ( SELECT REGEXP_SUBSTR(
				ITEM_VALUE_IN
				,'[^' || V_DELIMITER || ']+'
				,1
				,ROWNUM
			) ITEM_VALUE
			             FROM DUAL CONNECT BY
				ROWNUM <= LENGTH(
					REGEXP_SUBSTR(
						ITEM_VALUE_IN
						,'[^' || V_DELIMITER || ']+'
						,1
						,ROWNUM
					)
				)
			) LOOP
				IF V_CND IS NULL THEN
					V_CND   := ' instr(' || FIELD_NAME_IN || ',' || V_QUOTE || I.ITEM_VALUE || V_QUOTE || ') > 0';
				ELSE
					V_CND   := V_CND || ' OR ' || ' instr(' || FIELD_NAME_IN || ',' || V_QUOTE || I.ITEM_VALUE || V_QUOTE || ') > 0';
				END IF;
			END LOOP;
		ELSE
			V_CND   := ' instr(' || FIELD_NAME_IN || ',' || V_QUOTE || ITEM_VALUE_IN || V_QUOTE || ') > 0';
		END IF;
		RETURN V_CND;
	END GET_HAS_CND;
BEGIN
	V_���״̬                := 0;
	N_PID                 := PID_IN;
	N_PVID                := PVID_IN;
	D_START               := SYSDATE;
	N_REVIEWE_RECORDS     := 0;
	N_NOREVIEWE_RECORDS   := 0;
	V_QUOTE               := CHR(39);
	V_REVIEWE_DATE        := REVIEWE_DATE_IN;
	V_ORDER_IDS_IN        := ',' || ORDER_IDS_IN || ',';
	SELECT MAX(P_TYPE)
	  INTO N_PATIENT_TYPE
	  FROM RECIPE_PATIENT_INFO
	 WHERE PID = PID_IN
	   AND PVID = PVID_IN;
   /*select a.para_value into v_�Զ�ʱ���� from  RECIPE_REVIEWE_PARA a where a.para_name='��ʱ�Զ�ͨ�����ʱ��';*/
   -- select sysdate into v_��ʼʱ�� from dual;
   --�ó������ϰ��ڼ�
	SELECT TO_DATE(
		TO_CHAR(
			SYSDATE
			,'yyyy-mm-dd'
		) || ' ' || NVL(
			A.PARA_VALUE
			,'8:30'
		)
		,'yyyy-mm-dd hh24:mi:ss'
	)
	  INTO V_�����ϰ�ʱ��
	  FROM RECIPE_REVIEWE_PARA A
	 WHERE A.PARA_NAME = '�����ϰ�ʱ��';
   --�ó������°��ڼ�
	SELECT TO_DATE(
		TO_CHAR(
			SYSDATE
			,'yyyy-mm-dd'
		) || ' ' || NVL(
			A.PARA_VALUE
			,'11:45'
		)
		,'yyyy-mm-dd hh24:mi:ss'
	)
	  INTO V_�����°�ʱ��
	  FROM RECIPE_REVIEWE_PARA A
	 WHERE A.PARA_NAME = '�����°�ʱ��';
   --�ó������ϰ��ڼ�
	SELECT TO_DATE(
		TO_CHAR(
			SYSDATE
			,'yyyy-mm-dd'
		) || ' ' || NVL(
			A.PARA_VALUE
			,'14:00'
		)
		,'yyyy-mm-dd hh24:mi:ss'
	)
	  INTO V_�����ϰ�ʱ��
	  FROM RECIPE_REVIEWE_PARA A
	 WHERE A.PARA_NAME = '�����ϰ�ʱ��';
   --�ó������°��ڼ�
	SELECT TO_DATE(
		TO_CHAR(
			SYSDATE
			,'yyyy-mm-dd'
		) || ' ' || NVL(
			A.PARA_VALUE
			,'17:45'
		)
		,'yyyy-mm-dd hh24:mi:ss'
	)
	  INTO V_�����°�ʱ��
	  FROM RECIPE_REVIEWE_PARA A
	 WHERE A.PARA_NAME = '�����°�ʱ��';

   
   --�Ƿ������ڸ�
	SELECT COUNT(1)
	  INTO N_�Ƿ��ϸ�
	  FROM PHARMACIST_WORK_RECORD A
	 WHERE A.REGISTER_DATE = TO_CHAR(
		SYSDATE
		,'yyyymmdd'
	)
	   AND A.UNREGISTER_TIME IS NULL;
   
   -- �õ����˾������id ͨ������pid,pvid 
	SELECT COUNT(*)
	  INTO N_�Ƿ�����
	  FROM RECIPE_PATIENT_INFO A
	      ,REVIEWE_DEPT B
	 WHERE A.P_DEPT_ID = B.DEPT_ID
	   AND B.DEPT_STATUS = 1
	   AND A.PID = N_PID
	   AND A.PVID = N_PVID; 
   
 -- ���ж��Ƿ���Ҫ�����󷽹����жϣ��磬δ�ϰࡢδ�ϸ��ڼ� ֱ��ͨ������������󷽹����ж�
      -- �жϹ��� ���״̬ 
	IF ( SYSDATE > V_�����ϰ�ʱ��    AND SYSDATE < V_�����°�ʱ�� )     OR ( SYSDATE > V_�����ϰ�ʱ��    AND SYSDATE < V_�����°�ʱ�� ) THEN
          --���ϰ��ڼ�
		IF N_�Ƿ��ϸ� > 0 THEN
               -- v_�Ƿ��ϸ�=1 ���ϸ� �����״̬=-2 ���մ���
			IF N_�Ƿ����� > 0 THEN
                --���ϰ࣬�ϸڲ��������ÿ��� ������󷽹���
          
       -- ����ҽ�� ���״̬=20,�ȴ������ҽ����״̬
				UPDATE REVIEWE_RECIPES A
				   SET
					A.REVIEWE_RESULT = 20
				 WHERE A.EMERGENCY = 1
				   AND A.PID = PID_IN
				   AND A.PVID = PVID_IN;     
             
    --ѭ�������������÷���
				FOR S IN ( SELECT A.REVIEWE_SOLUTION_ID
				                 ,A.REVIEWE_SOLUTION_NAME
				             FROM REVIEWE_SOLUTION A
				            WHERE A.REVIEWE_SOLUTION_STATUS = 1
				   AND REVIEWE_SOLUTION_TYPE = N_PATIENT_TYPE
				) LOOP
        --���һ������������
					FOR D IN ( SELECT C.SOLUTION_ITEM
					                 ,C.ITEM_EXPRESSION
					                 ,C.ITEM_VALUE
					                 ,C.ITEM_TYPE
					                 ,C.ITEM_TABLE_NAME || '.' || C.ITEM_FIELD_NAME FIELD_NAME
					             FROM REVIEWE_SOLUTION_DETAIL C
					            WHERE C.REVIEWE_SOLUTION_ID = S.REVIEWE_SOLUTION_ID
					) LOOP
						CASE
							WHEN D.ITEM_VALUE IS NULL THEN
								V_SOLUTION_TMP_CND   := D.FIELD_NAME || ' is null';
							WHEN D.ITEM_EXPRESSION = '������' THEN
								V_SOLUTION_TMP_CND   := '  instr(' || V_QUOTE || D.ITEM_VALUE || V_QUOTE || ',' || D.FIELD_NAME || ') > 0';
							WHEN D.ITEM_EXPRESSION = '����' THEN
								--V_SOLUTION_TMP_CND   := '  instr(' || D.FIELD_NAME || ',' || V_QUOTE || D.ITEM_VALUE || V_QUOTE || ') > 0';
								V_SOLUTION_TMP_CND   := GET_HAS_CND(
									D.FIELD_NAME
									,D.ITEM_VALUE
								);
							ELSE
								V_SOLUTION_TMP_CND   := D.FIELD_NAME || D.ITEM_EXPRESSION || D.ITEM_VALUE;
						END CASE;
						IF V_SOLUTION_CND IS NULL THEN
							V_SOLUTION_CND   := V_SOLUTION_TMP_CND;
						ELSE
							V_SOLUTION_CND   := V_SOLUTION_CND || ' and ' || V_SOLUTION_TMP_CND;
						END IF;
					END LOOP;
					IF V_CND IS NULL THEN
						V_CND   := V_SOLUTION_CND;
					ELSE
						V_CND   := V_CND || ' or ' || '(' || V_SOLUTION_CND || ')';
					END IF;
					V_SOLUTION_CND   := '';
				END LOOP;
				V_CND                 := '(' || V_CND || ') and
               reviewe_recipes.reviewe_result=-2 and reviewe_recipes.Receive_Date = ' || V_QUOTE || V_REVIEWE_DATE || V_QUOTE;
			   
	  --��ɾ�������ҽ��
				V_SQL                 := 'Delete wait_reviewe_recipe where instr(' || V_QUOTE || V_ORDER_IDS_IN || V_QUOTE || ',' || V_QUOTE || ',' || V_QUOTE || '||wait_reviewe_recipe.order_id || ' || V_QUOTE || ',' || V_QUOTE || ') > 0';
				EXECUTE IMMEDIATE V_SQL;
				--Dbms_Output.Put_Line(V_SQL);
      --��Ҫ��˵�ҽ����������ҽ����                          
				V_SQL                 := 'insert into wait_reviewe_recipe (order_id,
                                     receive_time,
                                     receive_date,
                                     reviewe_normal_time,
                                     pvid,
                                     pid,
                                     p_dept_id,
                                     pharmacist,
                                     pharmacist_id,
                                     pharmacist_receive_time)
    select reviewe_recipes.order_id,
           reviewe_recipes.receive_time,
           reviewe_recipes.Receive_Date,
           reviewe_recipes.reviewe_normal_time,
           reviewe_recipes.pvid,
           reviewe_recipes.pid,
           recipe_patient_info.p_dept_id,
           reviewe_recipes.pharmacist,
           reviewe_recipes.pharmacist_id,
           reviewe_recipes.pharmacist_receive_time
      from reviewe_recipes, recipe_patient_info
     where reviewe_recipes.pid = recipe_patient_info.pid
       and recipe_patient_info.pvid = reviewe_recipes.pvid
       and '
|| V_CND || ' and instr(' || V_QUOTE || V_ORDER_IDS_IN || V_QUOTE || ',' || V_QUOTE || ',' || V_QUOTE || '||reviewe_recipes.order_id || ' || V_QUOTE || ',' || V_QUOTE || ') > 0 and reviewe_recipes.recipe_date=' || V_QUOTE || V_REVIEWE_DATE || V_QUOTE || ' --��������ҽ��';
				EXECUTE IMMEDIATE V_SQL;
			--Dbms_Output.Put_Line(V_SQL);
      --���´����ҽ��Ϊ�����״̬                          
				V_SQL                 := ' update reviewe_recipes set reviewe_result=0 where order_id in (select order_id from  reviewe_recipes, recipe_patient_info
     where reviewe_recipes.pid = recipe_patient_info.pid
       and recipe_patient_info.pvid = reviewe_recipes.pvid
       and '
|| V_CND || '
       and instr(' || V_QUOTE || V_ORDER_IDS_IN || V_QUOTE || ',' || V_QUOTE || ',' || V_QUOTE || '||reviewe_recipes.order_id || ' || V_QUOTE || ',' || V_QUOTE || ') > 0 and reviewe_recipes.Receive_Date=' || V_QUOTE || V_REVIEWE_DATE || V_QUOTE || ')
	   and reviewe_recipes.reviewe_result = -2 ';
				EXECUTE IMMEDIATE V_SQL;
				--Dbms_Output.Put_Line(V_SQL);
				N_REVIEWE_RECORDS     := SQL%ROWCOUNT;
      --����ĸ���Ϊ�������
				V_SQL                 := ' update reviewe_recipes set reviewe_result=20,reviewe_time=sysdate where reviewe_recipes.reviewe_result = -2 and instr(' || V_QUOTE || V_ORDER_IDS_IN || V_QUOTE || ',' || V_QUOTE || ',' || V_QUOTE || '||reviewe_recipes.order_id || ' || V_QUOTE || ',' || V_QUOTE || ') > 0 and reviewe_recipes.Receive_Date='
|| V_QUOTE || V_REVIEWE_DATE || V_QUOTE || ' --����ҽ������Ϊ�������';
				EXECUTE IMMEDIATE V_SQL;
				N_NOREVIEWE_RECORDS   := SQL%ROWCOUNT;
			ELSE
			--���˿���δ������
				V_���״̬   := 20;
			END IF;
		ELSE
               --�ϰ��ڼ䣬δ�ϸ� 
			V_���״̬   := 21;
		END IF;
	ELSE
         -- ���ϰ��ڼ䣬
		V_���״̬   := 23;
	END IF;
	IF V_���״̬ > 0 THEN
		UPDATE REVIEWE_RECIPES A
		   SET
			A.REVIEWE_RESULT = V_���״̬
  -- ,A.reviewe_time = SYSDATE
		 WHERE INSTR(
			V_ORDER_IDS_IN
			,',' || A.ORDER_ID || ','
		) > 0
		   AND A.PID = N_PID
		   AND A.PVID = N_PVID
		   AND A.REVIEWE_RESULT =-2;
	END IF;
  --����ZLHIS���񣬸���ҽ��ͨ��״̬
	D_FINISH              := SYSDATE;
EXCEPTION
	WHEN OTHERS THEN
		PKG_RECIPE_REVIEWE.INSERT_LOG(
			LOG_TITILE_IN    => 'ִ���󷽷���������'
			,LOG_TYPE_IN      => 'E'
			,LOG_CONTENT_IN   => '��ʼʱ��:' || D_START || ',��ȡ����ʱ��:' || SYSDATE || CHR(10) || '�������:' || CHR(10) || 'ִ�����' || V_SQL || CHR(10) || SQLCODE || CHR(10) || '������Ϣ��' || SQLERRM
		);
END REVIEWE_SOLUTION_RUN;

/
