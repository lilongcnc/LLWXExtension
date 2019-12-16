
#import "Helper/LLRedEnvelopManager.h"

@interface WCRedEnvelopesReceiveHomeView
- (void)OnOpenRedEnvelopes;
- (void)removeView;
@end

%hook WCRedEnvelopesReceiveHomeView


- (id)initWithFrame:(struct CGRect)arg1 andData:(id)arg2 delegate:(id)arg3 { 
	%log;
	arg1 = CGRectMake(0, 0, 0, 0);
	id r = %orig;
	HBLogDebug(@" = %@", r); 
	[LLRedEnvelopManager shareInstance].isGettingRedEnvelop = YES;
	[self OnOpenRedEnvelopes]; // 领取红包
	return r; 
}

%end
