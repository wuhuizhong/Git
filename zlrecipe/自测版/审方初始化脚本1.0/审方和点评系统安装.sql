
--ע�⣺�����Ȱ�װAPEX��ORDS
--��Sys��ݵ�¼
--������ռ�
@@1-������ռ���û�/ZLR_REVIEWE.sql;
--�����û�
@@1-������ռ���û�/zlrecipe_create_user.sql;
--����DBLINK
@@2-��¼ZLRECIPE����DBLINK/zlrecipe_dblink.sql;

--3-���������ͼ�����С�����
@@3-���������ͼ�����С�����/table_view_sequence_index.sql;


--�����ʼ����

--ADMIN�û�
@@4-��ʼ����/zlrecipe_admin_user.sql;
--����
@@4-��ʼ����/zlrecipe_para.sql;
--�󷽲�ͨ������
@@4-��ʼ����/zlrecipe_no_pass_reason.sql;
--ƴ��
@@4-��ʼ����/ZLPINYIN.sql;
--����������Ŀ
@@4-��ʼ����/ZLRECIPE_COMMENT_ITEM.sql;
--��˷���
@@4-��ʼ����/zlrecipe_solution.sql;
--��˷�����ϸ
@@4-��ʼ����/zlrecipe_solution_detail.sql;

commit;

--��װ�����
--���������
@@5-�����/APEXIR_XLSX_PKG.sql;
@@5-�����/AS_ZIP.sql;
@@5-�����/FTP.sql;
@@5-�����/IR_TO_MSEXCEL.sql;
@@5-�����/IR_TO_XLSX.sql;
@@5-�����/WS_NOTIFY_API.sql;

--���������
@@5-�����/PKG_RECIPE_COMMENT.sql;
--�󷽳����
@@5-�����/PKG_RECIPE_REVIEWE.sql;

--���жϷ��������̺���
@@�����/���̺���.sql;


--����
--@@6-REST����/recipe_service.sql;

--����JOB
--@@7-����JOB/create_job.sql;
