//
//  FlipsideViewController.h
//  TripCompass
//
//  Created by Eduardo Sasso on 7/1/13.
//  Copyright (c) 2013 Context Software. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FlipsideViewController;

@protocol FlipsideViewControllerDelegate
- (void)flipsideViewControllerDidFinish:(FlipsideViewController *)controller;
@end

@interface FlipsideViewController : UIViewController <UITextFieldDelegate>

@property (weak, nonatomic) id <FlipsideViewControllerDelegate> delegate;
@property (weak, nonatomic) IBOutlet UITextField *nameField;


- (IBAction)done:(id)sender;

@end
