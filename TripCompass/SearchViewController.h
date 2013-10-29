//
//  SearchControllerViewController.h
//  TripCompass
//
//  Created by Eduardo Sasso on 7/11/13.
//  Copyright (c) 2013 Context Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <CoreData/CoreData.h>
#import "Place.h"

@interface SearchViewController : UITableViewController <NSFetchedResultsControllerDelegate, UISearchBarDelegate>

@property (retain, nonatomic) NSArray *results;
@property (nonatomic, assign) CLLocationCoordinate2D currentLocation;

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (nonatomic, assign) BOOL searching;
@property (nonatomic, assign) BOOL currentLocationChanged;

@end

