CREATE OR REPLACE PACKAGE PKG_RECIPE_REVIEWE IS
  --处方审核
  -- Author  : ZLAPEX开发组
  -- Created : 2018/6/6 9:43:08
  -- Purpose : 

  --药师上岗[001]
  PROCEDURE PHARMACIST_REGISTER(USER_ID_IN IN VARCHAR2);

  --药师下岗[002]
  PROCEDURE PHARMACIST_UNREGISTER(USER_ID_IN IN VARCHAR2);

  --药师审方[003]
  PROCEDURE PHARMACIST_REVIEWE(INPUT_IN IN CLOB);

  -- 接收处方信息
  PROCEDURE RECEIVE_RECIPES(prescription IN CLOB);

  -- 接单，分配/刷新 药师审方 任务
  PROCEDURE ORDER_RECEIVING(USER_ID     IN VARCHAR2,
                            P_TYPE_IN   IN NUMBER,
                            ORDER_SCOPE IN NUMBER,
                            OUTPUT_OUT  OUT CLOB);

  -- 检查超时待审核处方
  PROCEDURE TIMEOUT_REVIEWE;

  --查询病人处方审核结果
  PROCEDURE GET_RECIPES_REVIEWE_RESULT(PID_IN    IN NUMBER,
                                       PVID_IN   IN NUMBER,
                                       RESULTOUT OUT SYS_REFCURSOR);
   --查询病人处方所有审核结果
  PROCEDURE GET_RECIPES_REVIEWE_RESULT_ALL(PID_IN    IN NUMBER,
                                           PVID_IN   IN NUMBER,
                                           RESULTOUT OUT SYS_REFCURSOR);
                                       
  --编辑审核方案
  PROCEDURE EDIT_REVIEWE_SOLUTION(INPUT_IN IN CLOB, EDIT_TYPE_IN IN NUMBER);    
  
  --编辑审核方案明细
  PROCEDURE EDIT_REVIEWE_SOLUTION_DETAIL(INPUT_IN IN CLOB, EDIT_TYPE_IN IN NUMBER);                               
  -----------------ATOM------------------------------------------
  --新增药师工作记录
  PROCEDURE INSERT_PHARMACIST_WORK_RECORD(INPUT_IN IN CLOB);

  --修改药师工作记录
  PROCEDURE UPD_PHARMACIST_WORK_RECORD(INPUT_IN IN CLOB);
  
  --药师科室分配设置
  Procedure Upd_pharmacist_reviewe_dept(dept_id in clob,user_id in varchar2,V_Current_USER_CODE in varchar2);
  
  --新增药师/修改药师 管理
 Procedure Upd_recipe_user(
               V_Current_USER_NAME in varchar2,
               V_USER_CODE in varchar2,
               V_USER_NAME IN VARCHAR2,
               V_USER_JOB in varchar2,
               V_USER_STATUS in  number,
               N_change number,
               V_WEB_PASSWORD IN VARCHAR2,
               N_IS_ADMIN  NUMBER);
               
   --新增药师 apex登录用户
    Procedure CREATE_USER(
              V_USER_ID in varchar2,
              V_WEB_PASSWORD in varchar2,
              N_STATUS_IN in NUMBER,
              N_ADMIN IN NUMBER
              );
   -- 修改apex用户
   Procedure EDIT_USER(
       p_user_name in varchar2,
       status in NUMBER,
       N_ADMIN IN NUMBER
        );
 --科室启用配置
 Procedure DEPT_START( DEPT_NAME_IN in varchar2,  USER_NAME_IN in varchar2);

--取消启用科室
 Procedure DEL_REVIEWE_DEPT( DEPT_NAME_IN in varchar2);

  --修改门诊处方住院医嘱记录
  PROCEDURE UPD_REVIEWE_RECIPES(INPUT_IN IN CLOB);

  --删除待审记录
  PROCEDURE DEL_WAIT_REVIEWE_RECIPE(INPUT_IN IN CLOB);

  --记录运行日志
  PROCEDURE INSERT_LOG(LOG_TITILE_IN  IN VARCHAR2,
                       LOG_TYPE_IN    IN VARCHAR2,
                       LOG_Content_IN IN CLOB);

  --医生填写拒绝药师不通过理由
  PROCEDURE UPD_DR_REFUSE_COMMENT(RECIPES_IN IN CLOB);
  --向ZLHIS发送审方结果消息
  PROCEDURE SEND_MESSAGE_TO_ZLHIS(PID_IN            IN NUMBER,
                                  PVID_IN           IN NUMBER,
                                  REVIEWE_RESULT_IN IN NUMBER,
                                  PHARMACIST_NAME   IN VARCHAR2 := '');
  --修改审核方案
  PROCEDURE UPD_REVIEWE_SOLUTION(INPUT_IN IN CLOB);
  
  --审方方案设计
   Procedure Prescriptions_Regularity( V_field_name in varchar2, C_REVIEWE_SOLUTION_OUT out clob);
  
  --新增审核方案
  PROCEDURE INSERT_REVIEWE_SOLUTION(INPUT_IN IN CLOB);
  
  --保存方案时，验证审核方案准确性
  PROCEDURE VERIFY_SOLUTION( V_REVIEWE_SOLUTION_ID IN VARCHAR2);
 
  --删除审核方案
  PROCEDURE DEL_REVIEWE_SOLUTION(REVIEWE_SOLUTION_ID_IN IN VARCHAR2);
  
  --修改审核方案明细
  Procedure Upd_Reviewe_Solution_Detail(Input_In In Clob);
  
  --新增审核方案明细
  Procedure Insert_Reviewe_Solution_Detail(Input_In In Clob);

  --删除审核方案明细
  Procedure Del_Reviewe_Solution_Detail(Input_In In Clob);
      
  --审方系统安装后初始化
  Procedure Recipe_Reviewe_comment_Init;
END PKG_RECIPE_REVIEWE;

/


CREATE OR REPLACE PACKAGE BODY PKG_RECIPE_REVIEWE IS

  --药师上岗[001]
	PROCEDURE PHARMACIST_REGISTER (
		USER_ID_IN IN VARCHAR2
	) AS
    --头注释开始-----------------------------------------------------------------------------------------
    --方法名称：药师上岗[001]
    --功能说明：药师上岗[001]
    --入参说明：User_ID_In In Varchar2
    --出参说明：
    --编 写 者：白天
    --编写时间：2018-06-06
    --版本记录：版本号+时间+修改者+修改需求描述
    --头注释结束-----------------------------------------------------------------------------------------
		V_USER_NAME        VARCHAR2(80);
		N_REGISTER_COUNT   NUMBER;
		C_INPUT            CLOB;
	BEGIN
		IF USER_ID_IN IS NOT NULL THEN
			SELECT MAX(USER_NAME)
			  INTO V_USER_NAME
			  FROM RECIPE_USER
			 WHERE USER_CODE = UPPER(USER_ID_IN);
      --重复上岗
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

  --药师下岗[002]
	PROCEDURE PHARMACIST_UNREGISTER (
    USER_ID_IN IN VARCHAR2
  ) AS
    --头注释开始-----------------------------------------------------------------------------------------
    --方法名称：药师下岗[002]
    --功能说明：药师下岗[002]
    --入参说明：User_ID_In In Varchar2
    --出参说明：
    --编 写 者：白天
    --编写时间：2018-06-06
    --版本记录：2018-07-12 增加下线，接单待审回退
    --头注释结束-----------------------------------------------------------------------------------------
    J_UNREGISTER   JSON_OBJECT_T;
    C_UNREGISTER   CLOB;
  BEGIN
    IF USER_ID_IN IS NOT NULL THEN
      ----回推已接单处方
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

  --药师审方[003]
	PROCEDURE PHARMACIST_REVIEWE (
		INPUT_IN IN CLOB
	) AS
    --头注释开始-----------------------------------------------------------------------------------------
    --方法名称：药师审方[003]
    --功能说明：药师审方[003]
    --入参说明：Input_In[{"pid": ,"pvid":"","order_id": ,"pharmacist_id":"","reviewe_result": ,"reviewe_comment":""}]
    --出参说明：
    --编 写 者：白天
    --编写时间：2018-06-12
    --版本记录：版本号+时间+修改者+修改需求描述
    --头注释结束-----------------------------------------------------------------------------------------
		N_NO_PASS        NUMBER(18);
		N_PID            NUMBER(18);
		N_PVID           NUMBER(18);
		N_PATIENT_TYPE   NUMBER(18);
		V_PHARMACIST     VARCHAR2(80);
	BEGIN
		PKG_RECIPE_REVIEWE.INSERT_LOG(
			LOG_TITILE_IN    => '审方提交'
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
      --删除待审记录（子表）
			PKG_RECIPE_REVIEWE.DEL_WAIT_REVIEWE_RECIPE(INPUT_IN);
      --修改门诊处方住院医嘱记录（主表）
			PKG_RECIPE_REVIEWE.UPD_REVIEWE_RECIPES(INPUT_IN);
		END IF;
		SELECT MAX(P_TYPE)
		  INTO N_PATIENT_TYPE
		  FROM RECIPE_PATIENT_INFO
		 WHERE PID = N_PID
		   AND PVID = N_PVID;
		IF N_PATIENT_TYPE = 1 THEN
      --门诊病人，全部通知
			SEND_MESSAGE_TO_ZLHIS(
				N_PID
				,N_PVID
				,1
				,V_PHARMACIST
			);
		ELSE
			IF N_NO_PASS > 0 THEN
        ----住院病人，有未通过才通知
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
				'药师审方'
				,'E'
				,INPUT_IN
			);
	END PHARMACIST_REVIEWE;

  -- 接收处方信息、病人基本信息
	PROCEDURE RECEIVE_RECIPES (
		PRESCRIPTION IN CLOB
	) IS
    --头注释开始-----------------------------------------------------------------------------------------
    --方法名称：接收医嘱信息
    --功能说明：接收门诊、住院新开医嘱信息、
    --入参说明：合理用药传入医嘱信息XML
    --出参说明：pid、pvid、医嘱ID串
    --编 写 者：吴开波
    --编写时间：2018-06-13
    --版本记录：版本号+时间+修改者+修改需求描述
    --头注释结束-----------------------------------------------------------------------------------------
		T_开始时间         REVIEWE_RECIPES.RECIPE_TIME%TYPE;
		T_结束时间         REVIEWE_RECIPES.RECIPE_TIME%TYPE;
    --记录 医嘱表的操作数
		N_修改_RECIPE    NUMBER;
		N_插入_RECIPE    NUMBER;
    --记录 病人基本信息表中的操作数
		N_修改_PATIENT   NUMBER;
		N_插入_PATIENT   NUMBER;
		N_自动时间间隔       RECIPE_REVIEWE_PARA.PARA_VALUE%TYPE;
		C_ORDER_ID     CLOB;
    --病人基本信息参数
		N_PID          NUMBER(20);
		N_PVID         NUMBER(20);
		V_姓名           VARCHAR2(50);
		V_性别           VARCHAR2(10);
		V_年龄           VARCHAR2(20);
		V_出生日期         VARCHAR2(50);
		V_入院日期         VARCHAR2(50);
		V_病生理情况        VARCHAR2(500);
		V_出院日期         VARCHAR2(20);
		V_主要诊断         VARCHAR2(100);
		V_门诊号          VARCHAR2(20);
		V_住院号          VARCHAR2(20);
		V_床号           VARCHAR2(20);
		V_就诊科室         VARCHAR2(50);
		V_就诊科室ID       VARCHAR2(36);
		N_婴儿           NUMBER(1);
		N_HIS_NO       NUMBER(3);
		T_当前时间         REVIEWE_RECIPES.RECIPE_TIME%TYPE;
		V_就诊病区         VARCHAR2(50);
		V_就诊病区ID       VARCHAR2(36);
		N_病人来源         NUMBER(1);
		N_提交类型         NUMBER(1);
		X_RECIPES      SYS.XMLTYPE;
	BEGIN
		X_RECIPES      := XMLTYPE.CREATEXML(PRESCRIPTION);
		C_ORDER_ID     := '';
		N_修改_PATIENT   := 0;
		N_插入_PATIENT   := 0;
		N_插入_RECIPE    := 0;
		N_修改_RECIPE    := 0;

		SELECT MAX(提交类型)
		  INTO N_提交类型
		  FROM XMLTABLE ( '/details_xml/patient_info' PASSING X_RECIPES COLUMNS 提交类型 NUMBER(20) PATH '//info[@name="提交类型"]/@value' );
		IF N_提交类型 = 1 THEN
			RETURN;
		END IF;
		
		SELECT A.PARA_VALUE
		  INTO N_自动时间间隔
		  FROM RECIPE_REVIEWE_PARA A
		 WHERE A.PARA_NAME = '超时自动通过间隔时长';

		
		SELECT A.病人ID
		      ,A.就诊ID
		      ,A.姓名
		      ,A.性别
		      ,A.年龄
		      ,A.出生日期
		      ,A.入院日期
		      ,DECODE(
			A.妊娠
			,1
			,'妊娠|'
			,''
		) || DECODE(
			A.哺乳
			,1
			,'哺乳|'
			,''
		) || DECODE(
			A.肝功能不全
			,1
			,'肝功能不全|'
			,''
		) || DECODE(
			A.严重肝功能不全
			,1
			,'严重肝功能不全|'
			,''
		) || DECODE(
			A.肾功能不全
			,1
			,'肾功能不全|'
			,''
		) || DECODE(
			A.严重肾功能不全
			,1
			,'严重肾功能不全|'
			,''
		) 病生理情况
		      ,A.主要诊断
		      ,A.门诊号
		      ,A.住院号
		      ,A.床号
		      ,A.就诊科室
		      ,A.就诊科室ID
		      ,A.婴儿
		      ,A.HIS_NO
		      ,A.就诊病区
		      ,A.就诊病区ID
		      ,A.病人来源
		  INTO
			N_PID
		,N_PVID
		,V_姓名
		,V_性别
		,V_年龄
		,V_出生日期
		,V_入院日期
		,V_病生理情况
		,V_主要诊断
		,V_门诊号
		,V_住院号
		,V_床号
		,V_就诊科室
		,V_就诊科室ID
		,N_婴儿
		,N_HIS_NO
		,V_就诊病区
		,V_就诊病区ID
		,N_病人来源
		  FROM XMLTABLE ( '/details_xml/patient_info' PASSING X_RECIPES COLUMNS 病人ID NUMBER(20) PATH '//info[@name="病人ID"]/@value',就诊ID NUMBER(20) PATH '//info[@name="就诊ID"]/@value',姓名 VARCHAR2(30) PATH '//info[@name="姓名"]/@value',性别 VARCHAR2(12) PATH '//info[@name="性别"]/@value'
,年龄 VARCHAR2(10) PATH '//info[@name="年龄"]/@value',出生日期 VARCHAR2(20) PATH '//info[@name="出生日期"]/@value',入院日期 VARCHAR2(20) PATH '//info[@name="入院日期"]/@value',妊娠 VARCHAR2(50) PATH '//info[@name="妊娠"]/@value',哺乳 VARCHAR2(50) PATH '//info[@name="哺乳"]/@value',肝功能不全 VARCHAR2
(50) PATH '//info[@name="肝功能不全"]/@value',严重肝功能不全 VARCHAR2(50) PATH '//info[@name="严重肝功能不全"]/@value',肾功能不全 VARCHAR2(50) PATH '//info[@name="肾功能不全"]/@value',严重肾功能不全 VARCHAR2(50) PATH '//info[@name="严重肾功能不全"]/@value',主要诊断 VARCHAR2(200) PATH '//info[@name="诊断名称"]/@value'
,门诊号 VARCHAR2(20) PATH '//info[@name="门诊号"]/@value',住院号 VARCHAR2(20) PATH '//info[@name="住院号"]/@value',床号 VARCHAR2(20) PATH '//info[@name="床号"]/@value',就诊科室 VARCHAR2(20) PATH '//info[@name="就诊科室"]/@value',就诊科室ID VARCHAR2(36) PATH '//info[@name="就诊科室ID"]/@value',婴儿 NUMBER
(1) PATH '//info[@name="婴儿"]/@value',HIS_NO NUMBER(3) PATH '//info[@name="HIS_NO"]/@value',就诊病区 VARCHAR2(20) PATH '//info[@name="就诊病区"]/@value',就诊病区ID VARCHAR2(36) PATH '//info[@name="就诊病区ID"]/@value',病人来源 NUMBER(1) PATH '//info[@name="病人来源"]/@value' ) A;


    -- 如果 病人id、就诊id重复则 修改。  
		UPDATE RECIPE_PATIENT_INFO A
		   SET A.P_NAME = V_姓名,A.P_GENDER = V_性别
		,A.P_AGE = V_年龄
		,A.P_BIRTHDAY = TO_DATE(
				V_出生日期
				,'yyyy-mm-dd hh24:mi:ss'
			)
		,A.P_IN_TIME = TO_DATE(
				V_入院日期
				,'yyyy-mm-dd hh24:mi:ss'
			)
		,A.P_PHYS = V_病生理情况
		,A.P_MAJOR_DIAG = V_主要诊断
		,A.P_OUT_NO = V_门诊号
		,A.P_IN_NO = V_住院号
		,A.P_BED_NO = V_床号
		,A.P_DEPT_NAME = V_就诊科室
		,A.P_DEPT_ID = V_就诊科室ID
		,A.P_NURSING_DEPT_NAME = V_就诊病区
		,A.P_NURSING_DEPT_ID = V_就诊病区ID
		,A.P_TYPE = N_病人来源
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
				,V_姓名
				,V_性别
				,V_年龄
				,TO_DATE(
					V_出生日期
					,'yyyy-mm-dd hh24:mi:ss'
				)
				,TO_DATE(
					V_入院日期
					,'yyyy-mm-dd hh24:mi:ss'
				)
				,V_病生理情况
				,V_主要诊断
				,V_门诊号
				,V_住院号
				,V_床号
				,V_就诊科室
				,V_就诊科室ID
				,V_就诊病区ID
				,N_病人来源
				,V_就诊病区
			);
      -- i_插入 记录插入数据条数  
			N_插入_PATIENT   := N_插入_PATIENT + 1;
		ELSE
      --记录修改数据条数
			N_修改_PATIENT   := N_修改_PATIENT + 1;
		END IF;
  
    --获取当前时间
		T_当前时间         := SYSDATE;
    -- 循环医嘱信息

		IF N_PID IS NOT NULL THEN
		
			PKG_RECIPE_REVIEWE.INSERT_LOG(
				LOG_TITILE_IN    => 'ZLHIS保存医嘱'
				,LOG_TYPE_IN      => 'T'
				,LOG_CONTENT_IN   => null
			);
		
			FOR R_ROW IN ( SELECT A.*
			                 FROM XMLTABLE ( '/details_xml/medicine_info/medicine' PASSING X_RECIPES COLUMNS 医嘱ID NUMBER(18) PATH '//info[@name="医嘱ID"]/@value',输液组号 NUMBER(18) PATH '//info[@name="输液组号"]/@value',本位码 VARCHAR2(400) PATH '//info[@name="本位码"]/@value',医嘱期效 NUMBER(1) PATH '//info[@name="医嘱期效"]/@value'
,开嘱时间 VARCHAR2(40) PATH '//info[@name="开嘱时间"]/@value',紧急标志 NUMBER(1) PATH '//info[@name="紧急标志"]/@value',开嘱医生 VARCHAR2(80) PATH '//info[@name="开嘱医生"]/@value',医生职称 VARCHAR2(20) PATH '//info[@name="医生职称"]/@value',医嘱内容 VARCHAR2(1000) PATH '//info[@name="医嘱内容"]/@value',医生抗菌药物等级
NUMBER(1) PATH '//info[@name="医生抗菌药物等级"]/@value',用药天数 NUMBER(18,5) PATH '//info[@name="用药天数"]/@value',剂型 VARCHAR2(50) PATH '//info[@name="剂型"]/@value',药品抗菌药物等级 NUMBER(1) PATH '//info[@name="药品抗菌药物等级"]/@value',毒理分类 VARCHAR2(50) PATH '//info[@name="毒理分类"]/@value',超量说明
VARCHAR2(500) PATH '//info[@name="超量说明"]/@value',用药目的 VARCHAR2(400) PATH '//info[@name="用药目的"]/@value',药品禁忌说明 VARCHAR2(1000) PATH '//info[@name="药品禁忌说明"]/@value',药品禁忌等级 VARCHAR2(50) PATH '//info[@name="药品禁忌等级"]/@value',药品禁忌类型 VARCHAR2(1000) PATH '//info[@name="药品禁忌类型"]/@value'
,处方诊断 VARCHAR2(500) PATH '//info[@name="处方诊断"]/@value',给药途径 VARCHAR2(400) PATH '//info[@name="给药途径"]/@value',给药途径名称 VARCHAR2(400) PATH '//info[@name="给药途径名称"]/@value',单次用量 NUMBER(18,5) PATH '//info[@name="单次量"]/@value',单日用量 NUMBER(18,5) PATH '//info[@name="单日量"]/@value'
,剂量单位 VARCHAR2(50) PATH '//info[@name="计量单位"]/@value',给药频次 VARCHAR2(50) PATH '//info[@name="给药频次名称"]/@value',医嘱状态 NUMBER(2) PATH '//info[@name="医嘱状态"]/@value' ) A
			                WHERE A.医嘱状态 = 1
			) LOOP
				UPDATE REVIEWE_RECIPES A
				   SET A.ORDER_STAT = R_ROW.医嘱期效,A.ORDER_BABY = N_婴儿
				,A.RECIPE_TIME = TO_DATE(
						R_ROW.开嘱时间
						,'yyyy-mm-dd hh24:mi:ss'
					)
				,A.RECIPE_DATE = TO_CHAR(
						TO_DATE(
							R_ROW.开嘱时间
							,'yyyy-mm-dd hh24:mi:ss'
						)
						,'yyyymmdd'
					)
				,A.EMERGENCY = R_ROW.紧急标志
				,A.RECIPE_DR = R_ROW.开嘱医生
				,A.ORDER_GROUP_ID = R_ROW.输液组号
				,A.RECIPE_DR_TITLE = R_ROW.医生职称
				,A.ORDER_COMMENT = R_ROW.医嘱内容
				,A.DR_ANTI_LEVEL = R_ROW.医生抗菌药物等级
				,A.DRUG_BASE_CODE = R_ROW.本位码
				,A.DRUG_FORM = R_ROW.剂型
				,A.DRUG_TIME_INTERVAL = R_ROW.给药频次
				,A.DRUG_ROUTE = R_ROW.给药途径
				,A.DRUG_ROUTE_NAME = R_ROW.给药途径名称
				,A.DRUG_ONCE_DOSEAGE = R_ROW.单次用量
				,A.DRUG_DAY_DOSEAGE = R_ROW.单日用量
				,A.DRUG_DOSEAGE_UNIT = R_ROW.剂量单位
				,A.DRUG_USED_DAYS = R_ROW.用药天数
				,A.OVER_DOSEAGE_REASON = R_ROW.超量说明
				,A.DRUG_TOXICITY = R_ROW.毒理分类
				,A.DRUG_ANTI_LEVEL = R_ROW.药品抗菌药物等级
				,A.ANTI_DRUG_REASON = R_ROW.用药目的
				,A.HIS_NO = N_HIS_NO
				,A.RECIPE_DIAG = R_ROW.处方诊断
				,A.RECEIVE_TIME = T_当前时间
				,A.Receive_Date=to_char(T_当前时间,'yyyymmdd')
				,A.REVIEWE_NORMAL_TIME = T_当前时间 + N_自动时间间隔 / 24 / 60
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
               -- 以下三个来源 合理用药
				,A.DRUG_CONTRA_LEVEL = R_ROW.药品禁忌等级
				,A.DRUG_CONTRA_TYPE = R_ROW.药品禁忌类型
				,A.DRUG_CONTRA_COMMENT = R_ROW.药品禁忌说明
				 WHERE ORDER_ID = R_ROW.医嘱ID;
				IF SQL%FOUND = FALSE THEN
          -- 如果 上述update 无数据 则表示无相同医嘱ID的记录 则进行插入该数据
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
						,R_ROW.医嘱期效
						,R_ROW.医嘱ID
						,N_婴儿
						,TO_DATE(
							R_ROW.开嘱时间
							,'yyyy-mm-dd hh24:mi:ss'
						)
						,TO_CHAR(
							TO_DATE(
								R_ROW.开嘱时间
								,'yyyy-mm-dd hh24:mi:ss'
							)
							,'yyyymmdd'
						)
						,R_ROW.紧急标志
						,R_ROW.开嘱医生
						,R_ROW.医生职称
						,R_ROW.医嘱内容
						,R_ROW.医生抗菌药物等级
						,R_ROW.本位码
						,R_ROW.剂型
						,R_ROW.给药频次
						,R_ROW.给药途径
						,R_ROW.给药途径名称
						,R_ROW.单次用量
						,R_ROW.单日用量
						,R_ROW.剂量单位
						,R_ROW.用药天数
						,R_ROW.超量说明
						,R_ROW.毒理分类
						,R_ROW.药品抗菌药物等级
						,R_ROW.用药目的
						,N_HIS_NO
						,R_ROW.处方诊断
						,T_当前时间
						,to_char(T_当前时间,'yyyymmdd')
						,T_当前时间 + N_自动时间间隔 / 24 / 60
						,-2
						,R_ROW.药品禁忌等级
						,R_ROW.药品禁忌类型
						,R_ROW.药品禁忌说明
						,R_ROW.输液组号
					);
          -- i_插入 记录插入数据条数  
					N_插入_RECIPE   := N_插入_RECIPE + 1;
				ELSE
          --记录修改数据条数
					N_修改_RECIPE   := N_修改_RECIPE + 1;
				END IF;
				IF C_ORDER_ID IS NULL THEN
					C_ORDER_ID   := C_ORDER_ID || R_ROW.医嘱ID;
				ELSE
					C_ORDER_ID   := C_ORDER_ID || ',' || R_ROW.医嘱ID;
				END IF;
  
			END LOOP;
		END IF;

    -- 调用 审方方案规则

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

  -- 接单，分配任务
	PROCEDURE ORDER_RECEIVING (
		USER_ID       IN VARCHAR2
		,P_TYPE_IN     IN NUMBER
		,ORDER_SCOPE   IN NUMBER
		,OUTPUT_OUT    OUT CLOB
	) IS
    --头注释开始-----------------------------------------------------------------------------------------
    --方法名称：接单
    --功能说明：点击上岗后，分配审核任务,刷新任务
    --入参说明：传入药师id ,接单类型 1-门诊 2-住院， 接单范围 order_Scope(是否允许接其他科室的单，无视 科室对应人员表) 1-是  0-否
    --出参说明：锁定 该药师对应需要审的任务（pid、pvid）
    --编 写 者：吴开波
    --编写时间：2018-06-11
    --版本记录：版本号+时间+修改者+修改需求描述
    --头注释结束-----------------------------------------------------------------------------------------   
		C_分配病人信息_OUT    CLOB;
		V_USER_NAME     VARCHAR2(20);
		N_PID           NUMBER(18);
		N_PVID          NUMBER(18);
		N_COUNT         NUMBER(1);
		V_审核范围          VARCHAR2(20);
		N_存在待审任务        NUMBER(18);
		N_是否继续循环        NUMBER(18);
		N_ORDER_SCOPE   NUMBER(1);
		T_当前时间          DATE;
	BEGIN
		N_PID          := 12;
		N_PVID         := 55;
		V_USER_NAME    := '';
		C_分配病人信息_OUT   := '';
		T_当前时间         := SYSDATE;
    -- 通过传入的user_id获取 user_name
		SELECT MAX(USER_NAME)
		  INTO V_USER_NAME
		  FROM RECIPE_USER A
		 WHERE A.USER_CODE = UPPER(USER_ID)
		   AND A.USER_STATUS = 1;
  
    --如果，待审处方中已经有该药师的审核任务，则返回该pid、pvid  
		SELECT COUNT(1)
		  INTO N_存在待审任务
		  FROM WAIT_REVIEWE_RECIPE A
		      ,RECIPE_PATIENT_INFO B
		 WHERE A.PHARMACIST_ID = USER_ID
		   AND A.PID = B.PID
		   AND A.PVID = B.PVID
		   AND B.P_TYPE = P_TYPE_IN;
    -- 获取待审处方 以医嘱接收时间升序排列，取时间最小的那一条
  
    -- 该 USER_ID 是否已存在待审任务
		IF N_存在待审任务 = 0 THEN
      -- 判断 这个药师 对应的科室是否为空，如果为空 则所有科室病人都可审核 ,不为空 则得到科室字符串 
			SELECT
				LISTAGG(A.DEPT_ID
				,',') WITHIN  GROUP(
					 ORDER BY A.DEPT_ID
				)
			  INTO V_审核范围
			  FROM PHARMACIST_REVIEWE_DEPT A
			 WHERE A.USER_CODE = UPPER(USER_ID)
			   AND A.RELATION_STATUS = 1;
    
      -- order_Scope 1-可以接所有科室单
			N_ORDER_SCOPE   := ORDER_SCOPE;
			IF N_ORDER_SCOPE = 1 THEN
				V_审核范围   := '';
			END IF;
			N_是否继续循环        := 0;
    
      -- if v_审核范围 is null then 
      -- 所有科室都可审核
			WHILE
				N_是否继续循环 = 0
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
						V_审核范围
					)
					    OR V_审核范围 IS NULL
				)
                 -- b.p_type=1 门诊、 2-住院
				   AND A.REVIEWE_NORMAL_TIME > SYSDATE
				   AND A.PHARMACIST_ID IS NULL
                 -- 正常完成时间>sysdate 还在需要审核时间范围内
				 ORDER BY A.RECEIVE_TIME )
				 WHERE ROWNUM = 1;
        -- 锁定该病人处方被该USER_ID 审查
				UPDATE WAIT_REVIEWE_RECIPE B
				   SET B.PHARMACIST_ID = USER_ID,B.PHARMACIST = V_USER_NAME
				,B.PHARMACIST_RECEIVE_TIME = T_当前时间
				 WHERE B.PID = N_PID
				   AND B.PVID = N_PVID
				   AND PHARMACIST_ID IS NULL;
        --如果上述sql执行成功，则表示已经锁定 退出循环         
				IF SQL%FOUND = TRUE THEN
          --更新处方表中的状态 改为审核中 2
					UPDATE REVIEWE_RECIPES C
					   SET C.REVIEWE_RESULT = 2,C.PHARMACIST_RECEIVE_TIME = T_当前时间
					 WHERE C.PID = N_PID
					   AND C.PVID = N_PVID
					   AND C.REVIEWE_RESULT = 0;
					N_是否继续循环   := 1;
				END IF;
				IF N_PID IS NULL THEN
					N_是否继续循环   := 1;
				END IF;
			END LOOP;
			IF N_PID IS NOT NULL    AND N_PVID IS NOT NULL THEN
				C_分配病人信息_OUT   := '{' || '"' || 'pid' || '"' || ':' || N_PID || ',' || '"' || 'pvid' || '"' || ':' || N_PVID || '}';
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
			C_分配病人信息_OUT   := '{' || '"' || 'pid' || '"' || ':' || N_PID || ',' || '"' || 'pvid' || '"' || ':' || N_PVID || '}';
		END IF;
		OUTPUT_OUT     := C_分配病人信息_OUT;
	EXCEPTION
		WHEN OTHERS THEN
			NULL;
      --zl_ErrorCenter(SQLCode, SQLErrM);
	END ORDER_RECEIVING;

  -- 检查超时待审核处方
	PROCEDURE TIMEOUT_REVIEWE IS
    --头注释开始-----------------------------------------------------------------------------------------
  
    --方法名称：检查超时待审核处方
  
    --功能说明：检查待审核处方中，超时的自动晚餐
  
    --入参说明：
  
    --出参说明：
  
    --编 写 者：罗虹
  
    --编写时间：2018-06-13
  
    --版本记录：版本号+时间+修改者+修改需求描述
  
    --头注释结束-----------------------------------------------------------------------------------------
		V_TIME           DATE;
		N_WAIT_REVIEWE   NUMBER(18);
	BEGIN
		V_TIME   := SYSDATE;
    -- 先删除 待审表中的记录（无药师正在审核）
  
    --删除待审中，未接单的超时记录
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
      --删除待审处方
			DELETE WAIT_REVIEWE_RECIPE B
			 WHERE B.PID = P.PID
			   AND B.PVID = P.PVID
			   AND B.REVIEWE_NORMAL_TIME <= V_TIME
			   AND B.PHARMACIST IS NULL;
    
      --把处方表中未接单的待审 更新为超时通过
			UPDATE REVIEWE_RECIPES A
			   SET A.REVIEWE_RESULT = 22,A.REVIEWE_TIME = V_TIME
			 WHERE A.PID = P.PID
			   AND A.PVID = P.PVID
			   AND (
				A.REVIEWE_RESULT =-2
				    OR A.REVIEWE_RESULT = 0
			);
      --检查病人是否还有待审医嘱
			SELECT COUNT(*)
			  INTO N_WAIT_REVIEWE
			  FROM WAIT_REVIEWE_RECIPE B
			 WHERE B.PID = P.PID
			   AND B.PVID = P.PVID;
			IF N_WAIT_REVIEWE IS NULL     OR N_WAIT_REVIEWE = 0 THEN
        --没有待审医嘱，通知HIS，这个病人的审方结果
				SEND_MESSAGE_TO_ZLHIS(
					P.PID
					,P.PVID
					,1
				);
			END IF;
		END LOOP;
	END TIMEOUT_REVIEWE;

  --编辑审核方案
	PROCEDURE EDIT_REVIEWE_SOLUTION (
		INPUT_IN       IN CLOB
		,EDIT_TYPE_IN   IN NUMBER
	)
		AS
    --头注释开始-----------------------------------------------------------------------------------------
    --方法名称：编辑审核方案
    --功能说明：编辑审核方案
    --入参说明：Input_In{"reviewe_solution_id":"","reviewe_solution_name":"","last_editor":"","last_edit_time":"","reviewe_solution_type":"","reviews_solution_status":""}
    --         Edit_Type_In (0 修改, 1 新增, -1 删除)
    --出参说明：
    --编 写 者：白天
    --编写时间：2018-06-29
    --版本记录：版本号+时间+修改者+修改需求描述
    --头注释结束-----------------------------------------------------------------------------------------
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
  
  --编辑审核方案明细
	PROCEDURE EDIT_REVIEWE_SOLUTION_DETAIL (
		INPUT_IN       IN CLOB
		,EDIT_TYPE_IN   IN NUMBER
	)
		AS
    --头注释开始-----------------------------------------------------------------------------------------
    --方法名称：编辑审核方案明细
    --功能说明：编辑审核方案明细
    --入参说明：Input_In{"reviewe_solution_id":"","reviewe_solution_name":"","last_editor":"","last_edit_time":"","reviewe_solution_type":"","reviews_solution_status":""}
    --         Edit_Type_In (0 修改, 1 新增, -1 删除)
    --出参说明：
    --编 写 者：白天
    --编写时间：2018-07-02
    --版本记录：版本号+时间+修改者+修改需求描述
    --头注释结束-----------------------------------------------------------------------------------------
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
  --新增药师工作记录
	PROCEDURE INSERT_PHARMACIST_WORK_RECORD (
		INPUT_IN IN CLOB
	)
		AS
    --头注释开始-----------------------------------------------------------------------------------------
    --方法名称：新增药师工作记录
    --功能说明：新增药师工作记录
    --入参说明：{"pharmacist":"","pharmacist_id":"","register_time":"","register_date":"","unregister_time":"","last_reviewe_time":""}
    --出参说明：
    --编 写 者：白天
    --编写时间：2018-06-06
    --版本记录：版本号+时间+修改者+修改需求描述
    --头注释结束-----------------------------------------------------------------------------------------
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

  --修改药师工作记录(仅仅适用于下岗操作)
	PROCEDURE UPD_PHARMACIST_WORK_RECORD (
		INPUT_IN IN CLOB
	)
		AS
    --头注释开始-----------------------------------------------------------------------------------------
    --方法名称：修改药师工作记录
    --功能说明：修改药师工作记录
    --入参说明：{"pharmacist":"","pharmacist_id":"","register_time":"","register_date":"","unregister_time":"","last_reviewe_time":""}
    --出参说明：
    --编 写 者：白天
    --编写时间：2018-06-06
    --版本记录：版本号+时间+修改者+修改需求描述
    --头注释结束-----------------------------------------------------------------------------------------
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

-- 药师科室分配设置
	PROCEDURE UPD_PHARMACIST_REVIEWE_DEPT (
		DEPT_ID               IN CLOB
		,USER_ID               IN VARCHAR2
		,V_CURRENT_USER_CODE   IN VARCHAR2
	) IS
    --头注释开始-----------------------------------------------------------------------------------------
    --方法名称：Upd_pharmacist_reviewe_dept
    --功能说明：-- 药师对应科室分配设置
    --入参说明： -- user_id 为界面上获取的 当前光标指向的用户ID，dept_name 科室名称串  内一科，内二科，...
    --出参说明：
    --编 写 者：吴开波
    --编写时间：2018-06-27
    --版本记录：版本号+时间+修改者+修改需求描述
    --头注释结束-----------------------------------------------------------------------------------------
		V_DEPT_ID   VARCHAR2(500);
		V_当前时间      DATE;
		V_最后编辑者     VARCHAR2(80);
	BEGIN
		V_DEPT_ID   := ',' || REPLACE(
			DEPT_ID
			,':'
			,','
		) || ',';
		V_当前时间      := SYSDATE;
 -- 查询当前用户科室 对应情况
		SELECT MAX(USER_NAME)
		  INTO V_最后编辑者
		  FROM RECIPE_USER
		 WHERE USER_CODE = V_CURRENT_USER_CODE;

 --删除该用户的科室对应数据，再插入最新的设置数据
		DELETE   FROM PHARMACIST_REVIEWE_DEPT A
		 WHERE A.USER_CODE = UPPER(USER_ID);
		FOR I IN ( SELECT A.ID 科室ID
		                 ,A.名称 科室名称
		             FROM 部门表@TO_ZLHIS A
		            WHERE INSTR(
			V_DEPT_ID
			,',' || A.ID || ','
		) > 0
		) LOOP
			INSERT   INTO PHARMACIST_REVIEWE_DEPT VALUES (
				USER_ID
				,I.科室ID
				,I.科室名称
				,V_最后编辑者
				,V_当前时间
				,1
			);
		END LOOP;
	EXCEPTION
		WHEN OTHERS THEN
			NULL;
    --zl_ErrorCenter(SQLCode, SQLErrM);
	END UPD_PHARMACIST_REVIEWE_DEPT;

--新增药师/修改药师 管理
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
    --头注释开始-----------------------------------------------------------------------------------------
    --方法名称：Upd_recipe_user
    --功能说明：新增药师/修改药师 管理
    --入参说明：V_Current_USER_NAME 当前操作人员名称，V_USER_CODE 对应 HIS 上机人员表 的用户名  ，N_CHANGE 1-新增，2-修改
    --出参说明：
    --编 写 者：吴开波
    --编写时间：2018-06-27
    --版本记录：版本号+时间+修改者+修改需求描述
    --头注释结束-----------------------------------------------------------------------------------------
		T_当前时间   DATE;
	BEGIN
      
		T_当前时间   := SYSDATE;
		IF V_USER_NAME IS NOT NULL    AND V_USER_CODE IS NOT NULL THEN
			IF N_CHANGE = 1 THEN
      -- 新增药师   
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
					,T_当前时间
					,V_CURRENT_USER_NAME
					,T_当前时间
					,DECODE(
						V_USER_JOB
						,1
						,'药师'
						,2
						,'主管药师'
						,3
						,'副主任药师'
						,4
						,'主任药师'
					)
					,V_USER_STATUS
					,N_IS_ADMIN
				);
        --调用 create_user 同时新增apex登录账户
				CREATE_USER(
					V_USER_CODE
					,V_WEB_PASSWORD
					,V_USER_STATUS
          ,N_IS_ADMIN
				);
			ELSIF N_CHANGE = 2 THEN
       -- 修改药师 
				UPDATE RECIPE_USER
				   SET LAST_EDITOR = V_CURRENT_USER_NAME,LAST_EDIT_TIME = T_当前时间
				,USER_JOB = DECODE(
						V_USER_JOB
						,1
						,'药师'
						,2
						,'主管药师'
						,3
						,'副主任药师'
						,4
						,'主任药师'
					)
				,USER_STATUS = V_USER_STATUS
				,IS_ADMIN = N_IS_ADMIN
				 WHERE USER_CODE = UPPER(V_USER_CODE)
				   AND USER_NAME = V_USER_NAME;
        --调用 edit_user 同时修改apex登录账户   
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
  
--新增 apec 药师用户
	PROCEDURE CREATE_USER (
		V_USER_ID        IN VARCHAR2
		,V_WEB_PASSWORD   IN VARCHAR2
		,N_STATUS_IN      IN NUMBER
    ,N_ADMIN          IN NUMBER
	) IS
-- 新增药师
--user_id  his 用户id
--V_USER_CODE 对应 HIS 用户的简码
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
    --判断新增是否是管理员
    if N_ADMIN=1 then
      --是管理员
      V_P_DEVELOPER_PRIVS:='ADMIN:CREATE:DATA_LOADER:EDIT:HELP:MONITOR:SQL' ;
      else
      --不是管理员  
      V_P_DEVELOPER_PRIVS :='' ;
    end if; 
    
		APEX_UTIL.CREATE_USER(
  -- P_USER_NAME 等于 recipe_user.user_code
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

-- 修改人员 apex用户 
	PROCEDURE EDIT_USER (
		P_USER_NAME   IN VARCHAR2
		,STATUS        IN NUMBER
    ,N_ADMIN      IN NUMBER
	) IS
-- 新增药师管理
--user_id  his 用户id

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
      
     --获取 L_USER_ID
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
       --判断是否是管理员    
    if N_ADMIN=1 then
      --是管理员
      L_DEVELOPER_ROLE:='ADMIN:CREATE:DATA_LOADER:EDIT:HELP:MONITOR:SQL' ;
      else
      --不是管理员  
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

--科室启用配置
	PROCEDURE DEPT_START (
		DEPT_NAME_IN   IN VARCHAR2
		,USER_NAME_IN   IN VARCHAR2
	) IS --DEPT_STATUS number,
    --头注释开始-----------------------------------------------------------------------------------------
    --方法名称：Upd_recipe_user
    --功能说明：新增药师/修改药师 管理
    --入参说明：传入当前操作人员 NAME 、已选科室ID    148：252：354
    --出参说明：
    --编 写 者：吴开波
    --编写时间：2018-06-27
    --版本记录：版本号+时间+修改者+修改需求描述
    --头注释结束-----------------------------------------------------------------------------------------
		V_DEPT_ID   VARCHAR2(500);
		V_当前时间      DATE;
	BEGIN
   /* V_DEPT_ID   := ',' || REPLACE(
      DEPT_ID
   ,':'
   ,','
    ) || ',';*/
		V_当前时间   := SYSDATE;
		PKG_RECIPE_REVIEWE.INSERT_LOG(
			LOG_TITILE_IN    => '科室启用'
			,LOG_TYPE_IN      => 'T'
			,LOG_CONTENT_IN   => DEPT_NAME_IN || USER_NAME_IN || DEPT_NAME_IN
		);
   -- DELETE   FROM REVIEWE_DEPT;
		FOR I IN ( SELECT A.ID 科室ID
		                 ,A.名称 科室名称
		             FROM 部门表@TO_ZLHIS A
		            WHERE --a.id in (v_dept_id) 
		            INSTR(
			DEPT_NAME_IN
			,',' || A.名称 || ','
		) > 0
		) LOOP
			INSERT   INTO REVIEWE_DEPT VALUES (
				I.科室ID
				,I.科室名称
				,USER_NAME_IN
				,V_当前时间
				,1
			);
		END LOOP;
	EXCEPTION
		WHEN OTHERS THEN
			NULL;
    --zl_ErrorCenter(SQLCode, SQLErrM);
	END DEPT_START;
--科室取消启用
	PROCEDURE DEL_REVIEWE_DEPT
-- 传入当前操作人员 NAME 、已选科室ID
--取消启用科室
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

  --修改门诊处方住院医嘱记录
	PROCEDURE UPD_REVIEWE_RECIPES (
		INPUT_IN IN CLOB
	) AS
    --头注释开始-----------------------------------------------------------------------------------------
    --方法名称：修改门诊处方住院医嘱记录
    --功能说明：修改门诊处方住院医嘱记录
    --入参说明：Input_In[{"pid": ,"pvid": ,"order_id": ,"pharmacist_id":"","reviewe_result": ,"reviewe_comment":""}]
    --出参说明：
    --编 写 者：白天
    --编写时间：2018-06-12
    --版本记录：版本号+时间+修改者+修改需求描述
    --头注释结束-----------------------------------------------------------------------------------------
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
				'修改审核结果'
				,'E'
				,INPUT_IN
			);
	END UPD_REVIEWE_RECIPES;

  --删除待审记录
	PROCEDURE DEL_WAIT_REVIEWE_RECIPE (
		INPUT_IN IN CLOB
	)
		AS
    --头注释开始-----------------------------------------------------------------------------------------
    --方法名称：删除待审记录
    --功能说明：删除待审记录
    --入参说明：Input_In[{"pid": ,"pvid":"","order_id": ,"pharmacist_id":""}]
    --出参说明：
    --编 写 者：白天
    --编写时间：2018-06-12
    --版本记录：版本号+时间+修改者+修改需求描述
    --头注释结束-----------------------------------------------------------------------------------------
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
				'删除待审记录'
				,'E'
				,INPUT_IN
			);
	END DEL_WAIT_REVIEWE_RECIPE;

  --查询病人处方审方结果
	PROCEDURE GET_RECIPES_REVIEWE_RESULT (
		PID_IN      IN NUMBER
		,PVID_IN     IN NUMBER
		,RESULTOUT   OUT SYS_REFCURSOR
	) IS
    --头注释开始-----------------------------------------------------------------------------------------
    --方法名称：查询病人处方审方结果
    --功能说明：查询指定医嘱id的审核结果：-1 未通过(审核中也算未通过),1 通过
    --入参说明：[{"病人id":123123,"就诊id":"2123"}] pid:病人id,pvid：就诊id，门诊挂号单号，住院：主页id
    --出参说明：病人单日医嘱审核结果，逐条医嘱返回
    --    [{"病人ID:"：123123,"就诊ID":123123}]
    --编 写 者：罗虹
    --编写时间：2018-06-11
    --版本记录：版本号+时间+修改者+修改需求描述
    --头注释结束-----------------------------------------------------------------------------------------
		V_审核日期   VARCHAR2(10);
    V_PHARMACIST_ID VARCHAR2(1000);
	BEGIN
		V_审核日期   := TO_CHAR(
			SYSDATE
			,'yyyymmdd'
		);
    --查询当前在岗药师,获取药师code 串
    select 
      max(listagg(t.pharmacist_id,',') Within Group(order by t.pharmacist_id)) into V_PHARMACIST_ID
    from PHARMACIST_WORK_RECORD t where t.register_date>=V_审核日期 ;
		OPEN RESULTOUT FOR SELECT DISTINCT ORDER_ID
		                                  ,ORDER_GROUP_ID
                                      ,nvl(PHARMACIST_ID,V_PHARMACIST_ID)
		                                  ,CASE
				WHEN A.REVIEWE_RESULT =-1  THEN --未通过
					NVL(
						A.REVIEWE_COMMENT
						,'-药师未填写未通过理由-'
					) --药师填写的理由
				ELSE '审核中'
			END
		NO_PASS_REASON
		                     FROM REVIEWE_RECIPES A
		                    WHERE A.DR_REFUSE_COMMENT IS NULL --医师填写了拒绝理由
		   --AND A.REVIEWE_NORMAL_TIME > SYSDATE --没有超时
		   AND (
			A.REVIEWE_RESULT =-1
			    OR A.REVIEWE_RESULT = 0
			    OR A.REVIEWE_RESULT = 2
			    OR A.REVIEWE_RESULT =-2
		) ---1未通过 0 待接单 -2 待处理 2 审核中
		   AND A.PID = PID_IN
		   AND A.PVID = PVID_IN
		   AND A.RECIPE_DATE = V_审核日期; --只非当日的算通过
		PKG_RECIPE_REVIEWE.INSERT_LOG(
			LOG_TITILE_IN    => 'HIS查询审方结果'
			,LOG_TYPE_IN      => 'T'
			,LOG_CONTENT_IN   => PID_IN || ',' || PVID_IN
		);
    --服务方式调用时，返回JSON
		APEX_JSON.OPEN_OBJECT;
		APEX_JSON.WRITE(
			'recipes'
			,RESULTOUT
		);
		APEX_JSON.CLOSE_OBJECT;
	EXCEPTION
		WHEN OTHERS THEN
			PKG_RECIPE_REVIEWE.INSERT_LOG(
				LOG_TITILE_IN    => 'HIS查询审方结果'
				,LOG_TYPE_IN      => 'E'
				,LOG_CONTENT_IN   => PID_IN || ',' || PVID_IN || CHR(10) || SQLERRM
			);
	END GET_RECIPES_REVIEWE_RESULT;
  
 --查询病人所有处方审方结果
  PROCEDURE GET_RECIPES_REVIEWE_RESULT_ALL (
    PID_IN      IN NUMBER
    ,PVID_IN     IN NUMBER
    ,RESULTOUT   OUT SYS_REFCURSOR
  ) IS
    --头注释开始-----------------------------------------------------------------------------------------
    --方法名称：查询病人所有处方审方结果
    --功能说明：查询指定医嘱id的审核结果：-1 未通过(审核中也算未通过),1 通过
    --入参说明：[{"病人id":123123,"就诊id":"2123"}] pid:病人id,pvid：就诊id，门诊挂号单号，住院：主页id
    --出参说明：病人单日医嘱审核结果，逐条医嘱返回
    --    [{"病人ID:"：123123,"就诊ID":123123}]
    --编 写 者：吴开波
    --编写时间：2018-08-27
    --版本记录：版本号+时间+修改者+修改需求描述
    --头注释结束-----------------------------------------------------------------------------------------
    V_审核日期   VARCHAR2(10);
  BEGIN
    V_审核日期   := TO_CHAR(
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
      LOG_TITILE_IN    => 'HIS查询所有审方结果ALL'
      ,LOG_TYPE_IN      => 'T'
      ,LOG_CONTENT_IN   => PID_IN || ',' || PVID_IN
    );
    --服务方式调用时，返回JSON
    APEX_JSON.OPEN_OBJECT;
    APEX_JSON.WRITE(
      'recipes'
      ,RESULTOUT
    );
    APEX_JSON.CLOSE_OBJECT;
  EXCEPTION
    WHEN OTHERS THEN
      PKG_RECIPE_REVIEWE.INSERT_LOG(
        LOG_TITILE_IN    => 'HIS查询所有审方结果ALL'
        ,LOG_TYPE_IN      => 'E'
        ,LOG_CONTENT_IN   => PID_IN || ',' || PVID_IN || CHR(10) || SQLERRM
      );
  END GET_RECIPES_REVIEWE_RESULT_ALL;
  --记录运行日志
	PROCEDURE INSERT_LOG (
		LOG_TITILE_IN    IN VARCHAR2
		,LOG_TYPE_IN      IN VARCHAR2
		,LOG_CONTENT_IN   IN CLOB
	)
		AS
    --头注释开始-----------------------------------------------------------------------------------------
    --方法名称：记录运行日志
    --功能说明：记录运行日志
    --入参说明：
    --出参说明：
    --编 写 者：罗虹
    --编写时间：2018-06-08
    --版本记录：版本号+时间+修改者+修改需求描述
    --头注释结束-----------------------------------------------------------------------------------------
	BEGIN
	--ALTER SESSION SET PLSQL_CCFLAGS = 'dev_env:TRUE'; --条件编译，如果不是开发环境，调试（T）类型步骤不记录

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
		--如果是错误，发送web消息给所有人，消息服务器可能没有启动，所有防止错误
			BEGIN
				WS_NOTIFY_API.DO_NOTIFY_ALL_PUBLIC_ERROR(
					I_TITLE     => LOG_TITILE_IN
					,I_MESSAGE   => '发送错误，请和系统管理员联系'
				);
				NULL;
			EXCEPTION
				WHEN OTHERS THEN
					NULL;
			END;
		END IF;
	END INSERT_LOG;

  --向ZLHIS发送审方结果消息
	PROCEDURE SEND_MESSAGE_TO_ZLHIS (
		PID_IN              IN NUMBER
		,PVID_IN             IN NUMBER
		,REVIEWE_RESULT_IN   IN NUMBER
		,PHARMACIST_NAME     IN VARCHAR2 := ''
	) AS
    --头注释开始-----------------------------------------------------------------------------------------
    --方法名称：向ZLHIS发送审方结果消息
    --功能说明：通过调用ZLHIS的过程，向ZLHIS发送审方消息
    --入参说明：reviewe_result:审核结果,1--全部通过，-1：有未通过
    --出参说明：病人单日医嘱审核结果，逐条医嘱返回
    --    
    --编 写 者：罗虹
    --编写时间：2018-06-15
    --版本记录：版本号+时间+修改者+修改需求描述
    --头注释结束-----------------------------------------------------------------------------------------
		V_REVIEWE_RECIPE_MESSAGE_CODE   VARCHAR2(100);
		V_MESSAGE_LOCATION              VARCHAR2(10); --当消息分类为1临床时："1111"从第一位开始依次是:门诊医生站,住院医生站,住院护士站,医技工作站
		N_PATIENT_DEPT_ID               NUMBER(18);
		N_PATIENT_TYPE                  NUMBER(18);
		N_PATIENT_NURSING_DEPT_ID       NUMBER(18);
		V_PATIENT_NAME                  VARCHAR2(80);
		V_PATIENT_BED_NO                VARCHAR2(20);
		V_MESSAGE                       VARCHAR2(4000);
		N_WAIT_REVIEWE                  NUMBER(18);
	BEGIN
  
    --检查病人是否还有待审医嘱,不包括已经超时的
		SELECT COUNT(*)
		  INTO N_WAIT_REVIEWE
		  FROM WAIT_REVIEWE_RECIPE B
		 WHERE B.PID = PID_IN
		   AND B.PVID = PVID_IN
		   AND B.REVIEWE_NORMAL_TIME > SYSDATE;
		IF N_WAIT_REVIEWE > 0 THEN
      --还有待审医嘱，不通知
			PKG_RECIPE_REVIEWE.INSERT_LOG(
				LOG_TITILE_IN    => '不通知ZLHIS'
				,LOG_TYPE_IN      => 'T'
				,LOG_CONTENT_IN   => PID_IN || ',' || PVID_IN
			);
			RETURN;
		END IF;
  

    --获取病人信息
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
			V_MESSAGE   := V_PATIENT_BED_NO || '床;';
		END IF;
		IF REVIEWE_RESULT_IN = 1 THEN
			V_MESSAGE   := V_MESSAGE || V_PATIENT_NAME || '新开医嘱药师审方完成，可以进行下一步。';
		ELSE
			V_MESSAGE   := V_MESSAGE || V_PATIENT_NAME || '新开医嘱未通过药师审方，请检查修改';
			IF PHARMACIST_NAME IS NOT NULL THEN
				V_MESSAGE   := V_MESSAGE || ',审方药师:' || PHARMACIST_NAME || '联系';
			END IF;
		END IF;
  
    --门诊病人提醒门诊医生站，住院病人提醒住院医生站
		IF N_PATIENT_TYPE = 1 THEN
			V_REVIEWE_RECIPE_MESSAGE_CODE   := 'ZLHIS_RECIPEAUDIT_001';
			V_MESSAGE_LOCATION              := '1000';
		ELSE
			V_REVIEWE_RECIPE_MESSAGE_CODE   := 'ZLHIS_RECIPEAUDIT_002';
			V_MESSAGE_LOCATION              := '0100';
		END IF;
  
    --门诊病人有结果就通知，住院病人只通知有未通过的结果
		IF REVIEWE_RESULT_IN =-1     OR N_PATIENT_TYPE = 1 THEN
			PKG_RECIPE_REVIEWE.INSERT_LOG(
				LOG_TITILE_IN    => '通知ZLHIS4'
				,LOG_TYPE_IN      => 'T'
				,LOG_CONTENT_IN   => PID_IN || ',' || PVID_IN || ';dept-' || N_PATIENT_DEPT_ID || ';nursing_dept-' || N_PATIENT_DEPT_ID || ';' || V_MESSAGE || ';location-' || V_MESSAGE_LOCATION || ';code-' || V_REVIEWE_RECIPE_MESSAGE_CODE
			);
			ZL_业务消息清单_INSERT@TO_ZLHIS (
				病人ID_IN     => PID_IN
				,就诊ID_IN     => PVID_IN
				,就诊科室ID_IN   => N_PATIENT_DEPT_ID
				,就诊病区ID_IN   => N_PATIENT_NURSING_DEPT_ID
				,病人来源_IN     => N_PATIENT_TYPE
				,消息内容_IN     => V_MESSAGE
				,提醒场合_IN     => V_MESSAGE_LOCATION
				,类型编码_IN     => V_REVIEWE_RECIPE_MESSAGE_CODE
				,业务标识_IN     => '合理用药审方'
				,优先程度_IN     => 2
				,是否已阅_IN     => 0
				,登记时间_IN     => SYSDATE
				,提醒部门_IN     => N_PATIENT_DEPT_ID
				,提醒人员_IN     => N_PATIENT_NURSING_DEPT_ID
			);
		END IF;
	EXCEPTION
		WHEN OTHERS THEN
			INSERT_LOG(
				LOG_TITILE_IN    => 'SEND_MESSAGE_TO_ZLHIS'
				,LOG_TYPE_IN      => 'E'
				,LOG_CONTENT_IN   => 'pid:' || PID_IN || ',pvid:' || PVID_IN || CHR(10) || '错误代码:' || SQLCODE || '错误信息：' || SQLERRM
			);
	END SEND_MESSAGE_TO_ZLHIS;
  --医生填写拒绝药师不通过理由
	PROCEDURE UPD_DR_REFUSE_COMMENT (
		RECIPES_IN IN CLOB
	)
		IS
    --头注释开始-----------------------------------------------------------------------------------------
    --方法名称：医生填写拒绝药师不通过理由
    --功能说明：由ZLHIS调用，回写医生拒绝理由;
    --入参说明：reviewe_result:审核结果，1-通过（全部通过），-1-未通过(有一条医嘱未通过就算）
    --[{"order_id":123,"dr_refuse_comment":"aaaa"}]
    --出参说明：病人单日医嘱审核结果，逐条医嘱返回
    --    
    --编 写 者：罗虹
    --编写时间：2018-06-20
    --版本记录：版本号+时间+修改者+修改需求描述
    --头注释结束-----------------------------------------------------------------------------------------
	BEGIN
		PKG_RECIPE_REVIEWE.INSERT_LOG(
			'医师拒绝审方记录'
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
				'医师拒绝审方记录'
				,'E'
				,RECIPES_IN || CHR(10) || SQLERRM
			);
	END UPD_DR_REFUSE_COMMENT;
  
    --修改审核方案
	PROCEDURE UPD_REVIEWE_SOLUTION (
		INPUT_IN IN CLOB
	)
		AS
    --头注释开始-----------------------------------------------------------------------------------------
    --方法名称：修改审核方案
    --功能说明：修改审核方案
    --入参说明：INPUT_IN{"reviewe_solution_id":"","reviewe_solution_name":"","last_editor":"","last_edit_time":"","reviewe_solution_type":"","reviews_solution_status":""}
    --出参说明：
    --编 写 者：白天
    --编写时间：2018-06-29
    --版本记录：版本号+时间+修改者+修改需求描述
    --头注释结束-----------------------------------------------------------------------------------------
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
      -- 判断修改方案成启用状态时，是否存在明细，如果没有则“方案启用失败，请先添加方案明细再启用！”
      select count(*) INTO N_COUNT from reviewe_solution_detail where reviewe_solution_id=i.reviewe_solution_id;
      if i.reviewe_solution_status=1 AND N_COUNT=0 then
         V_EXCPTION:='方案启用失败，请先添加该方案的明细再启用！';
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
  
---审方方案设计
	PROCEDURE PRESCRIPTIONS_REGULARITY (
		V_FIELD_NAME             IN VARCHAR2
		,C_REVIEWE_SOLUTION_OUT   OUT CLOB
	) IS
    --头注释开始-----------------------------------------------------------------------------------------
    --方法名称：修改审核方案
    --功能说明：修改审核方案
    --入参说明：审方规则审核涉计.项目字段名称  
    --出参说明：对应的表达式、条件值域、单选，多选 1.2  xml
    --编 写 者：吴开波
    --编写时间：2018-06-29
    --版本记录：版本号+时间+修改者+修改需求描述
    --头注释结束-----------------------------------------------------------------------------------------
		C_REVIEWE_SOLUTION   CLOB;
		T_当前时间               DATE;
	BEGIN
		T_当前时间                   := SYSDATE;
  --药品剂型
		IF V_FIELD_NAME = 'drug_form' THEN
			SELECT XMLAGG(XMLELEMENT(
				"value"
				,XMLELEMENT(
					"display"
					,A.药品剂型
				)
				,XMLELEMENT(
					"key"
					,A.药品剂型
				)
			) ).GETCLOBVAL()
			  INTO C_REVIEWE_SOLUTION
			  FROM ( SELECT DISTINCT 药品剂型
			           FROM 药品特性@TO_ZLHIS
			) A;
			C_REVIEWE_SOLUTION   := '<range><type>1</type>' || C_REVIEWE_SOLUTION || '<expression><display>包含于</display><key>包含于</key></expression></range>';
		END IF; 
  --给药途径
		IF V_FIELD_NAME = 'drug_route' THEN
			SELECT XMLAGG(XMLELEMENT(
				"value"
				,XMLELEMENT(
					"display"
					,A.给药途径
				)
				,XMLELEMENT(
					"key"
					,A.给药途径
				)
			) ).GETCLOBVAL()
			  INTO C_REVIEWE_SOLUTION
			  FROM ( SELECT DISTINCT T.观察项明细值名称 AS 给药途径
			           FROM V_外部系统对照@TO_ZLKBC T
			          WHERE T.外部明细名称 = '给药途径'
			) A;
			C_REVIEWE_SOLUTION   := '<range><type>2</type>' || C_REVIEWE_SOLUTION || '<expression><display>含有</display><key>含有</key></expression></range>';
		END IF; 
  --禁忌类型 
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
			           FROM V_合理用药提示类型@TO_ZLKBC
			) A;
			C_REVIEWE_SOLUTION   := '<range><type>2</type>' || C_REVIEWE_SOLUTION || '<expression><display>包含于</display><key>包含于</key></expression></range>';
		END IF;
		C_REVIEWE_SOLUTION       :=
			CASE
				
				WHEN V_FIELD_NAME = 'recipe_dr_title' THEN
					'<range>
          <type>2</type>
          <value>
            <display>主任医师</display>
            <key>主任医师</key>
          </value>
          <value>
            <display>副主任医师</display>
            <key>副主任医师</key>
          </value>
          <value>
            <display>主治医师</display>
            <key>主治医师</key>
          </value>
          <value>
            <display>医师</display>
            <key>医师</key>
          </value>
          <expression>
            <display>包含于</display>
            <key>包含于</key>
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
                <display>含有</display>
                <key>含有</key>
              </expression>
            </range>'
				WHEN V_FIELD_NAME = 'dr_anti_level'     OR V_FIELD_NAME = 'drug_anti_level' THEN
					'<range>
              <type>1</type>
              <value>
                <display>1-非限制</display>
                <key>1</key>
              </value>
              <value>
                <display>2-限制</display>
                <key>2</key>
              </value>
              <value>
                <display>3-特殊</display>
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
    --药品通用名称 drug_generic_Name
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
                <display>麻醉药</display>
                <key>麻醉药</key>
              </value>
              <value>
                <display>毒性药</display>
                <key>毒性药</key>
              </value>
              <value>
                <display>精神I类</display>
                <key>精神I类</key>
              </value>
              <value>
                <display>精神II类</display>
                <key>精神II类</key>
              </value>
              <value>
                <display>普通药</display>
                <key>普通药</key>
              </value>
              <expression>
                <display>包含于</display>
                <key>包含于</key>
              </expression>
            </range>'
				WHEN V_FIELD_NAME = 'anti_drug_reason' THEN
					'<range>
              <type>1</type>
              <value>
                <display>治疗</display>
                <key>治疗</key>
              </value>
              <value>
                <display>预防</display>
                <key>预防</key>
              </value>
              <expression>
                <display>含有</display>
                <key>含有</key>
              </expression>
            </range>'
				WHEN V_FIELD_NAME = 'p_phys' THEN
					'<range>
              <type>2</type>
              <value>
                <display>妊娠</display>
                <key>妊娠</key>
              </value>
              <value>
                <display>哺乳</display>
                <key>哺乳</key>
              </value>
              <value>
                <display>肝功能不全</display>
                <key>肝功能不全</key>
              </value>
              <value>
                <display>严重肝功能不全</display>
                <key>严重肝功能不全</key>
              </value>
              <value>
                <display>肾功能不全</display>
                <key>肾功能不全</key>
              </value>
              <value>
                <display>严重肾功能不全</display>
                <key>严重肾功能不全</key>
              </value>
              <expression>
                <display>含有</display>
                <key>含有</key>
              </expression>
            </range>'
				WHEN V_FIELD_NAME = 'drug_contra_level' THEN
					'<range>
              <type>2</type>
              <value>
                <display>禁用</display>
                <key>禁用</key>
              </value>
              <value>
                <display>慎用</display>
                <key>慎用</key>
              </value>
              <expression>
                <display>含有</display>
                <key>含有</key>
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

  --新增审核方案
	PROCEDURE INSERT_REVIEWE_SOLUTION (
		INPUT_IN IN CLOB
	)
		AS
    --头注释开始-----------------------------------------------------------------------------------------
    --方法名称：新增审核方案
    --功能说明：新增审核方案
    --入参说明：INPUT_IN{"reviewe_solution_id":"","reviewe_solution_name":"","last_editor":"","last_edit_time":"","reviewe_solution_type":"","reviews_solution_status":""}
    --出参说明：
    --编 写 者：白天
    --编写时间：2018-06-29
    --版本记录：版本号+时间+修改者+修改需求描述
    --头注释结束-----------------------------------------------------------------------------------------
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

  --删除审核方案
	PROCEDURE DEL_REVIEWE_SOLUTION (
		REVIEWE_SOLUTION_ID_IN IN VARCHAR2
	)
		AS
    --头注释开始-----------------------------------------------------------------------------------------
    --方法名称：删除审核方案
    --功能说明：删除审核方案
    --入参说明：REVIEWE_SOLUTION_ID_IN
    --出参说明：
    --编 写 者：白天
    --编写时间：2018-06-29
    --版本记录：版本号+时间+修改者+修改需求描述
    --头注释结束-----------------------------------------------------------------------------------------
	BEGIN
		IF REVIEWE_SOLUTION_ID_IN IS NOT NULL THEN
			DELETE REVIEWE_SOLUTION
			 WHERE REVIEWE_SOLUTION_ID = REVIEWE_SOLUTION_ID_IN;
		END IF;
	END DEL_REVIEWE_SOLUTION;

  --修改审核方案明细
	PROCEDURE UPD_REVIEWE_SOLUTION_DETAIL (
		INPUT_IN IN CLOB
	) AS
    --头注释开始-----------------------------------------------------------------------------------------
    --方法名称：修改审核方案明细
    --功能说明：修改审核方案明细
    --入参说明：Input_In{"reviewe_solution_id":"","last_editor":"","last_edit_time":"","solution_item":"","item_field_name":"","item_expression":"","item_value":"","item_type":"","item_table_name":""}
    --出参说明：
    --编 写 者：白天
    --编写时间：2018-07-02
    --版本记录：版本号+时间+修改者+修改需求描述
    --头注释结束-----------------------------------------------------------------------------------------
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
      -- 调用验证过程，看是否能够验证通过。
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

  --新增审核方案明细
	PROCEDURE INSERT_REVIEWE_SOLUTION_DETAIL (
		INPUT_IN IN CLOB
	) AS
    --头注释开始-----------------------------------------------------------------------------------------
    --方法名称：新增审核方案明细
    --功能说明：新增审核方案明细
    --入参说明：Input_In{"reviewe_solution_id":"","reviewe_solution_name":"","last_editor":"","last_edit_time":"","reviewe_solution_type":"","reviews_solution_status":""}
    --出参说明：
    --编 写 者：白天
    --编写时间：2018-07-02
    --版本记录：版本号+时间+修改者+修改需求描述
    --头注释结束-----------------------------------------------------------------------------------------
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
    -- 调用验证过程，看是否能够验证通过。
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
			'验证方案明细规则'
			,INPUT_IN
			,'T'
			,SYSDATE
		);
		VERIFY_SOLUTION(V_REVIEWE_SOLUTION_ID);
	END INSERT_REVIEWE_SOLUTION_DETAIL;

-- 验证审核方案
	PROCEDURE VERIFY_SOLUTION
-- 审方方案保存时，验证准确性
	 (
		V_REVIEWE_SOLUTION_ID IN VARCHAR2
	) IS
		V_DEPT_ID            VARCHAR2(500);
		V_当前时间               DATE;
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
--对应"含有"条件，多选是，查分为多个条件表达式 instr(字段,'条件值1')>0  or instr(字段,'条件值2')>0 
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
        --组合一个方案的条件
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
|| V_SOLUTION_CND || ' and instr(' || V_QUOTE || V_ORDER_IDS_IN || V_QUOTE || ',' || V_QUOTE || ',' || V_QUOTE || '||reviewe_recipes.order_id || ' || V_QUOTE || ',' || V_QUOTE || ') > 0 and reviewe_recipes.recipe_date=' || V_QUOTE || V_REVIEWE_DATE || V_QUOTE || ' --查询验证数据';
		DBMS_OUTPUT.PUT_LINE(V_SQL);
		EXECUTE IMMEDIATE V_SQL;
		INSERT   INTO RECIPE_REVIEWE_LOG (
			LOG_TITLE
			,LOG_CONTENT
			,LOG_TYPE
			,LOG_TIME
		) VALUES (
			'验证方案明细规则'
			,V_SQL
			,'T'
			,SYSDATE
		);
	EXCEPTION
		WHEN OTHERS THEN
    --出错则该方案存在问题，还需要调整 无法直接保存 回滚事物
			ROLLBACK;
			RETURN;
    --zl_ErrorCenter(SQLCode, SQLErrM);
	END VERIFY_SOLUTION;

  --删除审核方案明细
	PROCEDURE DEL_REVIEWE_SOLUTION_DETAIL (
		INPUT_IN IN CLOB
	) AS
    --头注释开始-----------------------------------------------------------------------------------------
    --方法名称：删除审核方案明细
    --功能说明：删除审核方案明细
    --入参说明：Input_In{"reviewe_solution_id":"","reviewe_solution_name":"","last_editor":"","last_edit_time":"","reviewe_solution_type":"","reviews_solution_status":""}
    --出参说明：
    --编 写 者：白天
    --编写时间：2018-07-02
    --版本记录：版本号+时间+修改者+修改需求描述
    --头注释结束-----------------------------------------------------------------------------------------
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
           --2018-7-11 吴开波新增 控制：删除吼，明细中数据为0后则同时修改 该方案为停用状态。
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

  --审方系统安装后初始化
	PROCEDURE RECIPE_REVIEWE_COMMENT_INIT AS
    --头注释开始-----------------------------------------------------------------------------------------
    --方法名称：审方系统安装后初始化
    --功能说明：创建审方系统运行需要的数据、数据对象的环境
    --入参说明：
    --出参说明：
    --编 写 者：罗虹
    --编写时间：2018-07-02
    --版本记录：版本号+时间+修改者+修改需求描述
    --头注释结束-----------------------------------------------------------------------------------------
		V_审方结果查询     VARCHAR2(4000);
		V_医生拒绝回写     VARCHAR2(4000);
		V_HIS连接      VARCHAR2(4000);
		V_合理用药连接     VARCHAR2(4000);
		V_SQL        VARCHAR2(4000);
		V_JOB_NAME   VARCHAR2(100);
	BEGIN
  --给ZLHIS配置审方的参数
		SELECT 'http://' || MAX(PARA_VALUE) || '/ords/zlrecipe/recipe/result'
		      ,'http://' || MAX(PARA_VALUE) || '/ords/zlrecipe/recipe/refuse'
		  INTO
			V_审方结果查询
		,V_医生拒绝回写
		  FROM RECIPE_REVIEWE_PARA
		 WHERE PARA_NAME = '审方服务器地址';
		IF V_审方结果查询 IS NULL THEN
			PKG_RECIPE_REVIEWE.INSERT_LOG(
				LOG_TITILE_IN    => '审方系统初始化'
				,LOG_TYPE_IN      => '审方系统服务器地址未配置'
				,LOG_CONTENT_IN   => V_审方结果查询
			);
			RETURN;
		END IF;
		UPDATE 三方服务配置目录@TO_ZLHIS
		   SET
			服务地址 = V_审方结果查询
		 WHERE 系统标识 = '药师处方审查'
		   AND 服务名称 = '审查结果查询';
		IF SQL%ROWCOUNT = 0 THEN
			INSERT   INTO 三方服务配置目录@TO_ZLHIS (
				系统标识
				,服务名称
				,服务地址
			) VALUES (
				'药师处方审查'
				,'审查结果查询'
				,V_审方结果查询
			);
		END IF;
		UPDATE 三方服务配置目录@TO_ZLHIS
		   SET
			服务地址 = V_医生拒绝回写
		 WHERE 系统标识 = '药师处方审查'
		   AND 服务名称 = '回写医生拒绝理由';
		IF SQL%ROWCOUNT = 0 THEN
			INSERT   INTO 三方服务配置目录@TO_ZLHIS (
				系统标识
				,服务名称
				,服务地址
			) VALUES (
				'药师处方审查'
				,'回写医生拒绝理由'
				,V_医生拒绝回写
			);
		END IF;
		V_JOB_NAME   := 'ZLRECIPE.审方点评系统每日作业';
    --创建增量自动作业
    --先停止和删除job
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

    --创建增量自动作业
		DBMS_SCHEDULER.CREATE_JOB(
			JOB_NAME     => V_JOB_NAME
			,JOB_TYPE     => 'STORED_PROCEDURE'
			,JOB_ACTION   => 'ZLRECIPE.PKG_RECIPE_REVIEWE.DEL_TimeOut_WAIT_REVIEWE_RECIPES'
			,ENABLED      => TRUE
			,COMMENTS     => '每日清除超期未审处方'
		);

    --配置为立即生效执行
		DBMS_SCHEDULER.ENABLE(NAME   => V_JOB_NAME);
		DBMS_SCHEDULER.SET_ATTRIBUTE(
			NAME        => V_JOB_NAME
			,ATTRIBUTE   => 'start_date'
			,VALUE       => SYSDATE
		);
    --每日19点00分运行，可调。
		DBMS_SCHEDULER.SET_ATTRIBUTE(
			NAME        => V_JOB_NAME
			,ATTRIBUTE   => 'repeat_interval'
			,VALUE       => 'FREQ=DAILY; BYHOUR=19;BYMINUTE=00'
		);

    --禁止错误后自动删除
		DBMS_SCHEDULER.SET_ATTRIBUTE(
			NAME        => V_JOB_NAME
			,ATTRIBUTE   => 'auto_drop'
			,VALUE       => FALSE
		);
    --配置JOB执行出现错误后，下次继续执行。
		DBMS_SCHEDULER.SET_ATTRIBUTE(
			NAME        => V_JOB_NAME
			,ATTRIBUTE   => 'RESTARTABLE'
			,VALUE       => TRUE
		);

    --配置日志级别，只记录失败日志
		DBMS_SCHEDULER.SET_ATTRIBUTE(
			NAME        => V_JOB_NAME
			,ATTRIBUTE   => 'logging_level'
			,VALUE       => DBMS_SCHEDULER.LOGGING_FAILED_RUNS
		);
	END RECIPE_REVIEWE_COMMENT_INIT;
	--删除已经超期的待审处方
	PROCEDURE DEL_TIMEOUT_WAIT_REVIEWE_RECIPES
		AS
    --头注释开始-----------------------------------------------------------------------------------------
    --方法名称：删除已经超期的待审处方
    --功能说明：删除已经超期的待审处方，每天晚上自动作用
    --入参说明：
    --出参说明：
    --编 写 者：罗虹
    --编写时间：2018-07-10
    --版本记录：版本号+时间+修改者+修改需求描述
    --头注释结束-----------------------------------------------------------------------------------------
	BEGIN
	--删除待审处方中超时的内容
		DELETE WAIT_REVIEWE_RECIPE
		 WHERE REVIEWE_NORMAL_TIME < SYSDATE;
		 --更新审处方的审核结果为超时通过
		UPDATE REVIEWE_RECIPES
		   SET
			REVIEWE_RESULT = 22
		 WHERE REVIEWE_NORMAL_TIME < SYSDATE
		   AND REVIEWE_RESULT = 0;
	END DEL_TIMEOUT_WAIT_REVIEWE_RECIPES;
END PKG_RECIPE_REVIEWE;

/
