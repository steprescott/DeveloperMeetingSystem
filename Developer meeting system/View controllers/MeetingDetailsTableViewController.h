//
//  MeetingDetailsTableViewController.h
//  Developer meeting system
//
//  Created by Ste Prescott on 05/12/2014.
//  Copyright (c) 2014 Ste Prescott. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MeetingDetailsTableViewControllerDelegate <NSObject>

- (void)meetingDetailsFormDissmissed;

@end

@class Meeting;

@interface MeetingDetailsTableViewController : UITableViewController

@property (nonatomic, assign) id <MeetingDetailsTableViewControllerDelegate> delegate;
@property (nonatomic, weak) Meeting *meeting;\

@end
