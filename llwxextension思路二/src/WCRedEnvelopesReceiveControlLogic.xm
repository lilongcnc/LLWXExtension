
#import "Helper/LLRedEnvelopManager.h"

%hook WCRedEnvelopesReceiveControlLogic

- (void)closeAnimationWindowAndShowDetailView:(id)arg1 { // MMUIWindow
	%log;
	[LLRedEnvelopManager shareInstance].isGettingRedEnvelop = NO;
	%orig; 
}

%end
