//
//  Grade.h
//  SHCoreDataManagerDemo
//
//  Created by Hayden Wang on 15/8/7.
//  Copyright (c) 2015年 YardLAN. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Grade : NSManagedObject

@property (nonatomic, retain) NSString * strGradeID;
@property (nonatomic, retain) NSString * strGradeName;

@end
