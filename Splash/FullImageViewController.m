//
//  FullImageViewController.m
//  Splash
//
//  Created by Alec Kretch on 1/18/15.
//  Copyright (c) 2015 Alec Kretch. All rights reserved.
//

#import "FullImageViewController.h"

@interface FullImageViewController ()

@end

@implementation FullImageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setImage];
    if (![[PFUser currentUser].username isEqualToString:self.user.username])
    {
        [self addViewer];
    }
    [self showDate];
    
    self.view.backgroundColor = [UIColor blackColor];
    
}

- (void)setImage {    
    PFFile *tileFile = [self.user objectForKey:[NSString stringWithFormat:@"tile%d", self.tileNumber]];
    self.image = [UIImage imageWithData:tileFile.getData];
    self.imageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    self.imageView.image = self.image;
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:self.imageView];
    
}

- (void)addViewer {
    [PFCloud callFunctionInBackground:[NSString stringWithFormat:@"addViewer%d", self.tileNumber] withParameters:@{@"toUser": self.user.username, @"fromUser":[PFUser currentUser].username}];
    
}

- (void)showDate {
    UILabel *dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(6, self.view.frame.size.height-35, self.view.frame.size.width-12, 50)];
    
    PFObject *dateObject = [self.user objectForKey:[NSString stringWithFormat:@"dateTile%d", self.tileNumber]];
    NSDate *dateUpdated = (NSDate *)dateObject;
    NSString *dateUpdatedAgo = [[NSDate date] timeAgoSinceDate:dateUpdated numericDates:YES];
    
    dateLabel.text = [NSString stringWithFormat:@"added %@", dateUpdatedAgo].lowercaseString;

    dateLabel.font = [UIFont fontWithName:@"MyriadPro-Regular" size:14];
    dateLabel.textColor = [UIColor whiteColor];
    dateLabel.layer.shadowColor = [[UIColor blackColor] CGColor];
    dateLabel.layer.shadowOffset = CGSizeMake(0.0f, 1.0f);
    dateLabel.layer.shadowOpacity = 1.0f;
    dateLabel.layer.shadowRadius = 1.0f;
    [self.view addSubview:dateLabel];
    
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
