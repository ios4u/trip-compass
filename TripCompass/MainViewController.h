//
//  MainViewController.h
//  TripCompass
//
//  Created by Eduardo Sasso on 7/1/13.
//  Copyright (c) 2013 Context Software. All rights reserved.
//

#import "FlipsideViewController.h"
#import <CoreData/CoreData.h>
#import <CoreLocation/CoreLocation.h>
#import "Place.h"
#import "Util.h"

@interface MainViewController : UIViewController <FlipsideViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UILabel *magneticHeadingLabel;

//@property (nonatomic, retain) CLLocationManager *locationManager;
@property (nonatomic, retain) CLLocation *currentLocation;

@property (weak, nonatomic) IBOutlet UILabel *trueHeadingLabel;

@property (weak, nonatomic) IBOutlet UIView *subView;
@property (weak, nonatomic) IBOutlet UIImageView *compassImage;
@property (strong, nonatomic) Place *place;

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@end
