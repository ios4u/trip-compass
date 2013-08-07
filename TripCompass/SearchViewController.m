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

@interface SearchViewController () <UISearchDisplayDelegate, UISearchBarDelegate>

@end

@implementation SearchViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
  [super viewDidLoad];

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
  return self.results.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  static NSString *CellIdentifier = @"SearchCell";
  UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
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
    
  [self.places addObject:place];
  
  cell.textLabel.text = place.name;
  
  double distance = [place distanceTo:self.currentLocation toFormat:@"mi"];
  cell.detailTextLabel.text = [Util stringWithDistance:distance];
  
  return cell;
}

//- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption {
//  NSString *searchString = controller.searchBar.text;
//  return YES;
//}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
  
  NSString *lat = [NSString stringWithFormat:@"%.5f", self.currentLocation.latitude];
  NSString *lon = [NSString stringWithFormat:@"%.5f", self.currentLocation.longitude];
  NSString *api = [NSString stringWithFormat:@"http://api.gogobot.com/api/v2/search/nearby.json?_v=2.3.8&page=1&lng=%@&lat=%@&term=%@&per_page=20&source=explore&bypass=1", lon, lat, searchString];
  
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

  return YES;
}

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
