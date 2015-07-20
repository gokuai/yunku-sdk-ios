//
//  PopoverView.h
//  ArrowView
//
//  Created by guojiang on 4/9/14.
//  Copyright (c) 2014年 LINAICAI. All rights reserved.
//


#import <UIKit/UIKit.h>

@protocol PopViewDelegate

-(void)selectRowOfPopview:(NSInteger)index;

@end

@interface PopoverView : UIView

-(id)initWithPoint:(CGPoint)point titles:(NSArray *)titles images:(NSArray *)images;
-(id)initWithPoint:(CGPoint)point btns:(NSArray*)btns;
-(void)show;
-(void)dismiss;
-(void)dismiss:(BOOL)animated;

@property (nonatomic, copy) UIColor *borderColor;
@property (nonatomic, copy) void (^selectRowAtIndex)(NSInteger index);
//@property(nonatomic,weak) id<PopViewDelegate> delegate;

@end
