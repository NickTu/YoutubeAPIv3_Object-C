//
//  PlayViewController.m
//  YoutubeAPIv3_Object-C
//
//  Created by 涂安廷 on 2016/6/21.
//  Copyright © 2016年 涂安廷. All rights reserved.
//

#import "PlayViewController.h"

@interface PlayViewController ()

@end

@implementation PlayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.playerView loadWithVideoId:self.videoID];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)backViewController:(UIBarButtonItem *)sender {
    
    [self dismissViewControllerAnimated:true completion:nil];
    
}
@end
