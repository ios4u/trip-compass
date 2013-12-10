//
//  GAUITableViewController.m
//  TripCompass
//
//  Created by Eduardo Sasso on 12/10/13.
//  Copyright (c) 2013 Context Software. All rights reserved.
//

#import "GAUITableViewController.h"
#import "GAI.h"
#import "GAIDictionaryBuilder.h"
#import "GAIFields.h"

@interface GAUITableViewController ()

@end

@implementation GAUITableViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  
  [self trackGoogleAnalytics];
}

- (void) trackGoogleAnalytics {
  id tracker = [[GAI sharedInstance] defaultTracker];
  [tracker set:kGAIScreenName value:[self googleAnalyticsScreenName]];
  [tracker send:[[GAIDictionaryBuilder createAppView] build]];  
}

- (NSString*) googleAnalyticsScreenName {
  NSAssert(NO, @"You must override this method!");
  return nil;
}

@end
