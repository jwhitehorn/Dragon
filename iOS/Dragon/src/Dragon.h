//
//  Dragon.h
//  Dragon
//
//  Created by Jason Whitehorn on 1/8/14.
//  Copyright (c) 2014 Jason Whitehorn. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <JavaScriptCore/JavaScriptCore.h>

@interface Dragon : NSObject

+ (Dragon *) defaultInstance;

- (void) loadFile:(NSString *)path encoding:(NSStringEncoding)enc error:(NSError **)error;
- (void) define:(NSString *)function withBlock:(id)block;
- (id) execute:(NSString *)statement;
- (id) callFunction:(NSString *)functionName withArguments:(NSArray *)args;
- (id) invokeBlock:(JSValue *)block;

@end