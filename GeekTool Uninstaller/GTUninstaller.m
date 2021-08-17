#import "GTUninstaller.h"

@implementation GTUninstaller

- (void)awakeFromNib
{
    [ panel center ];
    [ panel makeKeyAndOrderFront: self ];
}
- (IBAction)no:(id)sender
{
    [ NSApp terminate: self ];
}

- (IBAction)yes:(id)sender
{
    [ yes setEnabled: NO ];
    [ no setEnabled: NO ];
    typedef struct OpaqueMenuExtraRef *MenuExtraRef;
    unsigned int outExtra;

    NSString *identifier;
    MenuExtraRef *menuExtra;

    identifier=@"org.tynsoe.geektool";
    menuExtra = nil;
    CoreMenuExtraGetMenuExtra((CFStringRef)identifier, &menuExtra);
    if (menuExtra != nil)
        CoreMenuExtraRemoveMenuExtra( menuExtra, &outExtra );

    identifier=@"net.sourceforge.menucracker";
    menuExtra = nil;
    CoreMenuExtraGetMenuExtra((CFStringRef)identifier, &menuExtra);
    if (menuExtra != nil)
        CoreMenuExtraRemoveMenuExtra( menuExtra, &outExtra );

    [[ NSDistributedNotificationCenter defaultCenter ] postNotificationName: @"GTQuit"
                                                                     object: @"GeekToolPrefs"
                                                                   userInfo: nil
                                                         deliverImmediately: YES
        ];
    NSString *ppPath;
    while(ppPath = [ self searchPrefsPath ])
        [[ NSFileManager defaultManager ] removeFileAtPath: ppPath handler:nil ];
    
    [ label setStringValue: NSLocalizedString(@"safe",@"") ];
}
- (NSString*)searchPrefsPath
{
    NSString *home = [[ NSString stringWithString: @"~/Library/PreferencePanes/" ] stringByExpandingTildeInPath ];

    NSArray *testArray = [ NSArray arrayWithObjects:
        [ home stringByAppendingPathComponent: @"GeekTool.prefPane/" ],
        @"/Library/PreferencePanes/GeekTool.prefPane/",
        @"/System/Library/PreferencePanes/GeekTool.prefPane/",
        nil ];
    NSEnumerator *e = [ testArray objectEnumerator ];
    NSString *path;
    BOOL isDir;
    while (path = [ e nextObject ])
        if ([[ NSFileManager defaultManager ] fileExistsAtPath: path isDirectory: &isDir ])
            if (isDir)
                return path;
    return nil;
}
@end
