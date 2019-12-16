//
//  LLRedEnvelopManager.h
//  Demo111
//
//  Created by Lauren on 2019/12/14.
//  Copyright © 2019 Lauren. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LLRedEnvelopManager : NSObject
@property (nonatomic, assign) BOOL isGettingRedEnvelop;

+ (instancetype)shareInstance;
@end

