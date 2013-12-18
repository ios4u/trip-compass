//
//  NSString+QueryString.m
//  TripCompass
//
//  Created by Eduardo Sasso on 12/17/13.
//  Copyright (c) 2013 Context Software. All rights reserved.
//

#import "NSString+QueryString.h"

@implementation NSString (QueryString)

- (NSString*)stringByUnescapingFromURLArgument {
	NSMutableString *resultString = [NSMutableString stringWithString:self];
	[resultString replaceOccurrencesOfString:@"+"
                                withString:@" "
                                   options:NSLiteralSearch
                                     range:NSMakeRange(0, [resultString length])];
	return [resultString stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

- (NSDictionary *)httpParams {
  NSMutableDictionary* ret = [NSMutableDictionary dictionary];
	NSArray* components = [self componentsSeparatedByString:@"&"];
	// Use reverse order so that the first occurrence of a key replaces
	// those subsequent.
	for (NSString* component in [components reverseObjectEnumerator]) {
		if ([component length] == 0)
			continue;
		NSRange pos = [component rangeOfString:@"="];
		NSString *key;
		NSString *val;
		if (pos.location == NSNotFound) {
			key = [component stringByUnescapingFromURLArgument];
			val = @"";
		} else {
			key = [[component substringToIndex:pos.location]
             stringByUnescapingFromURLArgument];
			val = [[component substringFromIndex:pos.location + pos.length]
             stringByUnescapingFromURLArgument];
		}
		// stringByUnescapingFromURLArgument returns nil on invalid UTF8
		// and NSMutableDictionary raises an exception when passed nil values.
		if (!key) key = @"";
		if (!val) val = @"";
		[ret setObject:val forKey:key];
	}
	return ret;
}

@end
