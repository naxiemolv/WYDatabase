//
//  WYDatabaseFilter.h
//  WYDatabase
//
//  Created by 李育洋 on 2017/6/9.
//  Copyright © 2017年 walktewy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WYDatabaseFilter : NSObject
/** 筛选出今天的数据*/
- (WYDatabaseFilter *)isToday;

/** 反转查询结果集*/
- (WYDatabaseFilter * )reverse;

/** 筛选出XXX字段 并从大到小排序*/
- (WYDatabaseFilter * (^)(NSString * ))orderByColumnBigToSmall;

/** 筛选出XXX字段 并从小到大排序*/
- (WYDatabaseFilter * (^)(NSString * ))orderByColumnSmallBigTo;



/** 限制结果集个数*/
- (WYDatabaseFilter * (^)(NSInteger))limit;

- (WYDatabaseFilter * (^)(NSInteger))page;

/** 与条件*/
- (WYDatabaseFilter* (^)(NSString*))orCondition;
/** 或条件*/
- (WYDatabaseFilter* (^)(NSString*))andCondition;
@end
typedef NS_ENUM(NSUInteger, WYFilterCondition) {
    AND,
    OR,
    NOR,
};
@interface WYDatabaseFilterCondition : NSObject
@property (nonatomic,assign) WYFilterCondition conditionType;
@property (nonatomic,copy) NSString * conditionString;
@end
