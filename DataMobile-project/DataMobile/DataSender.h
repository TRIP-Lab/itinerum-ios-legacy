/*///////////////////////////////////////////////////////////////////
 GNU PUBLIC LICENSE - The copying permission statement
 --------------------------------------------------------------------
 This program is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.
 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.
 You should have received a copy of the GNU General Public License
 along with this program.  If not, see <http://www.gnu.org/licenses/>.
 ///////////////////////////////////////////////////////////////////*/

//
//  DataSender.h
//  DataMobile
//
//  Created by DataMobile on 13-07-26.
//  Copyright (c) 2013 MML-Concordia. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DataSender : NSObject

+ (DataSender*)instance;

/**
 Send user GPS data to the server at the url specified in config.plist.
 @param delegate the NSURLConnectionDataDelegate
 */
//- (void)syncWithServerWithDelegate:(id<NSURLConnectionDataDelegate>)delegate;

-(void)syncWithServerSynchronously:(void(^)(BOOL success))completionBlock;

/**
 Send user GPS data to the server at the url specified in config.plist.
 */
- (void)syncWithServer;

// Modified by MUKAI Takeshi in 2016-08 // for custom survey
- (NSDictionary*)postDataForCustomSurveyCreate:(NSString*)surveyName;
- (NSURLRequest*)requestWithPostDataForCustomSurvey:(NSDictionary*)dico
                                              ToURL:(NSString*)url;

@end
