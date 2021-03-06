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
#import "GAUITableViewController.h"

@interface SearchViewController : GAUITableViewController <NSFetchedResultsControllerDelegate, UISearchBarDelegate, UITabBarControllerDelegate>

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (nonatomic, assign) BOOL searching;

- (IBAction)pullToRefresh:(id)sender;

@end

