//
//  YesNoTableViewCell.h
//  Developer meeting system
//
//  Created by Ste Prescott on 08/12/2014.
//  Copyright (c) 2014 Ste Prescott. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YesNoTableViewCell : UITableViewCell

@property (nonatomic, assign) BOOL enabled;
@property (weak, nonatomic) IBOutlet UILabel *label;

- (BOOL)isYes;
- (void)setToYes;

@end
