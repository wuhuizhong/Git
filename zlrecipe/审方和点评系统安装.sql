
--ע�⣺�����Ȱ�װAPEX��ORDS
--��Sys��ݵ�¼
--������ռ�
@@ZLR_REVIEWE.sql;
--�����û�
@@zlrecipe_create_user.sql;
--������
@@zlrecipe_table.sql;

--��������
@@zlrecipe_sequence.sql;

--������ͼ
@@zlrrecipe_view.sql;

--�����ʼ����

--ADMIN�û�

@@��ʼ����/zlrecipe_admin_user.sql;
--����
@@��ʼ����/zlrecipe_para.sql;
--�󷽲�ͨ������
@@��ʼ����/zlrecipe_no_pass_reason.sql;

--������ϸ
delete ZLRECIPE.REVIEWE_SOLUTION;
delete ZLRECIPE.REVIEWE_SOLUTION_DETAIL;

@@��ʼ����/zlrecipe_solution.sql;
@@��ʼ����/zlrecipe_solution_detail.sql;

commit;
--��װ�����
--���������
@@�����/APEXIR_XLSX_PKG.sql;
@@�����/AS_ZIP.sql;
@@�����/FTP.sql;
@@�����/IR_TO_MSEXCEL.sql;
@@�����/IR_TO_XLSX.sql;
@@�����/WS_NOTIFY_API.sql;

--���жϷ���
@@�����/zlrecipe_REVIEWE_SOLUTION_RUN.sql;

--���������
@@�����/PKG_RECIPE_COMMENT.sql;
--�󷽳����
@@�����/PKG_RECIPE_REVIEWE.sql;


--RESTFul����
--@@zlrecipe_restful.sql
