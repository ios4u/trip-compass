//
//  NSString+QueryString.h
//  TripCompass
//
//  Created by Eduardo Sasso on 12/17/13.
//  Copyright (c) 2013 Context Software. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (QueryString)

-(NSDictionary *)httpParams;

@end
