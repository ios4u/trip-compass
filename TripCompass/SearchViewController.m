#import "SearchViewController.h"
#import "MainViewController.h"
#import "Place.h"
#import "PlaceModel.h"
#import "Util.h"
#import "AFNetworking.h"
#import "BookmarkItemViewController.h"
#import "LocationSearchViewController.h"
#import "AppDelegate.h"

@interface SearchViewController ()
@end

@implementation SearchViewController {
  NSArray *searchFilters;
  AppDelegate *appDelegate;
  NSString *lat;
  NSString *lng;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  
  searchFilters = [NSArray arrayWithObjects:@"Attractions",@"Restaurants",@"Hotels",@"Popular", nil];
  
  appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
  self.managedObjectContext = [appDelegate managedObjectContext];

  lat = [NSString stringWithFormat:@"%.5f", self.currentLocation.latitude];
  lng = [NSString stringWithFormat:@"%.5f", self.currentLocation.longitude];
  if (appDelegate.selectedLocation) {
    lat = [appDelegate.selectedLocation.lat stringValue];
    lng = [appDelegate.selectedLocation.lng stringValue];
  }
  
  self.places = [[NSMutableArray alloc] init];
  
  NSString *api = [NSString stringWithFormat:@"http://api.gogobot.com/api/v2/search/nearby.json?_v=2.3.8&page=1&lng=%@&lat=%@&per_page=20&source=create&bypass=1", lng, lat];
  
  NSURL *url = [NSURL URLWithString:api];
  NSURLRequest *request = [NSURLRequest requestWithURL:url];
  
  AFJSONRequestOperation *operation = [AFJSONRequestOperation
                                       JSONRequestOperationWithRequest:request
                                       success:^(NSURLRequest *request, NSHTTPURLResponse *response, id json) {
                                         self.results = [json objectForKey:@"results"];
                                         [self.tableView reloadData];
                                       } failure:^(NSURLRequest *request , NSURLResponse *response , NSError *error , id JSON){
                                         NSLog(@"Failed: %@",[error localizedDescription]);
                                       }];
  
  [operation start];
}

- (void)viewWillAppear:(BOOL)animated {
  self.tabBarController.navigationItem.title = @"Nearby Search";
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  // Return the number of rows in the section.
  if (self.searching == NO) {
    return self.results.count;
  } else {
    return ([searchFilters count] + 1);
//    return 5;
  }
}

//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
//  return @"title header";
//}

//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
//  return [self.tableView dequeueReusableCellWithIdentifier:@"headerCell"];
//}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  NSString *CellIdentifier;
  UITableViewCell *cell;

  if (self.searching == NO) {
    CellIdentifier = @"SearchCell";
    cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
      
    UIButton *button = [UIButton buttonWithType:UIButtonTypeContactAdd];
    button.tag = indexPath.row;
    [button addTarget:self action:@selector(btnAddClick:) forControlEvents:UIControlEventTouchUpInside];
    cell.accessoryView = button;
    
    NSDictionary *result = [self.results objectAtIndex:indexPath.row];
    
    Place *place = [[Place alloc] init];
    place.name = [result objectForKey:@"name"];
    place.address = [result valueForKeyPath:@"address.address"];
    place.lat = [NSNumber numberWithDouble:[[result valueForKeyPath:@"address.lat"] doubleValue]];
    place.lng = [NSNumber numberWithDouble:[[result valueForKeyPath:@"address.lng"] doubleValue]];
    place.area = [result objectForKey:@"travel_unit"];
      
    [self.places addObject:place];
    
    cell.textLabel.text = place.name;
    
    double distance = [place distanceTo:self.currentLocation toFormat:@"mi"];
    cell.detailTextLabel.text = [Util stringWithDistance:distance];
  } else {
    if (indexPath.row == 0) {
      CellIdentifier = @"LocationCell";
      cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];

      cell.detailTextLabel.text = @"Current Location";
      if (appDelegate.selectedLocation) {
        cell.detailTextLabel.text = appDelegate.selectedLocation.name;
      }      
    } else {
      CellIdentifier = @"FilterCell";
      cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
      NSString *filterName = [searchFilters objectAtIndex:(indexPath.row -1)];
      cell.textLabel.text = filterName;
    }
  }
  return cell;
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
  self.searching = YES;
  [searchBar setShowsCancelButton:YES animated:YES];
  [self.tableView reloadData];
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
  
  NSURL *url = [NSURL URLWithString:apiUrl];
  NSURLRequest *request = [NSURLRequest requestWithURL:url];
  
  [self.places removeAllObjects];
  
  AFJSONRequestOperation *operation = [AFJSONRequestOperation
                                       JSONRequestOperationWithRequest:request
                                       success:^(NSURLRequest *request, NSHTTPURLResponse *response, id json) {
                                         //                                           self.places = [[NSMutableArray alloc] init];
                                         self.results = [json objectForKey:@"results"];
                                         [self.tableView reloadData];
                                       } failure:^(NSURLRequest *request , NSURLResponse *response , NSError *error , id JSON){
                                         NSLog(@"Failed: %@",[error localizedDescription]);
                                       }];

  [operation start];
}


- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
  NSString *encodedSearchString = [searchText stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
  NSString *apiUrl = [NSString stringWithFormat:@"http://api.gogobot.com/api/v2/search/nearby.json?_v=2.3.8&page=1&lng=%@&lat=%@&term=%@&per_page=20&source=create&bypass=1", lng, lat, encodedSearchString];
  
  [self keywordSearch:apiUrl];
  self.searching = NO;
  [self.tableView reloadData];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
  [searchBar resignFirstResponder];
  self.searching = NO;
  searchBar.text = nil;
  
  NSString *apiUrl = [NSString stringWithFormat:@"http://api.gogobot.com/api/v2/search/nearby.json?_v=2.3.8&page=1&lng=%@&lat=%@&per_page=20&source=create&bypass=1", lng, lat];
  
  [self keywordSearch:apiUrl];
  [self.tableView reloadData];
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

-(void)btnAddClick:(id)sender {
  UIButton* btnAdd = (UIButton *) sender;
  
  UITableViewCell *cell = (UITableViewCell *)[btnAdd superview];
  cell.userInteractionEnabled = NO;
//  cell.textLabel.enabled = NO;
//  cell.detailTextLabel.enabled = NO;
//  cell.accessoryView = nil;
  
  Place *place = [self.places objectAtIndex:btnAdd.tag];
  
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
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
  if ([cell.reuseIdentifier isEqual: @"FilterCell"]) {
    [self.searchBar resignFirstResponder];
    self.searching = NO;
    self.searchBar.text = nil;
    
    NSString *source = @"create";
    NSString *type = cell.textLabel.text;
    if ([type isEqual: @"Popular"]) {
      type = @"all";
      source = @"explore";
    }
    
    NSString *apiUrl = [NSString stringWithFormat:@"http://api.gogobot.com/api/v2/search/nearby.json?_v=2.3.8&type=%@&page=1&lng=%@&lat=%@&per_page=20&source=%@&bypass=1", type, lng, lat, source];
    
    [self keywordSearch:apiUrl];
    [self.tableView reloadData];
  }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
  if([[segue identifier] isEqualToString:@"SearchSelection"]) {
    NSIndexPath *path = [self.tableView indexPathForSelectedRow];
    
    UINavigationController *navigationController = (UINavigationController *)segue.destinationViewController;
    MainViewController *mainViewController = [[navigationController viewControllers] lastObject];
    
    Place *place = [self.places objectAtIndex:path.row];
    mainViewController.place = place;
  }
}

@end