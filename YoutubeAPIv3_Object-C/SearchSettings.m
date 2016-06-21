//
//  SearchSettings.m
//  YoutubeAPIv3_Object-C
//
//  Created by 涂安廷 on 2016/6/22.
//  Copyright © 2016年 涂安廷. All rights reserved.
//

#import "SearchSettings.h"
#import "AppDelegate.h"

@interface SearchSettings ()

@end

@implementation SearchSettings{
    NSArray *tableKey;
    NSDictionary *tableData;
    NSInteger nowType;
    AppDelegate *appDelegate;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    tableKey = @[@"type",@"order",@"videoDuration",@"videoDimension",@"videoDefinition",@"uploadTime"];
    tableData = @{tableKey[0]:@[ @"video", @"channel", @"playlist" ],
                  tableKey[1]:@[ @"date", @"rating", @"relevance",@"viewCount" ],
                  tableKey[2]:@[ @"any", @"long", @"medium", @"short"],
                  tableKey[3]:@[ @"2d",@ "3d", @"any"],
                  tableKey[4]:@[ @"any", @"high", @"standard"],
                  tableKey[5]:@[ @"anytime", @"today", @"this week", @"this month", @"this year"]};
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    nowType = [[ tableData objectForKey:tableKey[0] ] indexOfObject:appDelegate.type];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [[tableData objectForKey:tableKey[section]] count];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

    NSInteger section = [indexPath section];
    NSArray *array = [tableData objectForKey:tableKey[ section ] ];
    NSInteger row = [array indexOfObject: [self sectionToString:section] ];
    NSIndexPath *lastIndex = [NSIndexPath indexPathForRow:row inSection:[indexPath section] ];
    switch (section) {
        case 0:
            appDelegate.type = array[ [indexPath row] ];
            nowType = [indexPath row];
            break;
        case 1:
            appDelegate.order = array[ [indexPath row] ];
            break;
        case 2:
            appDelegate.videoDuration = array[ [indexPath row] ];
            break;
        case 3:
            appDelegate.videoDimension = array[ [indexPath row] ];
            break;
        case 4:
            appDelegate.videoDefinition = array[ [indexPath row] ];
            break;
        case 5:
            appDelegate.uploadTime = array[ [indexPath row] ];
            break;
        default:
            break;
    }

    [tableView cellForRowAtIndexPath:lastIndex].accessoryType = UITableViewCellAccessoryNone;
    [tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryCheckmark;
    [tableView reloadData];
    
}

-(NSString*) sectionToString:(NSInteger)section {
    NSString *string;
    switch (section) {
        case 0:
            string = appDelegate.type;
            break;
        case 1:
            string = appDelegate.order;
            break;
        case 2:
            string = appDelegate.videoDuration;
            break;
        case 3:
            string = appDelegate.videoDimension;
            break;
        case 4:
            string = appDelegate.videoDefinition;
            break;
        case 5:
            string = appDelegate.uploadTime;
            break;
        default:
            break;
    }
    return string;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"idCellSearchSettings"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"idCellSearchSettings"];
    }
    NSInteger section = [indexPath section];
    NSInteger row = [[tableData objectForKey:tableKey[ section ] ] indexOfObject: [self sectionToString: section ] ];
    if ( [indexPath row] == row ) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    cell.textLabel.text = [tableData objectForKey:tableKey[indexPath.section] ][[indexPath row]];
    return cell;
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if( nowType == 0 ) {
        return [tableKey count];
    }else {
        return 1;
    }
}

-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return tableKey[section];
}

- (IBAction)finishSearchSettings:(UIBarButtonItem *)sender {
    
    [self dismissViewControllerAnimated:true completion:nil];
    
}
@end
