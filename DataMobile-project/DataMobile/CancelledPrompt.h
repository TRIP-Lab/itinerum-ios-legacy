//
//  CancelledPrompt.h
//  Itinerum
//
//  Created by Takeshi MUKAI on 9/25/17.
//  Copyright (c) 2017 MML-Concordia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface CancelledPrompt : NSManagedObject

@property (nonatomic) double latitude;
@property (nonatomic) double longitude;
@property (nonatomic) NSTimeInterval timestamp;
@property (nonatomic) NSTimeInterval cancelled_at;
@property (nonatomic) NSString* is_travelling;
@property (nonatomic) BOOL uploaded;

@end
