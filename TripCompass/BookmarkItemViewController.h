#import <UIKit/UIKit.h>
#import "CustomCell.h"

@interface BookmarkItemViewController : UITableViewController <NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@property (strong, nonatomic) NSString *selectedAreaGroup;
@property (nonatomic, strong) NSMutableArray *savedPlaces;

@end
