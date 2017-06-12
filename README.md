# WYDatabase
数据库映射模型的封装 极大简化了数据库操作 具体Demo 比较详细
开发版本1.0.0 持续更新



使用：
1.  [[WYDatabaseManager manager] configWithUserID:userID];
#    调用初始化方法，以不同用户的形式初始化数据库文件

2.  LLStudentModel *model = [[LLStudentModel alloc]init];
#    LLStudentModel 继承于 WYDatabaseModel 
#    所有非单下划线开头的属性都将自动创建为数据库字段
#    所有以单下划线开头的属性将不会自动创建数据库字段

3.  [model save]
#    自动保存
