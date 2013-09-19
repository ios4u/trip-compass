//
//  BookmarkViewController.m
//  TripCompass
//
//  Created by Eduardo Sasso on 8/1/13.
//  Copyright (c) 2013 Context Software. All rights reserved.
//

#import "BookmarkViewController.h"
#import "MainViewController.h"
#import "BookmarkItemViewController.h"
#import "Place.h"
#import "PlaceModel.h"

@interface BookmarkViewController () <CLLocationManagerDelegate>
@end

@implementation BookmarkViewController {
  CLLocationManager *locationManager;
}

- (void)viewDidLoad {
  [super viewDidLoad];

  id delegate = [[UIApplication sharedApplication] delegate];
  self.managedObjectContext = [delegate managedObjectContext];
  self.tabBarController.navigationItem.rightBarButtonItem = self.editButtonItem;
}

-(void)viewWillAppear:(BOOL)animated {
  self.tabBarController.navigationItem.title = @"Saved list";
  
  NSError *error;
  NSEntityDescription *entity = [NSEntityDescription entityForName:@"PlaceModel" inManagedObjectContext:self.managedObjectContext];
    
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
 return [self.savedPlaces count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  static NSString *CellIdentifier = @"BookmarkCell";
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
  
  NSDictionary *place = [self.savedPlaces objectAtIndex:indexPath.row];
  
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


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
  NSDictionary *place = [self.savedPlaces objectAtIndex:indexPath.row];
  [place valueForKey:@"area"];
  [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
  NSIndexPath *path = [self.tableView indexPathForSelectedRow];
//
//  UINavigationController *navigationController = (UINavigationController *)segue.destinationViewController;
//  MainViewController *mainViewController = [[navigationController viewControllers] lastObject];
//
  NSDictionary *place = [self.savedPlaces objectAtIndex:path.row];
  BookmarkItemViewController *controller = (BookmarkItemViewController *)segue.destinationViewController;
  controller.selectedAreaGroup = [place valueForKey:@"area"];  
//
//  Place *place = [[Place alloc] init];
//  place.name = placeModel.name;
//  place.address = placeModel.address;
//  place.lat = placeModel.lat;
//  place.lng = placeModel.lng;
//  
//  mainViewController.place = place;
}

@end
