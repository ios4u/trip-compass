//
//  Place.m
//  TripCompass
//
//  Created by Eduardo Sasso on 7/12/13.
//  Copyright (c) 2013 Context Software. All rights reserved.
//

#import "Place.h"

@implementation Place

-(double)distanceTo:(CLLocationCoordinate2D)currentLocation toFormat:(NSString *)format {
  
  CLLocation *current = [[CLLocation alloc] initWithLatitude:currentLocation.latitude longitude:currentLocation.longitude];
  CLLocation *destination = [[CLLocation alloc] initWithLatitude:[self.lat doubleValue] longitude:[self.lng doubleValue]];
  
  return [current distanceFromLocation:destination];
}

@end