#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "Place.h"
#import "GAUITableViewController.h"

@interface LocationSearchViewController : GAUITableViewController <NSFetchedResultsControllerDelegate, UISearchDisplayDelegate, UISearchBarDelegate>

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *closeButton;
@property (nonatomic, assign) BOOL closeButtonClicked;

@end
