//
//  BoardViewController.m
//  Splash
//
//  Created by Alec Kretch on 1/8/15.
//  Copyright (c) 2015 Alec Kretch. All rights reserved.
//

#import "BoardViewController.h"

@interface BoardViewController ()

@end

@implementation BoardViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = LIGHT_BLUE_COLOR;
    [self mainAreaCollectionViewSetup];
    if (!self.isTransitioningToBoard)
    {
        self.arrayBoardImages = [self arrayBoardImages];
        self.selectedTileNumber = 1;
        if (!self.user)
        {
            self.user = [PFUser currentUser];
        }
    }
    
    //initialize image picker
    self.imagePickerController = [[FixedStatusBarImagePickerViewController alloc] init];
    self.imagePickerController.delegate = self;
    self.imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    //in case of home button tap(s)
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeFullImageLayer) name:UIApplicationDidBecomeActiveNotification object:nil];
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.tabBarController setTitle:self.userName];
    
}

- (void)viewDidDisappear:(BOOL)animated {
    self.viewersBoard = NO;
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tabBarController setTitle:self.userName];
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.tabBarController setTitle:@"explore"];
    
}

- (void)loadUserInBackground {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Loading";
    [PFCloud callFunctionInBackground:@"getUser" withParameters:@{@"username": self.userName} block:^(id object, NSError *error) {
        self.user = object;
        self.arrayBoardImages = [self arrayBoardImages];
        [self.boardCollectionView reloadData];
        self.selectedTileNumber = 1;
        self.isTransitioningToBoard = NO;
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        BOOL hasViewedASplash = [[NSUserDefaults standardUserDefaults] boolForKey:@"hasViewedASplash"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        if (!hasViewedASplash)
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Tip!" message:@"Tap and hold to view a tile." delegate: nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"hasViewedASplash"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    }];
    
}

- (void)removeFullImageLayer {
    [self.fullImageViewController viewDidDisappear:YES];
    [self.fullImageViewController.view removeFromSuperview];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    self.tabBarController.tabBar.hidden = NO;
    self.viewingImage = NO;
    [self.lblTapAndHold removeFromSuperview];
    self.view.backgroundColor = LIGHT_BLUE_COLOR;
    
}

- (void)mainAreaCollectionViewSetup {
    //establish layout
    if (!self.viewersBoard)
    {
        self.view.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height-TAB_BAR_HEIGHT-STATUS_BAR_HEIGHT);
    }
    else
    {
        self.view.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height-NAV_BAR_HEIGHT-STATUS_BAR_HEIGHT);
    }
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake(ceil(self.view.frame.size.width/3), (ceil(self.view.frame.size.height)/3));
    CGRect boardFrame = CGRectMake(0, 0, layout.itemSize.width*3, (layout.itemSize.height*3));
    layout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
    layout.minimumInteritemSpacing = 0.0f;
    layout.minimumLineSpacing = 0.0f;
    
    //create view
    self.boardCollectionView = [[UICollectionView alloc] initWithFrame:boardFrame collectionViewLayout:layout];
    self.boardCollectionView.center = self.view.center;
    [self.boardCollectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"Cell"];
    self.boardCollectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    self.boardCollectionView.delegate = self;
    self.boardCollectionView.dataSource = self;
    self.boardCollectionView.backgroundColor = [UIColor clearColor];
    [self.boardCollectionView setScrollEnabled:NO];
    [self.view addSubview:self.boardCollectionView];
    
}

- (BOOL)connected {
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [reachability currentReachabilityStatus];
    
    return networkStatus != NotReachable;
    
}

- (NSMutableArray *)arrayBoardImages {
    NSMutableArray *arrayBoardImages = [NSMutableArray array];
    NSMutableArray *emptyIndexes = [NSMutableArray array];
    for (int count = 1; count < 10; count++)
    {
        PFFile *tileFile = [self.user objectForKey:[NSString stringWithFormat:@"tile%d", count]];
        UIImage *imageAtPath = [UIImage imageWithData:tileFile.getData];
        if (imageAtPath != nil)
        {
            [arrayBoardImages addObject:imageAtPath];
        }
        else
        {
            UIImage *tileImage = [UIImage imageNamed:[NSString stringWithFormat:@"img_blank_tile_%d.png", count]];
            [arrayBoardImages addObject:tileImage];
            [emptyIndexes addObject:[NSNumber numberWithInt:count]];
        }
    }
    
    self.arrayIndexOfEmptyTiles = emptyIndexes;
    return arrayBoardImages;
    
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 9;
    
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    //create tile buttons
    UIButton *tile = [UIButton buttonWithType:UIButtonTypeCustom];
    tile.frame = CGRectMake(0, 0, cell.frame.size.width, cell.frame.size.height);
    [tile setImage:[self.arrayBoardImages objectAtIndex:indexPath.row] forState:UIControlStateNormal];
    tile.exclusiveTouch = YES;
    if ([self.arrayIndexOfEmptyTiles containsObject:[NSNumber numberWithInteger:self.selectedTileNumber]]) //if empty tile
    {
        if ([[PFUser currentUser].username isEqualToString:self.userName])
        {
            [tile addTarget:self action:@selector(onTapEmptyTile:) forControlEvents:UIControlEventTouchUpInside];
        }
        else
        {
            [tile setEnabled:NO];
            [tile setImage:[self.arrayBoardImages objectAtIndex:indexPath.row] forState:UIControlStateDisabled];
        }
        tile.imageView.contentMode = UIViewContentModeScaleToFill;
    }
    else
    {
        tile.imageView.contentMode = UIViewContentModeScaleAspectFill;
        UILongPressGestureRecognizer *hold = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(onHoldTile:)];
        hold.minimumPressDuration = .25;
        [tile addGestureRecognizer:hold];
        if ([[PFUser currentUser].username isEqualToString:self.userName])
        {
            [tile addTarget:self action:@selector(onTapTile:) forControlEvents:UIControlEventTouchUpInside];
        }
        else
        {
            if (!self.viewersBoard)
            {
                [tile addTarget:self action:@selector(onTapOtherTile) forControlEvents:UIControlEventTouchUpInside];
            }
        }
    }
    tile.tag = self.selectedTileNumber; //tag the buttons based on image position in array
    
    self.selectedTileNumber++;
    
    //add tile button to cell
    [cell addSubview:tile];
    
    return cell;
    
}

- (void)onTapTile:(UIButton *)sender {
    self.selectedTileNumber = sender.tag;
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"See viewers", @"Change tile", nil];
    
    [actionSheet showInView:self.view];
    
}

- (void)onTapEmptyTile:(UIButton *)sender {
    self.selectedTileNumber = sender.tag;
    [self uploadImage];
    
}

- (void)onTapOtherTile {
    if ([UIApplication sharedApplication].isStatusBarHidden == NO)
    {
        [[UIApplication sharedApplication] setStatusBarHidden:YES];
        self.view.backgroundColor = LIGHT_RED_COLOR;
        
        self.lblTapAndHold = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 20)];
        self.lblTapAndHold.text = @"(tap and hold to view a tile)";
        self.lblTapAndHold.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:14];
        self.lblTapAndHold.textColor = [UIColor whiteColor];
        self.lblTapAndHold.textAlignment = NSTextAlignmentCenter;
        [self.view addSubview:self.lblTapAndHold];
        
        [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(returnStatusBar) userInfo:nil repeats:NO];
    }
    
}

- (void)returnStatusBar {
    if (!self.viewingImage)
    {
        [[UIApplication sharedApplication] setStatusBarHidden:NO];
    }
    [self.lblTapAndHold removeFromSuperview];
    self.view.backgroundColor = LIGHT_BLUE_COLOR;
    
}

- (void)onHoldTile:(UILongPressGestureRecognizer *)gesture {
    [self viewFullImageWithGesture:gesture];
    
}

- (void)viewFullImageWithGesture:(UILongPressGestureRecognizer *)gesture {
    if(gesture.state == UIGestureRecognizerStateEnded)
    {
        [self removeFullImageLayer];
    }
    else
    {
        if (!self.viewingImage)
        {
            self.selectedTileNumber = gesture.view.tag;
            [self viewImageWithFileNumber:(int)self.selectedTileNumber];
        }
    }
    
}

- (void)viewImageWithFileNumber:(int)number {
    self.fullImageViewController = [[FullImageViewController alloc] init];
    self.fullImageViewController.tileNumber = number;
    self.fullImageViewController.user = self.user;
    [self.navigationController.view.superview addSubview:self.fullImageViewController.view];
    self.tabBarController.tabBar.hidden = YES;
    self.viewingImage = YES;
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    
}

- (void)actionSheet:(UIActionSheet *)actionSheet willDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) //see viewers
    {
        ViewersViewController *viewersViewController = [[ViewersViewController alloc] init];
        viewersViewController.tileNumber = (int)self.selectedTileNumber;
        viewersViewController.userName = self.userName;
        UINavigationController *viewersViewNavigationController = [[UINavigationController alloc] initWithRootViewController:viewersViewController];
        [self presentViewController:viewersViewNavigationController animated:YES completion:nil];
    }
    else if (buttonIndex == 1) //change tile
    {
        [self uploadImage];
    }
    
}

- (void)uploadImage {
    [self presentViewController:self.imagePickerController animated:YES completion:nil];
    
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    if ([self connected])
    {
        int updatingTile = (int)self.selectedTileNumber;
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:picker.view animated:YES];
        hud.labelText = @"Loading";
        UIImage *pickedImage = [info objectForKey:UIImagePickerControllerOriginalImage];
        //resize image
        UIImage *resizedImage = [[UIImage alloc] init];
        CGFloat desiredRatio = 891/540;
        CGFloat pickedRatio = pickedImage.size.width / pickedImage.size.height;
        if (pickedRatio > desiredRatio) //image too wide
        {
            CGFloat ratio = pickedImage.size.width / 540;
            CGFloat newHeight = pickedImage.size.height / ratio;
            resizedImage = [self resizeImage:pickedImage width:540 height:newHeight];
        }
        else
        {
            CGFloat ratio = pickedImage.size.height / 891;
            CGFloat newWidth = pickedImage.size.width / ratio;
            resizedImage = [self resizeImage:pickedImage width:newWidth height:891];
        }
        
        //save the image
        NSData *imageData = UIImageJPEGRepresentation(resizedImage, 0.2);
        PFFile *imageFile = [PFFile fileWithData:imageData];
        
        [imageFile saveInBackground];
        
        self.user = [PFUser currentUser];
        [self.user setObject:imageFile forKey:[NSString stringWithFormat:@"tile%d", updatingTile]];
        
        //save update date
        NSDate *currDate = [NSDate date];
        [self.user setObject:currDate forKey:@"lastBoardUpdate"];
        [self.user setObject:currDate forKey:[NSString stringWithFormat:@"dateTile%d", updatingTile]];
        
        //save objects
        [self.user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
         {
             [MBProgressHUD hideHUDForView:picker.view animated:YES];
             if (error)
             {
                 UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Uh, oh!" message:UNABLE_TO_PROCESS_MESSAGE delegate: nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                 [alert show];
             }
             else
             {
                 UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success!" message:@"Tap and hold to view your tile OR tap to view the options for it." delegate: nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                 [alert show];
                 [self resetViewersOfTile:updatingTile];
             }
         }];
        [self.boardCollectionView reloadData];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Uh, oh!" message:UNABLE_TO_CONNECT_MESSAGE delegate: nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
    self.selectedTileNumber = 1;
    
}

- (UIImage *)resizeImage:(UIImage *)image width:(CGFloat)width height:(CGFloat)height {
    UIImage *resizedImage;
    CGSize size = CGSizeMake(width, height);
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0f);
    [image drawInRect:CGRectMake(0, 0, width, height)];
    resizedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return resizedImage;
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

- (void)resetViewersOfTile:(int)tileNumber {
    [self.user removeObjectForKey:[NSString stringWithFormat:@"viewersTile%d", tileNumber]];
    [self.user saveInBackground];
    
}

- (UIImage *)squareBoardImage {
    self.selectedTileNumber = 1;
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake(150, 150);
    CGRect boardFrame = CGRectMake(0, 0, layout.itemSize.width*3, (layout.itemSize.height*3));
    layout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
    layout.minimumInteritemSpacing = 0.0f;
    layout.minimumLineSpacing = 0.0f;
    
    //create view
    UICollectionView *boardCollectionViewCopy = [[UICollectionView alloc] initWithFrame:boardFrame collectionViewLayout:layout];
    [boardCollectionViewCopy registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"Cell"];
    boardCollectionViewCopy.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    boardCollectionViewCopy.delegate = self;
    boardCollectionViewCopy.dataSource = self;
    boardCollectionViewCopy.backgroundColor = [UIColor whiteColor];
    
    UIView *boardCopyView = [[UIView alloc] initWithFrame:boardCollectionViewCopy.frame];
    [boardCopyView addSubview:boardCollectionViewCopy];
    
    UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, boardCopyView.frame.size.height-40, boardCollectionViewCopy.frame.size.width, 50)];
    textLabel.text = [NSString stringWithFormat:@"splash: @%@", self.user.username.lowercaseString];
    textLabel.font = SAVED_BOARD_FONT;
    textLabel.textColor = [UIColor whiteColor];
    textLabel.layer.shadowColor = [[UIColor blackColor] CGColor];
    textLabel.layer.shadowOffset = CGSizeMake(0.0f, 1.0f);
    textLabel.layer.shadowOpacity = 1.0f;
    textLabel.layer.shadowRadius = 1.0f;
    [boardCopyView addSubview:textLabel];
    
    CGRect rect = boardCopyView.frame;
    
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, [UIScreen mainScreen].scale);
    [boardCopyView drawViewHierarchyInRect:boardCopyView.frame afterScreenUpdates:YES];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    self.selectedTileNumber = 1;
    
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
