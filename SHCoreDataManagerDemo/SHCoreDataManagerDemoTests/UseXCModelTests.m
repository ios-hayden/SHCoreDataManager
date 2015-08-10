//
//  UseXCModelTests.m
//  SHCoreDataManagerDemo
//
//  Created by Hayden Wang on 15/8/7.
//  Copyright (c) 2015年 YardLAN. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "SHCoreDataManager.h"
#import "Grade.h"

@interface UseXCModelTests : XCTestCase
@property(nonatomic, assign) NSInteger iState;
@end

@implementation UseXCModelTests

- (void)setUp {
    [super setUp];
    self.iState = 0;
    [[SHCoreDataManager sharedManager] addDatabase:@"Model"];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)test011MultipleThreedInsertAndUpdate{
    
}

- (void)test012MultipleThreedInsertAndDelete {
    NSMutableArray *muArrayValues = [self generateTestData];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSArray *array = [[SHCoreDataManager sharedManager] createEntity:@"Grade" withCount:muArrayValues.count andValues:muArrayValues inDatabase:@"Model"];
        NSLog(@"=======12_Count_%d",(int)array.count);
        self.iState ++;
    });
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSUInteger iCount = [[SHCoreDataManager sharedManager] deleteEntity:@"Grade" withWhere:nil inDatabase:@"Model"];
        NSLog(@"=======12_Delete:%d",(int)iCount);
        self.iState ++;
    });
    [self waitForState:2];
}

- (void)testMultiple013ThreedInsert {
    NSMutableArray *muArrayValues = [self generateTestData];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSArray *array = [[SHCoreDataManager sharedManager] createEntity:@"Grade" withCount:muArrayValues.count andValues:muArrayValues inDatabase:@"Model"];
        NSLog(@"131_Count_%d",(int)array.count);
        self.iState ++;
    });
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSArray *array = [[SHCoreDataManager sharedManager] createEntity:@"Grade" withCount:muArrayValues.count andValues:muArrayValues inDatabase:@"Model"];
        NSLog(@"132_Count_%d",(int)array.count);
        self.iState ++;
    });
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSArray *array = [[SHCoreDataManager sharedManager] createEntity:@"Grade" withCount:muArrayValues.count andValues:muArrayValues inDatabase:@"Model"];
        NSLog(@"133_Count_%d",(int)array.count);
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
        NSString *strNum = [NSString stringWithFormat:@"TXX%d",(int)i];
        NSDictionary *dicValue = @{
                                   @"strGradeName": strName,
                                   @"strGradeID": strNum
                                   };
        [muArrayValues addObject:dicValue];
    }
    return muArrayValues;
}
@end
