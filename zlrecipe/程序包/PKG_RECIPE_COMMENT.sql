CREATE OR REPLACE PACKAGE PKG_RECIPE_COMMENT AS

  /* TODO enter package declarations (types, exceptions, methods etc) here */
	PROCEDURE EXTRACT_RECIPE (
		EXTRACT_MONTH_IN     IN VARCHAR2
		,PATIEN_TYPE_IN       IN NUMBER
		,RECIPE_TYPE_IN       IN NUMBER
		,SURGERY_TYPE_IN      IN NUMBER
		,RECIPES_NUMBER_IN    IN NUMBER
		,EXTRACT_TYPE_IN      IN NUMBER := 0
		,PHARMACIST_IN        IN VARCHAR2
		,PHARMACIST_ID_IN     IN VARCHAR2
		,EXTRACT_DEPT_ID_IN   IN VARCHAR2
		,EXTRACT_DR_ID_IN     IN VARCHAR2
		,EXTRACT_DRUG_ID_IN   NUMBER
		,EXTRACT_ID_OUT       OUT NUMBER
	);
  --סԺ���˴�����ȡ
	PROCEDURE INPATIENT_EXTRACT (
		EXTRACT_MONTH_IN    IN VARCHAR2
		,RECIPE_TYPE_IN      IN NUMBER
		,SURGERY_TYPE_IN     IN NUMBER
		,RECIPES_NUMBER_IN   IN NUMBER
		,EXTRACT_TYPE_IN     IN NUMBER := 0
		,PHARMACIST_IN       IN VARCHAR2
		,PHARMACIST_ID_IN    IN VARCHAR2
				,extract_dept_id_in in varchar2
		,extract_dr_id_in in varchar2
		,extract_drug_id_in number
		,EXTRACT_ID_OUT      OUT NUMBER
	);
  --���ﲡ�˴�����ȡ
	PROCEDURE OUTPATIENT_EXTRACT (
		EXTRACT_MONTH_IN    IN VARCHAR2
		,RECIPE_TYPE_IN      IN NUMBER
		,SURGERY_TYPE_IN     IN NUMBER
		,RECIPES_NUMBER_IN   IN NUMBER
		,EXTRACT_TYPE_IN     IN NUMBER := 0
		,PHARMACIST_IN       IN VARCHAR2
		,PHARMACIST_ID_IN    IN VARCHAR2
				,extract_dept_id_in in varchar2
		,extract_dr_id_in in varchar2
		,extract_drug_id_in number
		,EXTRACT_ID_OUT      OUT NUMBER
	);
  
    --��ɵ���
	PROCEDURE FINISH_COMMENT_RECIPE (
		EXTRACT_ID_IN IN NUMBER
	);
  
	  --�Զ�����
	PROCEDURE AUTO_COMMENT_RECIPE (
		EXTRACT_ID_IN IN NUMBER
	);
 --�˹�����
	PROCEDURE MANUAL_COMMENT_RESULT (
		C_INPUT IN CLOB
	);
	PROCEDURE INSERT_COMMENT_RESULT (
		RECIPE_NO_IN           IN VARCHAR2
		,COMMENT_ITEM_CODE_IN   IN VARCHAR2
		,ORDER_ID_IN            IN NUMBER
		,ITEM_CONTENT_IN        IN VARCHAR2
	);
	PROCEDURE UPD_COMMENT_RESULT (
		RECIPE_NO_IN           IN VARCHAR2
		,COMMENT_ITEM_CODE_IN   IN VARCHAR2
		,ORDER_ID_IN            IN NUMBER
		,ITEM_CONTENT_IN        IN VARCHAR2
	);
	--ɾ���������
	PROCEDURE DEL_COMMENT_RESULT (
		RECIPE_NO_IN           IN VARCHAR2
		,COMMENT_ITEM_CODE_IN   IN VARCHAR2
		,ORDER_ID_IN            IN NUMBER
	);
--ɾ��������ȡ	
 procedure del_ectract(extract_id_in number);	
END PKG_RECIPE_COMMENT;

/


CREATE OR REPLACE PACKAGE BODY PKG_RECIPE_COMMENT IS
 --��ȡ��������
	PROCEDURE EXTRACT_RECIPE (
		EXTRACT_MONTH_IN     IN VARCHAR2
		,PATIEN_TYPE_IN       IN NUMBER
		,RECIPE_TYPE_IN       IN NUMBER
		,SURGERY_TYPE_IN      IN NUMBER
		,RECIPES_NUMBER_IN    IN NUMBER
		,EXTRACT_TYPE_IN      IN NUMBER := 0
		,PHARMACIST_IN        IN VARCHAR2
		,PHARMACIST_ID_IN     IN VARCHAR2
		,EXTRACT_DEPT_ID_IN   IN VARCHAR2
		,EXTRACT_DR_ID_IN     IN VARCHAR2
		,EXTRACT_DRUG_ID_IN   NUMBER
		,EXTRACT_ID_OUT       OUT NUMBER
	)
		AS
  --ͷע�Ϳ�ʼ-----------------------------------------------------------------------------------------
  --�������ƣ���ȡ��������
  --����˵�������ݽ�������ò���������һ�ε���������ȡ
  --���˵����
  ----EXTRACT_MONTH ��ȡ�·�;
  ----PATIEN_TYPE ��������,1-���2-סԺ
  ----RECIPE_TYPE ����ҩ������;0-���д���,1-Ԥ���ÿ���ҩ�ﴦ��,2-�����ÿ���ҩ�ﴦ��
  ----SURGERY_TYPE_IN 0-���в���,1-��������
  ----RECIPES_NUMBER_in ��ȡ��������
  ----EXTRACT_TYPE ��ȡ����,0-���
  ----PHARMACIST_IN ����ҩʦ����
  ----PHARMACIST_ID_IN ������ҩ�û�ID
  ----EXTRACT_DEPT_ID_IN ��������ID
  ----EXTRACT_DR_ID_IN ����ҽʦID
  ----EXTRACT_DRUG_ID_IN ����ҩƷID
  --����˵����extract_id ���γ�ȡID
  --�� д �ߣ��޺�
  --��дʱ�䣺2018-06-21
  --�汾��¼���汾��+ʱ��+�޸���+�޸���������
  --ͷע�ͽ���----------------------------------------------------------------------------------------- 
	BEGIN
		IF PATIEN_TYPE_IN = 2 THEN
			INPATIENT_EXTRACT(
				EXTRACT_MONTH_IN     => EXTRACT_MONTH_IN
				,RECIPE_TYPE_IN       => RECIPE_TYPE_IN
				,SURGERY_TYPE_IN      => SURGERY_TYPE_IN
				,RECIPES_NUMBER_IN    => RECIPES_NUMBER_IN
				,EXTRACT_TYPE_IN      => EXTRACT_TYPE_IN
				,PHARMACIST_IN        => PHARMACIST_IN
				,PHARMACIST_ID_IN     => PHARMACIST_ID_IN
				,EXTRACT_DEPT_ID_IN   => EXTRACT_DEPT_ID_IN
				,EXTRACT_DR_ID_IN     => EXTRACT_DR_ID_IN
				,EXTRACT_DRUG_ID_IN   => EXTRACT_DRUG_ID_IN
				,EXTRACT_ID_OUT       => EXTRACT_ID_OUT
			);
		ELSE
			OUTPATIENT_EXTRACT(
				EXTRACT_MONTH_IN     => EXTRACT_MONTH_IN
				,RECIPE_TYPE_IN       => RECIPE_TYPE_IN
				,SURGERY_TYPE_IN      => SURGERY_TYPE_IN
				,RECIPES_NUMBER_IN    => RECIPES_NUMBER_IN
				,EXTRACT_TYPE_IN      => EXTRACT_TYPE_IN
				,PHARMACIST_IN        => PHARMACIST_IN
				,PHARMACIST_ID_IN     => PHARMACIST_ID_IN
				,EXTRACT_DEPT_ID_IN   => EXTRACT_DEPT_ID_IN
				,EXTRACT_DR_ID_IN     => EXTRACT_DR_ID_IN
				,EXTRACT_DRUG_ID_IN   => EXTRACT_DRUG_ID_IN
				,EXTRACT_ID_OUT       => EXTRACT_ID_OUT
			);
		END IF;
	END EXTRACT_RECIPE;

  --סԺ���˴�����ȡ
	PROCEDURE INPATIENT_EXTRACT (
		EXTRACT_MONTH_IN     IN VARCHAR2
		,RECIPE_TYPE_IN       IN NUMBER
		,SURGERY_TYPE_IN      IN NUMBER
		,RECIPES_NUMBER_IN    IN NUMBER
		,EXTRACT_TYPE_IN      IN NUMBER := 0
		,PHARMACIST_IN        IN VARCHAR2
		,PHARMACIST_ID_IN     IN VARCHAR2
		,EXTRACT_DEPT_ID_IN   IN VARCHAR2
		,EXTRACT_DR_ID_IN     IN VARCHAR2
		,EXTRACT_DRUG_ID_IN   NUMBER
		,EXTRACT_ID_OUT       OUT NUMBER
--ͷע�Ϳ�ʼ-----------------------------------------------------------------------------------------
--�������ƣ���ȡסԺ��������
--����˵������ȡסԺ��������
--���˵����
----EXTRACT_MONTH ��ȡ�·�;
----PATIEN_TYPE ��������,1-���2-סԺ
----RECIPE_TYPE ����ҩ������;0-���д���,1-Ԥ���ÿ���ҩ�ﴦ��,2-�����ÿ���ҩ�ﴦ��
----SURGERY_TYPE_IN 0-���в���,1-��������
----RECIPES_NUMBER_in ��ȡ��������
----EXTRACT_TYPE ��ȡ����,0-���
----PHARMACIST_IN ����ҩʦ����
----PHARMACIST_ID_IN ������ҩ�û�ID
--����˵����extract_id ���γ�ȡID
--�� д �ߣ��޺�
--��дʱ�䣺2018-06-21
--�汾��¼���汾��+ʱ��+�޸���+�޸���������
--ͷע�ͽ���----------------------------------------------------------------------------------------- 
	) AS
		BEGIN_TIME    DATE; --��ȡҽ����ʼʱ��
		FINISH_TIME   DATE; --��ȡҽ������ʱ��
		V_DEPT_NAME   VARCHAR2(500);
		V_DR_NAME     VARCHAR2(500);
		V_DRUG_NAME   VARCHAR2(500);
	BEGIN
		SELECT MAX(����)
		  INTO V_DEPT_NAME
		  FROM ���ű�@TO_ZLHIS
		 WHERE ID = EXTRACT_DEPT_ID_IN;
		SELECT MAX(����)
		  INTO V_DR_NAME
		  FROM ��Ա��@TO_ZLHIS
		 WHERE ���� = EXTRACT_DR_ID_IN;
		SELECT MAX(����)
		  INTO V_DRUG_NAME
		  FROM �շ���ĿĿ¼@TO_ZLHIS
		 WHERE ID = EXTRACT_DRUG_ID_IN;
		EXTRACT_ID_OUT   := ZLRECIPE.COMMENT_EXTRACT_EXTRACT_ID_SEQ.NEXTVAL;
  --��ʼʱ���ǳ�ȡ�µ�1��0��
		BEGIN_TIME       := TO_DATE(
			EXTRACT_MONTH_IN || '01 00:00:00'
			,'yyyymmdd hh24:mi:ss'
		);
  --����ʱ������1��0���1��
		FINISH_TIME      := ADD_MONTHS(
			BEGIN_TIME
			,1
		) - 1 / 24 / 60 / 60;
  --�Ȳ�����ȡ��¼
		INSERT   INTO COMMENT_EXTRACT (
			EXTRACT_ID
			,EXTRACT_TIME
			,PHARMACIST
			,PHARMACIST_ID
			,EXTRACT_MONTH
			,PATIENT_TYPE
			,SURGERY
			,RECIPE_TYPE
			,EXTRACT_TYPE
			,RECIPES_NUMBER
			,EXTRACT_DEPT_ID
			,EXTRACT_DEPT_NAME
			,EXTRACT_DR_ID
			,EXTRACT_DR_NAME
			,EXTRACT_DRUG_ID
			,EXTRACT_DRUG_NAME
		) VALUES (
			EXTRACT_ID_OUT
			,SYSDATE
			,PHARMACIST_IN
			,PHARMACIST_ID_IN
			,EXTRACT_MONTH_IN
			,2
			,SURGERY_TYPE_IN
			,RECIPE_TYPE_IN
			,EXTRACT_TYPE_IN
			,RECIPES_NUMBER_IN
			,EXTRACT_DEPT_ID_IN
			,V_DEPT_NAME
			,EXTRACT_DR_ID_IN
			,V_DR_NAME
			,EXTRACT_DRUG_ID_IN
			,V_DRUG_NAME
		);
		INSERT   INTO COMMENT_RECIPES (
			EXTRACT_ID
			,RECIPE_NO
			,PID
			,PVID
			,RECIPE_DR
			,RECIPE_DR_TITLE
			,DR_ANTI_LEVEL
			,HIS_NO
			,PATIENT_AGE
			,BASE_DRUG_NUMBER
			,RECIPE_AMOUNT
			,RECIPE_DIAG
			,PATIENT_BIRTHDAY
			,RECIPE_DATE
		)
			SELECT EXTRACT_ID_OUT
			      ,RECIPE_NO
			      ,PID
			      ,PVID
			      ,RECIPE_DR
			      ,RECIPE_DR_TITLE
			      ,DR_ANTI_LEVEL
			      ,100
			      ,PATIENT_AGE
			      , ( SELECT SUM(DECODE(
				H.����ҩ��
				,'��ҩ'
				,1
				,'���һ�ҩ'
				,1
				,0
			) )
			             FROM ����ҽ����¼@TO_ZLHIS A
			                 ,ҩƷ���@TO_ZLHIS H
			            WHERE H.ҩ��ID = A.������ĿID
			   AND A.����ID = PID
			   AND A.��ҳID = PVID
			) BASE_DRUG_NUMBER
			      , ( SELECT TRUNC(
				SUM(B.ʵ�ս��)
			)
			             FROM סԺ���ü�¼@TO_ZLHIS B
			            WHERE B.��¼״̬ <> 0
			   AND B.����ID = PID
			   AND B.��ҳID = PVID
			            GROUP BY B.����ID
			                    ,B.��ҳID
			) RECIPE_AMOUNT
			      , ( SELECT
				LISTAGG(C.�������
				,'|') WITHIN  GROUP(
					 ORDER BY ''
				)
			             FROM ������ϼ�¼@TO_ZLHIS C
			            WHERE C.��¼��Դ = 3
			   AND ��ϴ��� = 1
			   AND C.������� IN (
				3
				,13
			)
			   AND C.����ID = PID
			   AND C.��ҳID = PVID
			) RECIPE_DIAG
			      ,PATIENT_BIRTHDAY
			      ,RECIPE_DATE
			  FROM ( SELECT RECIPE_NO
			               ,PID
			               ,PVID
			               ,RECIPE_DR
			               ,RECIPE_DR_TITLE
			               ,DR_ANTI_LEVEL
			               ,RECIPES_NUMBER_IN ��PATIENT_AGE
			               ,PATIENT_BIRTHDAY
			               ,RECIPE_DATE
			           FROM ( SELECT A.����ID PID
			                        ,A.��ҳID PVID
			                        ,A.���� PATIENT_AGE
			                        ,A.����ID || '-' || A.��ҳID RECIPE_NO
			                        ,A.סԺҽʦ RECIPE_DR
			                        ,D.רҵ����ְ�� RECIPE_DR_TITLE
			                        ,E.���� DR_ANTI_LEVEL
			                        ,F.�������� PATIENT_BIRTHDAY
			                        ,A.��Ժ���� RECIPE_DATE
			                    FROM ������ҳ@TO_ZLHIS A
			                        ,��Ա��@TO_ZLHIS D
			                        ,��Ա����ҩ��Ȩ��@TO_ZLHIS E
			                        ,������Ϣ@TO_ZLHIS F
			                   WHERE A.סԺҽʦ = D.����
			   AND F.����ID = A.����ID
			   AND D.ID = E.��ԱID (+)
			   AND E.���� (+) = 1
			   AND E.��¼״̬ (+) = 1
			   AND A.��Ժ���� BETWEEN BEGIN_TIME    AND FINISH_TIME
			   AND (
				EXISTS ( SELECT 1
				           FROM ����ҽ����¼@TO_ZLHIS BB
				          WHERE BB.����ID = A.����ID
				   AND BB.��ҳID = A.��ҳID
				   AND BB.�շ�ϸĿID = EXTRACT_DRUG_ID_IN
				)
				    OR NVL(
					EXTRACT_DRUG_ID_IN
					,0
				) = 0
			)
			   AND (
				A.סԺҽʦ = EXTRACT_DR_ID_IN
				    OR EXTRACT_DR_ID_IN IS NULL
			)
			   AND (
				A.��Ժ����ID = EXTRACT_DEPT_ID_IN
				    OR ( NVL(
					EXTRACT_DEPT_ID_IN
					,0
				) = 0 )
			)
			   AND (
				RECIPE_TYPE_IN = 0
				    OR ( EXISTS ( SELECT 1
				                    FROM ����ҽ����¼@TO_ZLHIS AA
				                   WHERE AA.����ID = A.����ID
				   AND AA.��ҳID = A.��ҳID
				   AND (
					(
						AA.��ҩĿ�� = 1
						   AND RECIPE_TYPE_IN = 1
					)
					    OR (
						AA.��ҩĿ�� = 2
						   AND RECIPE_TYPE_IN = 2
					)
				)
				) )
			)
			   AND NOT EXISTS ( SELECT 1
			                      FROM COMMENT_RECIPES F
			                     WHERE F.RECIPE_NO = A.����ID || '-' || A.��ҳID
			)
			 ORDER BY DBMS_RANDOM.VALUE )
			          WHERE ROWNUM <= RECIPES_NUMBER_IN
			);
		IF SQL%ROWCOUNT = 0 THEN  --û�г�ȡ������
			DELETE COMMENT_EXTRACT
			 WHERE EXTRACT_ID = EXTRACT_ID_OUT;
			EXTRACT_ID_OUT   := NULL;
			--RAISE_APPLICATION_ERROR(-20001, 'û�г�ȡ�����������Ĵ���');
		END IF;
	END INPATIENT_EXTRACT;
  
  --���ﲡ�˴�����ȡ
	PROCEDURE OUTPATIENT_EXTRACT (
		EXTRACT_MONTH_IN     IN VARCHAR2
		,RECIPE_TYPE_IN       IN NUMBER
		,SURGERY_TYPE_IN      IN NUMBER
		,RECIPES_NUMBER_IN    IN NUMBER
		,EXTRACT_TYPE_IN      IN NUMBER := 0
		,PHARMACIST_IN        IN VARCHAR2
		,PHARMACIST_ID_IN     IN VARCHAR2
		,EXTRACT_DEPT_ID_IN   IN VARCHAR2
		,EXTRACT_DR_ID_IN     IN VARCHAR2
		,EXTRACT_DRUG_ID_IN   NUMBER
		,EXTRACT_ID_OUT       OUT NUMBER
--ͷע�Ϳ�ʼ-----------------------------------------------------------------------------------------
--�������ƣ���ȡ�����������
--����˵������ȡ��סԺ������
--���˵����
----EXTRACT_MONTH ��ȡ�·�;
----PATIEN_TYPE ��������,1-���2-סԺ
----RECIPE_TYPE ����ҩ������;0-���д���,1-Ԥ���ÿ���ҩ�ﴦ��,2-�����ÿ���ҩ�ﴦ��  
----SURGERY_TYPE_IN 0-���в���,1-��������
----RECIPES_NUMBER_in ��ȡ��������
----EXTRACT_TYPE ��ȡ����,0-���
----PHARMACIST_IN ����ҩʦ����
----PHARMACIST_ID_IN ������ҩ�û�ID
--����˵����extract_id ���γ�ȡID
--�� д �ߣ��޺�
--��дʱ�䣺2018-06-21
--�汾��¼���汾��+ʱ��+�޸���+�޸���������
--ͷע�ͽ���-----------------------------------------------------------------------------------------
	) AS
		BEGIN_TIME    DATE; --��ȡҽ����ʼʱ��
		FINISH_TIME   DATE; --��ȡҽ������ʱ��
		V_DEPT_NAME   VARCHAR2(500);
		V_DR_NAME     VARCHAR2(500);
		V_DRUG_NAME   VARCHAR2(500);
	BEGIN
		PKG_RECIPE_REVIEWE.INSERT_LOG(
			LOG_TITILE_IN    => '����'
			,LOG_TYPE_IN      => 'T'
			,LOG_CONTENT_IN   => EXTRACT_DRUG_ID_IN || '--'
		);
		SELECT MAX(����)
		  INTO V_DEPT_NAME
		  FROM ���ű�@TO_ZLHIS
		 WHERE ID = EXTRACT_DEPT_ID_IN;
		SELECT MAX(����)
		  INTO V_DR_NAME
		  FROM ��Ա��@TO_ZLHIS
		 WHERE ���� = EXTRACT_DR_ID_IN;
		SELECT MAX(����)
		  INTO V_DRUG_NAME
		  FROM �շ���ĿĿ¼@TO_ZLHIS
		 WHERE ID = EXTRACT_DRUG_ID_IN;
		EXTRACT_ID_OUT   := ZLRECIPE.COMMENT_EXTRACT_EXTRACT_ID_SEQ.NEXTVAL;
  --��ʼʱ���ǳ�ȡ�µ�1��0��
		BEGIN_TIME       := TO_DATE(
			EXTRACT_MONTH_IN || '01 00:00:00'
			,'yyyymmdd hh24:mi:ss'
		);
  --����ʱ������1��0���1��
		FINISH_TIME      := ADD_MONTHS(
			BEGIN_TIME
			,1
		) - 1 / 24 / 60 / 60;
  --�Ȳ�����ȡ��¼
		INSERT   INTO COMMENT_EXTRACT (
			EXTRACT_ID
			,EXTRACT_TIME
			,PHARMACIST
			,PHARMACIST_ID
			,EXTRACT_MONTH
			,RECIPES_NUMBER
			,PATIENT_TYPE
			,SURGERY
			,RECIPE_TYPE
			,EXTRACT_TYPE
			,EXTRACT_DEPT_ID
			,EXTRACT_DEPT_NAME
			,EXTRACT_DR_ID
			,EXTRACT_DR_NAME
			,EXTRACT_DRUG_ID
			,EXTRACT_DRUG_NAME
		) VALUES (
			EXTRACT_ID_OUT
			,SYSDATE
			,PHARMACIST_IN
			,PHARMACIST_ID_IN
			,EXTRACT_MONTH_IN
			,RECIPES_NUMBER_IN
			,1
			,SURGERY_TYPE_IN
			,RECIPE_TYPE_IN
			,EXTRACT_TYPE_IN
			,EXTRACT_DEPT_ID_IN
			,V_DEPT_NAME
			,EXTRACT_DR_ID_IN
			,V_DR_NAME
			,EXTRACT_DRUG_ID_IN
			,V_DRUG_NAME
		);

  
  --��ȡ����
		INSERT   INTO COMMENT_RECIPES (
			EXTRACT_ID
			,RECIPE_NO
			,PID
			,PVID
			,RECIPE_DR
			,RECIPE_DR_TITLE
			,DR_ANTI_LEVEL
			,HIS_NO
			,RECIPE_DRUG_NUMBER
			,ANTI_DRUG_MAX_LEVEL
			,BASE_DRUG_NUMBER
			,PATIENT_AGE
			,PATIENT_BIRTHDAY
			,RECIPE_DATE
			,RECIPE_AMOUNT
			,RECIPE_DIAG
		)
			SELECT EXTRACT_ID_OUT
			      ,RECIPE_NO
			      ,PID
			      ,PVID
			      ,RECIPE_DR
			      ,RECIPE_DR_TITLE
			      ,DR_ANTI_LEVEL
			      ,100
			      ,RECIPES_NUMBER_IN
			      ,ANTI_DRUG_MAX_LEVEL
			      ,BASE_DRUG_NUMBER
			      ,PATIENT_AGE
			      ,PATIENT_BIRTHDAY
			      ,RECIPE_DATE
			      , ( SELECT TRUNC(
				SUM(II.ʵ�ս��)
			)
			             FROM ������ü�¼@TO_ZLHIS II
			            WHERE II.��¼״̬ <> 0
			   AND II.NO = E.RECIPE_NO
			            GROUP BY II.NO
			) RECIPE_AMOUNT
			      , ( SELECT
				LISTAGG(�������
				,'|') WITHIN  GROUP(
					 ORDER BY ''
				)
			             FROM ( SELECT DISTINCT HH.�������
			                      FROM �������ҽ��@TO_ZLHIS JJ
			                          ,������ϼ�¼@TO_ZLHIS HH
			                          ,����ҽ������@TO_ZLHIS KK
			                          ,����ҽ����¼@TO_ZLHIS LL
			                     WHERE JJ.���ID = HH.ID
			   AND LL.���ID = JJ.ҽ��ID
			   AND LL.ID = KK.ҽ��ID
			   AND KK.NO = E.RECIPE_NO
			)
			) RECIPE_DIAG
			  FROM ( SELECT RECIPE_NO
			               ,PID
			               ,PVID
			               ,RECIPE_DR
			               ,RECIPE_DR_TITLE
			               ,DR_ANTI_LEVEL
			               ,COUNT(*) RECIPE_DRUG_NUMBER
			               ,MAX(������) ANTI_DRUG_MAX_LEVEL
			               ,MAX(��Ƭ���� + ����Ƭ����) RECIPE_TYPE
			               ,SUM(BASE_DRUG_NUMBER) BASE_DRUG_NUMBER
			               ,MAX(PATIENT_AGE) PATIENT_AGE
			               ,MAX(PATIENT_BIRTHDAY) PATIENT_BIRTHDAY
			               ,MAX(RECIPE_DATE) RECIPE_DATE
			           FROM ( SELECT C.NO RECIPE_NO
			                        ,A.����ID PID
			                        ,A.�Һŵ� PVID
			                        ,A.����ҽ�� RECIPE_DR
			                        ,D.רҵ����ְ�� RECIPE_DR_TITLE
			                        ,E.���� DR_ANTI_LEVEL
			                        ,B.������
			                        ,A.��ҩĿ��
			                        ,CASE
					WHEN A.������� = 7 THEN
						1
					ELSE 0
				END
			��Ƭ����
			                        ,CASE
					WHEN A.������� <> 7 THEN
						3
					ELSE 0
				END
			����Ƭ����
			                        ,DECODE(
				H.����ҩ��
				,'��ҩ'
				,1
				,'���һ�ҩ'
				,1
				,0
			) BASE_DRUG_NUMBER
			                        ,I.���� PATIENT_AGE
			                        ,J.�������� PATIENT_BIRTHDAY
			                        ,A.����ʱ�� RECIPE_DATE
			                    FROM ����ҽ����¼@TO_ZLHIS A
			                        ,ҩƷ����@TO_ZLHIS B
			                        ,����ҽ������@TO_ZLHIS C
			                        ,��Ա��@TO_ZLHIS D
			                        ,��Ա����ҩ��Ȩ��@TO_ZLHIS E
			                        ,ҩƷ���@TO_ZLHIS H
			                        ,���˹Һż�¼@TO_ZLHIS I
			                        ,������Ϣ@TO_ZLHIS J
			                   WHERE A.������Դ = 1
			   AND A.������� IN (
				'5'
				,'6'
				,'7'
			)
			   AND H.ҩ��ID = A.������ĿID
			   AND A.����ID = J.����ID
			   AND B.ҩ��ID = A.������ĿID
			   AND I.NO = A.�Һŵ�
			   AND A.ID = C.ҽ��ID
			   AND A.����ҽ�� = D.����
			   AND (
				A.�շ�ϸĿID = EXTRACT_DRUG_ID_IN
				    OR NVL(
					EXTRACT_DRUG_ID_IN
					,0
				) = 0
			)
			   AND (
				A.����ҽ�� = EXTRACT_DR_ID_IN
				    OR EXTRACT_DR_ID_IN IS NULL
			)
			   AND (
				A.��������ID = EXTRACT_DEPT_ID_IN
				    OR ( NVL(
					EXTRACT_DEPT_ID_IN
					,0
				) = 0 )
			)
			   AND D.ID = E.��ԱID (+)
			   AND E.���� (+) = 1
			   AND E.��¼״̬ (+) = 1
			   AND A.ҽ��״̬ IN (
				7
				,8
				,9
			)
			   AND (
				(
					A.��ҩĿ�� = 1
					   AND RECIPE_TYPE_IN = 1
				)
				    OR (
					A.��ҩĿ�� = 2
					   AND RECIPE_TYPE_IN = 2
				)
				    OR RECIPE_TYPE_IN = 0
			)
			   AND A.����ʱ�� BETWEEN BEGIN_TIME    AND FINISH_TIME
			   AND NOT EXISTS ( SELECT 1
			                      FROM COMMENT_RECIPES F
			                     WHERE F.RECIPE_NO = C.NO
			)
			)
			          GROUP BY RECIPE_NO
			,PID
			,PVID
			,RECIPE_DR
			,RECIPE_DR_TITLE
			,DR_ANTI_LEVEL
			 ORDER BY DBMS_RANDOM.VALUE ) E
			 WHERE ROWNUM <= RECIPES_NUMBER_IN;
		IF SQL%ROWCOUNT = 0 THEN  --û�г�ȡ������
			DELETE COMMENT_EXTRACT
			 WHERE EXTRACT_ID = EXTRACT_ID_OUT;
			EXTRACT_ID_OUT   := NULL;
			--RAISE_APPLICATION_ERROR(-20001, 'û�г�ȡ�����������Ĵ���');
		END IF;
	END OUTPATIENT_EXTRACT;
  --��ɵ���
	PROCEDURE FINISH_COMMENT_RECIPE (
		EXTRACT_ID_IN IN NUMBER
	) AS
    --ͷע�Ϳ�ʼ-----------------------------------------------------------------------------------------
    --�������ƣ���ɵ���
    --����˵������ɵ���
    --���˵����EXTRACT_ID_IN IN NUMBER
    --����˵����
    --�� д �ߣ�����
    --��дʱ�䣺2018-06-26
    --�汾��¼���汾��+ʱ��+�޸���+�޸���������
    --ͷע�ͽ���-----------------------------------------------------------------------------------------
		N_PRO_COUNT   NUMBER;
	BEGIN
		IF EXTRACT_ID_IN != 0 THEN
			FOR I IN ( SELECT RECIPE_NO
			             FROM COMMENT_RECIPES
			            WHERE EXTRACT_ID = EXTRACT_ID_IN
			) LOOP
				SELECT COUNT(*)
				  INTO N_PRO_COUNT
				  FROM COMMENT_RESULT
				 WHERE RECIPE_NO = I.RECIPE_NO;
				IF N_PRO_COUNT > 0 THEN
					UPDATE COMMENT_RECIPES
					   SET
						COMMENT_RESULT =-1
					 WHERE RECIPE_NO = I.RECIPE_NO
					   AND EXTRACT_ID = EXTRACT_ID_IN;
				ELSE
					UPDATE COMMENT_RECIPES
					   SET
						COMMENT_RESULT = 1
					 WHERE RECIPE_NO = I.RECIPE_NO
					   AND EXTRACT_ID = EXTRACT_ID_IN;
				END IF;
			END LOOP;
			UPDATE COMMENT_EXTRACT
			   SET
				EXTRACT_STATUS = 1
			 WHERE EXTRACT_ID = EXTRACT_ID_IN;
		END IF;
	END FINISH_COMMENT_RECIPE;

  --�Զ�����
	PROCEDURE AUTO_COMMENT_RECIPE (
		EXTRACT_ID_IN IN NUMBER
	) AS
--ͷע�Ϳ�ʼ-----------------------------------------------------------------------------------------
--�������ƣ��Զ���������
--����˵������ĳһ�γ�ȡ�Ĵ��������Զ�����
--���˵����extract_ID_IN ��ȡID,patient_type_in ��������
--����˵����
--�� д �ߣ��޺�
--��дʱ�䣺2018-06-21
--�汾��¼���汾��+ʱ��+�޸���+�޸���������
--ͷע�ͽ���-----------------------------------------------------------------------------------------
		N_COMMENT_PROBLEM   NUMBER(18);
		V_COMMENT_CODE      VARCHAR2(20);
		N_PATIENT_TYPE      NUMBER(18);
	BEGIN
 --סԺ���ﶼ�еĹ���
  --����1-4 ��������Ӥ�׶�δд���ա����� ��Ҫ��������
  --����1-14 ҽʦδ���տ���ҩ���ٴ�Ӧ�ù���涨���߿���ҩ�ﴦ����
  --����2-1 ��Ӧ֤�����˵�
  --����2-2 ��ѡ��ҩƷ�����˵ģ����н��ɵ���ҩ��
  --����2-3 ҩƷ���ͻ��ҩ;�������˵�
  --����2-5 �÷������������˵ģ�
  --����2-6 ������ҩ�����˵�
  --����2-7 �ظ���ҩ��
  --����2-8 ��������ɻ��߲����໥���õģ�
  --����3-3 ���������ɳ�˵������ҩ�� ͨ��ҽ�������޽���ҩƷ˵���ж�
  --����3-4 ����������Ϊͬһ����ͬʱ����2������ҩ��������ͬҩ��� ͨ��ҽ�������޽���ҩƷ˵���ж�

  --���ﲡ�˹���
  --����:1-3 ҩƷ�շ���¼�У���ҩ�ˡ�����˲����
  --����1-5 ��ҩ���г�ҩ����ҩ��Ƭδ�ֱ𿪾ߴ�����
  --����1-10 ���ߴ���δд�ٴ���ϻ��ٴ������д��ȫ��
  --����1-11 �����ż��ﴦ����������ҩƷ��
  --����1-12 ����������£����ﴦ������7�����������ﴦ������3������
  --����1-13 ��������ҩƷ������ҩƷ��ҽ���ö���ҩƷ��������ҩƷ���������ҩƷ����δִ�й����йع涨�ġ������ʱ����
		SELECT MAX(PATIENT_TYPE)
		  INTO N_PATIENT_TYPE
		  FROM COMMENT_EXTRACT
		 WHERE EXTRACT_ID = EXTRACT_ID_IN;
		FOR I IN ( SELECT RECIPE_NO
		                 ,PID
		                 ,PVID
		                 ,RECIPE_DR
		                 ,RECIPE_DR_TITLE
		                 ,DR_ANTI_LEVEL
		                 ,HIS_NO
		                 ,COMMENT_RESULT
		                 ,RECIPE_DRUG_NUMBER
		                 ,ANTI_DRUG_MAX_LEVEL
		                 ,RECIPE_TYPE
		                 ,RECIPE_AMOUNT
		                 ,PATIENT_AGE
		                 ,RECIPE_DIAG
		                 ,PATIENT_BIRTHDAY
		                 ,RECIPE_DATE
		             FROM COMMENT_RECIPES
		            WHERE EXTRACT_ID = EXTRACT_ID_IN
		) LOOP
			IF N_PATIENT_TYPE = 1 THEN --���ﲡ��
			--����1-4 ��������Ӥ�׶�δд���ա����� ��Ҫ��������
				CASE
					WHEN I.RECIPE_DATE - I.PATIENT_BIRTHDAY <= 28 THEN --������
						IF INSTR(
								I.PATIENT_AGE
								,'��'
							) = 0 THEN
							UPD_COMMENT_RESULT(
								I.RECIPE_NO
								,'1-4'
								,NULL
								,NULL
							);
						END IF;
					WHEN MONTHS_BETWEEN(
						I.RECIPE_DATE
						,I.PATIENT_BIRTHDAY
					) <= 12 THEN --Ӥ��
						IF INSTR(
								I.PATIENT_AGE
								,'��'
							) = 0 THEN
							INSERT_COMMENT_RESULT(
								I.RECIPE_NO
								,'1-4'
								,NULL
								,NULL
							);
						END IF;
					ELSE
						NULL;
				END CASE;
				IF I.RECIPE_TYPE = 4 THEN --����1-5
					UPD_COMMENT_RESULT(
						I.RECIPE_NO
						,'1-5'
						,NULL
						,NULL
					);
				END IF;
				IF I.RECIPE_DIAG IS NULL THEN --����1-10 
					UPD_COMMENT_RESULT(
						I.RECIPE_NO
						,'1-10'
						,NULL
						,NULL
					);
				END IF;
				IF I.RECIPE_DRUG_NUMBER > 5    AND I.RECIPE_TYPE <> 1 THEN --����1-11
					UPD_COMMENT_RESULT(
						I.RECIPE_NO
						,'1-11'
						,NULL
						,NULL
					);
				END IF;
				IF I.DR_ANTI_LEVEL < I.ANTI_DRUG_MAX_LEVEL THEN --����1-14
					UPD_COMMENT_RESULT(
						I.RECIPE_NO
						,'1-14'
						,NULL
						,NULL
					);
				END IF;
				IF N_PATIENT_TYPE = 1 THEN  --���ﲡ�� ����1-3
					--���ﲡ�� ���Ϊҩʦ�ķ�ҩ����ҩ��¼
					SELECT COUNT(*)
					  INTO N_COMMENT_PROBLEM
					  FROM ҩƷ�շ���¼@TO_ZLHIS A
					      ,������ü�¼@TO_ZLHIS B
					 WHERE A.���� = 8
					   AND B.NO = A.NO
					   AND B.NO = I.RECIPE_NO
					   AND (
						A.��ҩ�� IS NULL
						    OR A."�����" IS NULL
					);
					IF N_COMMENT_PROBLEM > 0 THEN
						UPD_COMMENT_RESULT(
							I.RECIPE_NO
							,'1-3'
							,NULL
							,NULL
						);
					END IF;
				ELSE --סԺ���� ���Ϊҩʦ�ķ�ҩ����ҩ��¼								
					SELECT COUNT(*)
					  INTO N_COMMENT_PROBLEM
					  FROM ҩƷ�շ���¼@TO_ZLHIS A
					      ,סԺ���ü�¼@TO_ZLHIS B
					 WHERE A.���� = 8
					   AND B.NO = A.NO
					   AND B.����ID = I.PID
					   AND B.��ҳID = I.PVID
					   AND (
						A.��ҩ�� IS NULL
						    OR A."�����" IS NULL
					);
					IF N_COMMENT_PROBLEM > 0 THEN
						UPD_COMMENT_RESULT(
							I.RECIPE_NO
							,'1-3'
							,NULL
							,NULL
						);
					END IF;
				END IF;
			END IF;
			--����ҽ����¼
  --
  --����2-1 ��Ӧ֤�����˵�
  --����2-2 ��ѡ��ҩƷ�����˵ģ����н��ɵ���ҩ��
  --����2-3 ҩƷ���ͻ��ҩ;�������˵�
  --����2-5 �÷������������˵ģ�
  --����2-6 ������ҩ�����˵�
  --����2-7 �ظ���ҩ��
  --����2-8 ��������ɻ��߲����໥���õģ�
  --����3-3 ���������ɳ�˵������ҩ�� ͨ��ҽ�������޽���ҩƷ˵���ж�
  --����3-4 ����������Ϊͬһ����ͬʱ����2������ҩ��������ͬҩ��� ͨ��ҽ�������޽���ҩƷ˵���ж�
			FOR O IN ( SELECT A.ID
			                 ,A.ҽ������
			                 ,A.����
			                 ,A.������־
			                 ,A.����˵��
			                 ,C.��������
			                 ,C.���ɵȼ�
			                 ,C.˵��
			             FROM ����ҽ����¼@TO_ZLHIS A
			                 ,����ҽ������@TO_ZLHIS B
			                 ,V_������ҩ�����¼@TO_ZLKBC C
			            WHERE A.ҽ��״̬ IN (
				7
				,8
				,9
			)
			   AND A.ID = B.ҽ��ID
			   AND C.ҽ��ID (+) = A.ID
			   AND B.NO = I.RECIPE_NO
			) LOOP
				IF ( ( O.���� > 7    AND O.������־ = 0 )     OR ( O.���� > 3    AND O.������־ = 1 ) )    AND O.����˵�� IS NULL    AND N_PATIENT_TYPE = 1 THEN --���ﲡ��;����1-3
					UPD_COMMENT_RESULT(
						I.RECIPE_NO
						,'1-12'
						,O.ID
						,NULL
					);
				END IF;
				IF O.�������� IS NOT NULL THEN --������ҩ��˽��
					CASE
						WHEN O.�������� = '001' THEN --��Ӧ֢
							V_COMMENT_CODE   := '2-1';
						WHEN INSTR(
							',002,003,004,005,006,007,010'
							,',' || O.��������
						) > 0 THEN --����֢
							V_COMMENT_CODE   := '2-2';
						WHEN O.�������� = '009' THEN --ҩƷ���ͻ��ҩ;�������˵�
							V_COMMENT_CODE   := '2-3';
						WHEN O.�������� = '008' THEN --�÷������������˵ģ�
							V_COMMENT_CODE   := '2-5';
						WHEN O.�������� = '012' THEN --������ҩ�����˵�
							V_COMMENT_CODE   := '2-6';
						WHEN O.�������� = '011' THEN --�ظ���ҩ��
							V_COMMENT_CODE   := '2-7';
						WHEN O.�������� = '013' THEN --��������ɻ��߲����໥���õ�
							V_COMMENT_CODE   := '2-8';
						ELSE
							V_COMMENT_CODE   := NULL;
					END CASE;
					IF V_COMMENT_CODE IS NOT NULL THEN
						UPD_COMMENT_RESULT(
							I.RECIPE_NO
							,V_COMMENT_CODE
							,O.ID
							,O.ҽ������ || '����������:' || O.˵��
						);
					END IF;
				END IF;
			END LOOP;
		END LOOP;
		UPDATE COMMENT_RECIPES A
		   SET
			A.COMMENT_RESULT =-1
		 WHERE A.EXTRACT_ID = EXTRACT_ID_IN
		   AND EXISTS ( SELECT 1
		                  FROM COMMENT_RESULT B
		                 WHERE B.RECIPE_NO = A.RECIPE_NO
		);
	END AUTO_COMMENT_RECIPE;
  
  --�˹�����
	PROCEDURE MANUAL_COMMENT_RESULT (
		C_INPUT IN CLOB
	) AS 
--ͷע�Ϳ�ʼ-----------------------------------------------------------------------------------------
--�������ƣ��˹���������
--����˵�����Ե����Ľ��������Ӧ�ı��桢�޸�
--���˵����c_input Ϊ���洫���json ����RECIPE_NO��COMMENT_ITEM_CODE��ORDER_ID��COMMENT_CONTENT
--����˵����
--�� д �ߣ��⿪��
--��дʱ�䣺2018-06-23
--�汾��¼���汾��+ʱ��+�޸���+�޸���������
--ͷע�ͽ���-----------------------------------------------------------------------------------------
		C_COMMENT           CLOB;
		V_COMMENT_CONTENT   VARCHAR2(4000);
		N_COUNT             NUMBER(18);
	BEGIN
		C_COMMENT   := C_INPUT;
--- �������Ϊ�գ���������� ��ʾ  COMMENT_ITEM_CODE��Ŀ��Ӧ��ֵ
		FOR I IN ( SELECT RECIPE_NO
		                 ,COMMENT_ITEM_CODE
		                 ,ORDER_ID
		                 ,COMMENT_CONTENT
		             FROM
			JSON_TABLE ( C_COMMENT,'$[*]'
				COLUMNS
					RECIPE_NO VARCHAR2 ( 50 ) PATH '$."recipe_no"'
				,COMMENT_ITEM_CODE VARCHAR2 ( 50 ) PATH '$."comment_item_code"'
				,ORDER_ID NUMBER ( 18,0 ) PATH '$."order_id"'
				,COMMENT_CONTENT VARCHAR2 ( 4000 ) PATH '$."comment_content"'
			)
		) LOOP
			V_COMMENT_CONTENT   := I.COMMENT_CONTENT;
			IF I.COMMENT_CONTENT IS NULL THEN
				SELECT MAX(A.ITEM_CONTENT)
				  INTO V_COMMENT_CONTENT
				  FROM COMMENT_ITEM A
				 WHERE A.ITEM_CODE = I.COMMENT_ITEM_CODE;
			END IF;
			UPD_COMMENT_RESULT(
				I.RECIPE_NO
				,I.COMMENT_ITEM_CODE
				,I.ORDER_ID
				,V_COMMENT_CONTENT
			);
		END LOOP;
	EXCEPTION
		WHEN OTHERS THEN
			NULL;
    --zl_ErrorCenter(SQLCode, SQLErrM);
	END MANUAL_COMMENT_RESULT;
	--����������
	PROCEDURE INSERT_COMMENT_RESULT (
		RECIPE_NO_IN           IN VARCHAR2
		,COMMENT_ITEM_CODE_IN   IN VARCHAR2
		,ORDER_ID_IN            IN NUMBER
		,ITEM_CONTENT_IN        IN VARCHAR2
	) AS
--ͷע�Ϳ�ʼ-----------------------------------------------------------------------------------------
--�������ƣ������������
--����˵��������һ������ĵ������
--���˵����RECIPE_NO_IN ����,COMMENT_ITEM_CODE_IN ������Ŀ����,ORDER_ID_IN ����ҽ��ID,ITEM_CONTENT_IN ������Ŀ����
--����˵����
--�� д �ߣ��޺�
--��дʱ�䣺2018-06-23
--�汾��¼���汾��+ʱ��+�޸���+�޸���������
--ͷע�ͽ���-----------------------------------------------------------------------------------------		
		V_ITEM_CONTENT   VARCHAR2(4000);
	BEGIN
	--���û�е�����������ݣ���ֱ��ȡ������Ŀ������
		IF ITEM_CONTENT_IN IS NULL THEN
			SELECT MAX(ITEM_CONTENT)
			  INTO V_ITEM_CONTENT
			  FROM COMMENT_ITEM
			 WHERE ITEM_CODE = COMMENT_ITEM_CODE_IN;
		ELSE
			V_ITEM_CONTENT   := ITEM_CONTENT_IN;
		END IF;
		INSERT   INTO COMMENT_RESULT (
			RECIPE_NO
			,COMMENT_ITEM_CODE
			,ORDER_ID
			,COMMENT_CONTENT
		) VALUES (
			RECIPE_NO_IN
			,COMMENT_ITEM_CODE_IN
			,ORDER_ID_IN
			,V_ITEM_CONTENT
		);
	END INSERT_COMMENT_RESULT;
--���µ������
	PROCEDURE UPD_COMMENT_RESULT (
		RECIPE_NO_IN           IN VARCHAR2
		,COMMENT_ITEM_CODE_IN   IN VARCHAR2
		,ORDER_ID_IN            IN NUMBER
		,ITEM_CONTENT_IN        IN VARCHAR2
	) AS
--ͷע�Ϳ�ʼ-----------------------------------------------------------------------------------------
--�������ƣ����µ������
--����˵��������һ������ĵ������
--���˵����RECIPE_NO_IN ����,COMMENT_ITEM_CODE_IN ������Ŀ����,ORDER_ID_IN ����ҽ��ID,ITEM_CONTENT_IN ������Ŀ����
--����˵����
--�� д �ߣ��޺�
--��дʱ�䣺2018-06-23
--�汾��¼���汾��+ʱ��+�޸���+�޸���������
--ͷע�ͽ���-----------------------------------------------------------------------------------------
		V_ITEM_CONTENT   VARCHAR2(4000);
	BEGIN
		IF ITEM_CONTENT_IN IS NULL THEN  --û�е������ݣ�ȡ������Ŀ������
			SELECT MAX(ITEM_CONTENT)
			  INTO V_ITEM_CONTENT
			  FROM COMMENT_ITEM
			 WHERE ITEM_CODE = COMMENT_ITEM_CODE_IN;
		ELSE
			V_ITEM_CONTENT   := ITEM_CONTENT_IN;
		END IF;
		UPDATE COMMENT_RESULT
		   SET
			COMMENT_CONTENT = V_ITEM_CONTENT
		 WHERE RECIPE_NO = RECIPE_NO_IN
		   AND (
			ORDER_ID = ORDER_ID_IN
			    OR ORDER_ID_IN IS NULL
		)
		   AND COMMENT_ITEM_CODE = COMMENT_ITEM_CODE_IN;
		--û�и��¾�����   
		IF SQL%ROWCOUNT = 0 THEN
			INSERT_COMMENT_RESULT(
				RECIPE_NO_IN
				,COMMENT_ITEM_CODE_IN
				,ORDER_ID_IN
				,ITEM_CONTENT_IN
			);
		END IF;
	END UPD_COMMENT_RESULT;
--ɾ���������
	PROCEDURE DEL_COMMENT_RESULT (
		RECIPE_NO_IN           IN VARCHAR2
		,COMMENT_ITEM_CODE_IN   IN VARCHAR2
		,ORDER_ID_IN            IN NUMBER
	)
		AS
--ͷע�Ϳ�ʼ-----------------------------------------------------------------------------------------
--�������ƣ�ɾ���������
--����˵����ɾ��һ������ĵ������
--���˵����RECIPE_NO_IN ����,COMMENT_ITEM_CODE_IN ������Ŀ����,ORDER_ID_IN ����ҽ��ID,ITEM_CONTENT_IN ������Ŀ����
--����˵����
--�� д �ߣ��޺�
--��дʱ�䣺2018-06-23
--�汾��¼���汾��+ʱ��+�޸���+�޸���������
--ͷע�ͽ���-----------------------------------------------------------------------------------------
	BEGIN
		DELETE COMMENT_RESULT
		 WHERE RECIPE_NO = RECIPE_NO_IN
		   AND (
			ORDER_ID = ORDER_ID_IN
			    OR ORDER_ID_IN IS NULL
		)
		   AND COMMENT_ITEM_CODE = COMMENT_ITEM_CODE_IN;
	END DEL_COMMENT_RESULT;
--ɾ��������ȡ	
	PROCEDURE DEL_ECTRACT (
		EXTRACT_ID_IN NUMBER
	)
		AS
 --ͷע�Ϳ�ʼ-----------------------------------------------------------------------------------------
--�������ƣ�ɾ��������ȡ
--����˵����ɾ��һ��������ȡ
--���˵����
--����˵����
--�� д �ߣ��޺�
--��дʱ�䣺2018-07-03
--�汾��¼���汾��+ʱ��+�޸���+�޸���������
--ͷע�ͽ���-----------------------------------------------------------------------------------------
	BEGIN
		DELETE COMMENT_EXTRACT
		 WHERE EXTRACT_ID = EXTRACT_ID_IN;
	END DEL_ECTRACT;
END PKG_RECIPE_COMMENT;

/
