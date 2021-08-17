//
//  GeekToolPrefPref.m
//  GeekToolPref
//
//  Created by Yann Bizeul on Thu Nov 21 2002.
//  Copyright (c) 2002 __MyCompanyName__. All rights reserved.
//

#define g_logs comTynsoeGeekToolLogs

#define GTTypeFile 0
#define GTTypeCommand 1

#define GTAlignLeft 0
#define GTAlignCenter 1
#define GTAlignRight 2
#define GTAlignJustify 3

#import "GeekToolPrefs.h"


@implementation GeekToolPrefs
- (id)initWithBundle:(NSBundle *)bundle
{
    if (( self = [super initWithBundle:bundle]) != nil)
        appID = CFSTR("org.tynsoe.geektool");
    
    return self;
}
- (void) mainViewDidLoad
{
    NSLog(@"test1");
    lastSelected = -1;
    [ gEnable setAllowsMixedState:YES ];

    // Remember number of items in an empty menu
    numberOfItemsInPoolMenu = [ gPoolsMenu numberOfItems ];

    // Set the first column of list as a checkbox
    NSButtonCell *theCell	= [[[ NSButtonCell alloc ] initTextCell: @""] autorelease ];
    [ theCell setButtonType: NSSwitchButton ];
    [ theCell setControlSize: NSSmallControlSize ];
    [ theCell setTarget: self ];

    [[ gLogsList tableColumnWithIdentifier: @"enabled" ] setDataCell: theCell ];

    // Register for some notifications
    [[ NSNotificationCenter defaultCenter ] addObserver: self
                                               selector: @selector(applyAndNotifyNotification:)
                                                   name: NSControlTextDidEndEditingNotification
                                                 object: nil
        ];
    
    [[ NSDistributedNotificationCenter defaultCenter ] addObserver: self
                                                          selector: @selector(geekToolLaunched:)
                                                              name: @"GTLaunched"
                                                            object: @"GeekTool"
                                                suspensionBehavior: NSNotificationSuspensionBehaviorDeliverImmediately
        ];
    [[ NSDistributedNotificationCenter defaultCenter ] addObserver: self
                                                          selector: @selector(geekToolQuit:)
                                                              name: @"GTQuitOK"
                                                            object: @"GeekTool"
                                                suspensionBehavior: NSNotificationSuspensionBehaviorDeliverImmediately
        ];
    [[ NSDistributedNotificationCenter defaultCenter ] addObserver: self
                                                          selector: @selector(geekToolWindowChanged:)
                                                              name: @"GTWindowChanged"
                                                            object: @"GeekTool"
                                                suspensionBehavior: NSNotificationSuspensionBehaviorCoalesce
        ];
    [[ NSDistributedNotificationCenter defaultCenter ] addObserver: self
                                                          selector: @selector(applyNotification:)
                                                              name: @"GTApply"
                                                            object: @"GeekTool"
                                                suspensionBehavior: NSNotificationSuspensionBehaviorDeliverImmediately
        ];    
    
    //isAddingLog = NO;

    NSDictionary *temp = (NSDictionary*)CFPreferencesCopyAppValue( CFSTR("pools"), appID );
    if (! temp || [ temp count ] == 0)
        pools = [[ NSMutableDictionary dictionaryWithObject: [ NSMutableArray array ] forKey: DGROUP ] retain ];
    else
    {
        pools = [[ NSMutableDictionary dictionary ] retain ];
        NSEnumerator *p = [ temp keyEnumerator ];
        NSString *cPoolKey;
        while (cPoolKey = [ p nextObject ])
        {
            cPoolKey = [ self addPool: cPoolKey ];
            NSEnumerator *l = [[ temp objectForKey: cPoolKey ] objectEnumerator ];
            NSDictionary *logDict;
            while (logDict = [ l nextObject ])
            {
                [ self addLog: [[ GTLog alloc ] initWithDictionary: logDict ] toPool: cPoolKey ];
            }
        }        
    }
    // Yes, we need transparency
    [[ NSColorPanel sharedColorPanel ] setShowsAlpha: YES ];
    // This array stores GUI elements that should be mass (de)activated
    controlsList = [[ NSArray arrayWithObjects:
        tMenu,
        cf1AlignCenter, cf1AlignJustify, cf1AlignLeft, cf1AlignRight, cf1BackgroundColor, cf1ChooseFont, cf1FontTextField, cf1TextColor, cf1ShadowText, cf1ShadowWindow,
        cf2AlignCenter, cf2AlignJustify, cf2AlignLeft, cf2AlignRight, cf2BackgroundColor, cf2ChooseFont, cf2FontTextField, cf2TextColor, cf2ShadowText, cf2ShadowWindow,
	sH, sW, sX, sY,
        t1FilePath, t2Command, t2Refresh, nil
	] retain ];
    [ gVersion setStringValue: [ NSString stringWithFormat: [ gVersion stringValue ],
        [[ self bundle ] objectForInfoDictionaryKey: @"CFBundleShortVersionString" ],
        [[[ self bundle ] objectForInfoDictionaryKey: @"CFBundleVersion" ] intValue ]]];
    NSNumber *en = (NSNumber*)CFPreferencesCopyAppValue( CFSTR("enableMenu"), appID );
    [ gEnableMenu setState: [ en boolValue ]];
    if ([en boolValue ])
        [ self loadMenu ];

    [ self initCurrentPoolMenu ];
    [ self initPoolsMenu ];
    guiPool = [[ gPoolsMenu titleOfSelectedItem ] retain ];
    [ self updatePanel ];
    [ gLogsList registerForDraggedTypes:[NSArray arrayWithObjects:
        @"GTLogIndex", nil]];
    //[ cf3transparency setTarget: self ];
    //[ cf3transparency setAction: @selector(adjustTransparency:) ];
    [ cf1BackgroundColor setTarget: self ];
    [ cf1BackgroundColor setAction: @selector(gApply:) ];
    [ cf1TextColor setTarget: self ];
    [ cf1TextColor setAction: @selector(gApply:) ];
    [ cf2BackgroundColor setTarget: self ];
    [ cf2BackgroundColor setAction: @selector(gApply:) ];
    [ cf2TextColor setTarget: self ];
    [ cf2TextColor setAction: @selector(gApply:) ];

    [ gLogsList reloadData ];
}

#pragma mark -
#pragma mark UI management
- (int)numberOfRowsInTableView:(NSTableView *)aTableView
{
    if (aTableView == gLogsList && [ gPoolsMenu selectedItem ] != [ gPoolsMenu lastItem ])
        return [[ self currentPoolMenu ] count ];
    else if (aTableView == pList)
        return [ self numberOfPools ];
    return 0;
}
- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(int)rowIndex
{
    if ([[ aTableColumn identifier ] isEqualTo: @"name" ])
        return [[[ self currentPoolMenu ] objectAtIndex: rowIndex ] name ];
    else if ([[ aTableColumn identifier ] isEqualTo: @"enabled" ])
        return [[[ self currentPoolMenu ] objectAtIndex: rowIndex ] enabledAsNumber ];
    else if ([[ aTableColumn identifier ] isEqualTo: @"logSets" ])
        return [[ self orderedPoolNames ] objectAtIndex: rowIndex ];
    return nil;
}
- (void)tableView:(NSTableView *)aTableView setObjectValue:(id)anObject forTableColumn:(NSTableColumn *)aTableColumn row:(int)rowIndex
{
    if ([[ aTableColumn identifier ] isEqualTo: @"name" ])
        [(GTLog*)[[ self currentPoolMenu ] objectAtIndex: rowIndex ] setName: anObject ];
    else if ([[ aTableColumn identifier ] isEqualTo: @"enabled" ])
        [(GTLog*)[[ self currentPoolMenu ] objectAtIndex: rowIndex ] setEnabled: [ anObject boolValue ] ]; 
    else if ([[ aTableColumn identifier ] isEqualTo: @"logSets" ])
        [ self renamePool: rowIndex to: anObject ];
            
    [ gLogsList reloadData ];
    [ self applyChanges ];
    [ self savePrefs ];
    [ self updateWindows ];

}
- (void)tableViewSelectionDidChange:(NSNotification *)aNotification
{
    [ cf1BackgroundColor setTarget: nil ];
    [ cf1TextColor setTarget: nil ];
    [ cf2BackgroundColor setTarget: nil ];
    [ cf2TextColor setTarget: nil ];
    /*
    [ cf1BackgroundColor deactivate ];
    [ cf1TextColor deactivate ];
    [ cf2BackgroundColor deactivate ];
    [ cf2TextColor deactivate ];
    */
    if ([ aNotification object ] == gLogsList)
    {
        if (lastSelected > -1)
        {
            [ self applyChanges ];
            [ self updatePanel ];
        }
        if ([[ aNotification object ] selectedRow ] != -1)
        {
            [ self setControlsState: YES ];
            [ self updatePanel ];
        }
        else
        {
            [ self setControlsState: NO ];
        }
        lastSelected = [[ aNotification object ] selectedRow ];
        [ self notifHilight ];        
    }
    else if ([ aNotification object ] == pList)
    {
        if ([ pList selectedRow ] == -1)
        {
            [ pDelete setEnabled: NO ];
            [ pDuplicate setEnabled: NO ];
        }
        else
        {
            [ pDelete setEnabled: YES ];
            [ pDuplicate setEnabled: YES ];
        }
    }
}
- (BOOL)tableView:(NSTableView *)tableView writeRows:(NSArray*)rows toPasteboard:(NSPasteboard*)pboard
{
    if ([ rows count ] > 1)
        return NO;
    [ self applyChanges ];
    [ pboard declareTypes: [ NSArray arrayWithObjects: @"GTLogIndex", nil ] owner: self ];
    [ pboard setString: [ NSString stringWithFormat: @"%@",[ rows objectAtIndex: 0 ]] forType: @"GTLogIndex" ];

    return YES;
}
- (NSDragOperation)tableView:(NSTableView*)tableView validateDrop:(id <NSDraggingInfo>)info proposedRow:(int)row proposedDropOperation:(NSTableViewDropOperation)operation;
{
    NSPasteboard *pb = [ NSPasteboard pasteboardWithName: NSDragPboard ];
    int draggedRow = [[ pb stringForType: @"GTLogIndex" ] intValue ];

    if (operation == NSTableViewDropOn || row == draggedRow || row == draggedRow + 1)
        return NSDragOperationNone;
    return NSDragOperationMove;
}
- (BOOL)tableView:(NSTableView*)tableView acceptDrop:(id <NSDraggingInfo>)info row:(int)row dropOperation:(NSTableViewDropOperation)operation
{
    NSPasteboard *pb = [ NSPasteboard pasteboardWithName: NSDragPboard ];
    int draggedRow = [[ pb stringForType: @"GTLogIndex" ] intValue ];

    if (lastSelected != -1)
        [ self applyChanges ];
    lastSelected = -1;
    NSMutableArray *tempPool = [[ self currentPool ] mutableCopy ];
    
    [ tempPool insertObject: [ tempPool objectAtIndex: draggedRow ] atIndex: row ];

    if (row < draggedRow )
        [ tempPool removeObjectAtIndex: draggedRow + 1 ];
    else
        [ tempPool removeObjectAtIndex: draggedRow ];
    
    [ pools setObject: tempPool forKey: [ gPoolsMenu titleOfSelectedItem ]];
    [ tempPool release ];
    [ gLogsList reloadData ];
    [ self reorder: draggedRow to: row ];
    if (row < draggedRow )
        [ gLogsList selectRow: row byExtendingSelection:NO ];
    else
        [ gLogsList selectRow: row - 1 byExtendingSelection:NO ];
    [ self updatePanel ];
    [ self savePrefs ];
    [ self notifHilight ];
    
    return YES;
}
- (void)initPoolsMenu
{
    while ([ gPoolsMenu numberOfItems ] != numberOfItemsInPoolMenu)
        [ gPoolsMenu removeItemAtIndex: 0 ];
    NSEnumerator *e = [[ pools allKeys ] objectEnumerator ];
    NSString *poolName;
    int i=0;
    while (poolName = [ e nextObject ])
        [ gPoolsMenu insertItemWithTitle: poolName atIndex: i++ ];
    [ gPoolsMenu selectItemWithTitle: [ gActivePool titleOfSelectedItem ]];
}
- (void)initCurrentPoolMenu
{
    CFPreferencesAppSynchronize( appID );
    while ([ gActivePool numberOfItems ] != 0)
        [ gActivePool removeItemAtIndex: 0 ];
    NSEnumerator *e = [[ pools allKeys ] objectEnumerator ];
    NSString *poolName;
    int i=0;
    while (poolName = [ e nextObject ])
        [ gActivePool insertItemWithTitle: poolName atIndex: i++ ];
    NSString *activePoolPrefs = (NSString*)CFPreferencesCopyAppValue( CFSTR("currentPool"), appID );
    if (activePoolPrefs)
        [ gActivePool selectItemWithTitle:  activePoolPrefs ];
    else
        [ gActivePool selectItemAtIndex:  0 ];
}
- (void)updatePanel
{
    NSString *poolMenuState = [ gPoolsMenu titleOfSelectedItem ];
    NSString *currentPoolMenuState = [ gActivePool titleOfSelectedItem ];
    [ self initPoolsMenu ];
    [ self initCurrentPoolMenu ];
    [ gPoolsMenu selectItemWithTitle: poolMenuState ];
    [ gActivePool selectItemWithTitle: currentPoolMenuState ];
    GTLog *log = [ self currentLog ];
    if (! log)
    {
        [ self setControlsState: NO ];
        return;
    }
    [ self setLogType: [ log type ]];
    NSFont *font;
    NSRect rect;

    [ t1FilePath setStringValue: [ log file ]];
    [ t2Command setStringValue: [ log command ]];

    [ cf1BackgroundColor setColor: [ log backgroundColor ] ];
    [ cf1TextColor setColor: [ log textColor ]];
    font = [ NSFont fontWithName: [ log fontName ] size: [ log fontSize ]];
    [ cf1FontTextField setFont: font ];
    [ cf1FontTextField setStringValue: [ font displayName ]];
    [ cf1ShadowText setState: [ log shadowText ]];
    [ cf1ShadowWindow setState: [ log shadowWindow ]];
    [ self setAlignment: [ log alignment ]];

    [ cf2BackgroundColor setColor: [ log backgroundColor ] ];
    [ cf2TextColor setColor: [ log textColor ]];
    font = [ NSFont fontWithName: [ log fontName ] size: [ log fontSize ]];
    [ cf2FontTextField setFont: font ];
    [ cf2FontTextField setStringValue: [ font displayName ]];
    [ cf2ShadowText setState: [ log shadowText ]];
    [ cf2ShadowWindow setState: [ log shadowWindow ]];
    [ self setAlignment: [ log alignment ]];
    [ t2Refresh setIntValue: [ log refresh ]];

    [ t3Refresh setIntValue: [ log refresh ]];
    
    [ t3URL setStringValue: [ log imageURL ]];
    [ cf3transparency setFloatValue: [ log transparency ]];
    [ cf3Fit selectItemAtIndex: [ log imageFit ]];
    [ cf3FrameType selectItemAtIndex: [ log frameType ]];
    [ self setPictureAlignment: [ log pictureAlignment ]];
    //[ cf3Crop setState: [ log crop ]];
    
    rect = [ log rect ];
    [ sX setIntValue: rect.origin.x ];
    [ sY setIntValue: rect.origin.y ];
    [ sW setIntValue: rect.size.width ];
    [ sH setIntValue: rect.size.height ];
    if ([ log windowLevel ] == NSStatusWindowLevel)
        [ kot setState: YES ];
    else
        [ kot setState: NO ];
    switch ([ self logType ])
    {
        case 0:
            [ gLogsList setNextResponder: cf1FontTextField ];
            [[ NSFontPanel sharedFontPanel ] setPanelFont: [ cf1FontTextField font ] isMultiple: NO ];
            if ([ cf2BackgroundColor isActive ])
                [ cf1BackgroundColor activate: YES ];
            if ([ cf2TextColor isActive ])
                [ cf1TextColor activate: YES ];
            
            break;
        case 1:
            if ([ cf1BackgroundColor isActive ])
                [ cf2BackgroundColor activate: YES ];
            if ([ cf1TextColor isActive ])
                [ cf2TextColor activate: YES ];
                
            [ gLogsList setNextResponder: cf2FontTextField ];
            [[ NSFontPanel sharedFontPanel ] setPanelFont: [ cf2FontTextField font ] isMultiple: NO ];

            break;
    }
    [ cf1BackgroundColor setTarget: self ];
    [ cf1BackgroundColor setAction: @selector(gApply:) ];
    [ cf1TextColor setTarget: self ];
    [ cf1TextColor setAction: @selector(gApply:) ];
    [ cf2BackgroundColor setTarget: self ];
    [ cf2BackgroundColor setAction: @selector(gApply:) ];
    [ cf2TextColor setTarget: self ];
    [ cf2TextColor setAction: @selector(gApply:) ];
}
- (int)alignment
{
    NSArray *aligns;
    switch ([ self logType ])
    {
        case 0:
            aligns = [ NSArray arrayWithObjects: cf1AlignLeft, cf1AlignCenter, cf1AlignRight, cf1AlignJustify, nil ];
            break;
        case 1:
            aligns = [ NSArray arrayWithObjects: cf2AlignLeft, cf2AlignCenter, cf2AlignRight, cf2AlignJustify, nil ];
            break;
        default:
            return 0;
    }
    NSEnumerator *e = [ aligns objectEnumerator ];
    NSButton *c;
    while (c = [ e nextObject ])
    {
        if ( [c state ])
            return [c tag];
    }
    return 0;
}

- (void)setAlignment:(int)alignment
{
    NSArray *aligns;
    switch ([ self logType ])
    {
        case 0:
            aligns = [ NSArray arrayWithObjects: cf1AlignLeft, cf1AlignCenter, cf1AlignRight, cf1AlignJustify, nil ];
            break;
        case 1:
            aligns = [ NSArray arrayWithObjects: cf2AlignLeft, cf2AlignCenter, cf2AlignRight, cf2AlignJustify, nil ];
            break;
        default:
            return;
    }
    NSEnumerator *e = [ aligns objectEnumerator ];
    NSButton *c;
    while (c = [ e nextObject ])
    {
        if ([c tag] == alignment)
            [ c setState: YES ];
        else
            [ c setState: NO ];
    }
}
- (int)pictureAlignment
{
    NSArray *aligns = [ NSArray arrayWithObjects:
        t2align1, t2align2, t2align3,
        t2align4, t2align5, t2align6,
        t2align7, t2align8, t2align9,
        nil ];
    NSEnumerator *e = [ aligns objectEnumerator ];
    NSButton *c;
    while (c = [ e nextObject ])
    {
        if ([c state])
            return [ c tag ];
    }
    return 1;
}

- (void)setPictureAlignment:(int)alignment
{
    NSArray *aligns = [ NSArray arrayWithObjects:
        t2align1, t2align2, t2align3,
        t2align4, t2align5, t2align6,
        t2align7, t2align8, t2align9,
        nil ];
    NSEnumerator *e = [ aligns objectEnumerator ];
    NSButton *c;
    while (c = [ e nextObject ])
    {
        if ([c tag] == alignment)
            [ c setState: YES ];
        else
            [ c setState: NO ];
    }
}
-(IBAction)gChoose:(id)sender
{
    NSOpenPanel *openPanel = [ NSOpenPanel openPanel ];
    [ openPanel setAllowsMultipleSelection: NO ];
    [ openPanel setCanChooseFiles: YES ];
    [ openPanel beginSheetForDirectory: @"/var/log/"
                                                              file: @"system.log"
                                                             types: nil
                                             modalForWindow: [[ self mainView ] window ]
                                              modalDelegate: self
                                             didEndSelector: @selector(openPanelDidEnd:returnCode:contextInfo:)
                                                contextInfo: nil
        ];
}

- (IBAction)changeAlignment:(id)sender
{
    [ self setAlignment: [ sender tag ]];
    [ self applyChanges ];
    [ self savePrefs ];
    [ self updateWindows ];    
}

- (void)openPanelDidEnd:(NSOpenPanel *)sheet returnCode:(int)returnCode contextInfo:(void  *)contextInfo
{
    [ NSApp endSheet: sheet ];
    if (returnCode == NSOKButton) {
        NSArray *filesToOpen = [sheet filenames];
        [ t1FilePath setStringValue: [ filesToOpen objectAtIndex: 0Ê]];
    }
}
-(void)sheetDidEnd:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo;
{
    if (returnCode == NSAlertDefaultReturn)
        [ self poolDelete: [ pList selectedRow ]];
    [ sheet close ];
    [ pList reloadData ];
}
- (void)setControlsState:(bool)state
{
    NSEnumerator *controls = [ controlsList objectEnumerator ];
    NSControl *control;
    if (! state)
    {
        [ cf1BackgroundColor setColor: [ NSColor clearColor ]];
        [ cf1TextColor setColor: [ NSColor blackColor ]];
        [ cf2BackgroundColor setColor: [ NSColor clearColor ]];
        [ cf2TextColor setColor: [ NSColor blackColor ]];
        [ t1FilePath setStringValue: @"" ];
        [ t2Command setStringValue: @"" ];
        [ t2Refresh setStringValue: @"" ];
        [ t3URL setStringValue: @"" ];
        [ sX setStringValue: @"" ];
        [ sY setStringValue: @"" ];
        [ sW setStringValue: @"" ];
        [ sH setStringValue: @"" ];
        [ self setLogType: GTTypeFile ];
        [ self setAlignment: GTAlignLeft ];
    }

    while (control = [ controls nextObject ])
        [ control setEnabled: state ];
}
- (int)logType
{
    return [ tMenu indexOfSelectedItem ];
    /*
    if ([ tTypeFile state ] == YES)
        return GTTypeFile;
    else
        return GTTypeCommand;
     */
}

- (void)setLogType:(int)logType
{
    [ tMenu selectItemAtIndex: logType ];
    [ tTab selectTabViewItemAtIndex: logType ];
 
    /*
    switch (logType)
    {
        case GTTypeFile:
            [ tTypeFile setState: YES ];
            [ tTypeCommand setState: NO ];
            break;
        case GTTypeCommand:
            [ tTypeFile setState: NO ];
            [ tTypeCommand setState: YES ];
            break;
    }
     */
}
- (IBAction)pDelete:(id)sender;
{

        [ self poolDelete: [ pList selectedRow ]];
    [ pList reloadData ];
    
}
- (IBAction)pAdd:(id)sender;
{
    NSString *nPool = [ self addPool: NLOGSET ];
    [ pList reloadData ];
    int myRow = [[ self orderedPoolNames ] indexOfObject: nPool ];  
    [ pList selectRow: myRow byExtendingSelection:NO ];
    [ pList editColumn:0
                   row: myRow
             withEvent: nil select: YES ];
}
- (IBAction)pDuplicate:(id)sender;
{
    NSString *sourcePool = [[ self orderedPoolNames ] objectAtIndex: [ pList selectedRow ]];
    NSString *dstPool = [ NSString stringWithFormat: @"%@ %@", sourcePool, COPY ];

    dstPool = [ self addPool: dstPool ];

    NSEnumerator *e = [[ pools objectForKey: sourcePool ] objectEnumerator ];
    GTLog *tempLog;
    while (tempLog = [ e nextObject ])
    {
        [ self addLog: [ tempLog copy ] toPool: dstPool ];
    }
    [ pList reloadData ];
    int myRow = [[ self orderedPoolNames ] indexOfObject: dstPool ];
    [ pList selectRow: myRow byExtendingSelection:NO ];
    [ pList editColumn:0
                   row: myRow
             withEvent: nil select: YES ];
    [ self savePrefs ];
}
- (IBAction)pClose:(id)sender
{
    [ pList deselectAll: self ];
    [ NSApp stopModal ];
    [ self initPoolsMenu ];
    [ self initCurrentPoolMenu ];
    guiPool = [[ gPoolsMenu titleOfSelectedItem ] retain ];
    [ gLogsList reloadData ];
}
-(IBAction)gChooseFont:(id)sender
{
    switch ([ self logType ])
    {
        case 0:
            [[[ self mainView ] window ] makeFirstResponder: cf1FontTextField ];
            break;
        case 1:
            [[[ self mainView ] window ] makeFirstResponder: cf2FontTextField ];
            break;
    }
    [[ NSFontManager sharedFontManager ] orderFrontFontPanel: self ];
}
- (IBAction)poolsMenuChanged:(id)sender;
{
    [ self applyChanges ];
    if ([ sender selectedItem ] == [ sender lastItem ])
        [ self showPoolsCustomization ];
    else
    {
        [ self setSelectedPool: [ sender titleOfSelectedItem ]];
    }
    [ self notifHilight ];
}
- (IBAction)activePoolChanged:(id)sender;
{
    [ self applyChanges ];
    [ self savePrefs];
    [ self updateWindows ];
    [ self notifHilight ];
}
- (IBAction)typeChanged:(id)sender;
{
    [ tTab selectTabViewItemAtIndex: [ sender indexOfSelectedItem ]];
    /*
    if (sender == tTypeFile)
    {
        [ tTypeCommand setState: NO ];
        [ tTypeFile setState: YES ];
    }
    else
    {
        [ tTypeCommand setState: YES ];
        [ tTypeFile setState: NO ];
    }
     */
    [ self applyChanges ];
    [ self savePrefs];
    [ self updateWindows ];
}
- (IBAction)changeImageAlignment:(id)sender;
{
    [ self setPictureAlignment: [ sender tag ]];
    
    [ self applyChanges ];
    [ self savePrefs ];
    [ self updateWindows ];
}
- (IBAction)adjustTransparency:(id)sender
{
    [[[ self currentPool ] objectAtIndex: lastSelected ] setTransparency: [ sender floatValue ]];
    [ cf3transparencyValue setString: [ NSString stringWithFormat: @"%i%%", [ sender intValue ]]];
    [[ NSDistributedNotificationCenter defaultCenter ] postNotificationName: @"GTTransparency"
                                                                     object: @"GeekToolPrefs"
                                                                   userInfo: [ NSDictionary dictionaryWithObjectsAndKeys:
                                                                       [ NSNumber numberWithFloat: [ sender floatValue ] / 100],@"transparency",
                                                                       nil ]
                                                         deliverImmediately: YES
        ];
    [ self applyChanges ];
    [ self savePrefs ];
    
}
#pragma mark -
#pragma mark Pool Management
- (void)showPoolsCustomization;
{
    [ pList reloadData ];
    [NSApp beginSheet: pSheet
       modalForWindow: [[ self mainView ] window ]
        modalDelegate: nil
       didEndSelector: nil
          contextInfo: nil];
    [NSApp runModalForWindow: [[ self mainView ] window ]];
    // Sheet is up here.
    [NSApp endSheet: pSheet];
    [pSheet orderOut: self];
}

- (BOOL) poolExists:(NSString*)myPoolName;
{
    return [[ pools allKeys ] containsObject: myPoolName ];
}

- (void) addLog:(GTLog*)myLog toPool:(NSString*)myPoolName;
{
    if (! [ self poolExists: myPoolName ])
        return;
    [[ pools objectForKey: myPoolName ] addObject: myLog ];
}

- (NSString*) addPool:(NSString*)myPoolName;
{
    NSString *newPoolName = [ NSString stringWithString: myPoolName ];
    if ([ self poolExists: myPoolName ])
    {
        int i = 2;
        while ([ self poolExists: [ NSString stringWithFormat: @"%@ %i", myPoolName,i]])
            i++;
        [ pools setObject: [ NSMutableArray array ] forKey: [ NSString stringWithFormat: @"%@ %i", myPoolName,i] ];
        newPoolName = [ NSString stringWithFormat: @"%@ %i", myPoolName,i];
    }
    [ pools setObject: [ NSMutableArray array ] forKey: newPoolName ];
    return newPoolName;
}

- (NSEnumerator*)enumeratorForPool:(NSString*)myPoolName;
{
    return [[ pools objectForKey: myPoolName ] objectEnumerator ];
}

- (void)setSelectedPool:(NSString*)myPoolName;
{
    [ guiPool release ];
    [ gLogsList reloadData ];
    guiPool = [[ gPoolsMenu titleOfSelectedItem ] retain ];
    [ self updatePanel ];
}
- (NSArray*)currentPool;
{
    return [ pools objectForKey: guiPool];
}
- (NSArray*)currentPoolMenu;
{
    return [ pools objectForKey: [ gPoolsMenu titleOfSelectedItem ]];
}
- (int)numberOfPools
{
    return [ pools count ];
}
- (void)renamePool:(int)index to:(NSString*)newName
{
    CFPreferencesAppSynchronize( appID );
    NSString *activePoolPrefs = (NSString*)CFPreferencesCopyAppValue( CFSTR("currentPool"), appID );
    NSString *oldName = [[ self orderedPoolNames ] objectAtIndex: index ];

    NSArray *pool = [[ pools objectForKey: oldName ] retain ];
    [ pools removeObjectForKey: oldName ];
    [ pools setObject: pool forKey: newName ];
    if ([ oldName isEqualTo: activePoolPrefs])
        CFPreferencesSetAppValue( CFSTR("currentPool"), newName, appID );

    [ pool release ];
    CFPreferencesAppSynchronize( appID );
}
-(NSArray*)orderedPoolNames
{
    return [[ pools allKeys ] sortedArrayUsingSelector: @selector(caseInsensitiveCompare:) ];
}
- (void)poolDelete:(int)line
{
    CFPreferencesAppSynchronize( appID );
    NSString *poolName = [[ self orderedPoolNames ] objectAtIndex: line ];
    NSString *activePoolPrefs = (NSString*)CFPreferencesCopyAppValue( CFSTR("currentPool"), appID );
    
    [ pools removeObjectForKey: poolName ];

    if ([ poolName isEqualTo: activePoolPrefs ])
        [ gActivePool selectItemWithTitle: [[ self orderedPoolNames ] objectAtIndex: 0 ]];
   //     CFPreferencesSetAppValue( CFSTR("currentPool"), [[ self orderedPoolNames ] objectAtIndex: 0 ], appID );
  //  CFPreferencesAppSynchronize( appID );
    [ self savePrefs ];
    [ self updateWindows ];
}
#pragma mark -
#pragma mark Log management


- (void)addLogWithDictionary:(NSDictionary*)log
{
    [ g_logs addObject: log ];
    [ gLogsList reloadData ];
}

- (GTLog*)currentLog
{
    if ([ gLogsList selectedRow ] == -1)
        return nil;
    return [[ self currentPool ] objectAtIndex: [ gLogsList selectedRow ]];
}
- (IBAction)newLog:(id)sender
{
    GTLog *log = [[ GTLog alloc ] initWithDictionary: [ NSDictionary dictionaryWithObjectsAndKeys:
        @"Console",@"name",
        @"/var/tmp/console.log", @"file",
        [ NSNumber numberWithInt: 0 ], @"kind",
        [ NSNumber numberWithInt: 0 ], @"shadow",
        [ NSNumber numberWithInt: 10 ], @"refresh",
        @"Monaco",@"fontName",
        [ NSNumber numberWithFloat: 9 ],@"fontSize",
        [ NSMutableDictionary dictionaryWithObjectsAndKeys:
            [ NSNumber numberWithInt: 0 ], @"red",
            [ NSNumber numberWithInt: 0 ], @"green",
            [ NSNumber numberWithInt: 0 ], @"blue",
            [ NSNumber numberWithInt: 0 ], @"alpha", nil ],@"backgroundColor",
        [ NSMutableDictionary dictionaryWithObjectsAndKeys:
            [ NSNumber numberWithInt: 0 ], @"red",
            [ NSNumber numberWithInt: 0 ], @"green",
            [ NSNumber numberWithInt: 0 ], @"blue",
            [ NSNumber numberWithInt: 1 ], @"alpha", nil ],@"textColor",
        [ NSMutableDictionary dictionaryWithObjectsAndKeys:
            [ NSNumber numberWithInt: 0 ], @"x",
            [ NSNumber numberWithInt: 22 ], @"y",
            [ NSNumber numberWithInt: 400 ], @"w",
            [ NSNumber numberWithInt: 200 ], @"h", nil ],@"rect",
        [ NSNumber numberWithInt: 1 ],@"enabled",
        [ NSNumber numberWithFloat: 100 ], @"transparency",
        [ NSNumber numberWithInt: 0 ], @"imageFit",
        [ NSNumber numberWithInt: 0 ], @"pictureAlignment",
        [ NSNumber numberWithInt: 0 ], @"alignment",
        nil ]];
    [ self addLog: log toPool: [ gPoolsMenu titleOfSelectedItem ]];
    [ gLogsList reloadData ];
    [ gLogsList selectRow: [[ self currentPool ] count ]-1 byExtendingSelection:NO ];
    [ self setControlsState: YES ];
    [ self updatePanel ];
    [ log release ];
    [ self applyChanges ];
    [ self savePrefs ];
    [ self updateWindows ];
    [ self notifHilight ];
}
- (IBAction) deleteLog:(id)sender
{
    NSMutableArray *tempPool = [[ self currentPool ] mutableCopy ];
    [ tempPool removeObjectAtIndex: [ gLogsList selectedRow ]];
    lastSelected = -1;
    //[ self savePrefs ];
    [ pools setObject: tempPool forKey: [ gPoolsMenu titleOfSelectedItem ]];
    [ tempPool release ];
    [ gLogsList reloadData ];
    [ self savePrefs ];
    [ self updateWindows ];
    
}
- (IBAction) duplicateLog:(id)sender
{
    NSMutableArray *tempPool = [[ self currentPool ] mutableCopy ];
    GTLog *newLog = [[ tempPool objectAtIndex: [ gLogsList selectedRow ]] copy ];
    [ newLog setName: [ NSString stringWithFormat: @"%@ copie", [ newLog name ]]];
    [ tempPool addObject: newLog ];
    [ newLog release ];
    [ pools setObject: tempPool forKey: [ gPoolsMenu titleOfSelectedItem ]];
    [ gLogsList reloadData ];
    [ self applyChanges ];
    [ self savePrefs ];
    [ self updateWindows ];
}
#pragma mark -
#pragma mark Daemon interaction
- (void)didSelect
{
    [[ NSDistributedNotificationCenter defaultCenter ] postNotificationName: @"GTPrefsLaunched"
								     object: @"GeekToolPrefs"
								   userInfo: nil
							 deliverImmediately: YES
	];
    
}
- (void)geekToolWindowChanged:(NSNotification*)aNotification
{
    [[ NSDistributedNotificationCenter defaultCenter ] setSuspended : YES ];
    NSDictionary *infos = [ aNotification userInfo ];
   // if ([[ infos objectForKey: @"logFile" ] isEqualTo: [[[ g_logs objectAtIndex: [ gLogsList selectedRow ] ] objectForKey: @"logEntry" ] objectForKey: @"file" ]])
    //{
	[ sX setIntValue: [[ infos objectForKey: @"x" ] intValue ]];
	[ sY setIntValue: [[ infos objectForKey: @"y" ] intValue ]];
	[ sW setIntValue: [[ infos objectForKey: @"w" ] intValue ]];
	[ sH setIntValue: [[ infos objectForKey: @"h" ] intValue ]];
        [[ NSDistributedNotificationCenter defaultCenter ] setSuspended : NO ];
   // }
}

- (void)geekToolLaunched:(NSNotification*)aNotification;
{
    [ gEnable setState: YES ];
    [ self notifHilight ];
}

- (void)geekToolQuit:(NSNotification*)aNotification;
{
    [ gEnable setState: NO ];
}

- (IBAction)toggleEnable:(id)sender
{
    NSMutableArray *loginItems = (NSMutableArray*) CFPreferencesCopyValue((CFStringRef)
                                                                          @"AutoLaunchedApplicationDictionary", (CFStringRef) @"loginwindow",
                                                                          kCFPreferencesCurrentUser, kCFPreferencesAnyHost);
    NSDictionary *myLoginItem = [ NSDictionary dictionaryWithObjectsAndKeys: [ NSNumber numberWithBool: NO ],
        @"Hide",
        [[ self bundle ] pathForResource:@"GeekTool" ofType: @"app" ],@"Path",
        nil ];
    loginItems = [[loginItems autorelease] mutableCopy];
    [ loginItems removeObject: myLoginItem ];

    if ([ sender state ] == NO)
    {
        CFPreferencesSetValue((CFStringRef) @"AutoLaunchedApplicationDictionary", loginItems,
                              (CFStringRef)@"loginwindow", kCFPreferencesCurrentUser, kCFPreferencesAnyHost);
        CFPreferencesSynchronize((CFStringRef) @"loginwindow", kCFPreferencesCurrentUser,
                                 kCFPreferencesAnyHost);
        [loginItems release];
	[[ NSDistributedNotificationCenter defaultCenter ] postNotificationName: @"GTQuit"
								         object: @"GeekToolPrefs"
								       userInfo: nil
							     deliverImmediately: YES
	    ];
    [ gEnable setState: NSOnState ];
        //[ RemoteGeekTool deactivate ];
    }
    else
    {
        [ loginItems addObject: myLoginItem ];
        CFPreferencesSetValue((CFStringRef) @"AutoLaunchedApplicationDictionary", loginItems,
                              (CFStringRef)@"loginwindow", kCFPreferencesCurrentUser, kCFPreferencesAnyHost);
        CFPreferencesSynchronize((CFStringRef) @"loginwindow", kCFPreferencesCurrentUser,
                                 kCFPreferencesAnyHost);
        [loginItems release];
        [ gEnable setState: NSMixedState ];
        NSString *myPath = [[[[[ self bundle ] pathForResource:@"GeekTool" ofType: @"app" ]
                                    stringByAppendingPathComponent: @"Contents" ]
                                    stringByAppendingPathComponent: @"MacOS" ]
                                    stringByAppendingPathComponent: @"GeekTool" ];
        [ NSTask launchedTaskWithLaunchPath: myPath arguments: [ NSArray array ]];
    }

}
- (void)updateWindows
{
    //[ RemoteGeekTool updateWindows ];
    [[ NSDistributedNotificationCenter defaultCenter ] postNotificationName: @"GTUpdateWindows"
								     object: @"GeekToolPrefs"
								   userInfo: nil
							 deliverImmediately: YES
	];
    //[ self notifHilight ];    
}
- (void)notifHilight
{
    NSDictionary *userInfo = [ NSDictionary dictionaryWithObjectsAndKeys:
        [ gPoolsMenu titleOfSelectedItem ], @"poolName",
        [ NSNumber numberWithInt: [ gLogsList selectedRow ]], @"index",
        nil ];
    [[ NSDistributedNotificationCenter defaultCenter ] postNotificationName: @"GTHilightWindow"
                                                                     object: @"GeekToolPrefs"
                                                                   userInfo: userInfo
                                                         deliverImmediately: YES
        ];    
}
- (void)applyNotification:(NSNotification*)aNotification
{
    [ self applyChanges ];
    [ self savePrefs ];
    //[ self updateWindows ];
}
- (void)applyAndNotifyNotification:(NSNotification*)aNotification
{
    [ self applyChanges ];
    [ self savePrefs ];
    [ self updateWindows ];
}

- (void)reorder:(int)from to:(int)to
{
    [[ NSDistributedNotificationCenter defaultCenter ] postNotificationName: @"GTReorder"
                                                                     object: @"GeekToolPrefs"
                                                                   userInfo: [ NSDictionary dictionaryWithObjectsAndKeys:
                                                                       [ NSNumber numberWithInt: from ], @"from",
                                                                       [ NSNumber numberWithInt: to ], @"to",
                                                                       nil ]
                                                         deliverImmediately: YES
        ];
    
}

#pragma mark -
#pragma mark Preferences handling
- (IBAction)gApply:(id)sender
{
    [ self applyChanges ];
    [ self savePrefs ];
    [ self updateWindows ];
}

- (void)updatePrefs
{
    NSLog(@"Old preferences format detected, updating");
    NSEnumerator *e = [ g_logs objectEnumerator ];
    NSDictionary *log;

    while (log = [ e nextObject ])
    {
        NSDictionary *rectDictionary =
        [[ log objectForKey: @"logEntry" ] objectForKey: @"rect" ];

        NSRect oldRect = NSMakeRect(
                                    [[ rectDictionary objectForKey: @"x" ] intValue ],
                                    [[ rectDictionary objectForKey: @"y" ] intValue ],
                                    [[ rectDictionary objectForKey: @"w" ] intValue ],
                                    [[ rectDictionary objectForKey: @"h" ] intValue ]
                                    );
        NSRect newRect = [ self screenRect: oldRect ];
        NSDictionary *newDictionary = [ NSDictionary dictionaryWithObjectsAndKeys:
            [ NSNumber numberWithInt: newRect.origin.x], @"x",
            [ NSNumber numberWithInt: newRect.origin.y], @"y",
            [ NSNumber numberWithInt: newRect.size.width], @"w",
            [ NSNumber numberWithInt: newRect.size.height], @"h",
            nil ];
        [[ log objectForKey: @"logEntry" ] setObject: newDictionary forKey: @"rect" ];
    }
    [ self savePrefs ];
}
- (void)savePrefs
{
    CFPreferencesAppSynchronize( appID );
    NSMutableDictionary *poolsDictionary = [ NSMutableDictionary dictionary ];

    NSEnumerator *p = [ pools keyEnumerator ];
    NSString *cPoolKey;
    while (cPoolKey = [ p nextObject ])
    {
        NSMutableArray *logsArray = [ NSMutableArray array ];
        NSEnumerator *l = [[ pools objectForKey: cPoolKey ] objectEnumerator ];
        GTLog *gtl;
        while (gtl = [ l nextObject ])
        {
            [ logsArray addObject: [ gtl dictionary ]];
        }
        [ poolsDictionary setObject: logsArray forKey: cPoolKey ];
    }
    CFPreferencesSetAppValue( CFSTR("pools"), poolsDictionary, appID );
    CFPreferencesSetAppValue( CFSTR("currentPool"), [ gActivePool titleOfSelectedItem ], appID );
    CFPreferencesAppSynchronize( appID );
}
- (void)applyChanges
{
    if (lastSelected == -1)
        return;
    GTLog *currentLog = [[ self currentPool ] objectAtIndex: lastSelected ];

    // File type specific
    [ currentLog setType: [ self logType ]];

    [ currentLog setFile: [ t1FilePath stringValue ]];
    [ currentLog setCommand: [ t2Command stringValue ]];
    switch ([ self logType ])
    {
        case 0 : // File type

            [ currentLog setTextColor: [[ cf1TextColor color ] colorUsingColorSpaceName: @"NSCalibratedRGBColorSpace"  ]];
            [ currentLog setBackgroundColor: [[ cf1BackgroundColor color ] colorUsingColorSpaceName: @"NSCalibratedRGBColorSpace" ]];
            [ currentLog setFontName: [[ cf1FontTextField font ] fontName ]];
            [ currentLog setFontSize: [[ cf1FontTextField font ] pointSize ]];
            [ currentLog setShadowText: [ cf1ShadowText state ]];
            [ currentLog setShadowWindow: [ cf1ShadowWindow state ]];
            [ currentLog setAlignment: [ self alignment ]];
            break;
        case 1 : // Command type
            [ currentLog setTextColor: [[ cf2TextColor color ] colorUsingColorSpaceName: @"NSCalibratedRGBColorSpace"  ]];
            [ currentLog setBackgroundColor: [[ cf2BackgroundColor color ] colorUsingColorSpaceName: @"NSCalibratedRGBColorSpace" ]];
            [ currentLog setFontName: [[ cf2FontTextField font ] fontName ]];
            [ currentLog setFontSize: [[ cf2FontTextField font ] pointSize ]];
            [ currentLog setShadowText: [ cf2ShadowText state ]];
            [ currentLog setShadowWindow: [ cf2ShadowWindow state ]];
            [ currentLog setAlignment: [ self alignment ]];
            [ currentLog setRefresh: [ t2Refresh intValue ]];
            break;
        case 2 :
            [ currentLog setRefresh: [ t3Refresh intValue ]];
    }
    
    // Image type
    [ currentLog setImageURL: [ t3URL stringValue ] ];
    [ currentLog setTransparency: [ cf3transparency floatValue ]];
    [ currentLog setImageFit: [ cf3Fit indexOfSelectedItem ]];
    [ currentLog setFrameType: [ cf3FrameType indexOfSelectedItem ]];
    [ currentLog setPictureAlignment: [ self pictureAlignment ]];
    //[ currentLog setCrop: [ cf3Crop state ]];
    
    // Generic
    [ currentLog setRect: NSMakeRect([ sX intValue ],
                                     [ sY intValue ],
                                     [ sW intValue ],
                                     [ sH intValue ])];
    if ([ kot state])
        [ currentLog setWindowLevel: NSStatusWindowLevel ];
    else
        [ currentLog setWindowLevel: kCGDesktopWindowLevel ];
}

- (IBAction)menuCheckBoxChanged:(id)sender
{
    if ([ sender state ])
    {
        CFPreferencesSetAppValue( CFSTR("enableMenu"), [ NSNumber numberWithBool: YES ], appID );
        [ self loadMenu ];
    }
    else
    {
        CFPreferencesSetAppValue( CFSTR("enableMenu"), [ NSNumber numberWithBool: NO ], appID );
        [ self unloadMenu ];
    }
    CFPreferencesAppSynchronize( appID );
}
- (void)loadMenu
{
    NSString *menuExtraPath;
    CFURLRef url;
    unsigned int outExtra;

    menuExtraPath = [[ NSBundle bundleWithPath: [[self bundle] pathForResource:@"GeekToolMenu" ofType: @"menu" ]
        ] pathForResource:@"MenuCracker" ofType: @"menu" ];
    url = CFURLCreateWithFileSystemPath(kCFAllocatorDefault, (CFStringRef)menuExtraPath, kCFURLPOSIXPathStyle, NO);
    CoreMenuExtraAddMenuExtra(url, 0, 0, nil, 0, &outExtra);

    menuExtraPath = [[self bundle] pathForResource:@"GeekToolMenu" ofType: @"menu" ];
    url = CFURLCreateWithFileSystemPath(kCFAllocatorDefault, (CFStringRef)menuExtraPath, kCFURLPOSIXPathStyle, NO);
    CoreMenuExtraAddMenuExtra(url, 0, 0, nil, 0, &outExtra);
    CFRelease(url);
}
- (void)unloadMenu
{
    typedef struct OpaqueMenuExtraRef *MenuExtraRef;
    unsigned int outExtra;

    CFPreferencesSetAppValue( CFSTR("enableMenu"), [ NSNumber numberWithBool: NO ], appID );
    NSString *identifier=@"org.tynsoe.geektool";
    MenuExtraRef *menuExtra = nil;
    CoreMenuExtraGetMenuExtra((CFStringRef)identifier, &menuExtra);
    if (menuExtra != nil)
        CoreMenuExtraRemoveMenuExtra( menuExtra, &outExtra );    
}
#pragma mark -
#pragma mark Misc

- (NSRect)screenRect:(NSRect)oldRect
{
    NSRect screenSize = [[ NSScreen mainScreen ] frame ];
    int screenY = screenSize.size.height - oldRect.origin.y - oldRect.size.height;
    return NSMakeRect(oldRect.origin.x, screenY, oldRect.size.width, oldRect.size.height);
}

- (void)didUnselect
{
    CFPreferencesAppSynchronize( appID );
    [[ NSDistributedNotificationCenter defaultCenter ] postNotificationName: @"GTPrefsQuit"
								     object: @"GeekToolPrefs"
								   userInfo: nil
						         deliverImmediately: YES
	];
    [[[ NSFontManager sharedFontManager ] fontPanel: NO ] close ];
}
@end
