#import "BookmarkItemViewController.h"
#import "PlaceModel.h"
#import "Place.h"
#import "MainViewController.h"

@interface BookmarkItemViewController ()
@end

@implementation BookmarkItemViewController {
  int savedPlacesCount;
}

- (void)viewDidLoad {
  [super viewDidLoad];

  id delegate = [[UIApplication sharedApplication] delegate];
  self.managedObjectContext = [delegate managedObjectContext];
}

-(void)viewWillAppear:(BOOL)animated {
  self.navigationItem.rightBarButtonItem = self.editButtonItem;
  self.navigationItem.title = self.selectedAreaGroup;
  
  NSError *error;
  NSEntityDescription *entity = [NSEntityDescription entityForName:@"PlaceModel" inManagedObjectContext:self.managedObjectContext];
  NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
  
  [fetchRequest setEntity:entity];

  NSPredicate *predicate = [NSPredicate predicateWithFormat:@"area == %@", self.selectedAreaGroup];
  [fetchRequest setPredicate:predicate];
  
  self.savedPlaces = [[NSMutableArray alloc] initWithArray: [self.managedObjectContext executeFetchRequest:fetchRequest error:&error]];
  savedPlacesCount = [self.savedPlaces count];
  
  [self.tableView reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
  return savedPlacesCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
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
  cell.detailTextLabel.text = @"details";
  
  return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
  NSDictionary *place = [self.savedPlaces objectAtIndex:indexPath.row];
  
  NSEntityDescription *entity = [NSEntityDescription entityForName:@"PlaceModel" inManagedObjectContext:self.managedObjectContext];
  NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
  
  [fetchRequest setEntity:entity];
  
  NSPredicate *predicate = [NSPredicate predicateWithFormat:@"area == %@ AND name == %@", [place valueForKey:@"area"], [place valueForKey:@"name"]];
  [fetchRequest setPredicate:predicate];
  NSArray *results = [self.managedObjectContext executeFetchRequest:fetchRequest error:nil];
  
  for (NSManagedObject *managedObject in results) {
    [self.managedObjectContext deleteObject:managedObject];
  }
  
  --savedPlacesCount;
  [self.savedPlaces removeObjectAtIndex:indexPath.row];
  [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
  
  [self.managedObjectContext save:nil];
  
  if (savedPlacesCount == 0) {
    [self.navigationController popViewControllerAnimated:YES];
  }
  [self.tableView reloadData];
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
