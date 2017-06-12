//
//  ChatHistoryViewController.m
//  WYDatabase
//
//  Created by 李育洋 on 2017/6/10.
//  Copyright © 2017年 walktewy. All rights reserved.
//

#import "ChatHistoryViewController.h"
#import "LLChatHistoryModel.h"
@interface ChatHistoryViewController ()
@property (nonatomic,assign) NSInteger userA;
@property (nonatomic,assign) NSInteger userB;
@end

@implementation ChatHistoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)back:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)generateChatHistory:(UIButton *)sender {
    @autoreleasepool {
        NSMutableArray *inserts = [NSMutableArray array];
        for (int i = 0; i <100000; i++) {
            LLChatHistoryModel *model = [[LLChatHistoryModel alloc]init];
            if (i%2 == 0) {
                model.fromID = 100000;
                model.toID = arc4random()%40+100001;
            } else {
                model.toID = 100000;
                model.fromID = arc4random()%40+100001;
            }
            model.messageType = arc4random()%10;
            model.message = [NSString stringWithFormat:@"这是 %ld 发给 %ld 的第%d条消息",model.fromID,model.toID,i];
            model.joinTime = [NSDate date];
            [inserts addObject:model];
        }
        [LLChatHistoryModel saveModels:inserts.copy];
    }
    
}

- (IBAction)loadCurrent20Results:(UIButton *)sender {
    NSLog(@"尚未实现");
    NSLog(@"模拟打开了聊天界面 将加载用户A与用户B 最近的20条聊天记录");
    _userA = 100000;
    _userB = arc4random()%40+100001;
    
    
    WYDatabaseFilter *filter = [[WYDatabaseFilter alloc]init];
    
    filter
    .andCondition([NSString stringWithFormat:@"fromID=%ld AND toID=%ld",_userA,_userB])
    .orCondition([NSString stringWithFormat:@"fromID=%ld AND toID=%ld",_userB,_userA])
    .page(0)
    .limit(20);
    
    [LLChatHistoryModel filter:filter];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
