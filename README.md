# thinkphp5-pgsql

## 基于 Thinkphp5

### 1. 默认连接操作
默认地， 使用Pgsql前，需要执行SQL脚本。   
默认是在public模式下，不支持其他自定义模式。  
需要先导入 thinkphp/library/think/db/connector/pgsql.sql文件到数据库执行。 
可参考：https://www.kancloud.cn/manual/thinkphp5_1/353998

### 2. 手动解决方案

> * 修改模式

    根据版本 5.0,5.1 目录进行选择（实际上没什么区别）。需要将所有“tp5”,"tp51",该为目标模式，比如test. 
-- Linux 
```shell
	$ sed -i 's#tp5#<test>#g' tp5.sql 
```
-- Windows 
    使用编辑器全局替换，比如Notepad.



### 3. 自动解决方案
	
> * 修改模式
  
  同上
> * 实现扩展

参考 extend .
> * 数据库配置

修改 database.php
```php 
	'type'        => '\org\db\PgsqlClient',		//扩展类
	'schema' => 'tp51',							//模式
	//必须加，否则会提示致命错误: Class '\think\db\builder\\org\PgsqlClient' not found
	'builder'=> '\\think\\db\\builder\\Pgsql'   
```


未完待续。。。

	
