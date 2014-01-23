//
//  DragonDAO.h
//  Dragon
//
//  Created by Jason Whitehorn on 1/17/14.
//  Copyright (c) 2014 Jason Whitehorn. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Dragon.h"

@interface DragonDAO : NSObject

- (id) initWithDragon:(Dragon *)dragon;
- (void) invokeFunction:(NSString *)functionName withArguments:(NSArray *)args andCallback:(void(^)(id))block;

@end
