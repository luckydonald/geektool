#import "LogWindow.h"
#import <Carbon/Carbon.h>

@implementation LogWindow
- (id)initWithContentRect:(NSRect)contentRect styleMask:(unsigned int)styleMask backing:(NSBackingStoreType)backingType defer:(BOOL)flag
{
    self = [ super initWithContentRect:contentRect styleMask:NSBorderlessWindowMask backing:backingType defer:NO ];
    [ self setHasShadow: NO ];
    [ self setOpaque: NO ];
    [ text setEnabled: NO ];
    [ self setReleasedWhenClosed:YES ];
    //[ self setIgnoresMouseEvents: YES ];
    //[ self setClickThrough: YES ];

    return self;
}
- (void)display
{
    [ super display ];
    ready = YES;
}
- (void)setReady:(bool)myReady
{
    ready = myReady;
}
- (BOOL)ready
{
    return ready;
}
- (BOOL)canBecomeKeyWindow
{
    return YES;
}
- (void)setHilighted:(BOOL)flag;
{
    if (flag)
        [ self setClickThrough: NO ];
    else
        [ self setClickThrough: YES ];
    
    [ logView setHilighted: flag ];
    [ text resetCursorRects ];
}
- (void)setClickThrough:(BOOL)clickThrough
{
/* carbon */
    void *ref = [self windowRef];
    if (clickThrough)
        ChangeWindowAttributes(ref, kWindowIgnoreClicksAttribute,kWindowNoAttributes);
    else
        ChangeWindowAttributes(ref, kWindowNoAttributes, kWindowIgnoreClicksAttribute);
    /* cocoa */
    [ self setIgnoresMouseEvents:clickThrough];
}
@end
