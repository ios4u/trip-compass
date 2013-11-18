//
//  CustomCell.h
//  TripCompass
//
//  Created by Eduardo Sasso on 11/4/13.
//  Copyright (c) 2013 Context Software. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *placeLabel;
@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;

- (CGFloat) calculateHeight:(NSString *)text;

@end
