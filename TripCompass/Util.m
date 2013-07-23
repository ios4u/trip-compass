//
//  Util.m
//  Pods
//
//  Created by Eduardo Sasso on 7/22/13.
//
//

#import "Util.h"

@implementation Util

#define METERS_TO_FEET  3.2808399
#define METERS_TO_MILES 0.000621371192
#define METERS_CUTOFF   1000
#define FEET_CUTOFF     3281
#define FEET_IN_MILES   5280

+ (NSString *)stringWithDistance:(double)distance {
  BOOL isMetric = [[[NSLocale currentLocale] objectForKey:NSLocaleUsesMetricSystem] boolValue];
  
  NSString *format;
  
  if (isMetric) {
    if (distance < METERS_CUTOFF) {
      format = @"%@ metres";
    } else {
      format = @"%@ km";
      distance = distance / 1000;
    }
  } else { // assume Imperial / U.S.
    distance = distance * METERS_TO_FEET;
    if (distance < FEET_CUTOFF) {
      format = @"%@ feet";
    } else {
      format = @"%@ miles";
      distance = distance / FEET_IN_MILES;
    }
  }
  
  NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc]init];
  [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
  [numberFormatter setRoundingMode:NSNumberFormatterRoundHalfUp];
  [numberFormatter setMaximumFractionDigits:2];
  NSString *roundDistance = [numberFormatter stringFromNumber:[NSNumber numberWithFloat:distance]];
  
  return [NSString stringWithFormat:format, roundDistance];
}

@end
