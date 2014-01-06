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

#define BASE_URL @"http://api.gogobot.com/api/v3"
#define NEARBY_ENDPOINT @"/search/nearby_search.json"

@implementation API {
  double lat;
  double lng;
}

//TODO define type constants for POI's

-(id)initWithLatitude:(double)newLat longitude:(double)newLng {
  self = [super init];

  lat = newLat;
  lng = newLng;
  
  return self;
}

-(void) makeRequest {
  [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:TRUE];
  
  NSString *api = BASE_URL;
  api = [api stringByAppendingString:NEARBY_ENDPOINT];
  api = [api stringByAppendingFormat:@"?lat=%f&lng=%f", lat,lng];
  
  NSURL *url = [NSURL URLWithString:api];
  
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
    //TODO this error shuold go somewhere
    NSLog(@"Error, %@", jsonError);
  }
}

-(NSArray *)getPlacesNearby {
  [self makeRequest];
  return nil;
}

-(NSArray *)getPopularRestaurantsNearby {
  return nil;
}

-(NSArray *)getPopularAttractionsNearby {
  return nil;
}

-(NSArray *)getPopularHotelsNearby {
  return nil;
}

@end
