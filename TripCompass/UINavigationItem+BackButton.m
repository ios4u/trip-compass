#import "UINavigationItem+BackButton.h"

@implementation UINavigationItem (BackButton)

-(UIBarButtonItem*)backBarButtonItem {
  UIBarButtonItem *backButton = [[UIBarButtonItem alloc]
                                 initWithTitle: @""
                                 style: UIBarButtonItemStyleBordered
                                 target: nil action: nil];
  
  return backButton;
}

@end
