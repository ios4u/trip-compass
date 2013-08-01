//
//  PlaceModel.h
//  TripCompass
//
//  Created by Eduardo Sasso on 7/31/13.
//  Copyright (c) 2013 Context Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface PlaceModel : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * lat;
@property (nonatomic, retain) NSNumber * lng;
@property (nonatomic, retain) NSDate * created;
@property (nonatomic, retain) NSString * desc;
@property (nonatomic, retain) NSString * address;

@end
