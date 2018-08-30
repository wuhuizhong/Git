-- Create the user
--需要再安装APEX执行
create user ZLRECIPE identified by zlsoft
      default tablespace ZLR_REVIEWE
      temporary tablespace TEMP
      profile DEFAULT
      password expire
      quota unlimited on ZLR_REVIEWE;
-- Grant/Revoke object privileges
grant execute, debug on APEX_180100.HTMLDB_UTIL to ZLRECIPE;
grant execute on SYS.DBMS_LOB to ZLRECIPE;
grant execute on SYS.UTL_FILE to ZLRECIPE;
-- Grant/Revoke role privileges
grant apex_administrator_role to ZLRECIPE;
grant dba to ZLRECIPE with admin option;
-- Grant/Revoke system privileges
grant create any index to ZLRECIPE;
grant create any table to ZLRECIPE;
grant create any trigger to ZLRECIPE;
grant create any view to ZLRECIPE;
grant create cluster to ZLRECIPE;
grant create dimension to ZLRECIPE;
grant create indextype to ZLRECIPE;
grant create job to ZLRECIPE;
grant create materialized view to ZLRECIPE;
grant create operator to ZLRECIPE;
grant create procedure to ZLRECIPE;
grant create sequence to ZLRECIPE;
grant create session to ZLRECIPE;
grant create synonym to ZLRECIPE;
grant create table to ZLRECIPE;
grant create trigger to ZLRECIPE;
grant create type to ZLRECIPE;
grant create view to ZLRECIPE;
grant debug any procedure to ZLRECIPE;
grant debug connect session to ZLRECIPE;
GRANT apex_administrator_role TO ZLRECIPE;
grant unlimited tablespace to ZLRECIPE with admin option;
