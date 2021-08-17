/* ImageLogWindowController */

#import <Cocoa/Cocoa.h>
#import "ImageLogWindow.h"

@interface ImageLogWindowController : NSWindowController
{
    IBOutlet id picture;
    IBOutlet id logView;
}
- (void)setImage:(NSImage*)anImage;
- (void)setHilighted:(BOOL)flag;
- (void)setStyle:(int)style;
- (void)display;
-(void)setFit:(int)fit;
-(void)setCrop:(BOOL)crop;
-(void)setPictureAlignment:(int)alignment;
@end
