/* LogWindowController */

#import <Cocoa/Cocoa.h>
#import "LogWindow.h"

@interface LogWindowController : NSWindowController
{
    IBOutlet id text;
    IBOutlet id scrollView;
    //bool rc = NO;
}
- (void)setFont:(NSFont*)font;
- (void)setShadowText:(bool)shadow;
- (void)setTextBackgroundColor:(NSColor*)color;
- (void)setTextColor:(NSColor*)color;
- (void)setTextAlignment:(int)alignment;
- (void)setFrame:(NSRect)logWindowRect display:(bool)flag;
- (void)setHasShadow:(bool)flag;
- (void)setOpaque:(bool)flag;
- (void)setAutodisplay:(BOOL)value;
- (void)setLevel: (int)level;
- (void)makeKeyAndOrderFront: (id)sender;
- (void)display;
- (void)windowWillClose:(NSNotification *)aNotification;
- (void)addText:(NSString*)newText clear:(BOOL)clear;
- (void)scrollEnd;
- (void)setHilighted:(BOOL)flag;
- (void)setReady:(bool)myReady;
- (BOOL)ready;

@end
