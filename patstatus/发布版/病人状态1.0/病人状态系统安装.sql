
--ע�⣺�����Ȱ�װAPEX��ORDS
--��Sys��ݵ�¼
--������ռ�
@@1-������ռ���û�/zl_patient_status.sql;
--�����û�
@@1-������ռ���û�/zl_patient_status_user.sql;
--����DBLINK
@@2-��¼patstatus����DBLINK/patstatus_dblink.sql;

--3-���������ͼ�����С�����
@@3-���������ͼ�����С�����/���������ͼ_����_����.sql;


--�����ʼ����

--�����ֵ�
@@4-��ʼ����/DICT_DEPT.sql;
--�Ա��ֵ�
@@4-��ʼ����/DICT_GENDER.sql;
--�����ֵ�
@@4-��ʼ����/DICT_MARRIAGE.sql;
--�����б�
@@4-��ʼ����/ENVR_LIST.sql;
--״̬����
@@4-��ʼ����/STATUS_TYPE.sql;

commit;

--��װ�����

--״̬�������
@@5-�����/PKG_STATUS_MANAGE.sql;

--״̬��ѯ����
@@5-�����/PKG_STATUS_QUERY.sql;

--״̬��¼����
@@5-�����/PKG_STATUS_RECORD.sql;

--REST����
--@@6-REST����/patstatus_service.sql;


