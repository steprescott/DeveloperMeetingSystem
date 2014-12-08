//
//  Developer meeting system
//
//  Created by Ste Prescott on 05/12/2014.
//  Copyright (c) 2014 Ste Prescott. All rights reserved.
//

#import "CurrentTimeIndicator.h"

#define MAS_SHORTHAND

@interface CurrentTimeIndicator ()

@property (nonatomic, strong) UILabel *time;
@property (nonatomic, retain) NSTimer *minuteTimer;

@end

@implementation CurrentTimeIndicator

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = [UIColor whiteColor];
        
        self.time = [UILabel new];
        self.time.font = [UIFont boldSystemFontOfSize:10.0];
        self.time.textColor = [UIColor colorWithRed:0.980 green:0.235 blue:0.239 alpha:1];
        [self addSubview:self.time];
        
        [self.time makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.centerY);
            make.right.equalTo(self.right).offset(-5.0);
        }];
        
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSDate *oneMinuteInFuture = [[NSDate date] dateByAddingTimeInterval:60];
        NSDateComponents *components = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit) fromDate:oneMinuteInFuture];
        NSDate *nextMinuteBoundary = [calendar dateFromComponents:components];
        
        self.minuteTimer = [[NSTimer alloc] initWithFireDate:nextMinuteBoundary interval:60 target:self selector:@selector(minuteTick:) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:self.minuteTimer forMode:NSDefaultRunLoopMode];
        
        [self updateTime];
    }
    return self;
}

#pragma mark - MSCurrentTimeIndicator

- (void)minuteTick:(id)sender
{
    [self updateTime];
}

- (void)updateTime
{
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    [dateFormatter setDateFormat:@"h:mm aa"];
    self.time.text = [dateFormatter stringFromDate:[NSDate date]];
    [self.time sizeToFit];
}

@end
