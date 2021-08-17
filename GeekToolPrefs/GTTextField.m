#import "GTTextField.h"
#import "GeekToolPrefs.h"

@implementation GTTextField
- (BOOL)acceptsFirstResponder {
    return YES;
}
- (BOOL)resignFirstResponder {
    return YES;
}
- (BOOL)becomeFirstResponder {
    [[ NSFontManager sharedFontManager ] setSelectedFont: [ self font ] isMultiple: NO];
    return YES;
}
- (void)changeFont:(id)sender
{
    NSFont *oldFont = [ self font ];
    NSFont *newFont = [ sender convertFont:oldFont ];
    [ self setStringValue: [ newFont displayName ]];
    [ self setFont: newFont ];
    // [self setSelectionFont:newFont];
    [ gtPrefs applyChanges ];
    [ gtPrefs savePrefs ];
    [ gtPrefs updateWindows ];
    return;
}
@end
