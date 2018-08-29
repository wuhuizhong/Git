--需要修改IP地址等信息
create public database link to_zlhis connect to zlhis identified by HIS using '(DESCRIPTION =(ADDRESS = (PROTOCOL = TCP)(HOST = 192.168.0.43)(PORT = 1521))(CONNECT_DATA =(SERVER = DEDICATED)(SERVICE_NAME = his)))';

create public database link to_zlkbc connect to rudrug identified by rudrug using '(DESCRIPTION =(ADDRESS = (PROTOCOL = TCP)(HOST = 192.168.32.203)(PORT = 1521))(CONNECT_DATA =(SERVER = DEDICATED)(SERVICE_NAME = zlkbc)))';