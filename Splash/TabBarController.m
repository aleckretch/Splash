//
//  TabBarController.m
//  Splash
//
//  Created by Alec Kretch on 1/11/15.
//  Copyright (c) 2015 Alec Kretch. All rights reserved.
//

#import "TabBarController.h"

@interface TabBarController ()

@end

@implementation TabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.boardViewController = [[BoardViewController alloc] init];
    self.exploreViewController = [[ExploreViewController alloc] init];
    self.exploreViewNavigationController = [[UINavigationController alloc] initWithRootViewController:self.exploreViewController];
    [self.exploreViewNavigationController setNavigationBarHidden:YES];
    
    NSMutableArray *tabViewControllers = [[NSMutableArray alloc] init];
    [tabViewControllers addObject:self.boardViewController];
    [tabViewControllers addObject:self.exploreViewNavigationController];
    
    [self setViewControllers:tabViewControllers];
    self.boardViewController.tabBarItem = [[UITabBarItem alloc] initWithTitle:nil image:nil tag:0];
    self.boardViewController.tabBarItem.image = [[UIImage imageNamed:@"tabbtn_board.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    self.boardViewController.tabBarItem.selectedImage = [UIImage imageNamed:@"tabbtn_board_selected.png"];
    self.exploreViewNavigationController.tabBarItem = [[UITabBarItem alloc] initWithTitle:nil image:nil tag:1];
    self.exploreViewNavigationController.tabBarItem.image = [[UIImage imageNamed:@"tabbtn_explore.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    self.exploreViewNavigationController.tabBarItem.selectedImage = [UIImage imageNamed:@"tabbtn_explore_selected.png"];
    
    int btnDistanceFromEdge = ((self.view.frame.size.width/4)-13)-((self.view.frame.size.width/6)-13); //center of 1/3 (13 is half button size)
    
    self.boardViewController.tabBarItem.imageInsets = UIEdgeInsetsMake(5, -btnDistanceFromEdge, -5, btnDistanceFromEdge);
    self.exploreViewNavigationController.tabBarItem.imageInsets = UIEdgeInsetsMake(5, btnDistanceFromEdge, -5, -btnDistanceFromEdge);
        
    self.tabBar.tintColor = DARK_GRAY_COLOR;
    self.tabBar.translucent = NO;
    
    self.boardViewController.userName = [PFUser currentUser].username;
    
}

- (void)setTitle:(NSString *)title {
    if ([title isEqual:@"explore"])
    {
        self.titleString = title;
        [self setTitleButton:NO];
    }
    else
    {
        self.userName = title;
        self.titleString = [NSString stringWithFormat:@"@%@", self.userName];
        [self setTitleButton:YES];
        self.boardIsFavorited = [self checkIfBoardIsFavorited];
        if(self.boardIsFavorited)
        {
            [self favoriteBoardDesign];
        }
        else
        {
            [self unFavoriteBoardDesign];
        }
    }
    
}

- (void)setTitleButton:(BOOL)isButton {
    [self.btnTitle removeFromSuperview];
    CGRect titleFrame = CGRectMake(0, 0, (self.view.frame.size.width) - (self.view.frame.size.width/3) - (self.boardViewController.tabBarItem.image.size.width/2) - (self.exploreViewNavigationController.tabBarItem.image.size.width/2) - (ENDS_SPACING*2), self.tabBar.frame.size.height);
    self.btnTitle = [UIButton buttonWithType:UIButtonTypeCustom];
    self.btnTitle.frame = titleFrame;
    [self.btnTitle setTitle:self.titleString forState:UIControlStateNormal];
    self.btnTitle.titleLabel.font = [UIFont fontWithName:@"BebasNeue" size:22];
    self.btnTitle.center = CGPointMake(self.view.center.x, self.tabBar.frame.size.height/2);
    if (isButton)
    {
        if (self.boardIsFavorited)
        {
            [self favoriteBoardDesign];
        }
        else
        {
            [self unFavoriteBoardDesign];
        }
        [self.btnTitle addTarget:self action:@selector(onTapTitleButton:) forControlEvents:UIControlEventTouchUpInside];
        self.btnTitle.titleEdgeInsets = UIEdgeInsetsMake(0, -self.btnTitle.imageView.frame.size.width, 0, self.btnTitle.imageView.frame.size.width);
        self.btnTitle.imageEdgeInsets = UIEdgeInsetsMake(0, self.btnTitle.titleLabel.frame.size.width, 0, -self.btnTitle.titleLabel.frame.size.width);
    }
    else
    {
        [self.btnTitle setTitleColor:LIGHT_GRAY_COLOR forState:UIControlStateNormal];
    }
    [self.tabBar addSubview:self.btnTitle];
    
    //get user
    if ([self.user.username isEqualToString:self.userName])
    {
        PFQuery *query = [PFUser query];
        [query whereKey:@"username" equalTo:self.userName];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
         {
             if (!error)
             {
                 PFObject *foundObject = (PFObject *)objects[0];
                 self.user = (PFUser *)foundObject;
             }
         }];
    }
    
}

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item {
    if (item.tag == 0) //myboard
    {
        self.titleString = [NSString stringWithFormat:@"@%@", self.userName];
        [self setTitleButton:YES];
        self.exploreViewController.isActive = NO;
        [self.boardViewController.boardCollectionView reloadData];
        self.boardViewController.selectedTileNumber = 1;
    }
    else if (item.tag == 1) //explore
    {
        self.titleString = @"explore";
        [self setTitleButton:NO];
        if (self.exploreViewController.isActive)
        {
            [self.exploreViewController.mainTableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES]; //scroll the view to the top
        }
    }
    
}

- (BOOL)checkIfBoardIsFavorited {
    NSMutableArray *currentFavorites = [[PFUser currentUser] objectForKey:@"favorites"];
    if ([currentFavorites containsObject:self.userName])
    {
        return YES;
    }
    else
    {
        return NO;
    }
    
}

- (void)onTapTitleButton:(id)sender {
    if ([[PFUser currentUser].username isEqualToString:self.userName])
    {
        self.actionSheetSelfBoard = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Export my splash", @"Logout", nil];
        
        [self.actionSheetSelfBoard showInView:self.view];
    }
    else
    {
        if (self.boardIsFavorited)
        {
            self.actionSheetOtherBoard = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Unfavorite", @"Flag as inappropriate", nil];
        }
        else
        {
            self.actionSheetOtherBoard = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Favorite", @"Flag as inappropriate", nil];
        }
        
        [self.actionSheetOtherBoard showInView:self.view];
    }
    
}

- (void)actionSheet:(UIActionSheet *)actionSheet willDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (actionSheet == self.actionSheetSelfBoard)
    {
        if (buttonIndex == 0) //save to camera roll
        {
            UIImage *myBoardImage = [self.boardViewController squareBoardImage];
            UIImageWriteToSavedPhotosAlbum(myBoardImage, self, @selector(image:finishedSavingWithError:contextInfo:), nil);
        }
        if (buttonIndex == 1) //logout
        {
            [[NSUserDefaults standardUserDefaults] setObject:[PFUser currentUser].username forKey:@"splashUsername"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [PFUser logOut];
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }
    else if (actionSheet == self.actionSheetOtherBoard)
    {
        if (buttonIndex == 0) //favorite or unfavorite board
        {
            if (self.boardIsFavorited)
            {
                [self setUnFavorite];
            }
            else
            {
                [self setFavorite];
            }
        }
        else if (buttonIndex == 1) //flag
        {
            PFObject *object = [PFObject objectWithClassName:@"Flagged"];
            [object setObject:self.userName forKey:@"flaggedUser"];
            [object setObject:[PFUser currentUser].username forKey:@"flaggedBy"];
            [object saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
             {
                 if (!error)
                 {
                     UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success!" message:@"Thank you for flagging this board. We will review the board in a timely fashion and act accordingly." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                     [alert show];
                 }
                 else
                 {
                     UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Uh, oh!" message:UNABLE_TO_PROCESS_MESSAGE delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                     [alert show];
                 }
             }];
        }
    }
    
}

- (void)image:(UIImage *)image finishedSavingWithError:(NSError *) error contextInfo:(void *)contextInfo {
    if (error) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Uh, oh!" message:@"There was a problem saving your splash. Try again later." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success!" message:@"A square snapshot of your splash has been saved to your camera roll." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
    
}

- (void)setFavorite {
    [PFCloud callFunctionInBackground:@"addFavorite" withParameters:@{@"favoritedUsername": self.userName, @"senderUsername": [PFUser currentUser].username} block:^(id object, NSError *error) {
        if (!error)
        {
            [PFCloud callFunctionInBackground:@"addFavoritedBy" withParameters:@{@"favoritedUsername": self.userName, @"senderUsername": [PFUser currentUser].username} block:^(id object, NSError *error) {
                NSString *message = [NSString stringWithFormat:@"%@ favorited your splash page!", [PFUser currentUser].username];
                [PFCloud callFunctionInBackground:@"sendPushFavorited" withParameters:@{@"favoritedUsername": self.userName, @"senderUsername": [PFUser currentUser].username, @"message": message}];
            }];
            [self favoriteBoardDesign];

        }
    }];
    
}

- (void)setUnFavorite {
    [PFCloud callFunctionInBackground:@"removeFavorite" withParameters:@{@"favoritedUsername": self.userName, @"senderUsername": [PFUser currentUser].username} block:^(id object, NSError *error) {
        if (!error)
        {
            [PFCloud callFunctionInBackground:@"removeFavoritedBy" withParameters:@{@"favoritedUsername": self.userName, @"senderUsername": [PFUser currentUser].username}];
            [self unFavoriteBoardDesign];
        }
    }];
    
}

- (void)favoriteBoardDesign {
    self.boardIsFavorited = YES; //put this in setFavorite
    [self.btnTitle setTitleColor:LIGHT_GOLD_COLOR forState:UIControlStateNormal];
    [self.btnTitle setTitleColor:DARK_GOLD_COLOR forState:UIControlStateHighlighted];
    UIImage *goldTriangle = [UIImage imageNamed:@"btn_down_triangle_gold.png"];
    [self.btnTitle setImage:goldTriangle forState:UIControlStateNormal];
    
}

- (void)unFavoriteBoardDesign {
    self.boardIsFavorited = NO; //put this in setUnFavorite
    [self.btnTitle setTitleColor:LIGHT_GRAY_COLOR forState:UIControlStateNormal];
    [self.btnTitle setTitleColor:DARK_GRAY_COLOR forState:UIControlStateHighlighted];
    UIImage *triangle = [UIImage imageNamed:@"btn_down_triangle.png"];
    [self.btnTitle setImage:triangle forState:UIControlStateNormal];
    
}

- (void)showWelcomeMessage {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Welcome to splash!" message:@"Select 'Quick Start' to quickly fill your splash page with up to 9 images. Otherwise, tap tiles individually to fill them." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:@"Quick Start", nil];
    [alert show];
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1)
    {
        QBImagePickerController *imagePickerController = [[QBImagePickerController alloc] init];
        imagePickerController.delegate = self;
        imagePickerController.allowsMultipleSelection = YES;
        imagePickerController.maximumNumberOfSelection = 9;
        imagePickerController.mediaType = QBImagePickerMediaTypeImage;
        imagePickerController.showsNumberOfSelectedAssets = YES;
        imagePickerController.assetCollectionSubtypes = @[
                                                          @(PHAssetCollectionSubtypeSmartAlbumGeneric),
                                                          @(PHAssetCollectionSubtypeSmartAlbumUserLibrary), // Camera Roll
                                                          @(PHAssetCollectionSubtypeAlbumMyPhotoStream), // My Photo Stream
                                                          @(PHAssetCollectionSubtypeSmartAlbumFavorites), // Favorites
                                                          @(PHAssetCollectionSubtypeSmartAlbumPanoramas), // Panoramas
                                                          @(PHAssetCollectionSubtypeSmartAlbumBursts), // Bursts
                                                          ];
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
        [self presentViewController:imagePickerController animated:YES completion:nil];
    }
}

- (void)qb_imagePickerController:(QBImagePickerController *)imagePickerController didFinishPickingAssets:(NSArray *)assets {
    if ([self.boardViewController connected])
    {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:imagePickerController.view animated:YES];
        hud.labelText = @"Loading";
        int number = 0;
        for (PHAsset *asset in assets)
        {
            number++;
            [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:PHImageManagerMaximumSize contentMode:PHImageContentModeDefault options:nil resultHandler:^(UIImage *result, NSDictionary *info) {
                //resize image
                UIImage *resizedImage = [[UIImage alloc] init];
                CGFloat desiredRatio = 891/540;
                CGFloat pickedRatio = result.size.width / result.size.height;
                if (pickedRatio > desiredRatio) //image too wide
                {
                    CGFloat ratio = result.size.width / 540;
                    CGFloat newHeight = result.size.height / ratio;
                    resizedImage = [self.boardViewController resizeImage:result width:540 height:newHeight];
                }
                else
                {
                    CGFloat ratio = result.size.height / 891;
                    CGFloat newWidth = result.size.width / ratio;
                    resizedImage = [self.boardViewController resizeImage:result width:newWidth height:891];
                }
                //save the image
                NSData *imageData = UIImageJPEGRepresentation(resizedImage, 0.2);
                PFFile *imageFile = [PFFile fileWithData:imageData];
                
                [imageFile saveInBackground];
                
                self.user = [PFUser currentUser];
                [self.user setObject:imageFile forKey:[NSString stringWithFormat:@"tile%d", number]];
                
                //save update date
                NSDate *currDate = [NSDate date];
                [self.user setObject:currDate forKey:@"lastBoardUpdate"];
                [self.user setObject:currDate forKey:[NSString stringWithFormat:@"dateTile%d", number]];
                
                //save objects
                [self.user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
                 {
                     if (!error && assets.count == number)
                     {
                         [MBProgressHUD hideHUDForView:imagePickerController.view animated:YES];
                         [self.boardViewController.boardCollectionView reloadData];
                         self.boardViewController.selectedTileNumber = 1;
                         [self dismissModalView];
                         UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success!" message:@"Tap and hold to view a tile OR tap to view the options for it." delegate: nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                         [alert show];
                     }
                 }];
                
            }];
            
        }
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Uh, oh!" message:UNABLE_TO_CONNECT_MESSAGE delegate: nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
    
}

- (void)qb_imagePickerControllerDidCancel:(QBImagePickerController *)imagePickerController {
    [self dismissModalView];
    
}

- (void)dismissModalView {
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [self dismissViewControllerAnimated:YES completion:nil];
    
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
