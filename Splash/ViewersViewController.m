//
//  ViewersViewController.m
//  Splash
//
//  Created by Alec Kretch on 4/17/15.
//  Copyright (c) 2015 Alec Kretch. All rights reserved.
//

#import "ViewersViewController.h"

@interface ViewersViewController ()

@end

@implementation ViewersViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
    self.view.backgroundColor = [UIColor whiteColor];
    self.doneLoading = NO;
    [self setNavBar];
    [self getViewers];
    [self setMainTable];
    // Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self getFavorites];
    
}

- (void)setNavBar
{
    //opaque navbar
    self.navigationController.navigationBar.translucent = NO;
    
    //done button
    UIBarButtonItem *doneBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done)];
    self.navigationItem.rightBarButtonItem = doneBarButtonItem;
}

- (void)setMainTable {
    self.view.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height-NAV_BAR_HEIGHT-STATUS_BAR_HEIGHT);
    self.mainTableView = [[UITableView alloc] initWithFrame:self.view.frame];
    [self.mainTableView registerClass:[ViewersTableViewCell class] forCellReuseIdentifier:@"ViewersCell"];
    self.mainTableView.delegate = self;
    self.mainTableView.dataSource = self;
    self.mainTableView.backgroundColor = [UIColor clearColor];
    self.mainTableView.rowHeight = 52;
    self.mainTableView.separatorColor = LIGHT_GRAY_COLOR;
    self.mainTableView.allowsSelection = NO;
    self.mainTableView.separatorInset = UIEdgeInsetsZero;
    [self.view addSubview:self.mainTableView];
    
}

- (void)done {
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

- (void)getViewers {
    [PFCloud callFunctionInBackground:[NSString stringWithFormat:@"getViewers%d", self.tileNumber] withParameters:@{@"username": self.userName} block:^(id object, NSError *error) {
        self.arrayViewersUsernames = object;
        self.doneLoading = YES;
        //set navbar title
        if (self.arrayViewersUsernames.count == 1)
        {
            self.navigationItem.title = @"1 View";
        }
        else
        {
            self.navigationItem.title = [NSString stringWithFormat:@"%d Views", (int)self.arrayViewersUsernames.count];
        }
        if (self.arrayViewersUsernames.count >> 0)
        {
            [self loadViewers];
        }
        else
        {
            [self.mainTableView reloadData];
        }
    }];
    
}

- (void)loadViewers {
    NSMutableArray *arrayViewers = [NSMutableArray array];
    for (int count = (int)self.arrayViewersUsernames.count-1; count >= 0; count--)
    {
        PFQuery *query = [PFUser query];
        [query whereKey:@"username" equalTo:[self.arrayViewersUsernames objectAtIndex:count]];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
         {
             if (!error)
             {
                 PFObject *foundObject = (PFObject *)objects[0];
                 PFUser *viewerUser = (PFUser *)foundObject;
                 [arrayViewers addObject:viewerUser];
                 NSArray *sortedArrayViewers = [self sortUsersByView:arrayViewers];
                 if (sortedArrayViewers.count == self.arrayViewersUsernames.count)
                 {
                     self.arrayMain = sortedArrayViewers;
                     [self.mainTableView reloadData];
                 }
             }
         }];
    }
    
}

- (NSArray *)sortUsersByView:(NSMutableArray *)array {
    NSMutableArray *sortedArray = [[NSMutableArray alloc] initWithObjects:nil];
    for (int i=(int)self.arrayViewersUsernames.count-1; i >= 0; i--)
    {
        NSString *usernameAtIndex = [self.arrayViewersUsernames objectAtIndex:i];
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.arrayViewersUsernames.count == 0 && self.doneLoading)
    {
        return 1;
    }
    else
    {
        return self.arrayViewersUsernames.count;
    }

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ViewersTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ViewersCell" forIndexPath:indexPath];
    if (cell == nil) {
        cell = [[ViewersTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ViewersCell"];
    }
    if (self.arrayViewersUsernames.count == 0 && self.doneLoading)
    {
        if (indexPath.row == 0)
        {
            cell.title.center = CGPointMake(self.mainTableView.frame.size.width/2, self.mainTableView.rowHeight/2);
            cell.title.textAlignment = NSTextAlignmentCenter;
            cell.title.text = @"No viewers yet.";
            [cell.contentView addSubview:cell.title];
            [cell.proPicImageView removeFromSuperview];
            [cell.btnCell removeFromSuperview];
            [cell.btnFavorite removeFromSuperview];
            [cell.btnUnfavorite removeFromSuperview];
            [cell.userName removeFromSuperview];
        }
    }
    else
    {
        [cell.title removeFromSuperview];
        [cell.contentView addSubview:cell.proPicImageView];
        [cell.contentView addSubview:cell.btnCell];
        [cell.contentView addSubview:cell.btnFavorite];
        [cell.contentView addSubview:cell.btnUnfavorite];
        [cell.contentView addSubview:cell.userName];
        
        PFUser *user = [self.arrayMain objectAtIndex:indexPath.row];
        PFFile *tileFile = [user objectForKey:@"tile5"];
        UIImage *imageAtPath = [UIImage imageWithData:tileFile.getData];
        
        if (!imageAtPath)
        {
            imageAtPath = [UIImage imageNamed:@"img_blank_tile_5.png"];
        }
        cell.proPicImageView.image = imageAtPath;
        cell.userName.text = user.username;
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
        
        cell.btnCell.tag = indexPath.row;
        [cell.btnCell addTarget:self action:@selector(onTapCell:) forControlEvents:UIControlEventTouchUpInside];
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
    //get user
    PFUser *user = self.arrayMain[sender.tag];
    BoardViewController *controller = [[BoardViewController alloc] init];
    controller.userName = user.username;
    //controller.user = user;
    controller.navigationItem.title = user.username;
    controller.viewersBoard = YES;
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
    
    UIBarButtonItem *doneBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done)];
    controller.navigationItem.rightBarButtonItem = doneBarButtonItem;
    
    [self.navigationController pushViewController:controller animated:YES];
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    self.navigationController.interactivePopGestureRecognizer.delegate = self;
        
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
