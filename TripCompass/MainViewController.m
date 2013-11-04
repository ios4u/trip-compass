//
//  MainViewController.m
//  TripCompass
//
//  Created by Eduardo Sasso on 7/1/13.
//  Copyright (c) 2013 Context Software. All rights reserved.
//

#import "MainViewController.h"
#import "SearchViewController.h"
#import "PlaceModel.h"

@interface MainViewController () <CLLocationManagerDelegate, UIAlertViewDelegate>
  
@end

@implementation MainViewController {
    CLLocationManager *locationManager;
    NSString *selectedLocation;
    float GeoAngle;
    id appDelegate;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  
  appDelegate = [[UIApplication sharedApplication] delegate];
  self.managedObjectContext = [appDelegate managedObjectContext];
  
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
  
  if (self.place) {
    self.navigationItem.title = self.place.name;
    double distance = [self.place distanceTo:self.currentLocation.coordinate toFormat:@"mi"];
    self.navigationItem.prompt = [Util stringWithDistance:distance];
    GeoAngle = [Util setLatLonForDistanceAndAngle:self.currentLocation.coordinate toCoordinate:[self.place getCoordinate]];
  }
  
//  NSString *lat = [NSString stringWithFormat:@"%.5f", self.currentLocation.coordinate.latitude];
//  NSString *lon = [NSString stringWithFormat:@"%.5f", self.currentLocation.coordinate.longitude];
//  NSLog(@"lat %@ -- lon %@", lat,lon);
}

- (void)locationManager:(CLLocationManager*)manager
       didUpdateHeading:(CLHeading*)newHeading {
  
  if (newHeading.headingAccuracy > 0) {
    float magneticHeading = newHeading.magneticHeading;
//    float trueHeading = newHeading.trueHeading;
    
    float heading = -1.0f * M_PI * magneticHeading / 180.0f;
//    image.transform = CGAffineTransformMakeRotation(heading);
    self.compassImage.transform = CGAffineTransformScale(self.compassImage.transform, 0.5, 0.5);
    self.compassImage.transform = CGAffineTransformMakeRotation(heading);
    
    if (self.place) {
//      float bearing = [Util getHeadingForDirectionFromCoordinate:self.currentLocation.coordinate toCoordinate:[self.place getCoordinate]];
//      float bearing = [Util setLatLonForDistanceAndAngle:self.currentLocation.coordinate toCoordinate:[self.place getCoordinate]];
//      float destinationHeading =  heading - bearing;
      self.needleImage.transform = CGAffineTransformScale(self.needleImage.transform, 0.5, 0.5);
//    self.needleImage.transform = CGAffineTransformMakeRotation(destinationHeading);
      float direction = -newHeading.trueHeading;  
      self.needleImage.transform = CGAffineTransformMakeRotation((direction* M_PI / 180)+ GeoAngle);
    }
  }
}

- (BOOL)locationManagerShouldDisplayHeadingCalibration:(CLLocationManager *)manager {
  return YES;
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
  NSLog(@"Can't report heading"); 
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Flipside View

- (void)flipsideViewControllerDidFinish:(FlipsideViewController *)controller
{
  [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
  if ([[segue identifier] isEqualToString:@"showAlternate"]) {
    [[segue destinationViewController] setDelegate:self];
  } else {
    UITabBarController *tabBarController = (UITabBarController *)segue.destinationViewController;
    SearchViewController *searchViewController = [tabBarController.viewControllers objectAtIndex:0];
    
    searchViewController.currentLocation = self.currentLocation.coordinate;
  }
}

- (IBAction)checkpointAction:(id)sender {
  UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Add Checkpoint" message:@"Save your current location to make sure you never get lost." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
  alert.alertViewStyle = UIAlertViewStylePlainTextInput;
  UITextField * alertTextField = [alert textFieldAtIndex:0];
  alertTextField.placeholder = @"e.g: Ace Hotel New York";
  
  [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
  NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
  if([title isEqualToString:@"OK"]) {
    NSString *name = [alertView textFieldAtIndex:0].text;
    
    NSManagedObjectContext *context = [self managedObjectContext];
    PlaceModel *placeModel = [NSEntityDescription insertNewObjectForEntityForName:@"PlaceModel" inManagedObjectContext:context];
    
    placeModel.name = name;
    placeModel.checkpoint = YES;
    placeModel.area = @"Checkpoints";
    
    
    placeModel.lat = [NSNumber numberWithFloat:self.currentLocation.coordinate.latitude];
    placeModel.lng = [NSNumber numberWithFloat:self.currentLocation.coordinate.longitude];
    
    NSError *error;
    if (![context save:&error]) {
      NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
    }

  }
}

@end
