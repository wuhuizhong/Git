CREATE OR REPLACE Package Pkg_Clinical_View Is

  -- Author  : 天
  -- Created : 2018/8/8 9:40:00
  -- Purpose : 临床视图相关存储过程
  
  --根据患者ID获取患者就诊时间轴[001]
  Procedure Get_Visit_TimeLine$Pid(Pid_In In Number, Output_Out Out Clob);

  --根据CDR病历ID获取病历PDF地址[002]
  Procedure Get_PDF$Pat_Emr_Id(Pat_Emr_Id_In In Number, Output_Out Out Varchar2);
  
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
                  From v_Pat_Diag 
                 Where Pvid = i.Pvid
                   And Diag_Name Is Not Null
              Order By Pat_Diag_Type Desc,Pat_Diag_Sno)
         Where Rownum = 1;        
        Select regexp_replace(Listagg(Pat_Diag_Desc,'</br>')within group(order by 1), '([^</br>]+)(</br>\1)+', '\1') Into v_Diags
          From (Select Pat_Diag_Sno, Pat_Diag_Type, Pat_Diag_Desc
                  From v_Pat_Diag 
                 Where pvid = i.Pvid
              Order By Pat_Diag_Type, Pat_Diag_Sno);
        l_SimgleVisit := l_SimgleVisit||',{"date":"'||i.Pat_Visit_Date||'","type":"'||i.Pat_Visit_Type_Name||'","pvid":"'||i.Pvid||
                        '","firstdiag":"'||v_First_Diag||'","totaldiag":"'||v_Diags||'"}';
      End Loop;
      Output_Out := '{"data":['|| Ltrim(l_SimgleVisit, ',')||']}';
    Else
      Output_Out := '{"data":[{"date":"","type":"","pvid":"","firstdiag":"","totaldiag":""}]}';
    End If;
  End;

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
            v_Antetype_Id := 'N5';
          Else
            If Length(i.Appsys_Emr_Antetype_Id) = 32 Then
              v_Antetype_Id := 'E1';
            Else
              v_Antetype_Id := 'H1';
            End If;
          End If;
        Elsif i.Pat_Visit_Type_Name = '门诊' Or i.Pat_Visit_Type_Name = '急诊' Then
          If i.Emr_Dataset_Name = '检验报告' Then
            v_Antetype_Id := 'N3';
          Else
            If Length(i.Appsys_Emr_Antetype_Id) = 32 Then
              v_Antetype_Id := 'E0';
            Else
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
  End;
    
End Pkg_Clinical_View;

/
