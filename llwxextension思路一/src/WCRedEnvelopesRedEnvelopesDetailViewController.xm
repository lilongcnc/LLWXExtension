#import "Helper/LLRedEnvelopManager.h"


%hook WCRedEnvelopesRedEnvelopesDetailViewController
- (id)init { 
	%log;
	if ([LLRedEnvelopManager shareInstance].isGettingRedEnvelop)
	{
		return nil;
	}
	else {
		id r = %orig;
	    HBLogDebug(@" = %@", r);
	    return r; 
	}	
}
	 
%end
