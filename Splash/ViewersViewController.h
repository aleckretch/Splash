//
//  ViewersViewController.h
//  Splash
//
//  Created by Alec Kretch on 4/17/15.
//  Copyright (c) 2015 Alec Kretch. All rights reserved.
//

#import <Parse/Parse.h>
#import <UIKit/UIKit.h>
#import "Constants.h"
#import "Reachability.h"
#import "BoardViewController.h"
#import "ViewersTableViewCell.h"

@interface ViewersViewController : UIViewController <UIGestureRecognizerDelegate, UITableViewDataSource, UITableViewDelegate>

@property (retain, nonatomic) IBOutlet NSString *userName;
@property (retain, nonatomic) IBOutlet UITableView *mainTableView;

@property (assign, nonatomic) BOOL doneLoading;
@property (assign, nonatomic) int tileNumber;
@property (retain, nonatomic) NSArray *arrayCurrentFavorites;
@property (retain, nonatomic) NSArray *arrayMain;
@property (retain, nonatomic) NSArray *arrayViewersUsernames;

@end
