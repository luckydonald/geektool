/* GTUninstaller */

#import <Cocoa/Cocoa.h>
#import <CoreFoundation/CoreFoundation.h>

@interface GTUninstaller : NSObject
{
    IBOutlet id label;
    IBOutlet id no;
    IBOutlet id panel;
    IBOutlet id yes;
}
- (IBAction)no:(id)sender;
- (IBAction)yes:(id)sender;

- (NSString*)searchPrefsPath;

@end
