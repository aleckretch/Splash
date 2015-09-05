//
//  ExploreViewController.m
//  Splash
//
//  Created by Alec Kretch on 1/10/15.
//  Copyright (c) 2015 Alec Kretch. All rights reserved.
//

#import "ExploreViewController.h"

@interface ExploreViewController ()

@end

@implementation ExploreViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = LIGHT_BLUE_COLOR;
    [self searchBarDesign];
    [self mainAreaDesign];
    //lower keyboard on outside tap
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cancelSearch:)];
    [self.view addGestureRecognizer:tap]; //potentially make this self.navBarView
    //raise keyboard on tap on search bar view
    UITapGestureRecognizer *searchBarViewTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapSearchBarView:)];
    [self.searchBarView addGestureRecognizer:searchBarViewTap];
    //add notification to track keyboard press (for favorites/search results switch)
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter addObserver:self selector:@selector(textFieldText:) name:UITextFieldTextDidChangeNotification object:self.tfSearchBar];
    //detect iphone type for keyboard size
    if ([[UIScreen mainScreen] bounds].size.height == 736) //iphone 6 plus
    {
        self.keyboardHeight = 226;
    }
    else
    {
        self.keyboardHeight = 216;
    }
    if ([self connected])
    {
        [self setArrayFavoritedWithProgressHud:YES];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Uh, oh!" message:UNABLE_TO_CONNECT_MESSAGE delegate: nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
    self.favoritesOpen = YES;
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.isActive = YES;
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    //pull to refresh
    self.mainTableViewController.refreshControl = [[UIRefreshControl alloc] init];
    [self.mainTableViewController.refreshControl setTintColor:LIGHT_GRAY_COLOR];
    [self.mainTableView addSubview:self.mainTableViewController.refreshControl];
    [self.mainTableViewController.refreshControl addTarget:self action:@selector(reloadTable) forControlEvents:UIControlEventValueChanged];
    
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.mainTableViewController.refreshControl removeFromSuperview];
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if ([self.mainTableViewController.refreshControl isRefreshing])
    {
        [self.mainTableViewController.refreshControl endRefreshing];
    }
    
}

- (void)searchBarDesign {
    //create the nav bar
    self.navBarView = [[UIView alloc] initWithFrame:CGRectMake(0, STATUS_BAR_HEIGHT, self.view.frame.size.width, NAV_BAR_HEIGHT)];
    [self.view addSubview:self.navBarView];
    
    //create another subview which will serve as the background for the search bar
    self.searchBarView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.navBarView.frame.size.width-(ENDS_SPACING*2), self.navBarView.frame.size.height-(NAV_BAR_TOP_PADDING*2))];
    self.searchBarView.center = CGPointMake(self.navBarView.frame.size.width/2, self.navBarView.frame.size.height/2);
    self.searchBarView.backgroundColor = [UIColor whiteColor];
    [self.searchBarView.layer setCornerRadius:5.0f];
    [self.navBarView addSubview:self.searchBarView];
    
    //add search icon
    UIImage *searchIcon = [UIImage imageNamed:@"img_mag_glass.png"];
    UIImageView *searchIconView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 27, self.searchBarView.frame.size.height)];
    searchIconView.image = searchIcon;
    searchIconView.contentMode = UIViewContentModeCenter;
    [self.searchBarView addSubview:searchIconView];
    
    //add cancel button
    self.btnCancelSearch = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.btnCancelSearch setTitle:@"Cancel" forState:UIControlStateNormal];
    CGSize textSize = [[self.btnCancelSearch.titleLabel text] sizeWithAttributes:@{NSFontAttributeName:[self.btnCancelSearch.titleLabel font]}];
    [self.btnCancelSearch setTitleColor:LIGHT_GRAY_COLOR forState:UIControlStateNormal];
    [self.btnCancelSearch addTarget:self action:@selector(cancelSearch:) forControlEvents:UIControlEventTouchUpInside];
    CGFloat btnCancelSearchWidth = textSize.width+6; //6 may need to be adjusted depending on what text is
    CGFloat btnCancelSearchHeight = textSize.height;
    self.btnCancelSearch.frame = CGRectMake(0, 0, btnCancelSearchWidth, btnCancelSearchHeight);
    self.btnCancelSearch.center = CGPointMake(self.searchBarView.frame.size.width-(btnCancelSearchWidth/2)-(ELEMENTS_SPACING*2), self.searchBarView.frame.size.height/2);
    self.btnCancelSearch.hidden = YES;
    [self.searchBarView addSubview:self.btnCancelSearch];
    
    //add search bar
    self.tfSearchBar = [[UITextField alloc] initWithFrame:CGRectMake(searchIconView.frame.size.width, 0, self.searchBarView.frame.size.width-self.btnCancelSearch.frame.size.width-(ELEMENTS_SPACING*2)-searchIconView.frame.size.width, self.searchBarView.frame.size.height)]; //70 is temp, replace with actual cancel button width...
    self.tfSearchBar.textColor = DARK_GRAY_COLOR;
    self.tfSearchBar.placeholder = @"search";
    self.tfSearchBar.textAlignment = NSTextAlignmentLeft;
    self.tfSearchBar.keyboardType = UIKeyboardTypeAlphabet;
    self.tfSearchBar.autocorrectionType = UITextAutocorrectionTypeNo;
    self.tfSearchBar.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.tfSearchBar.returnKeyType = UIReturnKeySearch;
    self.tfSearchBar.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.tfSearchBar.backgroundColor = [UIColor whiteColor];
    self.tfSearchBar.delegate = self;
    [self.searchBarView addSubview:self.tfSearchBar];
    
}

- (void)mainAreaDesign {
    //create the view
    self.mainAreaView = [[UIView alloc] initWithFrame:CGRectMake(0, self.navBarView.frame.origin.y+self.navBarView.frame.size.height, self.view.frame.size.width, self.view.frame.size.height-TAB_BAR_HEIGHT-(self.navBarView.frame.origin.y+self.navBarView.frame.size.height))];
    [self.mainAreaView setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:self.mainAreaView];
    
    //create explore options button view
    self.exploreOptionsButtonView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 34)];
    [self.mainAreaView addSubview:self.exploreOptionsButtonView];
    
    //add options view
    UIView *optionsButtonView = [[UIView alloc] initWithFrame:CGRectMake(ENDS_SPACING, ELEMENTS_SPACING, self.view.frame.size.width-(ENDS_SPACING*2), self.exploreOptionsButtonView.frame.size.height-ELEMENTS_SPACING)];
    optionsButtonView.layer.cornerRadius = 8;
    optionsButtonView.layer.borderWidth = 1.0f;
    optionsButtonView.layer.borderColor = LIGHT_GRAY_COLOR.CGColor;
    optionsButtonView.clipsToBounds = YES;
    [self.exploreOptionsButtonView addSubview:optionsButtonView];
    
    //add lines
    UIBezierPath *pathLineOne = [UIBezierPath bezierPath];
    [pathLineOne moveToPoint:CGPointMake(optionsButtonView.frame.size.width/3, 0)];
    [pathLineOne addLineToPoint:CGPointMake(optionsButtonView.frame.size.width/3, optionsButtonView.frame.size.height)];
    
    CAShapeLayer *lineOne = [CAShapeLayer layer];
    lineOne.path = [pathLineOne CGPath];
    lineOne.strokeColor = [LIGHT_GRAY_COLOR CGColor];
    lineOne.lineWidth = LINE_THICKNESS;
    [optionsButtonView.layer addSublayer:lineOne];
    
    UIBezierPath *pathLineTwo = [UIBezierPath bezierPath];
    [pathLineTwo moveToPoint:CGPointMake(2*optionsButtonView.frame.size.width/3, 0)];
    [pathLineTwo addLineToPoint:CGPointMake(2*optionsButtonView.frame.size.width/3, optionsButtonView.frame.size.height)];
    
    CAShapeLayer *lineTwo = [CAShapeLayer layer];
    lineTwo.path = [pathLineTwo CGPath];
    lineTwo.strokeColor = [LIGHT_GRAY_COLOR CGColor];
    lineTwo.lineWidth = LINE_THICKNESS;
    [optionsButtonView.layer addSublayer:lineTwo];
    
    //add favorites option button
    self.btnExploreFavorites = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.btnExploreFavorites setTitle:@"favorites" forState:UIControlStateNormal];
    [self.btnExploreFavorites setTitleColor:LIGHT_GRAY_COLOR forState:UIControlStateNormal];
    [self.btnExploreFavorites setTitleColor:[UIColor whiteColor] forState:UIControlStateDisabled];
    [self.btnExploreFavorites setBackgroundImage:[self imageWithColor:LIGHT_GRAY_COLOR] forState:UIControlStateDisabled];
    [self.btnExploreFavorites setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [self.btnExploreFavorites setBackgroundImage:[self imageWithColor:LIGHT_GRAY_COLOR] forState:UIControlStateHighlighted];
    self.btnExploreFavorites.titleLabel.font = LABEL_FONT;
    self.btnExploreFavorites.titleEdgeInsets = UIEdgeInsetsMake(2, 0, 0, 0);
    [self.btnExploreFavorites addTarget:self action:@selector(onTapExploreFavorites) forControlEvents:UIControlEventTouchUpInside];
    self.btnExploreFavorites.frame = CGRectMake(0, 0, optionsButtonView.frame.size.width/3, optionsButtonView.frame.size.height);
    self.btnExploreFavorites.center = CGPointMake(optionsButtonView.frame.size.width/6, optionsButtonView.frame.size.height/2);
    self.btnExploreFavorites.enabled = NO;
    self.btnExploreFavorites.tintColor = [UIColor clearColor];
    [optionsButtonView addSubview:self.btnExploreFavorites];
    
    //add favorited by option button
    self.btnExploreFavoritedBy = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.btnExploreFavoritedBy setTitle:@"favorited by" forState:UIControlStateNormal];
    [self.btnExploreFavoritedBy setTitleColor:LIGHT_GRAY_COLOR forState:UIControlStateNormal];
    [self.btnExploreFavoritedBy setTitleColor:[UIColor whiteColor] forState:UIControlStateDisabled];
    [self.btnExploreFavoritedBy setBackgroundImage:[self imageWithColor:LIGHT_GRAY_COLOR] forState:UIControlStateDisabled];
    [self.btnExploreFavoritedBy setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [self.btnExploreFavoritedBy setBackgroundImage:[self imageWithColor:LIGHT_GRAY_COLOR] forState:UIControlStateHighlighted];
    self.btnExploreFavoritedBy.titleLabel.font = LABEL_FONT;
    self.btnExploreFavoritedBy.titleEdgeInsets = UIEdgeInsetsMake(2, 0, 0, 0);
    [self.btnExploreFavoritedBy addTarget:self action:@selector(onTapExploreFavoritedBy) forControlEvents:UIControlEventTouchUpInside];
    self.btnExploreFavoritedBy.frame = CGRectMake(0, 0, optionsButtonView.frame.size.width/3, optionsButtonView.frame.size.height);
    self.btnExploreFavoritedBy.center = CGPointMake(optionsButtonView.frame.size.width/2, optionsButtonView.frame.size.height/2);
    [optionsButtonView addSubview:self.btnExploreFavoritedBy];
    
    //add facebook option button
    self.btnExploreFacebook = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.btnExploreFacebook setTitle:@"facebook" forState:UIControlStateNormal];
    [self.btnExploreFacebook setTitleColor:LIGHT_GRAY_COLOR forState:UIControlStateNormal];
    [self.btnExploreFacebook setTitleColor:[UIColor whiteColor] forState:UIControlStateDisabled];
    [self.btnExploreFacebook setBackgroundImage:[self imageWithColor:LIGHT_GRAY_COLOR] forState:UIControlStateDisabled];
    [self.btnExploreFacebook setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [self.btnExploreFacebook setBackgroundImage:[self imageWithColor:LIGHT_GRAY_COLOR] forState:UIControlStateHighlighted];
    self.btnExploreFacebook.titleLabel.font = LABEL_FONT;
    self.btnExploreFacebook.titleEdgeInsets = UIEdgeInsetsMake(2, 0, 0, 0);
    [self.btnExploreFacebook addTarget:self action:@selector(onTapExploreFacebook) forControlEvents:UIControlEventTouchUpInside];
    self.btnExploreFacebook.frame = CGRectMake(0, 0, optionsButtonView.frame.size.width/3, optionsButtonView.frame.size.height);
    self.btnExploreFacebook.center = CGPointMake(5*optionsButtonView.frame.size.width/6, optionsButtonView.frame.size.height/2);
    [optionsButtonView addSubview:self.btnExploreFacebook];
    
    //add title (favorites initially)
    self.favoritesOpen = YES;
    
    //create table view controller
    self.fullMainTableViewFrame = CGRectMake(ENDS_SPACING, self.exploreOptionsButtonView.frame.size.height+ELEMENTS_SPACING, self.view.frame.size.width-(ENDS_SPACING*2), self.mainAreaView.frame.size.height-self.exploreOptionsButtonView.frame.size.height-ELEMENTS_SPACING);
    self.mainTableViewController = [[UITableViewController alloc] initWithStyle:UITableViewStylePlain];
    [self addChildViewController:self.mainTableViewController];
    
    self.mainTableViewController.refreshControl = [[UIRefreshControl alloc] init];
    self.mainTableViewController.refreshControl.tintColor = LIGHT_GRAY_COLOR;
    [self.mainTableViewController.refreshControl addTarget:self action:@selector(reloadTable) forControlEvents:UIControlEventValueChanged];
    
    //create table view
    self.mainTableView = [[UITableView alloc] initWithFrame:self.fullMainTableViewFrame];
    [self.mainTableView registerClass:[UserTableViewCell class] forCellReuseIdentifier:@"Cell"];
    self.mainTableView.delegate = self;
    self.mainTableView.dataSource = self;
    self.mainTableView.backgroundColor = [UIColor clearColor];
    self.mainTableView.rowHeight = 52;
    self.mainTableView.separatorColor = LIGHT_GRAY_COLOR;
    self.mainTableView.allowsSelection = NO;
    self.mainTableView.separatorInset = UIEdgeInsetsZero;
    self.mainTableViewController.tableView = self.mainTableView;
    [self.mainAreaView addSubview:self.mainTableViewController.tableView];
    
}

- (void)reloadTable {
    if ([self connected])
    {
        if (self.favoritesOpen)
        {
            [self setArrayFavoritedWithProgressHud:NO];
        }
        else if (self.favoritedByOpen)
        {
            [self setArrayFavoritedBysWithProgressHud:NO];
        }
        else if (self.facebookOpen)
        {
            [self setArrayFriendsWithProgressHud:NO];
        }
        [self.mainTableView reloadData];
    }
    else
    {
        [self.mainTableViewController.refreshControl endRefreshing];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Uh, oh!" message:UNABLE_TO_CONNECT_MESSAGE delegate: nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
    
}

- (void)setArrayFavoritedWithProgressHud:(BOOL)includeHud {
    [self getFavorites];
    if (includeHud)
    {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.labelText = @"Loading";
        self.isLoading = YES;
    }
    [PFCloud callFunctionInBackground:@"getFavorites" withParameters:@{@"username": [PFUser currentUser].username} block:^(id object, NSError *error) {
        NSArray *arrayFavoritesUsernames = object;
        NSMutableArray *arrayFavorites = [NSMutableArray array];
        if (arrayFavoritesUsernames.count >> 0)
        {
            for (int i=0; i<arrayFavoritesUsernames.count; i++)
            {
                [PFCloud callFunctionInBackground:@"getUser" withParameters:@{@"username": [arrayFavoritesUsernames objectAtIndex:i]} block:^(id object, NSError *error) {
                    if (!error)
                    {
                        PFUser *favoriteUser = object;
                        [arrayFavorites addObject:favoriteUser];
                        NSArray *sortedArrayFavorites = [self sortArrayByDateUpdated:arrayFavorites];
                        if (sortedArrayFavorites.count == arrayFavoritesUsernames.count)
                        {
                            if (!self.btnExploreFavorites.isEnabled) //meaning that it is selected
                            {
                                self.arrayMain = sortedArrayFavorites;
                                self.arrayFavorited = self.arrayMain;
                            }
                            if (includeHud)
                            {
                                [MBProgressHUD hideHUDForView:self.view animated:YES];
                                self.isLoading = NO;
                            }
                            else
                            {
                                [self.mainTableViewController.refreshControl endRefreshing];
                            }
                            [self.mainTableView reloadData];
                        }
                    }
                    else
                    {
                        if (includeHud)
                        {
                            [MBProgressHUD hideHUDForView:self.view animated:YES];
                            self.isLoading = NO;
                        }
                        else
                        {
                            [self.mainTableViewController.refreshControl endRefreshing];
                        }
                        [self.mainTableView reloadData];
                        
                    }
                }];
            }
        }
        else
        {
            self.arrayFavorited = nil;
            self.arrayMain = nil;
            if (includeHud)
            {
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                self.isLoading = NO;
            }
            else
            {
                [self.mainTableViewController.refreshControl endRefreshing];
            }
            [self.mainTableView reloadData];
        }
    }];
    
}

- (void)setArrayFavoritedBysWithProgressHud:(BOOL)includeHud {
    [self getFavorites];
    if (includeHud)
    {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.labelText = @"Loading";
        self.isLoading = YES;
    }
    [PFCloud callFunctionInBackground:@"getFavoritedBys" withParameters:@{@"username": [PFUser currentUser].username} block:^(id object, NSError *error) {
        NSMutableArray *arrayFavoritedBysUsernames = object;
        NSMutableArray *arrayFavoritedBys = [NSMutableArray array];
        if (arrayFavoritedBysUsernames.count >> 0)
        {
            for (int i=0; i<arrayFavoritedBysUsernames.count; i++)
            {
                [PFCloud callFunctionInBackground:@"getUser" withParameters:@{@"username": [arrayFavoritedBysUsernames objectAtIndex:i]} block:^(id object, NSError *error) {
                    if (!error)
                    {
                        PFUser *favoriteUser = object;
                        [arrayFavoritedBys addObject:favoriteUser];
                        NSArray *arrayFavoritedBysSorted = [self sortArrayByIndex:arrayFavoritedBys toUsernames:arrayFavoritedBysUsernames];
                        if (arrayFavoritedBysSorted.count == arrayFavoritedBysUsernames.count)
                        {
                            if (!self.btnExploreFavoritedBy.isEnabled) //meaning that it is selected
                            {
                                self.arrayMain = arrayFavoritedBysSorted;
                                self.arrayFavoritedBys = self.arrayMain;
                            }
                            if (includeHud)
                            {
                                [MBProgressHUD hideHUDForView:self.view animated:YES];
                                self.isLoading = NO;
                            }
                            else
                            {
                                [self.mainTableViewController.refreshControl endRefreshing];
                            }
                            [self.mainTableView reloadData];
                        }
                    }
                    else
                    {
                        if (includeHud)
                        {
                            [MBProgressHUD hideHUDForView:self.view animated:YES];
                            self.isLoading = NO;
                        }
                        else
                        {
                            [self.mainTableViewController.refreshControl endRefreshing];
                        }
                        [self.mainTableView reloadData];
                        
                    }
                }];
            }
        }
        else
        {
            self.arrayFavoritedBys = nil;
            self.arrayMain = nil;
            if (includeHud)
            {
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                self.isLoading = NO;
            }
            else
            {
                [self.mainTableViewController.refreshControl endRefreshing];
            }
            [self.mainTableView reloadData];
        }
    }];
    
}

- (void)setArrayFriendsWithProgressHud:(BOOL)includeHud {
    [self getFavorites];
    NSMutableArray *arrayFriends = [NSMutableArray array];
    NSMutableArray *friendIds = [NSMutableArray array];
    FBRequest* friendsRequest = [FBRequest requestWithGraphPath:@"me/friends" parameters:nil HTTPMethod:@"GET"];
    [friendsRequest startWithCompletionHandler: ^(FBRequestConnection *connection, NSDictionary* result, NSError *error) {
        NSArray *friendObjects = [result objectForKey:@"data"];
        for (NSDictionary<FBGraphUser>* friend in friendObjects)
        {
            [friendIds addObject:friend.objectID];
        }
        if (friendIds.count != 0)
        {
            for (int count = 0; count < friendIds.count; count++)
            {
                [PFCloud callFunctionInBackground:@"getUserFromFacebook" withParameters:@{@"facebookId": [friendIds objectAtIndex:count]} block:^(id object, NSError *error) {
                    if (!error)
                    {
                        PFUser *facebookUser = object;
                        [arrayFriends addObject:facebookUser];
                        NSArray *arrayFriendsSorted = [self sortArrayByDateUpdated:arrayFriends];
                        if (arrayFriendsSorted.count == friendIds.count)
                        {
                            if (!self.btnExploreFacebook.isEnabled) //meaning that it is selected
                            {
                                self.arrayMain = arrayFriendsSorted;
                                self.arrayFacebookFriends = self.arrayMain;
                            }
                            if (includeHud)
                            {
                                [MBProgressHUD hideHUDForView:self.view animated:YES];
                                self.isLoading = NO;
                            }
                            else
                            {
                                [self.mainTableViewController.refreshControl endRefreshing];
                            }
                            [self.mainTableView reloadData];
                        }
                    }
                    else
                    {
                        if (includeHud)
                        {
                            [MBProgressHUD hideHUDForView:self.view animated:YES];
                            self.isLoading = NO;
                        }
                        else
                        {
                            [self.mainTableViewController.refreshControl endRefreshing];
                        }
                        [self.mainTableView reloadData];
                        
                    }
                }];
            }
        }
        else
        {
            self.arrayFacebookFriends = nil;
            self.arrayMain = nil;
            if (includeHud)
            {
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                self.isLoading = NO;
            }
            else
            {
                [self.mainTableViewController.refreshControl endRefreshing];
            }
            [self.mainTableView reloadData];
        }
    }];
    
}

- (void)setArraySearchResults {
    [self getFavorites];
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Loading";
    self.showFooter = NO;
    NSMutableArray *arrayResults = [NSMutableArray array];
    PFQuery *query = [PFUser query];
    [query whereKey:@"username" containsString:self.tfSearchBar.text.lowercaseString];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
     {
         if (objects.count != 0)
         {
             for (int i=0; i<=objects.count; i++)
             {
                 if (!error)
                 {
                     PFObject *foundObject = (PFObject *)objects[i];
                     PFUser *foundUser = (PFUser *)foundObject;
                     [arrayResults addObject:foundUser];
                     NSArray *arrayResultsSorted = [self sortArrayByDateUpdated:arrayResults];
                     if (arrayResultsSorted.count == objects.count)
                     {
                         if (arrayResultsSorted.count > 10)
                         {
                             NSMutableArray *arrayTenResultsSorted = [NSMutableArray array];
                             for (int i=0; i<10; i++)
                             {
                                 [arrayTenResultsSorted addObject:arrayResultsSorted[i]];
                             }
                             self.arrayMain = arrayTenResultsSorted;
                         }
                         else
                         {
                             self.arrayMain = arrayResultsSorted;
                         }
                         [self.mainTableView reloadData];
                         [MBProgressHUD hideHUDForView:self.view animated:YES];
                     }
                 }
                 else
                 {
                     [MBProgressHUD hideHUDForView:self.view animated:YES];
                 }
             }
         }
         else
         {
             [MBProgressHUD hideHUDForView:self.view animated:YES];
         }
     }];
    [self.mainTableView reloadData];
    
}

- (void)searchingList {
    [self getFavorites];
    NSMutableArray *arrayFiltered = [NSMutableArray array];
    if (self.facebookOpen)
    {
        for (PFUser *user in self.arrayFacebookFriends)
        {
            if (self.tfSearchBar.text.length == 0 ||
                [user.username.lowercaseString rangeOfString:self.tfSearchBar.text.lowercaseString].location != NSNotFound)
            {
                [arrayFiltered addObject:user];
            }
        }
    }
    else if (self.favoritesOpen)
    {
        for (PFUser *user in self.arrayFavorited)
        {
            if (self.tfSearchBar.text.length == 0 ||
                [user.username.lowercaseString rangeOfString:self.tfSearchBar.text.lowercaseString].location != NSNotFound)
            {
                [arrayFiltered addObject:user];
            }
        }
    }
    else if (self.favoritedByOpen)
    {
        for (PFUser *user in self.arrayFavoritedBys)
        {
            if (self.tfSearchBar.text.length == 0 ||
                [user.username.lowercaseString rangeOfString:self.tfSearchBar.text.lowercaseString].location != NSNotFound)
            {
                [arrayFiltered addObject:user];
            }
        }
    }

    self.arrayFiltered = arrayFiltered;
    
}

- (NSArray *)sortArrayByDateUpdated:(NSMutableArray *)array {
    NSSortDescriptor *dateDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"lastBoardUpdate" ascending:NO];
    NSArray *sortDescriptors = [NSArray arrayWithObject:dateDescriptor];
    NSArray *sortedEventArray = [array sortedArrayUsingDescriptors:sortDescriptors];
    
    return sortedEventArray;
    
}

- (NSArray *)sortArrayByIndex:(NSMutableArray *)array toUsernames:(NSMutableArray *)arrayUsernames {
    NSMutableArray *sortedArray = [[NSMutableArray alloc] initWithObjects:nil];
    for (int i=(int)arrayUsernames.count-1; i >= 0; i--)
    {
        NSString *usernameAtIndex = [arrayUsernames objectAtIndex:i];
        for (int j=0; j<array.count; j++)
        {
            PFUser *userAtIndex = (PFUser *)[array objectAtIndex:j];
            if ([userAtIndex.username isEqualToString:usernameAtIndex])
            {
                [sortedArray addObject:userAtIndex];
                j = (int)array.count; //end this part of the loop
            }
        }
    }
    
    return sortedArray;
    
}

- (BOOL)noCellsAvailable {
    if (self.arrayMain.count == 0)
    {
        return YES;
    }
    else
    {
        return NO;
    }
    
}

- (BOOL)isSearching {
    if (self.tfSearchBar.text.length != 0)
    {
        return YES;
    }
    else
    {
        return NO;
    }
    
}

- (void)cancelSearch:(id)sender {
    [self.tfSearchBar resignFirstResponder];
    
}

- (void)onTapExploreFavorites {
    self.btnExploreFavorites.enabled = NO;
    self.btnExploreFavoritedBy.enabled = YES;
    self.btnExploreFacebook.enabled = YES;
    
    self.favoritesOpen = YES;
    self.favoritedByOpen = NO;
    self.facebookOpen = NO;
    
    self.arrayMain = self.arrayFavorited;
    [self.mainTableView reloadData];
    
    [self.tfSearchBar resignFirstResponder];
    
}

- (void)onTapExploreFavoritedBy {
    self.btnExploreFavorites.enabled = YES;
    self.btnExploreFavoritedBy.enabled = NO;
    self.btnExploreFacebook.enabled = YES;
    
    self.favoritesOpen = NO;
    self.favoritedByOpen = YES;
    self.facebookOpen = NO;
    
    if (!self.arrayFavoritedBys)
    {
        if ([self connected])
        {
            [self setArrayFavoritedBysWithProgressHud:YES];
        }
        else
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Uh, oh!" message:UNABLE_TO_CONNECT_MESSAGE delegate: nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        }
    }
    else
    {
        self.arrayMain = self.arrayFavoritedBys;
        [self.mainTableView reloadData];
    }
    
    [self.tfSearchBar resignFirstResponder];
    
}

- (void)onTapExploreFacebook {
    self.btnExploreFavorites.enabled = YES;
    self.btnExploreFavoritedBy.enabled = YES;
    self.btnExploreFacebook.enabled = NO;
    
    self.favoritesOpen = NO;
    self.favoritedByOpen = NO;
    self.facebookOpen = YES;
    
    if (!self.arrayFacebookFriends)
    {
        if ([self connected])
        {
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            hud.labelText = @"Loading";
            self.isLoading = YES;
            [PFFacebookUtils initializeFacebook];
            //log user in
            NSArray *permissions = [[NSArray alloc] initWithObjects:@"public_profile", @"user_friends", nil];
            [PFFacebookUtils linkUser:[PFUser currentUser] permissions:permissions block:^(BOOL suceeded, NSError *error) {
                if (suceeded)
                {
                    [PFFacebookUtils logInWithPermissions:permissions block:^(PFUser *user, NSError *error) {
                        if (user) {
                            [FBRequestConnection startForMeWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                                if (!error) {
                                    [[PFUser currentUser] setObject:[result objectForKey:@"id"] forKey:@"fbId"];
                                    [[PFUser currentUser] saveInBackground];
                                }
                            }];
                        }
                    }];
                    [self setArrayFriendsWithProgressHud:YES];
                }
                else
                {
                    [MBProgressHUD hideHUDForView:self.view animated:YES];
                    self.isLoading = NO;
                }
            }];
        }
        else
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Uh, oh!" message:UNABLE_TO_CONNECT_MESSAGE delegate: nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        }
    }
    else
    {
        self.arrayMain = self.arrayFacebookFriends;
        [self.mainTableView reloadData];
    }
    
    [self.tfSearchBar resignFirstResponder];
    
}

- (void)onTapSearchBarView:(id)sender {
    [self.tfSearchBar becomeFirstResponder];
    
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    self.btnCancelSearch.hidden = NO;
    self.mainTableView.frame = CGRectMake(self.fullMainTableViewFrame.origin.x, self.fullMainTableViewFrame.origin.y, self.fullMainTableViewFrame.size.width, self.fullMainTableViewFrame.size.height-(self.keyboardHeight-TAB_BAR_HEIGHT)); //should only be scrollable through keyboard
    
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [self.mainTableView addSubview:self.mainTableViewController.refreshControl];
    self.btnCancelSearch.hidden = YES;
    self.tfSearchBar.text = @"";
    if (self.facebookOpen)
    {
        //[self setMainAreaHeaderText:@"facebook friends" isButton:YES];
        self.arrayMain = self.arrayFacebookFriends;
    }
    else if (self.favoritesOpen)
    {
        //[self setMainAreaHeaderText:@"favorites" isButton:YES];
        self.arrayMain = self.arrayFavorited;
    }
    else if (self.favoritedByOpen)
    {
        //[self setMainAreaHeaderText:@"favorited by" isButton:YES];
        self.arrayMain = self.arrayFavoritedBys;
    }
    [self.mainTableView reloadData];
    self.mainTableView.frame = self.fullMainTableViewFrame; //reset frame back to original size
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if ([self isSearching] && self.tfSearchBar.text.length != 0)
    {
        [self setArraySearchResults];
    }
    else
    {
        [self.tfSearchBar resignFirstResponder];
    }
    return NO;
    
}

- (void)textFieldText:(id)notification {
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    self.showFooter = YES;
    if (self.tfSearchBar.text.length != 0)
    {
        [self.mainTableViewController.refreshControl removeFromSuperview];
        //[self setMainAreaHeaderText:@"search results" isButton:NO];
        [self searchingList];
        self.arrayMain = self.arrayFiltered;
    }
    else
    {
        [self.mainTableView addSubview:self.mainTableViewController.refreshControl];
        if (self.facebookOpen)
        {
            //[self setMainAreaHeaderText:@"facebook friends" isButton:YES];
            self.arrayMain = self.arrayFacebookFriends;
        }
        else if (self.favoritesOpen)
        {
            self.arrayMain = self.arrayFavorited;
        }
        else if (self.favoritedByOpen)
        {
            self.arrayMain = self.arrayFavoritedBys;
        }
    }
    [self.mainTableView reloadData];
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger returnValue = 0;
    if (!self.isLoading)
    {
        if ([self noCellsAvailable])
        {
            if (([self isSearching] && self.showFooter))
            {
                returnValue++;
            }
            returnValue++;
        }
        else if (([self isSearching] && self.arrayMain.count < 6 && self.showFooter))
        {
            returnValue = self.arrayMain.count+1;
        }
        else
        {
            returnValue = self.arrayMain.count;
        }
    }
    
    return returnValue;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UserTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    if (cell == nil) {
        cell = [[UserTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    }
    if ([self noCellsAvailable])
    {
        if (indexPath.row == 0)
        {
            cell.title.center = CGPointMake(self.mainTableView.frame.size.width/2, self.mainTableView.rowHeight/2);
            cell.title.textAlignment = NSTextAlignmentCenter;
            cell.title.text = @"No users found.";
            [cell.contentView addSubview:cell.title];
            [cell.proPicImageView removeFromSuperview];
            [cell.btnCell removeFromSuperview];
            [cell.btnFavorite removeFromSuperview];
            [cell.btnUnfavorite removeFromSuperview];
            [cell.userName removeFromSuperview];
            [cell.timeStamp removeFromSuperview];
            [cell.btnTitle removeFromSuperview];
        }
        if ([self isSearching] && self.arrayMain.count < 6 && self.showFooter)
        {
            if (indexPath.row == [self tableView:self.mainTableView numberOfRowsInSection:0]-1)
            {
                cell.btnTitle.center = CGPointMake(self.mainTableView.frame.size.width/2, self.mainTableView.rowHeight/2);
                cell.btnTitle.titleLabel.textAlignment = NSTextAlignmentCenter;
                [cell.btnTitle setTitle:@"Search all users?" forState:UIControlStateNormal];
                [cell.btnTitle addTarget:self action:@selector(setArraySearchResults) forControlEvents:UIControlEventTouchUpInside];
                [cell.contentView addSubview:cell.btnTitle];
                [cell.title removeFromSuperview];
                [cell.proPicImageView removeFromSuperview];
                [cell.btnCell removeFromSuperview];
                [cell.btnFavorite removeFromSuperview];
                [cell.btnUnfavorite removeFromSuperview];
                [cell.userName removeFromSuperview];
                [cell.timeStamp removeFromSuperview];
            }
        }
    }
    else
    {
        if ([self noCellsAvailable] && indexPath.row == 0)
        {
            cell.title.center = CGPointMake(self.mainTableView.frame.size.width/2, self.mainTableView.rowHeight/2);
            cell.title.textAlignment = NSTextAlignmentCenter;
            cell.title.text = @"No users found.";
            [cell.contentView addSubview:cell.title];
            [cell.proPicImageView removeFromSuperview];
            [cell.btnCell removeFromSuperview];
            [cell.btnFavorite removeFromSuperview];
            [cell.btnUnfavorite removeFromSuperview];
            [cell.userName removeFromSuperview];
            [cell.timeStamp removeFromSuperview];
            [cell.btnTitle removeFromSuperview];
        }
        if ([self isSearching] && self.arrayMain.count < 6 && self.showFooter && indexPath.row == [self tableView:self.mainTableView numberOfRowsInSection:0]-1)
        {
            cell.btnTitle.center = CGPointMake(self.mainTableView.frame.size.width/2, self.mainTableView.rowHeight/2);
            cell.btnTitle.titleLabel.textAlignment = NSTextAlignmentCenter;
            [cell.btnTitle setTitle:@"Search all users?" forState:UIControlStateNormal];
            [cell.btnTitle addTarget:self action:@selector(setArraySearchResults) forControlEvents:UIControlEventTouchUpInside];
            [cell.contentView addSubview:cell.btnTitle];
            [cell.title removeFromSuperview];
            [cell.proPicImageView removeFromSuperview];
            [cell.btnCell removeFromSuperview];
            [cell.btnFavorite removeFromSuperview];
            [cell.btnUnfavorite removeFromSuperview];
            [cell.userName removeFromSuperview];
            [cell.timeStamp removeFromSuperview];
        }
        else
        {
            [cell.title removeFromSuperview];
            [cell.btnTitle removeFromSuperview];
            [cell.contentView addSubview:cell.proPicImageView];
            [cell.contentView addSubview:cell.btnCell];
            [cell.contentView addSubview:cell.btnFavorite];
            [cell.contentView addSubview:cell.btnUnfavorite];
            [cell.contentView addSubview:cell.userName];
            [cell.contentView addSubview:cell.timeStamp];
            
            PFUser *user = [self.arrayMain objectAtIndex:indexPath.row];
            PFFile *tileFile = [user objectForKey:@"tile5"];
            UIImage *imageAtPath = [UIImage imageWithData:tileFile.getData];
            
            if (!imageAtPath)
            {
                imageAtPath = [UIImage imageNamed:@"img_blank_tile_5.png"];
            }
            cell.proPicImageView.image = imageAtPath;
            cell.userName.text = user.username;
            
            PFObject *dateObject = [user objectForKey:@"lastBoardUpdate"];
            NSDate *dateUpdated = (NSDate *)dateObject;
            NSString *dateUpdatedAgo = [[NSDate date] timeAgoSinceDate:dateUpdated numericDates:YES];
            
            if (!dateUpdated)
            {
                dateUpdatedAgo = @"never";
            }
            
            cell.timeStamp.text = [NSString stringWithFormat:@"last update: %@", dateUpdatedAgo].lowercaseString;
            if ([cell.userName.text isEqualToString:[PFUser currentUser].username])
            {
                cell.btnFavorite.hidden = YES;
                cell.btnUnfavorite.hidden = YES;
            }
            else
            {
                if ([self.arrayCurrentFavorites containsObject:cell.userName.text])
                {
                    cell.btnFavorite.hidden = YES;
                    cell.btnUnfavorite.hidden = NO;
                }
                else
                {
                    cell.btnFavorite.hidden = NO;
                    cell.btnUnfavorite.hidden = YES;
                }
            }
            cell.btnCell.tag = indexPath.row;
            [cell.btnCell addTarget:self action:@selector(onTapCell:) forControlEvents:UIControlEventTouchUpInside];
        }
    }
    
    return cell;
    
}

- (void)getFavorites {
    [PFCloud callFunctionInBackground:@"getFavorites" withParameters:@{@"username": [PFUser currentUser].username} block:^(id object, NSError *error) {
        self.arrayCurrentFavorites = object;
        [self.mainTableView reloadData];
    }];
    
}

- (void)onTapCell:(UIButton *)sender {
    self.isActive = NO;
    //get user
    PFUser *user = self.arrayMain[sender.tag];
    BoardViewController *controller = [[BoardViewController alloc] init];
    controller.userName = user.username;
    [[PFUser currentUser] fetchInBackground]; //to reload favorites
    PFQuery *query = [PFUser query];
    [query whereKey:@"username" equalTo:user.username];
    query.cachePolicy = kPFCachePolicyCacheThenNetwork;
    if ([query hasCachedResult])
    {
        controller.user = user;
    }
    else
    {
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            controller.user = objects[0];
        }];
        controller.isTransitioningToBoard = YES;
        [controller loadUserInBackground];
    }
    
    [self.navigationController pushViewController:controller animated:YES];
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    self.navigationController.interactivePopGestureRecognizer.delegate = self;
    
    [self.tfSearchBar resignFirstResponder];
    
}

//this method is to remove table view's separator auto inset
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    //remove separator inset
    if ([cell respondsToSelector:@selector(setSeparatorInset:)])
    {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    //prevent cell from inheriting the table view's margin settings
    if ([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)])
    {
        [cell setPreservesSuperviewLayoutMargins:NO];
    }
    //set cell's layout margins
    if ([cell respondsToSelector:@selector(setLayoutMargins:)])
    {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
    
}

- (BOOL)connected {
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [reachability currentReachabilityStatus];
    
    return networkStatus != NotReachable;
    
}

- (UIImage *)imageWithColor:(UIColor *)color {
    CGRect rect = CGRectMake(0, 0, 300, 300);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
