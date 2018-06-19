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
//  CustomButtonCell.m
//  CustomButtonExample
//
//  Created by Nick Lockwood on 07/04/2014.
//  Copyright (c) 2014 Charcoal Design. All rights reserved.
//

#import "CustomButtonCell.h"


@interface CustomButtonCell ()

@property (nonatomic, strong) IBOutlet UIButton *cellButton;

@end


@implementation CustomButtonCell

//note: we could override -awakeFromNib or -initWithCoder: if we wanted
//to do any customisation in code, but in this case we don't need to

//if we were creating the cell programamtically instead of using a nib
//we would override -initWithStyle:reuseIdentifier: to do the configuration

- (IBAction)buttonAction
{
    if (self.field.action) self.field.action(self);
}

@end
