//
//  UseCustomModelTests.m
//  SHCoreDataManagerDemo
//
//  Created by Hayden Wang on 15/8/7.
//  Copyright (c) 2015年 YardLAN. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import <CoreData/CoreData.h>
#import "SHCoreDataManager.h"
#import "School.h"

@interface UseCustomModelTests : XCTestCase
@property(nonatomic, assign) NSInteger iState;
@end

@implementation UseCustomModelTests

- (void)setUp {
    [super setUp];
    self.iState = 0;
    [[SHCoreDataManager sharedManager] addDatabase:@"CustomModel" withManagedObjectModel:[self model]];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)test021MultipleThreedInsertAndUpdate{
    
}

- (void)test022MultipleThreedInsertAndDelete {
    NSMutableArray *muArrayValues = [self generateTestData];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSArray *array = [[SHCoreDataManager sharedManager] createEntity:@"School" withCount:muArrayValues.count andValues:muArrayValues inDatabase:@"CustomModel"];
        NSLog(@"=======22_Count_%d",(int)array.count);
        self.iState ++;
    });
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSUInteger iCount = [[SHCoreDataManager sharedManager] deleteEntity:@"School" withWhere:nil inDatabase:@"CustomModel"];
        NSLog(@"=======22_Delete:%d",(int)iCount);
        self.iState ++;
    });
    [self waitForState:2];
}

- (void)testMultiple023ThreedInsert {
    NSMutableArray *muArrayValues = [self generateTestData];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSArray *array = [[SHCoreDataManager sharedManager] createEntity:@"School" withCount:muArrayValues.count andValues:muArrayValues inDatabase:@"CustomModel"];
        NSLog(@"231_Count_%d",(int)array.count);
        self.iState ++;
    });
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSArray *array = [[SHCoreDataManager sharedManager] createEntity:@"School" withCount:muArrayValues.count andValues:muArrayValues inDatabase:@"CustomModel"];
        NSLog(@"232_Count_%d",(int)array.count);
        self.iState ++;
    });
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSArray *array = [[SHCoreDataManager sharedManager] createEntity:@"School" withCount:muArrayValues.count andValues:muArrayValues inDatabase:@"CustomModel"];
        NSLog(@"233_Count_%d",(int)array.count);
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
                                   @"strSchoolName": strName,
                                   @"strSchoolID": strNum,
                                   @"iSchoolLevel":[NSNumber numberWithInteger:i]
                                   };
        [muArrayValues addObject:dicValue];
    }
    return muArrayValues;
}

- (NSManagedObjectModel *)model
{
    NSManagedObjectModel *model = [[NSManagedObjectModel alloc] init];
    // create the entity
    NSEntityDescription *entity = [[NSEntityDescription alloc] init];
    [entity setName:@"School"];
    [entity setManagedObjectClassName:@"School"];
    
    // create the attributes
    NSMutableArray *properties = [NSMutableArray array];
    
    NSAttributeDescription *schoolID = [[NSAttributeDescription alloc] init];
    [schoolID setName:@"strSchoolID"];
    [schoolID setAttributeType:NSStringAttributeType];
    [schoolID setOptional:NO];
    [schoolID setIndexed:YES];
    [properties addObject:schoolID];
    
    NSAttributeDescription *schoolName = [[NSAttributeDescription alloc] init];
    [schoolName setName:@"strSchoolName"];
    [schoolName setAttributeType:NSStringAttributeType];
    [schoolName setOptional:YES];
    [schoolName setIndexed:NO];
    [properties addObject:schoolName];
    
    NSAttributeDescription *schoolLevel = [[NSAttributeDescription alloc] init];
    [schoolLevel setName:@"iSchoolLevel"];
    [schoolLevel setAttributeType:NSInteger32AttributeType];
    [schoolLevel setOptional:YES];
    [schoolLevel setIndexed:NO];
    [properties addObject:schoolLevel];
    
    
//    NSAttributeDescription *fileDataAttribute = [[NSAttributeDescription alloc] init];
//    [fileDataAttribute setName:@"fileData"];
//    [fileDataAttribute setAttributeType:NSBinaryDataAttributeType];
//    [fileDataAttribute setOptional:NO];
//    [fileDataAttribute setAllowsExternalBinaryDataStorage:YES];
//    [properties addObject:fileDataAttribute];
//    
//    NSAttributeDescription *lastAccessDateAttribute = [[NSAttributeDescription alloc] init];
//    [lastAccessDateAttribute setName:@"lastAccessDate"];
//    [lastAccessDateAttribute setAttributeType:NSDateAttributeType];
//    [lastAccessDateAttribute setOptional:NO];
//    [properties addObject:lastAccessDateAttribute];
//    
//    NSAttributeDescription *expirationDateAttribute = [[NSAttributeDescription alloc] init];
//    [expirationDateAttribute setName:@"expirationDate"];
//    [expirationDateAttribute setAttributeType:NSDateAttributeType];
//    [expirationDateAttribute setOptional:NO];
//    [properties addObject:expirationDateAttribute];
//    
//    NSAttributeDescription *contentTypeAttribute = [[NSAttributeDescription alloc] init];
//    [contentTypeAttribute setName:@"contentType"];
//    [contentTypeAttribute setAttributeType:NSStringAttributeType];
//    [contentTypeAttribute setOptional:YES];
//    [properties addObject:contentTypeAttribute];
//    
//    NSAttributeDescription *fileSizeAttribute = [[NSAttributeDescription alloc] init];
//    [fileSizeAttribute setName:@"fileSize"];
//    [fileSizeAttribute setAttributeType:NSInteger32AttributeType];
//    [fileSizeAttribute setOptional:NO];
//    [properties addObject:fileSizeAttribute];
//    
//    NSAttributeDescription *entityTagIdentifierAttribute = [[NSAttributeDescription alloc] init];
//    [entityTagIdentifierAttribute setName:@"entityTagIdentifier"];
//    [entityTagIdentifierAttribute setAttributeType:NSStringAttributeType];
//    [entityTagIdentifierAttribute setOptional:YES];
//    [properties addObject:entityTagIdentifierAttribute];
//    
    // add attributes to entity
    [entity setProperties:properties];
    
    // add entity to model
    [model setEntities:[NSArray arrayWithObject:entity]];
    
    return model;
}

@end
