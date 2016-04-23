//
//  Utility.m
//  EmployeeDirectory
//
//  Created by Naveen on 4/21/16.
//  Copyright © 2016 Christophe Coenraets. All rights reserved.
//

#import "Utility.h"

@implementation Utility

+ (id)sharedManager {
    static Utility *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
    });
    return sharedMyManager;
}


-(void)showLoadingScreen
{
    self.vw = [[UIView alloc] initWithFrame:CGRectMake([Utility screenSize].size.width/2-50, [Utility screenSize].size.height/2-100, 100, 100)];
    self.vw.backgroundColor = [UIColor lightGrayColor];
    self.vw.layer.cornerRadius = 16.0f;
    self.vw.layer.borderWidth = 5.0f;
    self.vw.layer.borderColor = [UIColor blackColor].CGColor;
    
    
    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [indicator setFrame:CGRectMake(self.vw.frame.size.width/2-18.5 , self.vw.frame.size.height/2-18.5, indicator.frame.size.width , indicator.frame.size.height)];
    [indicator startAnimating];
    
    UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(self.vw.frame.size.width/2-30 , self.vw.frame.size.height/2+20, 100 , 20)];
    [lbl setTextColor:[UIColor blackColor]];
    [lbl setText:@"Loading..."];
    
    [self.vw addSubview:indicator];
    [self.vw addSubview:lbl];
    
    UINavigationController *nvc = (UINavigationController*)[[UIApplication sharedApplication] keyWindow].rootViewController;
    [nvc.topViewController.view addSubview:self.vw];
}

+(CGRect)screenSize
{
    return [[UIScreen mainScreen]bounds];
}

-(void)removeLoadingScreen
{
    [self.vw removeFromSuperview];
}
@end
