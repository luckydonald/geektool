#import "ImageLogWindowController.h"

@implementation ImageLogWindowController
- (void)setImage:(NSImage*)anImage
{
    [ picture setImage: anImage ];
}
- (void)setHilighted:(BOOL)flag;
{
    [(ImageLogWindow*)[ self window ] setHilighted: flag ];
    [ self display ];
}
- (void)setStyle:(int)style
{
    [ picture setImageFrameStyle: style ];
}
-(void)setFit:(int)fit;
{
        [ picture setImageScaling: fit ];
}
-(void)setCrop:(BOOL)crop;
{
    [ logView setCrop: crop ];
}
-(void)setPictureAlignment:(int)alignment
{
    [ picture setImageAlignment: alignment ];
}
- (void)display
{
    [[ self window ] display ];
    //NSLog(@"%@",self );
    //[[NSGraphicsContext currentContext] setShouldAntialias: NO];
}

@end
