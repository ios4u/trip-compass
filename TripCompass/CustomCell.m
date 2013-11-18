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
  }
  return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
  [super setSelected:selected animated:animated];
}

- (CGFloat) calculateHeight:(NSString *)text {
  self.placeLabel.text =  text;
  self.placeLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
  
  [self.contentView setNeedsLayout];
  [self.contentView layoutIfNeeded];
  
  CGFloat height = [self.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
  
  //+1 is the only way to get the height right, seems to be a bug from Apple
  return height + 1;
}

@end
