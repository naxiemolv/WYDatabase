//
//  WYDatabaseManager.m
//  WYDatabase
//
//  Created by 李育洋 on 2017/6/7.
//  Copyright © 2017年 walktewy. All rights reserved.
//

#import "WYDatabaseManager.h"




static WYDatabaseManager * _instance = nil;
@interface WYDatabaseManager()
@property (nonatomic,strong) NSDictionary * propertyHach;

@end

static NSString * const pathAppend = @"WYDatabase";


@implementation WYDatabaseManager
+ (instancetype)manager {
    return [[self alloc] init];
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [super allocWithZone:zone];
    });
    return _instance;
}

- (instancetype)init {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [super init];
    });
    return _instance;
}

- (id)copyWithZone:(NSZone *)zone {
    return  _instance;
}

+ (id)copyWithZone:(struct _NSZone *)zone {
    return  _instance;
}

+ (id)mutableCopyWithZone:(struct _NSZone *)zone {
    return _instance;
}

- (id)mutableCopyWithZone:(NSZone *)zone {
    return _instance;
}

- (void)configWithUserID:(NSString *)userID {
    if (userID.length>0 == NO) _userID = @"";
    else _userID = userID;
    if (_instance.dbQueue) _instance.dbQueue = nil;

    _instance.dbQueue = [[FMDatabaseQueue alloc] initWithPath:[[[self class] databasePath] stringByAppendingPathComponent:[NSString stringWithFormat:@"db_%@.sqlite",userID]]];
    
}

+ (NSString *)databasePath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docDir = [paths objectAtIndex:0];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *filePath = [docDir stringByAppendingPathComponent:pathAppend];
    
    BOOL isDir = FALSE;
    BOOL isDirExist = [fileManager fileExistsAtPath:filePath isDirectory:&isDir];
    if(!(isDirExist && isDir)) [fileManager createDirectoryAtPath:filePath
                                      withIntermediateDirectories:YES
                                                       attributes:nil
                                                            error:nil];
    return filePath;
}

- (FMDatabaseQueue *)dbQueue {
    if (_dbQueue == nil) {
        if (_userID.length>0 == NO) _userID = @"";
        _dbQueue = [[FMDatabaseQueue alloc] initWithPath:[[[self class] databasePath] stringByAppendingPathComponent:[NSString stringWithFormat:@"db_%@.sqlite",_userID]]];
    }
    return _dbQueue;
}

- (NSMutableDictionary *)tableNameHash {
    if (!_tableNameHash) {
        _tableNameHash = [NSMutableDictionary dictionary];
    }
    return _tableNameHash;
}





@end
