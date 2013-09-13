#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "Place.h"

@interface LocationSearchViewController : UITableViewController <NSFetchedResultsControllerDelegate, UISearchDisplayDelegate, UISearchBarDelegate>

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@end
