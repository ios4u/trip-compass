//
//  CustomCell.m
//  TripCompass
//
//  Created by Eduardo Sasso on 11/4/13.
//  Copyright (c) 2013 Context Software. All rights reserved.
//

#import "CustomCell.h"

@implementation CustomCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
//      self.contentView.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

//- (void) layoutSubviews {
//  [super layoutSubviews];
//  
//  int diff = 20;
//  
//  self.placeLabel.frame = CGRectMake(self.textLabel.frame.origin.x,
//                                    self.textLabel.frame.origin.y,
//                                    20,
//                                    self.textLabel.frame.size.height);
//  
////  self.detailTextLabel.frame = CGRectMake(self.detailTextLabel.frame.origin.x - diff,
////                                          self.detailTextLabel.frame.origin.y,
////                                          self.detailTextLabel.frame.size.width + diff,
////                                          self.detailTextLabel.frame.size.height);
//  
//
//}

- (void)viewDidLayoutSubviews
{
  // Now that you know what the constraints gave you for the label's width, use that for the preferredMaxLayoutWidth—so you get the correct height for the layout
//  self.placeLabel.preferredMaxLayoutWidth = CGRectGetWidth(self.placeLabel.bounds);
  
  // And then layout again with the label's correct height.
  [self layoutSubviews];
}


@end
