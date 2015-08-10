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

@property (readonly, strong, nonatomic) NSManagedObjectContext *defaultMOC;

- (NSManagedObjectContext*)mocWithDatabaseName:(NSString*)strDatabaseName;
- (BOOL)setDefaultDatabase:(NSString*)strDatabaseName;
- (BOOL)addDatabase:(NSString*)strDatabaseName;
- (BOOL)addDatabase:(NSString*)strDatabaseName withManagedObjectModel:(NSManagedObjectModel*)mom;

- (BOOL)saveDefault;
- (BOOL)saveMOC:(NSManagedObjectContext*)moc;

@end
