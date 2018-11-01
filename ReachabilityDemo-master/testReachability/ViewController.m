//
//  ViewController.m
//  testReachability
//
//  Created by GrandSu on 2018/8/7.
//  Copyright © 2018年 GrandSu. All rights reserved.
//

#import "ViewController.h"
#import <sys/utsname.h>
#include <sys/types.h>
#include <sys/sysctl.h>
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(offline:) name:@"offline" object:nil];
}

-(void)offline:(NSNotification*)not{
    NSLog(@"hahah%@",not.userInfo[@"offline"]);

}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}





- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
