//
//  CoreDataSyncTests.m
//  SHCoreDataManagerDemo
//
//  Created by Hayden Wang on 15/6/11.
//  Copyright (c) 2015年 YardLAN. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "SHCoreDataManager.h"

@interface CoreDataSyncTests : XCTestCase
@property (nonatomic, assign) NSInteger iState;
@end

@implementation CoreDataSyncTests

- (void)setUp {
    [super setUp];
    self.iState = 0;
    [[SHCoreDataManager sharedManager] initWithDataModelName:@"CoreDataModel"];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)test009MultipleThreedInsertAndUpdate{
    
}

- (void)test010MultipleThreedInsertAndDelete {
    NSMutableArray *muArrayValues = [self generateTestData];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSArray *array = [[SHCoreDataManager sharedManager] createEntity:@"Teacher" withCount:muArrayValues.count andValues:muArrayValues];
        NSLog(@"=======1_Count_%d",(int)array.count);
        self.iState ++;
    });
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSUInteger iCount = [[SHCoreDataManager sharedManager] deleteEntity:@"Teacher" withWhere:nil];
        NSLog(@"=======Delete:%d",(int)iCount);
        self.iState ++;
    });
    [self waitForState:2];
}

- (void)testMultiple011ThreedInsert {
    NSMutableArray *muArrayValues = [self generateTestData];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSArray *array = [[SHCoreDataManager sharedManager] createEntity:@"Teacher" withCount:muArrayValues.count andValues:muArrayValues];
        NSLog(@"1_Count_%d",(int)array.count);
        self.iState ++;
    });
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSArray *array = [[SHCoreDataManager sharedManager] createEntity:@"Teacher" withCount:muArrayValues.count andValues:muArrayValues];
        NSLog(@"2_Count_%d",(int)array.count);
        self.iState ++;
    });
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSArray *array = [[SHCoreDataManager sharedManager] createEntity:@"Teacher" withCount:muArrayValues.count andValues:muArrayValues];
        NSLog(@"3_Count_%d",(int)array.count);
        self.iState++;
    });
    [self waitForState:3];
    XCTAssert(YES);
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

- (void)waitForState:(NSInteger)iState
{
    while (self.iState<iState) {
        //wait
    }
    self.iState = 0;
}

- (NSMutableArray*)generateTestData
{
    NSInteger iCount = 10000;
    NSMutableArray *muArrayValues = [[NSMutableArray alloc]initWithCapacity:iCount];
    for (NSUInteger i=0; i<iCount; i++) {
        NSString *strName = [NSString stringWithFormat:@"Hayden%d",(int)i];
        NSNumber *age = [NSNumber numberWithUnsignedInteger:i];
        NSString *strNum = [NSString stringWithFormat:@"TXX%d",(int)i];
        NSDictionary *dicValue = @{
                                   @"name": strName,
                                   @"age": age,
                                   @"num": strNum
                                   };
        [muArrayValues addObject:dicValue];
    }
    return muArrayValues;
}
@end
