//
//  BookmarkItemViewController.h
//  TripCompass
//
//  Created by Eduardo Sasso on 8/19/13.
//  Copyright (c) 2013 Context Software. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BookmarkItemViewController : UITableViewController <NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@property (strong, nonatomic) NSString *selectedAreaGroup;
@property (nonatomic, strong) NSArray *savedPlaces;

@end
