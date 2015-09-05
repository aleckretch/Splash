//
//  ExploreViewController.h
//  Splash
//
//  Created by Alec Kretch on 1/10/15.
//  Copyright (c) 2015 Alec Kretch. All rights reserved.
//

#import <FacebookSDK/FacebookSDK.h>
#import <Parse/Parse.h>
#import <ParseFacebookUtils/PFFacebookUtils.h>
#import <UIKit/UIKit.h>
#import "BoardViewController.h"
#import "Constants.h"
#import "DateTools.h"
#import "MBProgressHUD.h"
#import "Reachability.h"
#import "UserTableViewCell.h"

@interface ExploreViewController : UIViewController <UIGestureRecognizerDelegate, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>

@property (retain, nonatomic) IBOutlet UIButton *btnCancelSearch;
@property (retain, nonatomic) IBOutlet UIButton *btnExploreFavorites;
@property (retain, nonatomic) IBOutlet UIButton *btnExploreFavoritedBy;
@property (retain, nonatomic) IBOutlet UIButton *btnExploreFacebook;
@property (retain, nonatomic) IBOutlet UITableView *mainTableView;
@property (retain, nonatomic) IBOutlet UITableViewController *mainTableViewController;
@property (retain, nonatomic) IBOutlet UITextField *tfSearchBar;
@property (retain, nonatomic) IBOutlet UIView *exploreOptionsButtonView;
@property (retain, nonatomic) IBOutlet UIView *mainAreaView;
@property (retain, nonatomic) IBOutlet UIView *navBarView;
@property (retain, nonatomic) IBOutlet UIView *searchBarView;

@property (assign, nonatomic) BOOL facebookOpen;
@property (assign, nonatomic) BOOL favoritedByOpen;
@property (assign, nonatomic) BOOL favoritesOpen;
@property (assign, nonatomic) BOOL isActive;
@property (assign, nonatomic) BOOL isLoading;
@property (assign, nonatomic) BOOL showFooter;
@property (assign, nonatomic) CGRect fullMainTableViewFrame;
@property (assign, nonatomic) int keyboardHeight;
@property (retain, nonatomic) NSArray *arrayMain;
@property (retain, nonatomic) NSArray *arrayCurrentFavorites;
@property (retain, nonatomic) NSArray *arrayFavorited;
@property (retain, nonatomic) NSArray *arrayFavoritedBys;
@property (retain, nonatomic) NSArray *arrayFiltered;
@property (retain, nonatomic) NSArray *arrayFacebookFriends;

@end
