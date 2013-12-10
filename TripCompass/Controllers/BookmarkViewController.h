#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <CoreData/CoreData.h>
#import "Place.h"
#import "CustomCell.h"
#import "GAUITableViewController.h"

@interface BookmarkViewController : GAUITableViewController <NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSMutableArray *savedPlaces;
@property (nonatomic, retain) CLLocation *currentLocation;


@end
