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
  --住院病人处方提取
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
  --门诊病人处方提取
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
  
    --完成点评
	PROCEDURE FINISH_COMMENT_RECIPE (
		EXTRACT_ID_IN IN NUMBER
	);
  
	  --自动点评
	PROCEDURE AUTO_COMMENT_RECIPE (
		EXTRACT_ID_IN IN NUMBER
	);
 --人工点评
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
	--删除点评结果
	PROCEDURE DEL_COMMENT_RESULT (
		RECIPE_NO_IN           IN VARCHAR2
		,COMMENT_ITEM_CODE_IN   IN VARCHAR2
		,ORDER_ID_IN            IN NUMBER
	);
--删除点评抽取	
 procedure del_ectract(extract_id_in number);	
END PKG_RECIPE_COMMENT;

/


CREATE OR REPLACE PACKAGE BODY PKG_RECIPE_COMMENT IS
 --抽取点评处方
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
  --头注释开始-----------------------------------------------------------------------------------------
  --方法名称：抽取点评处方
  --功能说明：根据界面的设置参数，进行一次点评处方抽取
  --入参说明：
  ----EXTRACT_MONTH 抽取月份;
  ----PATIEN_TYPE 病人类型,1-门诊；2-住院
  ----RECIPE_TYPE 抗菌药物类型;0-所有处方,1-预防用抗菌药物处方,2-治疗用抗菌药物处方
  ----SURGERY_TYPE_IN 0-所有病例,1-手术病例
  ----RECIPES_NUMBER_in 提取处方数量
  ----EXTRACT_TYPE 提取类型,0-随机
  ----PHARMACIST_IN 点评药师姓名
  ----PHARMACIST_ID_IN 点评用药用户ID
  ----EXTRACT_DEPT_ID_IN 点评科室ID
  ----EXTRACT_DR_ID_IN 点评医师ID
  ----EXTRACT_DRUG_ID_IN 点评药品ID
  --出参说明：extract_id 本次抽取ID
  --编 写 者：罗虹
  --编写时间：2018-06-21
  --版本记录：版本号+时间+修改者+修改需求描述
  --头注释结束----------------------------------------------------------------------------------------- 
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

  --住院病人处方提取
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
--头注释开始-----------------------------------------------------------------------------------------
--方法名称：抽取住院点评处方
--功能说明：抽取住院点评处方
--入参说明：
----EXTRACT_MONTH 抽取月份;
----PATIEN_TYPE 病人类型,1-门诊；2-住院
----RECIPE_TYPE 抗菌药物类型;0-所有处方,1-预防用抗菌药物处方,2-治疗用抗菌药物处方
----SURGERY_TYPE_IN 0-所有病例,1-手术病例
----RECIPES_NUMBER_in 提取处方数量
----EXTRACT_TYPE 提取类型,0-随机
----PHARMACIST_IN 点评药师姓名
----PHARMACIST_ID_IN 点评用药用户ID
--出参说明：extract_id 本次抽取ID
--编 写 者：罗虹
--编写时间：2018-06-21
--版本记录：版本号+时间+修改者+修改需求描述
--头注释结束----------------------------------------------------------------------------------------- 
	) AS
		BEGIN_TIME    DATE; --抽取医嘱开始时间
		FINISH_TIME   DATE; --抽取医嘱结束时间
		V_DEPT_NAME   VARCHAR2(500);
		V_DR_NAME     VARCHAR2(500);
		V_DRUG_NAME   VARCHAR2(500);
	BEGIN
		SELECT MAX(名称)
		  INTO V_DEPT_NAME
		  FROM 部门表@TO_ZLHIS
		 WHERE ID = EXTRACT_DEPT_ID_IN;
		SELECT MAX(别名)
		  INTO V_DR_NAME
		  FROM 人员表@TO_ZLHIS
		 WHERE 姓名 = EXTRACT_DR_ID_IN;
		SELECT MAX(名称)
		  INTO V_DRUG_NAME
		  FROM 收费项目目录@TO_ZLHIS
		 WHERE ID = EXTRACT_DRUG_ID_IN;
		EXTRACT_ID_OUT   := ZLRECIPE.COMMENT_EXTRACT_EXTRACT_ID_SEQ.NEXTVAL;
  --开始时间是抽取月的1号0点
		BEGIN_TIME       := TO_DATE(
			EXTRACT_MONTH_IN || '01 00:00:00'
			,'yyyymmdd hh24:mi:ss'
		);
  --结束时间下月1号0点减1秒
		FINISH_TIME      := ADD_MONTHS(
			BEGIN_TIME
			,1
		) - 1 / 24 / 60 / 60;
  --先产生抽取记录
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
				H.基本药物
				,'基药'
				,1
				,'国家基药'
				,1
				,0
			) )
			             FROM 病人医嘱记录@TO_ZLHIS A
			                 ,药品规格@TO_ZLHIS H
			            WHERE H.药名ID = A.诊疗项目ID
			   AND A.病人ID = PID
			   AND A.主页ID = PVID
			) BASE_DRUG_NUMBER
			      , ( SELECT TRUNC(
				SUM(B.实收金额)
			)
			             FROM 住院费用记录@TO_ZLHIS B
			            WHERE B.记录状态 <> 0
			   AND B.病人ID = PID
			   AND B.主页ID = PVID
			            GROUP BY B.病人ID
			                    ,B.主页ID
			) RECIPE_AMOUNT
			      , ( SELECT
				LISTAGG(C.诊断描述
				,'|') WITHIN  GROUP(
					 ORDER BY ''
				)
			             FROM 病人诊断记录@TO_ZLHIS C
			            WHERE C.记录来源 = 3
			   AND 诊断次序 = 1
			   AND C.诊断类型 IN (
				3
				,13
			)
			   AND C.病人ID = PID
			   AND C.主页ID = PVID
			) RECIPE_DIAG
			      ,PATIENT_BIRTHDAY
			      ,RECIPE_DATE
			  FROM ( SELECT RECIPE_NO
			               ,PID
			               ,PVID
			               ,RECIPE_DR
			               ,RECIPE_DR_TITLE
			               ,DR_ANTI_LEVEL
			               ,RECIPES_NUMBER_IN ，PATIENT_AGE
			               ,PATIENT_BIRTHDAY
			               ,RECIPE_DATE
			           FROM ( SELECT A.病人ID PID
			                        ,A.主页ID PVID
			                        ,A.年龄 PATIENT_AGE
			                        ,A.病人ID || '-' || A.主页ID RECIPE_NO
			                        ,A.住院医师 RECIPE_DR
			                        ,D.专业技术职务 RECIPE_DR_TITLE
			                        ,E.级别 DR_ANTI_LEVEL
			                        ,F.出生日期 PATIENT_BIRTHDAY
			                        ,A.入院日期 RECIPE_DATE
			                    FROM 病案主页@TO_ZLHIS A
			                        ,人员表@TO_ZLHIS D
			                        ,人员抗菌药物权限@TO_ZLHIS E
			                        ,病人信息@TO_ZLHIS F
			                   WHERE A.住院医师 = D.姓名
			   AND F.病人ID = A.病人ID
			   AND D.ID = E.人员ID (+)
			   AND E.场合 (+) = 1
			   AND E.记录状态 (+) = 1
			   AND A.出院日期 BETWEEN BEGIN_TIME    AND FINISH_TIME
			   AND (
				EXISTS ( SELECT 1
				           FROM 病人医嘱记录@TO_ZLHIS BB
				          WHERE BB.病人ID = A.病人ID
				   AND BB.主页ID = A.主页ID
				   AND BB.收费细目ID = EXTRACT_DRUG_ID_IN
				)
				    OR NVL(
					EXTRACT_DRUG_ID_IN
					,0
				) = 0
			)
			   AND (
				A.住院医师 = EXTRACT_DR_ID_IN
				    OR EXTRACT_DR_ID_IN IS NULL
			)
			   AND (
				A.出院科室ID = EXTRACT_DEPT_ID_IN
				    OR ( NVL(
					EXTRACT_DEPT_ID_IN
					,0
				) = 0 )
			)
			   AND (
				RECIPE_TYPE_IN = 0
				    OR ( EXISTS ( SELECT 1
				                    FROM 病人医嘱记录@TO_ZLHIS AA
				                   WHERE AA.病人ID = A.病人ID
				   AND AA.主页ID = A.主页ID
				   AND (
					(
						AA.用药目的 = 1
						   AND RECIPE_TYPE_IN = 1
					)
					    OR (
						AA.用药目的 = 2
						   AND RECIPE_TYPE_IN = 2
					)
				)
				) )
			)
			   AND NOT EXISTS ( SELECT 1
			                      FROM COMMENT_RECIPES F
			                     WHERE F.RECIPE_NO = A.病人ID || '-' || A.主页ID
			)
			 ORDER BY DBMS_RANDOM.VALUE )
			          WHERE ROWNUM <= RECIPES_NUMBER_IN
			);
		IF SQL%ROWCOUNT = 0 THEN  --没有抽取到处方
			DELETE COMMENT_EXTRACT
			 WHERE EXTRACT_ID = EXTRACT_ID_OUT;
			EXTRACT_ID_OUT   := NULL;
			--RAISE_APPLICATION_ERROR(-20001, '没有抽取到符合条件的处方');
		END IF;
	END INPATIENT_EXTRACT;
  
  --门诊病人处方提取
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
--头注释开始-----------------------------------------------------------------------------------------
--方法名称：抽取门诊点评处方
--功能说明：抽取点住院评处方
--入参说明：
----EXTRACT_MONTH 抽取月份;
----PATIEN_TYPE 病人类型,1-门诊；2-住院
----RECIPE_TYPE 抗菌药物类型;0-所有处方,1-预防用抗菌药物处方,2-治疗用抗菌药物处方  
----SURGERY_TYPE_IN 0-所有病例,1-手术病例
----RECIPES_NUMBER_in 提取处方数量
----EXTRACT_TYPE 提取类型,0-随机
----PHARMACIST_IN 点评药师姓名
----PHARMACIST_ID_IN 点评用药用户ID
--出参说明：extract_id 本次抽取ID
--编 写 者：罗虹
--编写时间：2018-06-21
--版本记录：版本号+时间+修改者+修改需求描述
--头注释结束-----------------------------------------------------------------------------------------
	) AS
		BEGIN_TIME    DATE; --抽取医嘱开始时间
		FINISH_TIME   DATE; --抽取医嘱结束时间
		V_DEPT_NAME   VARCHAR2(500);
		V_DR_NAME     VARCHAR2(500);
		V_DRUG_NAME   VARCHAR2(500);
	BEGIN
		PKG_RECIPE_REVIEWE.INSERT_LOG(
			LOG_TITILE_IN    => '点评'
			,LOG_TYPE_IN      => 'T'
			,LOG_CONTENT_IN   => EXTRACT_DRUG_ID_IN || '--'
		);
		SELECT MAX(名称)
		  INTO V_DEPT_NAME
		  FROM 部门表@TO_ZLHIS
		 WHERE ID = EXTRACT_DEPT_ID_IN;
		SELECT MAX(别名)
		  INTO V_DR_NAME
		  FROM 人员表@TO_ZLHIS
		 WHERE 姓名 = EXTRACT_DR_ID_IN;
		SELECT MAX(名称)
		  INTO V_DRUG_NAME
		  FROM 收费项目目录@TO_ZLHIS
		 WHERE ID = EXTRACT_DRUG_ID_IN;
		EXTRACT_ID_OUT   := ZLRECIPE.COMMENT_EXTRACT_EXTRACT_ID_SEQ.NEXTVAL;
  --开始时间是抽取月的1号0点
		BEGIN_TIME       := TO_DATE(
			EXTRACT_MONTH_IN || '01 00:00:00'
			,'yyyymmdd hh24:mi:ss'
		);
  --结束时间下月1号0点减1秒
		FINISH_TIME      := ADD_MONTHS(
			BEGIN_TIME
			,1
		) - 1 / 24 / 60 / 60;
  --先产生抽取记录
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

  
  --抽取处方
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
				SUM(II.实收金额)
			)
			             FROM 门诊费用记录@TO_ZLHIS II
			            WHERE II.记录状态 <> 0
			   AND II.NO = E.RECIPE_NO
			            GROUP BY II.NO
			) RECIPE_AMOUNT
			      , ( SELECT
				LISTAGG(诊断描述
				,'|') WITHIN  GROUP(
					 ORDER BY ''
				)
			             FROM ( SELECT DISTINCT HH.诊断描述
			                      FROM 病人诊断医嘱@TO_ZLHIS JJ
			                          ,病人诊断记录@TO_ZLHIS HH
			                          ,病人医嘱发送@TO_ZLHIS KK
			                          ,病人医嘱记录@TO_ZLHIS LL
			                     WHERE JJ.诊断ID = HH.ID
			   AND LL.相关ID = JJ.医嘱ID
			   AND LL.ID = KK.医嘱ID
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
			               ,MAX(抗生素) ANTI_DRUG_MAX_LEVEL
			               ,MAX(饮片处方 + 非饮片处方) RECIPE_TYPE
			               ,SUM(BASE_DRUG_NUMBER) BASE_DRUG_NUMBER
			               ,MAX(PATIENT_AGE) PATIENT_AGE
			               ,MAX(PATIENT_BIRTHDAY) PATIENT_BIRTHDAY
			               ,MAX(RECIPE_DATE) RECIPE_DATE
			           FROM ( SELECT C.NO RECIPE_NO
			                        ,A.病人ID PID
			                        ,A.挂号单 PVID
			                        ,A.开嘱医生 RECIPE_DR
			                        ,D.专业技术职务 RECIPE_DR_TITLE
			                        ,E.级别 DR_ANTI_LEVEL
			                        ,B.抗生素
			                        ,A.用药目的
			                        ,CASE
					WHEN A.诊疗类别 = 7 THEN
						1
					ELSE 0
				END
			饮片处方
			                        ,CASE
					WHEN A.诊疗类别 <> 7 THEN
						3
					ELSE 0
				END
			非饮片处方
			                        ,DECODE(
				H.基本药物
				,'基药'
				,1
				,'国家基药'
				,1
				,0
			) BASE_DRUG_NUMBER
			                        ,I.年龄 PATIENT_AGE
			                        ,J.出生日期 PATIENT_BIRTHDAY
			                        ,A.开嘱时间 RECIPE_DATE
			                    FROM 病人医嘱记录@TO_ZLHIS A
			                        ,药品特性@TO_ZLHIS B
			                        ,病人医嘱发送@TO_ZLHIS C
			                        ,人员表@TO_ZLHIS D
			                        ,人员抗菌药物权限@TO_ZLHIS E
			                        ,药品规格@TO_ZLHIS H
			                        ,病人挂号记录@TO_ZLHIS I
			                        ,病人信息@TO_ZLHIS J
			                   WHERE A.病人来源 = 1
			   AND A.诊疗类别 IN (
				'5'
				,'6'
				,'7'
			)
			   AND H.药名ID = A.诊疗项目ID
			   AND A.病人ID = J.病人ID
			   AND B.药名ID = A.诊疗项目ID
			   AND I.NO = A.挂号单
			   AND A.ID = C.医嘱ID
			   AND A.开嘱医生 = D.姓名
			   AND (
				A.收费细目ID = EXTRACT_DRUG_ID_IN
				    OR NVL(
					EXTRACT_DRUG_ID_IN
					,0
				) = 0
			)
			   AND (
				A.开嘱医生 = EXTRACT_DR_ID_IN
				    OR EXTRACT_DR_ID_IN IS NULL
			)
			   AND (
				A.开嘱科室ID = EXTRACT_DEPT_ID_IN
				    OR ( NVL(
					EXTRACT_DEPT_ID_IN
					,0
				) = 0 )
			)
			   AND D.ID = E.人员ID (+)
			   AND E.场合 (+) = 1
			   AND E.记录状态 (+) = 1
			   AND A.医嘱状态 IN (
				7
				,8
				,9
			)
			   AND (
				(
					A.用药目的 = 1
					   AND RECIPE_TYPE_IN = 1
				)
				    OR (
					A.用药目的 = 2
					   AND RECIPE_TYPE_IN = 2
				)
				    OR RECIPE_TYPE_IN = 0
			)
			   AND A.开嘱时间 BETWEEN BEGIN_TIME    AND FINISH_TIME
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
		IF SQL%ROWCOUNT = 0 THEN  --没有抽取到处方
			DELETE COMMENT_EXTRACT
			 WHERE EXTRACT_ID = EXTRACT_ID_OUT;
			EXTRACT_ID_OUT   := NULL;
			--RAISE_APPLICATION_ERROR(-20001, '没有抽取到符合条件的处方');
		END IF;
	END OUTPATIENT_EXTRACT;
  --完成点评
	PROCEDURE FINISH_COMMENT_RECIPE (
		EXTRACT_ID_IN IN NUMBER
	) AS
    --头注释开始-----------------------------------------------------------------------------------------
    --方法名称：完成点评
    --功能说明：完成点评
    --入参说明：EXTRACT_ID_IN IN NUMBER
    --出参说明：
    --编 写 者：白天
    --编写时间：2018-06-26
    --版本记录：版本号+时间+修改者+修改需求描述
    --头注释结束-----------------------------------------------------------------------------------------
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

  --自动点评
	PROCEDURE AUTO_COMMENT_RECIPE (
		EXTRACT_ID_IN IN NUMBER
	) AS
--头注释开始-----------------------------------------------------------------------------------------
--方法名称：自动点评处方
--功能说明：对某一次抽取的处方进行自动点评
--入参说明：extract_ID_IN 抽取ID,patient_type_in 病人类型
--出参说明：
--编 写 者：罗虹
--编写时间：2018-06-21
--版本记录：版本号+时间+修改者+修改需求描述
--头注释结束-----------------------------------------------------------------------------------------
		N_COMMENT_PROBLEM   NUMBER(18);
		V_COMMENT_CODE      VARCHAR2(20);
		N_PATIENT_TYPE      NUMBER(18);
	BEGIN
 --住院门诊都有的规则
  --规则1-4 新生儿、婴幼儿未写明日、月龄 需要出生日期
  --规则1-14 医师未按照抗菌药物临床应用管理规定开具抗菌药物处方的
  --规则2-1 适应证不适宜的
  --规则2-2 遴选的药品不适宜的；（有禁忌的用药）
  --规则2-3 药品剂型或给药途径不适宜的
  --规则2-5 用法、用量不适宜的；
  --规则2-6 联合用药不适宜的
  --规则2-7 重复给药的
  --规则2-8 有配伍禁忌或者不良相互作用的；
  --规则3-3 无正当理由超说明书用药的 通过医嘱中有无禁忌药品说明判断
  --规则3-4 无正当理由为同一患者同时开具2种以上药理作用相同药物的 通过医嘱中有无禁忌药品说明判断

  --门诊病人规则
  --规则:1-3 药品收发记录中，配药人、审核人不外空
  --规则1-5 西药、中成药与中药饮片未分别开具处方的
  --规则1-10 开具处方未写临床诊断或临床诊断书写不全的
  --规则1-11 单张门急诊处方超过五种药品的
  --规则1-12 无特殊情况下，门诊处方超过7日用量，急诊处方超过3日用量
  --规则1-13 开具麻醉药品、精神药品、医疗用毒性药品、放射性药品等特殊管理药品处方未执行国家有关规定的。这个暂时不做
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
			IF N_PATIENT_TYPE = 1 THEN --门诊病人
			--规则1-4 新生儿、婴幼儿未写明日、月龄 需要出生日期
				CASE
					WHEN I.RECIPE_DATE - I.PATIENT_BIRTHDAY <= 28 THEN --新生儿
						IF INSTR(
								I.PATIENT_AGE
								,'天'
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
					) <= 12 THEN --婴儿
						IF INSTR(
								I.PATIENT_AGE
								,'月'
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
				IF I.RECIPE_TYPE = 4 THEN --规则1-5
					UPD_COMMENT_RESULT(
						I.RECIPE_NO
						,'1-5'
						,NULL
						,NULL
					);
				END IF;
				IF I.RECIPE_DIAG IS NULL THEN --规则1-10 
					UPD_COMMENT_RESULT(
						I.RECIPE_NO
						,'1-10'
						,NULL
						,NULL
					);
				END IF;
				IF I.RECIPE_DRUG_NUMBER > 5    AND I.RECIPE_TYPE <> 1 THEN --规则1-11
					UPD_COMMENT_RESULT(
						I.RECIPE_NO
						,'1-11'
						,NULL
						,NULL
					);
				END IF;
				IF I.DR_ANTI_LEVEL < I.ANTI_DRUG_MAX_LEVEL THEN --规则1-14
					UPD_COMMENT_RESULT(
						I.RECIPE_NO
						,'1-14'
						,NULL
						,NULL
					);
				END IF;
				IF N_PATIENT_TYPE = 1 THEN  --门诊病人 规则1-3
					--门诊病人 检查为药师的发药、配药记录
					SELECT COUNT(*)
					  INTO N_COMMENT_PROBLEM
					  FROM 药品收发记录@TO_ZLHIS A
					      ,门诊费用记录@TO_ZLHIS B
					 WHERE A.单据 = 8
					   AND B.NO = A.NO
					   AND B.NO = I.RECIPE_NO
					   AND (
						A.配药人 IS NULL
						    OR A."审核人" IS NULL
					);
					IF N_COMMENT_PROBLEM > 0 THEN
						UPD_COMMENT_RESULT(
							I.RECIPE_NO
							,'1-3'
							,NULL
							,NULL
						);
					END IF;
				ELSE --住院病人 检查为药师的发药、配药记录								
					SELECT COUNT(*)
					  INTO N_COMMENT_PROBLEM
					  FROM 药品收发记录@TO_ZLHIS A
					      ,住院费用记录@TO_ZLHIS B
					 WHERE A.单据 = 8
					   AND B.NO = A.NO
					   AND B.病人ID = I.PID
					   AND B.主页ID = I.PVID
					   AND (
						A.配药人 IS NULL
						    OR A."审核人" IS NULL
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
			--处理医嘱记录
  --
  --规则2-1 适应证不适宜的
  --规则2-2 遴选的药品不适宜的；（有禁忌的用药）
  --规则2-3 药品剂型或给药途径不适宜的
  --规则2-5 用法、用量不适宜的；
  --规则2-6 联合用药不适宜的
  --规则2-7 重复给药的
  --规则2-8 有配伍禁忌或者不良相互作用的；
  --规则3-3 无正当理由超说明书用药的 通过医嘱中有无禁忌药品说明判断
  --规则3-4 无正当理由为同一患者同时开具2种以上药理作用相同药物的 通过医嘱中有无禁忌药品说明判断
			FOR O IN ( SELECT A.ID
			                 ,A.医嘱内容
			                 ,A.天数
			                 ,A.紧急标志
			                 ,A.超量说明
			                 ,C.返回类型
			                 ,C.禁忌等级
			                 ,C.说明
			             FROM 病人医嘱记录@TO_ZLHIS A
			                 ,病人医嘱发送@TO_ZLHIS B
			                 ,V_合理用药结果记录@TO_ZLKBC C
			            WHERE A.医嘱状态 IN (
				7
				,8
				,9
			)
			   AND A.ID = B.医嘱ID
			   AND C.医嘱ID (+) = A.ID
			   AND B.NO = I.RECIPE_NO
			) LOOP
				IF ( ( O.天数 > 7    AND O.紧急标志 = 0 )     OR ( O.天数 > 3    AND O.紧急标志 = 1 ) )    AND O.超量说明 IS NULL    AND N_PATIENT_TYPE = 1 THEN --门诊病人;规则1-3
					UPD_COMMENT_RESULT(
						I.RECIPE_NO
						,'1-12'
						,O.ID
						,NULL
					);
				END IF;
				IF O.返回类型 IS NOT NULL THEN --合理用药审核结果
					CASE
						WHEN O.返回类型 = '001' THEN --适应症
							V_COMMENT_CODE   := '2-1';
						WHEN INSTR(
							',002,003,004,005,006,007,010'
							,',' || O.返回类型
						) > 0 THEN --禁忌症
							V_COMMENT_CODE   := '2-2';
						WHEN O.返回类型 = '009' THEN --药品剂型或给药途径不适宜的
							V_COMMENT_CODE   := '2-3';
						WHEN O.返回类型 = '008' THEN --用法、用量不适宜的；
							V_COMMENT_CODE   := '2-5';
						WHEN O.返回类型 = '012' THEN --联合用药不适宜的
							V_COMMENT_CODE   := '2-6';
						WHEN O.返回类型 = '011' THEN --重复给药的
							V_COMMENT_CODE   := '2-7';
						WHEN O.返回类型 = '013' THEN --有配伍禁忌或者不良相互作用的
							V_COMMENT_CODE   := '2-8';
						ELSE
							V_COMMENT_CODE   := NULL;
					END CASE;
					IF V_COMMENT_CODE IS NOT NULL THEN
						UPD_COMMENT_RESULT(
							I.RECIPE_NO
							,V_COMMENT_CODE
							,O.ID
							,O.医嘱内容 || '。出现问题:' || O.说明
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
  
  --人工点评
	PROCEDURE MANUAL_COMMENT_RESULT (
		C_INPUT IN CLOB
	) AS 
--头注释开始-----------------------------------------------------------------------------------------
--方法名称：人工点评处方
--功能说明：对点评的结果进行相应的保存、修改
--入参说明：c_input 为界面传入的json 包含RECIPE_NO、COMMENT_ITEM_CODE、ORDER_ID、COMMENT_CONTENT
--出参说明：
--编 写 者：吴开波
--编写时间：2018-06-23
--版本记录：版本号+时间+修改者+修改需求描述
--头注释结束-----------------------------------------------------------------------------------------
		C_COMMENT           CLOB;
		V_COMMENT_CONTENT   VARCHAR2(4000);
		N_COUNT             NUMBER(18);
	BEGIN
		C_COMMENT   := C_INPUT;
--- 如果点评为空，则点评内容 显示  COMMENT_ITEM_CODE项目对应的值
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
	--插入点评结果
	PROCEDURE INSERT_COMMENT_RESULT (
		RECIPE_NO_IN           IN VARCHAR2
		,COMMENT_ITEM_CODE_IN   IN VARCHAR2
		,ORDER_ID_IN            IN NUMBER
		,ITEM_CONTENT_IN        IN VARCHAR2
	) AS
--头注释开始-----------------------------------------------------------------------------------------
--方法名称：新增点评结果
--功能说明：新增一个问题的点评结果
--入参说明：RECIPE_NO_IN 处方,COMMENT_ITEM_CODE_IN 点评项目编码,ORDER_ID_IN 点评医嘱ID,ITEM_CONTENT_IN 点评项目内容
--出参说明：
--编 写 者：罗虹
--编写时间：2018-06-23
--版本记录：版本号+时间+修改者+修改需求描述
--头注释结束-----------------------------------------------------------------------------------------		
		V_ITEM_CONTENT   VARCHAR2(4000);
	BEGIN
	--如果没有点评问题的内容，就直接取点评项目的内容
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
--更新点评结果
	PROCEDURE UPD_COMMENT_RESULT (
		RECIPE_NO_IN           IN VARCHAR2
		,COMMENT_ITEM_CODE_IN   IN VARCHAR2
		,ORDER_ID_IN            IN NUMBER
		,ITEM_CONTENT_IN        IN VARCHAR2
	) AS
--头注释开始-----------------------------------------------------------------------------------------
--方法名称：更新点评结果
--功能说明：更新一个问题的点评结果
--入参说明：RECIPE_NO_IN 处方,COMMENT_ITEM_CODE_IN 点评项目编码,ORDER_ID_IN 点评医嘱ID,ITEM_CONTENT_IN 点评项目内容
--出参说明：
--编 写 者：罗虹
--编写时间：2018-06-23
--版本记录：版本号+时间+修改者+修改需求描述
--头注释结束-----------------------------------------------------------------------------------------
		V_ITEM_CONTENT   VARCHAR2(4000);
	BEGIN
		IF ITEM_CONTENT_IN IS NULL THEN  --没有点评内容，取点评项目的内容
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
		--没有更新就新增   
		IF SQL%ROWCOUNT = 0 THEN
			INSERT_COMMENT_RESULT(
				RECIPE_NO_IN
				,COMMENT_ITEM_CODE_IN
				,ORDER_ID_IN
				,ITEM_CONTENT_IN
			);
		END IF;
	END UPD_COMMENT_RESULT;
--删除点评结果
	PROCEDURE DEL_COMMENT_RESULT (
		RECIPE_NO_IN           IN VARCHAR2
		,COMMENT_ITEM_CODE_IN   IN VARCHAR2
		,ORDER_ID_IN            IN NUMBER
	)
		AS
--头注释开始-----------------------------------------------------------------------------------------
--方法名称：删除点评结果
--功能说明：删除一个问题的点评结果
--入参说明：RECIPE_NO_IN 处方,COMMENT_ITEM_CODE_IN 点评项目编码,ORDER_ID_IN 点评医嘱ID,ITEM_CONTENT_IN 点评项目内容
--出参说明：
--编 写 者：罗虹
--编写时间：2018-06-23
--版本记录：版本号+时间+修改者+修改需求描述
--头注释结束-----------------------------------------------------------------------------------------
	BEGIN
		DELETE COMMENT_RESULT
		 WHERE RECIPE_NO = RECIPE_NO_IN
		   AND (
			ORDER_ID = ORDER_ID_IN
			    OR ORDER_ID_IN IS NULL
		)
		   AND COMMENT_ITEM_CODE = COMMENT_ITEM_CODE_IN;
	END DEL_COMMENT_RESULT;
--删除点评抽取	
	PROCEDURE DEL_ECTRACT (
		EXTRACT_ID_IN NUMBER
	)
		AS
 --头注释开始-----------------------------------------------------------------------------------------
--方法名称：删除点评抽取
--功能说明：删除一个点评抽取
--入参说明：
--出参说明：
--编 写 者：罗虹
--编写时间：2018-07-03
--版本记录：版本号+时间+修改者+修改需求描述
--头注释结束-----------------------------------------------------------------------------------------
	BEGIN
		DELETE COMMENT_EXTRACT
		 WHERE EXTRACT_ID = EXTRACT_ID_IN;
	END DEL_ECTRACT;
END PKG_RECIPE_COMMENT;

/
