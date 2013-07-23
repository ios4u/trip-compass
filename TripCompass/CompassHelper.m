//
//  Navigation.m
//  TripCompass
//
//  Created by Eduardo Sasso on 7/5/13.
//  Copyright (c) 2013 Context Software. All rights reserved.
//

#import "CompassHelper.h"

@implementation CompassHelper

- (float) getBearingFromCoordinate:(float)from toCoordinate:(float)to
{
  NSLog(@"+++here");
  
//  float fLat = fromLoc.latitude;
//  float fLng = fromLoc.longitude;
//  float tLat = toLoc.latitude;
//  float tLng = toLoc.longitude;
//  
//  return atan2(sin(fLng-tLng)*cos(tLat), cos(fLat)*sin(tLat)-sin(fLat)*cos(tLat)*cos(fLng-tLng));
//  http://stackoverflow.com/questions/4130821/iphone-compass-gps-direction
//  http://www.sundh.com/blog/2011/09/stabalize-compass-of-iphone-with-gyroscope/
//  https://github.com/tadelv/CLLocation-Bearing/blob/master/CLLocation%2BBearing.m
}

@end
