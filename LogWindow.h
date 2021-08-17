/* LogWindow */

#import <Cocoa/Cocoa.h>

@interface LogWindow : NSWindow
{
    IBOutlet id text;
    IBOutlet id logView;
    NSString *logFile;
    BOOL ready;
}
- (id)initWithContentRect:(NSRect)contentRect styleMask:(unsigned int)styleMask backing:(NSBackingStoreType)backingType defer:(BOOL)flag;
- (void)setReady:(bool)myReady;
- (BOOL)ready;
- (BOOL)canBecomeKeyWindow;
- (void)setHilighted:(BOOL)flag;
- (void)setClickThrough:(BOOL)clickThrough;
@end
