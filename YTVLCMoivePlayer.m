//
//  YTVLCMoivePlayer.m
//  YTVLCMoivePlayer
//
//  Created by yetaiwen on 2017/2/15.
//  Copyright © 2017年 yetaiwen. All rights reserved.
//

#import "YTVLCMoivePlayer.h"
#import <MobileVLCKit/MobileVLCKit.h>
#import "Header.h"
#import <MediaPlayer/MediaPlayer.h>

NSString* GetFormatStringWithDuration(long duration){
    UInt8 hour,min,sec;
    sec = duration / 1000 % 60 ;
    min = duration / 1000 / 60 % 60 ;
    hour = duration / 1000 / 60 / 60;
    
    return [NSString stringWithFormat:@"%.2d:%.2d:%.2d",hour,min,sec];
}

@interface YTVLCMoivePlayer ()<VLCMediaPlayerDelegate,UIActionSheetDelegate>
{
    VLCMediaPlayer* _player;
    BOOL _showControlView;
    UIView* _videoView;
    BOOL _showUpdateUI;
    MPVolumeView* _volumeView;
}

@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;
@property (weak, nonatomic) IBOutlet UIButton *preButton;
@property (weak, nonatomic) IBOutlet UIButton *doneButton;
@property (weak, nonatomic) IBOutlet UIView *topView;

@property (weak, nonatomic) IBOutlet UIView *buttomView;
@property (weak, nonatomic) IBOutlet UILabel *currentTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalTimeLabel;
@property (weak, nonatomic) IBOutlet UISlider *timeSlider;
@property (weak, nonatomic) IBOutlet UIButton *audioTrackButton;

@end

@implementation YTVLCMoivePlayer

#pragma mark - My method
- (void)showControlView:(BOOL)show{
    [[UIApplication sharedApplication]setStatusBarHidden:!show];
    
    [_topView setHidden:!show];
    [_buttomView setHidden:!show];
}

- (void)initUI{
    _showUpdateUI = YES;
    _showControlView = YES;
    
    [self showControlView:_showControlView];
    
    [_playButton setShowsTouchWhenHighlighted:YES];
    [_preButton setShowsTouchWhenHighlighted:YES];
    [_nextButton setShowsTouchWhenHighlighted:YES];
    
    [self.view bringSubviewToFront:_topView];
    [self.view bringSubviewToFront:_buttomView];
    
    [_doneButton setTitle:NKLocalizedString(@"Done") forState:UIControlStateNormal];
    
    // Single tap
    UITapGestureRecognizer* singleTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapAction:)];
    singleTap.numberOfTapsRequired = 1;
    [_videoView addGestureRecognizer:singleTap];
    
    // Double tap
    UITapGestureRecognizer* doubleTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapAction:)];
    doubleTap.numberOfTapsRequired = 2;
    [_videoView addGestureRecognizer:doubleTap];
    
    [singleTap requireGestureRecognizerToFail:doubleTap];
    
    // Left swipe
    UISwipeGestureRecognizer* leftSwipe = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipeAction:)];
    leftSwipe.direction = UISwipeGestureRecognizerDirectionLeft;
    [_videoView addGestureRecognizer:leftSwipe];
    
    // Right swipe
    UISwipeGestureRecognizer* rightSwipe = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipeAction:)];
    rightSwipe.direction = UISwipeGestureRecognizerDirectionRight;
    [_videoView addGestureRecognizer:rightSwipe];
    
    // Volume view
    CGRect frame;
    frame.size.width = self.view.frame.size.width - 40;
    frame.size.height = 20;
    frame.origin.x = 20;
    frame.origin.y = 50;
    _volumeView = [[MPVolumeView alloc]initWithFrame:frame];
    _volumeView.showsVolumeSlider = YES;
    [self.buttomView addSubview:_volumeView];
    [self.buttomView bringSubviewToFront:_volumeView];
}

- (void)updateUI{
    if (!_showUpdateUI) {
        return;
    }
    
    int currentTime = _player.time.intValue;
    int totalTime  = currentTime - _player.remainingTime.intValue;
    
//    NSLog(@"totalTime:%d,currentTime:%d",totalTime,currentTime);
    
    [_currentTimeLabel setText:GetFormatStringWithDuration(currentTime)];
    [_totalTimeLabel setText:GetFormatStringWithDuration(totalTime)];
    
    _timeSlider.value = (float)currentTime / totalTime;
}

#pragma mark - ButtonAction
- (IBAction)doneAction:(UIButton *)sender {
    [_player stop];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)playAction:(id)sender {
//    NSLog(@"state:%ld",(long)_player.state);
    
    if (_player.state == VLCMediaPlayerStateBuffering || _player.state == VLCMediaPlayerStatePlaying) {
        [_player pause];
        
        [_playButton setImage:[UIImage imageNamed:@"Controls_Play"] forState:UIControlStateNormal];
    }
    else{
        if(_player.state == VLCMediaPlayerStateStopped){
            _player.media = [VLCMedia mediaWithURL:_url];
        }
        
        [_player play];
        
        [_playButton setImage:[UIImage imageNamed:@"Controls_Pause"] forState:UIControlStateNormal];
    }
}

#define STEPFORTIME 15

- (IBAction)nextAction:(id)sender {
    [_player jumpForward:STEPFORTIME];
}

- (IBAction)preAction:(id)sender {
    [_player jumpBackward:STEPFORTIME];
}

- (void)tapAction:(UITapGestureRecognizer*)tap{
    if (tap.numberOfTapsRequired == 1) {
        _showControlView = !_showControlView;
        
        [self showControlView:_showControlView];
    }
    else if (tap.numberOfTapsRequired == 2){
        
        if (_player.scaleFactor == 0) {
            _player.scaleFactor = 1;
        }
        else{
            _player.scaleFactor = 0;
        }
    }
}

static bool timeSliderStart = NO;

- (IBAction)timeSliderAction:(UISlider *)sender {
//    NSLog(@"tracking:%d",sender.tracking);
    
    if (!sender.tracking && !timeSliderStart) {
        timeSliderStart = YES;
        
        return;
    }
    
    if (sender.tracking) {
        _showUpdateUI = NO;
        
        int currentTime = _player.time.intValue;
        int time = sender.value * (currentTime - _player.remainingTime.intValue);
        [_currentTimeLabel setText:GetFormatStringWithDuration(time)];
    }
    else{
        _showUpdateUI = YES;
        
        int currentTime = _player.time.intValue;
        int time = sender.value * (currentTime - _player.remainingTime.intValue);
//        NSLog(@"time:%d,currentTime:%d",time,currentTime);
        if (time - currentTime > 0) {
            [_player jumpForward:(time - currentTime) / 1000];
            
        }
        else{
            [_player jumpBackward:(currentTime - time) / 1000];
        }
        
        timeSliderStart = NO;
    }
}

- (void)swipeAction:(UISwipeGestureRecognizer*)swipe{
//    NSLog(@"swipe action");
    switch (swipe.direction) {
        case UISwipeGestureRecognizerDirectionLeft:
        {
            [self preAction:_preButton];
            break;
        }
            
        case UISwipeGestureRecognizerDirectionRight:
        {
            [self nextAction:_nextButton];
            break;
        }
            
        default:
            break;
    }
}

- (IBAction)audioTrackButtonAction:(UIButton *)sender {
    NSArray* audioTrackNames = _player.audioTrackNames;
    
    UIActionSheet* actionSheet = [[UIActionSheet alloc]initWithTitle:@"Audio track" delegate:self cancelButtonTitle:NKLocalizedString(@"Cancel") destructiveButtonTitle:nil otherButtonTitles:nil];
    
    for (NSString* trackName in audioTrackNames) {
        [actionSheet addButtonWithTitle:[NSString stringWithFormat:@"%@",trackName]];
    }
    
    [actionSheet showInView:self.view];
}

#pragma mark - View method

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    VLCMedia* media = [VLCMedia mediaWithURL:_url];
    
    _player = [[VLCMediaPlayer alloc]init];
    [_player setDelegate:self];
    
    _videoView = [[UIView alloc]init];
    [_videoView setFrame:self.view.frame];
    [_videoView setBackgroundColor:[UIColor blackColor]];
    [self.view addSubview:_videoView];
    
    _player.drawable = _videoView;
    
    _player.media = media;
    
    [_player play];
    
    
    
    [self initUI];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
//    ShowErrorMessage(_url.description);
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [[UIApplication sharedApplication]setStatusBarHidden:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator{
    CGRect frame = CGRectZero;
    frame.size = size;
    
    [_videoView setFrame:frame];
    
    frame = _volumeView.frame;
    frame.size.width = size.width - 40;
    
    [_volumeView setFrame:frame];
}

#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 0) {
        return;
    }
    
    NSNumber* track = [_player.audioTrackIndexes objectAtIndex:buttonIndex - 1];
    [_player setCurrentAudioTrackIndex:track.intValue];
}

#pragma mark - VLCMediaPlayerDelegate

- (void)mediaPlayerStateChanged:(NSNotification *)aNotification{
//    NSLog(@"mediaPlayerStateChanged:%ld",(long)_player.state);
    
    if (_player.state == VLCMediaPlayerStateStopped) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)mediaPlayerTimeChanged:(NSNotification *)aNotification{
//    NSLog(@"mediaPlayerTimeChanged:%@",aNotification.userInfo.description);
    [self updateUI];
}

@end
