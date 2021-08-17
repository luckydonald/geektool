/* GTTextField */

#import <Cocoa/Cocoa.h>

@interface GTTextField : NSTextField
{
    IBOutlet id gtPrefs;
}
- (BOOL)acceptsFirstResponder;
- (BOOL)resignFirstResponder;
- (BOOL)becomeFirstResponder;
- (void)changeFont:(id)sender;
@end
