//
//  NSError+KIFAdditions.m
//  KIF
//
//  Created by Brian Nickel on 7/27/13.
//
//

#import "NSError-KIFAdditions.h"
#import "LoadableCategory.h"


@implementation NSError (KIFAdditions)

+ (instancetype)KIFErrorWithFormat:(NSString *)format, ...
{
    va_list args;
    va_start(args, format);
    NSString *description = [[NSString alloc] initWithFormat:format arguments:args];
    va_end(args);
    
    return [self errorWithDomain:@"KIFTest" code:10000 userInfo:@{NSLocalizedDescriptionKey: description}];
}

+ (instancetype)KIFErrorWithUnderlyingError:(NSError *)underlyingError format:(NSString *)format, ...
{
    va_list args;
    va_start(args, format);
    NSString *description = [[NSString alloc] initWithFormat:format arguments:args];
    va_end(args);
    
    NSDictionary *userInfo = [[NSDictionary alloc] initWithObjectsAndKeys:description, NSLocalizedDescriptionKey, underlyingError, NSUnderlyingErrorKey, nil];
    
    return [self errorWithDomain:@"KIFTest" code:10000 userInfo:userInfo];
}

@end
