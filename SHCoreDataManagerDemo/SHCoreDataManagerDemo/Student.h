//
//  Student.h
//  SHCoreDataManagerDemo
//
//  Created by Hayden Wang on 15/6/10.
//  Copyright (c) 2015年 YardLAN. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Student : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * num;
@property (nonatomic, retain) NSNumber * grade;

@end
