//
//  MainUITabBarController.m
//  TripCompass
//
//  Created by Eduardo Sasso on 12/2/13.
//  Copyright (c) 2013 Context Software. All rights reserved.
//

#import "MainUITabBarController.h"
#import "Reachability.h"
#import "AppDelegate.h"

@interface MainUITabBarController ()
@end

@implementation MainUITabBarController {
  AppDelegate *appDelegate;
  Reachability *reachability;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  
  appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];

  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityDidChange:) name:kReachabilityChangedNotification object:nil];

  [self updateTabBarItem];
  [self selectActiveTab];
}

- (void)selectActiveTab {
  int searchTab = 0;
  int favoritesTab = 1;
  
  self.selectedIndex = appDelegate.isOnline ? searchTab : favoritesTab;
}

- (void)updateTabBarItem {
  UITabBarItem* searchButton = [[self.tabBar items] objectAtIndex:0];
  searchButton.badgeValue = appDelegate.isOnline ? nil : @"!";
}

- (void)reachabilityDidChange:(NSNotification *)notification {
  [self updateTabBarItem];
}

@end
