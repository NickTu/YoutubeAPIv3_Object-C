//
//  VideoCategories.m
//  YoutubeAPIv3_Object-C
//
//  Created by 涂安廷 on 2016/6/22.
//  Copyright © 2016年 涂安廷. All rights reserved.
//

#import "VideoCategories.h"
#import "AppDelegate.h"

@interface VideoCategories ()

@end

@implementation VideoCategories{
    NSArray *tableData;
    NSInteger nowType;
    AppDelegate *appDelegate;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    tableData = @[ @"All",@"Film & Animation", @"Autos & Vehicles", @"Music", @"Pets & Animals", @"Sports", @"Short Movies", @"Travel & Events", @"Gaming", @"Videoblogging", @"People & Blogs", @"Comedy", @"Entertainment", @"News & Politics", @"Howto & Style", @"Education", @"Science & Technology", @"Movies", @"Anime/Animation", @"Action/Adventure", @"Classics", @"Documentary", @"Drama", @"Family", @"Foreign", @"Horror", @"Sci-Fi/Fantasy", @"Thriller", @"Shorts", @"Shows", @"Trailers" ];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [tableData count];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSIndexPath *lastIndex = [NSIndexPath indexPathForRow:[ tableData indexOfObject:appDelegate.videoType ] inSection:[indexPath section] ];
    
    [tableView cellForRowAtIndexPath:lastIndex].accessoryType = UITableViewCellAccessoryNone;
    [tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryCheckmark;
    appDelegate.videoType = tableData[ [indexPath row] ];
    
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"idCellVideoCategories"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"idCellVideoCategories"];
    }
    /*NSInteger section = [indexPath section];
    NSInteger row = [[tableData objectForKey:tableKey[ section ] ] indexOfObject: [self sectionToString: section ] ];*/
    if ( [indexPath row] == [tableData indexOfObject:appDelegate.videoType] ) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    cell.textLabel.text = tableData[ [indexPath row] ];
    return cell;
    
}

- (IBAction)finishSearchSettings:(UIBarButtonItem *)sender {
    
    [self dismissViewControllerAnimated:true completion:nil];
    
}
@end
