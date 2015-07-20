//
//  FGalleryViewController.m
//  FGallery
//
//  Created by Grant Davis on 5/19/10.
//  Copyright 2011 Grant Davis Interactive, LLC. All rights reserved.
//

#import "FGalleryViewController.h"
#import "ObjcUtils.h"
#import <iOSYunkuSDK/iOSYunkuSDK-Swift.h>

#define kThumbnailSize 75
#define kThumbnailSpacing 4
#define kCaptionPadding 3
#define kToolbarHeight 40


@interface FGalleryViewController (Private)

// general
- (void)buildViews;

- (void)destroyViews;

- (void)layoutViews;

- (void)moveScrollerToCurrentIndexWithAnimation:(BOOL)animation;

- (void)updateTitle;

- (void)updateButtons;

- (void)layoutButtons;

- (void)updateScrollSize;

- (void)updateCaption;

- (void)resizeImageViewsWithRect:(CGRect)rect;

- (void)resetImageViewZoomLevels;

- (void)enterFullscreen;

- (void)exitFullscreen;

- (void)enableApp;

- (void)disableApp;

- (void)positionInnerContainer;

- (void)positionScroller;

- (void)positionToolbar;

- (void)resizeThumbView;


// thumbnails
- (void)toggleThumbnailViewWithAnimation:(BOOL)animation;

- (void)showThumbnailViewWithAnimation:(BOOL)animation;

- (void)hideThumbnailViewWithAnimation:(BOOL)animation;

- (void)buildThumbsViewPhotos;

- (void)arrangeThumbs;

- (void)loadAllThumbViewPhotos;

- (void)preloadThumbnailImages;

- (void)unloadFullsizeImageWithIndex:(NSUInteger)index;

- (void)scrollingHasEnded;

- (void)handleSeeAllTouch:(id)sender;

- (void)handleThumbClick:(id)sender;

- (FGalleryPhoto *)createGalleryPhotoForIndex:(NSUInteger)index;

- (void)loadThumbnailImageWithIndex:(NSUInteger)index;

- (void)loadFullsizeImageWithIndex:(NSUInteger)index;

@end


@implementation FGalleryViewController
{
    FGalleryPhoto *_nowLoadingPhoto;
    NSMutableData *_fileDownloadData;
    NSURLConnection *_fileDownloadConn;
    NSInteger _responseCode;
    long long _totalSize;
    
}
@synthesize galleryID;
@synthesize photoSource = _photoSource;
@synthesize currentIndex = _currentIndex;
@synthesize resouceListType = _resouceListType;
@synthesize photoArray = _photoArray;
@synthesize thumbsView = _thumbsView;
@synthesize toolBar = _toolbar;
@synthesize useThumbnailView = _useThumbnailView;
@synthesize startingIndex = _startingIndex;
@synthesize beginsInThumbnailView = _beginsInThumbnailView;
@synthesize bNeedRefresh;


#pragma mark - Public Methods


-(void)setNeedRefresh
{
    bNeedRefresh=YES;
    
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nil bundle:nil])) {

        // init gallery id with our memory address
        self.galleryID = [NSString stringWithFormat:@"%p", self];

        // configure view controller
        self.hidesBottomBarWhenPushed = YES;

        // set defaults
        _useThumbnailView = YES;
        _prevStatusStyle = [[UIApplication sharedApplication] statusBarStyle];

        // create storage objects
        _currentIndex = 0;
        _startingIndex = 0;
        _resouceListType = 0;
        _photoArray = [[NSMutableArray alloc] init];
        _photoLoaders = [[NSMutableDictionary alloc] init];
        _photoViews = [[NSMutableArray alloc] init];
        _photoThumbnailViews = [[NSMutableArray alloc] init];

    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
}


- (id)initWithPhotoSource:(NSObject <FGalleryViewControllerDelegate> *)photoSrc {
    if ((self = [self initWithNibName:nil bundle:nil])) {

        _photoSource = photoSrc;
    }
    return self;
}


- (id)initWithPhotoSource:(NSObject <FGalleryViewControllerDelegate> *)photoSrc barItems:(NSArray *)items {
    if ((self = [self initWithPhotoSource:photoSrc])) {

    }
    return self;
}



- (void)loadView {
    // create public objects first so they're available for custom configuration right away. positioning comes later.
    _container = [[UIView alloc] initWithFrame:CGRectZero];
    _innerContainer = [[UIView alloc] initWithFrame:CGRectZero];
    _scroller = [[UIScrollView alloc] initWithFrame:CGRectZero];
    _thumbsView = [[UIScrollView alloc] initWithFrame:CGRectZero];
    _toolbar = [[UIToolbar alloc] initWithFrame:CGRectZero];
    _captionContainer = [[UIView alloc] initWithFrame:CGRectZero];
    _caption = [[UILabel alloc] initWithFrame:CGRectZero];

    _toolbar.barStyle = UIBarStyleBlackTranslucent;
    _container.backgroundColor = [UIColor blackColor];

    // listen for container frame changes so we can properly update the layout during auto-rotation or going in and out of fullscreen
    [_container addObserver:self forKeyPath:@"frame" options:NSKeyValueObservingOptionNew context:nil];

    // setup scroller
    _scroller.delegate = self;
    _scroller.pagingEnabled = YES;
    _scroller.showsVerticalScrollIndicator = NO;
    _scroller.showsHorizontalScrollIndicator = NO;

    // setup caption
    _captionContainer.backgroundColor = [UIColor colorWithWhite:0.0 alpha:.35];
    _captionContainer.hidden = YES;
    _captionContainer.userInteractionEnabled = NO;
    _captionContainer.exclusiveTouch = YES;
    _caption.font = [UIFont systemFontOfSize:14.0];
    _caption.textColor = [UIColor whiteColor];
    _caption.backgroundColor = [UIColor clearColor];
    _caption.textAlignment = NSTextAlignmentCenter;
    _caption.shadowColor = [UIColor blackColor];
    _caption.shadowOffset = CGSizeMake(1, 1);

    // make things flexible
    _container.autoresizesSubviews = NO;
    _innerContainer.autoresizesSubviews = NO;
    _scroller.autoresizesSubviews = NO;
    _container.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

    // setup thumbs view
    _thumbsView.backgroundColor = [UIColor blackColor];
    _thumbsView.hidden = YES;
    _thumbsView.contentInset = UIEdgeInsetsMake(kThumbnailSpacing, kThumbnailSpacing, kThumbnailSpacing, kThumbnailSpacing);

    // set view
    self.view = _container;

    // add items to their containers
    [_container addSubview:_innerContainer];
    //[_container addSubview:_thumbsView];

    [_innerContainer addSubview:_scroller];
    [_innerContainer addSubview:_toolbar];

    [_toolbar addSubview:_captionContainer];
    [_captionContainer addSubview:_caption];

    _actionButton = [[UIBarButtonItem alloc] initWithImage: [OBJCMethodBridge getLocalImage:@"btn_action"] style:UIBarButtonItemStylePlain target:self action:@selector(onAction:)];
    _actionButton.tintColor = [UIColor whiteColor];

    // add prev next to front of the array

    UIBarButtonItem *fixedbtn=[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];

    _barItems=[NSMutableArray arrayWithObjects:fixedbtn,_actionButton,fixedbtn, nil];

    // set buttons on the toolbar.
    [_toolbar setItems:_barItems animated:NO];

    // build stuff
    [self reloadGallery];


}


- (void)viewDidUnload {

    [self destroyViews];

    _barItems = nil;
    _nextButton = nil;
    _prevButton = nil;
    _favorButton = nil;
    _container = nil;
    _innerContainer = nil;
    _scroller = nil;
    _thumbsView = nil;
    _toolbar = nil;
    _captionContainer = nil;
    _caption = nil;

    [super viewDidUnload];
}


- (void)destroyViews {
    // remove previous photo views
    for (UIView *view in _photoViews) {
        [view removeFromSuperview];
    }
    [_photoViews removeAllObjects];

    // remove previous thumbnails
    for (UIView *view in _photoThumbnailViews) {
        [view removeFromSuperview];
    }
    [_photoThumbnailViews removeAllObjects];

    // remove photo loaders
    NSArray *photoKeys = [_photoLoaders allKeys];
    for (int i = 0; i < [photoKeys count]; i++) {
        FGalleryPhoto *photoLoader = _photoLoaders[photoKeys[i]];
        photoLoader.delegate = nil;
        [photoLoader unloadFullsize];
    }
    [_photoLoaders removeAllObjects];
}


- (void)removeImageAtIndex:(NSUInteger)index {

}

- (void)reloadGallery {
    _currentIndex = _startingIndex;
    _isThumbViewShowing = NO;

    // build the new
    if (_photoArray.count > 0) {
        // create the image views for each photo
        [self buildViews];
    }
}

- (FGalleryPhoto *)currentPhoto {
    return _photoLoaders[[NSString stringWithFormat:@"%li", (long)_currentIndex]];
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    _isActive = YES;

    self.useThumbnailView = _useThumbnailView;

    // toggle into the thumb view if we should start there
    if (_beginsInThumbnailView && _useThumbnailView) {
        [self showThumbnailViewWithAnimation:NO];
        [self loadAllThumbViewPhotos];
    }

    [self layoutViews];

    // update status bar to be see-through
    //[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque animated:animated];

    // init with next on first run.
    if (_currentIndex == -1)
    {
        [self next];
    } else {
        [self gotoImageByIndex:_currentIndex animated:NO];
    }
}


- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    _isActive = NO;

    [[UIApplication sharedApplication] setStatusBarStyle:_prevStatusStyle animated:animated];
}


- (void)resizeImageViewsWithRect:(CGRect)rect {
    // resize all the image views
    NSUInteger i, count = [_photoViews count];
    float dx = 0;
    for (i = 0; i < count; i++) {
        FGalleryPhotoView *photoView = _photoViews[i];
        photoView.frame = CGRectMake(dx, 0, rect.size.width, rect.size.height);
        dx += rect.size.width;
    }
}


- (void)resetImageViewZoomLevels {
    // resize all the image views
    NSUInteger i, count = [_photoViews count];
    for (i = 0; i < count; i++) {
        FGalleryPhotoView *photoView = _photoViews[i];
        [photoView resetZoom];
    }
}

- (void)next {
    NSUInteger numberOfPhotos = _photoArray.count;
    NSUInteger nextIndex = _currentIndex + 1;

    // don't continue if we're out of images.
    if (nextIndex <= numberOfPhotos) {
        [self gotoImageByIndex:nextIndex animated:NO];
    }
}

- (void)previous {
    NSUInteger prevIndex = _currentIndex - 1;
    [self gotoImageByIndex:prevIndex animated:NO];
}


- (void)onAction:(id)sender {
    _needAction=YES;
    [self handleSeeAllTouch:sender];
    return;
}


#pragma documentDelegate

- (void)documentInteractionController:(UIDocumentInteractionController *)controller willBeginSendingToApplication:(NSString *)application {

}

- (void)documentInteractionController:(UIDocumentInteractionController *)controller didEndSendingToApplication:(NSString *)application {

}

- (void)documentInteractionControllerDidDismissOpenInMenu:(UIDocumentInteractionController *)controller {

    if (_isCopyFile) {
        NSString *deleteFilePath = [ObjcUtils replaceStrBySearchStr:[controller.URL absoluteString] search:@"file://localhost" replace:@""];
        [[NSFileManager defaultManager] removeItemAtPath:deleteFilePath error:nil];
    }
}

- (void)gotoImageByIndex:(NSUInteger)index animated:(BOOL)animated {
    NSUInteger numPhotos = _photoArray.count;

    // constrain index within our limits
    if (index >= numPhotos) index = numPhotos - 1;

    if (numPhotos == 0) {
        _currentIndex = -1;
    }
    else {

        // clear the fullsize image in the old photo
        //[self unloadFullsizeImageWithIndex:_currentIndex];

        _currentIndex = index;
        [self moveScrollerToCurrentIndexWithAnimation:animated];
        [self updateTitle];
        [self updateCaption];
        
        ImageData *fitem = _photoArray[index];
        BOOL bexist = NO;
        if (fitem.localPath && fitem.localPath.length>0 && [[NSFileManager defaultManager] fileExistsAtPath:fitem.localPath] ) {
            bexist=YES;
        }
        if (!bexist) {
            NSString *fpath= fitem.thumbBigCachePath;
            bexist =([[NSFileManager defaultManager] fileExistsAtPath:fpath] && fitem.thumbBigCacheSize>0);
        }
        
        if (bexist) {
            return;
        }
        
        
        if (!animated) {
            [self loadFullsizeImageWithIndex:index];
        }
        
    }
}


- (void)layoutViews {
    [self positionInnerContainer];
    [self positionScroller];
    [self positionToolbar];
    [self updateScrollSize];
    [self updateCaption];
    [self resizeImageViewsWithRect:_scroller.frame];
    [self moveScrollerToCurrentIndexWithAnimation:NO];
}

- (void)onCloseAction {
    NSArray *keys = [_photoLoaders allKeys];
    NSUInteger i, count = [keys count];
    for (i = 0; i < count; i++) {
        FGalleryPhoto *photo = _photoLoaders[keys[i]];
        if (photo.isFullsizeLoading) {
            [photo unloadFullsize];
            [photo cancelLoad];
        }
    }
    //FIXME
//    [FolderOperationManager getInstance].srcRefresh = bNeedRefresh;
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)setUseThumbnailView:(BOOL)useThumbnailView {
    _useThumbnailView = useThumbnailView;
    if (self.navigationController) {
        if (_useThumbnailView) {

            UIBarButtonItem *btn =  [[UIBarButtonItem alloc]initWithTitle:[OBJCMethodBridge getLocalString:@"Save" comment:@""] style:UIBarButtonItemStylePlain target:self action:@selector(onSaveAct:)];
           
            [self.navigationItem setRightBarButtonItem:btn animated:YES];

            UIBarButtonItem *closeBtn = [[UIBarButtonItem alloc]initWithTitle:[OBJCMethodBridge getLocalString:@"Close" comment:@""] style:UIBarButtonItemStylePlain target:self action:@selector(onCloseAction)];
            
            self.navigationItem.leftBarButtonItem = closeBtn;
        }
        else {
            [self.navigationItem setRightBarButtonItem:nil animated:NO];
        }
    }
}

-(void)onSaveAct:(id)sender
{
    _needAction=NO;
    [self handleSeeAllTouch:sender];
}


/*共享按钮事件及代理方法实现*/
#pragma mark - MFMailComposeViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController *)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError *)error {

    [controller dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - MFMessageComposeViewControllerDelegate

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
    switch (result) {
        case MessageComposeResultCancelled:
            break;

        case MessageComposeResultFailed:
            [OBJCMethodBridge makeToast:[OBJCMethodBridge getLocalString:@"Message send Failed" comment:@""] view:self.view];
        
            break;
        case MessageComposeResultSent:

            [OBJCMethodBridge makeToast:[OBJCMethodBridge getLocalString:@"Message send success" comment:@""] view:self.view];
            break;
        default:
            break;
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (void)animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
    if ([animationID isEqualToString:@"close"]) {

    }
}

#pragma mark - Private Methods

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"frame"]) {
        [self layoutViews];
    }
}


- (void)positionInnerContainer {
    CGRect screenFrame = [[UIScreen mainScreen] bounds];
    CGRect innerContainerRect;

    if (self.interfaceOrientation == UIInterfaceOrientationPortrait) {//portrait
        innerContainerRect = CGRectMake(0, _container.frame.size.height - screenFrame.size.height, _container.frame.size.width, screenFrame.size.height);
    }
    else {// landscape
        innerContainerRect = CGRectMake(0, _container.frame.size.height - screenFrame.size.width, _container.frame.size.width, screenFrame.size.width);
    }

    _innerContainer.frame = innerContainerRect;
}


- (void)positionScroller {
    CGRect screenFrame = [[UIScreen mainScreen] bounds];
    CGRect scrollerRect;

    if (self.interfaceOrientation == UIInterfaceOrientationPortrait) {//portrait
        scrollerRect = CGRectMake(0, 0, screenFrame.size.width, screenFrame.size.height);
    }
    else {//landscape
        scrollerRect = CGRectMake(0, 0, screenFrame.size.height, screenFrame.size.width);
    }

    _scroller.frame = scrollerRect;
}


- (void)positionToolbar {
    _toolbar.frame = CGRectMake(0, _scroller.frame.size.height - kToolbarHeight, _scroller.frame.size.width, kToolbarHeight);
}


- (void)resizeThumbView {
    int barHeight = 0;
    if (self.navigationController.navigationBar.barStyle == UIBarStyleBlackTranslucent) {
        barHeight = self.navigationController.navigationBar.frame.size.height;
    }
    _thumbsView.frame = CGRectMake(0, barHeight, _container.frame.size.width, _container.frame.size.height - barHeight);
}


- (void)enterFullscreen {
    _isFullscreen = YES;

    [self disableApp];

    [self.navigationController setNavigationBarHidden:YES animated:YES];

    [UIView beginAnimations:@"galleryOut" context:nil];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(enableApp)];
    _toolbar.alpha = 0.0;
    _captionContainer.alpha = 0.0;
    [UIView commitAnimations];
}


- (void)exitFullscreen {
    _isFullscreen = NO;

    [self disableApp];

    UIApplication *application = [UIApplication sharedApplication];
    if ([application respondsToSelector:@selector(setStatusBarHidden:withAnimation:)]) {
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade]; // 3.2+
    } else {
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
        [[UIApplication sharedApplication] setStatusBarHidden:NO animated:NO]; // 2.0 - 3.2
#pragma GCC diagnostic warning "-Wdeprecated-declarations"
    }

    [self.navigationController setNavigationBarHidden:NO animated:YES];

    [UIView beginAnimations:@"galleryIn" context:nil];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(enableApp)];
    _toolbar.alpha = 1.0;
    _captionContainer.alpha = 1.0;
    [UIView commitAnimations];
}


- (void)enableApp {
    [[UIApplication sharedApplication] endIgnoringInteractionEvents];
}


- (void)disableApp {
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
}


- (void)didTapPhotoView:(FGalleryPhotoView *)photoView {
    // don't change when scrolling
    if (_isScrolling || !_isActive) return;

    // toggle fullscreen.
    if (_isFullscreen == NO) {

        [self enterFullscreen];
    }
    else {

        [self exitFullscreen];
    }

}


- (void)updateCaption {
    if (_photoArray.count > 0) {
            ImageData * data = _photoArray[_currentIndex];
            NSString *caption = data.fileName;

            if ([caption length] > 0) {
                float captionWidth = _container.frame.size.width - kCaptionPadding * 2;
                CGSize textSize = [caption sizeWithFont:_caption.font];
                NSUInteger numLines = ceilf(textSize.width / captionWidth);
                NSInteger height = (textSize.height + kCaptionPadding) * numLines;

                _caption.numberOfLines = numLines;
                _caption.text = caption;

                NSInteger containerHeight = height + kCaptionPadding * 2;
                _captionContainer.frame = CGRectMake(0, -containerHeight, _container.frame.size.width, containerHeight);
                _caption.frame = CGRectMake(kCaptionPadding, kCaptionPadding, captionWidth, height);

                // show caption bar
                _captionContainer.hidden = NO;
            }
            else {

                // hide it if we don't have a caption.
                _captionContainer.hidden = YES;
            }

    }

}


- (void)updateScrollSize {
    float contentWidth = _scroller.frame.size.width * _photoArray.count;
    [_scroller setContentSize:CGSizeMake(contentWidth, _scroller.frame.size.height)];
}


- (void)updateTitle {
    self.navigationItem.title = [NSString stringWithFormat:@"%li of %lu", _currentIndex + 1, (unsigned long)_photoArray.count];
}


- (void)updateButtons {
    _prevButton.enabled = _currentIndex > 0;
    _nextButton.enabled = _currentIndex < _photoArray.count - 1;
}


- (void)layoutButtons {

}


- (void)moveScrollerToCurrentIndexWithAnimation:(BOOL)animation {
    int xp = _scroller.frame.size.width * _currentIndex;
    [_scroller scrollRectToVisible:CGRectMake(xp, 0, _scroller.frame.size.width, _scroller.frame.size.height) animated:animation];
    _isScrolling = animation;
}


// creates all the image views for this gallery
- (void)buildViews {
    NSUInteger i, count = _photoArray.count;
    for (i = 0; i < count; i++) {
        FGalleryPhotoView *photoView = [[FGalleryPhotoView alloc] initWithFrame:CGRectZero];
        photoView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        photoView.autoresizesSubviews = YES;
        photoView.photoDelegate = self;
        [_scroller addSubview:photoView];
        [_photoViews addObject:photoView];
        
        ImageData* fileitem = _photoArray[i];
        NSString *fpath = fileitem.localPath;
        BOOL bexist = NO;
        if (fpath && fpath.length>0 && [[NSFileManager defaultManager] fileExistsAtPath:fpath] && fileitem.localFileSize > 0 ) {
            bexist=YES;
        }
        if (!bexist) {
            fpath = fileitem.thumbBigCachePath;

            bexist = ([[NSFileManager defaultManager] fileExistsAtPath:fpath] && fileitem.thumbBigCacheSize > 0);
        }

        if (bexist) {
            photoView.imageView.image = [UIImage imageWithContentsOfFile:fpath];
            [photoView.activity stopAnimating];
            [photoView.progressLabel setHidden:YES];
        } else {
            [photoView.activity startAnimating];
        }
    }
}


- (void)buildThumbsViewPhotos {
    NSUInteger i, count = _photoArray.count;
    for (i = 0; i < count; i++) {

        FGalleryPhotoView *thumbView = [[FGalleryPhotoView alloc] initWithFrame:CGRectZero target:self action:@selector(handleThumbClick:)];
        [thumbView setContentMode:UIViewContentModeScaleAspectFill];
        [thumbView setClipsToBounds:YES];
        [thumbView setTag:i];
        [_thumbsView addSubview:thumbView];
        [_photoThumbnailViews addObject:thumbView];
    }
}


- (void)arrangeThumbs {
    float dx = 0.0;
    float dy = 0.0;
    // loop through all thumbs to size and place them
    NSUInteger i, count = [_photoThumbnailViews count];
    for (i = 0; i < count; i++) {
        FGalleryPhotoView *thumbView = _photoThumbnailViews[i];
        [thumbView setBackgroundColor:[UIColor grayColor]];

        // create new frame
        thumbView.frame = CGRectMake(dx, dy, kThumbnailSize, kThumbnailSize);

        // increment position
        dx += kThumbnailSize + kThumbnailSpacing;

        // check if we need to move to a different row
        if (dx + kThumbnailSize + kThumbnailSpacing > _thumbsView.frame.size.width - kThumbnailSpacing) {
            dx = 0.0;
            dy += kThumbnailSize + kThumbnailSpacing;
        }
    }

    // set the content size of the thumb scroller
    [_thumbsView setContentSize:CGSizeMake(_thumbsView.frame.size.width - (kThumbnailSpacing * 2), dy + kThumbnailSize + kThumbnailSpacing)];
}


- (void)toggleThumbnailViewWithAnimation:(BOOL)animation {
    if (_isThumbViewShowing) {
        [self hideThumbnailViewWithAnimation:animation];
    }
    else {
        [self showThumbnailViewWithAnimation:animation];
    }
}


- (void)showThumbnailViewWithAnimation:(BOOL)animation {
    _isThumbViewShowing = YES;

    [self arrangeThumbs];
    [self.navigationItem.rightBarButtonItem setTitle:NSLocalizedString(@"大图", nil)];

    if (animation) {
        // do curl animation
        [UIView beginAnimations:@"uncurl" context:nil];
        [UIView setAnimationDuration:.666];
        [UIView setAnimationTransition:UIViewAnimationTransitionCurlDown forView:_thumbsView cache:YES];
        [_thumbsView setHidden:NO];
        [UIView commitAnimations];
    }
    else {
        [_thumbsView setHidden:NO];
    }
}


- (void)hideThumbnailViewWithAnimation:(BOOL)animation {
    _isThumbViewShowing = NO;
    [self.navigationItem.rightBarButtonItem setTitle:NSLocalizedString(@"缩略图", nil)];

    if (animation) {
        // do curl animation
        [UIView beginAnimations:@"curl" context:nil];
        [UIView setAnimationDuration:.666];
        [UIView setAnimationTransition:UIViewAnimationTransitionCurlUp forView:_thumbsView cache:YES];
        [_thumbsView setHidden:YES];
        [UIView commitAnimations];
    }
    else {
        [_thumbsView setHidden:NO];
    }
}

- (void)showThumbImageList {
    // show thumb view
    [self toggleThumbnailViewWithAnimation:YES];

    // tell thumbs that havent loaded to load
    [self loadAllThumbViewPhotos];

//    [DejalBezelActivityView removeViewAnimated:YES];
}



#pragma mark -
#pragma mark NSURLConnection Delegate Methods

- (void)connection:(NSURLConnection *)conn didReceiveResponse:(NSURLResponse *)response {
    
    if( conn == _fileDownloadConn ){
        
        _responseCode =  [(NSHTTPURLResponse *)response statusCode];
        if (_responseCode == 200) {
            [_fileDownloadData setLength:0];
            
        }else{
            
            [OBJCMethodBridge makeToast: [OBJCMethodBridge getLocalString:@"Get File info error" comment:@""] view:self.view];
            [self.alertViewWithProgressbar hide];
            self.alertViewWithProgressbar = nil;
            
        }
        
    }
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
}



- (void)connection:(NSURLConnection *)conn didReceiveData:(NSData *)data {
    if( conn == _fileDownloadConn ){
        if (_responseCode == 200) {
            
            [_fileDownloadData appendData:data];
            
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
            
            
            [self setProgress:(float)_fileDownloadData.length/(float)_totalSize];
        }else{
            NSDictionary * errorDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            NSLog(@"%@",errorDic);
            
        }
        
    }
    
}



- (void)connectionDidFinishLoading:(NSURLConnection *)conn {
    
    if( conn == _fileDownloadConn ){

        
        if (_responseCode == 200) {
            
            ImageData *photoItem = _photoArray[_currentIndex];
            
            NSString *imgLocalPath= photoItem.localPath;


            BOOL writeResult = [_fileDownloadData writeToFile:imgLocalPath atomically: NO];
            if (writeResult) {
                if ([ObjcUtils getFileSizeWithPath:imgLocalPath] > 1024) {
                    
                    if (_needAction) {
                        NSString *newLocalPath = [ObjcUtils replaceStrBySearchStr:imgLocalPath search:[imgLocalPath lastPathComponent] replace:[photoItem.fullPath lastPathComponent]];
                        if ([[NSFileManager defaultManager] fileExistsAtPath:newLocalPath]) {
                            _docController = [UIDocumentInteractionController
                                              interactionControllerWithURL:[NSURL fileURLWithPath:newLocalPath]];
                            _isCopyFile = YES;
                        } else {
                            if ([[NSFileManager defaultManager] copyItemAtPath:imgLocalPath toPath:newLocalPath error:nil]) {
                                _docController = [UIDocumentInteractionController
                                                  interactionControllerWithURL:[NSURL fileURLWithPath:newLocalPath]];
                                _isCopyFile = YES;
                            } else {
                                _docController = [UIDocumentInteractionController
                                                  interactionControllerWithURL:[NSURL fileURLWithPath:imgLocalPath]];
                                _isCopyFile = NO;
                            }
                        }
                        _docController.delegate = self;
                        _docController.UTI = [ObjcUtils getDocumentUTIType:[[photoItem.fileName pathExtension] lowercaseString]];
                        [_docController presentOpenInMenuFromRect:CGRectZero inView:self.view animated:YES];
                    } else {
                        UIImage *imageToSave = [[UIImage alloc] initWithContentsOfFile:imgLocalPath];
                        UIImageWriteToSavedPhotosAlbum(imageToSave, nil, nil, nil);
                        [OBJCMethodBridge makeToast:@"Have saved to photos" view:self.view];
                    }
                    
                } else {
                    [[NSFileManager defaultManager] removeItemAtPath:imgLocalPath error:nil];
                    //                [[TKAlertCenter defaultCenter] postAlertWithMessage:NSLocalizedString(@"打开失败，请关闭后重试", nil)];
                    
                }
            }
            
        }
        
    }
    

    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

- (void)handleSeeAllTouch:(id)sender {
    
    if(_currentIndex<0 || _currentIndex>=_photoArray.count)
        return;
    ImageData *fileItemData=_photoArray[_currentIndex];
    _totalSize = fileItemData.fileSize;
    if (!fileItemData) {
        return;
    }

    NSString *imgLocalPath = fileItemData.localPath;

    
    if ([[NSFileManager defaultManager] fileExistsAtPath:imgLocalPath]) {
        if (_needAction) {
            NSString *newLocalPath = [ObjcUtils replaceStrBySearchStr:imgLocalPath search:[imgLocalPath lastPathComponent] replace:[fileItemData.fullPath lastPathComponent]];
            if ([[NSFileManager defaultManager] fileExistsAtPath:newLocalPath]) {
                _docController = [UIDocumentInteractionController
                                  interactionControllerWithURL:[NSURL fileURLWithPath:newLocalPath]];
                _isCopyFile = YES;
            } else {
                if ([[NSFileManager defaultManager] copyItemAtPath:imgLocalPath toPath:newLocalPath error:nil]) {
                    _docController = [UIDocumentInteractionController
                                      interactionControllerWithURL:[NSURL fileURLWithPath:newLocalPath]];
                    _isCopyFile = YES;
                } else {
                    _docController = [UIDocumentInteractionController
                                      interactionControllerWithURL:[NSURL fileURLWithPath:imgLocalPath]];
                    _isCopyFile = NO;
                }
            }
            _docController.delegate = self;
            _docController.UTI = [ObjcUtils getDocumentUTIType:[[fileItemData.fileName pathExtension] lowercaseString]];
            [_docController presentOpenInMenuFromRect:CGRectZero inView:self.view animated:YES];
        } else {
            UIImage *imageToSave = [[UIImage alloc] initWithContentsOfFile:imgLocalPath];
            UIImageWriteToSavedPhotosAlbum(imageToSave, nil, nil, nil);
            [OBJCMethodBridge makeToast:@"Have saved to photos" view:self.view];
        }
    
        return;
    }

    [OBJCMethodBridge showProgress:self];

    [fileItemData getFileUri:^(BOOL success, NSString *fullsizeUrl){
        [OBJCMethodBridge hideProgress:self];
        
        if ( success && fullsizeUrl != nil) {
            NSURL *url = [NSURL URLWithString:fullsizeUrl];
            NSURLRequest *request = [NSURLRequest requestWithURL:url];
            _fileDownloadConn = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
            [_fileDownloadConn start];
            _fileDownloadData = [[NSMutableData alloc]init];
            
            self.alertViewWithProgressbar = [[AGAlertViewWithProgressbar alloc]initWithTitle:nil message:[OBJCMethodBridge getLocalString:@"Loading" comment:@""] delegate:self cancelButtonTitle:[OBJCMethodBridge getLocalString:@"Cancel" comment:@""] otherButtonTitles:nil];
            [self.alertViewWithProgressbar show];
            
            _isLoading=YES;
        } else {
            [OBJCMethodBridge makeToast:[OBJCMethodBridge getLocalString:@"Can not get image url for downloading" comment:@""] view:self.view];
        }

    }];
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self.alertViewWithProgressbar hide];
    self.alertViewWithProgressbar=nil;

    if (_fileDownloadConn) {
        [_fileDownloadConn cancel];
    }
    
    _downloadFileHttpUrl=nil;
    _isLoading=NO;
}

#pragma mark -
#pragma mark ASIProgressDelegate

- (void)setProgress:(float)newProgress {
    self.alertViewWithProgressbar.progress = newProgress * 100;
    if (newProgress == 1.000000) {
        [self.alertViewWithProgressbar hide];
    }
}


- (void)handleThumbClick:(id)sender {
    FGalleryPhotoView *photoView = (FGalleryPhotoView *) [(UIButton *) sender superview];
    [self hideThumbnailViewWithAnimation:YES];
    [self gotoImageByIndex:photoView.tag animated:NO];
}



- (void)loadFullsizeImageWithIndex:(NSUInteger)index {
    FGalleryPhoto *photo = _photoLoaders[[NSString stringWithFormat:@"%lu", (unsigned long)index]];

    if (photo == nil)
        photo = [self createGalleryPhotoForIndex:index];
    
    if (photo.isFullsizeLoading) {
        return;
    }
    
    if (photo.hasFullsizeLoaded) {
        return;
    }

    [photo loadFullsize];
}


- (void)unloadFullsizeImageWithIndex:(NSUInteger)index {
    if (index < [_photoViews count]) {
        FGalleryPhoto *loader = _photoLoaders[[NSString stringWithFormat:@"%lu", (unsigned long)index]];
        [loader unloadFullsize];

        FGalleryPhotoView *photoView = _photoViews[index];
        //photoView.imageView.image = loader.thumbnail;
        if (self.interfaceOrientation == UIInterfaceOrientationPortrait || self.interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown) {
            photoView.imageView.image = [UIImage imageNamed:@"Default_Port.png"];
        } else {
            photoView.imageView.image = [UIImage imageNamed:@"Default_Land.png"];
        }
        [photoView.activity startAnimating];

        [photoView.progressLabel setHidden:YES];
    }
}


- (FGalleryPhoto *)createGalleryPhotoForIndex:(NSUInteger)index {
    
    ImageData *fileitemData = _photoArray[index];
    FGalleryPhoto *photo = [[FGalleryPhoto alloc]initWithImageData:fileitemData delegate:self index:index];
    // assign the photo index
    _photoLoaders[[NSString stringWithFormat:@"%lu", (unsigned long)index]] = photo;
    return photo;
}


- (void)scrollingHasEnded {

    _isScrolling = NO;

    NSUInteger newIndex = floor(_scroller.contentOffset.x / _scroller.frame.size.width);
    if (newIndex == _currentIndex) {
        return;
    }

    // clear previous
    //[self unloadFullsizeImageWithIndex:_currentIndex];
    
    [self gotoImageByIndex:newIndex animated:NO];
}


#pragma mark - FGalleryPhoto Delegate Methods

- (void)galleryPhoto:(FGalleryPhoto *)photo setFullsizeDownloadProgress:(float)progress {
    FGalleryPhotoView *photoView = [_photoViews objectAtIndex:photo.tag];
    if ((int)progress == 1) {
        photoView.progressLabel.text = @"100%";
    } else {
        NSString *currentProgress = [NSString stringWithFormat:@"%2.1f%%", progress*100];
        if ([photoView.progressLabel.text isEqualToString:@"100%"]) {
            photoView.progressLabel.text = @"";
        } else {
            if (photoView.progressLabel.text != nil && [photoView.progressLabel.text floatValue] < [currentProgress floatValue]) {
                photoView.progressLabel.text = currentProgress;
            }
        }
    }
}

- (void)galleryPhoto:(FGalleryPhoto *)photo didLoadFullsize:(UIImage *)image {
    FGalleryPhotoView *photoView = _photoViews[photo.tag];
    photoView.imageView.image = photo.fullsize;
    [photoView.activity stopAnimating];
    photoView.progressLabel.text = @"0.0%";
    [photoView.progressLabel setHidden:YES];
}

-(void)galleryPhoto:(FGalleryPhoto *)photo didWithError:(NSString *)message{
    [OBJCMethodBridge makeToast:message view:self.view];
}


#pragma mark - UIScrollView Methods


- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    _isScrolling = YES;
}


- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (!decelerate) {
        [self scrollingHasEnded];
    }
}


- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self scrollingHasEnded];
}


#pragma mark - Memory Management Methods

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];

    // Release any cached data, images, etc that aren't in use.

    NSLog(@"[FGalleryViewController] didReceiveMemoryWarning! clearing out cached images...");
    // unload fullsize and thumbnail images for all our images except at the current index.
    NSArray *keys = [_photoLoaders allKeys];
    NSUInteger i, count = [keys count];
    for (i = 0; i < count; i++) {
        if (i != _currentIndex) {
            FGalleryPhoto *photo = _photoLoaders[keys[i]];
            [photo unloadFullsize];

            // unload main image thumb
            FGalleryPhotoView *photoView = _photoViews[i];
            photoView.imageView.image = nil;

            // unload thumb tile
            photoView = _photoThumbnailViews[i];
            photoView.imageView.image = nil;
        }
    }
}


- (void)dealloc {

    // remove KVO listener
    [_container removeObserver:self forKeyPath:@"frame"];

    // Cancel all photo loaders in progress
    NSArray *keys = [_photoLoaders allKeys];
    NSUInteger i, count = [keys count];
    for (i = 0; i < count; i++) {
        FGalleryPhoto *photo = _photoLoaders[keys[i]];
        photo.delegate = nil;
        [photo unloadFullsize];
    }

    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];


    _photoSource = nil;

    _caption = nil;

    _captionContainer = nil;

    _container = nil;

    _innerContainer = nil;


    _scroller = nil;

    [_photoLoaders removeAllObjects];
    _photoLoaders = nil;

    [_barItems removeAllObjects];
    _barItems = nil;

    [_photoThumbnailViews removeAllObjects];
    _photoThumbnailViews = nil;

    [_photoViews removeAllObjects];
    _photoViews = nil;

    [_photoArray removeAllObjects];

    _nextButton = nil;

    _prevButton = nil;

    _favorButton = nil;

    _shareButton = nil;

    _remindButton = nil;

    _actionButton = nil;
}

@end

@implementation UINavigationController (FGallery)

- (BOOL)shouldAutorotate {
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    if (interfaceOrientation == UIInterfaceOrientationPortrait
            || interfaceOrientation == UIInterfaceOrientationLandscapeLeft
            || interfaceOrientation == UIInterfaceOrientationLandscapeRight) {
//        if ([FolderOperationManager getInstance].srcRefresh != YES) {
//            // see if the current controller in the stack is a gallery
//            if ([self.visibleViewController isKindOfClass:[FGalleryViewController class]]) {
//                return YES;
//            }
//        }
    }

    // we need to support at least one type of auto-rotation we'll get warnings.
    // so, we'll just support the basic portrait.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    // see if the current controller in the stack is a gallery
    if ([self.visibleViewController isKindOfClass:[FGalleryViewController class]]) {
        FGalleryViewController *galleryController = (FGalleryViewController *) self.visibleViewController;
        [galleryController resetImageViewZoomLevels];
    }
}

@end


