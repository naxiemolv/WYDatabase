//
//  WYDatabaseModel.m
//  WYDatabase
//
//  Created by 李育洋 on 2017/6/8.
//  Copyright © 2017年 walktewy. All rights reserved.
//

#import "WYDatabaseModel.h"
#import "WYDatabaseManager.h"

#define WYDB_DEBUG 1

#define kSQLiteTEXT @"TEXT DEFAULT ''"
#define kSQLiteINTEGER @"INTEGER DEFAULT 0"
#define kSQLiteREAL @"REAL"
#define kSQLiteBLOB @"BLOB"
#define kSQLiteNULL @"NULL"
#define kSQLitePrimaryKey @"ID"

#define WYDatabaseVerbose 1

@interface WYDatabaseModel()
@property (nonatomic,strong) NSArray *propertiesAndName;

@end

@implementation WYDatabaseModel

- (instancetype)init {
    self = [super init];
    if (self) {
        NSString *tableName = [NSStringFromClass([self class])lowercaseString];
        _propertiesAndName = [[WYDatabaseManager manager].tableNameHash objectForKey:tableName];
        if (!_propertiesAndName||_propertiesAndName.count == 0) {
            [[WYDatabaseManager manager].tableNameHash setObject:[[self class] getAllProperies] forKey:tableName];
            [[self class] migrateTable];
        }
                              
    }
    return self;
}

+ (NSString *)getTableName {
    return [NSString stringWithFormat:@"t_%@",NSStringFromClass([self class]).lowercaseString];
}

+ (BOOL)migrateTable {
    __block BOOL result = YES;
    WYDatabaseManager *manager = [WYDatabaseManager manager];
    [manager.dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        NSString *tableName = [[self class]getTableName];
        NSString *columnAndType = [[self class] columnsWithType];
        if (!(columnAndType.length>0)) {
            result = NO;
            return;
        }
        NSString *sql = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (%@ INTEGER PRIMARY KEY, %@);",tableName,kSQLitePrimaryKey,columnAndType];
        
        if (![db executeUpdate:sql]) {
            result = NO;
            *rollback = YES;
            return ;
        }
        NSMutableArray *columns = [NSMutableArray array];
        FMResultSet *resultSet = [db getTableSchema:tableName];
        while ([resultSet next]) {
            NSString *column = [resultSet stringForColumn:@"name"];
            [columns addObject:column];
        }
        NSArray *allProperties = [[self class] getAllProperies];
        //找出模型中有 但数据库没有的字段
        for (int i = 0; i<allProperties.count; i++) {
            BOOL found = NO;
            NSString *aColumn = allProperties[i][0];
            for (int j = 0; j<columns.count; j++) {
                if ([columns[j] isEqualToString:aColumn]) {
                    found = YES;
                    break;
                }
            }
            if (found == NO) {
                NSString *keys = [NSString stringWithFormat:@"%@ %@",allProperties[i][0],allProperties[i][1]];
                NSString *sql = [NSString stringWithFormat:@"ALTER TABLE %@ ADD COLUMN %@ ",tableName,keys];
                if (![db executeUpdate:sql]) {
                    result = NO;
                    *rollback = YES;
                    return ;
                }
            }
        }
    }];
    return result;
}

+ (NSString *)columnsWithType {
    NSMutableString *sql = [NSMutableString string];
    NSArray *propertiesAndNames = [[self class] getAllProperies];
    NSInteger count = propertiesAndNames.count;
    for (int i = 0; i<count; i++) {
        [sql appendFormat:@"%@ %@",propertiesAndNames[i][0],propertiesAndNames[i][1]];
        if (i+1 != count) [sql appendString:@","];
    }
    return sql;
}

/** 获取类的属性 注意,过滤了以单下划线为开头的属性 可拓展*/
+ (NSArray *)getAllProperies {
    NSMutableArray *propertiesAndName = [NSMutableArray array];
    unsigned int count, i;
    objc_property_t *properties = class_copyPropertyList([self class], &count);
    for (i = 0; i < count; i++) {
        objc_property_t property = properties[i];
        NSString *propertyName = [NSString stringWithCString:property_getName(property) encoding:NSUTF8StringEncoding];
        if ([propertyName hasPrefix:@"_"]) continue;

        NSString *propertyType = [NSString stringWithCString: property_getAttributes(property) encoding:NSUTF8StringEncoding];
        NSLog(@"%@==%@",propertyName,propertyType);
        
        
        //propertyName = [propertyName lowercaseString];
        NSString *keys;
        if ([propertyType hasPrefix:@"T@\"NSString\""]) {
            keys = kSQLiteTEXT;
        } else if ([propertyType hasPrefix:@"T@\"NSData\""]) {
            keys = kSQLiteBLOB;
        } else if ([propertyType hasPrefix:@"Ti"]||
                   [propertyType hasPrefix:@"TI"]||
                   [propertyType hasPrefix:@"TQ"]||
                   [propertyType hasPrefix:@"Tq"]||
                   [propertyType hasPrefix:@"TS"]||
                   [propertyType hasPrefix:@"Ts"]||
                   [propertyType hasPrefix:@"TB"]||
                   [propertyType hasPrefix:@"Tc"]||
                   [propertyType hasPrefix:@"TC"]) {
            keys = kSQLiteINTEGER;
        } else if ([propertyType hasPrefix:@"Tf"]||[propertyType hasPrefix:@"Td"]){
            keys = kSQLiteREAL;
        } else if ([propertyType hasPrefix:@"T@\"NSDate\""]) {
            NSLog(@"未处理 NSDate类型");
            continue;
        } else if ([propertyType hasPrefix:@"T@\"NSNumber\""]) {
            continue;
        }
        else {
            NSLog(@"未捕获属性类型===%@",propertyType);
            continue;
        }

        if (keys&&propertyName) {
            [propertiesAndName addObject:@[propertyName,keys]];
        }
    }
    free(properties);
    
    return propertiesAndName;
}



- (NSArray *)propertiesAndName {
    if (!_propertiesAndName) {
        _propertiesAndName = [[self class] getAllProperies];
    }
    return _propertiesAndName;
}

- (BOOL)save {
    NSString *tableName = [[self class] getTableName];
    NSMutableString *keys = [NSMutableString string];
    NSMutableString *values = [NSMutableString string];
    NSMutableArray *insertValues = [NSMutableArray  array];
    WYDatabaseManager *manager = [WYDatabaseManager manager];
    __block BOOL result = NO;
    for (int i = 0; i<self.propertiesAndName.count; i++) {
        NSString *paraName = self.propertiesAndName[i][0];
        if ([paraName isEqualToString:kSQLitePrimaryKey]) {
            continue;
        }
        [keys appendFormat:@"%@,",paraName];
        [values appendString:@"?,"];
        id value = [self valueForKey:paraName];
        value = value?:@"";
        [insertValues addObject:value];
    }
    [keys deleteCharactersInRange:NSMakeRange(keys.length - 1, 1)];
    [values deleteCharactersInRange:NSMakeRange(values.length - 1, 1)];
    
    [manager.dbQueue inDatabase:^(FMDatabase *db) {
        NSString *sql = [NSString stringWithFormat:@"INSERT INTO %@(%@) VALUES (%@);",tableName,keys,values];
        result = [db executeUpdate:sql withArgumentsInArray:insertValues];
        _ID = result?[NSNumber numberWithLongLong:db.lastInsertRowId].intValue:0;
        if (WYDatabaseVerbose) NSLog(result?@"插入成功":@"插入失败");
    }];
    return result;
}

+ (BOOL)saveModels:(NSArray *)models {

    for (int i = 0; i<models.count; i++) {
        WYDatabaseModel * model = [[[models[i] class] alloc] init];
        if (!model.propertiesAndName) {
            return NO;
        }
    }
    __block BOOL result = NO;
    WYDatabaseManager *manager = [WYDatabaseManager manager];
    [manager.dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        
        for (WYDatabaseModel *model in models) {
            if (![model isKindOfClass:[WYDatabaseModel class]]) {
                return ;
            }
            NSString *tableName = [[self class] getTableName];
            NSMutableString *keys = [NSMutableString string];
            NSMutableString *values = [NSMutableString string];
            NSMutableArray *insertValues = [NSMutableArray array];
            
            for (int i = 0; i<model.propertiesAndName.count; i++) {
                NSString *property = model.propertiesAndName[i][0];
                if ([property isEqualToString:kSQLitePrimaryKey]) {
                    continue;
                }
                [keys appendFormat:@"%@,",property];
                [values appendString:@"?,"];
                id value = [model valueForKey:property];
                value=value?:@"";
                [insertValues addObject:value];
            }
            [keys deleteCharactersInRange:NSMakeRange(keys.length - 1, 1)];
            [values deleteCharactersInRange:NSMakeRange(values.length - 1, 1)];
            
            NSString *sql = [NSString stringWithFormat:@"INSERT INTO %@ (%@) VALUES (%@)",
                             tableName,keys,values];
            BOOL flag = [db executeUpdate:sql withArgumentsInArray:insertValues];
            model.ID = result?[[NSNumber numberWithLongLong:db.lastInsertRowId] integerValue]:0;
            if (!flag) {
                result = NO;
                *rollback = YES;
                return;
            } else {
                result = YES;
            }
            
        }
        
    }];
    if (WYDatabaseVerbose) NSLog(result?@"插入成功":@"插入失败");
    return result;
}



- (BOOL)updateOnly {
    
    WYDatabaseManager *manager = [WYDatabaseManager manager];
    __block BOOL result = NO;
    NSMutableString *keys = [NSMutableString string];
    NSMutableArray *updataValues = [NSMutableArray  array];
    [manager.dbQueue inDatabase:^(FMDatabase *db) {
        NSString *tableName = [[self class] getTableName];
        id ID = [self valueForKey:kSQLitePrimaryKey];
        if (!ID || ID <= 0) {
            return ;
        }
        for (int i = 0; i<self.propertiesAndName.count; i++) {
            NSString *paraName = self.propertiesAndName[i][0];
            if ([paraName isEqualToString:kSQLitePrimaryKey]) {
                continue;
            }
            [keys appendFormat:@" %@=?,",paraName];
            id value = [self valueForKey:paraName];
            value = value?:@"";
            [updataValues addObject:value];
        }
        [keys deleteCharactersInRange:NSMakeRange(keys.length - 1, 1)];
        
        [updataValues addObject:ID];
        NSString *sql = [NSString stringWithFormat:@"UPDATE %@ SET%@ WHERE %@ = ?;",tableName,keys,kSQLitePrimaryKey];
        
        result = [db executeUpdate:sql withArgumentsInArray:updataValues];
        if (WYDatabaseVerbose) NSLog(result?@"更新成功":@"更新失败");
    }];
    return result;
}

+ (BOOL)updateModelsByID:(NSArray *)models {
    for (int i = 0; i<models.count; i++) {
        WYDatabaseModel * model = [[[models[i] class] alloc] init];
        if (!model.propertiesAndName) {
            return NO;
        }
    }
    __block BOOL result = NO;
    WYDatabaseManager *manager = [WYDatabaseManager manager];
    [manager.dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        for (WYDatabaseModel *model in models) {
            if (![model isKindOfClass:[WYDatabaseModel class]]) {
                return ;
            }
            NSMutableString *keys = [NSMutableString string];
            NSMutableArray *updateValues = [NSMutableArray array];
            NSString *tableName = [[self class] getTableName];
            id ID = [model valueForKey:kSQLitePrimaryKey];
            for (int i = 0; i<model.propertiesAndName.count; i++) {
                NSString *property = model.propertiesAndName[i][0];
                if ([property isEqualToString:kSQLitePrimaryKey]) {
                    continue;
                }
                [keys appendFormat:@" %@=?,",property];
                id value = [model valueForKey:property];
                value = value?:@"";
                [updateValues addObject:value];
                
            }
            
            [keys deleteCharactersInRange:NSMakeRange(keys.length - 1, 1)];
            NSString *sql = [NSString stringWithFormat:@"UPDATE %@ SET %@ WHERE %@ = ?",tableName,keys,ID];
            [updateValues addObject:ID];
            BOOL flag = [db executeUpdate:sql withArgumentsInArray:updateValues];
            if (!flag) {
                result = NO;
                *rollback = YES;
                return;
            } else {
                result = YES;
            }
        }
    }];
    if (WYDatabaseVerbose) NSLog(result?@"插入成功":@"插入失败");
    return result;
}

- (BOOL)deleteOnly {
    WYDatabaseManager *manager = [WYDatabaseManager manager];
    __block BOOL result = NO;
    [manager.dbQueue inDatabase:^(FMDatabase *db) {
        NSString *tableName = [[self class] getTableName];
        id ID = [self valueForKey:kSQLitePrimaryKey];
        if (!ID || ID <= 0) {
            return;
        }
        NSString *sql = [NSString stringWithFormat:@"DELETE FROM %@ WHERE %@ = ?",tableName,kSQLitePrimaryKey];
        result = [db executeUpdate:sql withArgumentsInArray:@[ID]];
        if (WYDatabaseVerbose) NSLog(result?@"删除成功":@"删除失败");
    }];
    return result;
}

+ (BOOL)deleteModels:(NSArray *)models {
    for (int i = 0; i<models.count; i++) {
        WYDatabaseModel * model = [[[models[i] class] alloc] init];
        if (!model.propertiesAndName||![models isKindOfClass:[WYDatabaseModel class]]) {
            return NO;
        }
    }
    
    WYDatabaseManager *manager = [WYDatabaseManager manager];
    __block BOOL result = NO;
    
    [manager.dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        for (WYDatabaseModel *model in models) {
            NSString *tableName = [[self class] getTableName];
            id ID = [model valueForKey:kSQLitePrimaryKey];
            if (!ID || ID <= 0) {
                return ;
            }
            
            NSString *sql = [NSString stringWithFormat:@"DELETE FROM %@ WHERE %@ = ?",tableName,ID];
            BOOL flag = [db executeUpdate:sql withArgumentsInArray:@[ID]];
            if (!flag) {
                result = NO;
                *rollback = YES;
                return;
            }
        }
    }];
    if (WYDatabaseVerbose) NSLog(result?@"删除成功":@"删除失败");
    return result;
    
}


+ (NSArray <__kindof WYDatabaseModel *>*)fetchall {
    WYDatabaseModel *model = [[self alloc]init];
    if (!model.propertiesAndName) return @[];
    WYDatabaseManager *manager = [WYDatabaseManager manager];
    NSMutableArray *results = [NSMutableArray array];
    [manager.dbQueue inDatabase:^(FMDatabase *db) {
        NSString *tableName = [[self class] getTableName];
        NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@;",tableName];
        FMResultSet *resultSet = [db executeQuery:sql];
        while ([resultSet next]) {
            WYDatabaseModel *model = [[self alloc]init];
            for (int i = 0; i< model.propertiesAndName.count; i++) {
                NSString *columnName = model.propertiesAndName[i][0];
                NSString *columeType = model.propertiesAndName[i][1];
                if ([columeType isEqualToString:kSQLiteTEXT]) {
                    [model setValue:[resultSet stringForColumn:columnName] forKey:columnName];
                } else if ([columeType isEqualToString:kSQLiteBLOB]) {
                    [model setValue:[resultSet dataForColumn:columnName] forKey:columnName];
                } else if ([columeType isEqualToString:kSQLiteINTEGER]) {
                    [model setValue:[NSNumber numberWithLongLong:[resultSet longLongIntForColumn:columnName]] forKey:columnName];
                } else if ([columeType isEqualToString:kSQLiteREAL]) {
                    [model setValue:[NSNumber numberWithDouble:[resultSet doubleForColumn:columnName]] forKey:columnName];
                } else {
#ifdef WYDB_DEBUG
                    [NSException raise:@"尚未实现的数据类型" format:@"%@",columnName];
#else
                    NSLog(@"尚未实现的数据类型%@",columnName);
#endif
                    
                }
                
            }
            [results addObject:model];
            FMDBRelease(model);
        }
    }];
    return results.copy;
}




+ (NSArray *)filter:(WYDatabaseFilter *)filter {
#warning To-do
    return @[];
}


/* 查询操作 (注意SQL注入！) 通过SQL语句查询数据 以防止SQL注入的方式,传递不安全参数 */
+ (NSArray *)selectBySQLConditions:(NSString *)sqlCondition values:(NSArray *)array {
    WYDatabaseModel *model = [[self alloc]init];
    if (!model.propertiesAndName) return @[];
    WYDatabaseManager *manager = [WYDatabaseManager manager];
    NSMutableArray *results = [NSMutableArray array];
    [manager.dbQueue inDatabase:^(FMDatabase *db) {
        NSString *tableName = [[self class] getTableName];
        NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@ %@",tableName,sqlCondition];
        FMResultSet *resultSet;
        if (array.count>0) {
            resultSet = [db executeQuery:sql withArgumentsInArray:array];
        } else {
            resultSet = [db executeQuery:sql];
        }
        
        while ([resultSet next]) {
            WYDatabaseModel *model = [[self alloc]init];
            for (int i = 0; i< model.propertiesAndName.count; i++) {
                NSString *columnName = model.propertiesAndName[i][0];
                NSString *columeType = model.propertiesAndName[i][1];
                if ([columeType isEqualToString:kSQLiteTEXT]) {
                    [model setValue:[resultSet stringForColumn:columnName] forKey:columnName];
                } else if ([columeType isEqualToString:kSQLiteBLOB]) {
                    [model setValue:[resultSet dataForColumn:columnName] forKey:columnName];
                } else if ([columeType isEqualToString:kSQLiteINTEGER]) {
                    [model setValue:[NSNumber numberWithLongLong:[resultSet longLongIntForColumn:columnName]] forKey:columnName];
                } else if ([columeType isEqualToString:kSQLiteREAL]) {
                    [model setValue:[NSNumber numberWithDouble:[resultSet doubleForColumn:columnName]] forKey:columnName];
                } else {
#ifdef WYDB_DEBUG
                    [NSException raise:@"尚未实现的数据类型" format:@"%@",columnName];
#else
                    NSLog(@"尚未实现的数据类型%@",columnName);
#endif
                    
                }
                
            }
            [results addObject:model];
            FMDBRelease(model);
        }
    }];
    return results.copy;
}

/* 删除操作 (注意条件遗漏误删除 注意SQL注入) 通过SQL语句删除数据 以防止SQL注入的方式,传递不安全参数 */
+ (BOOL)deleteBySQLConditions:(NSString *)sqlCondition values:(NSArray *)array {
    WYDatabaseModel *model = [[self alloc]init];
    if (!model.propertiesAndName) return @[];
    WYDatabaseManager *manager = [WYDatabaseManager manager];
    __block BOOL result = NO;
    
    
    [manager.dbQueue inDatabase:^(FMDatabase *db) {
        NSString *tableName = [[self class] getTableName];
        NSString *sql = [NSString stringWithFormat:@"DELETE FROM %@ %@",tableName,sqlCondition];
        if (array.count>0) {
           result = [db executeUpdate:sql withArgumentsInArray:array];
        } else {
           result = [db executeUpdate:sql];
        }
        
    }];
    
    if (WYDatabaseVerbose) NSLog(result?@"删除成功":@"删除失败");
    return result;
}


@end
