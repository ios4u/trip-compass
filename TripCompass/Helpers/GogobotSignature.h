//
//  GogobotSignature.h
//  TripCompass
//
//  Created by Eduardo Sasso on 12/19/13.
//  Copyright (c) 2013 Context Software. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GogobotSignature : NSObject

+ (NSURLRequest *)requestWithSignature:(NSURLRequest *)request;

@end
