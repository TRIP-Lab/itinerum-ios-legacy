//
//  DMMMDataManager.m
//  Itinerum
//
//  Created by Takeshi MUKAI on 5/24/17.
//  Copyright (c) 2017 MML-Concordia. All rights reserved.
//

#import "DMMMDataManager.h"

@implementation DMMMDataManager
@synthesize promptIndex, arrayAnswers;

- (id)init
{
    self =  [super init];
    if(self) {
        arrayAnswers = [NSMutableArray array];
    }
    return self;
}

+ (id)instance
{
    static id _instance = nil;
    if(!_instance) {
        _instance = [[self alloc] init];
    }
    return _instance;
}

@end
