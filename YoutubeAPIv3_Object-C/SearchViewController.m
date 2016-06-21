//
//  SearchViewController.m
//  YoutubeAPIv3_Object-C
//
//  Created by 涂安廷 on 2016/6/21.
//  Copyright © 2016年 涂安廷. All rights reserved.
//

#import "SearchViewController.h"
#import "SearchSettings.h"
#import "VideoCategories.h"

@interface SearchViewController ()

@end

@implementation SearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)showSearchSettings:(UIBarButtonItem *)sender {
    
    SearchSettings *searchSettings = [[SearchSettings alloc] initWithNibName:@"SearchSettings" bundle:nil];
    [self presentViewController:searchSettings animated:true completion:nil];
    
}

- (IBAction)showVideoCategories:(UIBarButtonItem *)sender {
    
    VideoCategories *videoCategories = [[VideoCategories alloc] initWithNibName:@"VideoCategories" bundle:nil];
    [self presentViewController:videoCategories animated:true completion:nil];
    
}
@end
