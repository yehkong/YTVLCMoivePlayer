//
//  ViewController.m
//  YTMoivePlayerDemo
//
//  Created by Geson on 2018/3/19.
//  Copyright © 2018年 yetaiwen. All rights reserved.
//

#import "ViewController.h"
#import "YTVLCMoivePlayer.h"

@interface ViewController ()

@end

@implementation ViewController

- (IBAction)playAction:(UIButton *)sender {
    NSURL *url = [NSURL URLWithString:@"http://v4ttyey-10001453.video.myqcloud.com/Microblog/288-4-1452304375video1466172731.mp4"];
    NSURL *bundleUrl = [[NSBundle mainBundle]URLForResource:@"YTVLCMoivePlayer" withExtension:@"bundle"];
    NSBundle *myBundle = [NSBundle bundleWithURL:bundleUrl];
    YTVLCMoivePlayer *player = [[YTVLCMoivePlayer alloc]initWithNibName:@"YTVLCMoivePlayer" bundle:myBundle];
    //    YTVLCMoivePlayer *player = [[YTVLCMoivePlayer alloc]init];
    player.url = url;
    [self presentViewController:player animated:YES completion:nil];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
