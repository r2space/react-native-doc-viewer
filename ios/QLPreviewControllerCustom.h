#import <QuickLook/QuickLook.h>
#import <React/RCTLog.h>

@interface QLPreviewControllerCustom : QLPreviewController
@property (assign,nonatomic) NSURL *fileUrl;
@property (assign,nonatomic) NSString *fileName;
@end
