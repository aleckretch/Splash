//
//  UserTableViewCell.h
//  Splash
//
//  Created by Alec Kretch on 1/30/15.
//  Copyright (c) 2015 Alec Kretch. All rights reserved.
//

#import <Parse/Parse.h>
#import <UIKit/UIKit.h>
#import "Constants.h"

@interface UserTableViewCell : UITableViewCell

@property (retain, nonatomic) IBOutlet UIButton *btnCell;
@property (retain, nonatomic) IBOutlet UIButton *btnFavorite;
@property (retain, nonatomic) IBOutlet UIButton *btnTitle;
@property (retain, nonatomic) IBOutlet UIButton *btnUnfavorite;
@property (retain, nonatomic) IBOutlet UIImageView *proPicImageView;
@property (retain, nonatomic) IBOutlet UILabel *timeStamp;
@property (retain, nonatomic) IBOutlet UILabel *title;
@property (retain, nonatomic) IBOutlet UILabel *userName;

@end
