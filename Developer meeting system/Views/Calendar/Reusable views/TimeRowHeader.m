//
//  Developer meeting system
//
//  Created by Ste Prescott on 05/12/2014.
//  Copyright (c) 2014 Ste Prescott. All rights reserved.
//

#import "TimeRowHeader.h"

@implementation TimeRowHeader

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.title = [UILabel new];
        self.title.backgroundColor = [UIColor clearColor];
        self.title.font = [UIFont systemFontOfSize:12.0];
        [self addSubview:self.title];
        
        [self.title makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.centerY);
            make.right.equalTo(self.right).offset(-5.0);
        }];
    }
    return self;
}

#pragma mark - MSTimeRowHeader

- (void)setTime:(NSDate *)time
{
    _time = time;
    
    static NSDateFormatter *dateFormatter;
    if (!dateFormatter) {
        dateFormatter = [NSDateFormatter new];
        dateFormatter.dateFormat = @"h a";
    }
    self.title.text = [dateFormatter stringFromDate:time];
    [self setNeedsLayout];
}

@end
