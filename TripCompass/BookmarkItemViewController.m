//
//  BookmarkItemViewController.m
//  TripCompass
//
//  Created by Eduardo Sasso on 8/19/13.
//  Copyright (c) 2013 Context Software. All rights reserved.
//

#import "BookmarkItemViewController.h"
#import "PlaceModel.h"
#import "Place.h"
#import "MainViewController.h"

@interface BookmarkItemViewController ()

@end

@implementation BookmarkItemViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];

  id delegate = [[UIApplication sharedApplication] delegate];
  self.managedObjectContext = [delegate managedObjectContext];

//  NSLog(self.selectedAreaGroup);
  
  // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
  // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

-(void)viewWillAppear:(BOOL)animated {
//  set title
  NSError *error;
  NSEntityDescription *entity = [NSEntityDescription entityForName:@"PlaceModel" inManagedObjectContext:self.managedObjectContext];
  NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
  
  [fetchRequest setEntity:entity];

  NSPredicate *predicate = [NSPredicate predicateWithFormat:@"area == %@", self.selectedAreaGroup];
  [fetchRequest setPredicate:predicate];
  
  self.savedPlaces = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
   return [self.savedPlaces count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
  
    PlaceModel *placeModel = [self.savedPlaces objectAtIndex:indexPath.row];
  
    Place *place = [[Place alloc] init];
    place.name = placeModel.name;
    place.address = placeModel.address;
    place.lat = placeModel.lat;
    place.lng = placeModel.lng;
  
    cell.textLabel.text = place.name;
  //  double distance = [place distanceTo:self.currentLocation.coordinate toFormat:@"mi"];
  //  cell.detailTextLabel.text = [Util stringWithDistance:distance];

  return cell;
}

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
