//
//  WYDatabaseFilter.m
//  WYDatabase
//
//  Created by 李育洋 on 2017/6/9.
//  Copyright © 2017年 walktewy. All rights reserved.
//

#import "WYDatabaseFilter.h"

@interface WYDatabaseFilter()
@property (nonatomic, assign) BOOL isLimit;
@property (nonatomic, assign) BOOL isReverseResult;
@property (nonatomic, assign) BOOL isHasWhere;
@property (nonatomic, assign) NSInteger limitNumber;
@property (nonatomic, assign) NSInteger pageNumber;
@property (nonatomic, copy) NSString *orderByColumnName;
@property (nonatomic, assign) BOOL isSmallToBig;

@property (nonatomic, strong) NSMutableArray *conditions;
@end


@implementation WYDatabaseFilter

- (NSMutableArray *)conditions {
    if (!_conditions) {
        _conditions = [NSMutableArray array];
    }
    return _conditions;
}

- (WYDatabaseFilter *)isToday {
    return self;
}

- (WYDatabaseFilter * (^)(NSString*))orderByColumnBigToSmall {
    return ^id(NSString *column) {
        self.isSmallToBig = NO;
        self.orderByColumnName = column;
        return self;
    };
}

- (WYDatabaseFilter * (^)(NSString*))orderByColumnSmallBigTo {
    return ^id(NSString *column) {
        self.isSmallToBig = YES;
        self.orderByColumnName = column;
        return self;
    };
}

- (WYDatabaseFilter *)reverse {
    self.isReverseResult = !self.isReverseResult;
    return self;
}

- (WYDatabaseFilter * (^)(NSInteger))limit {
    return ^id(NSInteger limit){
        self.limitNumber = limit;
        return self;
    };
}

- (WYDatabaseFilter * (^)(NSInteger))page {
    return ^id(NSInteger page){
        self.pageNumber = page;
        return self;
    };
}

- (WYDatabaseFilter* (^)(NSString*))andCondition {
    return ^id(NSString *condition) {
        WYDatabaseFilterCondition *fc = [[WYDatabaseFilterCondition alloc]init];
        fc.conditionType = AND;
        fc.conditionString = condition;
        [self.conditions addObject:fc];
        self.isHasWhere = YES;
        return self;
    };
}

- (WYDatabaseFilter* (^)(NSString*))orCondition {
    return ^id(NSString *condition) {
        WYDatabaseFilterCondition *fc = [[WYDatabaseFilterCondition alloc]init];
        fc.conditionType = OR;
        fc.conditionString = condition;
        [self.conditions addObject:fc];
        self.isHasWhere = YES;
        return self;
    };
}
#warning developing
- (NSString *)generateSQL {
    NSMutableString * sql = [NSMutableString string];
    if (self.isHasWhere) {
        [sql appendString:@"WHERE "];
    }
    for (int i = 0; i<self.conditions.count; i++) {
        WYDatabaseFilterCondition *cdt = self.conditions[i];
        [sql appendFormat:@"(%@)",cdt.conditionString];
        if (cdt.conditionType == AND && i!=(self.conditions.count-1)) {
            
        }
    }
    return nil;
}


@end



@interface WYDatabaseFilterCondition()

@end

@implementation WYDatabaseFilterCondition


@end
