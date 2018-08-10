Declare
 v_Count Number;
 v_Path  Varchar2(255);
 v_tablespace varchar2(80);
Begin
 --检查是否存在该表空间
 v_tablespace:=Upper('zlcdr_tbs');
 Select Count(*) Into v_Count From Dba_Tablespaces Where Upper(Tablespace_Name) = v_tablespace;
 If Nvl(v_Count, 0) = 0 Then
   --寻找基准表空间，以SYSTEM的表空间为基准，寻找文件路径，注意路径区分Win系统与Linux系统
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
