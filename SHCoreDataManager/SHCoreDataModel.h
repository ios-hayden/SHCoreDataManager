//
//  WCCCoreDataModel.h
//  wochacha
//
//  Created by Hayden on 15/2/11.
//  Copyright (c) 2015年 wochacha. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface SHCoreDataModel : NSObject

@property (strong, nonatomic) NSString *dataModelName;

@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

//该MOC用于读、改、删操作，在私有非主线程进行，但是读到的数据可能不是同步数据（没有进行merge）
@property (readonly, strong, nonatomic) NSManagedObjectContext *asyncHandleMOC;

@property (readonly, strong, nonatomic) NSManagedObjectContext *syncHandleMOC;

- (BOOL)saveSyncMOC;
- (void)saveAsyncMOC;
- (void)initIfNeed;

@end
