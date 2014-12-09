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

- (IBAction)doneButtonWasTapped:(id)sender;

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

- (IBAction)doneButtonWasTapped:(id)sender
{
    if(self.doneButtonWasTappedBlock)
    {
        self.doneButtonWasTappedBlock(self.textView.text);
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}
@end
