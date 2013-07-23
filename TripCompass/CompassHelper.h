//
//  Navigation.h
//  TripCompass
//
//  Created by Eduardo Sasso on 7/5/13.
//  Copyright (c) 2013 Context Software. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CompassHelper : NSObject
- (float) getBearingFromCoordinate:(float)from toCoordinate:(float)to;
@end
