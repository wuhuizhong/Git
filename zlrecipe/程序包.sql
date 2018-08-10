--------------------------------------------------------
--  文件已创建 - 星期二-七月-24-2018   
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
  --头注释开始-----------------------------------------------------------------------------------------
  --方法名称：审核方案运行
  --功能说明：通过审核方案运行,选出需要审核的处方进入待审处方，其他的自动通过
  --入参说明：order_ids_in:待处理的医嘱id,reviewe_date 审核日期，缺省为当天，用于开发调试时，从获取医嘱程序中获得日期
  --出参说明：
  --编 写 者：罗虹
  --编写时间：2018-06-08
  --版本记录：版本号+时间+修改者+修改需求描述
  --头注释结束-----------------------------------------------------------------------------------------
	V_CND                 CLOB;
	V_QUOTE               VARCHAR2(1);--单引号
	V_REVIEWE_DATE        VARCHAR2(8);--处理日期
	V_SOLUTION_CND        CLOB;
	V_SQL                 CLOB;
	V_SOLUTION_TMP_CND    VARCHAR2(4000);--一个方案的条件串
	D_START               TIMESTAMP;--开始运行时间
	D_FINISH              TIMESTAMP;--结束运行时间
	N_REVIEWE_RECORDS     NUMBER(18);--需要审核的医嘱记录数
	N_NOREVIEWE_RECORDS   NUMBER(18);--不需要审核的医嘱记录数
	V_ORDER_IDS_IN        CLOB;
  --判断规则相关变量
  /*v_自动时间间隔 RECIPE_REVIEWE_PARA.PARA_VALUE%type;*/
	N_是否上岗                NUMBER(18);
	V_上午上班时间              REVIEWE_RECIPES.RECIPE_TIME%TYPE;
	V_上午下班时间              REVIEWE_RECIPES.RECIPE_TIME%TYPE;
	V_下午上班时间              REVIEWE_RECIPES.RECIPE_TIME%TYPE;
	V_下午下班时间              REVIEWE_RECIPES.RECIPE_TIME%TYPE;
	V_审核状态                NUMBER;
	V_最终审核状态              NUMBER;
	N_是否启用                NUMBER(18);
	N_PID                 NUMBER(18);
	N_PVID                NUMBER(18);
	N_PATIENT_TYPE        NUMBER(18);
	
--对应"含有"条件，多选是，查分为多个条件表达式 instr(字段,'条件值1')>0	or instr(字段,'条件值2')>0	
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
		V_DELIMITER         := ':'; --条件值之间用:分隔
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
	V_审核状态                := 0;
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
   /*select a.para_value into v_自动时间间隔 from  RECIPE_REVIEWE_PARA a where a.para_name='超时自动通过间隔时长';*/
   -- select sysdate into v_开始时间 from dual;
   --得出上午上班期间
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
	  INTO V_上午上班时间
	  FROM RECIPE_REVIEWE_PARA A
	 WHERE A.PARA_NAME = '上午上班时间';
   --得出上午下班期间
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
	  INTO V_上午下班时间
	  FROM RECIPE_REVIEWE_PARA A
	 WHERE A.PARA_NAME = '上午下班时间';
   --得出下午上班期间
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
	  INTO V_下午上班时间
	  FROM RECIPE_REVIEWE_PARA A
	 WHERE A.PARA_NAME = '下午上班时间';
   --得出下午下班期间
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
	  INTO V_下午下班时间
	  FROM RECIPE_REVIEWE_PARA A
	 WHERE A.PARA_NAME = '下午下班时间';

   
   --是否又人在岗
	SELECT COUNT(1)
	  INTO N_是否上岗
	  FROM PHARMACIST_WORK_RECORD A
	 WHERE A.REGISTER_DATE = TO_CHAR(
		SYSDATE
		,'yyyymmdd'
	)
	   AND A.UNREGISTER_TIME IS NULL;
   
   -- 得到病人就诊科室id 通过病人pid,pvid 
	SELECT COUNT(*)
	  INTO N_是否启用
	  FROM RECIPE_PATIENT_INFO A
	      ,REVIEWE_DEPT B
	 WHERE A.P_DEPT_ID = B.DEPT_ID
	   AND B.DEPT_STATUS = 1
	   AND A.PID = N_PID
	   AND A.PVID = N_PVID; 
   
 -- 先判断是否需要进入审方规则判断，如，未上班、未上岗期间 直接通过，无需进行审方规则判断
      -- 判断规则 审核状态 
	IF ( SYSDATE > V_上午上班时间    AND SYSDATE < V_上午下班时间 )     OR ( SYSDATE > V_下午上班时间    AND SYSDATE < V_下午下班时间 ) THEN
          --在上班期间
		IF N_是否上岗 > 0 THEN
               -- v_是否上岗=1 是上岗 则审核状态=-2 接收待审
			IF N_是否启用 > 0 THEN
                --在上班，上岗并且是启用科室 则进入审方规则
          
       -- 紧急医嘱 审核状态=20,先处理紧急医嘱的状态
				UPDATE REVIEWE_RECIPES A
				   SET
					A.REVIEWE_RESULT = 20
				 WHERE A.EMERGENCY = 1
				   AND A.PID = PID_IN
				   AND A.PVID = PVID_IN;     
             
    --循环处理所有启用方案
				FOR S IN ( SELECT A.REVIEWE_SOLUTION_ID
				                 ,A.REVIEWE_SOLUTION_NAME
				             FROM REVIEWE_SOLUTION A
				            WHERE A.REVIEWE_SOLUTION_STATUS = 1
				   AND REVIEWE_SOLUTION_TYPE = N_PATIENT_TYPE
				) LOOP
        --组合一个方案的条件
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
							WHEN D.ITEM_EXPRESSION = '包含于' THEN
								V_SOLUTION_TMP_CND   := '  instr(' || V_QUOTE || D.ITEM_VALUE || V_QUOTE || ',' || D.FIELD_NAME || ') > 0';
							WHEN D.ITEM_EXPRESSION = '含有' THEN
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
			   
	  --先删除待审核医嘱
				V_SQL                 := 'Delete wait_reviewe_recipe where instr(' || V_QUOTE || V_ORDER_IDS_IN || V_QUOTE || ',' || V_QUOTE || ',' || V_QUOTE || '||wait_reviewe_recipe.order_id || ' || V_QUOTE || ',' || V_QUOTE || ') > 0';
				EXECUTE IMMEDIATE V_SQL;
				--Dbms_Output.Put_Line(V_SQL);
      --需要审核的医嘱插入待审核医嘱表                          
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
|| V_CND || ' and instr(' || V_QUOTE || V_ORDER_IDS_IN || V_QUOTE || ',' || V_QUOTE || ',' || V_QUOTE || '||reviewe_recipes.order_id || ' || V_QUOTE || ',' || V_QUOTE || ') > 0 and reviewe_recipes.recipe_date=' || V_QUOTE || V_REVIEWE_DATE || V_QUOTE || ' --插入待审核医嘱';
				EXECUTE IMMEDIATE V_SQL;
			--Dbms_Output.Put_Line(V_SQL);
      --更新待审核医嘱为待审核状态                          
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
      --其余的更新为无需审核
				V_SQL                 := ' update reviewe_recipes set reviewe_result=20,reviewe_time=sysdate where reviewe_recipes.reviewe_result = -2 and instr(' || V_QUOTE || V_ORDER_IDS_IN || V_QUOTE || ',' || V_QUOTE || ',' || V_QUOTE || '||reviewe_recipes.order_id || ' || V_QUOTE || ',' || V_QUOTE || ') > 0 and reviewe_recipes.Receive_Date='
|| V_QUOTE || V_REVIEWE_DATE || V_QUOTE || ' --其余医嘱更新为无需审核';
				EXECUTE IMMEDIATE V_SQL;
				N_NOREVIEWE_RECORDS   := SQL%ROWCOUNT;
			ELSE
			--病人科室未启用审方
				V_审核状态   := 20;
			END IF;
		ELSE
               --上班期间，未上岗 
			V_审核状态   := 21;
		END IF;
	ELSE
         -- 非上班期间，
		V_审核状态   := 23;
	END IF;
	IF V_审核状态 > 0 THEN
		UPDATE REVIEWE_RECIPES A
		   SET
			A.REVIEWE_RESULT = V_审核状态
  -- ,A.reviewe_time = SYSDATE
		 WHERE INSTR(
			V_ORDER_IDS_IN
			,',' || A.ORDER_ID || ','
		) > 0
		   AND A.PID = N_PID
		   AND A.PVID = N_PVID
		   AND A.REVIEWE_RESULT =-2;
	END IF;
  --调用ZLHIS服务，更新医嘱通过状态
	D_FINISH              := SYSDATE;
EXCEPTION
	WHEN OTHERS THEN
		PKG_RECIPE_REVIEWE.INSERT_LOG(
			LOG_TITILE_IN    => '执行审方方案规则处理'
			,LOG_TYPE_IN      => 'E'
			,LOG_CONTENT_IN   => '开始时间:' || D_START || ',提取结束时间:' || SYSDATE || CHR(10) || '错误代码:' || CHR(10) || '执行语句' || V_SQL || CHR(10) || SQLCODE || CHR(10) || '错误信息：' || SQLERRM
		);
END REVIEWE_SOLUTION_RUN;

/
