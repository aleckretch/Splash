//
//  ViewController.h
//  Splash
//
//  Created by Alec Kretch on 1/7/15.
//  Copyright (c) 2015 Alec Kretch. All rights reserved.
//

#import <Parse/Parse.h>
#import <UIKit/UIKit.h>
#import "Constants.h"
#import "MBProgressHUD.h"
#import "Reachability.h"
#import "TabBarController.h"

@interface ViewController : UIViewController <UIAlertViewDelegate, UITextFieldDelegate>

@property (retain, nonatomic) IBOutlet UIView *loginView;
@property (retain, nonatomic) IBOutlet UITextField *tfUsername;
@property (retain, nonatomic) IBOutlet UITextField *tfPassword;
@property (retain, nonatomic) IBOutlet UIButton *btnGo;

@property (assign, nonatomic) int keyboardHeight;
@property (retain, nonatomic) NSArray *arrayInitialFavorites;

@end

