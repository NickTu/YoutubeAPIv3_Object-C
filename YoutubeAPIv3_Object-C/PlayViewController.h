//
//  PlayViewController.h
//  YoutubeAPIv3_Object-C
//
//  Created by 涂安廷 on 2016/6/21.
//  Copyright © 2016年 涂安廷. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YTPlayerView.h"

@interface PlayViewController : UIViewController

@property (weak, nonatomic) NSString *videoID;
@property (weak, nonatomic) IBOutlet YTPlayerView *playerView;
- (IBAction)backViewController:(UIBarButtonItem *)sender;

@end
