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
    if (entityName.length==0) {
        return nil;
    }
    @synchronized(self.dataModel.syncHandleMOC){
        return [SHCoreDataHelper findWithWhereCondition:where context:self.dataModel.syncHandleMOC andEntityName:entityName];
    }
}

- (NSArray*)findWithConditions:(SHCoreDataConditions*)conditions entityName:(NSString*)entityName
{
    if (entityName.length==0) {
        return nil;
    }
    NSDictionary *dicConditions = [conditions toDictionary];
    @synchronized(self.dataModel.syncHandleMOC){
        return [SHCoreDataHelper findWithConditions:dicConditions context:self.dataModel.syncHandleMOC andEntityName:entityName];
    }
}

- (NSManagedObject*)createEntity:(NSString*)entityName withValues:(NSDictionary*)dicValues
{
    if (entityName.length==0) {
        return nil;
    }
    NSArray *arrValues = dicValues==nil ? nil : @[dicValues];
    NSArray *arrObjects = [self createEntity:entityName withCount:1 andValues:arrValues];
    return [arrObjects firstObject];
}

- (NSArray*)createEntity:(NSString*)entityName withCount:(NSUInteger)iCount andValues:(NSArray*)arrValues
{
    if (iCount==0 || entityName.length==0) {
        return nil;
    }
    
    NSMutableArray *muArrReturn = [[NSMutableArray alloc]initWithCapacity:iCount];
    @synchronized(self.dataModel.syncHandleMOC){
        for(NSUInteger i=0; i<iCount; i++){
            NSManagedObject *record = [NSEntityDescription insertNewObjectForEntityForName:entityName inManagedObjectContext:self.dataModel.syncHandleMOC];
            if (i<arrValues.count) {
                id aObject = arrValues[i];
                if ((NSNull*)aObject != [NSNull null] && [aObject isKindOfClass:[NSDictionary class]]) {
                    [record setValuesForKeysWithDictionary:(NSDictionary*)aObject];
                }
            }
            [muArrReturn addObject:record];
        }
        [self.dataModel saveSyncMOC];
    }
    return muArrReturn;
}

- (NSUInteger)updateRecord:(NSManagedObject*)managedObject to:(NSDictionary*)dicValues
{
    if (managedObject!=nil && dicValues!=nil) {
        @synchronized(self.dataModel.syncHandleMOC){
            if ([self.dataModel.syncHandleMOC objectWithID:managedObject.objectID] == managedObject) {
                [managedObject setValuesForKeysWithDictionary:dicValues];
                if ([self.dataModel saveSyncMOC]) {
                    return 1;
                }
            }
        }
    }
    return 0;
}

- (NSUInteger)updateEntity:(NSString*)entityName to:(NSDictionary*)dicValues withWhere:(id)where
{
    if (dicValues==nil || entityName.length==0) {
        return 0;
    }
    
    NSUInteger iUpdateCount = 0;
    @synchronized(self.dataModel.syncHandleMOC){
        NSArray *arrObjects = [SHCoreDataHelper findWithWhereCondition:where context:self.dataModel.syncHandleMOC andEntityName:entityName];
        for (NSManagedObject *aObject in arrObjects) {
            [aObject setValuesForKeysWithDictionary:dicValues];
            iUpdateCount ++;
        }
        BOOL bSaved = [self.dataModel saveSyncMOC];
        if (!bSaved) {
            iUpdateCount = 0;
        }
    }
    return iUpdateCount;
}

- (NSUInteger)deleteRecord:(NSManagedObject*)managedObject
{
    if (managedObject!=nil) {
        @synchronized(self.dataModel.syncHandleMOC){
            if ([self.dataModel.syncHandleMOC objectWithID:managedObject.objectID] == managedObject) {
                [self.dataModel.syncHandleMOC deleteObject:managedObject];
                if ([self.dataModel saveSyncMOC]) {
                    return 1;
                }
            }
        }
    }
    return 0;
}

- (NSUInteger)deleteEntity:(NSString*)entityName withWhere:(id)where
{
    if (entityName.length==0) {
        return 0;
    }
    
    NSUInteger iDeletedCount = 0;
    @synchronized(self.dataModel.syncHandleMOC){
        NSArray *arrObjects = [SHCoreDataHelper findWithWhereCondition:where context:self.dataModel.syncHandleMOC andEntityName:entityName];
        for (NSManagedObject *aObject in arrObjects) {
            [self.dataModel.syncHandleMOC deleteObject:aObject];
            iDeletedCount ++;
        }
        BOOL bSaved = [self.dataModel saveSyncMOC];
        if (!bSaved) {
            iDeletedCount = 0;
        }
    }
    return iDeletedCount;
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
    
    __weak NSManagedObjectContext *context = self.dataModel.asyncHandleMOC;
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
    __weak NSManagedObjectContext *context = self.dataModel.asyncHandleMOC;
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
    __weak NSManagedObjectContext *context = self.dataModel.asyncHandleMOC;
    [context performBlock:^{
        NSManagedObject *record = [NSEntityDescription insertNewObjectForEntityForName:entityName inManagedObjectContext:context];
        [record setValuesForKeysWithDictionary:dicRecord];
        [self.dataModel saveAsyncMOC];
    }];
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
        [self.dataModel saveAsyncMOC];
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
    
    __weak NSManagedObjectContext *context = self.dataModel.asyncHandleMOC;
    [context performBlock:^{
        [record setValuesForKeysWithDictionary:dicRecord];
        BOOL bResult = [self.dataModel.asyncHandleMOC save:nil];
        if (result) {
            result(bResult);
        }
    }];
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
            [self.dataModel.asyncHandleMOC deleteObject:obj];
        }
        [self.dataModel.asyncHandleMOC save:nil];
        if (result) {
            result(records.count);
        }
    }];
}

- (void)deleteRecord:(NSManagedObject*)record result:(SHCDCountBlock)resultBlock
{
    SHCDCountBlock result = [resultBlock copy];
    if (record==nil) {
        if (result) {
            result(0);
        }
        return;
    }
    
    __weak NSManagedObjectContext *context = self.dataModel.asyncHandleMOC;
    [context performBlock:^{
        [context deleteObject:record];
        BOOL bSaved = [self.dataModel.asyncHandleMOC save:nil];
        if (result) {
            result(bSaved ? 1 : 0);
        }
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
    
    __weak NSManagedObjectContext *context = self.dataModel.asyncHandleMOC;
    [context performBlock:^{
        NSArray *array = [SHCoreDataHelper findWithConditions:dicConditions context:context andEntityName:entityName];
        if (result) {
            result(array);
        }
    }];
}

#pragma mark - Save Context
- (BOOL)saveSyncMOC
{
    return [self.dataModel saveSyncMOC];
}

- (BOOL)saveAsyncMOC
{
    return [self.dataModel.asyncHandleMOC save:nil];
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
