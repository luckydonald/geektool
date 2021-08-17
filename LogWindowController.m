#import "LogWindowController.h"

@implementation LogWindowController
- (void)awakeFromNib
{
    [ scrollView setDocumentView: text ];
}
- (void)setFont:(NSFont*)font
{
    [ text setFont: font ];
}
- (void)setShadowText:(bool)shadow
{
    [ text setShadowText: shadow ];
}
- (void)setTextBackgroundColor:(NSColor*)color
{

    [ text setBackgroundColor: color ];
    [ [ self window ] setBackgroundColor: [NSColor clearColor] ];
}
- (void)setTextColor:(NSColor*)color
{
    [ text setTextColor: color ];
}
- (void)setTextAlignment:(int)alignment
{
    switch (alignment)
    {
        case 0:
            [ text setAlignment:NSLeftTextAlignment ];
            break;
        case 1:
            [ text setAlignment:NSCenterTextAlignment ];
            break;
        case 2:
            [ text setAlignment:NSRightTextAlignment ];
            break;
        case 3:
            [ text setAlignment:NSJustifiedTextAlignment ];
            break;
    }
    [ self display ];

}
- (void)setFrame:(NSRect)logWindowRect display:(bool)flag
{
    [[ self window ] setFrame: logWindowRect display: flag ];
}
- (void)setHasShadow:(bool)flag
{
    [[ self window ] setHasShadow: flag ];
}
- (void)setOpaque:(bool)flag
{
    [[ self window ] setOpaque: flag ];
}
- (void)setAutodisplay:(BOOL)value
{
    [[self window] setAutodisplay: value ];
}
- (void)setLevel: (int)level
{
    [[ self window ] setLevel: level ];
}
- (void)makeKeyAndOrderFront: (id)sender
{
    [[ self window ] makeKeyAndOrderFront: sender ];
}
- (void)display
{
    [[ self window ] display ];
    //NSLog(@"%@",self );
    //[[NSGraphicsContext currentContext] setShouldAntialias: NO];
}
- (void)windowWillClose:(NSNotification *)aNotification
{
    [ self autorelease ];
}
- (void)addText:(NSString*)newText clear:(BOOL)clear
{
   // NSRange range;
    NSMutableString *theText = [[ NSMutableString alloc ] init ];
    //if (!clear)
    //    [ theText appendString: @"\n" ];
    [ theText appendString: [ newText stringByTrimmingCharactersInSet: [ NSCharacterSet whitespaceAndNewlineCharacterSet ]]];
    if (clear)
        [ text setString: theText ];
    else
    {
        [ text insertNewline: self ];
        [ text insertText: theText ];
        
        //range = NSMakeRange([[ text string ] length ],0);
        //[ text replaceCharactersInRange: range withString: theText ];
    }
    [ theText release ];
}
- (void)scrollEnd
{
    NSRange range = NSMakeRange([[ text string ] length ]-1,1);
    [ text scrollRangeToVisible: range ];
}
- (void)setHilighted:(BOOL)flag;
{
    [(LogWindow*)[ self window ] setHilighted: flag ];
    [ self display ];
}
- (void)setReady:(bool)myReady
{
    [(LogWindow*)[ self window ] setReady : myReady];
}
- (BOOL)ready
{
    return   [(LogWindow*)[ self window ] ready ];
}

@end
