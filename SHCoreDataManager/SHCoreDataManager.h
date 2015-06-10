//
//  SHCoreDataManager.h
//  SHCoreDataManagerDemo
//
//  Created by Hayden Wang on 15/6/5.
//  Copyright (c) 2015年 YardLAN. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class SHCoreDataConditions;

typedef void (^SHCDRecordBlock)(NSManagedObject *record);
typedef void (^SHCDRecordsBlock)(NSArray *records);
typedef void (^SHCDCountBlock)(NSInteger count);
typedef void (^SHCDDictionaryBlock)(NSDictionary *result);
typedef void (^SHCDBOOLBlock)(BOOL result);


@interface SHCoreDataManager : NSObject

+ (SHCoreDataManager*)sharedManager;
- (void)initWithDataModelName:(NSString*)name;

#pragma mark - Synchronous Methods
- (NSArray*)findWithWhere:(id)where entityName:(NSString*)entityName;
- (NSArray*)findWithConditions:(SHCoreDataConditions*)conditions entityName:(NSString*)entityName;

#pragma mark - CURD Asynchronous Methods
- (void)createWithEntity:(NSString*)entityName result:(SHCDRecordBlock)resultBlock;
- (void)createWithEntity:(NSString*)entityName count:(NSUInteger)count result:(SHCDRecordsBlock)resultBlock;
- (void)createAndSaveWithRecord:(NSDictionary*)dicRecord entity:(NSString*)entityName;
- (void)updateEntity:(NSString*)entityName withWhere:(id)where to:(NSDictionary*)dicRecord;
- (void)updateEntity:(NSString*)entityName withWhere:(id)where to:(NSDictionary*)dicRecord  result:(SHCDCountBlock)resultBlock;
- (void)updateRecord:(NSManagedObject*)record to:(NSDictionary*)dicRecord result:(SHCDBOOLBlock)resultBlock;
- (void)updateRecord:(NSManagedObject*)record to:(NSDictionary*)dicRecord;
- (void)deleteEntity:(NSString*)entityName withWhere:(id)where;
- (void)deleteEntity:(NSString*)entityName withWhere:(id)where result:(SHCDCountBlock)resultBlock;
- (void)deleteRecord:(NSManagedObject*)record;
- (void)findWithWhere:(id)where entityName:(NSString*)entityName result:(SHCDRecordsBlock)resultBlock;
- (void)findWithConditions:(SHCoreDataConditions*)conditions entityName:(NSString*)entityName result:(SHCDRecordsBlock)resultBlock;

#pragma mark - Save Context
- (BOOL)save;
@end
