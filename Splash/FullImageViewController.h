//
//  FullImageViewController.h
//  Splash
//
//  Created by Alec Kretch on 1/18/15.
//  Copyright (c) 2015 Alec Kretch. All rights reserved.
//

#import <Parse/Parse.h>
#import <UIKit/UIKit.h>
#import "DateTools.h"

@interface FullImageViewController : UIViewController

@property (retain, nonatomic) IBOutlet PFUser *user;
@property (retain, nonatomic) IBOutlet UIImage *image;
@property (retain, nonatomic) IBOutlet UIImageView *imageView;

@property (assign, nonatomic) int tileNumber;

@end
