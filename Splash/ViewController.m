//
//  ViewController.m
//  Splash
//
//  Created by Alec Kretch on 1/7/15.
//  Copyright (c) 2015 Alec Kretch. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = LIGHT_BLUE_COLOR;
    
    if ([PFUser currentUser]) //if the user is logged in
    {
        [self loginWithUsername:[PFUser currentUser].username isNew:NO];
    }
    else
    {
        //detect iphone type for keyboard size
        if ([[UIScreen mainScreen] bounds].size.height == 736) //iphone 6 plus
        {
            self.keyboardHeight = 226;
        }
        else
        {
            self.keyboardHeight = 216;
        }
        
        [self loginBlockDesign];
        
        //add logo
        UIImage *logo = [UIImage imageNamed:@"logo.png"];
        UIImageView *logoView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 143, 78)];
        logoView.center = CGPointMake(self.view.center.x, ((self.view.frame.size.height) - (self.view.frame.size.height-self.loginView.frame.origin.y))*.5); //middle of the blue
        [logoView setImage:logo];
        [self.view addSubview:logoView];
        
        //add notification to track keyboard press (for go button)
        NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
        [notificationCenter addObserver:self selector:@selector(textFieldText:) name:UITextFieldTextDidChangeNotification object:self.tfPassword];
    }
    [self setTextfieldValues];

}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (self.tfUsername.text.length > 0)
    {
        [self.tfPassword becomeFirstResponder];
    }
    else
    {
        [self.tfUsername becomeFirstResponder];
    }
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self viewDidLoad];
    
}

- (void)setTextfieldValues {
    //set text values
    NSString *splashUsername = [[NSUserDefaults standardUserDefaults] stringForKey:@"splashUsername"];
    if (splashUsername)
    {
        self.tfUsername.text = splashUsername;
    }
    else
    {
        self.tfUsername.text = @"";
    }
    self.tfPassword.text = @"";
    
}

- (void)loginBlockDesign {
    //create the white view
    int loginViewHeight = 79;
    self.loginView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height-self.keyboardHeight-loginViewHeight, self.view.frame.size.width, loginViewHeight)];
    [self.loginView setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:self.loginView];
    
    //add text
    UILabel *lblLogin = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.loginView.frame.size.width, self.loginView.frame.size.height)];
    lblLogin.font = LABEL_FONT;
    lblLogin.text = @"login or create account";
    lblLogin.textColor = LIGHT_GRAY_COLOR;
    lblLogin.textAlignment = NSTextAlignmentCenter;
    [self.loginView addSubview:lblLogin];
    
    CGSize textSize = [[lblLogin text] sizeWithAttributes:@{NSFontAttributeName:[lblLogin font]}];
    CGFloat lblLoginWidth = textSize.width;
    
    //create lines
    UIBezierPath *pathLineOne = [UIBezierPath bezierPath];
    [pathLineOne moveToPoint:CGPointMake(ENDS_SPACING, self.loginView.frame.size.height/2)];
    [pathLineOne addLineToPoint:CGPointMake(self.loginView.center.x-((lblLoginWidth+(ELEMENTS_SPACING*2))/2), self.loginView.frame.size.height/2)];
    
    CAShapeLayer *lineOne = [CAShapeLayer layer];
    lineOne.path = [pathLineOne CGPath];
    lineOne.strokeColor = [LIGHT_GRAY_COLOR CGColor];
    lineOne.lineWidth = LINE_THICKNESS;
    [self.loginView.layer addSublayer:lineOne];
    
    UIBezierPath *pathLineTwo = [UIBezierPath bezierPath];
    [pathLineTwo moveToPoint:CGPointMake(self.loginView.center.x+((lblLoginWidth+(ELEMENTS_SPACING*2))/2), self.loginView.frame.size.height/2)];
    [pathLineTwo addLineToPoint:CGPointMake(self.loginView.frame.size.width-ENDS_SPACING, self.loginView.frame.size.height/2)];
    
    CAShapeLayer *lineTwo = [CAShapeLayer layer];
    lineTwo.path = [pathLineTwo CGPath];
    lineTwo.strokeColor = [LIGHT_GRAY_COLOR CGColor];
    lineTwo.lineWidth = LINE_THICKNESS;
    [self.loginView.layer addSublayer:lineTwo];
    
    //add forward arrow/login (or create) button
    UIImage *forwardArrow = [UIImage imageNamed:@"btn_go_arrow.png"];
    self.btnGo = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.btnGo addTarget:self action:@selector(onTapGoButton) forControlEvents:UIControlEventTouchUpInside];
    [self.btnGo setImage:forwardArrow forState:UIControlStateNormal];
    [self.btnGo setTintColor:LIGHT_GRAY_COLOR];
    self.btnGo.frame = CGRectMake(0, 0, forwardArrow.size.width*2, forwardArrow.size.height*2);
    self.btnGo.center = CGPointMake(self.loginView.frame.size.width-(ENDS_SPACING + (forwardArrow.size.width/2)), 3*self.loginView.frame.size.height/4);
    [self.btnGo setHidden:YES];
    [self.loginView addSubview:self.btnGo];
    
    //create username textfield
    self.tfUsername = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width-(ENDS_SPACING*2), self.loginView.frame.size.height/2)];
    self.tfUsername.center = CGPointMake(self.loginView.frame.size.width/2, self.loginView.frame.size.height/4);
    self.tfUsername.textColor = DARK_GRAY_COLOR;
    self.tfUsername.placeholder = @"username";
    self.tfUsername.textAlignment = NSTextAlignmentLeft;
    self.tfUsername.keyboardType = UIKeyboardTypeAlphabet;
    self.tfUsername.returnKeyType = UIReturnKeyNext;
    self.tfUsername.autocorrectionType = UITextAutocorrectionTypeNo;
    self.tfUsername.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.tfUsername.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.tfUsername.delegate = self;
    [self.loginView addSubview:self.tfUsername];
    
    //create password textfield
    self.tfPassword = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width-((ENDS_SPACING*2)+(forwardArrow.size.width/2)+ELEMENTS_SPACING), self.loginView.frame.size.height/2)];
    self.tfPassword.center = CGPointMake((self.loginView.frame.size.width/2)-(((forwardArrow.size.width/2)+ELEMENTS_SPACING)/2), 3*self.loginView.frame.size.height/4);
    self.tfPassword.textColor = DARK_GRAY_COLOR;
    self.tfPassword.placeholder = @"password";
    self.tfPassword.secureTextEntry = YES;
    self.tfPassword.textAlignment = NSTextAlignmentLeft;
    self.tfPassword.keyboardType = UIKeyboardTypeAlphabet;
    self.tfPassword.returnKeyType = UIReturnKeyGo;
    self.tfPassword.autocorrectionType = UITextAutocorrectionTypeNo;
    self.tfPassword.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.tfPassword.delegate = self;
    [self.loginView addSubview:self.tfPassword];
    
}

- (BOOL)connected {
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [reachability currentReachabilityStatus];
    
    return networkStatus != NotReachable;
    
}

- (void)loginWithUsername:(NSString *)userName isNew:(BOOL)new
{
    //save username to device
    [[NSUserDefaults standardUserDefaults] setObject:self.tfUsername.text.lowercaseString forKey:@"splashUsername"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    //push notifications
    UIUserNotificationType userNotificationTypes = (UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound);
    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:userNotificationTypes categories:nil];
    [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    [[UIApplication sharedApplication] registerForRemoteNotifications];
    
    TabBarController *controller = [[TabBarController alloc] init];
    controller.titleString = [NSString stringWithFormat:@"@%@", userName]; //set initial tabbar title text
    controller.userName = [NSString stringWithFormat:@"%@", userName];
    [controller setTitleButton:YES];
    if (new)
    {
        [controller showWelcomeMessage];
    }
    
    UINavigationController *navigation = [[UINavigationController alloc] initWithRootViewController:controller];
    navigation.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [navigation setNavigationBarHidden:YES];
    
    [self presentViewController:navigation animated:YES completion:nil];
}

- (void)setInitialFavoritesWithUsernames:(NSArray *)usernames {
    for (int i=0; i<usernames.count; i++)
    {
        [PFCloud callFunction:@"addFavorite" withParameters:@{@"favoritedUsername": usernames[i], @"senderUsername": [PFUser currentUser].username}];
        [PFCloud callFunction:@"addFavoritedBy" withParameters:@{@"favoritedUsername": usernames[i], @"senderUsername": [PFUser currentUser].username}];
    }
    
}

- (void)onTapGoButton {
    if ([self connected])
    {
        //create the account
        if (self.tfUsername.text.length>3 && self.tfUsername.text.length<13)
        {
            if (self.tfPassword.text.length>5)
            {
                MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                hud.labelText = @"Loading";
                [PFUser logInWithUsernameInBackground:self.tfUsername.text.lowercaseString password:self.tfPassword.text block:^(PFUser *user, NSError *error)
                 {
                     if (user)
                     {
                         [MBProgressHUD hideHUDForView:self.view animated:YES];
                         [self loginWithUsername:self.tfUsername.text.lowercaseString isNew:NO];
                     }
                     else
                     {
                         [MBProgressHUD hideHUDForView:self.view animated:YES];
                         PFUser *user = [PFUser user];
                         user.username = self.tfUsername.text.lowercaseString;
                         user.password = self.tfPassword.text;
                         
                         [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
                          {
                              if (!error) //if no error, create the account and enter app
                              {
                                  [self loginWithUsername:user.username isNew:YES];
                                  //follow starter accounts
                                  [PFCloud callFunctionInBackground:@"initialFavorites" withParameters:@{} block:^(NSArray *response, NSError *error) {
                                      [self setInitialFavoritesWithUsernames:response];
                                  }];
                              }
                              else
                              {
                                  UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Uh, oh!" message:@"There was an issue processing this request. It is possible the username is taken or that you entered the incorrect password." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                                  [alert show];
                              }
                          }];
                     }
                 }];
            }
            else
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Uh, oh!" message:@"Your password must be at least 6 characters." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
            }
        }
        else
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Uh, oh!" message:@"Your username must be between 4-12 characters." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        }
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Uh, oh!" message:UNABLE_TO_CONNECT_MESSAGE delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.tfUsername)
    {
        [textField resignFirstResponder];
        [self.tfPassword becomeFirstResponder];
    }
    else if (textField == self.tfPassword)
    {
        [self onTapGoButton];
    }
    return YES;
    
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (textField == self.tfUsername)
    {
        if (string.length == 0)
        {
            return YES;
        }
        NSString *allowedCharacters = @"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789_";
        if ([allowedCharacters rangeOfString:string].location == NSNotFound)
        {
            return NO;
        }
        return YES;
    }
    return YES;
    
}

- (void)textFieldText:(id)notification {
    if (self.tfPassword.text.length != 0)
    {
        [self.btnGo setHidden:NO];
    }
    else
    {
        [self.btnGo setHidden:YES];
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
