//
//  Developer meeting system
//
//  Created by Ste Prescott on 05/12/2014.
//  Copyright (c) 2014 Ste Prescott. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Meeting;

@interface MeetingCell : UICollectionViewCell

@property (nonatomic, weak) Meeting *meeting;

@property (nonatomic, strong) UILabel *title;
@property (nonatomic, strong) UILabel *location;

- (void)updateColors;

@end
