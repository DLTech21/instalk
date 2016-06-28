//
//  VideoPlayViewController.m
//  happychat
//
//  Created by Donal Tong on 16/1/15.
//  Copyright © 2016年 dl. All rights reserved.
//

#import "VideoPlayViewController.h"
#import <MediaPlayer/MediaPlayer.h>
#import "UIView+SDAutoLayout.h"
#import <AVFoundation/AVFoundation.h>
#import <CoreMedia/CoreMedia.h>
#import "SVProgressHUD.h"
#import <AFNetworking/AFNetworking.h>

@interface VideoPlayViewController ()
@property (strong, nonatomic) UIButton *backButton;
@property (strong, nonatomic) AVPlayer *player;
@property (strong, nonatomic) AVPlayerLayer *playerLayer;
@property (strong, nonatomic) UIButton *playButton;
@property (strong, nonatomic) AVPlayerItem *playerItem;
@end


@implementation VideoPlayViewController

-(void)viewDidLoad{
    self.view.backgroundColor = [UIColor blackColor];
    UIButton *closeButton = [UIButton new];
    [self.view addSubview:closeButton];
    [closeButton setTitle:@"关闭" forState:UIControlStateNormal];
    [closeButton setTitleEdgeInsets:UIEdgeInsetsMake(0, -40, 0, 0)];
    [closeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    closeButton.sd_layout
    .widthIs(88)
    .heightIs(44)
    .leftSpaceToView(self.view, 0)
    .topSpaceToView(self.view, 20);
    [closeButton addTarget:self action:@selector(didClose:) forControlEvents:UIControlEventTouchUpInside];
    if (_needDownload) {
        [self checkFile];
    }
    else {
        [self initPlayLayer:[NSURL fileURLWithPath:_videoPath]];
    }
}

-(void)checkFile
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *doc = [paths objectAtIndex:0];
    NSString *filePath = [doc stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.MP4",[Tool md5:self.videoUrl]]];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:filePath]) {
        NSURL *documentsDirectoryURL = [fileManager URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];
        [self initPlayLayer:[documentsDirectoryURL URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.MP4", [Tool md5:self.videoUrl]]]];
    }
    else {
        [self downloadVideo];
    }
}

-(void)downloadVideo
{
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    
    NSURL *URL = [NSURL URLWithString:self.videoUrl];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    NSProgress *progress;
    NSURLSessionDownloadTask *downloadTask =
    [manager downloadTaskWithRequest:request
                            progress:nil
                         destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
                            NSURL *documentsDirectoryURL = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];
                            return [documentsDirectoryURL URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.MP4", [Tool md5:self.videoUrl]]];
                         }
                   completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
                       [self initPlayLayer:filePath];
                   }];
    [progress addObserver:self
               forKeyPath:@"fractionCompleted"
                  options:NSKeyValueObservingOptionNew
                  context:NULL];
    [downloadTask resume];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"fractionCompleted"]) {
        NSProgress *progress = (NSProgress *)object;
        if (progress.fractionCompleted == 1) {
            [SVProgressHUD dismiss];
        }
        else{
            [SVProgressHUD showProgress:progress.fractionCompleted];
        }
//        NSLog(@"Progress… %f", progress.fractionCompleted);
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (void)pressPlayButton:(UIButton *)button
{
    [_playerItem seekToTime:kCMTimeZero];
    [_player play];
    _playButton.alpha = 0.0f;
}

-(void)didClose:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(avPlayerItemDidPlayToEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
}

- (void)avPlayerItemDidPlayToEnd:(NSNotification *)notification
{
    if ((AVPlayerItem *)notification.object != _playerItem) {
        return;
    }
    [UIView animateWithDuration:0.3f animations:^{
        _playButton.alpha = 1.0f;
    }];
}

- (void)initPlayLayer:(NSURL *)_videoFileURL
{
    if (!_videoFileURL) {
        return;
    }
    
    AVAsset *movieAsset = [AVURLAsset URLAssetWithURL:_videoFileURL options:nil];
    self.playerItem = [AVPlayerItem playerItemWithAsset:movieAsset];
    self.player = [AVPlayer playerWithPlayerItem:_playerItem];
    self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:_player];
    _playerLayer.frame = CGRectMake(0, 64, SCREEN_WIDTH, SCREEN_WIDTH);
    _playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
    [self.view.layer addSublayer:_playerLayer];
    [self initPlayButton];
}

-(void)initPlayButton
{
    self.playButton = [[UIButton alloc] initWithFrame:_playerLayer.frame];
    [_playButton setImage:[UIImage imageNamed:@"icon_vidoe_play"] forState:UIControlStateNormal];
    [_playButton addTarget:self action:@selector(pressPlayButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_playButton];
}

@end
