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

@interface SHCoreDataManager : NSObject

+ (SHCoreDataManager*)sharedManager;
- (BOOL)setDefaultDatabase:(NSString*)strDatabaseName;
- (BOOL)addDatabase:(NSString*)strDatabaseName;
- (BOOL)addDatabase:(NSString*)strDatabaseName withManagedObjectModel:(NSManagedObjectModel*)mom;

#pragma mark - Synchronous Methods
- (NSArray*)findWithWhere:(id)where entityName:(NSString*)entityName;
- (NSArray*)findWithConditions:(SHCoreDataConditions*)conditions entityName:(NSString*)entityName;
- (NSArray*)findWithWhere:(id)where entityName:(NSString*)entityName inDatabase:(NSString*)databaseName;
- (NSArray*)findWithConditions:(SHCoreDataConditions*)conditions entityName:(NSString*)entityName inDatabase:(NSString*)databaseName;

- (NSManagedObject*)createEntity:(NSString*)entityName withValues:(NSDictionary*)dicValues;
- (NSArray*)createEntity:(NSString*)entityName withCount:(NSUInteger)iCount andValues:(NSArray*)arrValues;
- (NSManagedObject*)createEntity:(NSString*)entityName withValues:(NSDictionary*)dicValues inDatabase:(NSString*)strDatabaseName;
- (NSArray*)createEntity:(NSString*)entityName withCount:(NSUInteger)iCount andValues:(NSArray*)arrValues inDatabase:(NSString*)strDatabaseName;


- (NSUInteger)updateRecord:(NSManagedObject*)managedObject to:(NSDictionary*)dicValues;
- (NSUInteger)updateEntity:(NSString*)entityName to:(NSDictionary*)dicValues withWhere:(id)where;
- (NSUInteger)updateRecord:(NSManagedObject*)managedObject to:(NSDictionary*)dicValues inDatabase:(NSString*)strDatabaseName;
- (NSUInteger)updateEntity:(NSString*)entityName to:(NSDictionary*)dicValues withWhere:(id)where inDatabase:(NSString*)strDatabaseName;

- (NSUInteger)deleteRecord:(NSManagedObject*)managedObject;
- (NSUInteger)deleteEntity:(NSString*)entityName withWhere:(id)where;
- (NSUInteger)deleteRecord:(NSManagedObject*)managedObject inDatabase:(NSString*)strDatabaseName;
- (NSUInteger)deleteEntity:(NSString*)entityName withWhere:(id)where inDatabase:(NSString*)strDatabaseName;

- (BOOL)save;
- (BOOL)saveWithDatabaseName:(NSString*)strDatabaseName;

@end
