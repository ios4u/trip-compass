//
//  MainViewController.h
//  TripCompass
//
//  Created by Eduardo Sasso on 7/1/13.
//  Copyright (c) 2013 Context Software. All rights reserved.
//

#import <CoreData/CoreData.h>
#import <CoreLocation/CoreLocation.h>
#import "Place.h"
#import "GAITrackedViewController.h"

@interface MainViewController : GAITrackedViewController

@property (nonatomic, retain) CLLocation *currentLocation;
@property (weak, nonatomic) IBOutlet UIImageView *compassImage;
@property (weak, nonatomic) IBOutlet UIImageView *needleImage;
@property (strong, nonatomic) Place *place;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

- (IBAction)checkpointAction:(id)sender;

@end
