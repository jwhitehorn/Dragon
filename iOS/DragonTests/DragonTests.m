//
//  DragonTests.m
//  DragonTests
//
//  Created by Jason Whitehorn on 1/8/14.
//  Copyright (c) 2014 Jason Whitehorn. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "Dragon.h"
#import <JavaScriptCore/JavaScriptCore.h>
#import "TestHelpers.h"

@interface DragonTests : XCTestCase

@property (strong, nonatomic) Dragon *transit;

@end

@implementation DragonTests
@synthesize transit;

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    transit = [Dragon new];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void) testDefine{
    [transit define:@"sum" withBlock:^(int a, int b){
        return a + b;
    }];
}

- (void) testDefineResults{
    [transit define:@"sum" withBlock:^(int a, int b){
        return a + b;
    }];
    
    int sum = [[transit execute:@"sum(6,8);"] intValue];
    
    XCTAssertEqual(sum, 14, @"Should equal");
}

- (void) testCallUndefinedMethod{
    id result = [transit execute:@"foo('bar');"];
    XCTAssertNil(result, @"Result should be nil");
}

- (void) testCallFunctionWithArguments{
    [transit define:@"sum" withBlock:^(int a, int b){
        return a + b;
    }];
    NSNumber *result = [transit callFunction:@"sum" withArguments:@[@4, @5]];
    XCTAssertEqualObjects(result, @9, @"Should equal nine!");
}

- (void) testCallback{
    __block bool success = false;
    [transit define:@"success" withBlock:^{
        success = true;
    }];
    [transit define:@"callMeBack" withBlock:^(JSValue *block){
        [transit invokeBlock:block];
    }];
    
    [transit execute:@"callMeBack(function(){ success(); });"];
    XCTAssertTrue(success, @"Success method not called");
}

- (void) testGCDCallback{
    StartBlock();
    [transit define:@"success" withBlock:^{
        EndBlock();
        XCTAssertTrue(true, @"Success method not called");
    }];
    [transit define:@"callMeBack" withBlock:^(JSValue *block){
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            [NSThread sleepForTimeInterval:5];
            dispatch_async(dispatch_get_main_queue(), ^{
                [transit invokeBlock:block];
            });
        });
    }];
    
    [transit execute:@"callMeBack(function(){ success(); });"];
    WaitUntilBlockCompletes();
}

- (void) testCallFromGCDBlock{
    StartBlock();
    
    [transit define:@"success" withBlock:^{
        EndBlock();
        
        XCTAssertTrue(true, @"Success method not called");
    }];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [transit execute:@"success();"];
    });
    
    WaitUntilBlockCompletes();
}

- (void) testTransitDispatch{
    StartBlock();
    [transit define:@"success" withBlock:^{
        EndBlock();
        XCTAssertTrue(true, @"");
    }];
    
    [transit execute:@"Dragon.Dispatch(Dragon.DefaultThread, function(){ success(); });"];
    
    WaitUntilBlockCompletes();
}

@end
