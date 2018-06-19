//
//  ScaleFontSize.m
//  DataMobile
//
//  Created by Takeshi MUKAI on 7/9/16.
//  Copyright (c) 2016 MML-Concordia. All rights reserved.
//

#import "ScaleFontSize.h"

@implementation ScaleFontSize

// scaleFontSizeByScreenWidth - base font size is iPhone5, screenSize is 320
+ (CGFloat)scaleFontSizeByScreenWidth
{
    CGRect frame = [[UIScreen mainScreen] applicationFrame];
    return frame.size.width/320.0;
}

@end
