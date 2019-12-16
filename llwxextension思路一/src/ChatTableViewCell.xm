
@class BaseChatCellView,BaseMsgContentViewController,WCPayC2CMessageCellView,WCPayC2CMessageViewModel,WCPayC2CMessageCellView;

@interface  ChatTableViewCell
- (BaseChatCellView *)cellView;
- (void)ll_getReadEnvelops:(id)arg1;
@end

@interface BaseMsgContentViewController
- (void)tapAppNodeView:(id)arg1;

@end


@interface WCPayC2CMessageCellView
-(WCPayC2CMessageViewModel *)viewModel;
-(CGRect)frame;
-(UIView *)superview;

@end


@interface WCPayC2CMessageViewModel
- (unsigned long long)bubbleType;
@end


%hook ChatTableViewCell

- (void)setDelegate:(id)arg1 { 
  %log; 
  %orig; 
  [self ll_getReadEnvelops:arg1];
}


%new
- (void)ll_getReadEnvelops:(id)arg1
{
  BaseMsgContentViewController *llsuperVC = (BaseMsgContentViewController *)arg1;
  id llcellView  =  [self cellView];
  if ([llcellView isKindOfClass:NSClassFromString(@"WCPayC2CMessageCellView")])
  {
      WCPayC2CMessageCellView *llRedCellView = (WCPayC2CMessageCellView * )llcellView;
      WCPayC2CMessageViewModel *llViewModel = [llRedCellView viewModel];
      if (4 == [llViewModel bubbleType])
      {
        HBLogDebug(@"lilong-didSelectRowAtIndexPath5-showRedView = %llu", [llViewModel bubbleType]);
        [llsuperVC tapAppNodeView:llRedCellView];
      }
  }
}


%end

