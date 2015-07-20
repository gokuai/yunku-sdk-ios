//
//  FGalleryViewController.h
//  FGallery
//
//  Created by Grant Davis on 5/19/10.
//  Copyright 2011 Grant Davis Interactive, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "FGalleryPhotoView.h"
#import "FGalleryPhoto.h"

#import <MessageUI/MFMailComposeViewController.h>
#import <MessageUI/MFMessageComposeViewController.h>
#import "AGAlertViewWithProgressbar.h"

@protocol FGalleryViewControllerDelegate;

@interface FGalleryViewController : UIViewController <UIScrollViewDelegate,FGalleryPhotoDelegate,FGalleryPhotoViewDelegate,UIDocumentInteractionControllerDelegate, MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate,UIAlertViewDelegate,NSURLConnectionDelegate> {
	
	BOOL _isActive;
	BOOL _isFullscreen;
	BOOL _isScrolling;
	BOOL _isThumbViewShowing;
	
	UIStatusBarStyle _prevStatusStyle;
	CGFloat _prevNextButtonSize;
	CGRect _scrollerRect;
	NSString *galleryID;
	NSInteger _currentIndex;
    NSInteger _resouceListType;
    NSMutableArray *_photoArray;
	
	UIView *_container; // used as view for the controller
	UIView *_innerContainer; // sized and placed to be fullscreen within the container
	UIToolbar *_toolbar;
	UIScrollView *_thumbsView;
	UIScrollView *_scroller;
	UIView *_captionContainer;
	UILabel *_caption;
	
	NSMutableDictionary *_photoLoaders;
	NSMutableArray *_barItems;
	NSMutableArray *_photoThumbnailViews;
	NSMutableArray *_photoViews;
    
	UIBarButtonItem *_nextButton;
	UIBarButtonItem *_prevButton;
    UIBarButtonItem *_favorButton;
    UIBarButtonItem *_shareButton;
    UIBarButtonItem *_remindButton;
    UIBarButtonItem *_actionButton;
    
    NSInteger _isCopyFile;

	UIDocumentInteractionController *_docController;
}

- (id)initWithPhotoSource:(NSObject<FGalleryViewControllerDelegate>*)photoSrc;
- (id)initWithPhotoSource:(NSObject<FGalleryViewControllerDelegate>*)photoSrc barItems:(NSArray*)items;

- (void)next;
- (void)previous;
- (void)gotoImageByIndex:(NSUInteger)index animated:(BOOL)animated;
- (void)removeImageAtIndex:(NSUInteger)index;
- (void)reloadGallery;
- (FGalleryPhoto*)currentPhoto;
-(void)setNeedRefresh;

@property NSInteger currentIndex;
@property NSInteger resouceListType;
@property NSInteger startingIndex;
@property (nonatomic,strong) NSMutableArray *photoArray;
@property (nonatomic,weak) NSObject<FGalleryViewControllerDelegate> *photoSource;
@property (nonatomic,readonly) UIToolbar *toolBar;
@property (nonatomic,readonly) UIView* thumbsView;
@property (nonatomic,strong) NSString *galleryID;
@property (nonatomic) BOOL useThumbnailView;
@property (nonatomic) BOOL beginsInThumbnailView;
@property (nonatomic)  BOOL bNeedRefresh;

@property(nonatomic,strong) NSString *downloadFileHttpUrl;
@property(nonatomic) BOOL isLoading;
@property(nonatomic) BOOL needRefresh;
@property(nonatomic) BOOL needAction;
@property(nonatomic) NSString* fileCachePath;
@property(nonatomic)AGAlertViewWithProgressbar *alertViewWithProgressbar;
@end

