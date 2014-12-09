//
//  TextFieldViewController.h
//  Developer meeting system
//
//  Created by Ste Prescott on 08/12/2014.
//  Copyright (c) 2014 Ste Prescott. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TextViewViewController : UIViewController

@property (nonatomic, strong) NSString *currentText;
@property (nonatomic, copy) void (^doneButtonWasTappedBlock)(NSString *updatedText);

@end
