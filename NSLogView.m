#import "NSLogView.h"
#import "LogWindow.h"
#import "LogWindowController.h"

@implementation NSLogView
- (BOOL)acceptsFirstMouse:(NSEvent *)theEvent;
{
    return YES;
}
- (void)drawRect:(NSRect)rect
{
    NSAutoreleasePool *pool = [[ NSAutoreleasePool alloc ] init ];
    [ super drawRect: rect ];
    NSBezierPath *bp = [ NSBezierPath bezierPathWithRect: [ self bounds ]];
    NSColor *color;
    if (hilighted)
    {
	color = [[NSColor blackColor] colorWithAlphaComponent:0.1];
	[ color set ];
	[ bp fill ];
        [ corner setImage: [ NSImage imageNamed: @"coin" ]];
    }
    else
    {
	color = [ NSColor clearColor ];
	[ color set ];
	[ bp fill ];
        [ corner setImage: nil ];
    }
    [ pool release ];
}

- (void)mouseDragged:(NSEvent *)theEvent;
{
    if (! hilighted)
	return;

    int newX, newY,newW,newH;

    NSPoint currentMouseLoc = [ NSEvent mouseLocation ];

    if (dragType == 1)
    {
        newW = windowFrame.size.width + ( currentMouseLoc.x - mouseLoc.x );
        newH = windowFrame.size.height + ( mouseLoc.y - currentMouseLoc.y );
        newX = windowFrame.origin.x;
        newY = windowFrame.origin.y + ( currentMouseLoc.y - mouseLoc.y );
        if (newW < 20)
            newW = 20;
        if (newH < 20)
        {
            newY = newY - (20-newH);
            newH = 20;
        }
    }
    else
    {
        newW = windowFrame.size.width;
        newH = windowFrame.size.height;
        newX = windowFrame.origin.x + ( currentMouseLoc.x - mouseLoc.x );
        newY = windowFrame.origin.y - ( mouseLoc.y - currentMouseLoc.y );
    }

    [[ self window ] setFrame: NSMakeRect(newX,newY,newW,newH) display: YES];
}

- (void)mouseDown:(NSEvent *)theEvent;
{
    NSAutoreleasePool *pool = [[ NSAutoreleasePool alloc ] init ];
    if (! hilighted)
	return;
    
    windowFrame = [[ self window ] frame ];
    if (NSMouseInRect([ NSEvent mouseLocation ],NSMakeRect(NSMaxX(windowFrame) - 10,NSMaxY(windowFrame) - NSHeight(windowFrame),10,10),NO))
	dragType=1;
    else
	dragType=2;
    mouseLoc = [ NSEvent mouseLocation ];

    timer = [[ NSTimer scheduledTimerWithTimeInterval: 0.5
                                               target: self
                                             selector: @selector(timerSendPosition:)
                                             userInfo: nil
                                              repeats: YES ] retain ];
    [ self display ];
    [ pool release ];
}
- (void)mouseUp:(NSEvent *)theEvent;
{
    //[ logWindowController scrollEnd ];
    [ timer invalidate ];
    [ timer release ];
    timer = nil;
    [ self sendPosition ];
    [[ NSDistributedNotificationCenter defaultCenter ] postNotificationName: @"GTApply"
                                                                     object: @"GeekTool"
                                                                   userInfo: nil
                                                         deliverImmediately: YES ];
    [ self display ];
}
- (void)setHilighted:(BOOL)flag;
{
    hilighted = flag;
    [ self display ];
// [ corner setVisible: flag ];
}
- (void)setCrop: (BOOL)aBool;
{
    crop = aBool;
}
- (void)timerSendPosition:(NSTimer*)aTimer
{
    [ self sendPosition ];
}
- (void)sendPosition
{
    NSRect screenSize = [[ NSScreen mainScreen ] frame ];
    LogWindow *logWindow = (LogWindow*)[ self window ];
    NSRect currentFrame = [ logWindow frame ];
    [[ NSDistributedNotificationCenter defaultCenter ] postNotificationName: @"GTWindowChanged"
                                                                     object: @"GeekTool"
                                                                   userInfo: [ NSDictionary dictionaryWithObjectsAndKeys:
                                                                       [ NSNumber numberWithInt: currentFrame.origin.x ], @"x",
                                                                       [ NSNumber numberWithInt: screenSize.size.height - currentFrame.origin.y - currentFrame.size.height ], @"y",
                                                                       [ NSNumber numberWithInt: currentFrame.size.width ], @"w",
                                                                       [ NSNumber numberWithInt: currentFrame.size.height ], @"h",
                                                                       nil ]
                                                         deliverImmediately: YES
        ];
}
@end