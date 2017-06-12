//
//  WYDatabaseManager.h
//  WYDatabase
//
//  Created by 李育洋 on 2017/6/7.
//  Copyright © 2017年 walktewy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import "FMDB.h"
@class WYDatabaseModel;
@interface WYDatabaseManager : NSObject

@property (nonatomic, copy,readonly) NSString * userID;
@property (nonatomic, strong) FMDatabaseQueue *dbQueue;
@property (nonatomic, strong) NSMutableDictionary *tableNameHash;
+ (instancetype)manager;

- (void)configWithUserID:(NSString *)userID;
@end
