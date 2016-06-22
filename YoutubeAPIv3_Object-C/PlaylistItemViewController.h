//
//  PlaylistItemViewController.h
//  YoutubeAPIv3_Object-C
//
//  Created by 涂安廷 on 2016/6/22.
//  Copyright © 2016年 涂安廷. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PlaylistItemViewController : UIViewController<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,UIScrollViewDelegate>
@property (weak, nonatomic) NSString *playlistId;
- (IBAction)backSearchViewController:(UIBarButtonItem *)sender;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UINavigationBar *navigationBar;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *collectionViewTop;

@end
