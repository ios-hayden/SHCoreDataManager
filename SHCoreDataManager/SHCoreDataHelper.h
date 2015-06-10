//
//  CoreDataHelper.h
//  wochacha
//
//  Created by Hayden on 14-5-9.
//  Copyright (c) 2014年 wochacha. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface SHCoreDataHelper : NSObject

//查询名称为entityName的实体（表）中所有数据，并根据字段名为field的字段进行排序，asc：YES->升序  NO->降序
+ (NSArray*)findSortByField:(NSString*)field asc:(BOOL)asc context:(NSManagedObjectContext*)context andEntityName:(NSString*)entityName;

//查询名称为entityName的实体（表）中满足where条件的数据，where为标准sql查询条件字符串
+ (NSArray*)findWithWhereCondition:(id)where context:(NSManagedObjectContext*)context andEntityName:(NSString*)entityName;

//查询名称为entityName的实体（表）中满足where条件的前limit条数据，where为标准sql查询条件字符串，limit<=0时不做限制
+ (NSArray*)findWithWhereCondition:(id)where limit:(NSInteger)limit  context:(NSManagedObjectContext*)context andEntityName:(NSString*)entityName;

//查询名称为entityName的实体（表）中满足where条件的前limit条数据，并将数据根据字段名为field的字段进行排序，asc：YES->升序  NO->降序，where为标准sql查询条件字符串
+ (NSArray*)findWithWhereCondition:(id)where limit:(NSInteger)limit sortByField:(NSString*)field asc:(BOOL)asc context:(NSManagedObjectContext*)context andEntityName:(NSString*)entityName;

/*
 查询名称为entityName的实体（表）中满足dicConditions条件的数据，dicConditions为NSDictionary，其结构需满足如下条件：
 参数dicConditions的结构示例：
 dicConditions = {
    "where":"messageid=1 AND isread=0",
    "sort":[
        {
            "field":"inserttime",
            "asc":1
        },
        {
            "field":"updatetime",
            "asc":1
        },
        ...
    ],
    "limit":10
 }
 
 或者：
 
 dicConditions = {
    "where":"messageid=1 AND isread=0",
    "sort":{
        "field"="inserttime",
        "asc"=0
    }
 }
 
 其中，键sort值为NSDictionaryl类型，键limit和键asc的值为NSNumber类型，其他键的值均为NSString类型，键where、sort、limit都是可选的
 
 */
+ (NSArray*)findWithConditions:(NSDictionary*)dicConditions context:(NSManagedObjectContext*)context andEntityName:(NSString*)entityName;

//删除名称为entityName的实体（表）中满足where条件的数据，where为标准sql查询条件字符串，返回值为成功删除的条数
+ (NSInteger)deleteEntityWithWhere:(id)where context:(NSManagedObjectContext*)context andEntityName:(NSString*)entityName;

//删除名称为entityName的实体（表）中所有数据，返回值为成功删除的条数
+ (NSInteger)clearEntityWithName:(NSString*)entityName andContext:(NSManagedObjectContext*)context;

//保存更改
+ (NSInteger)saveWithContext:(NSManagedObjectContext*)context;

@end
