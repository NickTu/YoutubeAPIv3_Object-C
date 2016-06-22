//
//  HomeViewController.m
//  YoutubeAPIv3_Object-C
//
//  Created by 涂安廷 on 2016/6/21.
//  Copyright © 2016年 涂安廷. All rights reserved.
//

#import "HomeViewController.h"
#import "VideoCollectionCell.h"
#import "PlayViewController.h"

@interface HomeViewController ()

@end

@implementation HomeViewController {
    
    NSMutableArray *collectionDataArray ;
    UIActivityIndicatorView *activityIndicator;
    NSString *apiKey;
    NSString *youtubeNetworkAddress;
    NSString *pageToken;
    Boolean hasNextPage;
    Boolean isScrollSearch;
    NSInteger selectedIndex;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    apiKey = @"AIzaSyDJFb3a04UYWc0NSdJv07SQ-wf8TFgyI6Y";
    youtubeNetworkAddress = @"https://www.googleapis.com/youtube/v3/";
    pageToken = @"";
    hasNextPage = true;
    isScrollSearch = false;
    collectionDataArray = [[NSMutableArray alloc] init];
    
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    UINib *nib = [UINib nibWithNibName:@"VideoCollectionCell" bundle:nil];
    [self.collectionView registerNib:nib forCellWithReuseIdentifier:@"idVideoCollectionCell"];
    activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
    [activityIndicator setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
    [activityIndicator setCenter:CGPointMake(self.view.bounds.size.width/2, self.navigationBar.frame.size.height + 25 + 20)];
    [activityIndicator startAnimating];
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
    [collectionDataArray removeAllObjects];
    self.collectionViewTop.constant = activityIndicator.frame.size.height;
    [self search];
}

-(void) endSearch{
    [activityIndicator stopAnimating];
    self.collectionViewTop.constant = 0;
    [self.collectionView reloadData];
    isScrollSearch = false;
}

-(void) search{
    
    NSString *urlStringPageToken;
    
    if (pageToken.length > 0) {
        urlStringPageToken = [NSString stringWithFormat: @"&pageToken=%@",pageToken];
    }else {
        urlStringPageToken = @"";
    }
    
    NSString *string = [NSString stringWithFormat: @"videos?&part=snippet,statistics&chart=mostPopular&maxResults=50&key=%@&regionCode=TW",apiKey];
    NSString *urlString = [NSString stringWithFormat:@"%@%@%@",youtubeNetworkAddress,string,urlStringPageToken];
    urlString = [urlString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    NSURL *targetURL = [NSURL URLWithString:urlString];
    [self performGetRequest:targetURL completionSuccess: ^(NSData* data, NSInteger HTTPStatusCode, NSError* error){
        if (HTTPStatusCode == 200 && error == nil) {
            
            @try {
                NSDictionary *resultsDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
                
                NSArray<NSDictionary *> *items = [resultsDict objectForKey:@"items"];
                
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
                    NSMutableDictionary *snippetDict = [items[i] objectForKey:@"snippet"];
                    NSMutableDictionary *videoDetailsDict = [ [NSMutableDictionary alloc] init];
                    [videoDetailsDict setObject:[snippetDict objectForKey:@"title"] forKey:@"title"];
                    [videoDetailsDict setObject:[[items[i] objectForKey:@"statistics"] objectForKey:@"viewCount"] forKey:@"viewCount"];
                    [videoDetailsDict setObject:[ [[snippetDict objectForKey:@"thumbnails"] objectForKey:@"default"] objectForKey:@"url"] forKey:@"thumbnail"];
                    [videoDetailsDict setObject:[items[i] objectForKey:@"id"] forKey:@"videoID"];
                    [collectionDataArray addObject:videoDetailsDict];
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
        [self search];
    }
    
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    selectedIndex = [indexPath row];
    PlayViewController *playViewController = [[PlayViewController alloc] initWithNibName:@"PlayViewController" bundle:nil];
    NSMutableDictionary *details = collectionDataArray[selectedIndex];
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
    NSMutableDictionary *details = collectionDataArray[indexPath.row];
    title.text = [details objectForKey:@"title"];
    /*NSString *text = @"viewCount = ";
    [text stringByAppendingString:[details objectForKey:@"viewCount"] ];
    viewCount.text = text;*/
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

@end
