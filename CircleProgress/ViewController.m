//
//  ViewController.m
//  CircleProgress
//
//  Created by XJY on 16/1/28.
//  Copyright © 2016年 XJY. All rights reserved.
//

#import "ViewController.h"
#import "XCircleProgress.h"

@interface ViewController () {
    XCircleProgress *circleProgress;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view setBackgroundColor:[UIColor redColor]];

    circleProgress = [[XCircleProgress alloc] init];
    [self.view addSubview:circleProgress];
    
    [circleProgress setIndicatorColor:[UIColor whiteColor]];                //进度条颜色
    [circleProgress setIndicatorBackgroundColor:[UIColor whiteColor]];      //进度条背景线条颜色
    [circleProgress setIndicatorAlpha:1];                                   //进度条透明度
    [circleProgress setIndicatorBackgroundAlpha:0.5];                       //进度条背景线条透明度
    [circleProgress setIndicatorWidth:5];                                   //进度条宽度
    [circleProgress setIndicatorBackgroundWidth:2];                         //进度条背景线条宽度
    
    [circleProgress setIndicatorGradient:YES];                              //进度条是否有渐变效果
    [circleProgress setIndicatorRadius:40];                                 //进度条半径
    [circleProgress setStartAngle:-M_PI_2];                                 //设置起始点角度
    [circleProgress setAutoAdjustSize:YES];                                 //自动调整大小
    
    [circleProgress setTextColor:[UIColor whiteColor]];                     //文字颜色
    [circleProgress setTextFont:[UIFont boldSystemFontOfSize:17]];          //文字字体
    [circleProgress.pointImageView setImage:[UIImage imageNamed:@"mine_task_icon_luminouspoint"]];  //进度条末端图片
    [circleProgress setPointImageSize:CGSizeZero];                          //进度条末端图片大小
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSInteger i = 0;
        while (i <= 10) {
            [circleProgress setProgress:i/10.0];                                            //进度
            [circleProgress setText:[NSString stringWithFormat:@"%d%@", (int)(i*10), @"%"]];//文字
            sleep(1);
            
            i += 1;
        }
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    [self updateFrame];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    [self updateFrame];
}

- (void)updateFrame {
    //设置该控件的frame
//    CGFloat width = (circleProgress.indicatorRadius + circleProgress.indicatorWidth / 2.0) * 2;
//    CGFloat height = width;
    [circleProgress setFrame:CGRectMake(0, 0, 30, 30)];
    [circleProgress setCenter:self.view.center];
}

@end
