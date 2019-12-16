//
//  LLRedEnvelopManager.m
//  Demo111
//
//  Created by Lauren on 2019/12/14.
//  Copyright © 2019 Lauren. All rights reserved.
//

#import "LLRedEnvelopManager.h"

@implementation LLRedEnvelopManager

+ (instancetype)shareInstance
{
    static LLRedEnvelopManager *Token = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Token = [LLRedEnvelopManager new];
    });
    return Token;
}


@end
