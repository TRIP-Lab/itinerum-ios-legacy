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
//  DataSender.m
//  DataMobile
//
//  Created by DataMobile on 13-07-26.
//  Copyright (c) 2013 MML-Concordia. All rights reserved.
//
// Modified by MUKAI Takeshi in 2015-10

#import "DataSender.h"
#import "User.h"
#import "CoreDataHelper.h"
#import "EntityManager.h"
#import "CSVExporter.h"
#import "UIDevice-Hardware.h"
#import "Config.h"
#import "DMGlobalLogger.h"
#import "DMUserSurveyForm.h"
#import "Modeprompt+Functionality.h"  // Modified by MUKAI Takeshi in 2015-11
#import "CancelledPrompt+Functionality.h"  // Modified by MUKAI Takeshi in 2017-09 // cancelledPrompt

@interface DataSender () <NSURLConnectionDelegate>

- (void)setObjectIfNotNil:(id)object
                  forKey:(id<NSCopying>)key
           inDictionnary:(NSMutableDictionary*)dictionnary;

@end

@implementation DataSender

static DataSender* instance;

/**
 * Singleton implementation
 */
+ (void)initialize
{
    if (instance == nil)
    {
        instance = [[DataSender alloc] init];
    }
}

+ (DataSender *)instance
{
    return instance;
}


// Modified by MUKAI Takeshi
- (NSDictionary*)postDataWithLocations:(NSArray*)locations modeprompts:(NSArray*)modeprompts {
    
    // ready data - user, location, modeprompts
    NSString* string_locations = [CSVExporter exportObjects:locations];
    NSString* string_modeprompts = [CSVExporter exportObjectsModeprompt:modeprompts];
    User* user = [[[CoreDataHelper instance] entityManager] fetchUser];
    
    // dataFormatter for the user created date
    NSDateFormatter *ISO8601Formatter = [[NSDateFormatter alloc]init];
    NSLocale *enUSPOSIXLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    [ISO8601Formatter setLocale:enUSPOSIXLocale];
    [ISO8601Formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZ"];
    
    // set postData
    NSMutableDictionary* postData = [[NSMutableDictionary alloc] init];
    // locations
    postData[@"text"] = string_locations;
    // modeprompts
    postData[@"modeprompt"] = string_modeprompts;
    // user
    postData[@"id"] = user.device_id;
    postData[@"created_at"] = [ISO8601Formatter stringFromDate: user.created_at];
    postData[@"model"] = [[UIDevice currentDevice] modelName];
    postData[@"version"] = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    postData[@"os"] = @"iOS";
    postData[@"osversion"] = [[UIDevice currentDevice] systemVersion];
    postData[@"use_notifications"] = [[NSUserDefaults standardUserDefaults]boolForKey:DM_REMINDERS_FIELD_KEY] ? @"true" : @"false";
    
    postData[@"location_home"] = user.location_home;
    postData[@"location_work"] = user.location_work;
    postData[@"location_study"] = user.location_study;
    postData[@"travel_mode_work"] = user.travel_mode_work;
    postData[@"travel_mode_alt_work"] = user.travel_mode_alt_work;
    postData[@"travel_mode_study"] = user.travel_mode_study;
    postData[@"travel_mode_alt_study"] = user.travel_mode_alt_study;
    
    postData[@"member_type"] = user.member_type;
    postData[@"sex"] = user.sex;
    postData[@"age_bracket"] = user.age_bracket;
    postData[@"documents"] = user.user_docs;
    postData[@"people"] = user.lives_with;
    postData[@"num_of_people"] = user.num_of_people_living;
    postData[@"num_of_minors"] = user.num_of_minors;
    postData[@"num_of_cars"] = user.num_of_cars;
    postData[@"email"] = user.email;
    
    return postData;
}

// Modified by MUKAI Takeshi - for custom survey // cancelledPropmt
- (NSDictionary*)postDataForCustomSurveyWithLocations:(NSArray*)locations modeprompts:(NSArray*)modeprompts cancelledPrompts:(NSArray*)cancelledPrompts {
    
    User* user = [[[CoreDataHelper instance] entityManager] fetchUser];
    
    // set postData
    NSMutableDictionary *postData = [[NSMutableDictionary alloc] init];
    // if user survey answer has no uploaded, post it
    if (!user.uploaded) {
        [postData setObject:user.custom_survey_answer forKey:@"survey"];
    }
    [postData setObject:[CSVExporter exportObjectsForCustomSurvey:locations] forKey:@"coordinates"];
    [postData setObject:[CSVExporter exportObjectsModepromptForCustomSurvey:modeprompts] forKey:@"prompts"];
    [postData setObject:[CSVExporter exportObjectsCancelledPrompt:cancelledPrompts] forKey:@"cancelledPrompts"];
    [postData setObject:user.device_id forKey:@"uuid"];
    
    return postData;
}

//POST DATA WITH LOCATION ONLY
- (NSDictionary*)postDataForCustomSurveyWithLocations:(NSArray*)locations {
    
    User* user = [[[CoreDataHelper instance] entityManager] fetchUser];
    
    // set postData
    NSMutableDictionary *postData = [[NSMutableDictionary alloc] init];
    // if user survey answer has no uploaded, post it
    if (!user.uploaded) {
        [postData setObject:user.custom_survey_answer forKey:@"survey"];
    }
    [postData setObject:[CSVExporter exportObjectsForCustomSurvey:locations] forKey:@"coordinates"];
    [postData setObject:user.device_id forKey:@"uuid"];
    
    return postData;
}

- (NSDictionary*)postDataForCustomSurveyWithModeprompts:(NSArray*)modeprompts{
    
    User* user = [[[CoreDataHelper instance] entityManager] fetchUser];
    // set postData
    NSMutableDictionary *postData = [[NSMutableDictionary alloc] init];
    // if user survey answer has no uploaded, post it
    if (!user.uploaded) {
        [postData setObject:user.custom_survey_answer forKey:@"survey"];
    }
    [postData setObject:[CSVExporter exportObjectsModepromptForCustomSurvey:modeprompts] forKey:@"prompts"];
    [postData setObject:user.device_id forKey:@"uuid"];
    return postData;
}


- (NSDictionary*)postDataForCustomSurveyWithCancelledPrompts:(NSArray*)cancelledPrompts {
    
    User* user = [[[CoreDataHelper instance] entityManager] fetchUser];
    
    // set postData
    NSMutableDictionary *postData = [[NSMutableDictionary alloc] init];
    // if user survey answer has no uploaded, post it
    if (!user.uploaded) {
        [postData setObject:user.custom_survey_answer forKey:@"survey"];
    }
    [postData setObject:[CSVExporter exportObjectsCancelledPrompt:cancelledPrompts] forKey:@"cancelledPrompts"];
    [postData setObject:user.device_id forKey:@"uuid"];
    
    return postData;
}



// Modified by MUKAI Takeshi - for custom survey
- (NSDictionary*)postDataForCustomSurveyCreate:(NSString*)surveyName {
    
    User* user = [[[CoreDataHelper instance] entityManager] fetchUser];
    
    // set postData
    NSMutableDictionary *postData = [[NSMutableDictionary alloc] init];
    [postData setObject:surveyName forKey:@"survey_name"];
    [postData setObject:@"en" forKey:@"lang"];
    //create user object
    NSMutableDictionary *userData = [[NSMutableDictionary alloc] init];
    [userData setObject:user.device_id forKey:@"uuid"];
    [userData setObject:[[UIDevice currentDevice] modelName] forKey:@"model"];
    [userData setObject:@"iOS" forKey:@"os"];
    [userData setObject:[[UIDevice currentDevice] systemVersion] forKey:@"os_version"];
    [userData setObject:[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"] forKey:@"itinerum_version"];
    //attach the object to
    [postData setObject:userData forKey:@"user"];
    
    return postData;
}

// this is called when the app is DidBecomeActive
- (void)syncWithServer
{
    // Modified by MUKAI Takeshi in 2015-11
    // load data which has not been synched yet
    NSArray *locations = [[[CoreDataHelper instance] entityManager] fetchUnsyncedLocations];
    NSArray *modeprompts = [[[CoreDataHelper instance] entityManager] fetchUnsyncedModeprompts];
    NSArray *cancelledPrompts = [[[CoreDataHelper instance] entityManager] fetchUnsyncedCancelledPrompts];  // cancelledPtopmt
    BOOL hasUploadedUser = [[[CoreDataHelper instance] entityManager] hasUplodedUser];  // for custom survey
    
   
    

    // sync with server
    if (locations.count > 0 || modeprompts.count > 0 || cancelledPrompts.count > 0) {
        
        if ([[[CoreDataHelper instance] entityManager] fetchCustomSurveyData]) {
           
            [self syncLocation:locations];
            [self syncModePrompt:modeprompts];
            [self syncCancelPrompt:cancelledPrompts];
            
            // for custom survey
            if (!hasUploadedUser) {
                User* user = [[[CoreDataHelper instance] entityManager] fetchUser];
                user.uploaded = YES;
            }
            [[[CoreDataHelper instance]entityManager]saveContext];
            
        }else{
            
            NSDictionary *postData = [self postDataWithLocations:locations modeprompts:modeprompts]; // ready postData
            NSString* url = [[Config instance] stringValueForKey:@"insertLocationUrl"]; // ready URL from config.plist
            NSURLRequest *postRequest = [self requestWithPostData:postData ToURL:url]; // ready postRequest
            
            [NSURLConnection sendAsynchronousRequest:postRequest queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                DDLogInfo(@"received response to post request: %@", response);
                if (!connectionError) {  // if no error, set property - uploaded "YES"
                   
                    for (Location* location in locations) {
                        location.uploaded = YES;
                    }
                    for (CancelledPrompt* cancelledPrompt in cancelledPrompts) {  // cancelledPrompt
                        cancelledPrompt.uploaded = YES;
                    }
                    for (Modeprompt* modeprompt in modeprompts) {
                        modeprompt.uploaded = YES;
                    }
                    
                    
                    // for custom survey
                    if (!hasUploadedUser) {
                        User* user = [[[CoreDataHelper instance] entityManager] fetchUser];
                        user.uploaded = YES;
                    }
                    [[[CoreDataHelper instance]entityManager]saveContext];
                    
                }else{
                    DDLogError(@"POST error: %@", connectionError);
                }
            }];
 
        }
        
    }
}


-(void)syncLocation:(NSArray*)locations {
    
    NSURLRequest *postRequest;
    
        // if customSurvey exists, do for custom survey  // cancellePropmts
        NSDictionary *postData = [self postDataForCustomSurveyWithLocations:locations]; // ready postData
        NSString* url = [[Config instance] stringValueForKey:@"dmapiURLUpdate"]; // ready URL from config.plist
        postRequest = [self requestWithPostDataForCustomSurvey:postData ToURL:url]; // ready postRequest
    
    
    [NSURLConnection sendAsynchronousRequest:postRequest queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        DDLogInfo(@"received response to post request: %@", response);
        if (!connectionError) {  // if no error, set property - uploaded "YES"
            for (Location* location in locations) {
                location.uploaded = YES;
            }
        }else{
            DDLogError(@"POST error: %@", connectionError);
        }
    }];
    
}


-(void)syncModePrompt:(NSArray*)modeprompts {
    
    NSURLRequest *postRequest;
    
        // if customSurvey exists, do for custom survey  // cancellePropmts
        NSDictionary *postData = [self postDataForCustomSurveyWithModeprompts:modeprompts]; // ready postData
        NSString* url = [[Config instance] stringValueForKey:@"dmapiURLUpdate"]; // ready URL from config.plist
        postRequest = [self requestWithPostDataForCustomSurvey:postData ToURL:url]; // ready postRequest
    
    
    [NSURLConnection sendAsynchronousRequest:postRequest queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        DDLogInfo(@"received response to post request: %@", response);
        if (!connectionError) {  // if no error, set property - uploaded "YES"
        
            for (Modeprompt* modeprompt in modeprompts) {
                modeprompt.uploaded = YES;
            }
           
        }else{
            DDLogError(@"POST error: %@", connectionError);
        }
    }];
}

-(void)syncCancelPrompt:(NSArray*)cancelledPrompts {
    
    NSURLRequest *postRequest;
   
        // if customSurvey exists, do for custom survey  // cancellePropmts
    NSDictionary *postData = [self postDataForCustomSurveyWithCancelledPrompts:cancelledPrompts]; // ready postData
    NSString* url = [[Config instance] stringValueForKey:@"dmapiURLUpdate"]; // ready URL from config.plist
    postRequest = [self requestWithPostDataForCustomSurvey:postData ToURL:url]; // ready postRequest
   
    
    [NSURLConnection sendAsynchronousRequest:postRequest queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        DDLogInfo(@"received response to post request: %@", response);
        if (!connectionError) {  // if no error, set property - uploaded "YES"
           
            for (CancelledPrompt* cancelledPrompt in cancelledPrompts) {  // cancelledPrompt
                cancelledPrompt.uploaded = YES;
            }
        }else{
            DDLogError(@"POST error: %@", connectionError);
        }
    }];
    
}


// this is called by BackgroundFetch
- (void)syncWithServerSynchronously:(void(^)(BOOL success))completionBlock {
    DDLogInfo(@"attempting synchronus POST");
    
    // Modified by MUKAI Takeshi in 2015-11
    // load data which has not been synched yet
    NSArray *locations = [[[CoreDataHelper instance] entityManager] fetchUnsyncedLocations];
    NSArray *modeprompts = [[[CoreDataHelper instance] entityManager] fetchUnsyncedModeprompts];
    NSArray *cancelledPrompts = [[[CoreDataHelper instance] entityManager] fetchUnsyncedCancelledPrompts];  // cancelledPtopmt
    BOOL hasUploadedUser = [[[CoreDataHelper instance] entityManager] hasUplodedUser];  // for custom survey
    
    // sync with server
    if (locations.count > 0 || modeprompts.count > 0 || cancelledPrompts.count > 0) {
        // for custom survey
        NSURLRequest *postRequest;
        if ([[[CoreDataHelper instance] entityManager] fetchCustomSurveyData]) {
            // if customSurvey exists, do for custom survey
            // if customSurvey exists, do for custom survey  // cancellePropmts
            NSDictionary *postData = [self postDataForCustomSurveyWithLocations:locations modeprompts:modeprompts cancelledPrompts:cancelledPrompts]; // ready postData
            NSString* url = [[Config instance] stringValueForKey:@"dmapiURLUpdate"]; // ready URL from config.plist
            postRequest = [self requestWithPostDataForCustomSurvey:postData ToURL:url]; // ready postRequest
        }else{
            // if customSurvey doesn't exist, do for default survey
            NSDictionary *postData = [self postDataWithLocations:locations modeprompts:modeprompts]; // ready postData
            NSString* url = [[Config instance] stringValueForKey:@"insertLocationUrl"]; // ready URL from config.plist
            postRequest = [self requestWithPostData:postData ToURL:url]; // ready postRequest
        }
        
        NSURLResponse *response;
        NSError *error = nil;
        [NSURLConnection sendSynchronousRequest:postRequest
                              returningResponse:&response
                                          error:&error];
        
        if (error == nil) {
            DDLogInfo(@"received response to synchronous POST: %@", response);
            for (Location* location in locations) {
                location.uploaded = YES;
            }
            for (Modeprompt* modeprompt in modeprompts) {
                modeprompt.uploaded = YES;
            }
            for (CancelledPrompt* cancelledPrompt in cancelledPrompts) {  // cancelledPrompt
                cancelledPrompt.uploaded = YES;
            }
            // for custom survey
            if (!hasUploadedUser) {
                User* user = [[[CoreDataHelper instance] entityManager] fetchUser];
                user.uploaded = YES;
            }
            [[[CoreDataHelper instance]entityManager]saveContext];
            completionBlock(YES);
        }else{
            DDLogError(@"sync failed with error: %@, %@, %@", error.localizedDescription, error.localizedFailureReason, error.localizedRecoverySuggestion);
            completionBlock(NO);
        }
    } else { // there are no new locations; don't send
        completionBlock(YES);
    }
}

- (NSURLRequest*)requestWithPostData:(NSDictionary*)dico
                              ToURL:(NSString*)url
{
    NSMutableURLRequest* request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:url]];
    request.HTTPMethod = @"POST" ;
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];
    
    // adding Post Parameters to the request.
    NSString* requestString =[self addQueryStringToUrl:@"" params:dico];
    NSData* data = [NSData dataWithBytes:[requestString UTF8String] length:[requestString length]];
    request.HTTPBody = data;
    request.timeoutInterval = [[Config instance] integerValueForKey:@"connexionTimeoutSeconds"];
    
    return request;
}

// Modified by MUKAI Takeshi - for custom survey
- (NSURLRequest*)requestWithPostDataForCustomSurvey:(NSDictionary*)dico
                                              ToURL:(NSString*)url
{
    NSMutableURLRequest* request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:url]];
    request.HTTPMethod = @"POST" ;
    [request setValue:@"application/json" forHTTPHeaderField:@"content-type"];
    
    // adding Post Parameters to the request.
    NSString* requestString = [self getJsonStringByDictionary:dico];  // convert to JSON format
//    NSLog(@"____________%@",requestString);
    
//    NSData* data = [NSData dataWithBytes:[requestString UTF8String] length:[requestString length]];
    NSData* data = [requestString dataUsingEncoding:NSUTF8StringEncoding];  // for text including non-ascii
    NSLog(@"____________%@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
    
    request.HTTPBody = data;
    request.timeoutInterval = [[Config instance] integerValueForKey:@"connexionTimeoutSeconds"];
    
    return request;
}

// Modified by MUKAI Takeshi - for custom survey
- (NSString*)getJsonStringByDictionary:(NSDictionary*)dictionary
{
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

+ (BOOL)errorMessageReceivedFromServer:(NSString*)dataResponse
{
    // matching the server response to "An error occured during saving your data"
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"An error occured during saving your data"
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:nil];
    NSArray *matches = [regex matchesInString:dataResponse
                                      options:0
                                        range:NSMakeRange(0, [dataResponse length])];
    return [matches count] != 0;
}


/**
 * Code Taken and modified from : git://gist.github.com/916845.git
 * Put a query string onto the end of a url
 */
- (NSString*)addQueryStringToUrl:(NSString*)url params:(NSDictionary *)params
{
    NSMutableString *urlWithQuerystring = [[NSMutableString alloc] initWithString:url];
    // Convert the params into a query string
    if (params)
    {
        BOOL first = true;
        for(id key in params)
        {
            NSString *sKey = [key description];
            NSString *sVal = [[params objectForKey:key] description];
            
            // Do we need to add k=v or &k=v ?
            if (first)
            {
                [urlWithQuerystring appendFormat:@"%@=%@",
                 [sKey stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
                 [sVal stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
                first = false ;
            }
            else
            {
                [urlWithQuerystring appendFormat:@"&%@=%@",
                 [sKey stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
                 [sVal stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
            }
        }
    }
    return urlWithQuerystring;
}

- (void)setObjectIfNotNil:(id)object
                  forKey:(id<NSCopying>)key
           inDictionnary:(NSMutableDictionary*)dictionnary
{
    if(object != nil)
    {
        [dictionnary setObject:object forKey:key];
    }
}


#pragma mark - NSURLConnectionDelegateStuff

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    DDLogError(@"connection: %@ failed with error: %@", connection, error);
}


@end
