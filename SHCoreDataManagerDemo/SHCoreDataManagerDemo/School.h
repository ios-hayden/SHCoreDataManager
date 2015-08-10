//
//  School.h
//  SHCoreDataManagerDemo
//
//  Created by Hayden Wang on 15/8/7.
//  Copyright (c) 2015年 YardLAN. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface School : NSManagedObject

@property (nonatomic, retain) NSString * strSchoolID;
@property (nonatomic, retain) NSString * strSchoolName;

@end
