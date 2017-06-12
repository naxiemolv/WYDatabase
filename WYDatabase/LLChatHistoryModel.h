//
//  LLChatHistoryModel.h
//  WYDatabase
//
//  Created by 李育洋 on 2017/6/10.
//  Copyright © 2017年 walktewy. All rights reserved.
//

#import "WYDatabaseModel.h"

@interface LLChatHistoryModel : WYDatabaseModel
@property (nonatomic,assign) NSInteger fromID;
@property (nonatomic,assign) NSInteger toID;
@property (nonatomic,assign) NSInteger messageType;
@property (nonatomic,copy) NSString *message;
@property (nonatomic,copy) NSString *extraInfo;
@property (nonatomic,strong) NSDate *joinTime;

@property (nonatomic,assign) BOOL isReaded;
@property (nonatomic,assign) BOOL isTimeStampShown;
@property (nonatomic,assign) BOOL isSendSuccess;
@end
