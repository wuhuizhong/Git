--------------------------------------------------------
--  文件已创建 - 星期三-八月-29-2018   
--------------------------------------------------------
--------------------------------------------------------
--  DDL for Procedure REVIEWE_SOLUTION_RUN
--------------------------------------------------------
set define off;

  CREATE OR REPLACE  PROCEDURE "ZLRECIPE"."REVIEWE_SOLUTION_RUN" (
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
  N_COUNT               NUMBER(18);
	
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
   
   --是否有人在岗
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
   
   --获取该就诊ID病人对应（门诊或者住院）是否存在方案明细并且启用的方案。
   select count(*) INTO N_COUNT from reviewe_solution a,REVIEWE_SOLUTION_DETAIL b,RECIPE_PATIENT_INFO c
    where a.reviewe_solution_status=1
      and a.reviewe_solution_id=b.reviewe_solution_id
      and a.reviewe_solution_type=c.p_type
      and c.pvid=N_PVID
      and c.pid=N_PID ;
   
 -- 先判断是否需要进入审方规则判断，如，未上班、未上岗期间 直接通过，无需进行审方规则判断
      -- 判断规则 审核状态 
	IF ( SYSDATE > V_上午上班时间    AND SYSDATE < V_上午下班时间 )     OR ( SYSDATE > V_下午上班时间    AND SYSDATE < V_下午下班时间 ) THEN
          --在上班期间
		IF N_是否上岗 > 0 THEN
               -- v_是否上岗=1 是上岗 则审核状态=-2 接收待审
			IF N_是否启用 > 0 THEN
                --在上班，上岗并且是启用科室 则进入审方规则
         IF N_COUNT>0 THEN
           --该病人存在符合条件的审方方案，可以进入审方
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
            --无符合条件的审方条件，无需审核 审核状态=20
            V_审核状态   := 20;
           END IF;
       -- 紧急医嘱 审核状态=20,先处理紧急医嘱的状态
				
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
--------------------------------------------------------
--  DDL for Function ZLPINYINCODE
--------------------------------------------------------

  CREATE OR REPLACE  FUNCTION "ZLRECIPE"."ZLPINYINCODE" 
( 
  v_Instr   In Varchar2, 
  n_Mode    In Number := 0, 
  n_Initial In Number := 0, 
  v_Split   In Varchar2 := Null, 
  n_Mutil   In Number := 1, 
  n_Outnum  In Number := 10 
) Return Varchar2 As 
  n_Pos Number(2); 
  n_Js  Number(2); 
  n_In  Number(2); 
-- n_Out     Number(2); 
-- v_Mutil   Varchar2(200); 
  v_Ascii  Varchar2(2000); 
  v_Symbol Varchar2(5); 
  v_Spell  Zlpinyin.拼音%Type; 
  b_Symbol Number(1); 
-- v_Spell_m Zlpinyin.拼音%Type; 
  v_Text   Varchar2(2000); 
  v_Return Varchar2(2000); 
--定义用以处理多音节的可变数组 
  Type Ma_Type Is Table Of Varchar2(200); 
  Mutilascii Ma_Type := Ma_Type(); 
--去掉重复的发音内容 
  Function Getdistascii(v_Process Varchar2) Return Varchar2 Is 
    n_Max  Number(2); 
    n_In   Number(2); 
    v_Pro  Varchar2(2000); 
    v_Sa   Varchar2(1000); 
    v_Dist Varchar2(1000); 
  Begin 
    v_Pro := v_Process; 
    v_Sa  := Null; 
    While True Loop 
  --多音字 
      Select Length(v_Process) - Length(Replace(v_Process, ',', '')) + 1 Into n_Max From Dual; --取逗号出现次数 
      If n_Max Is Null Then 
        n_Max := 1; 
      End If; 
      v_Dist := Null; 
      For n_In In 1 .. n_Max Loop 
        If n_In = 1 And n_Max = 1 Then 
          v_Sa := v_Process; 
        Elsif n_In = 1 And n_Max > 1 Then 
          v_Sa := Substr(v_Process, 1, Instr(v_Process, ',', 1, n_In) - 1); 
        Elsif n_In < n_Max Then 
          v_Sa := Substr(v_Process, 
                         Instr(v_Process, ',', 1, n_In - 1) + 1, 
                         Instr(v_Process, ',', 1, n_In) - Instr(v_Process, ',', 1, n_In - 1) - 1); 
        Elsif n_In = n_Max Then 
          v_Sa := Substr(v_Process, Instr(v_Process, ',', 1, n_In - 1) + 1); 
        End If; 
        If Instr(',' || v_Dist || ',', ',' || v_Sa || ',') = 0 Then 
          If v_Dist Is Null Then 
            v_Dist := v_Sa; 
          Else 
            v_Dist := v_Dist || ',' || v_Sa; 
          End If; 
        End If; 
      End Loop; 
      If v_Dist Is Null Then 
        v_Dist := v_Process; 
      End If; 
      Return(v_Dist); 
    End Loop; 
  End; 
--递归函数，用来处理多单字 
  Function Getmutilascii 
  ( 
    v_Process Varchar2, 
    n_Pos     Number 
  ) Return Varchar2 Is 
    n_Max    Number(2); 
    n_Lp     Number(2); 
    n_In     Number(2); 
    v_Pro    Varchar2(2000); 
    v_Ma     Varchar2(2000); 
    v_Sa     Varchar2(1000); 
    v_Sa_Pro Varchar2(1000); 
  Begin 
    n_Lp  := n_Pos; 
    v_Pro := v_Process; 
    v_Sa  := Null; 
    v_Ma  := Null; 
    While True Loop 
  --多音字 
      Select Length(Mutilascii(n_Lp)) - Length(Replace(Mutilascii(n_Lp), ',', '')) + 1 Into n_Max From Dual; --取逗号出现次数 
      While v_Pro Is Not Null Loop 
    --依次取出源串 
        If Instr(v_Pro, ',') > 0 Then 
          v_Sa_Pro := Substr(v_Pro, 1, Instr(v_Pro, ',') - 1); 
          v_Pro    := Substr(v_Pro, Instr(v_Pro, ',') + 1); 
        Else 
          v_Sa_Pro := v_Pro; 
          v_Pro    := Null; 
        End If; 
    --拼接上当前多音字1,2,3,4 
        If n_Max Is Null Then 
          n_Max := 1; 
        End If; 
        For n_In In 1 .. n_Max Loop 
          If n_In = 1 And n_Max = 1 Then 
            v_Sa := Mutilascii(n_Lp); 
          Elsif n_In = 1 And n_Max > 1 Then 
            v_Sa := Substr(Mutilascii(n_Lp), 1, Instr(Mutilascii(n_Lp), ',', 1, n_In) - 1); 
          Elsif n_In < n_Max Then 
            v_Sa := Substr(Mutilascii(n_Lp), 
                           Instr(Mutilascii(n_Lp), ',', 1, n_In - 1) + 1, 
                           Instr(Mutilascii(n_Lp), ',', 1, n_In) - Instr(Mutilascii(n_Lp), ',', 1, n_In - 1) - 1); 
          Elsif n_In = n_Max Then 
            v_Sa := Substr(Mutilascii(n_Lp), Instr(Mutilascii(n_Lp), ',', 1, n_In - 1) + 1); 
          End If; 
          If n_Mode = 1 And (Length(v_Sa) > 1 Or Length(Mutilascii(n_Lp + 1)) > 1) Then 
            v_Sa := v_Sa || v_Split || v_Sa_Pro; 
          Else 
            v_Sa := v_Sa || v_Sa_Pro; 
          End If; 
          If v_Ma Is Not Null Then 
            v_Ma := v_Ma || ',' || v_Sa; 
          Else 
            v_Ma := v_Sa; 
          End If; 
        End Loop; 
      End Loop; 
      If v_Ma Is Null Then 
        v_Ma := Mutilascii(n_Lp); 
      End If; 
      Return(v_Ma); 
    End Loop; 
  End; 
Begin 
  If v_Instr Is Null Then 
    Return ''; 
  End If; 
  v_Text := v_Instr; 
  n_Js   := n_Outnum; 
  If n_Js = 0 Or n_Js > Length(v_Text) Then 
    n_Js := Length(v_Text); 
  End If; 
  Mutilascii.Extend(n_Js); 
--循环将简码赋值到数组中; 
  n_Js := 1; 
  While v_Text Is Not Null Loop 
    b_Symbol := 0; 
    v_Symbol := Substr(v_Text, n_Js, 1); 
    Select Asciistr(v_Symbol) Into v_Ascii From Dual; 
    If v_Ascii <> v_Symbol And Substr(v_Ascii, 1, 1) = '\' Then 
  --不同则说明是汉字 
      v_Ascii := To_Number(Substr(v_Ascii, 2), 'XXXX'); 
      Begin 
        Select 拼音 Into v_Spell From Zlpinyin Where 汉字 = v_Ascii; 
        b_Symbol := 1; 
      Exception 
        When Others Then 
          v_Spell := v_Symbol; 
      End; 
      If b_Symbol = 1 Then 
    --去掉所有声调(数字) 
        v_Spell := Replace(v_Spell, '0', ''); 
        v_Spell := Replace(v_Spell, '1', ''); 
        v_Spell := Replace(v_Spell, '2', ''); 
        v_Spell := Replace(v_Spell, '3', ''); 
        v_Spell := Replace(v_Spell, '4', ''); 
        v_Spell := Replace(v_Spell, '5', ''); 
        v_Spell := Getdistascii(v_Spell); 
    --按入参规则处理 
        v_Ascii := Null; 
        If n_Mode = 0 Then 
      --取首字母 
          While True Loop 
            If v_Ascii Is Null Then 
              v_Ascii := Substr(v_Spell, 1, 1); 
            Else 
              v_Ascii := v_Ascii || ',' || Substr(v_Spell, 1, 1); 
            End If; 
            n_In := Instr(v_Spell, ',', 1); 
            If n_In > 0 Then 
              v_Spell := Substr(v_Spell, n_In + 1); 
            Else 
              Exit; 
            End If; 
          End Loop; 
          v_Ascii := Upper(v_Ascii); 
        Else 
          v_Ascii := Lower(v_Spell); 
          If n_Initial = 0 Then 
        --全部大写 
            v_Ascii := Upper(v_Ascii); 
          Else 
        --首字母大写 
            n_Pos   := 2; 
            v_Ascii := Upper(Substr(v_Ascii, 1, 1)) || Substr(v_Ascii, 2); 
            While n_Pos <= Length(v_Ascii) Loop 
              If Substr(v_Ascii, n_Pos - 1, 1) = ',' Then 
                v_Ascii := Substr(v_Ascii, 1, n_Pos - 1) || Upper(Substr(v_Ascii, n_Pos, 1)) || 
                           Substr(v_Ascii, n_Pos + 1); 
              End If; 
              n_Pos := n_Pos + 1; 
            End Loop; 
          End If; 
        End If; 
        Mutilascii(n_Js) := v_Ascii; 
      Else 
        Mutilascii(n_Js) := v_Symbol; 
      End If; 
    Else 
      Mutilascii(n_Js) := v_Ascii; 
    End If; 
    n_Js := n_Js + 1; 
    If n_Js > Mutilascii.Count Then 
      Exit; 
    End If; 
  End Loop; 
  n_In := Mutilascii.Count; 
  While n_In > 0 Loop 
    v_Return := Getmutilascii(v_Return, n_In); 
    n_In     := n_In - 1; 
  End Loop; 
  If n_Mutil = 0 Then 
    Return Substr(v_Return || ',', 1, Instr(v_Return || ',', ',', 1) - 1); 
  Else 
    Return v_Return; 
  End If; 
Exception 
  When Others Then 
    Return ''; 
End Zlpinyincode;

/
--------------------------------------------------------
--  DDL for Function GET_TAB_JSON_COL
--------------------------------------------------------

  CREATE OR REPLACE  FUNCTION "ZLRECIPE"."GET_TAB_JSON_COL" (tab_in varchar2)
  return sys_refcursor authid current_user is
  result sys_refcursor;
begin
  open result for
    select '(select ' || substr(col_name, 1, length(col_name) - 1) ||
           '  from json_table(Input_In,' || '''' || '$."' || lower(tab_in) ||
           '"[*]' || '''' || ' Columns  ' ||
           substr(tojson_col, 1, length(tojson_col) - 1) || '))' as tojson_col,
           'update ' || lower(tab_in) || ' a Set ' ||
           substr(update_col, 1, length(update_col) - 1) as update_col,
           substr(select_col, 1, length(select_col) - 1) as select_col,
           substr(values_col, 1, length(values_col) - 1) as values_col,
           '{"' || lower(tab_in) || '":[{' ||
           substr(json_col, 1, length(json_col) - 1) || '}]}' as json_col,
           '''{"' || lower(tab_in) || '":[{'' || ''' || substr(json_str, 7) ||
           ' || ''}]}''' as json_str,
           substr(col_name, 1, length(col_name) - 1) as col_name,
           'insert into ' || lower(tab_in) || '    (' ||
           substr(col_name, 1, length(col_name) - 1) || ') values(' ||
           substr(values_col, 1, length(values_col) - 1) || ');' as insert_col
      from (select listagg(lower(update_col)) within group(order by column_id) as update_col,
                   listagg(lower(tojson_col)) within group(order by column_id) as tojson_col,
                   listagg(lower(select_col)) within group(order by column_id) as select_col,
                   listagg(lower(values_col)) within group(order by column_id) as values_col,
                   listagg(lower(json_col)) within group(order by column_id) as json_col,
                   listagg(lower(json_str)) within group(order by column_id) as json_str,
                   listagg(lower(col_name)) within group(order by column_id) as col_name
              from (select update_col,
                           tojson_col,
                           select_col,
                           values_col,
                           json_col,
                           col_name,
                           column_id,
                           json_str
                      from (select 'a.' || a.column_name || '=v_q.' ||
                                   a.column_name || ',' as update_col,
                                   a.column_name || ' Number(' ||
                                   a.data_precision || ',' || a.data_scale || ')' ||
                                   ' Path ' || '''' || '$."' || a.column_name || '"' || '''' || ',' ||
                                   ' --' as tojson_col,
                                   'a.' || a.column_name || ',' as select_col,
                                   'v_q.' || a.column_name || ',' as values_col,
                                   '"' || a.column_name || '":"' || b.comments || '",' as json_col,
                                   a.column_name || ',' as col_name,
                                   a.column_id,
                                   ' || '',"' || a.column_name || '":'' || 1' as json_str
                              from all_tab_columns a, all_col_comments b
                             where a.table_name = upper(tab_in)
                               and b.owner = a.owner
                               and b.table_name = a.table_name
                               and b.column_name = a.column_name
                               and a.data_type = 'NUMBER'
                               and column_id is not null
                            union all
                            select 'a.' || a.column_name || '=v_q.' ||
                                   a.column_name || ',',
                                   a.column_name || ' Varchar2(' ||
                                   a.data_length || ')' || ' Path ' || '''' ||
                                   '$."' || a.column_name || '"' || '''' || ',',
                                   'a.' || a.column_name || ',' as select_col,
                                   'v_q.' || a.column_name || ',' as values_col,
                                   '"' || a.column_name || '":' || '"' ||
                                   b.comments || '",' as json_col,
                                   a.column_name || ',' as col_name,
                                   a.column_id,
                                   ' || '',"' || a.column_name ||
                                   '":"'' ||  1 || ''"''' as json_str
                              from all_tab_columns a, all_col_comments b
                             where a.table_name = upper(tab_in)
                               and b.owner = a.owner
                               and b.table_name = a.table_name
                               and b.column_name = a.column_name
                               and a.data_type = 'VARCHAR2'
                               and column_id is not null
                            union all
                            select 'a.' || a.column_name || '=v_q.' ||
                                   a.column_name || ',',
                                   a.column_name || ' Varchar2(40)' ||
                                   ' Path ' || '''' || '$."' || a.column_name || '"' || '''' || ',',
                                   'a.' || a.column_name || ',' as select_col,
                                   'v_q.' || a.column_name || ',' as values_col,
                                   '"' || a.column_name || '":' || '"' ||
                                   b.comments || '",' as json_col,
                                   a.column_name || ',' as col_name,
                                   a.column_id,
                                   ' || '',"' || a.column_name ||
                                   '":"'' || To_Char(' ||
                                   'sysdate, ''yyyy-MM-dd HH24:mi:ss'')  || ''"''' as json_str
                              from all_tab_columns a, all_col_comments b
                             where a.table_name = upper(tab_in)
                               and b.owner = a.owner
                               and b.table_name = a.table_name
                               and b.column_name = a.column_name
                               and a.data_type = 'DATE'
                               and column_id is not null)
                     order by column_id)
             order by column_id);
  return(result);
end get_tab_json_col;

/
--------------------------------------------------------
--  DDL for Function GET_HAS_CND
--------------------------------------------------------

  CREATE OR REPLACE  FUNCTION "ZLRECIPE"."GET_HAS_CND" (
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
	V_DELIMITER         := ':';
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

/
