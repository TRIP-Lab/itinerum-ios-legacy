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
//  DMTextCell.m
//  DataMobile
//
//  Created by Colin Rofls on 2014-07-28.
//  Copyright (c) 2014 MML-Concordia. All rights reserved.
//
// Modified by MUKAI Takeshi in 2016-09

#import "DMTextCell.h"
@interface DMTextCell ()
@property (weak, nonatomic) IBOutlet UILabel *customTextLabel;

@end

@implementation DMTextCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
    [super awakeFromNib];  // Modified by MUKAI Takeshi in 2016-09
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

//For each day you use DataMobile, you earn a ballot in our prize draw. At the end of the survey, you could win an iPad 2. To participate, please enter an email address.

-(void)setField:(FXFormField *)field {
    if (field != _field) {
        _field = field;
        if ([field.key isEqualToString:DM_SURVEY_CONTEST_HEADER_KEY]) {
            self.customTextLabel.text = @"To be entered into weekly prize draws, please enter an email address.";
        }else if ([field.key isEqualToString:DM_SURVEY_MAIN_HEADER_KEY]) {
            self.customTextLabel.text = @"To help our research, please tell us a little bit about yourself.";
        }
    }
}

+(CGFloat)heightForField:(FXFormField *)field width:(CGFloat)width {
    return 82.0f;
}



@end
