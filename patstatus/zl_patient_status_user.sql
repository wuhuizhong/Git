-- Create the user
create user patstatus identified by zlsoft
      default tablespace zl_patient_status
      temporary tablespace TEMP
      profile DEFAULT
      password expire
      quota unlimited on zl_patient_status;
-- Grant/Revoke object privileges
grant execute, debug on APEX_180100.HTMLDB_UTIL to patstatus;
grant execute on SYS.DBMS_LOB to patstatus;
grant execute on SYS.UTL_FILE to patstatus;
-- Grant/Revoke role privileges
grant apex_administrator_role to patstatus;
grant dba to patstatus with admin option;
-- Grant/Revoke system privileges
grant create any index to patstatus;
grant create any table to patstatus;
grant create any trigger to patstatus;
grant create any view to patstatus;
grant create cluster to patstatus;
grant create dimension to patstatus;
grant create indextype to patstatus;
grant create job to patstatus;
grant create materialized view to patstatus;
grant create operator to patstatus;
grant create procedure to patstatus;
grant create sequence to patstatus;
grant create session to patstatus;
grant create synonym to patstatus;
grant create table to patstatus;
grant create trigger to patstatus;
grant create type to patstatus;
grant create view to patstatus;
grant debug any procedure to patstatus;
grant debug connect session to patstatus;
GRANT apex_administrator_role TO patstatus;
grant unlimited tablespace to patstatus with admin option;
