//
//  CoreDataTests.m
//  SHCoreDataManagerDemo
//
//  Created by Hayden Wang on 15/6/5.
//  Copyright (c) 2015年 YardLAN. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "SHCoreDataManager.h"
#import "Teacher.h"
#import "Student.h"

@interface CoreDataTests : XCTestCase
@property (nonatomic, assign) NSInteger asyncState; //0-wait, 1-Pass, 2-Fail
@end

@implementation CoreDataTests

- (void)setUp {
    [super setUp];
    [[SHCoreDataManager sharedManager] initWithDataModelName:@"CoreDataModel"];
}

- (void)testInsert {
    [[SHCoreDataManager sharedManager] createWithEntity:@"Teacher" result:^(NSManagedObject *record) {
        Teacher *aTeacher = (Teacher*)record;
        aTeacher.name = @"Jason";
        aTeacher.age = [NSNumber numberWithShort:36];
        aTeacher.num = @"T20150303X";
        [[SHCoreDataManager sharedManager] createWithEntity:@"Student" count:10 result:^(NSArray *records) {
            for (Student *aStudent in records) {
                aStudent.name = @"Frank";
                aStudent.grade = [NSNumber numberWithUnsignedInteger:1 + arc4random() % 6];
                aStudent.num = @"S2121918";
                [aTeacher addStudentsObject:aStudent];
            }
            [[SHCoreDataManager sharedManager] save];
            self.asyncState = 1;
        }];
    }];
    [self waitForStateChange];
}

- (void)testRead {
    [[SHCoreDataManager sharedManager] findWithConditions:nil entityName:@"Teacher" result:^(NSArray *records) {
        if (records.count) {
            Teacher *aTeacher = [records lastObject];
            if (aTeacher.students.count==10) {
                self.asyncState = 1;
            }else{
                self.asyncState = 1;
            }
        }else{
            self.asyncState = 2;
        }
    }];
    [self waitForStateChange];
}

- (void)testUpdate
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name=%@", @"Jason"];
    NSDictionary *dicUpdate = @{
                                @"name":@"Hayden",
                                @"age":[NSNumber numberWithShort:30]
                                };
    [[SHCoreDataManager sharedManager] updateEntity:@"Teacher" withWhere:predicate to:dicUpdate result:^(NSInteger count) {
        if (count) {
            self.asyncState = 1;
        }else{
            self.asyncState = 2;
        }
    }];
    [self waitForStateChange];
}

- (void)testDelete
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name=%@", @"Hayden"];
    [[SHCoreDataManager sharedManager] deleteEntity:@"Teacher" withWhere:predicate result:^(NSInteger count) {
        if (count) {
            self.asyncState = 1;
        }else{
            self.asyncState = 2;
        }
    }];
    [self waitForStateChange];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

- (void)waitForStateChange
{
    while (self.asyncState==0) {
        //wait for asyncState change
    }
    XCTAssert(self.asyncState==1);
    self.asyncState = 0;
}

@end
