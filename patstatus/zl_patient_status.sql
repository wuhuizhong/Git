Declare
 v_Count Number;
 v_Path  Varchar2(255);
Begin
 Select Count(*) Into v_Count From Dba_Tablespaces Where Upper(Tablespace_Name) = Upper('zl_patient_status');
 If Nvl(v_Count, 0) = 0 Then
   Select Substr(File_Name,
                  1,
                  Decode(Instr(File_Name, '\', -1), 0, Instr(File_Name, '/', -1), Instr(File_Name, '\', -1)))
   Into v_Path
   From Dba_Data_Files
   Where Upper(Tablespace_Name) = Upper('SYSTEM') And Rownum < 2;

Execute Immediate 'Create Tablespace zl_patient_status Datafile ''' || v_Path ||
                     'zl_patient_status_data.dbf'' SIZE 1048576 REUSE AUTOEXTEND ON NEXT 102400 K MAXSIZE UNLIMITED
LOGGING ONLINE DEFAULT NOCOMPRESS NO INMEMORY EXTENT MANAGEMENT LOCAL AUTOALLOCATE FLASHBACK ON ';
 End If;

 Select Count(*) Into v_Count From Dba_Tablespaces Where Upper(Tablespace_Name) = Upper('zl_patient_status_ix');
 If Nvl(v_Count, 0) = 0 Then
   Select Substr(File_Name,
                  1,
                  Decode(Instr(File_Name, '\', -1), 0, Instr(File_Name, '/', -1), Instr(File_Name, '\', -1)))
   Into v_Path
   From Dba_Data_Files
   Where Upper(Tablespace_Name) = Upper('SYSTEM') And Rownum < 2;

Execute Immediate 'Create Tablespace zl_patient_status_ix Datafile ''' || v_Path ||
                     'zl_patient_status_ix_data.dbf'' SIZE 1048576 REUSE AUTOEXTEND ON NEXT 102400 K MAXSIZE UNLIMITED
LOGGING ONLINE DEFAULT NOCOMPRESS NO INMEMORY EXTENT MANAGEMENT LOCAL AUTOALLOCATE FLASHBACK ON ';
 End If;
End;
/
