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
    @synchronized(self.dataModel.defaultMOC){
        return [SHCoreDataHelper findWithWhereCondition:where context:self.dataModel.defaultMOC andEntityName:entityName];
    }
}

- (NSArray*)findWithConditions:(SHCoreDataConditions*)conditions entityName:(NSString*)entityName
{
    if (entityName.length==0) {
        return nil;
    }
    NSDictionary *dicConditions = [conditions toDictionary];
    @synchronized(self.dataModel.defaultMOC){
        return [SHCoreDataHelper findWithConditions:dicConditions context:self.dataModel.defaultMOC andEntityName:entityName];
    }
}

- (NSArray*)findWithWhere:(id)where entityName:(NSString*)entityName inDatabase:(NSString*)databaseName
{
    if (entityName.length==0 || databaseName.length==0) {
        return nil;
    }
    NSManagedObjectContext *moc = [self.dataModel mocWithDatabaseName:databaseName];
    
    if (moc==nil) {
        return nil;
    }
    
    @synchronized(moc){
        return [SHCoreDataHelper findWithWhereCondition:where context:moc andEntityName:entityName];
    }
}

- (NSArray*)findWithConditions:(SHCoreDataConditions*)conditions entityName:(NSString*)entityName inDatabase:(NSString*)databaseName
{
    if (entityName.length==0 || databaseName.length==0) {
        return nil;
    }
    NSManagedObjectContext *moc = [self.dataModel mocWithDatabaseName:databaseName];
    
    if (moc==nil) {
        return nil;
    }
    NSDictionary *dicConditions = [conditions toDictionary];
    @synchronized(moc){
        return [SHCoreDataHelper findWithConditions:dicConditions context:moc andEntityName:entityName];
    }
}

#pragma mark - Create
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
    @synchronized(self.dataModel.defaultMOC){
        for(NSUInteger i=0; i<iCount; i++){
            NSManagedObject *record = [NSEntityDescription insertNewObjectForEntityForName:entityName inManagedObjectContext:self.dataModel.defaultMOC];
            if (i<arrValues.count) {
                id aObject = arrValues[i];
                if ((NSNull*)aObject != [NSNull null] && [aObject isKindOfClass:[NSDictionary class]]) {
                    [record setValuesForKeysWithDictionary:(NSDictionary*)aObject];
                }
            }
            [muArrReturn addObject:record];
        }
        [self.dataModel saveDefault];
    }
    return muArrReturn;
}

- (NSManagedObject*)createEntity:(NSString*)entityName withValues:(NSDictionary*)dicValues inDatabase:(NSString*)strDatabaseName
{
    NSArray *arrValues = dicValues==nil ? nil : @[dicValues];
    NSArray *arrObjects = [self createEntity:entityName withCount:1 andValues:arrValues inDatabase:strDatabaseName];
    return [arrObjects firstObject];
}

- (NSArray*)createEntity:(NSString*)entityName withCount:(NSUInteger)iCount andValues:(NSArray*)arrValues inDatabase:(NSString*)strDatabaseName
{
    if (iCount==0 || entityName.length==0 || strDatabaseName.length==0) {
        return nil;
    }
    
    NSManagedObjectContext *moc = [self.dataModel mocWithDatabaseName:strDatabaseName];
    
    if (moc==nil) {
        return nil;
    }
    
    NSMutableArray *muArrReturn = [[NSMutableArray alloc]initWithCapacity:iCount];
    @synchronized(moc){
        for(NSUInteger i=0; i<iCount; i++){
            NSManagedObject *record = [NSEntityDescription insertNewObjectForEntityForName:entityName inManagedObjectContext:moc];
            if (i<arrValues.count) {
                id aObject = arrValues[i];
                if ((NSNull*)aObject != [NSNull null] && [aObject isKindOfClass:[NSDictionary class]]) {
                    [record setValuesForKeysWithDictionary:(NSDictionary*)aObject];
                }
            }
            [muArrReturn addObject:record];
        }
        [self.dataModel saveMOC:moc];
    }
    return muArrReturn;
}

#pragma mark - Update
- (NSUInteger)updateRecord:(NSManagedObject*)managedObject to:(NSDictionary*)dicValues
{
    if (managedObject!=nil && dicValues!=nil) {
        @synchronized(self.dataModel.defaultMOC){
            if ([self.dataModel.defaultMOC objectWithID:managedObject.objectID] == managedObject) {
                [managedObject setValuesForKeysWithDictionary:dicValues];
                if ([self.dataModel saveDefault]) {
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
    @synchronized(self.dataModel.defaultMOC){
        NSArray *arrObjects = [SHCoreDataHelper findWithWhereCondition:where context:self.dataModel.defaultMOC andEntityName:entityName];
        for (NSManagedObject *aObject in arrObjects) {
            [aObject setValuesForKeysWithDictionary:dicValues];
            iUpdateCount ++;
        }
        BOOL bSaved = [self.dataModel saveDefault];
        if (!bSaved) {
            iUpdateCount = 0;
        }
    }
    return iUpdateCount;
}

- (NSUInteger)updateRecord:(NSManagedObject*)managedObject to:(NSDictionary*)dicValues inDatabase:(NSString*)strDatabaseName
{
    if (managedObject==nil || dicValues==nil || strDatabaseName.length==0) {
        return 0;
    }
    NSManagedObjectContext *moc = [self.dataModel mocWithDatabaseName:strDatabaseName];
    if (moc==nil) {
        return 0;
    }
    NSUInteger iCount = 0;
    @synchronized(moc){
        if ([moc objectWithID:managedObject.objectID] == managedObject) {
            [managedObject setValuesForKeysWithDictionary:dicValues];
            if ([self.dataModel saveMOC:moc]) {
                iCount = 1;
            }
        }
    }
    return iCount;
}

- (NSUInteger)updateEntity:(NSString*)entityName to:(NSDictionary*)dicValues withWhere:(id)where inDatabase:(NSString*)strDatabaseName
{
    if (entityName.length==0 || dicValues==nil || strDatabaseName.length==0) {
        return 0;
    }
    
    NSManagedObjectContext *moc = [self.dataModel mocWithDatabaseName:strDatabaseName];
    if (moc==nil) {
        return 0;
    }
    
    NSUInteger iUpdateCount = 0;
    @synchronized(moc){
        NSArray *arrObjects = [SHCoreDataHelper findWithWhereCondition:where context:moc andEntityName:entityName];
        for (NSManagedObject *aObject in arrObjects) {
            [aObject setValuesForKeysWithDictionary:dicValues];
            iUpdateCount ++;
        }
        BOOL bSaved = [self.dataModel saveMOC:moc];
        if (!bSaved) {
            iUpdateCount = 0;
        }
    }
    return iUpdateCount;
}

#pragma mark - Delete
- (NSUInteger)deleteRecord:(NSManagedObject*)managedObject
{
    if (managedObject!=nil) {
        @synchronized(self.dataModel.defaultMOC){
            if ([self.dataModel.defaultMOC objectWithID:managedObject.objectID] == managedObject) {
                [self.dataModel.defaultMOC deleteObject:managedObject];
                if ([self.dataModel saveDefault]) {
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
    @synchronized(self.dataModel.defaultMOC){
        NSArray *arrObjects = [SHCoreDataHelper findWithWhereCondition:where context:self.dataModel.defaultMOC andEntityName:entityName];
        for (NSManagedObject *aObject in arrObjects) {
            [self.dataModel.defaultMOC deleteObject:aObject];
            iDeletedCount ++;
        }
        BOOL bSaved = [self.dataModel saveDefault];
        if (!bSaved) {
            iDeletedCount = 0;
        }
    }
    return iDeletedCount;
}

- (NSUInteger)deleteRecord:(NSManagedObject*)managedObject inDatabase:(NSString*)strDatabaseName
{
    if (managedObject==nil || strDatabaseName.length==0) {
        return 0;
    }
    
    NSManagedObjectContext *moc = [self.dataModel mocWithDatabaseName:strDatabaseName];
    if (moc==nil) {
        return 0;
    }
    
    NSUInteger iCount = 0;
    @synchronized(moc){
        if ([moc objectWithID:managedObject.objectID] == managedObject) {
            [moc deleteObject:managedObject];
            if ([self.dataModel saveMOC:moc]) {
                iCount = 1;
            }
        }
    }
    return iCount;
}

- (NSUInteger)deleteEntity:(NSString*)entityName withWhere:(id)where inDatabase:(NSString*)strDatabaseName
{
    if (entityName.length==0 || strDatabaseName.length==0) {
        return 0;
    }
    
    NSManagedObjectContext *moc = [self.dataModel mocWithDatabaseName:strDatabaseName];
    if (moc==nil) {
        return 0;
    }
    
    NSUInteger iDeletedCount = 0;
    @synchronized(moc){
        NSArray *arrObjects = [SHCoreDataHelper findWithWhereCondition:where context:moc andEntityName:entityName];
        for (NSManagedObject *aObject in arrObjects) {
            [moc deleteObject:aObject];
            iDeletedCount ++;
        }
        BOOL bSaved = [self.dataModel saveMOC:moc];
        if (!bSaved) {
            iDeletedCount = 0;
        }
    }
    return iDeletedCount;
}

#pragma mark - Save Context
- (BOOL)save
{
    BOOL bSuccess = NO;
    @synchronized(self.dataModel.defaultMOC){
        bSuccess = [self.dataModel saveDefault];
    }
    return bSuccess;
}

- (BOOL)saveWithDatabaseName:(NSString*)strDatabaseName
{
    NSManagedObjectContext *moc = [self.dataModel mocWithDatabaseName:strDatabaseName];
    if (moc==nil) {
        return NO;
    }
    BOOL bSuccess = NO;
    @synchronized(moc){
        bSuccess = [self.dataModel saveMOC:moc];
    }
    return bSuccess;
}

#pragma mark - Public Init Methods
- (BOOL)setDefaultDatabase:(NSString*)strDatabaseName
{
    return [self.dataModel setDefaultDatabase:strDatabaseName];
}

- (BOOL)addDatabase:(NSString*)strDatabaseName
{
    return [self.dataModel addDatabase:strDatabaseName];
}

- (BOOL)addDatabase:(NSString*)strDatabaseName withManagedObjectModel:(NSManagedObjectModel*)mom
{
    return [self.dataModel addDatabase:strDatabaseName withManagedObjectModel:mom];
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
