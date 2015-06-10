//
//  CoreDataHelper.m
//  wochacha
//
//  Created by Hayden on 14-5-9.
//  Copyright (c) 2014年 wochacha. All rights reserved.
//

#import "SHCoreDataHelper.h"

@implementation SHCoreDataHelper

//查询名称为entityName的实体（表）中所有数据，并根据字段名为field的字段进行排序，asc：YES->升序  NO->降序
+ (NSArray*)findSortByField:(NSString*)field asc:(BOOL)asc context:(NSManagedObjectContext*)context andEntityName:(NSString*)entityName
{
    return [SHCoreDataHelper findWithWhereCondition:nil limit:0 sortByField:field asc:asc context:context andEntityName:entityName];
}

//查询名称为entityName的实体（表）中满足where条件的数据，where为标准sql查询条件字符串
+ (NSArray*)findWithWhereCondition:(id)where context:(NSManagedObjectContext*)context andEntityName:(NSString*)entityName
{
    return [SHCoreDataHelper findWithWhereCondition:where limit:0 context:context andEntityName:entityName];
}

//查询名称为entityName的实体（表）中满足where条件的前limit条数据，where为标准sql查询条件字符串，limit<=0时不做限制
+ (NSArray*)findWithWhereCondition:(id)where limit:(NSInteger)limit  context:(NSManagedObjectContext*)context andEntityName:(NSString*)entityName
{
    NSMutableDictionary *dicWhere = [[NSMutableDictionary alloc]init];
    NSNumber *nLimit = limit>0 ? [NSNumber numberWithInteger:limit] : nil;
    if (where) {
        [dicWhere setValue:where forKey:@"where"];
    }
    if (nLimit) {
        [dicWhere setValue:nLimit forKey:@"limit"];
    }
    return [SHCoreDataHelper findWithConditions:dicWhere context:context andEntityName:entityName];
}

//查询名称为entityName的实体（表）中满足where条件的前limit条数据，并将数据根据字段名为field的字段进行排序，asc：YES->升序  NO->降序，where为标准sql查询条件字符串
+ (NSArray*)findWithWhereCondition:(id)where limit:(NSInteger)limit sortByField:(NSString*)field asc:(BOOL)asc context:(NSManagedObjectContext*)context andEntityName:(NSString*)entityName
{
    NSMutableDictionary *dicWhere = [[NSMutableDictionary alloc]init];
    NSNumber *nLimit = limit>0 ? [NSNumber numberWithInteger:limit] : nil;
    if (where) {
        [dicWhere setValue:where forKey:@"where"];
    }
    if (nLimit) {
        [dicWhere setValue:nLimit forKey:@"limit"];
    }
    
    if (field.length) {
        NSNumber *nAsc = [NSNumber numberWithBool:asc];
        NSDictionary *dicSort = @{@"field":field,@"asc":nAsc};
        [dicWhere setValue:dicSort forKeyPath:@"sort"];
    }
    return [SHCoreDataHelper findWithConditions:dicWhere context:context andEntityName:entityName];
}

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
+ (NSArray*)findWithConditions:(NSDictionary*)dicConditions context:(NSManagedObjectContext*)context andEntityName:(NSString*)entityName
{
    id where = [dicConditions valueForKey:@"where"];
    id arrSortObj = [dicConditions valueForKey:@"sort"];
    id fetch = [dicConditions valueForKey:@"fetch"];
    
    NSFetchRequest *fetchRequest;
    if (fetch) {
        fetchRequest = (NSFetchRequest*)fetch;
    }else{
        fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:context];
        [fetchRequest setEntity:entity];
        [fetchRequest setFetchBatchSize:10];
        
        // 添加排序条件
        if ([arrSortObj isKindOfClass:[NSDictionary class]]) {
            NSMutableArray *arrSortDescriptor = [[NSMutableArray alloc]init];
            NSDictionary *dicTemp = (NSDictionary*)arrSortObj;
            NSString *sortField = [dicTemp valueForKey:@"field"];
            id ascObj = [dicTemp valueForKey:@"asc"];
            if (sortField.length && [ascObj isKindOfClass:[NSNumber class]]) {
                BOOL bAsc = [((NSNumber*)ascObj) boolValue];
                NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:sortField ascending:bAsc];
                [arrSortDescriptor addObject:sortDescriptor];
            }
            if (arrSortDescriptor.count) {
                [fetchRequest setSortDescriptors:arrSortDescriptor];
            }
        }else if ([arrSortObj isKindOfClass:[NSArray class]] && ((NSArray*)arrSortObj).count) {
            NSMutableArray *arrSortDescriptor = [[NSMutableArray alloc]init];
            NSArray *arrSort = (NSArray*)arrSortObj;
            for (NSDictionary *dicTemp in arrSort) {
                NSString *sortField = [dicTemp valueForKey:@"field"];
                id ascObj = [dicTemp valueForKey:@"asc"];
                if (sortField.length && [ascObj isKindOfClass:[NSNumber class]]) {
                    BOOL bAsc = [((NSNumber*)ascObj) boolValue];
                    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:sortField ascending:bAsc];
                    [arrSortDescriptor addObject:sortDescriptor];
                }
            }
            if (arrSortDescriptor.count) {
                [fetchRequest setSortDescriptors:arrSortDescriptor];
            }
        }
        
        //添加Where条件
        if (where) {
            if ([where isKindOfClass:[NSString class]]) {
                NSPredicate * qcondition= [NSPredicate predicateWithFormat:(NSString*)where];
                [fetchRequest setPredicate:qcondition];
            }else if([where isKindOfClass:[NSPredicate class]]){
                [fetchRequest setPredicate:where];
            }
        }
    }
    
    //设置取前limit条数据
    id limit = [dicConditions valueForKeyPath:@"limit"];
    if (limit && [limit isKindOfClass:[NSNumber class]] && [((NSNumber*)limit) intValue]>0) {
        [fetchRequest setFetchLimit:[((NSNumber*)limit) intValue]];
    }
    
    NSError *error = nil;
    NSArray *listData = [context executeFetchRequest:fetchRequest error:&error];
    return listData;
}

//删除名称为entityName的实体（表）中满足where条件的数据，where为标准sql查询条件字符串，返回值为成功删除的条数
+ (NSInteger)deleteEntityWithWhere:(id)where context:(NSManagedObjectContext*)context andEntityName:(NSString*)entityName
{
    NSDictionary *dicConditions;
    if (where) {
        dicConditions = @{@"where":where};
    }
    NSArray *arrayDelete = [SHCoreDataHelper findWithConditions:dicConditions context:context andEntityName:entityName];
    for (id obj in arrayDelete) {
        [context deleteObject:obj];
    }
    NSInteger iCount = arrayDelete.count;
    if (iCount && [SHCoreDataHelper saveWithContext:context]) {
        return iCount;
    }else{
        return 0;
    }
}


//删除名称为entityName的实体（表）中所有数据，返回值为成功删除的条数
+ (NSInteger)clearEntityWithName:(NSString*)entityName andContext:(NSManagedObjectContext*)context
{
    if (context==nil) {
        return 0;
    }
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    [fetchRequest setFetchBatchSize:10];
    NSError *error = nil;
    NSArray *listData = [context executeFetchRequest:fetchRequest error:&error];
    for (id obj in listData) {
        [context deleteObject:obj];
    }
    NSInteger iCount = listData.count;
    if (iCount && [SHCoreDataHelper saveWithContext:context]) {
        return iCount;
    }else{
        return 0;
    }
}

//保存更改
+ (NSInteger)saveWithContext:(NSManagedObjectContext*)context
{
    NSError *savingError = nil;
    if ([context save:&savingError]){
        return 1;
    } else {
        return 0;
    }
}
@end
