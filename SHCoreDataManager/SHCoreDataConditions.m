//
//  SHCoreDataConditionModel.m
//  SHCoreDataManagerDemo
//
//  Created by Hayden Wang on 15/6/5.
//  Copyright (c) 2015年 YardLAN. All rights reserved.
//

#import "SHCoreDataConditions.h"

@implementation SHCoreDataConditions
- (id)init
{
    self = [super init];
    if (self) {
        self.limit =0;
        self.sort_asc = YES;
    }
    return self;
}

- (NSDictionary*)toDictionary
{
    NSMutableDictionary *muDIc = [[NSMutableDictionary alloc]initWithCapacity:4];
    if (self.fetch) {
        [muDIc setValue:self.fetch forKey:@"fetch"];
    }else{
        if (self.where) {
            [muDIc setValue:self.where forKey:@"where"];
        }
        
        if (self.sort_field) {
            NSNumber *numberASC = [NSNumber numberWithBool:self.sort_asc];
            NSDictionary *dicTemp = @{@"field":self.sort_field, @"asc":numberASC};
            [muDIc setValue:dicTemp forKey:@"sort"];
        }
        
        if (self.limit>0) {
            NSNumber *numberLimit = [NSNumber numberWithInteger:self.limit];
            [muDIc setValue:numberLimit forKey:@"limit"];
        }
    }
    
    return muDIc;
}
@end
