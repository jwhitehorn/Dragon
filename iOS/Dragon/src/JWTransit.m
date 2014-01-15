//
//  JWTransit.m
//  TransitTestsIOS
//
//  Created by Jason Whitehorn on 1/8/14.
//  Copyright (c) 2014 Jason Whitehorn. All rights reserved.
//

#import "JWTransit.h"

#define UI_THREAD      1
#define DEFAULT_THREAD 2

@interface JWTransit ()

@property (strong, nonatomic) JSContext *jsContext;

- (void) registerBuiltInFunctions;

@end

@implementation JWTransit

@synthesize jsContext;

- (id) init{
    self = [super init];
    if(self){
        jsContext = [[JSContext alloc] initWithVirtualMachine:[JSVirtualMachine new]];
        [self registerBuiltInFunctions];
    }
    return self;
}

- (void) loadFile:(NSString *)path encoding:(NSStringEncoding)enc error:(NSError **)error{
    [jsContext evaluateScript:[NSString stringWithContentsOfFile:path encoding:enc error:error]];
}

- (void) define:(NSString *)function withBlock:(id)block{
    jsContext[function] = block;
}

- (id) execute:(NSString *)statement{
    NSString *result = [[jsContext evaluateScript:statement] toString];
    return [result isEqualToString:@"undefined"] ? nil : result;
}

- (id) invokeBlock:(JSValue *)block{
    //http://trac.webkit.org/changeset/144489
    
    NSString *statement = [NSString stringWithFormat:@"(%@());", [block toString]];
    return [self execute:statement];
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

- (void) registerBuiltInFunctions{
    [self execute:@"var JWTransit = {};"];
    [self execute:[NSString stringWithFormat:@"JWTransit.UIThread = %i", UI_THREAD]];
    [self execute:[NSString stringWithFormat:@"JWTransit.UIThread = %i", DEFAULT_THREAD]];
    
    [self define:@"__JWTransitDispatch" withBlock:^(int thread, JSValue *block){
        dispatch_queue_t queue = thread == UI_THREAD ? dispatch_get_main_queue()
                                                     : dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_async(queue, ^{
            [self invokeBlock:block];
        });
    }];
    [self execute:@"JWTransit.Dispatch = __JWTransitDispatch;"];
    
    [self define:@"__JWTransitIsUIThread" withBlock:^{
        return [NSThread isMainThread];
    }];
    [self execute:@"JWTransit.isUIThread = __JWTransitIsUIThread"];
}

@end
