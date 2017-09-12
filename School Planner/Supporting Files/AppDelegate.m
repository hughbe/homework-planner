//
//  AppDelegate.m
//  Homework Planner & Diary
//
//  Created by Hugh Bellamy on 13/01/2015.
//  Copyright (c) 2015 Hugh Bellamy. All rights reserved.
//

#import "AppDelegate.h"

#import "UIColor+Additions.h"

#import "BButton.h"
#import "HomeworkViewController.h"

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    UIColor *barTintColor = [[UIColor colorWithRed:103.0/255.0 green:130.0/255.0 blue:180.0/255.0 alpha:1.0] add_darkerColorWithValue:0.75];
    UIColor *foregroundColor = [UIColor whiteColor];

    [[UITabBar appearance] setTintColor:foregroundColor];
    
    [[UITabBar appearance]setBarTintColor:barTintColor];
    [[UINavigationBar appearance]setBarTintColor:barTintColor];
    [[UIToolbar appearance]setBarTintColor:barTintColor];
    [[UISearchBar appearance]setBarTintColor:barTintColor];
    
    [[UINavigationBar appearance]setTitleTextAttributes:@{NSForegroundColorAttributeName : foregroundColor}];
    
    [[BButton appearance]setButtonCornerRadius:@(0)];
    
    self.window.tintColor = foregroundColor;
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    [[UITextField appearance]setTintColor:[UIColor blackColor]];
    [[UITextView appearance]setTintColor:[UIColor blackColor]];
    
    [[UITabBar appearance] setBackgroundColor:[UIColor colorWithRed:(CGFloat) (15 / 255.0) green:(CGFloat) (85 / 255.0) blue:(CGFloat) (160 / 255.0) alpha:1.0]];
    return YES;
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    [[UIApplication sharedApplication]cancelLocalNotification:notification];
    NSString *ID = notification.userInfo[@"homework"];
    if(ID.length) {
        id root = self.window.rootViewController;
        if([root isKindOfClass:[UITabBarController class]]) {
            [root setSelectedIndex:0];
            
            id nav = [[root viewControllers] firstObject];
            if([nav isKindOfClass:[UINavigationController class]]) {
                id homeworkViewController = [[nav viewControllers] firstObject];
                if([homeworkViewController isKindOfClass:[HomeworkViewController class]]) {
                    [homeworkViewController setViewingID:ID];
                }
            }
        }
    }
}

@end
