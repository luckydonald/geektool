//
//  GeekToolPrefPref.h
//  GeekToolPref
//
//  Created by Yann Bizeul on Thu Nov 21 2002.
//  Copyright (c) 2002 __MyCompanyName__. All rights reserved.
//

#import <PreferencePanes/PreferencePanes.h>
#import <CoreFoundation/CoreFoundation.h>

#import "GTLog.h"
#define g_logs comTynsoeGeekToolLogs

#define LOGSETN [[self bundle] localizedStringForKey:@"Log Set %i" value:nil table:nil]
#define NLOGSET [[self bundle] localizedStringForKey:@"New Log Set" value:nil table:nil]
#define DGROUP [[self bundle] localizedStringForKey:@"Default Group" value:nil table:nil]
#define COPY [[self bundle] localizedStringForKey:@"copy" value:nil table:nil]


@interface GeekToolPrefs : NSPreferencePane 
{
    CFStringRef appID;

    IBOutlet id gApply;
    IBOutlet id gDelete;
    IBOutlet id gEnable;
    IBOutlet id gEnableMenu;
    IBOutlet id gNew;
    IBOutlet id gLogsList;
    IBOutlet id gPoolsMenu;
    IBOutlet id gActivePool;
    IBOutlet id gVersion;
    IBOutlet id sH;
    IBOutlet id sW;
    IBOutlet id sX;
    IBOutlet id sY;
    IBOutlet id kot;
    IBOutlet id tTab;
    IBOutlet id tMenu;

    IBOutlet id cf1AlignCenter;
    IBOutlet id cf1AlignJustify;
    IBOutlet id cf1AlignLeft;
    IBOutlet id cf1AlignRight;
    IBOutlet id cf1BackgroundColor;
    IBOutlet id cf1ChooseFont;
    IBOutlet id cf1FontTextField;
    IBOutlet id cf1TextColor;
    IBOutlet id cf1ShadowText;
    IBOutlet id cf1ShadowWindow;
    IBOutlet id t1Choose;
    IBOutlet id t1FilePath;

    IBOutlet id cf2AlignCenter;
    IBOutlet id cf2AlignJustify;
    IBOutlet id cf2AlignLeft;
    IBOutlet id cf2AlignRight;
    IBOutlet id cf2BackgroundColor;
    IBOutlet id cf2ChooseFont;
    IBOutlet id cf2FontTextField;
    IBOutlet id cf2TextColor;
    IBOutlet id cf2ShadowText;
    IBOutlet id cf2ShadowWindow;
    IBOutlet id t2Command;
    IBOutlet id t2Refresh;
    IBOutlet id t2align1;
    IBOutlet id t2align2;
    IBOutlet id t2align3;
    IBOutlet id t2align4;
    IBOutlet id t2align5;
    IBOutlet id t2align6;
    IBOutlet id t2align7;
    IBOutlet id t2align8;
    IBOutlet id t2align9;

    
    IBOutlet id t3URL;
    IBOutlet id t3Refresh;
    IBOutlet id cf3transparency;
    IBOutlet id cf3transparencyValue;
    IBOutlet id cf3Fit;
    IBOutlet id cf3FrameType;
    //IBOutlet id cf3Crop;
    
    IBOutlet id pAdd;
    IBOutlet id pDuplicate;
    IBOutlet id pDelete;
    IBOutlet id pClose;
    IBOutlet id pList;
    IBOutlet id pSheet;
    
    NSMutableArray *g_logs;
    NSArray *controlsList;
    BOOL isAddingLog;
    NSString *guiPool;

    int numberOfItemsInPoolMenu;
    int lastSelected;
    
    NSMutableDictionary *pools;
    //NSConnection *theConnection;
    //id RemoteGeekTool;
}

- (id)initWithBundle:(NSBundle *)bundle;
- (void) mainViewDidLoad;

#pragma mark -
#pragma mark UI management
- (void)initPoolsMenu;
- (void)initCurrentPoolMenu;
- (void)updatePanel;
- (int)alignment;
- (void)setAlignment:(int)alignment;
- (int)pictureAlignment;
- (void)setPictureAlignment:(int)alignment;
- (IBAction)gChoose:(id)sender;
- (IBAction)changeAlignment:(id)sender;
- (void)setControlsState:(bool)state;
- (int)logType;
- (void)setLogType:(int)logType;
- (IBAction)pDelete:(id)sender;
- (IBAction)pAdd:(id)sender;
- (IBAction)pDuplicate:(id)sender;
- (IBAction)pClose:(id)sender;
- (IBAction)gChooseFont:(id)sender;
- (IBAction)poolsMenuChanged:(id)sender;
- (IBAction)activePoolChanged:(id)sender;
- (IBAction)typeChanged:(id)sender;
- (IBAction)changeImageAlignment:(id)sender;
- (IBAction)adjustTransparency:(id)sender;

#pragma mark -
#pragma mark Pool Management
- (void) showPoolsCustomization;
- (BOOL) poolExists:(NSString*)myPoolName;
- (void) addLog:(GTLog*)myLog toPool:(NSString*)myPoolName;
- (NSString*) addPool:(NSString*)myPoolName;
- (NSEnumerator*)enumeratorForPool:(NSString*)myPoolName;
- (void)setSelectedPool:(NSString*)myPoolName;
- (NSArray*)currentPool;
- (NSArray*)currentPoolMenu;
- (int)numberOfPools;
- (void)renamePool:(int)index to:(NSString*)newName;
- (NSArray*)orderedPoolNames;
- (void)poolDelete:(int)line;

#pragma mark -
#pragma mark Log management


- (void)addLogWithDictionary:(NSDictionary*)log;
- (GTLog*)currentLog;
- (IBAction)newLog:(id)sender;
- (IBAction) deleteLog:(id)sender;
- (IBAction) duplicateLog:(id)sender;

#pragma mark -
#pragma mark Daemon interaction
- (void)didSelect;
- (void)geekToolWindowChanged:(NSNotification*)aNotification;
- (void)geekToolLaunched:(NSNotification*)aNotification;
- (IBAction)toggleEnable:(id)sender;
- (void)updateWindows;
- (void)notifHilight;
- (void)reorder:(int)from to:(int)to;

#pragma mark -
#pragma mark Preferences handling
- (IBAction)gApply:(id)sender;
- (void)updatePrefs;
- (void)savePrefs;
- (void)applyChanges;
- (IBAction)menuCheckBoxChanged:(id)sender;
- (void)loadMenu;
- (void)unloadMenu;

#pragma mark -
#pragma mark Misc

- (NSRect)screenRect:(NSRect)oldRect;
- (void)didUnselect;
@end