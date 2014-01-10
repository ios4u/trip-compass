//
//  API.m
//  TripCompass
//
//  Created by Eduardo Sasso on 12/11/13.
//  Copyright (c) 2013 Context Software. All rights reserved.
//

#import "API.h"
#import <CoreLocation/CoreLocation.h>
#import "GogobotSignature.h"
#import "NSDictionary+QueryString.h"

#define BASE_URL @"http://api.gogobot.com/api/v3"
#define NEARBY_ENDPOINT @"/search/nearby_search.json"

@implementation API {
  double lat;
  double lng;
}

//TODO define type constants for POI's

-(id)initWithLatitude:(double)latitude longitude:(double)longitude {
  self = [super init];

  lat = latitude;
  lng = longitude;
  
  return self;
}

-(void)makeRequestWithEndpoint:(NSString *)endpoint params:(NSDictionary *)params {
  [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:TRUE];
  
  NSString *api = BASE_URL;
  api = [api stringByAppendingString:endpoint];
  api = [api stringByAppendingFormat:@"?%@", [params queryStringValue]];
  
  NSURL *url = [NSURL URLWithString:api];
  
  NSLog(@"API: %@", url);
  
  NSURLRequest *request = [GogobotSignature requestWithSignature:[NSURLRequest requestWithURL:url]];
  
  NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
  NSURLSession *session = [NSURLSession sessionWithConfiguration:config];
  
  NSURLSessionDataTask *task = [session dataTaskWithRequest:request
                                          completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                            dispatch_async(dispatch_get_main_queue(), ^{
                                              [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:FALSE];
                                              
                                              NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
                                              if (httpResponse.statusCode == 200) {
                                                [self handleResults:data];
                                              } else {
                                                //TODO verify if need this else statement.
                                                NSString *error = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                                                NSLog(@"Received HTTP %d: %@", httpResponse.statusCode, error);
                                              }
                                            });
                                          }];
  [task resume];
}

-(void)handleResults:(NSData *)data {
  NSError *jsonError;
  NSDictionary *response = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&jsonError];
  
  if (response) {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"apiResultsNotification" object:self userInfo:response];
  } else {
    //TODO this error should go somewhere
    NSLog(@"Error, %@", jsonError);
  }
}

//TODO DRY - too much repeated stuff here
-(void)getPlacesNearby {
  [self getPlacesNearbyPage:1];
}

-(void)getPlacesNearbyPage:(NSInteger)page {
  NSDictionary *params = @{
                           @"lat"  : [[NSNumber numberWithDouble: lat] stringValue],
                           @"lng"  : [[NSNumber numberWithDouble: lng] stringValue],
                           @"page" : [[NSNumber numberWithInt: page] stringValue]
                          };
  
  [self makeRequestWithEndpoint:NEARBY_ENDPOINT params:params];
}

-(void)searchPlacesNearby:(NSString *)query {
  NSDictionary *params = @{
                           @"lat" : [[NSNumber numberWithDouble: lat] stringValue],
                           @"lng" : [[NSNumber numberWithDouble: lng] stringValue],
                           @"query" : query
                          };
  
  [self makeRequestWithEndpoint:NEARBY_ENDPOINT params:params];
}

-(void)getRestaurantsNearby {
  NSDictionary *params = @{
                           @"lat" : [[NSNumber numberWithDouble: lat] stringValue],
                           @"lng" : [[NSNumber numberWithDouble: lng] stringValue],
                           @"type" : @"Restaurant"
                           };
  
  [self makeRequestWithEndpoint:NEARBY_ENDPOINT params:params];
}

-(void)getAttractionsNearby {
  NSDictionary *params = @{
                           @"lat" : [[NSNumber numberWithDouble: lat] stringValue],
                           @"lng" : [[NSNumber numberWithDouble: lng] stringValue],
                           @"type" : @"Attraction"
                           };
  
  [self makeRequestWithEndpoint:NEARBY_ENDPOINT params:params];
}

-(void)getHotelsNearby {
  NSDictionary *params = @{
                           @"lat" : [[NSNumber numberWithDouble: lat] stringValue],
                           @"lng" : [[NSNumber numberWithDouble: lng] stringValue],
                           @"type" : @"Hotel"
                           };
  [self makeRequestWithEndpoint:NEARBY_ENDPOINT params:params];
}

@end
