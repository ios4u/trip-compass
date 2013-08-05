//
//  BookmarkViewController.h
//  TripCompass
//
//  Created by Eduardo Sasso on 8/1/13.
//  Copyright (c) 2013 Context Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <CoreData/CoreData.h>
#import "Place.h"

@interface BookmarkViewController : UITableViewController <NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSArray *savedPlaces;
@property (nonatomic, retain) CLLocation *currentLocation;

@end
