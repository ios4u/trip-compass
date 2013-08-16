//
//  PlaceModel.m
//  TripCompass
//
//  Created by Eduardo Sasso on 7/31/13.
//  Copyright (c) 2013 Context Software. All rights reserved.
//

#import "PlaceModel.h"


@implementation PlaceModel

@dynamic name;
@dynamic lat;
@dynamic lng;
@dynamic created;
@dynamic desc;
@dynamic address;
@dynamic checkpoint;
@dynamic area;

- (void)awakeFromInsert {
  [super awakeFromInsert];
  self.created = [NSDate date];  
}

@end
