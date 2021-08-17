/* GeekTool */

#import <Cocoa/Cocoa.h>
#import "GTLog.h"

@interface GeekTool : NSObject
{
    id GeekToolPrefs;
    NSUserDefaults *defaults;
    NSMutableArray *g_logs;
    NSConnection *theConnection;
    NSConnection *theConnectionPrefs;
    BOOL isAddingLog;

    int hilighted;

}
- (void)notifyLaunched;
- (void)updateWindows;
- (void)prefsNotification:(NSNotification*)aNotification;
- (void)reorder;
- (void)loadDefaults;
- (void)applicationDidChangeScreenParameters:(NSNotification *)aNotification;
@end
