
#import "ZSFakeTouch/ZSFakeTouch.h"

@class BaseChatCellView,BaseMsgContentViewController,WCPayC2CMessageCellView,WCPayC2CMessageViewModel,WCPayC2CMessageCellView;
@interface  ChatTableViewCell
- (BaseChatCellView *)cellView;
-(void)lltouchesWithPoint:(CGPoint)zspoint;
@end
@interface WCPayC2CMessageViewModel
- (unsigned long long)bubbleType;
@end

@interface WCPayC2CMessageCellView
-(WCPayC2CMessageViewModel *)viewModel;
-(UIView *)superview;
-(CGRect)frame;
@end

%hook ChatTableViewCell
- (void)layoutSubviews {
  %log; 
	%orig; 
	id llcellView  =  [self cellView];
	if ([llcellView isKindOfClass:NSClassFromString(@"WCPayC2CMessageCellView")])
	{
      WCPayC2CMessageCellView *llRedCellView = (WCPayC2CMessageCellView * )llcellView;
    	CGRect cellFrame = [[llRedCellView superview] convertRect:[llRedCellView frame]  toView:[[UIApplication sharedApplication] keyWindow]];
      WCPayC2CMessageViewModel *llViewModel = [llRedCellView viewModel];
      if (4 == [llViewModel bubbleType])
      {
          [self lltouchesWithPoint:CGPointMake(100, cellFrame.origin.y+30)];
      }
	}

}

%new
-(void)lltouchesWithPoint:(CGPoint)zspoint{
    [ZSFakeTouch beginTouchWithPoint:zspoint];
    [ZSFakeTouch endTouchWithPoint:zspoint];   
}

%end

