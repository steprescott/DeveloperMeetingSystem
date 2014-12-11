//
//  YesNoTableViewCell.m
//  Developer meeting system
//
//  Created by Ste Prescott on 08/12/2014.
//  Copyright (c) 2014 Ste Prescott. All rights reserved.
//

#import "YesNoTableViewCell.h"

@interface YesNoTableViewCell ()

@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;

@end

@implementation YesNoTableViewCell

-(void)setEnabled:(BOOL)enabled
{
    _enabled = enabled;
    self.segmentedControl.enabled = self.enabled;
}

- (BOOL)isYes
{
    return self.segmentedControl.selectedSegmentIndex;
}

- (void)setToYes
{
    [self.segmentedControl setSelectedSegmentIndex:1];
}

@end
