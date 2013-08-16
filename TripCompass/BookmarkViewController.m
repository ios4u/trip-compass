//
//  BookmarkViewController.m
//  TripCompass
//
//  Created by Eduardo Sasso on 8/1/13.
//  Copyright (c) 2013 Context Software. All rights reserved.
//

#import "BookmarkViewController.h"
#import "MainViewController.h"
#import "Place.h"
#import "PlaceModel.h"

@interface BookmarkViewController () <CLLocationManagerDelegate>

@end

@implementation BookmarkViewController {
  CLLocationManager *locationManager;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {      
    }
    return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];

  id delegate = [[UIApplication sharedApplication] delegate];
  self.managedObjectContext = [delegate managedObjectContext];
  
  locationManager = [[CLLocationManager alloc] init];
  locationManager.delegate = self;
  locationManager.desiredAccuracy = kCLLocationAccuracyBest;
  
  if( [CLLocationManager locationServicesEnabled] &&  [CLLocationManager headingAvailable]) {
    [locationManager startUpdatingLocation];
    [locationManager startUpdatingHeading];
    NSLog(@"Started");
  } else {
    NSLog(@"Can't report heading");
  }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
  self.currentLocation = [locations lastObject];
}

-(void)viewWillAppear:(BOOL)animated {
  self.tabBarController.navigationItem.title = @"Saved list";
  
  NSError *error;
  NSEntityDescription *entity = [NSEntityDescription entityForName:@"PlaceModel" inManagedObjectContext:self.managedObjectContext];
  
//  NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
//  [fetchRequest setEntity:entity];
//
//  self.savedPlaces = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
//  
  
  NSPropertyDescription *propDesc = [[entity propertiesByName] objectForKey:@"area"];
  NSExpression *emailExpr = [NSExpression expressionForKeyPath:@"area"];
  NSExpression *countExpr = [NSExpression expressionForFunction:@"count:" arguments:[NSArray arrayWithObject:emailExpr]];
  NSExpressionDescription *exprDesc = [[NSExpressionDescription alloc] init];
  [exprDesc setExpression:countExpr];
  [exprDesc setExpressionResultType:NSInteger64AttributeType];
  [exprDesc setName:@"count"];
  
  NSFetchRequest *fr = [[NSFetchRequest alloc] init];
  [fr setEntity:entity];
  
  [fr setPropertiesToGroupBy:[NSArray arrayWithObject:propDesc]];
  fr.sortDescriptors= @[[NSSortDescriptor sortDescriptorWithKey:@"created" ascending:NO]];
  
  [fr setPropertiesToFetch:[NSArray arrayWithObjects:propDesc, exprDesc, nil]];
  [fr setResultType:NSDictionaryResultType];
  
  self.savedPlaces = [self.managedObjectContext executeFetchRequest:fr error:&error];
  
  [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
 return [self.savedPlaces count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  static NSString *CellIdentifier = @"BookmarkCell";
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
  
//  PlaceModel *placeModel = [self.savedPlaces objectAtIndex:indexPath.row];

  NSDictionary *place = [self.savedPlaces objectAtIndex:indexPath.row];
  NSNumber *count = [place objectForKey: @"count"];
  
//  Place *place = [[Place alloc] init];
//  place.name = placeModel.name;
//  place.address = placeModel.address;
//  place.lat = placeModel.lat;
//  place.lng = placeModel.lng;

  cell.textLabel.text = [place valueForKey:@"area"];
//  double distance = [place distanceTo:self.currentLocation.coordinate toFormat:@"mi"];
//  cell.detailTextLabel.text = [Util stringWithDistance:distance];
  cell.detailTextLabel.text = [[place objectForKey:@"count"]stringValue];

  return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
  NSIndexPath *path = [self.tableView indexPathForSelectedRow];
  
  UINavigationController *navigationController = (UINavigationController *)segue.destinationViewController;
  MainViewController *mainViewController = [[navigationController viewControllers] lastObject];
  
  PlaceModel *placeModel = [self.savedPlaces objectAtIndex:path.row];

  Place *place = [[Place alloc] init];
  place.name = placeModel.name;
  place.address = placeModel.address;
  place.lat = placeModel.lat;
  place.lng = placeModel.lng;
  
  mainViewController.place = place;
}

@end
