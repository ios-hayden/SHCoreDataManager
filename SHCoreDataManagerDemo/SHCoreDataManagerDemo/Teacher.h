//
//  Teacher.h
//  SHCoreDataManagerDemo
//
//  Created by Hayden Wang on 15/6/10.
//  Copyright (c) 2015年 YardLAN. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class NSManagedObject;

@interface Teacher : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * num;
@property (nonatomic, retain) NSNumber * age;
@property (nonatomic, retain) NSSet *students;
@end

@interface Teacher (CoreDataGeneratedAccessors)

- (void)addStudentsObject:(NSManagedObject *)value;
- (void)removeStudentsObject:(NSManagedObject *)value;
- (void)addStudents:(NSSet *)values;
- (void)removeStudents:(NSSet *)values;

@end
