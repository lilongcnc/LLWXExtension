//
//  UIViewController+LLWXHelper.m
//  Demo111
//
//  Created by Lauren on 2019/12/14.
//  Copyright © 2019 Lauren. All rights reserved.
//

#import "UIViewController+LLWXHelper.h"
#import <objc/runtime.h>
#import "LLRedEnvelopManager.h"
@implementation UIViewController (LLWXHelper)

+ (void)load {
	NSLog(@"替换presentViewController1");
    method_exchangeImplementations(class_getInstanceMethod(self,@selector(presentViewController:animated:completion:)),class_getInstanceMethod(self,@selector(ll_presentViewController:animated:completion:)));
}


- (void)ll_presentViewController:(UIViewController *)viewControllerToPresent animated: (BOOL)flag completion:(void (^ __nullable)(void))completion {
	NSLog(@"替换presentViewController");
		NSLog(@" = %d", [LLRedEnvelopManager shareInstance].isGettingRedEnvelop);
		NSLog(@" = %@", viewControllerToPresent);
	if ([LLRedEnvelopManager shareInstance].isGettingRedEnvelop && [viewControllerToPresent isKindOfClass:NSClassFromString(@"MMUINavigationController")]){
        NSLog(@"拦截红包跳转");
    }
    else{
    	NSLog(@"没有拦截红包跳转");
        [self ll_presentViewController:viewControllerToPresent animated:flag completion:nil];
    }
}


@end
