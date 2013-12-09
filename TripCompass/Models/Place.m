//
//  Place.m
//  TripCompass
//
//  Created by Eduardo Sasso on 7/12/13.
//  Copyright (c) 2013 Context Software. All rights reserved.
//

#import "Place.h"
#import "Util.h"

@implementation Place

-(double)distanceTo:(CLLocationCoordinate2D)location {
  CLLocation *current = [[CLLocation alloc] initWithLatitude:location.latitude longitude:location.longitude];
  CLLocation *destination = [[CLLocation alloc] initWithLatitude:[self.lat doubleValue] longitude:[self.lng doubleValue]];
  
  //the distance is returned in meters by default
  return [current distanceFromLocation:destination];
}

-(NSString *)formattedDistanceTo:(CLLocationCoordinate2D)location {
  return [Util stringWithDistance: [self distanceTo:location]];
}

-(CLLocationCoordinate2D)getCoordinate {
  return CLLocationCoordinate2DMake([self.lat doubleValue], [self.lng doubleValue]);
}
@end