#import "QLPreviewControllerCustom.h"

@implementation QLPreviewControllerCustom

- (void)viewDidLoad {
    [super viewDidLoad];
    self.orientations = [[UIApplication sharedApplication] statusBarOrientation];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction
                                                                                           target:self
                                                                                           action:@selector(shareAction)];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    UINavigationBar *navigationBar = [self getNavigationBarFromView:self.view];
    [navigationBar setHidden:YES];
    [self removeDefaultShareButton:navigationBar];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(orientationChanged:) name:UIDeviceOrientationDidChangeNotification object:nil];
    UINavigationBar *navigationBar = [self getNavigationBarFromView:self.view];
    [navigationBar setHidden:NO];
    [self removeDefaultShareButton:navigationBar];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    UINavigationBar *navigationBar = [self getNavigationBarFromView:self.view];
    [self removeDefaultShareButton:navigationBar];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    UINavigationBar *navigationBar = [self getNavigationBarFromView:self.view];
    [self removeDefaultShareButton:navigationBar];
}

- (void)orientationChanged:(NSNotification*)notification {
    [self adjustNavigationBarForOrientation:(UIInterfaceOrientation)[[UIApplication sharedApplication] statusBarOrientation]];
}

- (void)adjustNavigationBarForOrientation:(UIInterfaceOrientation) orientation {
    UINavigationBar *navigationBar = [self getNavigationBarFromView:self.view];
    if (orientation == UIInterfaceOrientationPortrait || orientation == UIInterfaceOrientationPortraitUpsideDown) {
        if (orientation != self.orientations) {
            [navigationBar setHidden:YES];
            self.orientations = orientation;
        }
    } else if (orientation == UIInterfaceOrientationLandscapeLeft || orientation == UIInterfaceOrientationLandscapeRight) {
        if (orientation != self.orientations) {
            [navigationBar setHidden:YES];
            self.orientations = orientation;
        }
    } else if (orientation == self.orientations) {
        [navigationBar setHidden:NO];
    }
}

- (void)removeDefaultShareButton:(UINavigationBar*)nvBar {
    if (nvBar) {
        UINavigationItem *item = nvBar.items.firstObject;
        if (item.rightBarButtonItems.count > 1) {
            UIBarButtonItem* button = item.rightBarButtonItems[1];
            NSArray * buttons = @[button];
            [item setRightBarButtonItems:buttons];
        }
    }
}

- (UINavigationBar*)getNavigationBarFromView:(UIView *)view {
    for (UIView *v in view.subviews) {
        if ([v isKindOfClass:[UINavigationBar class]]) {
            return (UINavigationBar *)v;
        } else {
            UINavigationBar *navigationBar = [self getNavigationBarFromView:v];
            if (navigationBar) {
                return navigationBar;
            }
        }
    }
    return nil;
}

- (NSURL*) createTmpFile
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSString *path = [NSTemporaryDirectory() stringByAppendingPathComponent: self.fileName];
    NSError *error = nil;
    
    // Delete the file if it already exists.
    if ([fileManager fileExistsAtPath: path])
        if (![fileManager removeItemAtPath: path error: &error])
            return nil;

    NSURL* tmpFileUrl = [[NSURL alloc] initFileURLWithPath:path];
    [fileManager copyItemAtURL:self.fileUrl toURL:tmpFileUrl error: &error];
    if (error) {
        RCTLogError(@"RNDOCVIEWER-ERROR:%@", error.localizedDescription);
        return nil;
    }
    return tmpFileUrl;
}


- (void)shareAction {
    NSURL *tmpFileUrl = [self createTmpFile];
    if (!tmpFileUrl) {
        return;
    }
    NSArray* dataToShare = @[tmpFileUrl];
    
    UIActivityViewController* activityViewController =
    [[UIActivityViewController alloc] initWithActivityItems:dataToShare
                                      applicationActivities:nil];
    
    //for iPhone
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {

        [self presentViewController:activityViewController animated:YES completion:^{}];

    }
    //for iPad
    else {
        // Change Rect to position Popover
        UIPopoverController *popup = [[UIPopoverController alloc] initWithContentViewController:activityViewController];
        [popup presentPopoverFromBarButtonItem:self.navigationItem.rightBarButtonItem permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];

    }
}

- (BOOL)canShowToolbar {
    return NO;
}

@end
