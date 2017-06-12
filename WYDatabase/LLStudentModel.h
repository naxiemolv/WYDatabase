//
//  LLStudentModel.h
//  WYDatabase
//
//  Created by 李育洋 on 2017/6/8.
//  Copyright © 2017年 walktewy. All rights reserved.
//

#import "WYDatabaseModel.h"

@interface LLStudentModel : WYDatabaseModel

//添加的模型 以单下划线开头的默认不添加数据库  不区分大小写
@property (nonatomic,assign) NSInteger studentID;
@property (nonatomic,assign) NSInteger grade;
@property (nonatomic,assign) NSInteger Class;
@property (nonatomic,copy) NSString *name;
@property (nonatomic,copy) NSString *school;


@property (nonatomic,assign) float _height;

@end
