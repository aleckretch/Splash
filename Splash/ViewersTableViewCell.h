//
//  ViewersTableViewCell.h
//  Splash
//
//  Created by Alec Kretch on 4/17/15.
//  Copyright (c) 2015 Alec Kretch. All rights reserved.
//

#import <Parse/Parse.h>
#import <UIKit/UIKit.h>
#import "Constants.h"

@interface ViewersTableViewCell : UITableViewCell

@property (retain, nonatomic) IBOutlet UIButton *btnCell;
@property (retain, nonatomic) IBOutlet UIButton *btnFavorite;
@property (retain, nonatomic) IBOutlet UIButton *btnUnfavorite;
@property (retain, nonatomic) IBOutlet UIImageView *proPicImageView;
@property (retain, nonatomic) IBOutlet UILabel *title;
@property (retain, nonatomic) IBOutlet UILabel *userName;

@end
