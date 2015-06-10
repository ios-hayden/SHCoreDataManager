//
//  SHCoreDataConditionModel.h
//  SHCoreDataManagerDemo
//
//  Created by Hayden Wang on 15/6/5.
//  Copyright (c) 2015年 YardLAN. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface SHCoreDataConditions : NSObject

// 查询的FetchRequest，如果不为nil，则仅使用该查询条件，后面的where等无效
@property (nonatomic, strong) NSFetchRequest *fetch;

// 查询条件，NSString或NSPredicate类型，当为NSString时为标准SQL where语句（不安全），如果查询字段为字符串类型，推荐使用NSPredicate
@property (nonatomic, strong) id where;

// 排序所依据的字段名称
@property (nonatomic, strong) NSString *sort_field;

// 升序（YES），降序（NO）
@property (nonatomic, assign) BOOL sort_asc;

// 取查询结果的前limit条数据，limit为0时不限制
@property (nonatomic, assign) NSUInteger limit;

- (NSDictionary*)toDictionary;
@end
