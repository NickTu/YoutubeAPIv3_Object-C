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
#import "PlayViewController.h"
#import "VideoCollectionCell.h"
#import "AppDelegate.h"

@interface SearchViewController ()

@end

@implementation SearchViewController {
    
    NSMutableDictionary *collectionDataArray ;
    UIActivityIndicatorView *activityIndicator;
    NSString *apiKey;
    NSString *youtubeNetworkAddress;
    NSString *pageToken;
    Boolean hasNextPage;
    Boolean isScrollSearch;
    NSInteger selectedIndex;
    NSInteger searchSuccessCount;
    NSInteger successCount;
    NSMutableArray *keyVideoId;
    NSDictionary *videoTypeDictionary;
    Boolean againSearch;
    AppDelegate *appDelegate;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    apiKey = @"AIzaSyDJFb3a04UYWc0NSdJv07SQ-wf8TFgyI6Y";
    youtubeNetworkAddress = @"https://www.googleapis.com/youtube/v3/";
    pageToken = @"";
    hasNextPage = false;
    isScrollSearch = false;
    collectionDataArray = [[NSMutableDictionary alloc] init];
    keyVideoId = [[NSMutableArray alloc] init];
    searchSuccessCount = 0;
    successCount = 0;
    videoTypeDictionary = @{ @"All":@"0", @"Film & Animation":@"1", @"Autos & Vehicles":@"2", @"Music":@"10", @"Pets & Animals":@"15", @"Sports":@"17", @"Short Movies":@"18", @"Travel & Events":@"19", @"Gaming":@"20", @"Videoblogging":@"21", @"People & Blogs":@"22", @"Comedy":@"23", @"Entertainment":@"24", @"News & Politics":@"25", @"Howto & Style":@"26", @"Education":@"27", @"Science & Technology":@"28", @"Movies":@"30", @"Anime/Animation":@"31", @"Action/Adventure":@"32", @"Classics":@"33", @"Documentary":@"35", @"Drama":@"36", @"Family":@"37", @"Foreign":@"38", @"Horror":@"39", @"Sci-Fi/Fantasy":@"40", @"Thriller":@"41", @"Shorts":@"42", @"Shows":@"43", @"Trailers":@"44" };
    againSearch = true;
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    self.cancelSearchButton.hidden = true;
    
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.searchBar.delegate = self;
    UINib *nib = [UINib nibWithNibName:@"VideoCollectionCell" bundle:nil];
    [self.collectionView registerNib:nib forCellWithReuseIdentifier:@"idVideoCollectionCell"];
    activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
    [activityIndicator setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
    [activityIndicator setCenter:CGPointMake(self.view.bounds.size.width/2, self.navigationBar.frame.size.height + 25 + 20)];
    [activityIndicator stopAnimating];
    [self.view addSubview:activityIndicator];
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    hasNextPage = true;
    isScrollSearch = false;
    if( self.searchBar.text.length > 0 && againSearch ) {
        [self cleanDataAndStartSearch];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)cleanDataAndStartSearch{
    self.collectionView.scrollEnabled = false;
    [keyVideoId removeAllObjects];
    [collectionDataArray removeAllObjects];
    self.collectionViewTop.constant = activityIndicator.frame.size.height;
    [self search:self.searchBar.text];
}

-(void) endSearch{
    [activityIndicator stopAnimating];
    self.collectionViewTop.constant = 0;
    [self.collectionView reloadData];
    self.collectionView.scrollEnabled = true;
    isScrollSearch = false;
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    [keyVideoId removeAllObjects];
    [collectionDataArray removeAllObjects];
    [self search:self.searchBar.text];
    [searchBar resignFirstResponder];
}

-(void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar{
    self.searchViewConstraint.constant = self.cancelSearchButton.frame.size.width;
    self.cancelSearchButton.hidden = false;
    CGFloat width = self.view.bounds.size.width - self.cancelSearchButton.frame.size.width;
    searchBar.frame = CGRectMake(searchBar.frame.origin.x, searchBar.frame.origin.y, width, searchBar.frame.size.height);
    
}

-(void)searchBarTextDidEndEditing:(UISearchBar *)searchBar{
    self.searchViewConstraint.constant = 0;
    self.cancelSearchButton.hidden = true;
    CGFloat width = self.view.bounds.size.width;
    searchBar.frame = CGRectMake(searchBar.frame.origin.x, searchBar.frame.origin.y, width, searchBar.frame.size.height);
}

-(NSInteger)getNumberOfDaysInMonth:(NSDate*)date {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSRange range = [calendar rangeOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitMonth forDate:date];
    return range.length;
}

-(void) search:(NSString*)searchTest{
    
    [activityIndicator startAnimating];
    NSString *urlString;
    NSString *urlStringVideoCategoryId;
    NSString *urlStringVideoDurationDimensionDefinition;
    NSString *urlStringUploadTime = @"";
    NSString *urlStringPageToken;
    successCount = 0;
    searchSuccessCount = 0;
    
    if ([appDelegate.videoType isEqualToString:@"All"]) {
        urlStringVideoCategoryId = @"";
    }else {
        urlStringVideoCategoryId = [NSString stringWithFormat:@"&videoCategoryId=%@",[videoTypeDictionary objectForKey:appDelegate.videoType] ];
    }
    if ([appDelegate.type isEqualToString:@"video"]) {
        urlStringVideoDurationDimensionDefinition = [NSString stringWithFormat:@"&videoDuration=%@&videoDimension=%@&videoDefinition=%@",appDelegate.videoDuration,appDelegate.videoDimension,appDelegate.videoDefinition];
    }else {
        urlStringVideoDurationDimensionDefinition = @"";
    }
    
    NSDate *date = [NSDate date];
    NSDateFormatter *dateformatter = [[NSDateFormatter alloc] init];
    dateformatter.dateFormat = @"yyyy-MM-dd'T'hh:mm:ss'Z'";
    NSString *dateString = [dateformatter stringFromDate:date];
    
    if ([appDelegate.uploadTime isEqualToString:@"anytime"]) {
        urlStringUploadTime = @"";
    }else if ([appDelegate.uploadTime isEqualToString:@"today"]){
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"yyyy-MM-dd'T00:00:00Z'";
        NSString *todayString = [formatter stringFromDate:date];
        urlStringUploadTime = [NSString stringWithFormat:@"&publishedAfter=%@&publishedBefore=%@",todayString,dateString];
        
    }else if ([appDelegate.uploadTime isEqualToString:@"this week"]){
        
        NSCalendar *calendar = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
        NSDateComponents *comps = [calendar components:NSCalendarUnitWeekday fromDate:date];
        NSInteger value = -comps.weekday + 1;
        NSDate *thisweek = [[NSCalendar currentCalendar] dateByAddingUnit:NSCalendarUnitDay value:value toDate:date options:NSCalendarMatchNextTime];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"yyyy-MM-dd'T00:00:00Z'";
        NSString *weekDayString = [formatter stringFromDate:thisweek];
        urlStringUploadTime = [NSString stringWithFormat:@"&publishedAfter=%@&publishedBefore=%@",weekDayString,dateString];
        
    }else if ([appDelegate.uploadTime isEqualToString:@"this month"]){
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"yyyy-MM-'01T00:00:00Z'";
        NSString *thisMonthString = [formatter stringFromDate:date];
        urlStringUploadTime = [NSString stringWithFormat:@"&publishedAfter=%@&publishedBefore=%@",thisMonthString,dateString];
        
    }else if ([appDelegate.uploadTime isEqualToString:@"this year"]){
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"yyyy-'01-01T00:00:00Z'";
        NSString *thisYearString = [formatter stringFromDate:date];
        urlStringUploadTime = [NSString stringWithFormat:@"&publishedAfter=%@&publishedBefore=%@",thisYearString,dateString];
        
    }
    
    if (pageToken.length > 0) {
        urlStringPageToken = [NSString stringWithFormat: @"&pageToken=%@",pageToken];
    }else {
        urlStringPageToken = @"";
    }
    
    urlString = [NSString stringWithFormat:@"%@search?&part=snippet&maxResults=50&q=%@&type=%@&key=%@&order=%@&regionCode=TW%@%@%@%@",youtubeNetworkAddress,searchTest,appDelegate.type,apiKey,appDelegate.order,urlStringVideoCategoryId,urlStringVideoDurationDimensionDefinition,urlStringUploadTime,urlStringPageToken];

    urlString = [urlString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    NSURL *targetURL = [NSURL URLWithString:urlString];
    [self performGetRequest:targetURL completionSuccess: ^(NSData* data, NSInteger HTTPStatusCode, NSError* error){
        if (HTTPStatusCode == 200 && error == nil) {
            
            @try {
                NSDictionary *resultsDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
                
                NSArray<NSDictionary *> *items = [resultsDict objectForKey:@"items"];
                searchSuccessCount = [items count];
                if ([resultsDict objectForKey:@"nextPageToken"] != nil && [resultsDict objectForKey:@"prevPageToken"] != nil) {
                    hasNextPage = true;
                    pageToken = [resultsDict objectForKey:@"nextPageToken"];
                }else if ([resultsDict objectForKey:@"nextPageToken"] == nil && [resultsDict objectForKey:@"prevPageToken"] != nil ){
                    hasNextPage = false;
                    pageToken = @"";
                }else if ([resultsDict objectForKey:@"nextPageToken"] != nil && [resultsDict objectForKey:@"prevPageToken"] == nil) {
                    hasNextPage = true;
                    pageToken = [resultsDict objectForKey:@"nextPageToken"];
                }
                
                for( int i = 0 ; i < [items count] ; i++) {
                    NSString *videoId = [ [items[i] objectForKey:@"id"] objectForKey:[ NSString stringWithFormat:@"%@Id",appDelegate.type ] ];
                    [keyVideoId addObject:videoId];
                    [self getDetails: videoId];
                }
                
                [self endSearch];
            } @catch (NSException *exception){
                NSLog(@"Exception = %@",exception);
            }
            
        }else {
            NSLog(@"HTTP Status Code = \(%ld)",(long)HTTPStatusCode);
            NSLog(@"Error while loading channel videos: \(%@)",error);
        }
        
    }];
}

-(void)getDetails:(NSString*) idString {
    
    NSString *urlString;
    NSString *urlStringVideoCategoryId;
    NSString *urlStringType;
    NSString *count;
    NSString *part;
    if ([appDelegate.videoType isEqualToString:@"All"]) {
        urlStringVideoCategoryId = @"";
        
    }else {
        urlStringVideoCategoryId = [NSString stringWithFormat:@"&videoCategoryId=%@",[videoTypeDictionary objectForKey:appDelegate.videoType]];
    }
    if ([appDelegate.type isEqualToString:@"playlist"]) {
        urlStringType = @"&part=snippet,contentDetails";
        count = @"itemCount";
        part = @"contentDetails";
    }else if ([appDelegate.type isEqualToString:@"channel"]) {
        urlStringType = @"&part=snippet,statistics,contentDetails";
        count = @"viewCount";
        part = @"statistics";
    }else {
        urlStringType = @"&part=snippet,statistics";
        count = @"viewCount";
        part = @"statistics";
    }
    
    urlString = [NSString stringWithFormat:@"%@%@s?%@&key=%@&regionCode=TW&id=%@%@",youtubeNetworkAddress,appDelegate.type,urlStringType,apiKey,idString,urlStringVideoCategoryId];
    NSLog(@"urlString=%@",urlString);
    urlString = [urlString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    NSURL *targetURL = [NSURL URLWithString:urlString];
    
    [self performGetRequest:targetURL completionSuccess: ^(NSData* data, NSInteger HTTPStatusCode, NSError* error){
        if (HTTPStatusCode == 200 && error == nil) {
            
            @try {
                NSDictionary *resultsDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
                
                NSArray<NSDictionary *> *items = [resultsDict objectForKey:@"items"];
                if ( [items count] == 1 ) {
                    NSDictionary *firstItemDict = items[0];
                    
                    NSDictionary *snippetDict = [firstItemDict objectForKey:@"snippet"];
                    
                    NSMutableDictionary *videoDetailsDict = [[NSMutableDictionary alloc] init];
                    [videoDetailsDict setObject:[ snippetDict objectForKey:@"title" ] forKey:@"title"];
                    [videoDetailsDict setObject:[ [ [ snippetDict objectForKey:@"thumbnails" ] objectForKey:@"default" ] objectForKey:@"url" ] forKey:@"thumbnail"];
                    [videoDetailsDict setObject:[ [ firstItemDict objectForKey:part ] objectForKey:count ] forKey:count];
                    
                    if ([appDelegate.type isEqualToString:@"channel"]) {
                        [videoDetailsDict setObject:[ [ [ firstItemDict objectForKey:@"contentDetails" ] objectForKey:@"relatedPlaylists" ] objectForKey:@"uploads" ] forKey:@"playlistID"];
                    }else if ([appDelegate.type isEqualToString:@"playlist"]) {
                        [videoDetailsDict setObject:idString forKey:@"playlistID"];
                    }else {
                        [videoDetailsDict setObject:idString forKey:@"videoID"];
                    }
                    
                    [collectionDataArray setObject:videoDetailsDict forKey:idString];
                    
                    successCount += 1;
                    if (successCount == searchSuccessCount) {
                        [self endSearch];
                    }
                }else {
                    [self.collectionView reloadData];
                }
            } @catch (NSException *exception){
                NSLog(@"Exception = %@",exception);
            }
            
        }else {
            NSLog(@"HTTP Status Code = \(%ld)",(long)HTTPStatusCode);
            NSLog(@"Error while loading channel videos: \(%@)",error);
        }
        
    }];

}

-(void) performGetRequest:(NSURL*)targetURL completionSuccess:( void (^)( NSData* data, NSInteger HTTPStatusCode, NSError* error ) )completion{
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:targetURL];
    request.HTTPMethod = @"GET";
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfiguration];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^( NSData *data, NSURLResponse* response, NSError* error ) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
        dispatch_async(dispatch_get_main_queue(),^{
            completion(data, httpResponse.statusCode, error);
        });
    }];
    [task resume];
    
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    CGPoint offset = scrollView.contentOffset;
    CGRect bounds = scrollView.bounds;
    CGSize size = scrollView.contentSize;
    UIEdgeInsets inset = scrollView.contentInset;
    CGFloat y = offset.y + bounds.size.height - inset.bottom;
    CGFloat h = size.height;
    CGFloat reload_distance = -bounds.size.height*10/3;
    
    if (y > (h + reload_distance) && !isScrollSearch && hasNextPage) {
        isScrollSearch = true;
        [self search:self.searchBar.text];
    }
    
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    selectedIndex = [indexPath row];
    againSearch = false;
    if ( [appDelegate.type isEqualToString:@"video"] ) {
        PlayViewController *playViewController = [[PlayViewController alloc] initWithNibName:@"PlayViewController" bundle:nil];
        NSDictionary *details = [collectionDataArray objectForKey:keyVideoId[selectedIndex] ];
        playViewController.videoID = [details objectForKey:@"videoID"];
        [self presentViewController:playViewController animated:true completion:nil];
    } else {
        
    }
    
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [collectionDataArray count];
}

- (UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    
    VideoCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"idVideoCollectionCell" forIndexPath:indexPath];
    UILabel *title = cell.title;
    UIImageView *thumbnail = cell.thumbnail;
    UILabel *viewCount = cell.viewCount;
    NSMutableDictionary *details = [collectionDataArray objectForKey:keyVideoId[ [indexPath row] ] ];
    title.text = [details objectForKey:@"title"];
    if ([appDelegate.type isEqualToString:@"playlist"]) {
        viewCount.text = [NSString stringWithFormat:@"itemCount = %@",[details objectForKey:@"itemCount"] ];
    }else {
        viewCount.text = [NSString stringWithFormat:@"viewCount = %@",[details objectForKey:@"viewCount"] ];
    }
    NSURL *url = [NSURL URLWithString:[details objectForKey:@"thumbnail"] ];
    NSData *data = [NSData dataWithContentsOfURL:url];
    UIImage *image = [[UIImage alloc] initWithData:data];
    thumbnail.image = image;
    return cell;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(nonnull UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(0, 0, 0, 0);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(nonnull UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    return CGSizeMake(self.collectionView.frame.size.width/2-5, self.collectionView.frame.size.height/3);
}


- (IBAction)showSearchSettings:(UIBarButtonItem *)sender {
    
    SearchSettings *searchSettings = [[SearchSettings alloc] initWithNibName:@"SearchSettings" bundle:nil];
    [self presentViewController:searchSettings animated:true completion:nil];
    
}

- (IBAction)showVideoCategories:(UIBarButtonItem *)sender {
    
    VideoCategories *videoCategories = [[VideoCategories alloc] initWithNibName:@"VideoCategories" bundle:nil];
    [self presentViewController:videoCategories animated:true completion:nil];
    
}
- (IBAction)cancelSearch:(UIButton *)sender {
    
    [self dismissViewControllerAnimated:true completion:nil];
    
}
@end
