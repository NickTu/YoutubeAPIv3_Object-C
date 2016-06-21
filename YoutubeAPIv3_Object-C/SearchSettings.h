//
//  SearchSettings.h
//  YoutubeAPIv3_Object-C
//
//  Created by 涂安廷 on 2016/6/22.
//  Copyright © 2016年 涂安廷. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SearchSettings : UIViewController<UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
- (IBAction)finishSearchSettings:(UIBarButtonItem *)sender;

@end
