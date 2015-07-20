//
//  AGAlertViewWithProgressbar.h
//  GoKuai
//
//  Created by apple on 12-7-25.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface AGAlertViewWithProgressbar : NSObject<UIAlertViewDelegate>
{
    NSUInteger progress;
    NSString *title;
    NSString *message;
    NSString *cancelButtonTitle;
    NSArray *otherButtonTitles;
}

@property (nonatomic, assign) NSUInteger progress;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *message;
@property (nonatomic, strong) NSString *cancelButtonTitle;
@property (nonatomic, strong) NSArray *otherButtonTitles;
@property (nonatomic, weak) id<UIAlertViewDelegate> delegate;
@property (nonatomic, readonly, getter=isVisible) BOOL visible;

- (id)initWithTitle:(NSString *)theTitle message:(NSString *)theMessage andDelegate:(id<UIAlertViewDelegate>)theDelegate;
- (id)initWithTitle:(NSString *)theTitle message:(NSString *)theMessage delegate:(id)theDelegate cancelButtonTitle:(NSString *)titleForTheCancelButton otherButtonTitles:(NSString *)titleForTheFirstButton, ... NS_REQUIRES_NIL_TERMINATION;

- (void)show;
- (void)hide;

@end
