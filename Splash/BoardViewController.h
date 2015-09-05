//
//  BoardViewController.h
//  Splash
//
//  Created by Alec Kretch on 1/8/15.
//  Copyright (c) 2015 Alec Kretch. All rights reserved.
//

#import <Parse/Parse.h>
#import <UIKit/UIKit.h>
#import "Constants.h"
#import "FixedStatusBarImagePickerViewController.h"
#import "FullImageViewController.h"
#import "MBProgressHUD.h"
#import "Reachability.h"
#import "ViewersViewController.h"

@interface BoardViewController : UIViewController <UIActionSheetDelegate, UIAlertViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (retain, nonatomic) IBOutlet FullImageViewController *fullImageViewController;
@property (retain, nonatomic) IBOutlet NSString *userName;
@property (retain, nonatomic) IBOutlet PFUser *user;
@property (retain, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (retain, nonatomic) IBOutlet UICollectionView *boardCollectionView;
@property (retain, nonatomic) IBOutlet FixedStatusBarImagePickerViewController *imagePickerController;
@property (retain, nonatomic) IBOutlet UILabel *lblTapAndHold;

@property (assign, nonatomic) BOOL viewingImage;
@property (assign, nonatomic) BOOL viewersBoard;
@property (assign, nonatomic) BOOL isTransitioningToBoard;
@property (retain, nonatomic) NSArray *arrayBoardImages;
@property (retain, nonatomic) NSArray *arrayIndexOfEmptyTiles;
@property (assign, nonatomic) NSInteger selectedTileNumber;

- (UIImage *)squareBoardImage;
- (UIImage *)resizeImage:(UIImage *)image width:(CGFloat)width height:(CGFloat)height;
- (BOOL)connected;
- (void)loadUserInBackground;

@end
