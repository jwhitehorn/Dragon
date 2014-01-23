//
//  DragonDAO.m
//  Dragon
//
//  Created by Jason Whitehorn on 1/17/14.
//  Copyright (c) 2014 Jason Whitehorn. All rights reserved.
//

#import "DragonDAO.h"

@interface DragonDAO ()

@property (strong, nonatomic) Dragon *context;

@end

@implementation DragonDAO
@synthesize context;

- (id) init{
    self = [super init];
    if(self){
        context = [Dragon defaultInstance];
    }
    return self;
}

- (id) initWithDragon:(Dragon *)dragon{
    self = [super init];
    if(self){
        context = dragon;
    }
    return self;
}

- (void) invokeFunction:(NSString *)functionName withArguments:(NSArray *)args andCallback:(void(^)(id))block{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        id result = [context callFunction:functionName withArguments:args];
        if(block){
            dispatch_async(dispatch_get_main_queue(), ^{
                block(result);
            });
        }
    });
}

@end
