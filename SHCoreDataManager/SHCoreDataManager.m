//
//  SHCoreDataManager.m
//  SHCoreDataManagerDemo
//
//  Created by Hayden Wang on 15/6/5.
//  Copyright (c) 2015年 YardLAN. All rights reserved.
//

#import "SHCoreDataManager.h"
#import "SHCoreDataModel.h"
#import "SHCoreDataConditions.h"
#import "SHCoreDataHelper.h"

static SHCoreDataManager *staticCoreDataManager;

@interface SHCoreDataManager ()
@property (nonatomic, strong) SHCoreDataModel *dataModel;
@end

@implementation SHCoreDataManager

#pragma mark - Synchronous Methods
- (NSArray*)findWithWhere:(id)where entityName:(NSString*)entityName
{
    return [SHCoreDataHelper findWithWhereCondition:where context:self.dataModel.readMOC andEntityName:entityName];
}

- (NSArray*)findWithConditions:(SHCoreDataConditions*)conditions entityName:(NSString*)entityName
{
    NSDictionary *dicConditions = [conditions toDictionary];
    return [SHCoreDataHelper findWithConditions:dicConditions context:self.dataModel.readMOC andEntityName:entityName];
}

#pragma mark - CURD Asynchronous Methods
- (void)createWithEntity:(NSString*)entityName result:(SHCDRecordBlock)resultBlock
{
    SHCDRecordBlock result = [resultBlock copy];
    if (entityName==nil || resultBlock==nil) {
        if (result) {
            result(nil);
        }
        return;
    }
    
    __weak NSManagedObjectContext *context = self.dataModel.handleMOC;
    [context performBlock:^{
        NSManagedObject *record = [NSEntityDescription insertNewObjectForEntityForName:entityName inManagedObjectContext:context];
        if (result) {
            result(record);
        }
    }];
}

- (void)createWithEntity:(NSString*)entityName count:(NSUInteger)count result:(SHCDRecordsBlock)resultBlock
{
    SHCDRecordsBlock result = [resultBlock copy];
    if (entityName==nil || resultBlock==nil) {
        if (result) {
            result(nil);
        }
        return;
    }
    count = MAX(0, count);
    __weak NSManagedObjectContext *context = self.dataModel.handleMOC;
    [context performBlock:^{
        NSMutableArray *muArray = [[NSMutableArray alloc]initWithCapacity:count];
        for (int i = 0; i<count; i++) {
            NSManagedObject *record = [NSEntityDescription insertNewObjectForEntityForName:entityName inManagedObjectContext:context];
            [muArray addObject:record];
        }
        result(muArray);
    }];
}

- (void)createAndSaveWithRecord:(NSDictionary*)dicRecord entity:(NSString*)entityName
{
    if (dicRecord==nil || entityName==nil) {
        return;
    }
    __weak NSManagedObjectContext *context = self.dataModel.handleMOC;
    [context performBlock:^{
        NSManagedObject *record = [NSEntityDescription insertNewObjectForEntityForName:entityName inManagedObjectContext:context];
        [record setValuesForKeysWithDictionary:dicRecord];
        [self.dataModel save];
    }];
}

- (void)updateEntity:(NSString*)entityName withWhere:(id)where to:(NSDictionary*)dicRecord
{
    [self updateEntity:entityName withWhere:where to:dicRecord result:nil];
}

- (void)updateEntity:(NSString*)entityName withWhere:(id)where to:(NSDictionary*)dicRecord  result:(SHCDCountBlock)resultBlock
{
    SHCDCountBlock result = [resultBlock copy];
    if (entityName==nil || dicRecord==nil) {
        if (result) {
            result(0);
        }
        return;
    }
    
    [self findWithWhere:where entityName:entityName result:^(NSArray *records) {
        for (NSManagedObject *obj in records) {
            [obj setValuesForKeysWithDictionary:dicRecord];
        }
        [self.dataModel save];
        if (result) {
            result(records.count);
        }
    }];
}

- (void)updateRecord:(NSManagedObject*)record to:(NSDictionary*)dicRecord result:(SHCDBOOLBlock)resultBlock
{
    SHCDBOOLBlock result = [resultBlock copy];
    if (record==nil || dicRecord==nil) {
        if (result) {
            result(NO);
        }
        return;
    }
    
    __weak NSManagedObjectContext *context = self.dataModel.handleMOC;
    [context performBlock:^{
        [record setValuesForKeysWithDictionary:dicRecord];
        BOOL bResult = [self.dataModel save];
        if (result) {
            result(bResult);
        }
    }];
}

- (void)updateRecord:(NSManagedObject*)record to:(NSDictionary*)dicRecord
{
    [self updateRecord:record to:dicRecord result:nil];
}

- (void)deleteEntity:(NSString*)entityName withWhere:(id)where
{
    [self deleteEntity:entityName withWhere:where result:nil];
}

- (void)deleteEntity:(NSString*)entityName withWhere:(id)where result:(SHCDCountBlock)resultBlock
{
    SHCDCountBlock result = [resultBlock copy];
    if (entityName==nil) {
        if (result) {
            result(0);
        }
        return;
    }
    
    [self findWithWhere:where entityName:entityName result:^(NSArray *records) {
        for (NSManagedObject *obj in records) {
            [self.dataModel.handleMOC deleteObject:obj];
        }
        [self.dataModel save];
        if (result) {
            result(records.count);
        }
    }];
}

- (void)deleteRecord:(NSManagedObject*)record
{
    __weak NSManagedObjectContext *context = self.dataModel.handleMOC;
    [context performBlock:^{
        [context deleteObject:record];
        [self.dataModel save];
    }];
}

- (void)findWithWhere:(id)where entityName:(NSString*)entityName result:(SHCDRecordsBlock)resultBlock
{
    SHCoreDataConditions *conditions;
    if (where) {
        conditions = [[SHCoreDataConditions alloc]init];
        if ([where isKindOfClass:[NSFetchRequest class]]) {
            conditions.fetch = (NSFetchRequest*)where;
        }else{
            conditions.where = where;
        }
    }
    [self findWithConditions:conditions entityName:entityName result:resultBlock];
}

- (void)findWithConditions:(SHCoreDataConditions*)conditions entityName:(NSString*)entityName result:(SHCDRecordsBlock)resultBlock
{
    SHCDRecordsBlock result = [resultBlock copy];
    if (entityName==nil || resultBlock==nil) {
        if (result) {
            result(nil);
        }
        return;
    }
    
    NSDictionary *dicConditions = [conditions toDictionary];
    
    __weak NSManagedObjectContext *context = self.dataModel.handleMOC;
    [context performBlock:^{
        NSArray *array = [SHCoreDataHelper findWithConditions:dicConditions context:context andEntityName:entityName];
        result(array);
    }];
}

#pragma mark - Save Context
- (BOOL)save
{
    return [self.dataModel save];
}

#pragma mark - Public Init Methods
- (void)initWithDataModelName:(NSString*)name
{
    self.dataModel.dataModelName = name;
    [self.dataModel initIfNeed];
}

#pragma mark - Lifecycle
+ (SHCoreDataManager*)sharedManager
{
    if (staticCoreDataManager) {
        return staticCoreDataManager;
    }else{
        return [[SHCoreDataManager alloc]init];
    }
}

- (id)init
{
    if (staticCoreDataManager != nil) {
        return staticCoreDataManager;
    }else{
        self = [super init];
        if (self) {
            self.dataModel = [[SHCoreDataModel alloc]init];
            staticCoreDataManager = self;
        }
        return self;
    }
}
@end
