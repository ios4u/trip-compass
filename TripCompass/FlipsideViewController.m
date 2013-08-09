//
//  FlipsideViewController.m
//  TripCompass
//
//  Created by Eduardo Sasso on 7/1/13.
//  Copyright (c) 2013 Context Software. All rights reserved.
//

#import "FlipsideViewController.h"

@interface FlipsideViewController ()

@end

@implementation FlipsideViewController

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)viewDidLoad {
  [super viewDidLoad];
  
  if ([[NSUserDefaults standardUserDefaults] boolForKey:@"isMetric"]) {
    self.segmentControl.selectedSegmentIndex = 0;
  } else {
    self.segmentControl.selectedSegmentIndex = 1;
  }
  
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Actions

- (IBAction)segmentControlChanged:(id)sender {
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

  BOOL isMetric = ((UISegmentedControl *)sender).selectedSegmentIndex == 0;
  [defaults setBool:isMetric forKey:@"isMetric"];
}

- (IBAction)done:(id)sender {
  [self.delegate flipsideViewControllerDidFinish:self];
}

@end
