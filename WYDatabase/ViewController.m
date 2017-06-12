//
//  ViewController.m
//  WYDatabase
//
//  Created by 李育洋 on 2017/6/7.
//  Copyright © 2017年 walktewy. All rights reserved.
//

#import "ViewController.h"
#import "WYDatabaseManager.h"
#import "LLStudentModel.h"
#import "LLClass.h"
#import "ChatHistoryViewController.h"

@interface ViewController ()
@property (strong, nonatomic) IBOutlet UITextField *userID;
- (IBAction)initDatabase:(UIButton *)sender;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)initDatabase:(UIButton *)sender {
    NSString *userID = _userID.text;
    
    NSLog(@"%@",NSHomeDirectory());
    
    [[WYDatabaseManager manager] configWithUserID:userID];
    
}
- (IBAction)migrateTable:(UIButton *)sender {
    [LLStudentModel migrateTable];
    
}

- (IBAction)insertOne:(UIButton *)sender {
    LLStudentModel *model = [[LLStudentModel alloc]init];
    model.Class = 2;
    model.name = @"walktewy";
    
    [model save];
}

- (IBAction)insertMulty:(UIButton *)sender {
    NSMutableArray *array = [NSMutableArray array];
    NSLog(@"开始插入");
    for (int i = 0; i<100; i++) {
        LLStudentModel *student = [[LLStudentModel alloc]init];
        student.name = [NSString stringWithFormat:@"name:%d",i];
        student.Class = arc4random()%6;
        [array addObject:student];
    }
    [LLStudentModel saveModels:array.copy];
}



- (IBAction)updateOne:(UIButton *)sender {
    LLStudentModel *model = [[LLStudentModel alloc]init];
    model.ID = 3;
    model.Class = arc4random()%20;
    model.name = @"ffff";
    [model updateOnly];
}

- (IBAction)deleteOne:(UIButton *)sender {
    LLStudentModel *model = [[LLStudentModel alloc]init];
    model.ID = 2;
    [model deleteOnly];
    
}

- (IBAction)fetchall:(UIButton *)sender {

    NSLog(@"查询结果:%ld条",[[LLStudentModel fetchall]count]);

}

- (IBAction)updatemultipleRecord:(UIButton *)sender {
    
}


- (IBAction)deleteBySQL:(UIButton *)sender {
    [LLStudentModel deleteBySQLConditions:@"WHERE Class = ?" values:@[@(2)]];
}

- (IBAction)selectBySQL:(UIButton *)sender {
    NSArray * array = [LLStudentModel selectBySQLConditions:@"WHERE ID = 5" values:nil];
    NSLog(@"查询结果:%ld条",array.count);
}



- (IBAction)buttonForTest:(UIButton *)sender {
    
    
    LLClass *classModel = [[LLClass alloc]init];
    classModel.studentID = 100;
    [classModel save];
    
    
    WYDatabaseFilter *filter = [[WYDatabaseFilter alloc]init];
    filter.orderByColumnBigToSmall(@"Class").limit(10);
    NSArray *result = [LLStudentModel filter:filter];
    
}



- (IBAction)pushChatHistory:(UIButton *)sender {
    [self presentViewController:[[ChatHistoryViewController alloc]init] animated:YES completion:nil];
}

@end
