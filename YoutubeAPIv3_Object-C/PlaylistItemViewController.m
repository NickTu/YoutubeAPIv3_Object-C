//
//  PlaylistItemViewController.m
//  YoutubeAPIv3_Object-C
//
//  Created by 涂安廷 on 2016/6/22.
//  Copyright © 2016年 涂安廷. All rights reserved.
//

#import "PlaylistItemViewController.h"
#import "PlayViewController.h"
#import "VideoCollectionCell.h"

@interface PlaylistItemViewController ()

@end

@implementation PlaylistItemViewController {
    
    NSMutableDictionary *collectionDataArray ;
    UIActivityIndicatorView *activityIndicator;
    NSString *apiKey;
    NSString *youtubeNetworkAddress;
    NSString *pageToken;
    Boolean hasNextPage;
    Boolean isScrollSearch;
    NSInteger searchSuccessCount;
    NSInteger successCount;
    NSMutableArray *keyVideoId;
    NSDictionary *videoTypeDictionary;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    apiKey = @"AIzaSyDJFb3a04UYWc0NSdJv07SQ-wf8TFgyI6Y";
    youtubeNetworkAddress = @"https://www.googleapis.com/youtube/v3/";
    pageToken = @"";
    hasNextPage = true;
    isScrollSearch = false;
    collectionDataArray = [[NSMutableDictionary alloc] init];
    keyVideoId = [[NSMutableArray alloc] init];
    searchSuccessCount = 0;
    successCount = 0;
    videoTypeDictionary = @{ @"All":@"0", @"Film & Animation":@"1", @"Autos & Vehicles":@"2", @"Music":@"10", @"Pets & Animals":@"15", @"Sports":@"17", @"Short Movies":@"18", @"Travel & Events":@"19", @"Gaming":@"20", @"Videoblogging":@"21", @"People & Blogs":@"22", @"Comedy":@"23", @"Entertainment":@"24", @"News & Politics":@"25", @"Howto & Style":@"26", @"Education":@"27", @"Science & Technology":@"28", @"Movies":@"30", @"Anime/Animation":@"31", @"Action/Adventure":@"32", @"Classics":@"33", @"Documentary":@"35", @"Drama":@"36", @"Family":@"37", @"Foreign":@"38", @"Horror":@"39", @"Sci-Fi/Fantasy":@"40", @"Thriller":@"41", @"Shorts":@"42", @"Shows":@"43", @"Trailers":@"44" };
    
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    UINib *nib = [UINib nibWithNibName:@"VideoCollectionCell" bundle:nil];
    [self.collectionView registerNib:nib forCellWithReuseIdentifier:@"idVideoCollectionCell"];
    activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
    [activityIndicator setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
    [activityIndicator setCenter:CGPointMake(self.navigationBar.bounds.size.width/2, self.navigationBar.frame.size.height + 25 + 20)];
    [activityIndicator stopAnimating];
    [self.view addSubview:activityIndicator];
    [self cleanDataAndStartSearch];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)cleanDataAndStartSearch{
    self.collectionView.scrollEnabled = false;
    [keyVideoId removeAllObjects];
    [collectionDataArray removeAllObjects];
    self.collectionViewTop.constant = activityIndicator.frame.size.height;
    [self searchInPlaylistItem];
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
    [self searchInPlaylistItem];
    [searchBar resignFirstResponder];
}


-(void) searchInPlaylistItem{
    
    [activityIndicator startAnimating];
    NSString *urlString;
    NSString *urlStringPageToken;
    successCount = 0;
    searchSuccessCount = 0;
    
    if (pageToken.length > 0) {
        urlStringPageToken = [NSString stringWithFormat: @"&pageToken=%@",pageToken];
    }else {
        urlStringPageToken = @"";
    }
    
    urlString = [NSString stringWithFormat:@"%@playlistItems?&part=snippet&maxResults=50&key=%@&regionCode=TW%@&playlistId=%@",youtubeNetworkAddress,apiKey,urlStringPageToken,self.playlistId];
    
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
                    NSString *videoId = [[ [items[i] objectForKey:@"snippet"] objectForKey:@"resourceId" ] objectForKey:@"videoId" ];
                    [keyVideoId addObject:videoId];
                    [self getVideoDetails: videoId];
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

-(void)getVideoDetails:(NSString*) idString {
    
    NSString *urlString;
    
    urlString = [NSString stringWithFormat:@"%@videos?&part=snippet,statistics&key=%@&regionCode=TW&id=%@",youtubeNetworkAddress,apiKey,idString];
    
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
                    [videoDetailsDict setObject:[ [ firstItemDict objectForKey:@"statistics" ] objectForKey:@"viewCount" ] forKey:@"viewCount"];
                    [videoDetailsDict setObject:idString forKey:@"videoID"];
                    
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
        [self searchInPlaylistItem];
    }
    
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    PlayViewController *playViewController = [[PlayViewController alloc] initWithNibName:@"PlayViewController" bundle:nil];
    NSDictionary *details = [collectionDataArray objectForKey:keyVideoId[ [indexPath row] ] ];
    playViewController.videoID = [details objectForKey:@"videoID"];
    [self presentViewController:playViewController animated:true completion:nil];
    
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
    viewCount.text = [NSString stringWithFormat:@"viewCount = %@",[details objectForKey:@"viewCount"] ];
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

- (IBAction)backSearchViewController:(UIBarButtonItem *)sender {
    
    [self dismissViewControllerAnimated:true completion:nil];
    
}
@end
