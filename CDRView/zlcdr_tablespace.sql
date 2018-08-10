Declare
 v_Count Number;
 v_Path  Varchar2(255);
 v_tablespace varchar2(80);
Begin
 --����Ƿ���ڸñ�ռ�
 v_tablespace:=Upper('zlcdr_tbs');
 Select Count(*) Into v_Count From Dba_Tablespaces Where Upper(Tablespace_Name) = v_tablespace;
 If Nvl(v_Count, 0) = 0 Then
   --Ѱ�һ�׼��ռ䣬��SYSTEM�ı�ռ�Ϊ��׼��Ѱ���ļ�·����ע��·������Winϵͳ��Linuxϵͳ
   Select Substr(File_Name,
                  1,
                  Decode(Instr(File_Name, '\', -1), 0, Instr(File_Name, '/', -1), Instr(File_Name, '\', -1)))
   Into v_Path
   From Dba_Data_Files
   Where Upper(Tablespace_Name) = Upper('SYSTEM') And Rownum < 2;

Execute Immediate 'Create Tablespace '||v_tablespace||' Datafile ''' || v_Path ||
                     v_tablespace||'_data.dbf'' SIZE 1048576 REUSE AUTOEXTEND ON NEXT 102400 K MAXSIZE UNLIMITED
LOGGING ONLINE DEFAULT NOCOMPRESS NO INMEMORY EXTENT MANAGEMENT LOCAL AUTOALLOCATE FLASHBACK ON ';
 End If;
End;
/
