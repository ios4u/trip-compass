#import "SearchViewController.h"
#import "MainViewController.h"
#import "Place.h"
#import "PlaceModel.h"
#import "BookmarkItemViewController.h"
#import "LocationSearchViewController.h"
#import "AppDelegate.h"
#import "Reachability.h"
#import "API.h"

@interface SearchViewController ()
@end

@implementation SearchViewController {
  NSArray *searchFilters;
  AppDelegate *appDelegate;
  NSString *lat;
  NSString *lng;
  UIView *defaultTableHeaderView;
  API *api;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  
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
  self.results = [[notification userInfo] valueForKey:@"results"];
  [self reloadTableViewData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  NSUInteger rows;
  
  if (self.searching == NO) {
    rows = self.results.count;
  } else {
    rows = ([searchFilters count] + 1);
  }

  if (rows > 0) {
    self.tabBarController.navigationItem.rightBarButtonItem = self.editButtonItem;
  }
  
  if (!appDelegate.isOnline) rows = 1;

  return rows;
}

//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
//  return @"title header";
//}

//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
//  return [self.tableView dequeueReusableCellWithIdentifier:@"headerCell"];
//}

- (Place *)getPlace:(NSInteger)row {
  NSDictionary *result = [self.results objectAtIndex:row];
  
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  UITableViewCell *cell;
  
  if (!appDelegate.isOnline) {
    return [self.tableView dequeueReusableCellWithIdentifier:@"NoInternet"];
  }
  
  if (self.searching == NO) {
    cell = [self.tableView dequeueReusableCellWithIdentifier:@"SearchCell"];
    
    Place *place = [self getPlace:indexPath.row];
    
    cell.textLabel.text = place.name;
    
    cell.detailTextLabel.text = [place formattedDistanceTo:self.currentLocation];;
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
  return cell;
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

- (void)keywordSearch:(NSString *)apiUrl {
//  NSString *lat = [NSString stringWithFormat:@"%.5f", self.currentLocation.latitude];
//  NSString *lon = [NSString stringWithFormat:@"%.5f", self.currentLocation.longitude];
  
//  NSString* encodedSearchString = [searchString stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
//  NSString *api;
//  if (searchString) {
//    api = [NSString stringWithFormat:@"http://api.gogobot.com/api/v2/search/nearby.json?_v=2.3.8&page=1&lng=%@&lat=%@&term=%@&per_page=20&source=create&bypass=1", lon, lat, encodedSearchString];
//  } else {
//    api = [NSString stringWithFormat:@"http://api.gogobot.com/api/v2/search/nearby.json?_v=2.3.8&page=1&lng=%@&lat=%@&per_page=20&source=create&bypass=1", lon, lat];
//  }
  
//  NSURL *url = [NSURL URLWithString:apiUrl];
//  NSURLRequest *request = [NSURLRequest requestWithURL:url];
  
//  AFJSONRequestOperation *operation = [AFJSONRequestOperation
//                                       JSONRequestOperationWithRequest:request
//                                       success:^(NSURLRequest *request, NSHTTPURLResponse *response, id json) {
//                                         self.results = [json objectForKey:@"results"];
//                                         [self reloadTableViewData];
//                                       } failure:^(NSURLRequest *request , NSURLResponse *response , NSError *error , id JSON){
//                                         NSLog(@"Failed: %@",[error localizedDescription]);
//                                       }];
//
//  [operation start];
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
  
  if([[segue identifier] isEqualToString:@"SearchSelection"]) {
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

@end