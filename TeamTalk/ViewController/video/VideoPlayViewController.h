//
//  VideoPlayViewController.h
//  happychat
//
//  Created by Donal Tong on 16/1/15.
//  Copyright © 2016年 dl. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VideoPlayViewController : UIViewController
@property (nonatomic, strong) NSString *videoUrl;
@property (nonatomic) BOOL needDownload;

@property (nonatomic, strong) NSString *videoPath;
@end
