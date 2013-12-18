//
//  API.m
//  TripCompass
//
//  Created by Eduardo Sasso on 12/11/13.
//  Copyright (c) 2013 Context Software. All rights reserved.
//

#import "API.h"
#import <CoreLocation/CoreLocation.h>
#import "NSString+QueryString.h"
#import "NSData+Base64.h"

#include <CommonCrypto/CommonHMAC.h>

#define GOGOBOT_OAUTH_CLIENT_ID @"0b4a01e2dd2cd6bf74f52a0e34db5626e32552ff6b86690e51fd3e73f9c6ac56"
#define GOGOBOT_OAUTH_CLIENT_SECRET @"a7894673ccf9f2f0d2db879dd5cd4b6a72bb0b18aec67b32be756faa544c65f7"

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
  
  NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
  [request addValue:GOGOBOT_OAUTH_CLIENT_ID forHTTPHeaderField:@"Gogobot-ClientID"];

  NSString *signature = [self apiSignatureFromRequest:request];
  [request addValue:[signature stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] forHTTPHeaderField:@"Gogobot-Signature"];

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
    NSLog(@"resuts %@", response[@"results"]);
  } else {
    NSLog(@"Error, %@", jsonError);
  }
}

- (NSString *)apiSignatureFromRequest:(NSURLRequest *)request {
  NSMutableDictionary *params;
  
  NSURL *url = [request URL];

  params = [url query] ? [[[url query] httpParams] mutableCopy] : [NSMutableDictionary dictionary];
  
  [params setValue:GOGOBOT_OAUTH_CLIENT_ID forKey:@"client_id"];
  
  NSMutableString* signature = [NSMutableString stringWithCapacity:512];
  NSArray* keys = [params.allKeys sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
  for (id key in [keys objectEnumerator]) {
    id value = [params valueForKey:key];
    if ([value isKindOfClass:[NSString class]]) {
      [signature appendFormat:@"%@%@", key, value];
    }
  }
  [signature appendString:GOGOBOT_OAUTH_CLIENT_SECRET];
  
  const char *cKey  = [GOGOBOT_OAUTH_CLIENT_SECRET cStringUsingEncoding:NSUTF8StringEncoding];
  const char *cData = [signature cStringUsingEncoding:NSUTF8StringEncoding];
  
  unsigned char cHMAC[CC_SHA256_DIGEST_LENGTH];
  
  CCHmac(kCCHmacAlgSHA256, cKey, strlen(cKey), cData, strlen(cData), cHMAC);
  NSData *HMAC = [[NSData alloc] initWithBytes:cHMAC length:sizeof(cHMAC)];
  
  //NSData-Base64: https://github.com/l4u/NSData-Base64
  return [HMAC base64EncodedString];
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
