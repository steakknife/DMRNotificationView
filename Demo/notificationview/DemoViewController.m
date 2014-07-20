//
//  DemoViewController.m
//  notificationview
//
//  Created by Damir Tursunovic on 1/23/13.
//  Copyright (c) 2013 Damir Tursunovic (damir.me). All rights reserved.
//

#import "DemoViewController.h"
#import "DMRNotificationView.h"

@interface DemoViewController () <DMRNotificationViewDelegate>

@end

@implementation DemoViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    self.title = @"Notification View";
    self.view.backgroundColor = [UIColor scrollViewTexturedBackgroundColor];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button setTitle:@"Quick notification!" forState:UIControlStateNormal];
    [button setFrame:CGRectMake(20.0, 20.0, 280.0, 34.0)];
    [button addTarget:self action:@selector(didTapButton:) forControlEvents:UIControlEventTouchUpInside];
    [button setTag:0];
    [self.view addSubview:button];
    
    UIButton *button2 = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button2 setTitle:@"Warning!" forState:UIControlStateNormal];
    [button2 setFrame:CGRectMake(20.0, 70, 280.0, 34.0)];
    [button2 addTarget:self action:@selector(didTapButton:) forControlEvents:UIControlEventTouchUpInside];
    [button2 setTag:1];
    [self.view addSubview:button2];
    
    UIButton *button3 = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button3 setTitle:@"More Advanced!" forState:UIControlStateNormal];
    [button3 setFrame:CGRectMake(20.0, 120, 280.0, 34.0)];
    [button3 addTarget:self action:@selector(didTapButton:) forControlEvents:UIControlEventTouchUpInside];
    [button3 setTag:2];
    [self.view addSubview:button3];
    
    UIButton *button4 = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button4 setTitle:@"Not transparent" forState:UIControlStateNormal];
    [button4 setFrame:CGRectMake(20.0, 170, 280.0, 34.0)];
    [button4 addTarget:self action:@selector(didTapButton:) forControlEvents:UIControlEventTouchUpInside];
    [button4 setTag:3];
    [self.view addSubview:button4];
    
    UIButton *button5 = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button5 setTitle:@"White panel" forState:UIControlStateNormal];
    [button5 setFrame:CGRectMake(20.0, 220, 280.0, 34.0)];
    [button5 addTarget:self action:@selector(didTapButton:) forControlEvents:UIControlEventTouchUpInside];
    [button5 setTag:4];
    [self.view addSubview:button5];
}





#pragma mark -
#pragma mark Input

-(void)didTapButton:(UIButton *)button
{
    switch (button.tag) {
        case 0:
            [DMRNotificationView showInView:self.view
                                  title:@"Simple notification"
                               subTitle:@"This method allows you to quickly show a notification panel."];
            break;
            
        case 1:
            [DMRNotificationView showWarningInView:self.view
                                               title:@"Warning!"
                                        subTitle:@"Simple method to quickly show a warning"];
            break;
            
        case 2:
            {
                NSString *title = @"Different font";
                NSString *subTitle = @"To customise fonts (and more) you need to use the default init method. \n\nTake a look at the beginning in the implementation file where you can also adjust the default tint color, shadow offset, text inset and more.\n\nBy the way, you have to tap this view to dismiss.";
                
                DMRNotificationView *notificationView = [[DMRNotificationView alloc] initWithTitle:title subTitle:subTitle targetView:self.view];
                notificationView.titleFont = [UIFont fontWithName:@"MarkerFelt-Thin" size:20.0];
                notificationView.subTitleFont = [UIFont fontWithName:@"MarkerFelt-Thin" size:13.0];
                notificationView.hideTimeInterval = 0.0;     // Prevents the notification view to automatically dismiss
                notificationView.didTapHandler =^() {
                    [[[UIAlertView alloc] initWithTitle:@"Good job!" message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles:@"ok", nil] show];
                };
                notificationView.delegate = self;
                [notificationView showAnimated:YES];
            }
            break;
            
        case 3:
            {
                DMRNotificationView *notificationView = [[DMRNotificationView alloc] initWithTitle:@"Not transparent" subTitle:@"You can disable transparency by setting 'trasparent' to NO" targetView:self.view];
                [notificationView setTintColor:[UIColor scrollViewTexturedBackgroundColor]];        
                [notificationView setIsTransparent:NO];         // Disable tint color transparency
                [notificationView showAnimated:YES];
            }
            break;

        case 4:
            {
                [DMRNotificationView showInView:self.view
                                          title:@"White panel"
                                       subTitle:@"Text will be dark if the tint color is bright"
                                      tintColor:[UIColor whiteColor]];
            }
            break;
    }
}

- (void)notificationDidAppearAnimated:(BOOL)animated {
    NSLog(@"did appear");
}

- (void)notificationDidDisappearAnimated:(BOOL)animated {
    NSLog(@"did disappear");
}

- (void)notificationDidTapAnimated:(BOOL)animated {
    NSLog(@"did tap");
}

- (void)notificationWillAppearAnimated:(BOOL)animated {
    NSLog(@"will appear");
}

- (void)notificationWillDisppearAnimated:(BOOL)animated {
    NSLog(@"will disappear");
}


@end
