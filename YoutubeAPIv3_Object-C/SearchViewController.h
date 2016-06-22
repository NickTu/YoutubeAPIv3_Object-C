//
//  SearchViewController.h
//  YoutubeAPIv3_Object-C
//
//  Created by 涂安廷 on 2016/6/21.
//  Copyright © 2016年 涂安廷. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SearchViewController : UIViewController<UISearchBarDelegate,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,UIScrollViewDelegate>
- (IBAction)showSearchSettings:(UIBarButtonItem *)sender;
- (IBAction)showVideoCategories:(UIBarButtonItem *)sender;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UIButton *cancelSearchButton;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UINavigationBar *navigationBar;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *searchViewConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *collectionViewTop;
- (IBAction)cancelSearch:(UIButton *)sender;

@end
