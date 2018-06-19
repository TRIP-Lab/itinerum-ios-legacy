//
//  DMMMDataManager.h
//  Itinerum
//
//  Created by Takeshi MUKAI on 5/24/17.
//  Copyright (c) 2017 MML-Concordia. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DMMMDataManager : NSObject
+ (id)instance;

@property (nonatomic) NSInteger promptIndex;
@property (nonatomic, retain) NSMutableArray* arrayAnswers;
@property (nonatomic, retain) NSArray* arrayPrompts;

@end
