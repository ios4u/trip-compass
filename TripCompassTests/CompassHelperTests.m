//
//  CompassHelperTests.m
//  TripCompass
//
//  Created by Eduardo Sasso on 7/5/13.
//  Copyright (c) 2013 Context Software. All rights reserved.
//

#import "CompassHelperTests.h"
#import "CompassHelper.h"

@implementation CompassHelperTests

-(void)testBearing {
  CompassHelper *compass = [[CompassHelper alloc] init];
  [compass getBearingFromCoordinate:1 toCoordinate:1];
  NSLog(@"+++testing ");
  STFail(@"Unit tests are not implemented yet in Bearing");
//  http://www.techrepublic.com/blog/ios-app-builder/better-and-cleaner-code-unit-testing-with-xcode/520
}

@end
