#import <UIKit/UIKit.h>
#import "CustomCell.h"
#import "GAUITableViewController.h"

@interface BookmarkItemViewController : GAUITableViewController <NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@property (strong, nonatomic) NSString *selectedAreaGroup;
@property (nonatomic, strong) NSMutableArray *savedPlaces;

@end