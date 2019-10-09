#import "QLPreviewControllerCustom.h"



@implementation QLPreviewControllerCustom

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction
                                                                                           target:self
                                                                                           action:@selector(shareAction)];
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
    
    [self presentViewController:activityViewController
                       animated:YES
                     completion:^{}];
    
}

- (BOOL)canShowToolbar {
    return NO;
}

@end
