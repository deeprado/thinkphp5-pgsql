# thinkphp5-pgsql

基于thinkphp5 5.0.9. 

默认地， 使用Pgsql前，需要执行SQL脚本。
默认是在public模式下，不支持其他自定义模式。 
需要先导入 thinkphp/library/think/db/connector/pgsql.sql文件到数据库执行。

解决方案： 
根据5.0,5.1 目录进行选择。 
需要将所有“tp5”,"tp51",该为目标模式，比如test. 
-- Linux 
	$ sed -i 's#tp5#<test>#g' tp5.sql 
-- Windows 
	使用编辑器全局替换，比如Notepad. 

同时，调整 thinkphp/library/think/db/connector/Pgsql.php 文件，修改 方法 getFields。 
...
	$sql = ... from table_msg(\'' . $tableName . '\');';
	修改改为： 
	$sql = ... from <test>.table_msg(\'' . $tableName . '\');';
...

补充： 
	可以在extend 扩展中，新建Pgsql连接类，对方法 getFields 进行重写，参考extend/org/db/PgsqlClient.php。 
	同时修改database.php , 
........... 
	'type'        => '\org\db\PgsqlClient',		//扩展类
	'schema' => 'tp51',							//模式
	'builder'=> '\\think\\db\\builder\\Pgsql'   //必须加，否则会提示致命错误: Class '\think\db\builder\\org\PgsqlClient' not found
........... 


未完待续。。。
	
	
