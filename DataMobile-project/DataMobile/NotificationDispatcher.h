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
//  NotificationDispatcher.h
//  DataMobile
//
//  Created by Zachary Patterson on 12-11-06.
//  Copyright (c) 2012 MML-Concordia. All rights reserved.
//

#import <Foundation/Foundation.h>


/**
 * Class Responsible for dispatching local Notifications
 */
@interface NotificationDispatcher : NSObject

/**
 * @returns a singleton-instance of the object.
 */
+(instancetype)sharedInstance;

+(void)requestNotificationAuthorization;

/**
 We want the user to be notified if and only if the app isn't running.
 We do this by scheduling a notification an hour into the future and
 setting a timer that will invalidate that notification. and repeat the process.
 
 If we are terminated, the timer won't fire and the notification will.
 */
+(void)startNotificationDispatcher;

@end
