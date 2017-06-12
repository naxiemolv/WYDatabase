//
//  LLClass.h
//  WYDatabase
//
//  Created by 李育洋 on 2017/6/9.
//  Copyright © 2017年 walktewy. All rights reserved.
//

#import "WYDatabaseModel.h"

@interface LLClass : WYDatabaseModel
@property (nonatomic,assign) NSInteger studentID;
@property (nonatomic,assign) NSInteger grade;
@property (nonatomic,assign) NSInteger Class;
@property (nonatomic,copy) NSString *name;
@property (nonatomic,copy) NSString *school;



@property (nonatomic,assign) float _height;
@end
