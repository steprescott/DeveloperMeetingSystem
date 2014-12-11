//
//  TextFieldViewController.m
//  Developer meeting system
//
//  Created by Ste Prescott on 08/12/2014.
//  Copyright (c) 2014 Ste Prescott. All rights reserved.
//

#import "TextViewViewController.h"

@interface TextViewViewController ()

@property (weak, nonatomic) IBOutlet UITextView *textView;

@end

@implementation TextViewViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.textView.text = self.currentText;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if(self.doneButtonWasTappedBlock)
    {
        self.doneButtonWasTappedBlock(self.textView.text);
    }
}

@end
