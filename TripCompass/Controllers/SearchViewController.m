#import "SearchViewController.h"
#import "MainViewController.h"
#import "Place.h"
#import "PlaceModel.h"
#import "BookmarkItemViewController.h"
#import "LocationSearchViewController.h"
#import "AppDelegate.h"
#import "Reachability.h"
#import "API.h"
#import "CustomCell.h"

const int kLoadingCellTag = 1273;

@interface SearchViewController ()
@end

@implementation SearchViewController {
  //TODO why declare var here as oposed to property? or in the interface?
  NSArray *searchFilters;
  AppDelegate *appDelegate;
  NSString *lat;
  NSString *lng;
  UIView *defaultTableHeaderView;
  API *api;
  NSMutableArray *results;
  NSInteger currentPage;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  
  self.tableView.contentInset = UIEdgeInsetsMake(self.tabBarController.topLayoutGuide.length, 0, 0, 0);
  
  [self.tableView registerNib:[UINib nibWithNibName:@"CustomCell" bundle:nil] forCellReuseIdentifier:@"customCell"];
  
  //TODO: get the initial size dynamically from the constraints
  self.tableView.estimatedRowHeight = 43;

  currentPage = 0;
  
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(apiResultsNotificationReceived:) name:@"apiResultsNotification" object:nil];
  
  appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
  self.managedObjectContext = [appDelegate managedObjectContext];
  
  self.tabBarController.delegate = self;
  defaultTableHeaderView = [self.tableView tableHeaderView];
  
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityDidChange:) name:kReachabilityChangedNotification object:nil];
}

- (NSString *)googleAnalyticsScreenName {
  return @"Search";
}

- (void)reachabilityDidChange:(NSNotification *)notification {
  //TODO remove this here. App Delegate should be responsible for this.
  if (appDelegate.isOnline) {
    [self.tableView setTableHeaderView:defaultTableHeaderView];

    [self.tableView reloadData];
  } else {
    [self.tableView setTableHeaderView:nil];
    //if the tableview is empty then show the no internet warning
    if ([self.tableView numberOfRowsInSection:0] == 0) [self.tableView reloadData];
  }
}

- (void)viewWillAppear:(BOOL)animated {
  [self.refreshControl endRefreshing];
  self.tabBarController.navigationItem.title = @"Nearby Search";
  self.tabBarController.navigationItem.rightBarButtonItem = nil;
}

- (void)viewDidAppear:(BOOL)animated {
  if (self.searching == YES) {
    [self.searchBar becomeFirstResponder];
  } else {
    searchFilters = [NSArray arrayWithObjects:@"Attractions",@"Restaurants",@"Hotels",@"Popular", nil];
    
    CLLocationCoordinate2D currentLocation = [(AppDelegate*)appDelegate currentLocation];
    api = [[API alloc] initWithLatitude:currentLocation.latitude longitude:currentLocation.longitude];
    [api getPlacesNearby];
  }
}

- (void) apiResultsNotificationReceived:(NSNotification *) notification {
  NSArray *apiResults = [[notification userInfo] valueForKey:@"results"];
  
  if (currentPage > 1) {
    [results addObjectsFromArray:apiResults];
  } else {
    results = [apiResults mutableCopy];
  }

  [self.refreshControl endRefreshing];
  [self reloadTableViewData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  if (self.searching) {
    return [searchFilters count] + 1;
  }
  
  //1 is for the loading row
  
  if (results) {
    return results.count + 1;
  }
  
  return 1;

//  NSUInteger rows;

  //TODO this logic with the search is confusing simplify
//  if (self.searching == NO) {
//    NSInteger loadingRow = 1;
////    rows = results.count + loadingRow;
//    rows = results.count;
//  } else {
//    rows = ([searchFilters count] + 1);
//  }

//  if (rows > 0) {
//    self.tabBarController.navigationItem.rightBarButtonItem = self.editButtonItem;
//  }
//  
//  if (!appDelegate.isOnline) rows = 1;
//
//  return rows;
}

//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
//  return @"title header";
//}

//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
//  return [self.tableView dequeueReusableCellWithIdentifier:@"headerCell"];
//}

- (Place *)getPlace:(NSInteger)row {
  NSDictionary *result = [results objectAtIndex:row];
  
  id place_lat = [result valueForKeyPath:@"address.lat"];
  id place_lng = [result valueForKeyPath:@"address.lng"];
  
  Place *place = [[Place alloc] init];
  place.name = [result objectForKey:@"name"];
  place.address = [result valueForKeyPath:@"address.address"];
  place.lat = [NSNumber numberWithDouble:[place_lat doubleValue]];
  place.lng = [NSNumber numberWithDouble:[place_lng doubleValue]];
  place.area = [result objectForKey:@"travel_unit"];

  return place;
}

//TODO do this in the storyboard
- (UITableViewCell *)loadingCell {
  UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                  reuseIdentifier:nil];
  
  UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc]
                                                initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
  activityIndicator.center = cell.center;
  [cell addSubview:activityIndicator];
  
  [activityIndicator startAnimating];
  
  cell.tag = kLoadingCellTag;
  
  return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  UITableViewCell *cell;
  
  //TODO this if/else logic sucks... too nested REDO
  if (!appDelegate.isOnline) {
    return [self.tableView dequeueReusableCellWithIdentifier:@"NoInternet"];
  }
  
  if (indexPath.row < results.count) {
    if (self.searching == NO) {
      CustomCell *customCell = [tableView dequeueReusableCellWithIdentifier:@"customCell"];
      
      Place *place = [self getPlace:indexPath.row];
      
      customCell.placeLabel.text = place.name;
      customCell.detailLabel.text = [place formattedDistanceTo:[(AppDelegate*)appDelegate currentLocation]];
      
      return customCell;
    } else {
      if (indexPath.row == 0) {
        cell = [self.tableView dequeueReusableCellWithIdentifier:@"LocationCell"];

        cell.detailTextLabel.text = @"Current Location";
        if (appDelegate.selectedLocation) {
          cell.detailTextLabel.text = appDelegate.selectedLocation.name;
        }      
      } else {
        cell = [self.tableView dequeueReusableCellWithIdentifier:@"FilterCell"];
        NSString *filterName = [searchFilters objectAtIndex:(indexPath.row -1)];
        cell.textLabel.text = filterName;
      }
    }
  } else {
    return [self loadingCell];
  }
  
  return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  if (indexPath.row < results.count) {
    CustomCell *cell = [tableView dequeueReusableCellWithIdentifier:@"customCell"];
    Place *place = [self getPlace:indexPath.row];
    
    return [cell calculateHeight:place.name];
  } else {
    //TODO find a better way to return the default size
    return 43;
  }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
  if (cell.tag == kLoadingCellTag) {
    currentPage++;
    [api getPlacesNearbyPage:currentPage];
  }
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
  [self setEditing:NO animated:YES];
  self.searching = YES;
  [searchBar setShowsCancelButton:YES animated:YES];
  [self reloadTableViewData];
  return YES;
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar {
  self.searching = NO;
	[searchBar sizeToFit];
  
	[searchBar setShowsCancelButton:NO animated:YES];
  
  NSLog(@"searchBarShouldEndEditing");
  
	return YES;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
  [api searchPlacesNearby:searchText];
  
  self.searching = NO;
//  [self reloadTableViewData];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
  [searchBar resignFirstResponder];
  self.searching = NO;
  searchBar.text = nil;
  
  [api getPlacesNearby];
//  [self reloadTableViewData];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
  [searchBar resignFirstResponder];
}

- (void)searchDisplayController:(UISearchDisplayController *)controller didHideSearchResultsTableView:(UITableView *)tableView {
  self.searchDisplayController.searchResultsTableView.hidden = YES;
}

- (void)searchDisplayControllerDidBeginSearch:(UISearchDisplayController *)controller {
  //  [self.searchDisplayController.searchBar becomeFirstResponder];
  //  [self.searchDisplayController.searchBar setText:@"whole"];
  //  [self.view addSubview:self.searchDisplayController.searchResultsTableView];
  self.searchDisplayController.searchResultsTableView.hidden = YES;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
  if ([cell.reuseIdentifier isEqual: @"FilterCell"]) {
    [self.searchBar resignFirstResponder];
    self.searching = NO;
    self.searchBar.text = nil;
    
//    NSString *source = @"create";
//    
//    if ([type isEqual: @"Popular"]) {
//      type = @"all";
//      source = @"explore";
//    }
    
//    NSString *apiUrl = [NSString stringWithFormat:@"http://api.gogobot.com/api/v2/search/nearby.json?_v=2.3.8&type=%@&page=1&lng=%@&lat=%@&per_page=20&source=%@&bypass=1", type, lng, lat, source];
    
//    [self keywordSearch:apiUrl];
//    [self reloadTableViewData];
    NSString *type = cell.textLabel.text;
    
    if ([type isEqualToString:@"Restaurants"]) [api getRestaurantsNearby];
    if ([type isEqualToString:@"Attractions"]) [api getAttractionsNearby];
    if ([type isEqualToString:@"Hotels"]) [api getHotelsNearby];
  } else {
    [self performSegueWithIdentifier:@"toMainView" sender:self];
  }
}

- (void) reloadTableViewData {
  [self.tableView reloadData];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
  return  UITableViewCellEditingStyleInsert;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
  if ([self.tableView isEditing]) {
    Place *place = [self getPlace:indexPath.row];
    
    NSError *error;
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"PlaceModel" inManagedObjectContext:self.managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    [fetchRequest setEntity:entity];
    
    //  TODO should compare with id
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name == %@", place.name];
    [fetchRequest setPredicate:predicate];
    
    NSArray *results = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    return [results count] == 0;
  } else {
    return YES;
  }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
  //  UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
  
  if (editingStyle == UITableViewCellEditingStyleDelete) {
    //delete code here
  }
  else if (editingStyle == UITableViewCellEditingStyleInsert) {
    Place *place = [self getPlace:indexPath.row];
    
    NSManagedObjectContext *context = [self managedObjectContext];
    
    PlaceModel *placeModel = [NSEntityDescription insertNewObjectForEntityForName:@"PlaceModel" inManagedObjectContext:context];
    placeModel.name = place.name;
    placeModel.lat = place.lat;
    placeModel.lng = place.lng;
    placeModel.area = place.area;
    
    NSError *error;
    if (![context save:&error]) {
      NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
    }
    
    [self reloadTableViewData];
  }
  
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
//  if([[segue identifier] isEqualToString:@"LocationSearch"]) {
//    [self.searchBar becomeFirstResponder];
//  }
  
  if([[segue identifier] isEqualToString:@"toMainView"]) {
    NSIndexPath *path = [self.tableView indexPathForSelectedRow];
    
    UINavigationController *navigationController = (UINavigationController *)segue.destinationViewController;
    MainViewController *mainViewController = [[navigationController viewControllers] lastObject];
    
    Place *place = [self getPlace:path.row];
    mainViewController.place = place;
  }
}

- (IBAction)unwindToSearchController:(UIStoryboardSegue *)segue {
  LocationSearchViewController *locationSearchViewController = [segue sourceViewController];
//  locationSearchViewController
  self.searching = locationSearchViewController.closeButtonClicked;
  [self reloadTableViewData];
}

- (IBAction)pullToRefresh:(id)sender {
  //TODO here it should be aware of the type (Attraction, Hotel, Restaurant) to refresh
  [api getPlacesNearby];
}

@end