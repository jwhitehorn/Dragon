//
//  Dragon.m
//  Dragon
//
//  Created by Jason Whitehorn on 1/8/14.
//  Copyright (c) 2014 Jason Whitehorn. All rights reserved.
//

#import "Dragon.h"

#define UI_THREAD      1
#define DEFAULT_THREAD 2

@interface Dragon ()

@property (strong, nonatomic) JSContext *jsContext;

- (void) registerBuiltInFunctions;

@end

@implementation Dragon

@synthesize jsContext;

- (id) init{
    self = [super init];
    if(self){
        jsContext = [[JSContext alloc] initWithVirtualMachine:[JSVirtualMachine new]];
        [self registerBuiltInFunctions];
    }
    return self;
}

+ (Dragon *) defaultInstance{
    static Dragon *instance = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        instance = [Dragon new];
    });
    return instance;
}

- (void) loadFile:(NSString *)path encoding:(NSStringEncoding)enc error:(NSError **)error{
    NSString *script = [NSString stringWithContentsOfFile:path encoding:enc error:error];
    if(script && !error){
        [jsContext evaluateScript:script];
    }
}

- (void) define:(NSString *)function withBlock:(id)block{
    jsContext[function] = block;
}

- (id) execute:(NSString *)statement{
    JSValue *result = [jsContext evaluateScript:statement];
    return [result toObject];
}

- (id) callFunction:(NSString *)functionName withArguments:(NSArray *)args{
    JSValue *function = jsContext[functionName];
    JSValue *result = [function callWithArguments:args];
    
    return [result toObject];
}

- (id) invokeBlock:(JSValue *)block{
    //http://trac.webkit.org/changeset/144489
    
    NSString *statement = [NSString stringWithFormat:@"(%@());", [block toString]];
    return [self execute:statement];
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

- (void) registerBuiltInFunctions{
    [self execute:@"var Dragon = {};"];
    [self execute:[NSString stringWithFormat:@"Dragon.UIThread = %i", UI_THREAD]];
    [self execute:[NSString stringWithFormat:@"Dragon.DefaultThread = %i", DEFAULT_THREAD]];
    
    [self define:@"__DragonDispatch" withBlock:^(int thread, JSValue *block){
        dispatch_queue_t queue = thread == UI_THREAD ? dispatch_get_main_queue()
                                                     : dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_async(queue, ^{
            [self invokeBlock:block];
        });
    }];
    [self execute:@"Dragon.Dispatch = __DragonDispatch;"];
    
    [self define:@"__DragonIsUIThread" withBlock:^{
        return [NSThread isMainThread];
    }];
    [self execute:@"Dragon.isUIThread = __DragonIsUIThread"];
}

@end
