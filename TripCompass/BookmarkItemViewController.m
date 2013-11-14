#import "BookmarkItemViewController.h"
#import "PlaceModel.h"
#import "Place.h"
#import "MainViewController.h"
#import "AppDelegate.h"

@interface BookmarkItemViewController ()
@end

@implementation BookmarkItemViewController {
  int savedPlacesCount;
  id delegate;
}

- (void)viewDidLoad {
  [super viewDidLoad];

  delegate = [[UIApplication sharedApplication] delegate];
  self.managedObjectContext = [delegate managedObjectContext];
  
  [self.tableView registerNib:[UINib nibWithNibName:@"CustomCell" bundle:nil] forCellReuseIdentifier:@"customCell"];
  
  self.tableView.estimatedRowHeight = 43;
  
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(preferredContentSizeChanged:) name:UIContentSizeCategoryDidChangeNotification object:nil];
}

- (void)preferredContentSizeChanged:(NSNotification *)aNotification {
  // adjust the layout of the cells
//  [self.view setNeedsLayout];
  [self.tableView reloadData];
  // refresh view...
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
  static NSString *CellIdentifier = @"customCell";
//  static NSString *CellIdentifier = @"Cell";
  CustomCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
//  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
  
  PlaceModel *placeModel = [self.savedPlaces objectAtIndex:indexPath.row];
  
  Place *place = [[Place alloc] init];
  place.name = placeModel.name;
//  place.name = @"Porto Alegre Porto Alegre Rio de Janeiro Goias Campinas Mato Grosso Porto Alegre Porto Alegre Rio de Janeiro Goias Campinas Mato Grosso";
  place.address = placeModel.address;
  place.lat = placeModel.lat;
  place.lng = placeModel.lng;
 
  
  cell.placeLabel.text = place.name;
  cell.placeLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];

//  cell.placeLabel.text =   @"Hot Wok Online Delivery Super Store";

//    [cell.placeLabel setPreferredMaxLayoutWidth:10];
//[cell.placeLabel sizeToFit];
  
//  cell.textLabel.text = place.name;
//    cell.textLabel.text = @"Porto Alegre Porto Alegre Rio de Janeiro Goias Campinas Mato Grosso";
  
  double distance = [place distanceTo:[(AppDelegate*)delegate currentLocation] toFormat:@"mi"];
//  cell.detailTextLabel.text = [Util stringWithDistance:distance];
  cell.distanceLabel.text = [Util stringWithDistance:distance];

  return cell;
}

//- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
//  return 150.0f;
//}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
//  http://www.peterboni.net/blog/2013/06/29/ios-7-dynamic-type/
//  return 300;
  
//  PlaceModel *placeModel = [self.savedPlaces objectAtIndex:indexPath.row];
//
//
//  CGFloat PADDING_OUTER = 10;
//  CGFloat totalHeight = PADDING_OUTER + nameLabelFontSize.height + PADDING_OUTER;
//  
//  return totalHeight;
  
//  return labelRect.size;

//  PlaceModel *placeModel = [self.savedPlaces objectAtIndex:indexPath.row];
//  
//  CGSize maximumLabelSize = CGSizeMake(308,9999);
//  UIFont *font=[UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
//  CGRect textRect = [placeModel.name  boundingRectWithSize:maximumLabelSize   options:NSStringDrawingUsesLineFragmentOrigin  attributes:@{NSFontAttributeName:font} context:nil];
//  CGFloat height = textRect.size.height;
//  return 12 + height + 12;
//  return 200;
  
  CustomCell *cell = [tableView dequeueReusableCellWithIdentifier:@"customCell"];
  //  CustomCell *cell = [tableView dequeueReusableCellWithIdentifier:@"customCell" forIndexPath:indexPath];
  PlaceModel *placeModel = [self.savedPlaces objectAtIndex:indexPath.row];

  cell.placeLabel.text =  placeModel.name;
  cell.placeLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
//
//  UIFont *nameLabelFont = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
//  CGSize nameLabelFontSize = [cell.placeLabel.text sizeWithAttributes:[NSDictionary dictionaryWithObject:nameLabelFont forKey:NSFontAttributeName]];

//  cell.placeLabel.text =  @"Hot Wok Online Delivery Super Store";
  
//  [cell.contentView updateConstraintsIfNeeded];
//  [cell.contentView layoutIfNeeded];
  
//  [cell updateConstraintsForWitdh:self.view.bounds.size.width];
  
//  [cell setNeedsUpdateConstraints];
//  [cell updateConstraintsIfNeeded];
//  

  [cell.contentView setNeedsLayout];
  [cell.contentView layoutIfNeeded];
  
//  CGFloat height = [cell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
  
//  CGSize maximumSize = CGSizeMake(320.0, UILayoutFittingCompressedSize.height);
//  CGFloat height = [cell.contentView systemLayoutSizeFittingSize:maximumSize].height;
//  CGFloat height = [cell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height + nameLabelFontSize.height;

  CGFloat height = [cell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
  
//  return ceil(height) + 1;
  
  // Note that depending on your constraints & subviews, height may sometimes be ever so slightly less than what's actually required,
  // probably due to internal rounding errors in the Auto Layout constraint solver. There are a couple ways to fix this,
  // the simplest of which is to just add one or more extra points to height and return that slightly larger value.
  return height +1;

}

//- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
//  PlaceModel *placeModel = [self.savedPlaces objectAtIndex:indexPath.row];
//  UIFont *nameLabelFont = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
//  CGSize nameLabelFontSize = [[placeModel name] sizeWithAttributes:[NSDictionary dictionaryWithObject:nameLabelFont forKey:NSFontAttributeName]];
//  return nameLabelFontSize.height;
//}

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
