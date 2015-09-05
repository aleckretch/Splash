//
//  UserTableViewCell.m
//  Splash
//
//  Created by Alec Kretch on 1/30/15.
//  Copyright (c) 2015 Alec Kretch. All rights reserved.
//

#import "UserTableViewCell.h"

@implementation UserTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        //set content view frame
        self.contentView.frame = CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width-(ENDS_SPACING*2), 52);
        
        //add button to background
        self.btnCell = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [self.btnCell setFrame:CGRectMake(0, 0, self.contentView.frame.size.width*2, 52)];
        [self.btnCell setBackgroundImage:[self imageWithColor:LIGHT_GRAY_COLOR] forState:UIControlStateHighlighted];
        self.btnCell.clipsToBounds = YES;
        self.btnCell.exclusiveTouch = YES;
        [self.contentView addSubview:self.btnCell];
        //add propic
        int proPicInsets = 6;
        self.proPicImageView = [[UIImageView alloc] initWithFrame:CGRectMake(proPicInsets, proPicInsets, 52-(proPicInsets*2), 52-(proPicInsets*2))];
        self.proPicImageView.backgroundColor = LIGHT_GRAY_COLOR; //for while loading or if no pro pic
        self.proPicImageView.contentMode = UIViewContentModeScaleAspectFill;
        self.proPicImageView.layer.cornerRadius = self.proPicImageView.frame.size.height/2;
        self.proPicImageView.clipsToBounds = YES;
        [self.contentView addSubview:self.proPicImageView];
        //add username label
        int textSpacing = 7;
        CGSize userNameTextSize = [@"text" sizeWithAttributes:@{NSFontAttributeName:USER_CELL_FONT}];
        CGFloat userNameHeight = userNameTextSize.height;
        self.userName = [[UILabel alloc] initWithFrame:CGRectMake(self.proPicImageView.frame.origin.x+self.proPicImageView.frame.size.width+textSpacing, proPicInsets+2, 300, userNameHeight)];
        self.userName.font = USER_CELL_FONT;
        self.userName.textColor = LIGHT_GRAY_COLOR;
        [self.contentView addSubview:self.userName];
        //add date label
        CGSize timeStampTextSize = [@"text" sizeWithAttributes:@{NSFontAttributeName:TIMESTAMP_CELL_FONT}];
        CGFloat timeStampHeight = timeStampTextSize.height;
        self.timeStamp = [[UILabel alloc] initWithFrame:CGRectMake(self.proPicImageView.frame.origin.x+self.proPicImageView.frame.size.width+textSpacing, self.proPicImageView.frame.size.height-proPicInsets-((timeStampHeight-4)/2), 300, timeStampHeight)]; //-4 is for more accurate precision
        self.timeStamp.font = TIMESTAMP_CELL_FONT;
        self.timeStamp.textColor = LIGHT_GRAY_COLOR;
        [self.contentView addSubview:self.timeStamp];
        //add favorite button
        self.btnFavorite = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        self.btnFavorite.tintColor = LIGHT_GOLD_COLOR;
        [self.btnFavorite setImage:[UIImage imageNamed:@"btn_favorite.png"] forState:UIControlStateNormal];
        [self.btnFavorite addTarget:self action:@selector(onTapFavoriteButton) forControlEvents:UIControlEventTouchUpInside];
        self.btnFavorite.frame = CGRectMake(0, 0, self.btnFavorite.imageView.image.size.width, self.btnFavorite.imageView.image.size.height);
        self.btnFavorite.center = CGPointMake(self.contentView.frame.size.width-44, 26);
        [self.contentView addSubview:self.btnFavorite];
        //add unfavorite button
        self.btnUnfavorite = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        self.btnUnfavorite.tintColor = LIGHT_GOLD_COLOR;
        [self.btnUnfavorite setImage:[UIImage imageNamed:@"btn_unfavorite.png"] forState:UIControlStateNormal];
        [self.btnUnfavorite addTarget:self action:@selector(onTapUnfavoriteButton) forControlEvents:UIControlEventTouchUpInside];
        self.btnUnfavorite.frame = CGRectMake(0, 0, self.btnUnfavorite.imageView.image.size.width, self.btnUnfavorite.imageView.image.size.height);
        self.btnUnfavorite.center = CGPointMake(self.contentView.frame.size.width-44, 26);
        [self.contentView addSubview:self.btnUnfavorite];
        //add main body text for other cells
        self.title = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.contentView.superview.bounds.size.width, self.contentView.frame.size.height)]; //30 to center
        self.title.textColor = DARK_GRAY_COLOR;
        [self.contentView addSubview:self.title];
        //add button main body text for other cells
        self.btnTitle = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [self.btnTitle setTitleColor:LIGHT_BLUE_COLOR forState:UIControlStateNormal];
        [self.btnTitle.titleLabel setFont:[UIFont fontWithName:@"MyriadPro-Regular" size:20]];
        self.btnTitle.frame = self.title.frame;
        [self.contentView addSubview:self.btnTitle];
    }
    return self;
    
}

- (void)onTapFavoriteButton {
    [PFCloud callFunctionInBackground:@"addFavorite" withParameters:@{@"favoritedUsername": self.userName.text, @"senderUsername": [PFUser currentUser].username} block:^(id object, NSError *error) {
        if (!error)
        {
            [PFCloud callFunctionInBackground:@"addFavoritedBy" withParameters:@{@"favoritedUsername": self.userName.text, @"senderUsername": [PFUser currentUser].username} block:^(id object, NSError *error) {
                NSString *message = [NSString stringWithFormat:@"%@ favorited your splash page!", [PFUser currentUser].username];
                [PFCloud callFunctionInBackground:@"sendPushFavorited" withParameters:@{@"favoritedUsername": self.userName.text, @"senderUsername": [PFUser currentUser].username, @"message": message}];
            }];
            self.btnFavorite.hidden = YES;
            self.btnUnfavorite.hidden = NO;
        }
    }];
    
}

- (void)onTapUnfavoriteButton {
    [PFCloud callFunctionInBackground:@"removeFavorite" withParameters:@{@"favoritedUsername": self.userName.text, @"senderUsername": [PFUser currentUser].username} block:^(id object, NSError *error) {
        if (!error)
        {
            [PFCloud callFunctionInBackground:@"removeFavoritedBy" withParameters:@{@"favoritedUsername": self.userName.text, @"senderUsername": [PFUser currentUser].username}];
            self.btnFavorite.hidden = NO;
            self.btnUnfavorite.hidden = YES;
        }
    }];
    
}

- (UIImage *)imageWithColor:(UIColor *)color {
    CGRect rect = self.btnCell.frame;
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
    
}

- (void)layoutSubViews
{
    [super layoutSubviews];
    // layout stuff relative to the size of the cell.
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

@end
