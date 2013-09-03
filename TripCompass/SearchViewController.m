//
//  SearchControllerViewController.m
//  TripCompass
//
//  Created by Eduardo Sasso on 7/11/13.
//  Copyright (c) 2013 Context Software. All rights reserved.
//

#import "SearchViewController.h"
#import "MainViewController.h"
#import "Place.h"
#import "PlaceModel.h"
#import "Util.h"
#import "AFNetworking.h"
#import "BookmarkItemViewController.h"

@interface SearchViewController ()
@end

@implementation SearchViewController {
  NSArray *searchFilters;
}

- (id)initWithStyle:(UITableViewStyle)style
{
  self = [super initWithStyle:style];
  if (self) {
    // Custom initialization
  }
  return self;
}


- (void)runSearch: (NSString *)xx {

}

- (void)viewDidLoad
{
  [super viewDidLoad];
  
  
  searchFilters = [NSArray arrayWithObjects:@"Attractions",@"Restaurants",@"Hotels",@"Popular", nil];
  
//  self.tableView.tableHeaderView = headerView;
  
  id delegate = [[UIApplication sharedApplication] delegate];
  self.managedObjectContext = [delegate managedObjectContext];
  
  NSString *lat = [NSString stringWithFormat:@"%.5f", self.currentLocation.latitude];
  NSString *lon = [NSString stringWithFormat:@"%.5f", self.currentLocation.longitude];
//  NSLog(@"lat %@ -- lon %@", lat,lon);

  // Uncomment the following line to preserve selection between presentations.
  // self.clearsSelectionOnViewWillAppear = NO;

  // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
  // self.navigationItem.rightBarButtonItem = self.editButtonItem;
  self.places = [[NSMutableArray alloc] init];
  
  NSString *api = [NSString stringWithFormat:@"http://api.gogobot.com/api/v2/search/nearby.json?_v=2.3.8&page=1&lng=%@&lat=%@&per_page=20&source=explore&bypass=1", lon, lat];

  NSURL *url = [NSURL URLWithString:api];
  NSURLRequest *request = [NSURLRequest requestWithURL:url];
  
  AFJSONRequestOperation *operation = [AFJSONRequestOperation
                                       JSONRequestOperationWithRequest:request
                                       success:^(NSURLRequest *request, NSHTTPURLResponse *response, id json) {
//                                         NSLog(@"Tweets: %@", [json valueForKeyPath:@"results"]);
                                         self.results = [json objectForKey:@"results"];
                                         [self.tableView reloadData];
                                       } failure:^(NSURLRequest *request , NSURLResponse *response , NSError *error , id JSON){
                                         NSLog(@"Failed: %@",[error localizedDescription]);
                                       }];
  
  [operation start];
//  http://nscookbook.com/2013/03/ios-programming-recipe-16-populating-a-uitableview-with-data-from-the-web/
//  http://nsscreencast.com/episodes/6-afnetworking
}

- (void)viewWillAppear:(BOOL)animated {
  self.tabBarController.navigationItem.title = @"Nearby Search";
  self.tabBarController.navigationItem.rightBarButtonItem = self.locationButton;
}

- (void)didReceiveMemoryWarning
{
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  // Return the number of rows in the section.
  if (self.searching == NO) {
    return self.results.count;
  } else {
    return [searchFilters count];
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
    CellIdentifier = @"FilterCell";
    cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    NSString *filterName = [searchFilters objectAtIndex:indexPath.row];
//    TODO add tag
    cell.textLabel.text = filterName;
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

- (void)keywordSearch:(NSString *)searchString {
  NSString *lat = [NSString stringWithFormat:@"%.5f", self.currentLocation.latitude];
  NSString *lon = [NSString stringWithFormat:@"%.5f", self.currentLocation.longitude];
  
  NSString* encodedSearchString = [searchString stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
  NSString *api;
  if (searchString) {
    api = [NSString stringWithFormat:@"http://api.gogobot.com/api/v2/search/nearby.json?_v=2.3.8&page=1&lng=%@&lat=%@&term=%@&per_page=20&source=explore&bypass=1", lon, lat, encodedSearchString];
  } else {
    api = [NSString stringWithFormat:@"http://api.gogobot.com/api/v2/search/nearby.json?_v=2.3.8&page=1&lng=%@&lat=%@&per_page=20&source=explore&bypass=1", lon, lat];
  }
  
  NSURL *url = [NSURL URLWithString:api];
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

//  if (searchText.length >=3) {
    [self keywordSearch:searchText];
    self.searching = NO;
    [self.tableView reloadData];
//  };

}

//- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
//  NSLog(@"searchBarTextDidBeginEditing");
//}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
  [searchBar resignFirstResponder];
  self.searching = NO;
  searchBar.text = nil;
  [self keywordSearch:nil];
  [self.tableView reloadData];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
  [searchBar resignFirstResponder];
}

//- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption {
//  NSString *searchString = controller.searchBar.text;
//  return YES;
//}

//- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
//  //do stuff
////  BookmarkItemViewController *viewController = [[BookmarkItemViewController alloc] init];
////  [self presentViewController:viewController animated:YES completion:nil];
////  searchBar.backgroundColor = [UIColor clearColor];
////  [[searchBar.subviews objectAtIndex:0] removeFromSuperview];
////    [[searchBar.subviews objectAtIndex:2] removeFromSuperview];
////  [searchBar becomeFirstResponder];
//
////  UIView *view1 = [[UIView alloc] init];
////  view1.frame = CGRectMake(0, 20, 320, 460);
////  view1.backgroundColor = [UIColor blueColor];
////  [searchBar addSubview:view1];
////  
////  self.searchDisplayController.searchResultsTableView.hidden = YES;
////  return YES;
//  
//}

//- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
//  [searchBar setShowsCancelButton:YES animated:YES];
//  self.tableView.allowsSelection = YES;
//  self.tableView.scrollEnabled = YES;
//}
//

- (void)searchDisplayController:(UISearchDisplayController *)controller didHideSearchResultsTableView:(UITableView *)tableView
{
  // add the tableview back in
//[self.view addSubview:self.searchDisplayController.searchResultsTableView];
//  self.searchDisplayController.searchResultsTableView.hidden = YES;
  self.searchDisplayController.searchResultsTableView.hidden = YES;
}

- (void)searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller
{
  // after the data has been preloaded
//  self.searchResults = self.allItems;
//    [controller.searchBar becomeFirstResponder];
//[self.searchDisplayController.searchResultsTableView reloadData];

  //  [self.view addSubview:self.searchDisplayController.searchResultsTableView];
//  self.searchDisplayController.searchResultsTableView.hidden = YES;
//  [[self.view.subviews lastObject] removeFromSuperview];
//  
//  UIView *hideSearchView = [[UIView alloc] initWithFrame:CGRectMake(self.searchDisplayController.searchResultsTableView.frame.origin.x, self.searchDisplayController.searchResultsTableView.frame.origin.y, self.searchDisplayController.searchResultsTableView.frame.size.width, self.searchDisplayController.searchResultsTableView.frame.size.height)];
//  hideSearchView.alpha = 0.8;
//  hideSearchView.tag = 1200;
//  hideSearchView.backgroundColor = [UIColor blackColor];
//  [self.searchDisplayController.searchContentsController.view addSubview:hideSearchView];
//
//  [self.view addSubview:hideSearchView];
}

- (void)searchDisplayControllerDidBeginSearch:(UISearchDisplayController *)controller
{
//  [self.searchDisplayController.searchBar becomeFirstResponder];
//  [self.searchDisplayController.searchBar setText:@"whole"];
//  [self.view addSubview:self.searchDisplayController.searchResultsTableView];
self.searchDisplayController.searchResultsTableView.hidden = YES;
}

// TODO: Your text here÷÷÷
- (void)searchDisplayController:(UISearchDisplayController *)controller willShowSearchResultsTableView:(UITableView *)tableView {
//  self.searchDisplayController.searchResultsTableView.hidden = YES;
//  self.searchDisplayController.searchResultsTableView.hidden = YES;
//  UIView *hideSearchView = [[UIView alloc] initWithFrame:CGRectMake(self.searchDisplayController.searchResultsTableView.frame.origin.x, self.searchDisplayController.searchResultsTableView.frame.origin.y, self.searchDisplayController.searchResultsTableView.frame.size.width, self.searchDisplayController.searchResultsTableView.frame.size.height)];
//  hideSearchView.alpha = 0.8;
//  hideSearchView.tag = 1200;
//  hideSearchView.backgroundColor = [UIColor blackColor];
//  [self.searchDisplayController.searchContentsController.view addSubview:hideSearchView];
  
}


//- (void)search:(NSString *)searchString


-(void)btnAddClick:(id)sender {
  UIButton* btnAdd = (UIButton *) sender;
//  NSLog(@"Button %d is selected",btnAdd.tag);
  
  UITableViewCell *cell = (UITableViewCell *)[btnAdd superview];
  cell.userInteractionEnabled = NO;
  cell.textLabel.enabled = NO;
  cell.detailTextLabel.enabled = NO;
  cell.accessoryView = nil;
  
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

#pragma mark - Table view delegate

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
  NSIndexPath *path = nil;
  if ([self.searchDisplayController isActive]) {
    path = [self.searchDisplayController.searchResultsTableView indexPathForSelectedRow];
  } else {
    path = [self.tableView indexPathForSelectedRow];
  }
  
  UINavigationController *navigationController = (UINavigationController *)segue.destinationViewController;
  MainViewController *mainViewController = [[navigationController viewControllers] lastObject];
  
//  Place *place = [[Place alloc] init];
//  place.name = [self.tableView cellForRowAtIndexPath:path].textLabel.text;
//  mainViewController.place = place;
  

  Place *place = [self.places objectAtIndex:path.row];
  mainViewController.place = place;

//  mainViewController.mainSubTitle = [self.tableView cellForRowAtIndexPath:path].detailTextLabel.text;
//  mainViewController.mainTitle = [self.tableView cellForRowAtIndexPath:path].textLabel.text;  
}

@end


//http://stackoverflow.com/questions/4434855/uisearchdisplaycontroller-without-instant-search-how-do-i-control-the-dimming-o
//http://pinkstone.co.uk/tag/uisearchdisplaycontroller/
//http://stackoverflow.com/questions/2388906/iphone-sdk-setting-the-size-of-uisearchdisplaycontrollers-table-view
//http://stackoverflow.com/questions/1912446/remove-transparent-overlay-uisearchbar