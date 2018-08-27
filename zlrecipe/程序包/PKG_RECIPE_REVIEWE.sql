CREATE OR REPLACE PACKAGE PKG_RECIPE_REVIEWE IS
  --�������
  -- Author  : ZLAPEX������
  -- Created : 2018/6/6 9:43:08
  -- Purpose : 

  --ҩʦ�ϸ�[001]
  PROCEDURE PHARMACIST_REGISTER(USER_ID_IN IN VARCHAR2);

  --ҩʦ�¸�[002]
  PROCEDURE PHARMACIST_UNREGISTER(USER_ID_IN IN VARCHAR2);

  --ҩʦ��[003]
  PROCEDURE PHARMACIST_REVIEWE(INPUT_IN IN CLOB);

  -- ���մ�����Ϣ
  PROCEDURE RECEIVE_RECIPES(prescription IN CLOB);

  -- �ӵ�������/ˢ�� ҩʦ�� ����
  PROCEDURE ORDER_RECEIVING(USER_ID     IN VARCHAR2,
                            P_TYPE_IN   IN NUMBER,
                            ORDER_SCOPE IN NUMBER,
                            OUTPUT_OUT  OUT CLOB);

  -- ��鳬ʱ����˴���
  PROCEDURE TIMEOUT_REVIEWE;

  --��ѯ���˴�����˽��
  PROCEDURE GET_RECIPES_REVIEWE_RESULT(PID_IN    IN NUMBER,
                                       PVID_IN   IN NUMBER,
                                       RESULTOUT OUT SYS_REFCURSOR);
   --��ѯ���˴���������˽��
  PROCEDURE GET_RECIPES_REVIEWE_RESULT_ALL(PID_IN    IN NUMBER,
                                           PVID_IN   IN NUMBER,
                                           RESULTOUT OUT SYS_REFCURSOR);
                                       
  --�༭��˷���
  PROCEDURE EDIT_REVIEWE_SOLUTION(INPUT_IN IN CLOB, EDIT_TYPE_IN IN NUMBER);    
  
  --�༭��˷�����ϸ
  PROCEDURE EDIT_REVIEWE_SOLUTION_DETAIL(INPUT_IN IN CLOB, EDIT_TYPE_IN IN NUMBER);                               
  -----------------ATOM------------------------------------------
  --����ҩʦ������¼
  PROCEDURE INSERT_PHARMACIST_WORK_RECORD(INPUT_IN IN CLOB);

  --�޸�ҩʦ������¼
  PROCEDURE UPD_PHARMACIST_WORK_RECORD(INPUT_IN IN CLOB);
  
  --ҩʦ���ҷ�������
  Procedure Upd_pharmacist_reviewe_dept(dept_id in clob,user_id in varchar2,V_Current_USER_CODE in varchar2);
  
  --����ҩʦ/�޸�ҩʦ ����
 Procedure Upd_recipe_user(
               V_Current_USER_NAME in varchar2,
               V_USER_CODE in varchar2,
               V_USER_NAME IN VARCHAR2,
               V_USER_JOB in varchar2,
               V_USER_STATUS in  number,
               N_change number,
               V_WEB_PASSWORD IN VARCHAR2,
               N_IS_ADMIN  NUMBER);
               
   --����ҩʦ apex��¼�û�
    Procedure CREATE_USER(
              V_USER_ID in varchar2,
              V_WEB_PASSWORD in varchar2,
              N_STATUS_IN in NUMBER,
              N_ADMIN IN NUMBER
              );
   -- �޸�apex�û�
   Procedure EDIT_USER(
       p_user_name in varchar2,
       status in NUMBER,
       N_ADMIN IN NUMBER
        );
 --������������
 Procedure DEPT_START( DEPT_NAME_IN in varchar2,  USER_NAME_IN in varchar2);

--ȡ�����ÿ���
 Procedure DEL_REVIEWE_DEPT( DEPT_NAME_IN in varchar2);

  --�޸����ﴦ��סԺҽ����¼
  PROCEDURE UPD_REVIEWE_RECIPES(INPUT_IN IN CLOB);

  --ɾ�������¼
  PROCEDURE DEL_WAIT_REVIEWE_RECIPE(INPUT_IN IN CLOB);

  --��¼������־
  PROCEDURE INSERT_LOG(LOG_TITILE_IN  IN VARCHAR2,
                       LOG_TYPE_IN    IN VARCHAR2,
                       LOG_Content_IN IN CLOB);

  --ҽ����д�ܾ�ҩʦ��ͨ������
  PROCEDURE UPD_DR_REFUSE_COMMENT(RECIPES_IN IN CLOB);
  --��ZLHIS�����󷽽����Ϣ
  PROCEDURE SEND_MESSAGE_TO_ZLHIS(PID_IN            IN NUMBER,
                                  PVID_IN           IN NUMBER,
                                  REVIEWE_RESULT_IN IN NUMBER,
                                  PHARMACIST_NAME   IN VARCHAR2 := '');
  --�޸���˷���
  PROCEDURE UPD_REVIEWE_SOLUTION(INPUT_IN IN CLOB);
  
  --�󷽷������
   Procedure Prescriptions_Regularity( V_field_name in varchar2, C_REVIEWE_SOLUTION_OUT out clob);
  
  --������˷���
  PROCEDURE INSERT_REVIEWE_SOLUTION(INPUT_IN IN CLOB);
  
  --���淽��ʱ����֤��˷���׼ȷ��
  PROCEDURE VERIFY_SOLUTION( V_REVIEWE_SOLUTION_ID IN VARCHAR2);
 
  --ɾ����˷���
  PROCEDURE DEL_REVIEWE_SOLUTION(REVIEWE_SOLUTION_ID_IN IN VARCHAR2);
  
  --�޸���˷�����ϸ
  Procedure Upd_Reviewe_Solution_Detail(Input_In In Clob);
  
  --������˷�����ϸ
  Procedure Insert_Reviewe_Solution_Detail(Input_In In Clob);

  --ɾ����˷�����ϸ
  Procedure Del_Reviewe_Solution_Detail(Input_In In Clob);
      
  --��ϵͳ��װ���ʼ��
  Procedure Recipe_Reviewe_comment_Init;
END PKG_RECIPE_REVIEWE;

/


CREATE OR REPLACE PACKAGE BODY PKG_RECIPE_REVIEWE IS

  --ҩʦ�ϸ�[001]
	PROCEDURE PHARMACIST_REGISTER (
		USER_ID_IN IN VARCHAR2
	) AS
    --ͷע�Ϳ�ʼ-----------------------------------------------------------------------------------------
    --�������ƣ�ҩʦ�ϸ�[001]
    --����˵����ҩʦ�ϸ�[001]
    --���˵����User_ID_In In Varchar2
    --����˵����
    --�� д �ߣ�����
    --��дʱ�䣺2018-06-06
    --�汾��¼���汾��+ʱ��+�޸���+�޸���������
    --ͷע�ͽ���-----------------------------------------------------------------------------------------
		V_USER_NAME        VARCHAR2(80);
		N_REGISTER_COUNT   NUMBER;
		C_INPUT            CLOB;
	BEGIN
		IF USER_ID_IN IS NOT NULL THEN
			SELECT MAX(USER_NAME)
			  INTO V_USER_NAME
			  FROM RECIPE_USER
			 WHERE USER_CODE = UPPER(USER_ID_IN);
      --�ظ��ϸ�
			SELECT COUNT(*)
			  INTO N_REGISTER_COUNT
			  FROM PHARMACIST_WORK_RECORD
			 WHERE PHARMACIST_ID = USER_ID_IN
			   AND REGISTER_TIME >= TRUNC(SYSDATE)
			   AND UNREGISTER_TIME IS NULL;
			IF N_REGISTER_COUNT = 0 THEN
				C_INPUT   := '{"pharmacist":"' || V_USER_NAME || '","pharmacist_id":"' || USER_ID_IN || '","register_time":"' || TO_CHAR(
					SYSDATE
					,'yyyy-mm-dd hh24:mi:ss'
				) || '","register_date":"' || TO_CHAR(
					SYSDATE
					,'yyyymmdd'
				) || '","unregister_time":""' || ',"last_reviewe_time":""}';
				INSERT_PHARMACIST_WORK_RECORD(C_INPUT);
			END IF;
		END IF;
	END PHARMACIST_REGISTER;

  --ҩʦ�¸�[002]
	PROCEDURE PHARMACIST_UNREGISTER (
    USER_ID_IN IN VARCHAR2
  ) AS
    --ͷע�Ϳ�ʼ-----------------------------------------------------------------------------------------
    --�������ƣ�ҩʦ�¸�[002]
    --����˵����ҩʦ�¸�[002]
    --���˵����User_ID_In In Varchar2
    --����˵����
    --�� д �ߣ�����
    --��дʱ�䣺2018-06-06
    --�汾��¼��2018-07-12 �������ߣ��ӵ��������
    --ͷע�ͽ���-----------------------------------------------------------------------------------------
    J_UNREGISTER   JSON_OBJECT_T;
    C_UNREGISTER   CLOB;
  BEGIN
    IF USER_ID_IN IS NOT NULL THEN
      ----�����ѽӵ�����
      For I In (Select Order_Id, PVID, PID
                  From wait_reviewe_recipe
                 Where PHARMACIST_ID = USER_ID_IN)Loop
        UPDATE WAIT_REVIEWE_RECIPE
           SET PHARMACIST_ID = Null,
               PHARMACIST = Null,
               PHARMACIST_RECEIVE_TIME = Null
         WHERE PID = I.PID
           AND PVID = I.PVID
           AND ORDER_ID = I.ORDER_ID;
        UPDATE REVIEWE_RECIPES
           SET PHARMACIST_ID = Null,
               PHARMACIST = Null,
               PHARMACIST_RECEIVE_TIME = Null,
               REVIEWE_RESULT = 0
         WHERE PID = I.PID
           AND PVID = I.PVID
           AND ORDER_ID = I.ORDER_ID;
      End Loop;
      SELECT
        JSON_OBJECT(
          KEY 'pharmacist' IS PHARMACIST
        ,KEY 'pharmacist_id' IS PHARMACIST_ID
        ,KEY 'register_time' IS TO_CHAR(
            REGISTER_TIME
            ,'yyyy-mm-dd hh24:mi:ss'
          )
        ,KEY 'register_date' IS REGISTER_DATE
        ,KEY 'unregister_time' IS TO_CHAR(
            UNREGISTER_TIME
            ,'yyyy-mm-dd hh24:mi:ss'
          )
        )
        INTO C_UNREGISTER
        FROM PHARMACIST_WORK_RECORD
       WHERE PHARMACIST_ID = USER_ID_IN
         AND REGISTER_TIME >= TRUNC(SYSDATE)
         AND UNREGISTER_TIME IS NULL;
      J_UNREGISTER   := JSON_OBJECT_T(C_UNREGISTER);
      J_UNREGISTER.PUT(
        'unregister_time'
        ,TO_CHAR(
          SYSDATE
          ,'yyyy-mm-dd hh24:mi:ss'
        )
      );
      UPD_PHARMACIST_WORK_RECORD(J_UNREGISTER.TO_CLOB() );
    END IF;
  END PHARMACIST_UNREGISTER;

  --ҩʦ��[003]
	PROCEDURE PHARMACIST_REVIEWE (
		INPUT_IN IN CLOB
	) AS
    --ͷע�Ϳ�ʼ-----------------------------------------------------------------------------------------
    --�������ƣ�ҩʦ��[003]
    --����˵����ҩʦ��[003]
    --���˵����Input_In[{"pid": ,"pvid":"","order_id": ,"pharmacist_id":"","reviewe_result": ,"reviewe_comment":""}]
    --����˵����
    --�� д �ߣ�����
    --��дʱ�䣺2018-06-12
    --�汾��¼���汾��+ʱ��+�޸���+�޸���������
    --ͷע�ͽ���-----------------------------------------------------------------------------------------
		N_NO_PASS        NUMBER(18);
		N_PID            NUMBER(18);
		N_PVID           NUMBER(18);
		N_PATIENT_TYPE   NUMBER(18);
		V_PHARMACIST     VARCHAR2(80);
	BEGIN
		PKG_RECIPE_REVIEWE.INSERT_LOG(
			LOG_TITILE_IN    => '���ύ'
			,LOG_TYPE_IN      => 'T'
			,LOG_CONTENT_IN   => INPUT_IN
		);
   -- return;
		SELECT SUM(
			CASE
				WHEN REVIEWE_RESULT =-1  THEN
					1
				ELSE 0
			END
		)
		      ,MAX(PID)
		      ,MAX(PVID)
		      ,MAX(PHARMACIST)
		  INTO
			N_NO_PASS
		,N_PID
		,N_PVID
		,V_PHARMACIST
		  FROM
			JSON_TABLE ( INPUT_IN,'$[*]'
				COLUMNS
					REVIEWE_RESULT NUMBER ( 18 ) PATH '$."reviewe_result"'
				,PID NUMBER ( 18 ) PATH '$."pid"'
				,PVID NUMBER ( 18 ) PATH '$."pvid"'
				,PHARMACIST VARCHAR2 ( 80 ) PATH '$."pharmacist"'
			);
		IF DBMS_LOB.GETLENGTH(INPUT_IN) <> 0 THEN
      --ɾ�������¼���ӱ�
			PKG_RECIPE_REVIEWE.DEL_WAIT_REVIEWE_RECIPE(INPUT_IN);
      --�޸����ﴦ��סԺҽ����¼������
			PKG_RECIPE_REVIEWE.UPD_REVIEWE_RECIPES(INPUT_IN);
		END IF;
		SELECT MAX(P_TYPE)
		  INTO N_PATIENT_TYPE
		  FROM RECIPE_PATIENT_INFO
		 WHERE PID = N_PID
		   AND PVID = N_PVID;
		IF N_PATIENT_TYPE = 1 THEN
      --���ﲡ�ˣ�ȫ��֪ͨ
			SEND_MESSAGE_TO_ZLHIS(
				N_PID
				,N_PVID
				,1
				,V_PHARMACIST
			);
		ELSE
			IF N_NO_PASS > 0 THEN
        ----סԺ���ˣ���δͨ����֪ͨ
				SEND_MESSAGE_TO_ZLHIS(
					N_PID
					,N_PVID
					,-1
					,V_PHARMACIST
				);
			END IF;
		END IF;
	EXCEPTION
		WHEN OTHERS THEN
			PKG_RECIPE_REVIEWE.INSERT_LOG(
				'ҩʦ��'
				,'E'
				,INPUT_IN
			);
	END PHARMACIST_REVIEWE;

  -- ���մ�����Ϣ�����˻�����Ϣ
	PROCEDURE RECEIVE_RECIPES (
		PRESCRIPTION IN CLOB
	) IS
    --ͷע�Ϳ�ʼ-----------------------------------------------------------------------------------------
    --�������ƣ�����ҽ����Ϣ
    --����˵�����������סԺ�¿�ҽ����Ϣ��
    --���˵����������ҩ����ҽ����ϢXML
    --����˵����pid��pvid��ҽ��ID��
    --�� д �ߣ��⿪��
    --��дʱ�䣺2018-06-13
    --�汾��¼���汾��+ʱ��+�޸���+�޸���������
    --ͷע�ͽ���-----------------------------------------------------------------------------------------
		T_��ʼʱ��         REVIEWE_RECIPES.RECIPE_TIME%TYPE;
		T_����ʱ��         REVIEWE_RECIPES.RECIPE_TIME%TYPE;
    --��¼ ҽ����Ĳ�����
		N_�޸�_RECIPE    NUMBER;
		N_����_RECIPE    NUMBER;
    --��¼ ���˻�����Ϣ���еĲ�����
		N_�޸�_PATIENT   NUMBER;
		N_����_PATIENT   NUMBER;
		N_�Զ�ʱ����       RECIPE_REVIEWE_PARA.PARA_VALUE%TYPE;
		C_ORDER_ID     CLOB;
    --���˻�����Ϣ����
		N_PID          NUMBER(20);
		N_PVID         NUMBER(20);
		V_����           VARCHAR2(50);
		V_�Ա�           VARCHAR2(10);
		V_����           VARCHAR2(20);
		V_��������         VARCHAR2(50);
		V_��Ժ����         VARCHAR2(50);
		V_���������        VARCHAR2(500);
		V_��Ժ����         VARCHAR2(20);
		V_��Ҫ���         VARCHAR2(100);
		V_�����          VARCHAR2(20);
		V_סԺ��          VARCHAR2(20);
		V_����           VARCHAR2(20);
		V_�������         VARCHAR2(50);
		V_�������ID       VARCHAR2(36);
		N_Ӥ��           NUMBER(1);
		N_HIS_NO       NUMBER(3);
		T_��ǰʱ��         REVIEWE_RECIPES.RECIPE_TIME%TYPE;
		V_���ﲡ��         VARCHAR2(50);
		V_���ﲡ��ID       VARCHAR2(36);
		N_������Դ         NUMBER(1);
		N_�ύ����         NUMBER(1);
		X_RECIPES      SYS.XMLTYPE;
	BEGIN
		X_RECIPES      := XMLTYPE.CREATEXML(PRESCRIPTION);
		C_ORDER_ID     := '';
		N_�޸�_PATIENT   := 0;
		N_����_PATIENT   := 0;
		N_����_RECIPE    := 0;
		N_�޸�_RECIPE    := 0;

		SELECT MAX(�ύ����)
		  INTO N_�ύ����
		  FROM XMLTABLE ( '/details_xml/patient_info' PASSING X_RECIPES COLUMNS �ύ���� NUMBER(20) PATH '//info[@name="�ύ����"]/@value' );
		IF N_�ύ���� = 1 THEN
			RETURN;
		END IF;
		
		SELECT A.PARA_VALUE
		  INTO N_�Զ�ʱ����
		  FROM RECIPE_REVIEWE_PARA A
		 WHERE A.PARA_NAME = '��ʱ�Զ�ͨ�����ʱ��';

		
		SELECT A.����ID
		      ,A.����ID
		      ,A.����
		      ,A.�Ա�
		      ,A.����
		      ,A.��������
		      ,A.��Ժ����
		      ,DECODE(
			A.����
			,1
			,'����|'
			,''
		) || DECODE(
			A.����
			,1
			,'����|'
			,''
		) || DECODE(
			A.�ι��ܲ�ȫ
			,1
			,'�ι��ܲ�ȫ|'
			,''
		) || DECODE(
			A.���ظι��ܲ�ȫ
			,1
			,'���ظι��ܲ�ȫ|'
			,''
		) || DECODE(
			A.�����ܲ�ȫ
			,1
			,'�����ܲ�ȫ|'
			,''
		) || DECODE(
			A.���������ܲ�ȫ
			,1
			,'���������ܲ�ȫ|'
			,''
		) ���������
		      ,A.��Ҫ���
		      ,A.�����
		      ,A.סԺ��
		      ,A.����
		      ,A.�������
		      ,A.�������ID
		      ,A.Ӥ��
		      ,A.HIS_NO
		      ,A.���ﲡ��
		      ,A.���ﲡ��ID
		      ,A.������Դ
		  INTO
			N_PID
		,N_PVID
		,V_����
		,V_�Ա�
		,V_����
		,V_��������
		,V_��Ժ����
		,V_���������
		,V_��Ҫ���
		,V_�����
		,V_סԺ��
		,V_����
		,V_�������
		,V_�������ID
		,N_Ӥ��
		,N_HIS_NO
		,V_���ﲡ��
		,V_���ﲡ��ID
		,N_������Դ
		  FROM XMLTABLE ( '/details_xml/patient_info' PASSING X_RECIPES COLUMNS ����ID NUMBER(20) PATH '//info[@name="����ID"]/@value',����ID NUMBER(20) PATH '//info[@name="����ID"]/@value',���� VARCHAR2(30) PATH '//info[@name="����"]/@value',�Ա� VARCHAR2(12) PATH '//info[@name="�Ա�"]/@value'
,���� VARCHAR2(10) PATH '//info[@name="����"]/@value',�������� VARCHAR2(20) PATH '//info[@name="��������"]/@value',��Ժ���� VARCHAR2(20) PATH '//info[@name="��Ժ����"]/@value',���� VARCHAR2(50) PATH '//info[@name="����"]/@value',���� VARCHAR2(50) PATH '//info[@name="����"]/@value',�ι��ܲ�ȫ VARCHAR2
(50) PATH '//info[@name="�ι��ܲ�ȫ"]/@value',���ظι��ܲ�ȫ VARCHAR2(50) PATH '//info[@name="���ظι��ܲ�ȫ"]/@value',�����ܲ�ȫ VARCHAR2(50) PATH '//info[@name="�����ܲ�ȫ"]/@value',���������ܲ�ȫ VARCHAR2(50) PATH '//info[@name="���������ܲ�ȫ"]/@value',��Ҫ��� VARCHAR2(200) PATH '//info[@name="�������"]/@value'
,����� VARCHAR2(20) PATH '//info[@name="�����"]/@value',סԺ�� VARCHAR2(20) PATH '//info[@name="סԺ��"]/@value',���� VARCHAR2(20) PATH '//info[@name="����"]/@value',������� VARCHAR2(20) PATH '//info[@name="�������"]/@value',�������ID VARCHAR2(36) PATH '//info[@name="�������ID"]/@value',Ӥ�� NUMBER
(1) PATH '//info[@name="Ӥ��"]/@value',HIS_NO NUMBER(3) PATH '//info[@name="HIS_NO"]/@value',���ﲡ�� VARCHAR2(20) PATH '//info[@name="���ﲡ��"]/@value',���ﲡ��ID VARCHAR2(36) PATH '//info[@name="���ﲡ��ID"]/@value',������Դ NUMBER(1) PATH '//info[@name="������Դ"]/@value' ) A;


    -- ��� ����id������id�ظ��� �޸ġ�  
		UPDATE RECIPE_PATIENT_INFO A
		   SET A.P_NAME = V_����,A.P_GENDER = V_�Ա�
		,A.P_AGE = V_����
		,A.P_BIRTHDAY = TO_DATE(
				V_��������
				,'yyyy-mm-dd hh24:mi:ss'
			)
		,A.P_IN_TIME = TO_DATE(
				V_��Ժ����
				,'yyyy-mm-dd hh24:mi:ss'
			)
		,A.P_PHYS = V_���������
		,A.P_MAJOR_DIAG = V_��Ҫ���
		,A.P_OUT_NO = V_�����
		,A.P_IN_NO = V_סԺ��
		,A.P_BED_NO = V_����
		,A.P_DEPT_NAME = V_�������
		,A.P_DEPT_ID = V_�������ID
		,A.P_NURSING_DEPT_NAME = V_���ﲡ��
		,A.P_NURSING_DEPT_ID = V_���ﲡ��ID
		,A.P_TYPE = N_������Դ
		 WHERE A.PID = N_PID
		   AND A.PVID = N_PVID;

		IF SQL%FOUND = FALSE    AND N_PID IS NOT NULL THEN
			INSERT   INTO RECIPE_PATIENT_INFO (
				PID
				,PVID
				,P_NAME
				,P_GENDER
				,P_AGE
				,P_BIRTHDAY
				,P_IN_TIME
				,P_PHYS
				,P_MAJOR_DIAG
				,P_OUT_NO
				,P_IN_NO
				,P_BED_NO
				,P_DEPT_NAME
				,P_DEPT_ID
				,P_NURSING_DEPT_ID
				,P_TYPE
				,P_NURSING_DEPT_NAME
			) VALUES (
				N_PID
				,N_PVID
				,V_����
				,V_�Ա�
				,V_����
				,TO_DATE(
					V_��������
					,'yyyy-mm-dd hh24:mi:ss'
				)
				,TO_DATE(
					V_��Ժ����
					,'yyyy-mm-dd hh24:mi:ss'
				)
				,V_���������
				,V_��Ҫ���
				,V_�����
				,V_סԺ��
				,V_����
				,V_�������
				,V_�������ID
				,V_���ﲡ��ID
				,N_������Դ
				,V_���ﲡ��
			);
      -- i_���� ��¼������������  
			N_����_PATIENT   := N_����_PATIENT + 1;
		ELSE
      --��¼�޸���������
			N_�޸�_PATIENT   := N_�޸�_PATIENT + 1;
		END IF;
  
    --��ȡ��ǰʱ��
		T_��ǰʱ��         := SYSDATE;
    -- ѭ��ҽ����Ϣ

		IF N_PID IS NOT NULL THEN
		
			PKG_RECIPE_REVIEWE.INSERT_LOG(
				LOG_TITILE_IN    => 'ZLHIS����ҽ��'
				,LOG_TYPE_IN      => 'T'
				,LOG_CONTENT_IN   => null
			);
		
			FOR R_ROW IN ( SELECT A.*
			                 FROM XMLTABLE ( '/details_xml/medicine_info/medicine' PASSING X_RECIPES COLUMNS ҽ��ID NUMBER(18) PATH '//info[@name="ҽ��ID"]/@value',��Һ��� NUMBER(18) PATH '//info[@name="��Һ���"]/@value',��λ�� VARCHAR2(400) PATH '//info[@name="��λ��"]/@value',ҽ����Ч NUMBER(1) PATH '//info[@name="ҽ����Ч"]/@value'
,����ʱ�� VARCHAR2(40) PATH '//info[@name="����ʱ��"]/@value',������־ NUMBER(1) PATH '//info[@name="������־"]/@value',����ҽ�� VARCHAR2(80) PATH '//info[@name="����ҽ��"]/@value',ҽ��ְ�� VARCHAR2(20) PATH '//info[@name="ҽ��ְ��"]/@value',ҽ������ VARCHAR2(1000) PATH '//info[@name="ҽ������"]/@value',ҽ������ҩ��ȼ�
NUMBER(1) PATH '//info[@name="ҽ������ҩ��ȼ�"]/@value',��ҩ���� NUMBER(18,5) PATH '//info[@name="��ҩ����"]/@value',���� VARCHAR2(50) PATH '//info[@name="����"]/@value',ҩƷ����ҩ��ȼ� NUMBER(1) PATH '//info[@name="ҩƷ����ҩ��ȼ�"]/@value',������� VARCHAR2(50) PATH '//info[@name="�������"]/@value',����˵��
VARCHAR2(500) PATH '//info[@name="����˵��"]/@value',��ҩĿ�� VARCHAR2(400) PATH '//info[@name="��ҩĿ��"]/@value',ҩƷ����˵�� VARCHAR2(1000) PATH '//info[@name="ҩƷ����˵��"]/@value',ҩƷ���ɵȼ� VARCHAR2(50) PATH '//info[@name="ҩƷ���ɵȼ�"]/@value',ҩƷ�������� VARCHAR2(1000) PATH '//info[@name="ҩƷ��������"]/@value'
,������� VARCHAR2(500) PATH '//info[@name="�������"]/@value',��ҩ;�� VARCHAR2(400) PATH '//info[@name="��ҩ;��"]/@value',��ҩ;������ VARCHAR2(400) PATH '//info[@name="��ҩ;������"]/@value',�������� NUMBER(18,5) PATH '//info[@name="������"]/@value',�������� NUMBER(18,5) PATH '//info[@name="������"]/@value'
,������λ VARCHAR2(50) PATH '//info[@name="������λ"]/@value',��ҩƵ�� VARCHAR2(50) PATH '//info[@name="��ҩƵ������"]/@value',ҽ��״̬ NUMBER(2) PATH '//info[@name="ҽ��״̬"]/@value' ) A
			                WHERE A.ҽ��״̬ = 1
			) LOOP
				UPDATE REVIEWE_RECIPES A
				   SET A.ORDER_STAT = R_ROW.ҽ����Ч,A.ORDER_BABY = N_Ӥ��
				,A.RECIPE_TIME = TO_DATE(
						R_ROW.����ʱ��
						,'yyyy-mm-dd hh24:mi:ss'
					)
				,A.RECIPE_DATE = TO_CHAR(
						TO_DATE(
							R_ROW.����ʱ��
							,'yyyy-mm-dd hh24:mi:ss'
						)
						,'yyyymmdd'
					)
				,A.EMERGENCY = R_ROW.������־
				,A.RECIPE_DR = R_ROW.����ҽ��
				,A.ORDER_GROUP_ID = R_ROW.��Һ���
				,A.RECIPE_DR_TITLE = R_ROW.ҽ��ְ��
				,A.ORDER_COMMENT = R_ROW.ҽ������
				,A.DR_ANTI_LEVEL = R_ROW.ҽ������ҩ��ȼ�
				,A.DRUG_BASE_CODE = R_ROW.��λ��
				,A.DRUG_FORM = R_ROW.����
				,A.DRUG_TIME_INTERVAL = R_ROW.��ҩƵ��
				,A.DRUG_ROUTE = R_ROW.��ҩ;��
				,A.DRUG_ROUTE_NAME = R_ROW.��ҩ;������
				,A.DRUG_ONCE_DOSEAGE = R_ROW.��������
				,A.DRUG_DAY_DOSEAGE = R_ROW.��������
				,A.DRUG_DOSEAGE_UNIT = R_ROW.������λ
				,A.DRUG_USED_DAYS = R_ROW.��ҩ����
				,A.OVER_DOSEAGE_REASON = R_ROW.����˵��
				,A.DRUG_TOXICITY = R_ROW.�������
				,A.DRUG_ANTI_LEVEL = R_ROW.ҩƷ����ҩ��ȼ�
				,A.ANTI_DRUG_REASON = R_ROW.��ҩĿ��
				,A.HIS_NO = N_HIS_NO
				,A.RECIPE_DIAG = R_ROW.�������
				,A.RECEIVE_TIME = T_��ǰʱ��
				,A.Receive_Date=to_char(T_��ǰʱ��,'yyyymmdd')
				,A.REVIEWE_NORMAL_TIME = T_��ǰʱ�� + N_�Զ�ʱ���� / 24 / 60
				,A.REVIEWE_RESULT =-2 
        -- 
				,A.PHARMACIST = ''
				,A.PHARMACIST_ID = ''
				,A.REVIEWE_TIME = ''
				,A.PHARMACIST_RECEIVE_TIME = ''
				,A.REVIEWE_COMMENT = ''
				,A.DR_REFUSE = ''
				,A.DR_REFUSE_COMMENT = ''
				,A.DR_REFUSE_TIME = ''
               -- ����������Դ ������ҩ
				,A.DRUG_CONTRA_LEVEL = R_ROW.ҩƷ���ɵȼ�
				,A.DRUG_CONTRA_TYPE = R_ROW.ҩƷ��������
				,A.DRUG_CONTRA_COMMENT = R_ROW.ҩƷ����˵��
				 WHERE ORDER_ID = R_ROW.ҽ��ID;
				IF SQL%FOUND = FALSE THEN
          -- ��� ����update ������ ���ʾ����ͬҽ��ID�ļ�¼ ����в��������
					INSERT   INTO REVIEWE_RECIPES (
						PID
						,PVID
						,ORDER_STAT
						,ORDER_ID
						,ORDER_BABY
						,RECIPE_TIME
						,RECIPE_DATE
						,EMERGENCY
						,RECIPE_DR
						,RECIPE_DR_TITLE
						,ORDER_COMMENT
						,DR_ANTI_LEVEL
						,DRUG_BASE_CODE
						,DRUG_FORM
						,DRUG_TIME_INTERVAL
						,DRUG_ROUTE
						,DRUG_ROUTE_NAME
						,DRUG_ONCE_DOSEAGE
						,DRUG_DAY_DOSEAGE
						,DRUG_DOSEAGE_UNIT
						,DRUG_USED_DAYS
						,OVER_DOSEAGE_REASON
						,DRUG_TOXICITY
						,DRUG_ANTI_LEVEL
						,ANTI_DRUG_REASON
						,HIS_NO
						,RECIPE_DIAG
						,RECEIVE_TIME
						,Receive_Date
						,REVIEWE_NORMAL_TIME
						,REVIEWE_RESULT
						,DRUG_CONTRA_LEVEL
						,DRUG_CONTRA_TYPE
						,DRUG_CONTRA_COMMENT
						,ORDER_GROUP_ID
					) VALUES (
						N_PID
						,N_PVID
						,R_ROW.ҽ����Ч
						,R_ROW.ҽ��ID
						,N_Ӥ��
						,TO_DATE(
							R_ROW.����ʱ��
							,'yyyy-mm-dd hh24:mi:ss'
						)
						,TO_CHAR(
							TO_DATE(
								R_ROW.����ʱ��
								,'yyyy-mm-dd hh24:mi:ss'
							)
							,'yyyymmdd'
						)
						,R_ROW.������־
						,R_ROW.����ҽ��
						,R_ROW.ҽ��ְ��
						,R_ROW.ҽ������
						,R_ROW.ҽ������ҩ��ȼ�
						,R_ROW.��λ��
						,R_ROW.����
						,R_ROW.��ҩƵ��
						,R_ROW.��ҩ;��
						,R_ROW.��ҩ;������
						,R_ROW.��������
						,R_ROW.��������
						,R_ROW.������λ
						,R_ROW.��ҩ����
						,R_ROW.����˵��
						,R_ROW.�������
						,R_ROW.ҩƷ����ҩ��ȼ�
						,R_ROW.��ҩĿ��
						,N_HIS_NO
						,R_ROW.�������
						,T_��ǰʱ��
						,to_char(T_��ǰʱ��,'yyyymmdd')
						,T_��ǰʱ�� + N_�Զ�ʱ���� / 24 / 60
						,-2
						,R_ROW.ҩƷ���ɵȼ�
						,R_ROW.ҩƷ��������
						,R_ROW.ҩƷ����˵��
						,R_ROW.��Һ���
					);
          -- i_���� ��¼������������  
					N_����_RECIPE   := N_����_RECIPE + 1;
				ELSE
          --��¼�޸���������
					N_�޸�_RECIPE   := N_�޸�_RECIPE + 1;
				END IF;
				IF C_ORDER_ID IS NULL THEN
					C_ORDER_ID   := C_ORDER_ID || R_ROW.ҽ��ID;
				ELSE
					C_ORDER_ID   := C_ORDER_ID || ',' || R_ROW.ҽ��ID;
				END IF;
  
			END LOOP;
		END IF;

    -- ���� �󷽷�������

		REVIEWE_SOLUTION_RUN(
			C_ORDER_ID
			,N_PID
			,N_PVID
			,TO_CHAR(
				SYSDATE
				,'yyyymmdd'
			)
		);
		SEND_MESSAGE_TO_ZLHIS(
			N_PID
			,N_PVID
			,1
		);

	EXCEPTION
		WHEN OTHERS THEN
			PKG_RECIPE_REVIEWE.INSERT_LOG(
				'Receive_recipes'
				,'E'
				,PRESCRIPTION || CHR(10) || SQLERRM
			);
	END RECEIVE_RECIPES;

  -- �ӵ�����������
	PROCEDURE ORDER_RECEIVING (
		USER_ID       IN VARCHAR2
		,P_TYPE_IN     IN NUMBER
		,ORDER_SCOPE   IN NUMBER
		,OUTPUT_OUT    OUT CLOB
	) IS
    --ͷע�Ϳ�ʼ-----------------------------------------------------------------------------------------
    --�������ƣ��ӵ�
    --����˵��������ϸں󣬷����������,ˢ������
    --���˵��������ҩʦid ,�ӵ����� 1-���� 2-סԺ�� �ӵ���Χ order_Scope(�Ƿ�������������ҵĵ������� ���Ҷ�Ӧ��Ա��) 1-��  0-��
    --����˵�������� ��ҩʦ��Ӧ��Ҫ�������pid��pvid��
    --�� д �ߣ��⿪��
    --��дʱ�䣺2018-06-11
    --�汾��¼���汾��+ʱ��+�޸���+�޸���������
    --ͷע�ͽ���-----------------------------------------------------------------------------------------   
		C_���䲡����Ϣ_OUT    CLOB;
		V_USER_NAME     VARCHAR2(20);
		N_PID           NUMBER(18);
		N_PVID          NUMBER(18);
		N_COUNT         NUMBER(1);
		V_��˷�Χ          VARCHAR2(20);
		N_���ڴ�������        NUMBER(18);
		N_�Ƿ����ѭ��        NUMBER(18);
		N_ORDER_SCOPE   NUMBER(1);
		T_��ǰʱ��          DATE;
	BEGIN
		N_PID          := 12;
		N_PVID         := 55;
		V_USER_NAME    := '';
		C_���䲡����Ϣ_OUT   := '';
		T_��ǰʱ��         := SYSDATE;
    -- ͨ�������user_id��ȡ user_name
		SELECT MAX(USER_NAME)
		  INTO V_USER_NAME
		  FROM RECIPE_USER A
		 WHERE A.USER_CODE = UPPER(USER_ID)
		   AND A.USER_STATUS = 1;
  
    --��������󴦷����Ѿ��и�ҩʦ����������򷵻ظ�pid��pvid  
		SELECT COUNT(1)
		  INTO N_���ڴ�������
		  FROM WAIT_REVIEWE_RECIPE A
		      ,RECIPE_PATIENT_INFO B
		 WHERE A.PHARMACIST_ID = USER_ID
		   AND A.PID = B.PID
		   AND A.PVID = B.PVID
		   AND B.P_TYPE = P_TYPE_IN;
    -- ��ȡ���󴦷� ��ҽ������ʱ���������У�ȡʱ����С����һ��
  
    -- �� USER_ID �Ƿ��Ѵ��ڴ�������
		IF N_���ڴ������� = 0 THEN
      -- �ж� ���ҩʦ ��Ӧ�Ŀ����Ƿ�Ϊ�գ����Ϊ�� �����п��Ҳ��˶������ ,��Ϊ�� ��õ������ַ��� 
			SELECT
				LISTAGG(A.DEPT_ID
				,',') WITHIN  GROUP(
					 ORDER BY A.DEPT_ID
				)
			  INTO V_��˷�Χ
			  FROM PHARMACIST_REVIEWE_DEPT A
			 WHERE A.USER_CODE = UPPER(USER_ID)
			   AND A.RELATION_STATUS = 1;
    
      -- order_Scope 1-���Խ����п��ҵ�
			N_ORDER_SCOPE   := ORDER_SCOPE;
			IF N_ORDER_SCOPE = 1 THEN
				V_��˷�Χ   := '';
			END IF;
			N_�Ƿ����ѭ��        := 0;
    
      -- if v_��˷�Χ is null then 
      -- ���п��Ҷ������
			WHILE
				N_�Ƿ����ѭ�� = 0
			LOOP
				SELECT MAX(PID)
				      ,MAX(PVID)
				  INTO
					N_PID
				,N_PVID
				  FROM ( SELECT A.PID
				               ,A.PVID
				           FROM WAIT_REVIEWE_RECIPE A
				               ,RECIPE_PATIENT_INFO B
				          WHERE A.PID = B.PID
				   AND A.PVID = B.PVID
				   AND B.P_TYPE = P_TYPE_IN
				   AND (
					A.P_DEPT_ID IN (
						V_��˷�Χ
					)
					    OR V_��˷�Χ IS NULL
				)
                 -- b.p_type=1 ��� 2-סԺ
				   AND A.REVIEWE_NORMAL_TIME > SYSDATE
				   AND A.PHARMACIST_ID IS NULL
                 -- �������ʱ��>sysdate ������Ҫ���ʱ�䷶Χ��
				 ORDER BY A.RECEIVE_TIME )
				 WHERE ROWNUM = 1;
        -- �����ò��˴�������USER_ID ���
				UPDATE WAIT_REVIEWE_RECIPE B
				   SET B.PHARMACIST_ID = USER_ID,B.PHARMACIST = V_USER_NAME
				,B.PHARMACIST_RECEIVE_TIME = T_��ǰʱ��
				 WHERE B.PID = N_PID
				   AND B.PVID = N_PVID
				   AND PHARMACIST_ID IS NULL;
        --�������sqlִ�гɹ������ʾ�Ѿ����� �˳�ѭ��         
				IF SQL%FOUND = TRUE THEN
          --���´������е�״̬ ��Ϊ����� 2
					UPDATE REVIEWE_RECIPES C
					   SET C.REVIEWE_RESULT = 2,C.PHARMACIST_RECEIVE_TIME = T_��ǰʱ��
					 WHERE C.PID = N_PID
					   AND C.PVID = N_PVID
					   AND C.REVIEWE_RESULT = 0;
					N_�Ƿ����ѭ��   := 1;
				END IF;
				IF N_PID IS NULL THEN
					N_�Ƿ����ѭ��   := 1;
				END IF;
			END LOOP;
			IF N_PID IS NOT NULL    AND N_PVID IS NOT NULL THEN
				C_���䲡����Ϣ_OUT   := '{' || '"' || 'pid' || '"' || ':' || N_PID || ',' || '"' || 'pvid' || '"' || ':' || N_PVID || '}';
			END IF;
		ELSE
			SELECT MAX(A.PID)
			      ,MAX(A.PVID)
			  INTO
				N_PID
			,N_PVID
			  FROM WAIT_REVIEWE_RECIPE A
			      ,RECIPE_PATIENT_INFO B
			 WHERE A.PHARMACIST_ID = USER_ID
			   AND A.PID = B.PID
			   AND A.PVID = B.PVID
			   AND B.P_TYPE = P_TYPE_IN;
			C_���䲡����Ϣ_OUT   := '{' || '"' || 'pid' || '"' || ':' || N_PID || ',' || '"' || 'pvid' || '"' || ':' || N_PVID || '}';
		END IF;
		OUTPUT_OUT     := C_���䲡����Ϣ_OUT;
	EXCEPTION
		WHEN OTHERS THEN
			NULL;
      --zl_ErrorCenter(SQLCode, SQLErrM);
	END ORDER_RECEIVING;

  -- ��鳬ʱ����˴���
	PROCEDURE TIMEOUT_REVIEWE IS
    --ͷע�Ϳ�ʼ-----------------------------------------------------------------------------------------
  
    --�������ƣ���鳬ʱ����˴���
  
    --����˵����������˴����У���ʱ���Զ����
  
    --���˵����
  
    --����˵����
  
    --�� д �ߣ��޺�
  
    --��дʱ�䣺2018-06-13
  
    --�汾��¼���汾��+ʱ��+�޸���+�޸���������
  
    --ͷע�ͽ���-----------------------------------------------------------------------------------------
		V_TIME           DATE;
		N_WAIT_REVIEWE   NUMBER(18);
	BEGIN
		V_TIME   := SYSDATE;
    -- ��ɾ�� ������еļ�¼����ҩʦ������ˣ�
  
    --ɾ�������У�δ�ӵ��ĳ�ʱ��¼
		FOR P IN ( SELECT PID
		                 ,PVID
		                 ,COUNT(*) ROWCOUNT
		             FROM WAIT_REVIEWE_RECIPE B
		            WHERE B.REVIEWE_NORMAL_TIME <= V_TIME
		   AND B.PHARMACIST IS NULL
		   AND B.PHARMACIST_ID IS NULL
		            GROUP BY PID
		                    ,PVID
		) LOOP
      --ɾ�����󴦷�
			DELETE WAIT_REVIEWE_RECIPE B
			 WHERE B.PID = P.PID
			   AND B.PVID = P.PVID
			   AND B.REVIEWE_NORMAL_TIME <= V_TIME
			   AND B.PHARMACIST IS NULL;
    
      --�Ѵ�������δ�ӵ��Ĵ��� ����Ϊ��ʱͨ��
			UPDATE REVIEWE_RECIPES A
			   SET A.REVIEWE_RESULT = 22,A.REVIEWE_TIME = V_TIME
			 WHERE A.PID = P.PID
			   AND A.PVID = P.PVID
			   AND (
				A.REVIEWE_RESULT =-2
				    OR A.REVIEWE_RESULT = 0
			);
      --��鲡���Ƿ��д���ҽ��
			SELECT COUNT(*)
			  INTO N_WAIT_REVIEWE
			  FROM WAIT_REVIEWE_RECIPE B
			 WHERE B.PID = P.PID
			   AND B.PVID = P.PVID;
			IF N_WAIT_REVIEWE IS NULL     OR N_WAIT_REVIEWE = 0 THEN
        --û�д���ҽ����֪ͨHIS��������˵��󷽽��
				SEND_MESSAGE_TO_ZLHIS(
					P.PID
					,P.PVID
					,1
				);
			END IF;
		END LOOP;
	END TIMEOUT_REVIEWE;

  --�༭��˷���
	PROCEDURE EDIT_REVIEWE_SOLUTION (
		INPUT_IN       IN CLOB
		,EDIT_TYPE_IN   IN NUMBER
	)
		AS
    --ͷע�Ϳ�ʼ-----------------------------------------------------------------------------------------
    --�������ƣ��༭��˷���
    --����˵�����༭��˷���
    --���˵����Input_In{"reviewe_solution_id":"","reviewe_solution_name":"","last_editor":"","last_edit_time":"","reviewe_solution_type":"","reviews_solution_status":""}
    --         Edit_Type_In (0 �޸�, 1 ����, -1 ɾ��)
    --����˵����
    --�� д �ߣ�����
    --��дʱ�䣺2018-06-29
    --�汾��¼���汾��+ʱ��+�޸���+�޸���������
    --ͷע�ͽ���-----------------------------------------------------------------------------------------
	BEGIN
		IF DBMS_LOB.GETLENGTH(INPUT_IN) <> 0 THEN
			IF EDIT_TYPE_IN = 1 THEN
				INSERT_REVIEWE_SOLUTION(INPUT_IN);
			ELSIF EDIT_TYPE_IN = 0 THEN
				UPD_REVIEWE_SOLUTION(INPUT_IN);
			ELSIF EDIT_TYPE_IN =-1 THEN
				DEL_REVIEWE_SOLUTION(INPUT_IN);
			END IF;
		END IF;
	END EDIT_REVIEWE_SOLUTION;
  
  --�༭��˷�����ϸ
	PROCEDURE EDIT_REVIEWE_SOLUTION_DETAIL (
		INPUT_IN       IN CLOB
		,EDIT_TYPE_IN   IN NUMBER
	)
		AS
    --ͷע�Ϳ�ʼ-----------------------------------------------------------------------------------------
    --�������ƣ��༭��˷�����ϸ
    --����˵�����༭��˷�����ϸ
    --���˵����Input_In{"reviewe_solution_id":"","reviewe_solution_name":"","last_editor":"","last_edit_time":"","reviewe_solution_type":"","reviews_solution_status":""}
    --         Edit_Type_In (0 �޸�, 1 ����, -1 ɾ��)
    --����˵����
    --�� д �ߣ�����
    --��дʱ�䣺2018-07-02
    --�汾��¼���汾��+ʱ��+�޸���+�޸���������
    --ͷע�ͽ���-----------------------------------------------------------------------------------------
	BEGIN
		IF DBMS_LOB.GETLENGTH(INPUT_IN) <> 0 THEN
			IF EDIT_TYPE_IN = 1 THEN
				INSERT_REVIEWE_SOLUTION_DETAIL(INPUT_IN);
			ELSIF EDIT_TYPE_IN = 0 THEN
				UPD_REVIEWE_SOLUTION_DETAIL(INPUT_IN);
			ELSIF EDIT_TYPE_IN =-1 THEN
				DEL_REVIEWE_SOLUTION_DETAIL(INPUT_IN);
			END IF;
		END IF;
	END EDIT_REVIEWE_SOLUTION_DETAIL;
  
  -----------------ATOM------------------------------------------
  --����ҩʦ������¼
	PROCEDURE INSERT_PHARMACIST_WORK_RECORD (
		INPUT_IN IN CLOB
	)
		AS
    --ͷע�Ϳ�ʼ-----------------------------------------------------------------------------------------
    --�������ƣ�����ҩʦ������¼
    --����˵��������ҩʦ������¼
    --���˵����{"pharmacist":"","pharmacist_id":"","register_time":"","register_date":"","unregister_time":"","last_reviewe_time":""}
    --����˵����
    --�� д �ߣ�����
    --��дʱ�䣺2018-06-06
    --�汾��¼���汾��+ʱ��+�޸���+�޸���������
    --ͷע�ͽ���-----------------------------------------------------------------------------------------
	BEGIN
		IF DBMS_LOB.GETLENGTH(INPUT_IN) <> 0 THEN
			INSERT   INTO PHARMACIST_WORK_RECORD (
				PHARMACIST
				,PHARMACIST_ID
				,REGISTER_TIME
				,REGISTER_DATE
				,UNREGISTER_TIME
			)
				SELECT PHARMACIST
				      ,PHARMACIST_ID
				      ,TO_DATE(
					REGISTER_TIME
					,'yyyy-mm-dd hh24:mi:ss'
				)
				      ,REGISTER_DATE
				      ,TO_DATE(
					UNREGISTER_TIME
					,'yyyy-mm-dd hh24:mi:ss'
				)
				  FROM
					JSON_TABLE ( INPUT_IN,'$'
						COLUMNS (
							PHARMACIST VARCHAR2 ( 80 ) PATH '$."pharmacist"'
						,PHARMACIST_ID VARCHAR2 ( 18 ) PATH '$."pharmacist_id"'
						,REGISTER_TIME VARCHAR2 ( 20 ) PATH '$."register_time"'
						,REGISTER_DATE VARCHAR2 ( 8 ) PATH '$."register_date"'
						,UNREGISTER_TIME VARCHAR2 ( 20 ) PATH '$."unregister_time"'
						)
					);
		END IF;
	END INSERT_PHARMACIST_WORK_RECORD;

  --�޸�ҩʦ������¼(�����������¸ڲ���)
	PROCEDURE UPD_PHARMACIST_WORK_RECORD (
		INPUT_IN IN CLOB
	)
		AS
    --ͷע�Ϳ�ʼ-----------------------------------------------------------------------------------------
    --�������ƣ��޸�ҩʦ������¼
    --����˵�����޸�ҩʦ������¼
    --���˵����{"pharmacist":"","pharmacist_id":"","register_time":"","register_date":"","unregister_time":"","last_reviewe_time":""}
    --����˵����
    --�� д �ߣ�����
    --��дʱ�䣺2018-06-06
    --�汾��¼���汾��+ʱ��+�޸���+�޸���������
    --ͷע�ͽ���-----------------------------------------------------------------------------------------
	BEGIN
		IF DBMS_LOB.GETLENGTH(INPUT_IN) <> 0 THEN
			FOR I IN ( SELECT PHARMACIST
			                 ,PHARMACIST_ID
			                 ,TO_DATE(
				REGISTER_TIME
				,'yyyy-mm-dd hh24:mi:ss'
			) REGISTER_TIME
			                 ,REGISTER_DATE
			                 ,TO_DATE(
				UNREGISTER_TIME
				,'yyyy-mm-dd hh24:mi:ss'
			) UNREGISTER_TIME
			                 ,TO_DATE(
				LAST_REVIEWE_TIME
				,'yyyy-mm-dd hh24:mi:ss'
			) LAST_REVIEWE_TIME
			             FROM
				JSON_TABLE ( INPUT_IN,'$'
					COLUMNS (
						PHARMACIST VARCHAR2 ( 80 ) PATH '$."pharmacist"'
					,PHARMACIST_ID VARCHAR2 ( 18 ) PATH '$."pharmacist_id"'
					,REGISTER_TIME VARCHAR2 ( 20 ) PATH '$."register_time"'
					,REGISTER_DATE VARCHAR2 ( 8 ) PATH '$."register_date"'
					,UNREGISTER_TIME VARCHAR2 ( 20 ) PATH '$."unregister_time"'
					,LAST_REVIEWE_TIME VARCHAR2 ( 20 ) PATH '$."last_reviewe_time"'
					)
				)
			) LOOP
				UPDATE PHARMACIST_WORK_RECORD
				   SET PHARMACIST = I.PHARMACIST,REGISTER_TIME = I.REGISTER_TIME
				,REGISTER_DATE = I.REGISTER_DATE
				,UNREGISTER_TIME = I.UNREGISTER_TIME
				 WHERE PHARMACIST_ID = I.PHARMACIST_ID
				   AND REGISTER_TIME >= TRUNC(SYSDATE)
				   AND UNREGISTER_TIME IS NULL;
			END LOOP;
		END IF;
	END UPD_PHARMACIST_WORK_RECORD;

-- ҩʦ���ҷ�������
	PROCEDURE UPD_PHARMACIST_REVIEWE_DEPT (
		DEPT_ID               IN CLOB
		,USER_ID               IN VARCHAR2
		,V_CURRENT_USER_CODE   IN VARCHAR2
	) IS
    --ͷע�Ϳ�ʼ-----------------------------------------------------------------------------------------
    --�������ƣ�Upd_pharmacist_reviewe_dept
    --����˵����-- ҩʦ��Ӧ���ҷ�������
    --���˵���� -- user_id Ϊ�����ϻ�ȡ�� ��ǰ���ָ����û�ID��dept_name �������ƴ�  ��һ�ƣ��ڶ��ƣ�...
    --����˵����
    --�� д �ߣ��⿪��
    --��дʱ�䣺2018-06-27
    --�汾��¼���汾��+ʱ��+�޸���+�޸���������
    --ͷע�ͽ���-----------------------------------------------------------------------------------------
		V_DEPT_ID   VARCHAR2(500);
		V_��ǰʱ��      DATE;
		V_���༭��     VARCHAR2(80);
	BEGIN
		V_DEPT_ID   := ',' || REPLACE(
			DEPT_ID
			,':'
			,','
		) || ',';
		V_��ǰʱ��      := SYSDATE;
 -- ��ѯ��ǰ�û����� ��Ӧ���
		SELECT MAX(USER_NAME)
		  INTO V_���༭��
		  FROM RECIPE_USER
		 WHERE USER_CODE = V_CURRENT_USER_CODE;

 --ɾ�����û��Ŀ��Ҷ�Ӧ���ݣ��ٲ������µ���������
		DELETE   FROM PHARMACIST_REVIEWE_DEPT A
		 WHERE A.USER_CODE = UPPER(USER_ID);
		FOR I IN ( SELECT A.ID ����ID
		                 ,A.���� ��������
		             FROM ���ű�@TO_ZLHIS A
		            WHERE INSTR(
			V_DEPT_ID
			,',' || A.ID || ','
		) > 0
		) LOOP
			INSERT   INTO PHARMACIST_REVIEWE_DEPT VALUES (
				USER_ID
				,I.����ID
				,I.��������
				,V_���༭��
				,V_��ǰʱ��
				,1
			);
		END LOOP;
	EXCEPTION
		WHEN OTHERS THEN
			NULL;
    --zl_ErrorCenter(SQLCode, SQLErrM);
	END UPD_PHARMACIST_REVIEWE_DEPT;

--����ҩʦ/�޸�ҩʦ ����
	PROCEDURE UPD_RECIPE_USER (
		V_CURRENT_USER_NAME   IN VARCHAR2
		,V_USER_CODE           IN VARCHAR2
		,V_USER_NAME           IN VARCHAR2
		,V_USER_JOB            IN VARCHAR2
		,V_USER_STATUS         IN NUMBER
		,N_CHANGE              NUMBER
		,V_WEB_PASSWORD        IN VARCHAR2
		,N_IS_ADMIN            NUMBER
	) IS
    --ͷע�Ϳ�ʼ-----------------------------------------------------------------------------------------
    --�������ƣ�Upd_recipe_user
    --����˵��������ҩʦ/�޸�ҩʦ ����
    --���˵����V_Current_USER_NAME ��ǰ������Ա���ƣ�V_USER_CODE ��Ӧ HIS �ϻ���Ա�� ���û���  ��N_CHANGE 1-������2-�޸�
    --����˵����
    --�� д �ߣ��⿪��
    --��дʱ�䣺2018-06-27
    --�汾��¼���汾��+ʱ��+�޸���+�޸���������
    --ͷע�ͽ���-----------------------------------------------------------------------------------------
		T_��ǰʱ��   DATE;
	BEGIN
      
		T_��ǰʱ��   := SYSDATE;
		IF V_USER_NAME IS NOT NULL    AND V_USER_CODE IS NOT NULL THEN
			IF N_CHANGE = 1 THEN
      -- ����ҩʦ   
				INSERT   INTO RECIPE_USER (
					USER_CODE
					,USER_NAME
					,REGISTER_TIME
					,LAST_EDITOR
					,LAST_EDIT_TIME
					,USER_JOB
					,USER_STATUS
					,IS_ADMIN
				) VALUES (
					UPPER(V_USER_CODE)
					,V_USER_NAME
					,T_��ǰʱ��
					,V_CURRENT_USER_NAME
					,T_��ǰʱ��
					,DECODE(
						V_USER_JOB
						,1
						,'ҩʦ'
						,2
						,'����ҩʦ'
						,3
						,'������ҩʦ'
						,4
						,'����ҩʦ'
					)
					,V_USER_STATUS
					,N_IS_ADMIN
				);
        --���� create_user ͬʱ����apex��¼�˻�
				CREATE_USER(
					V_USER_CODE
					,V_WEB_PASSWORD
					,V_USER_STATUS
          ,N_IS_ADMIN
				);
			ELSIF N_CHANGE = 2 THEN
       -- �޸�ҩʦ 
				UPDATE RECIPE_USER
				   SET LAST_EDITOR = V_CURRENT_USER_NAME,LAST_EDIT_TIME = T_��ǰʱ��
				,USER_JOB = DECODE(
						V_USER_JOB
						,1
						,'ҩʦ'
						,2
						,'����ҩʦ'
						,3
						,'������ҩʦ'
						,4
						,'����ҩʦ'
					)
				,USER_STATUS = V_USER_STATUS
				,IS_ADMIN = N_IS_ADMIN
				 WHERE USER_CODE = UPPER(V_USER_CODE)
				   AND USER_NAME = V_USER_NAME;
        --���� edit_user ͬʱ�޸�apex��¼�˻�   
				EDIT_USER(
					V_USER_CODE
					,V_USER_STATUS
          ,N_IS_ADMIN
				);
			END IF;
		END IF;
	EXCEPTION
		WHEN OTHERS THEN
			NULL;
    --zl_ErrorCenter(SQLCode, SQLErrM);
	END UPD_RECIPE_USER;
  
--���� apec ҩʦ�û�
	PROCEDURE CREATE_USER (
		V_USER_ID        IN VARCHAR2
		,V_WEB_PASSWORD   IN VARCHAR2
		,N_STATUS_IN      IN NUMBER
    ,N_ADMIN          IN NUMBER
	) IS
-- ����ҩʦ
--user_id  his �û�id
--V_USER_CODE ��Ӧ HIS �û��ļ���
		V_STATUS          VARCHAR2(10);
		V_WORKSPACE_ID    VARCHAR2(50);
		V_DEFAULT_SCHEM   VARCHAR2(50);
    V_P_DEVELOPER_PRIVS VARCHAR2(200);
	BEGIN
		V_DEFAULT_SCHEM   := 'zlrecipe';
		V_WORKSPACE_ID    := APEX_UTIL.FIND_SECURITY_GROUP_ID(P_WORKSPACE   => 'ZLAPEXDEV');
		APEX_UTIL.SET_SECURITY_GROUP_ID(P_SECURITY_GROUP_ID   => V_WORKSPACE_ID);
		SELECT DECODE(
			N_STATUS_IN
			,0
			,'Y'
			,1
			,'N'
		)
		  INTO V_STATUS
		  FROM DUAL;
    --�ж������Ƿ��ǹ���Ա
    if N_ADMIN=1 then
      --�ǹ���Ա
      V_P_DEVELOPER_PRIVS:='ADMIN:CREATE:DATA_LOADER:EDIT:HELP:MONITOR:SQL' ;
      else
      --���ǹ���Ա  
      V_P_DEVELOPER_PRIVS :='' ;
    end if; 
    
		APEX_UTIL.CREATE_USER(
  -- P_USER_NAME ���� recipe_user.user_code
			P_USER_NAME        => V_USER_ID
			,P_WEB_PASSWORD     => V_WEB_PASSWORD
			,P_DEFAULT_SCHEMA   => V_DEFAULT_SCHEM
      ,p_developer_privs => V_P_DEVELOPER_PRIVS
			,P_ACCOUNT_LOCKED   => V_STATUS
		);
	EXCEPTION
		WHEN OTHERS THEN
			NULL;
    --zl_ErrorCenter(SQLCode, SQLErrM);
	END CREATE_USER;

-- �޸���Ա apex�û� 
	PROCEDURE EDIT_USER (
		P_USER_NAME   IN VARCHAR2
		,STATUS        IN NUMBER
    ,N_ADMIN      IN NUMBER
	) IS
-- ����ҩʦ����
--user_id  his �û�id

		V_STATUS                         VARCHAR2(10);
		L_USER_ID                        NUMBER;
		L_WORKSPACE                      VARCHAR2(255);
		L_USER_NAME                      VARCHAR2(100);
		L_FIRST_NAME                     VARCHAR2(255);
		L_LAST_NAME                      VARCHAR2(255);
		L_WEB_PASSWORD                   VARCHAR2(255);
		L_EMAIL_ADDRESS                  VARCHAR2(240);
		L_START_DATE                     DATE;
		L_END_DATE                       DATE;
		L_EMPLOYEE_ID                    NUMBER(
			15
			,0
		);
		L_ALLOW_ACCESS_TO_SCHEMAS        VARCHAR2(4000);
		L_PERSON_TYPE                    VARCHAR2(1);
		L_DEFAULT_SCHEMA                 VARCHAR2(30);
		L_GROUPS                         VARCHAR2(1000);
		L_DEVELOPER_ROLE                 VARCHAR2(200);
		L_DESCRIPTION                    VARCHAR2(240);
		L_ACCOUNT_EXPIRY                 DATE;
		L_ACCOUNT_LOCKED                 VARCHAR2(1);
		L_FAILED_ACCESS_ATTEMPTS         NUMBER;
		L_CHANGE_PASSWORD_ON_FIRST_USE   VARCHAR2(1);
		L_FIRST_PASSWORD_USE_OCCURRED    VARCHAR2(1);
    
    V_WORKSPACE_ID                   number;
	BEGIN 
		SELECT DECODE(
			STATUS
			,0
			,'Y'
			,1
			,'N'
		)
		  INTO V_STATUS
		  FROM DUAL;
      
     --��ȡ L_USER_ID
    V_WORKSPACE_ID    := APEX_UTIL.FIND_SECURITY_GROUP_ID(P_WORKSPACE   => 'ZLAPEXDEV');
		APEX_UTIL.SET_SECURITY_GROUP_ID(P_SECURITY_GROUP_ID   => V_WORKSPACE_ID);
		L_USER_ID   := APEX_UTIL.GET_USER_ID(P_USER_NAME);
		APEX_UTIL.FETCH_USER(
			P_USER_ID                        => L_USER_ID
			,P_WORKSPACE                      => L_WORKSPACE
			,P_USER_NAME                      => L_USER_NAME
			,P_FIRST_NAME                     => L_FIRST_NAME
			,P_LAST_NAME                      => L_LAST_NAME
			,P_WEB_PASSWORD                   => L_WEB_PASSWORD
			,P_EMAIL_ADDRESS                  => L_EMAIL_ADDRESS
			,P_START_DATE                     => L_START_DATE
			,P_END_DATE                       => L_END_DATE
			,P_EMPLOYEE_ID                    => L_EMPLOYEE_ID
			,P_ALLOW_ACCESS_TO_SCHEMAS        => L_ALLOW_ACCESS_TO_SCHEMAS
			,P_PERSON_TYPE                    => L_PERSON_TYPE
			,P_DEFAULT_SCHEMA                 => L_DEFAULT_SCHEMA
			,P_GROUPS                         => L_GROUPS
			,P_DEVELOPER_ROLE                 => L_DEVELOPER_ROLE
			,P_DESCRIPTION                    => L_DESCRIPTION
			,P_ACCOUNT_EXPIRY                 => L_ACCOUNT_EXPIRY
			,P_ACCOUNT_LOCKED                 => L_ACCOUNT_LOCKED
			,P_FAILED_ACCESS_ATTEMPTS         => L_FAILED_ACCESS_ATTEMPTS
			,P_CHANGE_PASSWORD_ON_FIRST_USE   => L_CHANGE_PASSWORD_ON_FIRST_USE
			,P_FIRST_PASSWORD_USE_OCCURRED    => L_FIRST_PASSWORD_USE_OCCURRED
		);
       --�ж��Ƿ��ǹ���Ա    
    if N_ADMIN=1 then
      --�ǹ���Ա
      L_DEVELOPER_ROLE:='ADMIN:CREATE:DATA_LOADER:EDIT:HELP:MONITOR:SQL' ;
      else
      --���ǹ���Ա  
      L_DEVELOPER_ROLE :='' ;
    end if; 
		APEX_UTIL.EDIT_USER(
			P_USER_ID                        => L_USER_ID
			,P_USER_NAME                      => P_USER_NAME
			,P_FIRST_NAME                     => L_FIRST_NAME
			,P_LAST_NAME                      => L_LAST_NAME
			,P_WEB_PASSWORD                   => L_WEB_PASSWORD
			,P_NEW_PASSWORD                   => L_WEB_PASSWORD
			,P_EMAIL_ADDRESS                  => L_EMAIL_ADDRESS
			,P_START_DATE                     => L_START_DATE
			,P_END_DATE                       => L_END_DATE
			,P_EMPLOYEE_ID                    => L_EMPLOYEE_ID
			,P_ALLOW_ACCESS_TO_SCHEMAS        => L_ALLOW_ACCESS_TO_SCHEMAS
			,P_PERSON_TYPE                    => L_PERSON_TYPE
			,P_DEFAULT_SCHEMA                 => L_DEFAULT_SCHEMA
			,P_GROUP_IDS                      => L_GROUPS
			,P_DEVELOPER_ROLES                => L_DEVELOPER_ROLE
			,P_DESCRIPTION                    => L_DESCRIPTION
			,P_ACCOUNT_EXPIRY                 => L_ACCOUNT_EXPIRY
			,P_ACCOUNT_LOCKED                 => V_STATUS
			,P_FAILED_ACCESS_ATTEMPTS         => L_FAILED_ACCESS_ATTEMPTS
			,P_CHANGE_PASSWORD_ON_FIRST_USE   => L_CHANGE_PASSWORD_ON_FIRST_USE
			,P_FIRST_PASSWORD_USE_OCCURRED    => L_FIRST_PASSWORD_USE_OCCURRED
		);
	EXCEPTION
		WHEN OTHERS THEN
			NULL;
    --zl_ErrorCenter(SQLCode, SQLErrM);
	END EDIT_USER;

--������������
	PROCEDURE DEPT_START (
		DEPT_NAME_IN   IN VARCHAR2
		,USER_NAME_IN   IN VARCHAR2
	) IS --DEPT_STATUS number,
    --ͷע�Ϳ�ʼ-----------------------------------------------------------------------------------------
    --�������ƣ�Upd_recipe_user
    --����˵��������ҩʦ/�޸�ҩʦ ����
    --���˵�������뵱ǰ������Ա NAME ����ѡ����ID    148��252��354
    --����˵����
    --�� д �ߣ��⿪��
    --��дʱ�䣺2018-06-27
    --�汾��¼���汾��+ʱ��+�޸���+�޸���������
    --ͷע�ͽ���-----------------------------------------------------------------------------------------
		V_DEPT_ID   VARCHAR2(500);
		V_��ǰʱ��      DATE;
	BEGIN
   /* V_DEPT_ID   := ',' || REPLACE(
      DEPT_ID
   ,':'
   ,','
    ) || ',';*/
		V_��ǰʱ��   := SYSDATE;
		PKG_RECIPE_REVIEWE.INSERT_LOG(
			LOG_TITILE_IN    => '��������'
			,LOG_TYPE_IN      => 'T'
			,LOG_CONTENT_IN   => DEPT_NAME_IN || USER_NAME_IN || DEPT_NAME_IN
		);
   -- DELETE   FROM REVIEWE_DEPT;
		FOR I IN ( SELECT A.ID ����ID
		                 ,A.���� ��������
		             FROM ���ű�@TO_ZLHIS A
		            WHERE --a.id in (v_dept_id) 
		            INSTR(
			DEPT_NAME_IN
			,',' || A.���� || ','
		) > 0
		) LOOP
			INSERT   INTO REVIEWE_DEPT VALUES (
				I.����ID
				,I.��������
				,USER_NAME_IN
				,V_��ǰʱ��
				,1
			);
		END LOOP;
	EXCEPTION
		WHEN OTHERS THEN
			NULL;
    --zl_ErrorCenter(SQLCode, SQLErrM);
	END DEPT_START;
--����ȡ������
	PROCEDURE DEL_REVIEWE_DEPT
-- ���뵱ǰ������Ա NAME ����ѡ����ID
--ȡ�����ÿ���
	 (
		DEPT_NAME_IN IN VARCHAR2
 --DEPT_STATUS number,
	)
		IS
	BEGIN
		DELETE REVIEWE_DEPT A
		 WHERE INSTR(
			DEPT_NAME_IN
			,A.DEPT_NAME
		) > 0;
	EXCEPTION
		WHEN OTHERS THEN
			NULL;
    --zl_ErrorCenter(SQLCode, SQLErrM);
	END DEL_REVIEWE_DEPT;

  --�޸����ﴦ��סԺҽ����¼
	PROCEDURE UPD_REVIEWE_RECIPES (
		INPUT_IN IN CLOB
	) AS
    --ͷע�Ϳ�ʼ-----------------------------------------------------------------------------------------
    --�������ƣ��޸����ﴦ��סԺҽ����¼
    --����˵�����޸����ﴦ��סԺҽ����¼
    --���˵����Input_In[{"pid": ,"pvid": ,"order_id": ,"pharmacist_id":"","reviewe_result": ,"reviewe_comment":""}]
    --����˵����
    --�� д �ߣ�����
    --��дʱ�䣺2018-06-12
    --�汾��¼���汾��+ʱ��+�޸���+�޸���������
    --ͷע�ͽ���-----------------------------------------------------------------------------------------
		D_REVIEWE_TIME   DATE := SYSDATE;
	BEGIN
		IF DBMS_LOB.GETLENGTH(INPUT_IN) <> 0 THEN
			FOR I IN ( SELECT PID
			                 ,PVID
			                 ,ORDER_ID
			                 ,PHARMACIST_ID
			                 ,PHARMACIST
			                 ,REVIEWE_RESULT
			                 ,REVIEWE_COMMENT
			             FROM
				JSON_TABLE ( INPUT_IN,'$[*]'
					COLUMNS (
						PID NUMBER PATH '$."pid"'
					,PVID NUMBER PATH '$."pvid"'
					,ORDER_ID NUMBER PATH '$."order_id"'
					,PHARMACIST_ID VARCHAR2 ( 36 ) PATH '$."pharmacist_id"'
					,PHARMACIST VARCHAR2 ( 80 ) PATH '$."pharmacist"'
					,REVIEWE_RESULT NUMBER PATH '$."reviewe_result"'
					,REVIEWE_COMMENT VARCHAR2 ( 4000 ) PATH '$."reviewe_comment"'
					)
				)
			) LOOP
				UPDATE REVIEWE_RECIPES
				   SET PHARMACIST_ID = I.PHARMACIST_ID,PHARMACIST = I.PHARMACIST
				,REVIEWE_RESULT = I.REVIEWE_RESULT
				,REVIEWE_COMMENT = I.REVIEWE_COMMENT
				,REVIEWE_TIME = D_REVIEWE_TIME
				 WHERE PID = I.PID
				   AND PVID = I.PVID
				   AND ORDER_ID = I.ORDER_ID;
			END LOOP;
		END IF;
	EXCEPTION
		WHEN OTHERS THEN
			PKG_RECIPE_REVIEWE.INSERT_LOG(
				'�޸���˽��'
				,'E'
				,INPUT_IN
			);
	END UPD_REVIEWE_RECIPES;

  --ɾ�������¼
	PROCEDURE DEL_WAIT_REVIEWE_RECIPE (
		INPUT_IN IN CLOB
	)
		AS
    --ͷע�Ϳ�ʼ-----------------------------------------------------------------------------------------
    --�������ƣ�ɾ�������¼
    --����˵����ɾ�������¼
    --���˵����Input_In[{"pid": ,"pvid":"","order_id": ,"pharmacist_id":""}]
    --����˵����
    --�� д �ߣ�����
    --��дʱ�䣺2018-06-12
    --�汾��¼���汾��+ʱ��+�޸���+�޸���������
    --ͷע�ͽ���-----------------------------------------------------------------------------------------
	BEGIN
		IF DBMS_LOB.GETLENGTH(INPUT_IN) <> 0 THEN
			FOR I IN ( SELECT PID
			                 ,PVID
			                 ,ORDER_ID
			                 ,PHARMACIST_ID
			             FROM
				JSON_TABLE ( INPUT_IN,'$[*]'
					COLUMNS (
						PID NUMBER ( 18 ) PATH '$."pid"'
					,PVID NUMBER ( 18 ) PATH '$."pvid"'
					,ORDER_ID NUMBER PATH '$.order_id'
					,PHARMACIST_ID VARCHAR2 ( 36 ) PATH '$."pharmacist_id"'
					)
				)
			) LOOP
				DELETE WAIT_REVIEWE_RECIPE
				 WHERE PID = I.PID
				   AND PVID = I.PVID
				   AND ORDER_ID = I.ORDER_ID
				   AND PHARMACIST_ID = I.PHARMACIST_ID;
			END LOOP;
		END IF;
	EXCEPTION
		WHEN OTHERS THEN
			PKG_RECIPE_REVIEWE.INSERT_LOG(
				'ɾ�������¼'
				,'E'
				,INPUT_IN
			);
	END DEL_WAIT_REVIEWE_RECIPE;

  --��ѯ���˴����󷽽��
	PROCEDURE GET_RECIPES_REVIEWE_RESULT (
		PID_IN      IN NUMBER
		,PVID_IN     IN NUMBER
		,RESULTOUT   OUT SYS_REFCURSOR
	) IS
    --ͷע�Ϳ�ʼ-----------------------------------------------------------------------------------------
    --�������ƣ���ѯ���˴����󷽽��
    --����˵������ѯָ��ҽ��id����˽����-1 δͨ��(�����Ҳ��δͨ��),1 ͨ��
    --���˵����[{"����id":123123,"����id":"2123"}] pid:����id,pvid������id������Һŵ��ţ�סԺ����ҳid
    --����˵�������˵���ҽ����˽��������ҽ������
    --    [{"����ID:"��123123,"����ID":123123}]
    --�� д �ߣ��޺�
    --��дʱ�䣺2018-06-11
    --�汾��¼���汾��+ʱ��+�޸���+�޸���������
    --ͷע�ͽ���-----------------------------------------------------------------------------------------
		V_�������   VARCHAR2(10);
    V_PHARMACIST_ID VARCHAR2(1000);
	BEGIN
		V_�������   := TO_CHAR(
			SYSDATE
			,'yyyymmdd'
		);
    --��ѯ��ǰ�ڸ�ҩʦ,��ȡҩʦcode ��
    select 
      max(listagg(t.pharmacist_id,',') Within Group(order by t.pharmacist_id)) into V_PHARMACIST_ID
    from PHARMACIST_WORK_RECORD t where t.register_date>=V_������� ;
		OPEN RESULTOUT FOR SELECT DISTINCT ORDER_ID
		                                  ,ORDER_GROUP_ID
                                      ,nvl(PHARMACIST_ID,V_PHARMACIST_ID)
		                                  ,CASE
				WHEN A.REVIEWE_RESULT =-1  THEN --δͨ��
					NVL(
						A.REVIEWE_COMMENT
						,'-ҩʦδ��дδͨ������-'
					) --ҩʦ��д������
				ELSE '�����'
			END
		NO_PASS_REASON
		                     FROM REVIEWE_RECIPES A
		                    WHERE A.DR_REFUSE_COMMENT IS NULL --ҽʦ��д�˾ܾ�����
		   --AND A.REVIEWE_NORMAL_TIME > SYSDATE --û�г�ʱ
		   AND (
			A.REVIEWE_RESULT =-1
			    OR A.REVIEWE_RESULT = 0
			    OR A.REVIEWE_RESULT = 2
			    OR A.REVIEWE_RESULT =-2
		) ---1δͨ�� 0 ���ӵ� -2 ������ 2 �����
		   AND A.PID = PID_IN
		   AND A.PVID = PVID_IN
		   AND A.RECIPE_DATE = V_�������; --ֻ�ǵ��յ���ͨ��
		PKG_RECIPE_REVIEWE.INSERT_LOG(
			LOG_TITILE_IN    => 'HIS��ѯ�󷽽��'
			,LOG_TYPE_IN      => 'T'
			,LOG_CONTENT_IN   => PID_IN || ',' || PVID_IN
		);
    --����ʽ����ʱ������JSON
		APEX_JSON.OPEN_OBJECT;
		APEX_JSON.WRITE(
			'recipes'
			,RESULTOUT
		);
		APEX_JSON.CLOSE_OBJECT;
	EXCEPTION
		WHEN OTHERS THEN
			PKG_RECIPE_REVIEWE.INSERT_LOG(
				LOG_TITILE_IN    => 'HIS��ѯ�󷽽��'
				,LOG_TYPE_IN      => 'E'
				,LOG_CONTENT_IN   => PID_IN || ',' || PVID_IN || CHR(10) || SQLERRM
			);
	END GET_RECIPES_REVIEWE_RESULT;
  
 --��ѯ�������д����󷽽��
  PROCEDURE GET_RECIPES_REVIEWE_RESULT_ALL (
    PID_IN      IN NUMBER
    ,PVID_IN     IN NUMBER
    ,RESULTOUT   OUT SYS_REFCURSOR
  ) IS
    --ͷע�Ϳ�ʼ-----------------------------------------------------------------------------------------
    --�������ƣ���ѯ�������д����󷽽��
    --����˵������ѯָ��ҽ��id����˽����-1 δͨ��(�����Ҳ��δͨ��),1 ͨ��
    --���˵����[{"����id":123123,"����id":"2123"}] pid:����id,pvid������id������Һŵ��ţ�סԺ����ҳid
    --����˵�������˵���ҽ����˽��������ҽ������
    --    [{"����ID:"��123123,"����ID":123123}]
    --�� д �ߣ��⿪��
    --��дʱ�䣺2018-08-27
    --�汾��¼���汾��+ʱ��+�޸���+�޸���������
    --ͷע�ͽ���-----------------------------------------------------------------------------------------
    V_�������   VARCHAR2(10);
  BEGIN
    V_�������   := TO_CHAR(
      SYSDATE
      ,'yyyymmdd'
    );
    OPEN RESULTOUT FOR SELECT DISTINCT A.ORDER_ID
                                      ,A.ORDER_GROUP_ID
                                      ,A.PHARMACIST_ID
                                      ,A.REVIEWE_COMMENT
                                      ,A.REVIEWE_RESULT
                                      ,B.RESULT_NAME
                                      ,A.DR_REFUSE_COMMENT
                         FROM REVIEWE_RECIPES A,V_REVIEWE_RESULT B
                        WHERE A.PID = PID_IN
                          AND A.PVID = PVID_IN
                          AND A.REVIEWE_RESULT=B.result_code ;
    PKG_RECIPE_REVIEWE.INSERT_LOG(
      LOG_TITILE_IN    => 'HIS��ѯ�����󷽽��ALL'
      ,LOG_TYPE_IN      => 'T'
      ,LOG_CONTENT_IN   => PID_IN || ',' || PVID_IN
    );
    --����ʽ����ʱ������JSON
    APEX_JSON.OPEN_OBJECT;
    APEX_JSON.WRITE(
      'recipes'
      ,RESULTOUT
    );
    APEX_JSON.CLOSE_OBJECT;
  EXCEPTION
    WHEN OTHERS THEN
      PKG_RECIPE_REVIEWE.INSERT_LOG(
        LOG_TITILE_IN    => 'HIS��ѯ�����󷽽��ALL'
        ,LOG_TYPE_IN      => 'E'
        ,LOG_CONTENT_IN   => PID_IN || ',' || PVID_IN || CHR(10) || SQLERRM
      );
  END GET_RECIPES_REVIEWE_RESULT_ALL;
  --��¼������־
	PROCEDURE INSERT_LOG (
		LOG_TITILE_IN    IN VARCHAR2
		,LOG_TYPE_IN      IN VARCHAR2
		,LOG_CONTENT_IN   IN CLOB
	)
		AS
    --ͷע�Ϳ�ʼ-----------------------------------------------------------------------------------------
    --�������ƣ���¼������־
    --����˵������¼������־
    --���˵����
    --����˵����
    --�� д �ߣ��޺�
    --��дʱ�䣺2018-06-08
    --�汾��¼���汾��+ʱ��+�޸���+�޸���������
    --ͷע�ͽ���-----------------------------------------------------------------------------------------
	BEGIN
	--ALTER SESSION SET PLSQL_CCFLAGS = 'dev_env:TRUE'; --�������룬������ǿ������������ԣ�T�����Ͳ��費��¼

		INSERT   INTO RECIPE_REVIEWE_LOG (
			LOG_TIME
			,LOG_TITLE
			,LOG_TYPE
			,LOG_CONTENT
		) VALUES (
			SYSDATE
			,LOG_TITILE_IN
			,LOG_TYPE_IN
			,LOG_CONTENT_IN
		);
		IF LOG_TYPE_IN = 'E' THEN
		--����Ǵ��󣬷���web��Ϣ�������ˣ���Ϣ����������û�����������з�ֹ����
			BEGIN
				WS_NOTIFY_API.DO_NOTIFY_ALL_PUBLIC_ERROR(
					I_TITLE     => LOG_TITILE_IN
					,I_MESSAGE   => '���ʹ������ϵͳ����Ա��ϵ'
				);
				NULL;
			EXCEPTION
				WHEN OTHERS THEN
					NULL;
			END;
		END IF;
	END INSERT_LOG;

  --��ZLHIS�����󷽽����Ϣ
	PROCEDURE SEND_MESSAGE_TO_ZLHIS (
		PID_IN              IN NUMBER
		,PVID_IN             IN NUMBER
		,REVIEWE_RESULT_IN   IN NUMBER
		,PHARMACIST_NAME     IN VARCHAR2 := ''
	) AS
    --ͷע�Ϳ�ʼ-----------------------------------------------------------------------------------------
    --�������ƣ���ZLHIS�����󷽽����Ϣ
    --����˵����ͨ������ZLHIS�Ĺ��̣���ZLHIS��������Ϣ
    --���˵����reviewe_result:��˽��,1--ȫ��ͨ����-1����δͨ��
    --����˵�������˵���ҽ����˽��������ҽ������
    --    
    --�� д �ߣ��޺�
    --��дʱ�䣺2018-06-15
    --�汾��¼���汾��+ʱ��+�޸���+�޸���������
    --ͷע�ͽ���-----------------------------------------------------------------------------------------
		V_REVIEWE_RECIPE_MESSAGE_CODE   VARCHAR2(100);
		V_MESSAGE_LOCATION              VARCHAR2(10); --����Ϣ����Ϊ1�ٴ�ʱ��"1111"�ӵ�һλ��ʼ������:����ҽ��վ,סԺҽ��վ,סԺ��ʿվ,ҽ������վ
		N_PATIENT_DEPT_ID               NUMBER(18);
		N_PATIENT_TYPE                  NUMBER(18);
		N_PATIENT_NURSING_DEPT_ID       NUMBER(18);
		V_PATIENT_NAME                  VARCHAR2(80);
		V_PATIENT_BED_NO                VARCHAR2(20);
		V_MESSAGE                       VARCHAR2(4000);
		N_WAIT_REVIEWE                  NUMBER(18);
	BEGIN
  
    --��鲡���Ƿ��д���ҽ��,�������Ѿ���ʱ��
		SELECT COUNT(*)
		  INTO N_WAIT_REVIEWE
		  FROM WAIT_REVIEWE_RECIPE B
		 WHERE B.PID = PID_IN
		   AND B.PVID = PVID_IN
		   AND B.REVIEWE_NORMAL_TIME > SYSDATE;
		IF N_WAIT_REVIEWE > 0 THEN
      --���д���ҽ������֪ͨ
			PKG_RECIPE_REVIEWE.INSERT_LOG(
				LOG_TITILE_IN    => '��֪ͨZLHIS'
				,LOG_TYPE_IN      => 'T'
				,LOG_CONTENT_IN   => PID_IN || ',' || PVID_IN
			);
			RETURN;
		END IF;
  

    --��ȡ������Ϣ
		SELECT MAX(A.P_DEPT_ID)
		      ,MAX(A.P_NURSING_DEPT_ID)
		      ,MAX(A.P_TYPE)
		      ,MAX(A.P_NAME)
		      ,MAX(P_BED_NO)
		  INTO
			N_PATIENT_DEPT_ID
		,N_PATIENT_NURSING_DEPT_ID
		,N_PATIENT_TYPE
		,V_PATIENT_NAME
		,V_PATIENT_BED_NO
		  FROM RECIPE_PATIENT_INFO A
		 WHERE A.PID = PID_IN
		   AND A.PVID = PVID_IN;
		IF N_PATIENT_DEPT_ID IS NULL THEN
			RETURN;
		END IF;
		IF N_PATIENT_TYPE = 2 THEN
			V_MESSAGE   := V_PATIENT_BED_NO || '��;';
		END IF;
		IF REVIEWE_RESULT_IN = 1 THEN
			V_MESSAGE   := V_MESSAGE || V_PATIENT_NAME || '�¿�ҽ��ҩʦ����ɣ����Խ�����һ����';
		ELSE
			V_MESSAGE   := V_MESSAGE || V_PATIENT_NAME || '�¿�ҽ��δͨ��ҩʦ�󷽣������޸�';
			IF PHARMACIST_NAME IS NOT NULL THEN
				V_MESSAGE   := V_MESSAGE || ',��ҩʦ:' || PHARMACIST_NAME || '��ϵ';
			END IF;
		END IF;
  
    --���ﲡ����������ҽ��վ��סԺ��������סԺҽ��վ
		IF N_PATIENT_TYPE = 1 THEN
			V_REVIEWE_RECIPE_MESSAGE_CODE   := 'ZLHIS_RECIPEAUDIT_001';
			V_MESSAGE_LOCATION              := '1000';
		ELSE
			V_REVIEWE_RECIPE_MESSAGE_CODE   := 'ZLHIS_RECIPEAUDIT_002';
			V_MESSAGE_LOCATION              := '0100';
		END IF;
  
    --���ﲡ���н����֪ͨ��סԺ����ֻ֪ͨ��δͨ���Ľ��
		IF REVIEWE_RESULT_IN =-1     OR N_PATIENT_TYPE = 1 THEN
			PKG_RECIPE_REVIEWE.INSERT_LOG(
				LOG_TITILE_IN    => '֪ͨZLHIS4'
				,LOG_TYPE_IN      => 'T'
				,LOG_CONTENT_IN   => PID_IN || ',' || PVID_IN || ';dept-' || N_PATIENT_DEPT_ID || ';nursing_dept-' || N_PATIENT_DEPT_ID || ';' || V_MESSAGE || ';location-' || V_MESSAGE_LOCATION || ';code-' || V_REVIEWE_RECIPE_MESSAGE_CODE
			);
			ZL_ҵ����Ϣ�嵥_INSERT@TO_ZLHIS (
				����ID_IN     => PID_IN
				,����ID_IN     => PVID_IN
				,�������ID_IN   => N_PATIENT_DEPT_ID
				,���ﲡ��ID_IN   => N_PATIENT_NURSING_DEPT_ID
				,������Դ_IN     => N_PATIENT_TYPE
				,��Ϣ����_IN     => V_MESSAGE
				,���ѳ���_IN     => V_MESSAGE_LOCATION
				,���ͱ���_IN     => V_REVIEWE_RECIPE_MESSAGE_CODE
				,ҵ���ʶ_IN     => '������ҩ��'
				,���ȳ̶�_IN     => 2
				,�Ƿ�����_IN     => 0
				,�Ǽ�ʱ��_IN     => SYSDATE
				,���Ѳ���_IN     => N_PATIENT_DEPT_ID
				,������Ա_IN     => N_PATIENT_NURSING_DEPT_ID
			);
		END IF;
	EXCEPTION
		WHEN OTHERS THEN
			INSERT_LOG(
				LOG_TITILE_IN    => 'SEND_MESSAGE_TO_ZLHIS'
				,LOG_TYPE_IN      => 'E'
				,LOG_CONTENT_IN   => 'pid:' || PID_IN || ',pvid:' || PVID_IN || CHR(10) || '�������:' || SQLCODE || '������Ϣ��' || SQLERRM
			);
	END SEND_MESSAGE_TO_ZLHIS;
  --ҽ����д�ܾ�ҩʦ��ͨ������
	PROCEDURE UPD_DR_REFUSE_COMMENT (
		RECIPES_IN IN CLOB
	)
		IS
    --ͷע�Ϳ�ʼ-----------------------------------------------------------------------------------------
    --�������ƣ�ҽ����д�ܾ�ҩʦ��ͨ������
    --����˵������ZLHIS���ã���дҽ���ܾ�����;
    --���˵����reviewe_result:��˽����1-ͨ����ȫ��ͨ������-1-δͨ��(��һ��ҽ��δͨ�����㣩
    --[{"order_id":123,"dr_refuse_comment":"aaaa"}]
    --����˵�������˵���ҽ����˽��������ҽ������
    --    
    --�� д �ߣ��޺�
    --��дʱ�䣺2018-06-20
    --�汾��¼���汾��+ʱ��+�޸���+�޸���������
    --ͷע�ͽ���-----------------------------------------------------------------------------------------
	BEGIN
		PKG_RECIPE_REVIEWE.INSERT_LOG(
			'ҽʦ�ܾ��󷽼�¼'
			,'T'
			,RECIPES_IN || CHR(10)
		);
		FOR I IN ( SELECT ORDER_ID
		                 ,DR_REFUSE_COMMENT
		             FROM
			JSON_TABLE ( RECIPES_IN,'$[*]'
				COLUMNS (
					ORDER_ID NUMBER ( 18 ) PATH '$."order_id"'
				,DR_REFUSE_COMMENT VARCHAR2 ( 4000 ) PATH '$."dr_refuse_comment"'
				)
			)
		) LOOP
			UPDATE REVIEWE_RECIPES A
			   SET A.DR_REFUSE_COMMENT = I.DR_REFUSE_COMMENT,A.DR_REFUSE = DECODE(
					I.DR_REFUSE_COMMENT
					,NULL
					,0
					,1
				)
			 WHERE A.ORDER_ID = I.ORDER_ID;
		END LOOP;
	EXCEPTION
		WHEN OTHERS THEN
			PKG_RECIPE_REVIEWE.INSERT_LOG(
				'ҽʦ�ܾ��󷽼�¼'
				,'E'
				,RECIPES_IN || CHR(10) || SQLERRM
			);
	END UPD_DR_REFUSE_COMMENT;
  
    --�޸���˷���
	PROCEDURE UPD_REVIEWE_SOLUTION (
		INPUT_IN IN CLOB
	)
		AS
    --ͷע�Ϳ�ʼ-----------------------------------------------------------------------------------------
    --�������ƣ��޸���˷���
    --����˵�����޸���˷���
    --���˵����INPUT_IN{"reviewe_solution_id":"","reviewe_solution_name":"","last_editor":"","last_edit_time":"","reviewe_solution_type":"","reviews_solution_status":""}
    --����˵����
    --�� д �ߣ�����
    --��дʱ�䣺2018-06-29
    --�汾��¼���汾��+ʱ��+�޸���+�޸���������
    --ͷע�ͽ���-----------------------------------------------------------------------------------------
    N_COUNT NUMBER(18);
    e_detail_error  exception;
    V_EXCPTION VARCHAR2(200);
	BEGIN
    
		IF DBMS_LOB.GETLENGTH(INPUT_IN) <> 0 THEN
			FOR I IN ( SELECT REVIEWE_SOLUTION_ID
        
			                 ,REVIEWE_SOLUTION_NAME
			                 ,LAST_EDITOR
			                 ,TO_DATE(
				LAST_EDIT_TIME
				,'yyyy-mm-dd hh24:mi:ss'
			) AS LAST_EDIT_TIME
			                 ,REVIEWE_SOLUTION_TYPE
			                 ,REVIEWE_SOLUTION_STATUS
			             FROM
				JSON_TABLE ( INPUT_IN,'$'
					COLUMNS (
						REVIEWE_SOLUTION_ID VARCHAR2 ( 36 ) PATH '$.reviewe_solution_id'
					,REVIEWE_SOLUTION_NAME VARCHAR2 ( 100 ) PATH '$.reviewe_solution_name'
					,LAST_EDITOR VARCHAR2 ( 80 ) PATH '$.last_editor'
					,LAST_EDIT_TIME VARCHAR2 ( 20 ) PATH '$.last_edit_time'
					,REVIEWE_SOLUTION_TYPE NUMBER PATH '$.reviewe_solution_type'
					,REVIEWE_SOLUTION_STATUS NUMBER PATH '$.reviews_solution_status'
					)
				)
			) LOOP
      -- �ж��޸ķ���������״̬ʱ���Ƿ������ϸ�����û���򡰷�������ʧ�ܣ�������ӷ�����ϸ�����ã���
      select count(*) INTO N_COUNT from reviewe_solution_detail where reviewe_solution_id=i.reviewe_solution_id;
      if i.reviewe_solution_status=1 AND N_COUNT=0 then
         V_EXCPTION:='��������ʧ�ܣ�������Ӹ÷�������ϸ�����ã�';
          raise e_detail_error;
      else
				UPDATE REVIEWE_SOLUTION
				   SET REVIEWE_SOLUTION_NAME = I.REVIEWE_SOLUTION_NAME,LAST_EDITOR = I.LAST_EDITOR
				,LAST_EDIT_TIME = I.LAST_EDIT_TIME
				,REVIEWE_SOLUTION_TYPE = I.REVIEWE_SOLUTION_TYPE
				,REVIEWE_SOLUTION_STATUS = I.REVIEWE_SOLUTION_STATUS
				 WHERE REVIEWE_SOLUTION_ID = I.REVIEWE_SOLUTION_ID;
       end if;
			END LOOP;
		END IF;
    EXCEPTION 
      WHEN e_detail_error THEN
        RAISE_APPLICATION_ERROR(-20011, V_EXCPTION);
        WHEN OTHERS THEN
          NULL;    
	END UPD_REVIEWE_SOLUTION;
  
---�󷽷������
	PROCEDURE PRESCRIPTIONS_REGULARITY (
		V_FIELD_NAME             IN VARCHAR2
		,C_REVIEWE_SOLUTION_OUT   OUT CLOB
	) IS
    --ͷע�Ϳ�ʼ-----------------------------------------------------------------------------------------
    --�������ƣ��޸���˷���
    --����˵�����޸���˷���
    --���˵�����󷽹���������.��Ŀ�ֶ�����  
    --����˵������Ӧ�ı��ʽ������ֵ�򡢵�ѡ����ѡ 1.2  xml
    --�� д �ߣ��⿪��
    --��дʱ�䣺2018-06-29
    --�汾��¼���汾��+ʱ��+�޸���+�޸���������
    --ͷע�ͽ���-----------------------------------------------------------------------------------------
		C_REVIEWE_SOLUTION   CLOB;
		T_��ǰʱ��               DATE;
	BEGIN
		T_��ǰʱ��                   := SYSDATE;
  --ҩƷ����
		IF V_FIELD_NAME = 'drug_form' THEN
			SELECT XMLAGG(XMLELEMENT(
				"value"
				,XMLELEMENT(
					"display"
					,A.ҩƷ����
				)
				,XMLELEMENT(
					"key"
					,A.ҩƷ����
				)
			) ).GETCLOBVAL()
			  INTO C_REVIEWE_SOLUTION
			  FROM ( SELECT DISTINCT ҩƷ����
			           FROM ҩƷ����@TO_ZLHIS
			) A;
			C_REVIEWE_SOLUTION   := '<range><type>1</type>' || C_REVIEWE_SOLUTION || '<expression><display>������</display><key>������</key></expression></range>';
		END IF; 
  --��ҩ;��
		IF V_FIELD_NAME = 'drug_route' THEN
			SELECT XMLAGG(XMLELEMENT(
				"value"
				,XMLELEMENT(
					"display"
					,A.��ҩ;��
				)
				,XMLELEMENT(
					"key"
					,A.��ҩ;��
				)
			) ).GETCLOBVAL()
			  INTO C_REVIEWE_SOLUTION
			  FROM ( SELECT DISTINCT T.�۲�����ϸֵ���� AS ��ҩ;��
			           FROM V_�ⲿϵͳ����@TO_ZLKBC T
			          WHERE T.�ⲿ��ϸ���� = '��ҩ;��'
			) A;
			C_REVIEWE_SOLUTION   := '<range><type>2</type>' || C_REVIEWE_SOLUTION || '<expression><display>����</display><key>����</key></expression></range>';
		END IF; 
  --�������� 
		IF V_FIELD_NAME = 'drug_contra_type' THEN
			SELECT XMLAGG(XMLELEMENT(
				"value"
				,XMLELEMENT(
					"display"
					,A.TYPE_
				)
				,XMLELEMENT(
					"key"
					,A.TYPE_
				)
			) ).GETCLOBVAL()
			  INTO C_REVIEWE_SOLUTION
			  FROM ( SELECT TYPE_
			           FROM V_������ҩ��ʾ����@TO_ZLKBC
			) A;
			C_REVIEWE_SOLUTION   := '<range><type>2</type>' || C_REVIEWE_SOLUTION || '<expression><display>������</display><key>������</key></expression></range>';
		END IF;
		C_REVIEWE_SOLUTION       :=
			CASE
				
				WHEN V_FIELD_NAME = 'recipe_dr_title' THEN
					'<range>
          <type>2</type>
          <value>
            <display>����ҽʦ</display>
            <key>����ҽʦ</key>
          </value>
          <value>
            <display>������ҽʦ</display>
            <key>������ҽʦ</key>
          </value>
          <value>
            <display>����ҽʦ</display>
            <key>����ҽʦ</key>
          </value>
          <value>
            <display>ҽʦ</display>
            <key>ҽʦ</key>
          </value>
          <expression>
            <display>������</display>
            <key>������</key>
          </expression>
        </range>'
				WHEN V_FIELD_NAME = 'recipe_diag' THEN
					'<range>
              <type>3</type>
              <value>
                <display></display>
                <key></key>
              </value>
              <expression>
                <display>����</display>
                <key>����</key>
              </expression>
            </range>'
				WHEN V_FIELD_NAME = 'dr_anti_level'     OR V_FIELD_NAME = 'drug_anti_level' THEN
					'<range>
              <type>1</type>
              <value>
                <display>1-������</display>
                <key>1</key>
              </value>
              <value>
                <display>2-����</display>
                <key>2</key>
              </value>
              <value>
                <display>3-����</display>
                <key>3</key>
              </value>
              <expression>
                <display>&gt;</display>
                <key>&gt;</key>
              </expression>
              <expression>
                <display>=</display>
                <key>=</key>
              </expression>
              <expression>
                <display>&lt;</display>
                <key>&lt;</key>
              </expression>
            </range>'
    --ҩƷͨ������ drug_generic_Name
				WHEN V_FIELD_NAME = 'drug_generic_name' THEN
					'<range>
              <type>3</type>
              <value>
                <display></display>
                <key></key>
              </value>
              <expression>
                <display></display>
                <key></key>
              </expression>
            </range>'
     --------------       
				WHEN V_FIELD_NAME = 'drug_toxicity' THEN
					'<range>
              <type>2</type>
              <value>
                <display>����ҩ</display>
                <key>����ҩ</key>
              </value>
              <value>
                <display>����ҩ</display>
                <key>����ҩ</key>
              </value>
              <value>
                <display>����I��</display>
                <key>����I��</key>
              </value>
              <value>
                <display>����II��</display>
                <key>����II��</key>
              </value>
              <value>
                <display>��ͨҩ</display>
                <key>��ͨҩ</key>
              </value>
              <expression>
                <display>������</display>
                <key>������</key>
              </expression>
            </range>'
				WHEN V_FIELD_NAME = 'anti_drug_reason' THEN
					'<range>
              <type>1</type>
              <value>
                <display>����</display>
                <key>����</key>
              </value>
              <value>
                <display>Ԥ��</display>
                <key>Ԥ��</key>
              </value>
              <expression>
                <display>����</display>
                <key>����</key>
              </expression>
            </range>'
				WHEN V_FIELD_NAME = 'p_phys' THEN
					'<range>
              <type>2</type>
              <value>
                <display>����</display>
                <key>����</key>
              </value>
              <value>
                <display>����</display>
                <key>����</key>
              </value>
              <value>
                <display>�ι��ܲ�ȫ</display>
                <key>�ι��ܲ�ȫ</key>
              </value>
              <value>
                <display>���ظι��ܲ�ȫ</display>
                <key>���ظι��ܲ�ȫ</key>
              </value>
              <value>
                <display>�����ܲ�ȫ</display>
                <key>�����ܲ�ȫ</key>
              </value>
              <value>
                <display>���������ܲ�ȫ</display>
                <key>���������ܲ�ȫ</key>
              </value>
              <expression>
                <display>����</display>
                <key>����</key>
              </expression>
            </range>'
				WHEN V_FIELD_NAME = 'drug_contra_level' THEN
					'<range>
              <type>2</type>
              <value>
                <display>����</display>
                <key>����</key>
              </value>
              <value>
                <display>����</display>
                <key>����</key>
              </value>
              <expression>
                <display>����</display>
                <key>����</key>
              </expression>
            </range>'
				ELSE C_REVIEWE_SOLUTION
			END;
		C_REVIEWE_SOLUTION_OUT   := C_REVIEWE_SOLUTION;
	EXCEPTION
		WHEN OTHERS THEN
			NULL;
    --zl_ErrorCenter(SQLCode, SQLErrM);
	END PRESCRIPTIONS_REGULARITY;

  --������˷���
	PROCEDURE INSERT_REVIEWE_SOLUTION (
		INPUT_IN IN CLOB
	)
		AS
    --ͷע�Ϳ�ʼ-----------------------------------------------------------------------------------------
    --�������ƣ�������˷���
    --����˵����������˷���
    --���˵����INPUT_IN{"reviewe_solution_id":"","reviewe_solution_name":"","last_editor":"","last_edit_time":"","reviewe_solution_type":"","reviews_solution_status":""}
    --����˵����
    --�� д �ߣ�����
    --��дʱ�䣺2018-06-29
    --�汾��¼���汾��+ʱ��+�޸���+�޸���������
    --ͷע�ͽ���-----------------------------------------------------------------------------------------
	BEGIN
		IF DBMS_LOB.GETLENGTH(INPUT_IN) <> 0 THEN
			INSERT   INTO REVIEWE_SOLUTION (
				REVIEWE_SOLUTION_ID
				,REVIEWE_SOLUTION_NAME
				,LAST_EDITOR
				,LAST_EDIT_TIME
				,REVIEWE_SOLUTION_TYPE
				,REVIEWE_SOLUTION_STATUS
			)
				SELECT REVIEWE_SOLUTION_ID
				      ,REVIEWE_SOLUTION_NAME
				      ,LAST_EDITOR
				      ,TO_DATE(
					LAST_EDIT_TIME
					,'yyyy-mm-dd hh24:mi:ss'
				) AS LAST_EDIT_TIME
				      ,REVIEWE_SOLUTION_TYPE
				      ,REVIEWE_SOLUTION_STATUS
				  FROM
					JSON_TABLE ( INPUT_IN,'$'
						COLUMNS (
							REVIEWE_SOLUTION_ID VARCHAR2 ( 36 ) PATH '$.reviewe_solution_id'
						,REVIEWE_SOLUTION_NAME VARCHAR2 ( 100 ) PATH '$.reviewe_solution_name'
						,LAST_EDITOR VARCHAR2 ( 80 ) PATH '$.last_editor'
						,LAST_EDIT_TIME VARCHAR2 ( 20 ) PATH '$.last_edit_time'
						,REVIEWE_SOLUTION_TYPE NUMBER PATH '$.reviewe_solution_type'
						,REVIEWE_SOLUTION_STATUS NUMBER PATH '$.reviews_solution_status'
						)
					);
		END IF;
	END INSERT_REVIEWE_SOLUTION;

  --ɾ����˷���
	PROCEDURE DEL_REVIEWE_SOLUTION (
		REVIEWE_SOLUTION_ID_IN IN VARCHAR2
	)
		AS
    --ͷע�Ϳ�ʼ-----------------------------------------------------------------------------------------
    --�������ƣ�ɾ����˷���
    --����˵����ɾ����˷���
    --���˵����REVIEWE_SOLUTION_ID_IN
    --����˵����
    --�� д �ߣ�����
    --��дʱ�䣺2018-06-29
    --�汾��¼���汾��+ʱ��+�޸���+�޸���������
    --ͷע�ͽ���-----------------------------------------------------------------------------------------
	BEGIN
		IF REVIEWE_SOLUTION_ID_IN IS NOT NULL THEN
			DELETE REVIEWE_SOLUTION
			 WHERE REVIEWE_SOLUTION_ID = REVIEWE_SOLUTION_ID_IN;
		END IF;
	END DEL_REVIEWE_SOLUTION;

  --�޸���˷�����ϸ
	PROCEDURE UPD_REVIEWE_SOLUTION_DETAIL (
		INPUT_IN IN CLOB
	) AS
    --ͷע�Ϳ�ʼ-----------------------------------------------------------------------------------------
    --�������ƣ��޸���˷�����ϸ
    --����˵�����޸���˷�����ϸ
    --���˵����Input_In{"reviewe_solution_id":"","last_editor":"","last_edit_time":"","solution_item":"","item_field_name":"","item_expression":"","item_value":"","item_type":"","item_table_name":""}
    --����˵����
    --�� д �ߣ�����
    --��дʱ�䣺2018-07-02
    --�汾��¼���汾��+ʱ��+�޸���+�޸���������
    --ͷע�ͽ���-----------------------------------------------------------------------------------------
		V_REVIEWE_SOLUTION_ID   VARCHAR2(50);
	BEGIN
		IF DBMS_LOB.GETLENGTH(INPUT_IN) <> 0 THEN
			FOR I IN ( SELECT REVIEWE_SOLUTION_ID
			                 ,LAST_EDITOR
			                 ,TO_DATE(
				LAST_EDIT_TIME
				,'yyyy-mm-dd hh24:mi:ss'
			) AS LAST_EDIT_TIME
			                 ,SOLUTION_ITEM
			                 ,ITEM_FIELD_NAME
			                 ,ITEM_EXPRESSION
			                 ,ITEM_VALUE
			                 ,ITEM_TYPE
			                 ,ITEM_TABLE_NAME
			             FROM
				JSON_TABLE ( INPUT_IN,'$'
					COLUMNS (
						REVIEWE_SOLUTION_ID VARCHAR2 ( 36 ) PATH '$.reviewe_solution_id'
					,LAST_EDITOR VARCHAR2 ( 80 ) PATH '$.last_editor'
					,LAST_EDIT_TIME VARCHAR2 ( 20 ) PATH '$.last_edit_time'
					,SOLUTION_ITEM VARCHAR2 ( 90 ) PATH '$.solution_item'
					,ITEM_FIELD_NAME VARCHAR2 ( 90 ) PATH '$.item_field_name'
					,ITEM_EXPRESSION VARCHAR2 ( 20 ) PATH '$.item_expression'
					,ITEM_VALUE VARCHAR2 ( 100 ) PATH '$.item_value'
					,ITEM_TYPE VARCHAR2 ( 10 ) PATH '$.item_type'
					,ITEM_TABLE_NAME VARCHAR2 ( 90 ) PATH '$.item_table_name'
					)
				)
			) LOOP
				UPDATE REVIEWE_SOLUTION_DETAIL
				   SET LAST_EDITOR = I.LAST_EDITOR,LAST_EDIT_TIME = I.LAST_EDIT_TIME
				,SOLUTION_ITEM = I.SOLUTION_ITEM
				,ITEM_EXPRESSION = I.ITEM_EXPRESSION
				,ITEM_VALUE = I.ITEM_VALUE
				,ITEM_TYPE = I.ITEM_TYPE
				,ITEM_TABLE_NAME = I.ITEM_TABLE_NAME
				 WHERE REVIEWE_SOLUTION_ID = I.REVIEWE_SOLUTION_ID
				   AND ITEM_FIELD_NAME = I.ITEM_FIELD_NAME;
			END LOOP;
      -- ������֤���̣����Ƿ��ܹ���֤ͨ����
			SELECT MAX(REVIEWE_SOLUTION_ID)
			  INTO V_REVIEWE_SOLUTION_ID
			  FROM
				JSON_TABLE ( INPUT_IN,'$'
					COLUMNS (
						REVIEWE_SOLUTION_ID VARCHAR2 ( 36 ) PATH '$.reviewe_solution_id'
					)
				);
			VERIFY_SOLUTION(V_REVIEWE_SOLUTION_ID);
		END IF;
	END UPD_REVIEWE_SOLUTION_DETAIL;

  --������˷�����ϸ
	PROCEDURE INSERT_REVIEWE_SOLUTION_DETAIL (
		INPUT_IN IN CLOB
	) AS
    --ͷע�Ϳ�ʼ-----------------------------------------------------------------------------------------
    --�������ƣ�������˷�����ϸ
    --����˵����������˷�����ϸ
    --���˵����Input_In{"reviewe_solution_id":"","reviewe_solution_name":"","last_editor":"","last_edit_time":"","reviewe_solution_type":"","reviews_solution_status":""}
    --����˵����
    --�� д �ߣ�����
    --��дʱ�䣺2018-07-02
    --�汾��¼���汾��+ʱ��+�޸���+�޸���������
    --ͷע�ͽ���-----------------------------------------------------------------------------------------
		V_REVIEWE_SOLUTION_ID   VARCHAR2(50);
	BEGIN
		IF DBMS_LOB.GETLENGTH(INPUT_IN) <> 0 THEN
			INSERT   INTO REVIEWE_SOLUTION_DETAIL (
				REVIEWE_SOLUTION_ID
				,LAST_EDITOR
				,LAST_EDIT_TIME
				,SOLUTION_ITEM
				,ITEM_FIELD_NAME
				,ITEM_EXPRESSION
				,ITEM_VALUE
				,ITEM_TYPE
				,ITEM_TABLE_NAME
			)
				SELECT REVIEWE_SOLUTION_ID
				      ,LAST_EDITOR
				      ,TO_DATE(
					LAST_EDIT_TIME
					,'yyyy-mm-dd hh24:mi:ss'
				) AS LAST_EDIT_TIME
				      ,SOLUTION_ITEM
				      ,ITEM_FIELD_NAME
				      ,ITEM_EXPRESSION
				      ,ITEM_VALUE
				      ,ITEM_TYPE
				      ,ITEM_TABLE_NAME
				  FROM
					JSON_TABLE ( INPUT_IN,'$'
						COLUMNS (
							REVIEWE_SOLUTION_ID VARCHAR2 ( 36 ) PATH '$.reviewe_solution_id'
						,LAST_EDITOR VARCHAR2 ( 80 ) PATH '$.last_editor'
						,LAST_EDIT_TIME VARCHAR2 ( 20 ) PATH '$.last_edit_time'
						,SOLUTION_ITEM VARCHAR2 ( 90 ) PATH '$.solution_item'
						,ITEM_FIELD_NAME VARCHAR2 ( 90 ) PATH '$.item_field_name'
						,ITEM_EXPRESSION VARCHAR2 ( 20 ) PATH '$.item_expression'
						,ITEM_VALUE VARCHAR2 ( 100 ) PATH '$.item_value'
						,ITEM_TYPE VARCHAR2 ( 10 ) PATH '$.item_type'
						,ITEM_TABLE_NAME VARCHAR2 ( 90 ) PATH '$.item_table_name'
						)
					);
		END IF;
    -- ������֤���̣����Ƿ��ܹ���֤ͨ����
		SELECT MAX(REVIEWE_SOLUTION_ID)
		  INTO V_REVIEWE_SOLUTION_ID
		  FROM
			JSON_TABLE ( INPUT_IN,'$'
				COLUMNS (
					REVIEWE_SOLUTION_ID VARCHAR2 ( 36 ) PATH '$.reviewe_solution_id'
				)
			);
		INSERT   INTO RECIPE_REVIEWE_LOG (
			LOG_TITLE
			,LOG_CONTENT
			,LOG_TYPE
			,LOG_TIME
		) VALUES (
			'��֤������ϸ����'
			,INPUT_IN
			,'T'
			,SYSDATE
		);
		VERIFY_SOLUTION(V_REVIEWE_SOLUTION_ID);
	END INSERT_REVIEWE_SOLUTION_DETAIL;

-- ��֤��˷���
	PROCEDURE VERIFY_SOLUTION
-- �󷽷�������ʱ����֤׼ȷ��
	 (
		V_REVIEWE_SOLUTION_ID IN VARCHAR2
	) IS
		V_DEPT_ID            VARCHAR2(500);
		V_��ǰʱ��               DATE;
---
		V_REVIEWE_DATE       VARCHAR2(10);
		V_QUOTE              VARCHAR2(10);
		V_SOLUTION_TMP_CND   CLOB;
		V_SOLUTION_CND       CLOB;
		V_CND                CLOB;
		V_SQL                CLOB;
		V_ORDER_IDS          VARCHAR2(200);
		V_ORDER_IDS_IN       VARCHAR2(200);
		N_PID                NUMBER(18);
		N_PVID               NUMBER(18);
--��Ӧ"����"��������ѡ�ǣ����Ϊ����������ʽ instr(�ֶ�,'����ֵ1')>0  or instr(�ֶ�,'����ֵ2')>0 
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
		SELECT DISTINCT MAX(PID)
		               ,MAX(PVID)
		  INTO
			N_PID
		,N_PVID
		  FROM REVIEWE_RECIPES
		 WHERE ROWNUM = 1;
		SELECT
			LISTAGG(ORDER_ID
			,',') WITHIN  GROUP(
				 ORDER BY ORDER_ID
			)
		  INTO V_ORDER_IDS
		  FROM REVIEWE_RECIPES
		 WHERE PID = N_PID
		   AND PVID = N_PVID;
		V_ORDER_IDS_IN   := ',' || V_ORDER_IDS || ',';
		V_QUOTE          := CHR(39);
		V_REVIEWE_DATE   := TO_CHAR(
			SYSDATE
			,'YYYYMMDD'
		);
                              
--Input_In{"reviewe_solution_id":"","reviewe_solution_name":"","last_editor":"","last_edit_time":"","reviewe_solution_type":"","reviews_solution_status":""}  
        --���һ������������
		FOR D IN ( SELECT C.SOLUTION_ITEM
		                 ,C.ITEM_EXPRESSION
		                 ,C.ITEM_VALUE
		                 ,C.ITEM_TYPE
		                 ,C.ITEM_TABLE_NAME || '.' || C.ITEM_FIELD_NAME FIELD_NAME
		             FROM REVIEWE_SOLUTION_DETAIL C
		            WHERE C.REVIEWE_SOLUTION_ID = V_REVIEWE_SOLUTION_ID
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
         /* IF V_CND IS NULL THEN
            V_CND   := V_SOLUTION_CND;
          ELSE
            V_CND   := V_CND || ' or ' || '(' || V_SOLUTION_CND || ')';
          END IF;
          V_SOLUTION_CND   := '';
        END LOOP;*/
		V_SQL            := '
    select reviewe_recipes.order_id,
           reviewe_recipes.receive_time,
           reviewe_recipes.recipe_date,
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
|| V_SOLUTION_CND || ' and instr(' || V_QUOTE || V_ORDER_IDS_IN || V_QUOTE || ',' || V_QUOTE || ',' || V_QUOTE || '||reviewe_recipes.order_id || ' || V_QUOTE || ',' || V_QUOTE || ') > 0 and reviewe_recipes.recipe_date=' || V_QUOTE || V_REVIEWE_DATE || V_QUOTE || ' --��ѯ��֤����';
		DBMS_OUTPUT.PUT_LINE(V_SQL);
		EXECUTE IMMEDIATE V_SQL;
		INSERT   INTO RECIPE_REVIEWE_LOG (
			LOG_TITLE
			,LOG_CONTENT
			,LOG_TYPE
			,LOG_TIME
		) VALUES (
			'��֤������ϸ����'
			,V_SQL
			,'T'
			,SYSDATE
		);
	EXCEPTION
		WHEN OTHERS THEN
    --������÷����������⣬����Ҫ���� �޷�ֱ�ӱ��� �ع�����
			ROLLBACK;
			RETURN;
    --zl_ErrorCenter(SQLCode, SQLErrM);
	END VERIFY_SOLUTION;

  --ɾ����˷�����ϸ
	PROCEDURE DEL_REVIEWE_SOLUTION_DETAIL (
		INPUT_IN IN CLOB
	) AS
    --ͷע�Ϳ�ʼ-----------------------------------------------------------------------------------------
    --�������ƣ�ɾ����˷�����ϸ
    --����˵����ɾ����˷�����ϸ
    --���˵����Input_In{"reviewe_solution_id":"","reviewe_solution_name":"","last_editor":"","last_edit_time":"","reviewe_solution_type":"","reviews_solution_status":""}
    --����˵����
    --�� д �ߣ�����
    --��дʱ�䣺2018-07-02
    --�汾��¼���汾��+ʱ��+�޸���+�޸���������
    --ͷע�ͽ���-----------------------------------------------------------------------------------------
		N_COUNT   NUMBER;
	BEGIN
		IF DBMS_LOB.GETLENGTH(INPUT_IN) <> 0 THEN
			FOR I IN ( SELECT REVIEWE_SOLUTION_ID
			                 ,ITEM_FIELD_NAME
			             FROM
				JSON_TABLE ( INPUT_IN,'$'
					COLUMNS (
						REVIEWE_SOLUTION_ID VARCHAR2 ( 36 ) PATH '$.reviewe_solution_id'
					,ITEM_FIELD_NAME VARCHAR2 ( 90 ) PATH '$.item_field_name'
					)
				)
			) LOOP
				DELETE REVIEWE_SOLUTION_DETAIL
				 WHERE REVIEWE_SOLUTION_ID = I.REVIEWE_SOLUTION_ID
				   AND ITEM_FIELD_NAME = I.ITEM_FIELD_NAME;
           --2018-7-11 �⿪������ ���ƣ�ɾ������ϸ������Ϊ0����ͬʱ�޸� �÷���Ϊͣ��״̬��
				SELECT COUNT(*)
				  INTO N_COUNT
				  FROM REVIEWE_SOLUTION_DETAIL
				 WHERE REVIEWE_SOLUTION_ID = I.REVIEWE_SOLUTION_ID;
				IF N_COUNT = 0 THEN
					UPDATE REVIEWE_SOLUTION T
					   SET
						T.REVIEWE_SOLUTION_STATUS =-1
					 WHERE T.REVIEWE_SOLUTION_ID = I.REVIEWE_SOLUTION_ID;
				END IF;
			END LOOP;
		END IF;
	END DEL_REVIEWE_SOLUTION_DETAIL;

  --��ϵͳ��װ���ʼ��
	PROCEDURE RECIPE_REVIEWE_COMMENT_INIT AS
    --ͷע�Ϳ�ʼ-----------------------------------------------------------------------------------------
    --�������ƣ���ϵͳ��װ���ʼ��
    --����˵����������ϵͳ������Ҫ�����ݡ����ݶ���Ļ���
    --���˵����
    --����˵����
    --�� д �ߣ��޺�
    --��дʱ�䣺2018-07-02
    --�汾��¼���汾��+ʱ��+�޸���+�޸���������
    --ͷע�ͽ���-----------------------------------------------------------------------------------------
		V_�󷽽����ѯ     VARCHAR2(4000);
		V_ҽ���ܾ���д     VARCHAR2(4000);
		V_HIS����      VARCHAR2(4000);
		V_������ҩ����     VARCHAR2(4000);
		V_SQL        VARCHAR2(4000);
		V_JOB_NAME   VARCHAR2(100);
	BEGIN
  --��ZLHIS�����󷽵Ĳ���
		SELECT 'http://' || MAX(PARA_VALUE) || '/ords/zlrecipe/recipe/result'
		      ,'http://' || MAX(PARA_VALUE) || '/ords/zlrecipe/recipe/refuse'
		  INTO
			V_�󷽽����ѯ
		,V_ҽ���ܾ���д
		  FROM RECIPE_REVIEWE_PARA
		 WHERE PARA_NAME = '�󷽷�������ַ';
		IF V_�󷽽����ѯ IS NULL THEN
			PKG_RECIPE_REVIEWE.INSERT_LOG(
				LOG_TITILE_IN    => '��ϵͳ��ʼ��'
				,LOG_TYPE_IN      => '��ϵͳ��������ַδ����'
				,LOG_CONTENT_IN   => V_�󷽽����ѯ
			);
			RETURN;
		END IF;
		UPDATE ������������Ŀ¼@TO_ZLHIS
		   SET
			�����ַ = V_�󷽽����ѯ
		 WHERE ϵͳ��ʶ = 'ҩʦ�������'
		   AND �������� = '�������ѯ';
		IF SQL%ROWCOUNT = 0 THEN
			INSERT   INTO ������������Ŀ¼@TO_ZLHIS (
				ϵͳ��ʶ
				,��������
				,�����ַ
			) VALUES (
				'ҩʦ�������'
				,'�������ѯ'
				,V_�󷽽����ѯ
			);
		END IF;
		UPDATE ������������Ŀ¼@TO_ZLHIS
		   SET
			�����ַ = V_ҽ���ܾ���д
		 WHERE ϵͳ��ʶ = 'ҩʦ�������'
		   AND �������� = '��дҽ���ܾ�����';
		IF SQL%ROWCOUNT = 0 THEN
			INSERT   INTO ������������Ŀ¼@TO_ZLHIS (
				ϵͳ��ʶ
				,��������
				,�����ַ
			) VALUES (
				'ҩʦ�������'
				,'��дҽ���ܾ�����'
				,V_ҽ���ܾ���д
			);
		END IF;
		V_JOB_NAME   := 'ZLRECIPE.�󷽵���ϵͳÿ����ҵ';
    --���������Զ���ҵ
    --��ֹͣ��ɾ��job
		BEGIN
			DBMS_SCHEDULER.STOP_JOB(V_JOB_NAME);
		EXCEPTION
			WHEN OTHERS THEN
				NULL;
				BEGIN
					DBMS_SCHEDULER.DROP_JOB(V_JOB_NAME);
				EXCEPTION
					WHEN OTHERS THEN
						NULL;
				END;
		END; 

    --���������Զ���ҵ
		DBMS_SCHEDULER.CREATE_JOB(
			JOB_NAME     => V_JOB_NAME
			,JOB_TYPE     => 'STORED_PROCEDURE'
			,JOB_ACTION   => 'ZLRECIPE.PKG_RECIPE_REVIEWE.DEL_TimeOut_WAIT_REVIEWE_RECIPES'
			,ENABLED      => TRUE
			,COMMENTS     => 'ÿ���������δ�󴦷�'
		);

    --����Ϊ������Чִ��
		DBMS_SCHEDULER.ENABLE(NAME   => V_JOB_NAME);
		DBMS_SCHEDULER.SET_ATTRIBUTE(
			NAME        => V_JOB_NAME
			,ATTRIBUTE   => 'start_date'
			,VALUE       => SYSDATE
		);
    --ÿ��19��00�����У��ɵ���
		DBMS_SCHEDULER.SET_ATTRIBUTE(
			NAME        => V_JOB_NAME
			,ATTRIBUTE   => 'repeat_interval'
			,VALUE       => 'FREQ=DAILY; BYHOUR=19;BYMINUTE=00'
		);

    --��ֹ������Զ�ɾ��
		DBMS_SCHEDULER.SET_ATTRIBUTE(
			NAME        => V_JOB_NAME
			,ATTRIBUTE   => 'auto_drop'
			,VALUE       => FALSE
		);
    --����JOBִ�г��ִ�����´μ���ִ�С�
		DBMS_SCHEDULER.SET_ATTRIBUTE(
			NAME        => V_JOB_NAME
			,ATTRIBUTE   => 'RESTARTABLE'
			,VALUE       => TRUE
		);

    --������־����ֻ��¼ʧ����־
		DBMS_SCHEDULER.SET_ATTRIBUTE(
			NAME        => V_JOB_NAME
			,ATTRIBUTE   => 'logging_level'
			,VALUE       => DBMS_SCHEDULER.LOGGING_FAILED_RUNS
		);
	END RECIPE_REVIEWE_COMMENT_INIT;
	--ɾ���Ѿ����ڵĴ��󴦷�
	PROCEDURE DEL_TIMEOUT_WAIT_REVIEWE_RECIPES
		AS
    --ͷע�Ϳ�ʼ-----------------------------------------------------------------------------------------
    --�������ƣ�ɾ���Ѿ����ڵĴ��󴦷�
    --����˵����ɾ���Ѿ����ڵĴ��󴦷���ÿ�������Զ�����
    --���˵����
    --����˵����
    --�� д �ߣ��޺�
    --��дʱ�䣺2018-07-10
    --�汾��¼���汾��+ʱ��+�޸���+�޸���������
    --ͷע�ͽ���-----------------------------------------------------------------------------------------
	BEGIN
	--ɾ�����󴦷��г�ʱ������
		DELETE WAIT_REVIEWE_RECIPE
		 WHERE REVIEWE_NORMAL_TIME < SYSDATE;
		 --�����󴦷�����˽��Ϊ��ʱͨ��
		UPDATE REVIEWE_RECIPES
		   SET
			REVIEWE_RESULT = 22
		 WHERE REVIEWE_NORMAL_TIME < SYSDATE
		   AND REVIEWE_RESULT = 0;
	END DEL_TIMEOUT_WAIT_REVIEWE_RECIPES;
END PKG_RECIPE_REVIEWE;

/
