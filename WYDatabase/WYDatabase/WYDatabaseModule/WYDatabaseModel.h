//
//  WYDatabaseModel.h
//  WYDatabase
//
//  Created by 李育洋 on 2017/6/8.
//  Copyright © 2017年 walktewy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WYDatabaseFilter.h"

@interface WYDatabaseModel : NSObject
@property (nonatomic,assign) NSInteger ID;
+ (BOOL)migrateTable;

//INSERT
/** 插入单条数据模型*/
- (BOOL)save;
/** 插入多条数据模型 */
+ (BOOL)saveModels:(NSArray *)models;

//DELETE
/** 仅删除单条模型*/
- (BOOL)deleteOnly;
/** 仅删多单条模型*/
+ (BOOL)deleteModels:(NSArray *)models;

//UPDATE
/** 仅更新单条模型 如果不存在不插入*/
- (BOOL)updateOnly;
/** 更新多条模型 如果不存在不插入*/
+ (BOOL)updateModelsByID:(NSArray *)models;

//SELECT
/** 查询导出所有数据模型*/
+ (NSArray <__kindof WYDatabaseModel *>*)fetchall;


//条件为SQL 语句字符串

/** 删除操作 (注意条件遗漏误删除 注意SQL注入) 通过SQL语句删除数据 以防止SQL注入的方式,传递不安全参数 
如 "WHERE ID > 30" array传nil
或 "WHERE ID > ?"  array传@[@"30"]
*/
+ (BOOL)deleteBySQLConditions:(NSString *)sqlCondition values:(NSArray *)array;

/** 查询 (注意SQL注入) 通过SQL语句删除数据 以防止SQL注入的方式,传递不安全参数
 如 "WHERE ID > 30" array传nil
 或 "WHERE ID > ?"  array传@[@"30"]
 */
+ (NSArray *)selectBySQLConditions:(NSString *)sqlCondition values:(NSArray *)array;




//Filter
/** 通过过滤器查询 未做完*/
+ (NSArray *)filter:(WYDatabaseFilter *)filter;
@end
