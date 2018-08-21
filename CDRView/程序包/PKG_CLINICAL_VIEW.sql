CREATE OR REPLACE Package Pkg_Clinical_View Is

  -- Author  : 天
  -- Created : 2018/8/8 9:40:00
  -- Purpose : 临床视图相关存储过程
  
  --根据患者ID获取患者就诊时间轴[001]
  --PDF界面展示高度 ** PX 
  N_HEIGHT CONSTANT NUMBER:=630;
  Procedure Get_Visit_TimeLine$Pid(Pid_In In Number, Output_Out Out Clob);

  --根据CDR病历ID获取病历PDF地址[002]
  Procedure Get_PDF$Pat_Emr_Id(Pat_Emr_Id_In In Number, Output_Out Out Varchar2);
  
  --根据就诊ID获取门诊病历的PDF
  Procedure Get_EMR_PDF$PVID(pvid In varchar2, Output_Out Out Varchar2);
  
  --根据就诊ID获取检验报告的PDF
  Procedure Get_LIS_PDF$PVID(pvid In varchar2, Output_Out Out Varchar2);
  
  --根据就诊ID获取检查报告的PDF
  Procedure Get_EXAMINE_PDF$PVID(pvid In varchar2, Output_Out Out Varchar2);
  
  --根据pvid获取导航列表
  Procedure Get_LOCATION$PVID(pvid In varchar2, Output_Out Out Varchar2);
  
  --根据就诊ID获取住院视图[007]
  Procedure Get_Inp_View$Pvid(Pvid_In In Number, Page_Num_In In Number, App_ID_In Number, App_Session_In Number, Output_Out Out Clob, Max_Page_Out Out Number);
    
End Pkg_Clinical_View;

/


CREATE OR REPLACE Package Body Pkg_Clinical_View Is

  Procedure Get_Visit_TimeLine$Pid(Pid_In In Number, Output_Out Out Clob) As
    /*头注释开始-----------------------------------------------------------------------------------------
      方法名称：根据患者ID获取患者就诊时间轴[001]
      功能说明：根据患者ID获取患者就诊时间轴[001]
      入参说明：Pid_In
      出参说明：Output_Out
      编 写 者：白天
      编写时间：2018-08-08
      版本记录：版本号+时间+修改者+修改需求描述
      头注释结束---------------------------------------------------------------------------------------*/
    v_First_Diag    Varchar2(200);
    v_Diags         Varchar2(4000);
    l_SimgleVisit   Clob;
  Begin
    If Pid_In Is Not Null Then
      For i In (Select Pvid, To_Char(Pat_Visit_Date, 'yyyy-mm-dd') As Pat_Visit_Date, Pat_Visit_Type_Name 
                  From v_Pat_Visit_Info
                 Where Pid = Pid_In
              Order By Pat_Visit_Date) Loop
        v_First_Diag := Null;
        v_Diags := Null;
        Select Max(Diag_Name) Into v_First_Diag
          From (Select Pat_Diag_Sno, Pat_Diag_Type, Pat_Diag_Type_Name, Diag_Name
                  From v_Pat_Diag_info 
                 Where Pvid = i.Pvid
                   And Diag_Name Is Not Null
                   and Pat_Diag_Type<4
              Order By Pat_Diag_Type Desc,Pat_Diag_Sno)
         Where Rownum = 1;        
        Select regexp_replace(Listagg(Pat_Diag_Desc,'</br>')within group(order by 1), '([^</br>]+)(</br>\1)+', '\1') Into v_Diags
          From (Select Pat_Diag_Sno, Pat_Diag_Type, Pat_Diag_Desc
                  From v_Pat_Diag_info 
                 Where pvid = i.Pvid
              Order By Pat_Diag_Type, Pat_Diag_Sno);
        l_SimgleVisit := l_SimgleVisit||',{"date":"'||i.Pat_Visit_Date||'","type":"'||i.Pat_Visit_Type_Name||'","pvid":"'||i.Pvid||
                        '","firstdiag":"'||v_First_Diag||'","totaldiag":"'||v_Diags||'"}';
      End Loop;
      Output_Out := '{"data":['|| Ltrim(l_SimgleVisit, ',')||']}';
    Else
      Output_Out := '{"data":[{"date":"","type":"","pvid":"","firstdiag":"","totaldiag":""}]}';
    End If;
  End Get_Visit_TimeLine$Pid;

  Procedure Get_PDF$Pat_Emr_Id(Pat_Emr_Id_In In Number, Output_Out Out Varchar2) As
    /*头注释开始-----------------------------------------------------------------------------------------
      方法名称：根据CDR病历ID获取病历PDF地址[002]
      功能说明：根据CDR病历ID获取病历PDF地址[002]
      入参说明：Pat_Emr_Id
      出参说明：Output_Out
      编 写 者：白天
      编写时间：2018-08-09
      版本记录：版本号+时间+修改者+修改需求描述
      头注释结束---------------------------------------------------------------------------------------*/
    v_Antetype_Id       Varchar2(100);
  Begin
    If Pat_Emr_Id_In Is Not Null Then
      For i In (Select a.Pat_Visit_Type_Name, b.Emr_Dataset_Name, b.Appsys_Id, Nvl(b.Appsys_Lnk_Emr_Id,b.Appsys_Emr_Id) As Appsys_Emr_Id, b.Appsys_Emr_Antetype_Id 
                  From v_Pat_Visit_Info a, cdr.Pat_Emr b
                 Where b.Pat_Emr_Id = Pat_Emr_Id_In
                   And a.Pvid = b.Pvid) Loop
        If i.Pat_Visit_Type_Name = '住院' Then
          If i.Emr_Dataset_Name = '检验报告' Then
            --住院检验报告 N5
            v_Antetype_Id := 'N5';
          elsif i.Emr_Dataset_Name = '检查报告' then
            --住院检查报告
            v_Antetype_Id := '';
           else
            --住院病历
            If Length(i.Appsys_Emr_Antetype_Id) = 32 Then
              --住院新版病历  E1
              v_Antetype_Id := 'E1';
            Else
              --住院老版病历 H1
              v_Antetype_Id := 'H1';
            End If;
          End If;
        Elsif i.Pat_Visit_Type_Name = '门诊' Or i.Pat_Visit_Type_Name = '急诊' Then
          If i.Emr_Dataset_Name = '检验报告' Then
            --门诊检验报告
            v_Antetype_Id := 'N3';
          elsif i.Emr_Dataset_Name = '检查报告' then
            --门诊检查报告
            v_Antetype_Id := '';
           else
             --门诊病历
            If Length(i.Appsys_Emr_Antetype_Id) = 32 Then
              --门诊新版病历
              v_Antetype_Id := 'E0';
            Else
              --门诊老版病历
              v_Antetype_Id := 'H0';
            End If;
          End If;
        Else
          v_Antetype_Id := '';
        End If;
        For j In (Select b.Ftp_Url, a.Pat_Mr_File_Path, a.Pat_Mr_File_Name
                    From cdr.Pat_Mr a, cdr.Ftp b
                   Where a.Appsys_Id = i.Appsys_Id
                     And a.Appsys_Emr_Id = i.Appsys_Emr_Id
                     And a.Appsys_Emr_Antetype_Id = v_Antetype_Id
                     And a.Ftp_Id = b.Ftp_Id)Loop
          Output_Out := 'http://'||j.Ftp_Url||':8080/pdf/MR/'||j.Pat_Mr_File_Path||'/'||j.Pat_Mr_File_Name;
        End Loop;
      End Loop;
    End If;
  End Get_PDF$Pat_Emr_Id;
--根据就诊ID获取病历的PDF（门诊视图使用）
  Procedure Get_EMR_PDF$PVID(pvid In varchar2, Output_Out Out Varchar2)  as
      /*头注释开始-----------------------------------------------------------------------------------------
      方法名称：根据CDR就诊ID获取病历PDF地址[003]
      功能说明：根据CDR pvid获取病历PDF地址[003]
      入参说明：pvid
      出参说明：Output_Out
      编 写 者：吴开波
      编写时间：2018-08-14
      版本记录：版本号+时间+修改者+修改需求描述
      头注释结束---------------------------------------------------------------------------------------*/
       output_src varchar2(4000) ;
       iframe varchar2(4000) ;
       iframe_temp varchar2(4000) ;
       v_pvid varchar2(50);
begin
  iframe_temp:='';
  iframe:='';
  v_pvid:=pvid ;
 if pvid is not null then
    for p in (
     select A.Emr_Dataset_Name 病历名称,a.Appsys_Lnk_Emr_Id,a.Appsys_Emr_Id,a.Pat_Emr_Id from V_PAT_EMR_INFO a where  A.PVID=v_pvid
 order by a.emr_dataset_code    
      ) loop
      Pkg_Clinical_View.Get_PDF$Pat_Emr_Id(p.Pat_Emr_Id,output_src) ;
      if output_src is not null then
       iframe_temp:='<span style="font-size:20px;"><a id="'||p.Pat_Emr_Id||'">'||p.病历名称||'</a></span><iframe  src="'||output_src||'" frameborder="0" style="width: 100%; height:'||N_HEIGHT||'px;"></iframe>';
      if iframe_temp is null then
       iframe:=iframe_temp;
        else
        iframe:=iframe||iframe_temp ;  
       end if;
       end if;
    end loop;
    Output_Out:=iframe ;
 end if;
end Get_EMR_PDF$PVID;   
--根据就诊ID获取检验报告的PDF（门诊视图使用）
  Procedure Get_LIS_PDF$PVID(pvid In varchar2, Output_Out Out Varchar2)  as
      /*头注释开始-----------------------------------------------------------------------------------------
      方法名称：根据CDR就诊ID获取检验报告PDF地址[004]
      功能说明：根据CDR pvid获取检验报告PDF地址[004]
      入参说明：pvid
      出参说明：Output_Out
      编 写 者：吴开波
      编写时间：2018-08-14
      版本记录：版本号+时间+修改者+修改需求描述
      头注释结束---------------------------------------------------------------------------------------*/
       output_src varchar2(4000) ;
       iframe varchar2(4000) ;
       iframe_temp varchar2(4000) ;
       v_pvid varchar2(50);
begin
  iframe_temp:='';
  iframe:='';
  v_pvid:=pvid ;
 if pvid is not null then
    for p in (
    select a.lab_item_name 检验报告,a.Appsys_Emr_Id,a.Pat_Emr_Id from V_PAT_LIS_INFO a where A.PVID=v_pvid
    order by a.emr_dataset_code    
      ) loop
      Pkg_Clinical_View.Get_PDF$Pat_Emr_Id(p.Pat_Emr_Id,output_src) ;
      if output_src is not null then
       iframe_temp:='<span style="font-size:20px;"><a id="'||p.Pat_Emr_Id||'">'||p.检验报告||'</a></span><iframe  src="'||output_src||'" frameborder="0" style="width: 100%; height:'||N_HEIGHT||'px;"></iframe>'; 
      if iframe_temp is null then
       iframe:=iframe_temp;
        else
        iframe:=iframe||iframe_temp ;  
       end if;
       end if;
    end loop;
    Output_Out:=iframe ;
 end if;
end Get_LIS_PDF$PVID;   
--根据就诊ID获取检查报告的PDF（门诊视图使用）
  Procedure Get_EXAMINE_PDF$PVID(pvid In varchar2, Output_Out Out Varchar2)  as
      /*头注释开始-----------------------------------------------------------------------------------------
      方法名称：根据CDR就诊ID获取检查报告PDF地址[005]
      功能说明：根据CDR pvid获取检查报告PDF地址[005]
      入参说明：pvid
      出参说明：Output_Out
      编 写 者：吴开波
      编写时间：2018-08-14
      版本记录：版本号+时间+修改者+修改需求描述
      头注释结束---------------------------------------------------------------------------------------*/
       output_src varchar2(4000) ;
       iframe varchar2(4000) ;
       iframe_temp varchar2(4000) ;
       v_pvid varchar2(50);
begin
  iframe_temp:='';
  iframe:='';
  v_pvid:=pvid ;
 if pvid is not null then
    for p in (
    select A.exam_item_name 检查报告,a.Appsys_Emr_Id,a.Pat_Emr_Id from V_PAT_EXAMINE_INFO a where a.Pvid=v_pvid
    order by a.emr_dataset_code    
      ) loop
      Pkg_Clinical_View.Get_PDF$Pat_Emr_Id(p.Pat_Emr_Id,output_src) ;
      if output_src is not null then
       iframe_temp:='<span style="font-size:20px;"><a id="'||p.Pat_Emr_Id||'">'||p.检查报告||'</a></span><iframe  src="'||output_src||'" style="width: 100%; height:'||N_HEIGHT||'px;"></iframe>';
      if iframe_temp is null then
       iframe:=iframe_temp;
        else
        iframe:=iframe||iframe_temp ;  
       end if;
       end if;
    end loop;
    Output_Out:=iframe ;
 end if;
end Get_EXAMINE_PDF$PVID;  
--根据pvid获取导航列表
Procedure Get_LOCATION$PVID(pvid In varchar2, Output_Out Out Varchar2)  as
      /*头注释开始-----------------------------------------------------------------------------------------
      方法名称：根据CDR就诊ID获取带锚点html
      功能说明：根据CDR pvid获取带锚点的html 包含 病历、检验、检查
      入参说明：pvid
      出参说明：Output_Out  <table><span>病历</span><tr><li>病历名称1</li><li>病历名称2</li><li>病历名称3</li></tr><span>检验</span><tr><li>检验1</li><li>检验2</li><li>检验3</li></tr><span>检查</span><tr><li>检查1</li><li>检查2</li><li>检查3</li></tr></table>
      编 写 者：吴开波
      编写时间：2018-08-14
      版本记录：版本号+时间+修改者+修改需求描述
      头注释结束---------------------------------------------------------------------------------------*/
       output_emr varchar2(4000) ;
       v_emr varchar2(4000) ;
       v_emr_temp varchar2(4000) ;
       
       output_lis varchar2(4000) ;
       v_lis varchar2(4000) ;
       v_lis_temp varchar2(4000) ;
       
       output_examine varchar2(4000) ;
       v_examine varchar2(4000) ;
       v_examine_temp varchar2(4000) ;
       v_pvid varchar2(50);
begin
  v_lis:='';
  v_emr:='';
  v_EXAMINE:='';
  v_pvid:=pvid ;
 if pvid is not null then
   --获取门诊病历锚点
   for emr in (
    select A.Emr_Dataset_Name 病历名称,a.Appsys_Lnk_Emr_Id,a.Appsys_Emr_Id,a.Pat_Emr_Id from V_PAT_EMR_INFO a where  A.PVID=v_pvid
 order by a.emr_dataset_code   
      ) loop
      Pkg_Clinical_View.Get_PDF$Pat_Emr_Id(emr.Pat_Emr_Id,output_emr) ;
      if output_emr is not null then
       v_emr_temp:='<li style="list-style:none;padding-left:10px"><a href="#'||emr.Pat_Emr_Id||'">'||emr.病历名称||'</a></li>'; 
       v_emr:=v_emr||v_emr_temp ;  
       end if;
    end loop;
    if v_emr is not null then
    v_emr:='<span>病历名称</span><tr>'||v_emr||'</tr>' ;
    end if;
   --获取检验报告锚点
    for lis in (
    select a.lab_item_name 检验报告,a.Appsys_Emr_Id,a.Pat_Emr_Id from V_PAT_LIS_INFO a where A.PVID=v_pvid
    order by a.emr_dataset_code    
      ) loop
      Pkg_Clinical_View.Get_PDF$Pat_Emr_Id(lis.Pat_Emr_Id,output_lis) ;
      if output_lis is not null then
       v_lis_temp:='<li style="list-style:none;padding-left:10px"><a href="#'||lis.Pat_Emr_Id||'">'||lis.检验报告||'</a></li>'; 
      
        v_lis:=v_lis||v_lis_temp ;  
       
       end if;
    end loop;
    if v_lis is not null then
    v_lis:='<span>检验报告</span><tr>'||v_lis||'</tr>' ;
    end if;
    --获取检查报告锚点
    for examine in (
    select A.exam_item_name 检查报告,a.Appsys_Emr_Id,a.Pat_Emr_Id from V_PAT_EXAMINE_INFO a where a.Pvid=v_pvid
    order by a.emr_dataset_code    
      ) loop
      Pkg_Clinical_View.Get_PDF$Pat_Emr_Id(examine.Pat_Emr_Id,output_examine) ;
      if output_examine is not null then
       v_examine_temp:='<li style="list-style:none;padding-left:10px"><a href="#'||examine.Pat_Emr_Id||'">'||examine.检查报告||'</a></li>'; 
       v_examine:=v_examine||v_examine_temp ;  
       end if;
    end loop;
    if v_examine is not null then
    v_examine:='<span>检查报告</span><tr>'||v_lis||'</tr>' ;
    end if;
    --汇总病历、检验、检查HTML 串
    if (v_emr is not null) or (v_lis is not null) or (v_examine is not null) then
      Output_Out:='<table>'||v_emr||v_lis||v_examine||'</table>' ;
    
      end if;
    
 end if;
end Get_LOCATION$PVID;   

  --根据就诊ID获取住院视图[007]
  Procedure Get_Inp_View$Pvid(Pvid_In In Number, Page_Num_In In Number, App_ID_In Number, App_Session_In Number, Output_Out Out Clob, Max_Page_Out Out Number) As
    /*头注释开始-----------------------------------------------------------------------------------------
      方法名称：根据就诊ID获取住院视图[007]
      功能说明：根据就诊ID获取住院视图[007]
      入参说明：Pvid_In; Page_Num_In
      出参说明：Output_Out Clob(Json); Max_Page Number
      编 写 者：白天
      编写时间：2018-08-16
      版本记录：版本号+时间+修改者+修改需求描述
      头注释结束---------------------------------------------------------------------------------------*/
    d_Start_Date                         Date;     -- 入院时间
    d_End_Date                           Date;     -- 出院时间
    d_Time_Upper                         Date;     -- 时间上界
    d_Time_Lower                         Date;     -- 时间下界
    n_Hod_Days                         Number;     -- 住院天数
    l_HeadData                           Clob;
    l_YaxisData                          Clob;
    l_LineData                           Clob;
    l_VSData                             Clob;
    l_FooterData                         Clob;
    l_Items                              Clob;
    l_Item                               Clob;
    n_Temp                             Number;
    l_TemperatureYaxis  Constant Varchar2(100) := '34,35,36,37,38,39,40,41,42';
    v_PulseYaxis        Constant Varchar2(100) := '20,40,60,80,100,120,140,160,180';
  Begin
    If Pvid_In <> 0 Then
      --获取入院/出院时间
      Select Trunc(Pat_Visit_Start_Date, 'dd'), Trunc(Pat_Visit_End_Date, 'dd')
             Into d_Start_Date, d_End_Date
        From v_Pat_Visit_Info
       Where Pvid = Pvid_In;
      --病人未出院默认sysdate为最后时间
      If d_End_Date Is Null Then
        Select Trunc(sysdate,'dd') Into d_End_Date
          From Dual;
      End If;
      n_Hod_Days := d_End_Date - d_Start_Date + 1;
      Max_Page_Out := Ceil(n_Hod_Days/7);
      d_Time_Lower := d_Start_Date + (Page_Num_In-1)*7;
      d_Time_Upper := d_Start_Date + (Page_Num_In)*7;
      If d_Time_Upper > (d_End_Date+1) Then
        d_Time_Upper := d_End_Date+1;
      End If;
      --拼接HeadData   时间轴
      l_Items := Null;
      ---DateTime
      Select Listagg(DateTime,',') Within Group(Order By 1) Into l_Item
        From(Select Rownum,To_Char(Trunc(d_Time_Lower + Rownum-1,'dd'), 'YYYY-MM-DD') As DateTime 
               From dual 
         Connect By Rownum <= 7);
      l_Items := '"DateTime":"'||l_Item||'"';
      ---HOD
      l_Item := Null;
      For i In (d_Time_Lower-d_Start_Date+1) .. (d_Time_Upper-d_Start_Date) Loop
        l_Item := l_Item||','||i;
      End Loop;
      For i In (d_Time_Upper-d_Time_Lower+1) .. 7 Loop
        l_Item := l_Item||',';
      End Loop;
      l_Items := l_Items||',"HOD":"'||Ltrim(l_Item, ',')||'"';
      ---Remark
      l_Items := l_Items||',"Remark":""';
      ---TimeSpan
      l_Items := l_Items||',"TimeSpan":"0,4,8,12,16,20"';
      ---汇总
      l_HeadData := '"HeadData":{'||l_Items||'}';

      --拼接YaxisData   体温/脉搏折线图Y轴
      ---体温
      ---脉搏
      l_YaxisData := '"YaxisData":{"GroupOne":{"Title":"体温","Data":"'||l_TemperatureYaxis||'"},"GroupTwo":{"Title":"脉搏","Data":"'||v_PulseYaxis||'"}}';

      --拼接LineData   体温/脉搏/心率值
      l_Items := Null;
      ---体温
      l_Item := Null;
      Select Listagg((Occur_Time - to_date('1970-01-01','yyyy-mm-dd'))*86400000 || ',' || Record_Content,'|') Within Group(Order By occur_time) 
        Into l_Item
        From v_Pat_Vital_Sign_Info
       Where pvid = Pvid_In
         And Item_Name = '体温'
         And Occur_Time Between d_Time_Lower And d_Time_Upper;
      l_Items := '"GroupOne":{"Title":"体温","Number":"'||l_Item||'"}';
      ---脉搏
      l_Item := Null;
      Select Listagg((Occur_Time - to_date('1970-01-01','yyyy-mm-dd'))*86400000 || ',' || Record_Content,'|') Within Group(Order By occur_time) 
        Into l_Item
        From v_Pat_Vital_Sign_Info
       Where pvid = Pvid_In
         And Item_Name = '脉搏'
         And Occur_Time Between d_Time_Lower And d_Time_Upper;
      l_Items := l_Items||',"GroupTwo":{"Title":"脉搏","Number":"'||l_Item||'"}';
      ---心率
      l_Item := Null;
      Select Listagg((Occur_Time - to_date('1970-01-01','yyyy-mm-dd'))*86400000 || ',' || Record_Content,'|') Within Group(Order By occur_time) 
        Into l_Item
        From v_Pat_Vital_Sign_Info
       Where pvid = Pvid_In
         And Item_Name = '心率'
         And Occur_Time Between d_Time_Lower And d_Time_Upper;
      l_Items := l_Items||',"GroupThree":{"Title":"心率","Number":"'||l_Item||'"}';
      ---汇总
      l_LineData := '"LineData":{'||l_Items||'}';

      --拼接VSData   其他生命体征
      l_Items := Null;
      ---血压
      ----收缩压
      l_Item := Null;
      Select Listagg((Occur_Time - to_date('1970-01-01','yyyy-mm-dd'))*86400000 || ',' || Record_Content,'|') Within Group(Order By occur_time) 
        Into l_Item
        From v_Pat_Vital_Sign_Info
       Where pvid = Pvid_In
         And Item_Name = '收缩压'
         And Occur_Time Between d_Time_Lower And d_Time_Upper;
      l_Items := '"BloodPressure":{"SP":"'||l_Item||'",';
      ----舒张压
      l_Item := Null;
      Select Listagg((Occur_Time - to_date('1970-01-01','yyyy-mm-dd'))*86400000 || ',' || Record_Content,'|') Within Group(Order By occur_time) 
        Into l_Item
        From v_Pat_Vital_Sign_Info
       Where pvid = Pvid_In
         And Item_Name = '舒张压'
         And Occur_Time Between d_Time_Lower And d_Time_Upper;
      l_Items := l_Items||'"DP":"'||l_Item||'"},';
      ---其他  如果呼吸身高体重
      l_Items := l_Items||'"More":[';
      n_Temp := 1;
      For i In (Select a.Item_No, Nvl2(Item_Unit, Item_Name||'('||Item_Unit||')', Item_Name) As Item_Name, Item_Frequency, 
                       Decode(Item_Frequency,1,'Word','Number') As Item_Type
                  From v_Vital_Sign_Item a,
                      (Select Distinct Item_No
                         From v_Pat_Vital_Sign_Info
                        Where Pvid = Pvid_In
                          And Occur_Time Between d_Time_Lower And d_Time_Upper)b
                 Where a.Item_No = b.Item_No
                   And a.Item_No Not In (-1, 1, 2, 4, 5)
              Order By Item_Frequency Desc, Order_No) Loop
        l_Item := Null;
        If i.Item_Frequency = 1 Then
          Select Listagg(Nvl(Record_Content, '-'),',')Within Group(Order By DateTime) Into l_Item
            From(Select Trunc(Occur_Time, 'dd') As Occur_Time, Record_Content
                   From v_Pat_Vital_Sign_Info
                  Where Pvid = Pvid_In
                    And Item_No = i.Item_No
                    And Occur_Time Between d_Time_Lower And d_Time_Upper) a,
                (Select Rownum,Trunc(d_Time_Lower + Rownum-1,'dd') As DateTime 
                   From Dual 
             Connect By Rownum < 8) b
           Where b.DateTime = a.Occur_Time(+);
        Else
          Select Listagg((Occur_Time - to_date('1970-01-01','yyyy-mm-dd'))*86400000 || ',' || Record_Content,'|') Within Group(Order By occur_time) 
            Into l_Item
            From v_Pat_Vital_Sign_Info
           Where pvid = Pvid_In
             And Item_No = i.Item_No
             And Record_Time Between d_Time_Lower And d_Time_Upper;
        End If;        
        l_Item := '{"Title":"'||i.Item_Name||'","Type":"'||i.Item_Type||'","Data":"'||l_Item||'"}';
        If n_Temp = 1 Then
          l_Items := l_Items||l_Item;
        Else
          l_Items := l_Items||','||l_Item;
        End If;
        n_Temp := n_Temp + 1;
      End Loop; 
      l_Items := l_Items||']';
      l_VSData := '"VSData":{'||l_Items||'}';

      --拼接FooterData  底部数据
      ---诊断
      l_Items := '"Diagnosis":[';
      n_Temp := 1;
      l_Item := Null;
      For i In (Select Trunc(Nvl(Pat_Diag_Record_Time, d_Start_Date),'dd')-d_Time_Lower+1 As DateTime, Pat_Diag_Desc
                  From v_Pat_Diag_Info
                 Where Pvid = Pvid_In
                   And Pat_Diag_Desc Is Not Null
                   And Nvl(Pat_Diag_Record_Time, d_Start_Date) Between d_Time_Lower And d_Time_Upper
              Order By DateTime) Loop
        l_Item := '{"Date":"'||i.DateTime||'","Text":"'||i.Pat_Diag_Desc||'"}';
        If n_Temp = 1 Then
          l_Items := l_Items||l_Item;
        Else
          l_Items := l_Items||','||l_Item;
        End If;
        n_Temp := n_Temp + 1;
      End Loop;
      l_Items := l_Items||']';
      ---长嘱
      l_Items := l_Items||',"SecularMedicine":[';
      n_Temp := 1;
      l_Item := Null;
      For i In(Select Distinct Order_Item, 
                      Listagg(Start_Day||'-'||End_Day, '|') Within Group(Order By Start_Day) Over(Partition By Order_Item) As DateTime 
                 From(Select Distinct Order_Item,
                        Case
                          When (Trunc(Order_Start_Time,'dd')-d_Time_Lower+1) > 0 Then (Trunc(Order_Start_Time,'dd')-d_Time_Lower+1)||':'||To_Char(Order_Start_Time,'hh24')
                          Else '1:0'
                        End Start_Day,
                        Case
                          When (Trunc(Order_End_Time,'dd')-d_Time_Lower+1) > 7 Then '7:24'
                          Else (Trunc(Order_Start_Time,'dd')-d_Time_Lower+1)||':'||To_Char(Order_End_Time,'hh24')
                        End End_Day
                   From v_Pat_Drug_Info
                  Where Pvid = Pvid_In
                    And Order_Type_Name = '长期医嘱'
                    And Order_Start_Time < d_Time_Upper
                    And Order_End_Time > d_Time_Lower)
             Order By DateTime) Loop
        l_Item := '{"Date":"'||i.DateTime||'","Text":"'||i.Order_Item||'"}';
        If n_Temp = 1 Then
          l_Items := l_Items||l_Item;
        Else
          l_Items := l_Items||','||l_Item;
        End If;
        n_Temp := n_Temp + 1;
      End Loop;
      l_Items := l_Items||']';
      ---临嘱
      l_Items := l_Items||',"TempMedicine":[';
      n_Temp := 1;
      l_Item := Null;
      For i In(Select Trunc(Order_Start_Time,'dd')-d_Time_Lower+1 As DateTime, Order_Item
                 From v_Pat_Drug_Info
                Where Pvid = Pvid_In
                  And Order_Type_Name = '临时医嘱'
                  And Order_Start_Time Between d_Time_Lower And d_Time_Upper
             Order By Order_Start_Time) Loop
        l_Item := '{"Date":"'||i.DateTime||'","Text":"'||i.Order_Item||'"}';
        If n_Temp = 1 Then
          l_Items := l_Items||l_Item;
        Else
          l_Items := l_Items||','||l_Item;
        End If;
        n_Temp := n_Temp + 1;
      End Loop;
      l_Items := l_Items||']';
      ---检查
      l_Items := l_Items||',"Examination":[';
      n_Temp := 1;
      l_Item := Null;
      For i In(Select Trunc(Emr_Create_Time,'dd')-d_Time_Lower+1 As DateTime, Exam_Item_Name,
                      'f?p='||App_ID_In||':206:'||App_Session_In||':T:::P206_PAT_EMR_ID:'||Pat_Emr_Id As Link
                 From v_Pat_Examine_info
                Where Pvid = Pvid_In
                  And Emr_Create_Time Between d_Time_Lower And d_Time_Upper
             Order By Emr_Create_Time) Loop
        l_Item := '{"Date":"'||i.DateTime||'","Text":"'||i.Exam_Item_Name||'","Link":"'||i.Link||'"}';
        If n_Temp = 1 Then
          l_Items := l_Items||l_Item;
        Else
          l_Items := l_Items||','||l_Item;
        End If;
        n_Temp := n_Temp + 1;
      End Loop;
      l_Items := l_Items||']';

      ---检验
      l_Items := l_Items||',"Laboratory":[';
      n_Temp := 1;
      l_Item := Null;
      For i In(Select Trunc(Emr_Create_Time,'dd')-d_Time_Lower+1 As DateTime, Lab_Item_Name,
                      'f?p='||App_ID_In||':206:'||App_Session_In||':T:::P205_PAT_EMR_ID:'||Pat_Emr_Id As Link
                 From v_Pat_Lis_Info
                Where Pvid = Pvid_In
                  And Emr_Create_Time Between d_Time_Lower And d_Time_Upper
             Order By Emr_Create_Time) Loop
        l_Item := '{"Date":"'||i.DateTime||'","Text":"'||i.Lab_Item_Name||'","Link":"'||i.Link||'"}';
        If n_Temp = 1 Then
          l_Items := l_Items||l_Item;
        Else
          l_Items := l_Items||','||l_Item;
        End If;
        n_Temp := n_Temp + 1;
      End Loop;
      l_Items := l_Items||']';

      ---手术
      --l_Items := l_Items||',"Operation":""';

      ---病历文书
      l_Items := l_Items||',"MedicalRecord":[';
      n_Temp := 1;
      l_Item := Null;
      For i In(Select Trunc(Emr_Create_Time,'dd')-d_Time_Lower+1 As DateTime, Emr_Dataset_Name,
                      'f?p='||App_ID_In||':206:'||App_Session_In||':T:::P202_PAT_EMR_ID:'||Pat_Emr_Id As Link
                 From v_Pat_Emr_Info
                Where Pvid = Pvid_In
                  And Emr_Create_Time Between d_Time_Lower And d_Time_Upper
             Order By Emr_Create_Time, Emr_Dataset_Code) Loop
        l_Item := '{"Date":"'||i.DateTime||'","Text":"'||i.Emr_Dataset_Name||'","Link":"'||i.Link||'"}';
        If n_Temp = 1 Then
          l_Items := l_Items||l_Item;
        Else
          l_Items := l_Items||','||l_Item;
        End If;
        n_Temp := n_Temp + 1;
      End Loop;
      l_Items := l_Items||']';

      ---其他长嘱
      l_Items := l_Items||',"SecularOtherOrder":[';
      n_Temp := 1;
      l_Item := Null;
      For i In(Select Distinct Order_Item, 
                      Listagg(Start_Day||'-'||End_Day, '|') Within Group(Order By Start_Day) Over(Partition By Order_Item) As DateTime 
                 From(Select Distinct Order_Item,
                        Case
                          When (Trunc(Order_Start_Time,'dd')-d_Time_Lower+1) > 0 Then (Trunc(Order_Start_Time,'dd')-d_Time_Lower+1)||':'||To_Char(Order_Start_Time,'hh24')
                          Else '1:0'
                        End Start_Day,
                        Case
                          When (Trunc(Order_End_Time,'dd')-d_Time_Lower+1) > 7 Then '7:24'
                          Else (Trunc(Order_Start_Time,'dd')-d_Time_Lower+1)||':'||To_Char(Order_End_Time,'hh24')
                        End End_Day
                   From v_Pat_Other_Order
                  Where Pvid = Pvid_In
                    And Order_Type_Name = '长期医嘱'
                    And Order_Start_Time < d_Time_Upper
                    And Order_End_Time > d_Time_Lower)
             Order By DateTime) Loop
        l_Item := '{"Date":"'||i.DateTime||'","Text":"'||i.Order_Item||'"}';
        If n_Temp = 1 Then
          l_Items := l_Items||l_Item;
        Else
          l_Items := l_Items||','||l_Item;
        End If;
        n_Temp := n_Temp + 1;
      End Loop;
      l_Items := l_Items||']';

      ---其他临嘱
      l_Items := l_Items||',"TempOtherOrder":[';
      n_Temp := 1;
      l_Item := Null;
      For i In(Select Trunc(Order_Start_Time,'dd')-d_Time_Lower+1 As DateTime, Order_Item
                 From v_Pat_Other_Order
                Where Pvid = Pvid_In
                  And Order_Type_Name = '临时医嘱'
                  And Order_Start_Time Between d_Time_Lower And d_Time_Upper
             Order By Order_Start_Time) Loop
        l_Item := '{"Date":"'||i.DateTime||'","Text":"'||i.Order_Item||'"}';
        If n_Temp = 1 Then
          l_Items := l_Items||l_Item;
        Else
          l_Items := l_Items||','||l_Item;
        End If;
        n_Temp := n_Temp + 1;
      End Loop;
      l_Items := l_Items||']';

      l_FooterData := '"FooterData":{'||l_Items||'}';
      Output_Out := '{'||l_HeadData||','||l_YaxisData||','||l_LineData||','||l_VSData||','||l_FooterData||
                  ',"StartTime":"'||To_Char(d_Time_Lower,'YYYY-MM-DD')||' 08:00:00","EndTime":"'||
                  To_Char(d_Time_Lower+7,'YYYY-MM-DD')||' 08:00:00"}';
    Else
      Null;
    End If;
  End Get_Inp_View$Pvid;
  
End Pkg_Clinical_View;

/
