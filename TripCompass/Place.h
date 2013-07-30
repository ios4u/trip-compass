//
//  Place.h
//  TripCompass
//
//  Created by Eduardo Sasso on 7/12/13.
//  Copyright (c) 2013 Context Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface Place : NSObject

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSNumber *lat;
@property (nonatomic, copy) NSNumber *lng;
@property (nonatomic, strong) NSString *description;
@property (nonatomic, strong) NSString *address;

-(double)distanceTo:(CLLocationCoordinate2D)currentLocation toFormat:(NSString *)format;
-(CLLocationCoordinate2D)getCoordinate;
@end
