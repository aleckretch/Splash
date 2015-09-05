//
//  TabBarController.h
//  Splash
//
//  Created by Alec Kretch on 1/11/15.
//  Copyright (c) 2015 Alec Kretch. All rights reserved.
//

#import <AssetsLibrary/AssetsLibrary.h>
#import <Parse/Parse.h>
#import <UIKit/UIKit.h>
#import "BoardViewController.h"
#import "ExploreViewController.h"
#import "MBProgressHUD.h"
#import "QBImagePickerController.h"
#import "ViewController.h"

@interface TabBarController : UITabBarController <QBImagePickerControllerDelegate, UIActionSheetDelegate, UIAlertViewDelegate>

@property (retain, nonatomic) IBOutlet BoardViewController *boardViewController;
@property (retain, nonatomic) IBOutlet ExploreViewController *exploreViewController;
@property (retain, nonatomic) IBOutlet NSString *userName;
@property (retain, nonatomic) IBOutlet NSString *titleString;
@property (retain, nonatomic) IBOutlet PFUser *user;
@property (retain, nonatomic) IBOutlet UIActionSheet *actionSheetOtherBoard;
@property (retain, nonatomic) IBOutlet UIActionSheet *actionSheetSelfBoard;
@property (retain, nonatomic) IBOutlet UIButton *btnTitle;
@property (retain, nonatomic) IBOutlet UINavigationController *exploreViewNavigationController;

@property (retain, nonatomic) NSArray *arrayFavorites;
@property (assign, nonatomic) BOOL boardIsFavorited;

- (void)setTitleButton:(BOOL)isButton;
- (void)showWelcomeMessage;

@end
