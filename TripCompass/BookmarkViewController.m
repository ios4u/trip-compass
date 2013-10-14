#import "BookmarkViewController.h"
#import "MainViewController.h"
#import "BookmarkItemViewController.h"
#import "Place.h"
#import "PlaceModel.h"

@interface BookmarkViewController () <CLLocationManagerDelegate>
@end

@implementation BookmarkViewController {
  CLLocationManager *locationManager;
  int savedPlacesCount;
}

- (void)viewDidLoad {
  [super viewDidLoad];

  // Fix the header under status bar
  self.tableView.contentInset = UIEdgeInsetsMake(self.tabBarController.topLayoutGuide.length, 0, 0, 0);

  id delegate = [[UIApplication sharedApplication] delegate];
  self.managedObjectContext = [delegate managedObjectContext];
  self.tabBarController.navigationItem.rightBarButtonItem = self.editButtonItem;
}

-(void)viewWillAppear:(BOOL)animated {
//  self.edgesForExtendedLayout = UIRectEdgeNone;
//  self.automaticallyAdjustsScrollViewInsets = YES;

//  self.tabBarController.navigationItem.title = @"Saved list";
//    self.tabBarController.navigationItem.title = @"";
  
  
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
  savedPlacesCount = [self.savedPlaces count];
  
  [self.tableView reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
 return savedPlacesCount;
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

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
  NSDictionary *place = [self.savedPlaces objectAtIndex:indexPath.row];
  
  NSEntityDescription *entity = [NSEntityDescription entityForName:@"PlaceModel" inManagedObjectContext:self.managedObjectContext];
  NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
  
  [fetchRequest setEntity:entity];
  
  NSPredicate *predicate = [NSPredicate predicateWithFormat:@"area == %@", [place valueForKey:@"area"]];
  [fetchRequest setPredicate:predicate];
  NSArray *results = [self.managedObjectContext executeFetchRequest:fetchRequest error:nil];
  
  for (NSManagedObject *managedObject in results) {
    [self.managedObjectContext deleteObject:managedObject];
  }
  --savedPlacesCount;
  [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
  
  [self.managedObjectContext save:nil];
  
  [self.tableView reloadData];
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
