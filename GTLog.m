//
//  GTLog.m
//  GeekTool
//
//  Created by Yann Bizeul on Sun Jan 26 2003.
//  Copyright (c) 2003 __MyCompanyName__. All rights reserved.
//

#import "GTLog.h"
#define DEFAULT_REFRESH 10
#define NSYES [ NSNumber numberWithBool: YES ]
#define NSNO [ NSNumber numberWithBool: NO ]

@implementation GTLog
- (id)init
{
    self = [ super init ];
    return self;
}
- (id)initWithDictionary:(NSDictionary*)aDictionary;
{
    self = [ super init ];
    dictionary = [ aDictionary mutableCopy ];
    return self;
}

- (NSDictionary*)dictionary
{
    
    NSDictionary *textColorDictionary = [ NSDictionary dictionaryWithObjectsAndKeys:
        [ NSNumber numberWithFloat: [[ self textColor ] redComponent ]], @"red",
        [ NSNumber numberWithFloat: [[ self textColor ] greenComponent ]], @"green",
        [ NSNumber numberWithFloat: [[ self textColor ] blueComponent ]], @"blue",
        [ NSNumber numberWithFloat: [[ self textColor ] alphaComponent ]], @"alpha",
        nil ];
    NSDictionary *backgroundColorDictionary = [ NSDictionary dictionaryWithObjectsAndKeys:
        [ NSNumber numberWithFloat: [[ self backgroundColor ] redComponent ]], @"red",
        [ NSNumber numberWithFloat: [[ self backgroundColor ] greenComponent ]], @"green",
        [ NSNumber numberWithFloat: [[ self backgroundColor ] blueComponent ]], @"blue",
        [ NSNumber numberWithFloat: [[ self backgroundColor ] alphaComponent ]], @"alpha",
        nil ];
    NSDictionary *rectDictionary = [ NSDictionary dictionaryWithObjectsAndKeys:
        [ NSNumber numberWithInt: [ self rect ].origin.x], @"x",
        [ NSNumber numberWithInt: [ self rect ].origin.y], @"y",
        [ NSNumber numberWithInt: [ self rect ].size.width ], @"w",
        [ NSNumber numberWithInt: [ self rect ].size.height ], @"h",
        nil ];
    /*
    NSDictionary *cropDictionary = [ NSDictionary dictionaryWithObjectsAndKeys:
        [ NSNumber numberWithInt: [ self cropRect ].origin.x], @"x",
        [ NSNumber numberWithInt: [ self cropRect ].origin.y], @"y",
        [ NSNumber numberWithInt: [ self cropRect ].size.width ], @"w",
        [ NSNumber numberWithInt: [ self cropRect ].size.height ], @"h",
        nil ];
    */
    NSDictionary *resultDictionary=[ NSDictionary dictionaryWithObjectsAndKeys:
        [ self name ],@"name",
        [ NSNumber numberWithInt: [ self type ]]	, @"type",
        [ NSNumber numberWithBool: [ self enabled ]]	, @"enabled",

        [ self file ]					, @"file",
        
        [ self command ]				, @"command",
        [ NSNumber numberWithInt: [ self refresh ]]	, @"refresh",

        textColorDictionary				, @"textColor",
        backgroundColorDictionary			, @"backgroundColor",
        [ self fontName ]				, @"fontName",
        [ NSNumber numberWithFloat: [ self fontSize ]]	, @"fontSize",
        [ self shadowTextAsInteger ]			, @"shadowText",
        [ self shadowWindowAsInteger ]			, @"shadowWindow",
        [ NSNumber numberWithInt: [ self alignment ]]	, @"alignment",
        
        [ NSNumber numberWithInt: [ self pictureAlignment ]]	, @"pictureAlignment",
        [ self imageURL ]					, @"imageURL",
        [ NSNumber numberWithFloat: [ self transparency ]]	, @"transparency",
        [ NSNumber numberWithInt: [ self imageFit ]]		, @"imageFit",
        [ NSNumber numberWithInt: [ self frameType ]]		, @"frameType",
        [ NSNumber numberWithBool: [ self crop ]]		, @"crop",
        // cropDictionary						, @"cropRect",
        //
        rectDictionary					, @"rect",
        
        [ NSNumber numberWithInt: [ self windowLevel ]] ,@"windowLevel",
        nil
        ];
    return resultDictionary;
     
}

- (void)setDictionary:(NSDictionary*)aDictionary
{
    if (! [ aDictionary isEqual: [ self dictionary ]])
    {
        BOOL close = NO;
        if (([  aDictionary objectForKey: @"shadowWindow" ] != [[ self dictionary ] objectForKey : @"shadowWindow" ])
            || ( ! [[ aDictionary objectForKey: @"file" ] isEqual: [[ self dictionary ] objectForKey : @"file" ]])
            || ( ! [[ aDictionary objectForKey: @"command" ] isEqual: [[ self dictionary ] objectForKey : @"command" ]])
            || ( ! [[ aDictionary objectForKey: @"type" ] isEqual: [[ self dictionary ] objectForKey : @"type" ]] )
            || ( ! [[ aDictionary objectForKey: @"enabled" ] isEqual: [[ self dictionary ] objectForKey : @"enabled" ]] ))
            close = YES;

        [ dictionary release ];
        dictionary = [ aDictionary mutableCopy ];
        
        if (close)
        {
            [ self terminate ];
            [ self updateWindow ];
        }
        else
        {
            NSWindow *window = [ windowController window ];

            [ window setHasShadow: [ self shadowWindow ]];
            [ window setLevel: [ self windowLevel ]];
            [ window setFrame: [ self screenRect ] display: NO ];

            if ([ self type ] == 0 || [ self type ] == 1 )
            {
                [ windowController setTextBackgroundColor: [ self backgroundColor ]];
                [ windowController setTextColor: [ self textColor ] ];
                [ windowController setFont: [ self font ]];
                [ windowController setShadowText: [ self shadowText ]];

                [ windowController setTextAlignment: [ self alignment ]];
                [ windowController scrollEnd ];
            }
            if ([ self type ] == 2 )
            {
                [ (ImageLogWindowController*)windowController setStyle: [ self NSFrameType ]];
                [ (ImageLogWindowController*)windowController setPictureAlignment: [ self NSPictureAlignment ]];
                [[ windowController window ] setAlphaValue: [ self transparencyPercent ]];
                [ (ImageLogWindowController*)windowController setFit: [ self NSImageFit ]];
                //[ (ImageLogWindowController*)windowController setCrop: [ self crop ]];
                [ windowController display ];

            }
            if (timer)
            {
                [ timer invalidate ];
                [ timer release ];
                timer = [[ NSTimer scheduledTimerWithTimeInterval: [ self refresh ]
                                                           target: self
                                                         selector: @selector(updateCommand:)
                                                         userInfo: nil
                                                          repeats: YES ] retain ];
                [ timer fire ];
            }
        }
    }
}

#pragma mark -
#pragma mark Accessors
- (NSString*)name;
{
    NSString *result;
    
    if ([(NSString*)[ dictionary objectForKey: @"name" ] length ])
        result = [ dictionary objectForKey: @"name" ];
    else
        result = [ dictionary objectForKey: @"file" ];

    if ([ result length ])
        return result;

    return @"Untitled";
}
- (void)setName:(NSString*)aName;
{
    [ dictionary setObject: aName forKey: @"name" ];
}
- (BOOL)enabled;
{
    return [[ dictionary objectForKey: @"enabled" ] boolValue ];
}
- (NSNumber*)enabledAsNumber;
{
    return [ NSNumber numberWithBool: [ self enabled ]];
}
- (void)setEnabled:(BOOL)aBool;
{
    [ dictionary setObject: [ NSNumber numberWithBool: aBool ] forKey: @"enabled" ];
}

- (int)type;
{
    return [[ dictionary objectForKey: @"type" ] intValue ];
}
- (void)setType:(int)aType;
{
    [ dictionary setObject: [ NSNumber numberWithInt: aType ] forKey: @"type" ];
}

- (NSString*)file;
{
    if ([ dictionary objectForKey: @"file" ])
        return [ dictionary objectForKey: @"file" ];
    else
        return @"";
}
- (void)setFile:(NSString*)aFile;
{
    [ dictionary setObject: aFile forKey: @"file" ];
}

- (NSString*)command;
{
    if ([ dictionary objectForKey: @"command" ])
        return [ dictionary objectForKey: @"command" ];
    else
        return @"";
}
- (void)setCommand:(NSString*)aCommand;
{
    [ dictionary setObject: aCommand forKey: @"command" ];
}

- (int)refresh;
{
    return [[ dictionary objectForKey: @"refresh" ] intValue ];
}
- (void)setRefresh:(int)aRefresh;
{
    [ dictionary setObject: [ NSNumber numberWithInt: aRefresh ] forKey: @"refresh" ];
}

- (NSColor*)textColor;
{
    return [ NSColor colorWithCalibratedRed: [[[ dictionary objectForKey: @"textColor" ] objectForKey: @"red" ] floatValue ]
                                            green: [[[ dictionary objectForKey: @"textColor" ] objectForKey: @"green" ] floatValue ]
                                             blue: [[[ dictionary objectForKey: @"textColor" ] objectForKey: @"blue" ] floatValue ]
                                            alpha: [[[ dictionary objectForKey: @"textColor" ] objectForKey: @"alpha" ] floatValue ]
        ];
}
- (void)setTextColor:(NSColor*)aTextColor;
{
    [ dictionary setObject:
        [ NSDictionary dictionaryWithObjectsAndKeys:
            [ NSNumber numberWithFloat: [ aTextColor redComponent ]], @"red",
            [ NSNumber numberWithFloat: [ aTextColor greenComponent ]], @"green",
            [ NSNumber numberWithFloat: [ aTextColor blueComponent ]], @"blue",
            [ NSNumber numberWithFloat: [ aTextColor alphaComponent ]], @"alpha",
            nil ] forKey: @"textColor" ];
}
- (NSColor*)backgroundColor;
{
    return [ NSColor colorWithCalibratedRed: [[[ dictionary objectForKey: @"backgroundColor" ] objectForKey: @"red" ] floatValue ]
                                      green: [[[ dictionary objectForKey: @"backgroundColor" ] objectForKey: @"green" ] floatValue ]
                                       blue: [[[ dictionary objectForKey: @"backgroundColor" ] objectForKey: @"blue" ] floatValue ]
                                      alpha: [[[ dictionary objectForKey: @"backgroundColor" ] objectForKey: @"alpha" ] floatValue ]
        ];
}
- (void)setBackgroundColor:(NSColor*)aBackgroundColor;
{
    [ dictionary setObject:
        [ NSDictionary dictionaryWithObjectsAndKeys:
            [ NSNumber numberWithFloat: [ aBackgroundColor redComponent ]], @"red",
            [ NSNumber numberWithFloat: [ aBackgroundColor greenComponent ]], @"green",
            [ NSNumber numberWithFloat: [ aBackgroundColor blueComponent ]], @"blue",
            [ NSNumber numberWithFloat: [ aBackgroundColor alphaComponent ]], @"alpha",
            nil ] forKey: @"backgroundColor" ];
}
- (NSString*)fontName;
{
    if ([ dictionary objectForKey: @"fontName" ])
        return [ dictionary objectForKey: @"fontName" ];
    else
        return @"Monaco";
}
- (void)setFontName:(NSString*)aFontName;
{
    [ dictionary setObject: aFontName forKey: @"fontName" ];
}
- (float)fontSize;
{
    if ([[ dictionary objectForKey: @"fontSize" ] floatValue ])
        return [[ dictionary objectForKey: @"fontSize" ] floatValue ];
    else
        return 9;
}
- (void)setFontSize:(float)aFontSize;
{
    [ dictionary setObject: [ NSNumber numberWithInt: aFontSize ] forKey: @"fontSize" ];
}
- (NSFont*)font
{
    return [ NSFont fontWithName: [ self fontName ] size: [ self fontSize ]];
}
- (BOOL)shadowText;
{
    return [[ dictionary objectForKey: @"shadowText" ] boolValue ];
}
- (NSNumber*)shadowTextAsInteger;
{
    return [ NSNumber numberWithBool: [ self shadowText ]];
}

- (void)setShadowText:(BOOL)aBool;
{
    [ dictionary setObject: [ NSNumber numberWithBool: aBool ] forKey: @"shadowText" ];
}
- (float)shadowWindow;
{
    return [[ dictionary objectForKey: @"shadowWindow" ] boolValue ];
}
- (NSNumber*)shadowWindowAsInteger;
{
    return [ NSNumber numberWithBool: [ self shadowWindow ]];
}

- (void)setShadowWindow:(BOOL)aBool;
{
    [ dictionary setObject: [ NSNumber numberWithBool: aBool ] forKey: @"shadowWindow" ];
}
- (int)alignment;
{
    return [[ dictionary objectForKey: @"alignment" ] intValue ];
}
- (void)setAlignment:(int)anAlignment;
{
    [ dictionary setObject: [ NSNumber numberWithInt: anAlignment ] forKey: @"alignment" ];
}
- (int)pictureAlignment;
{
    return [[ dictionary objectForKey: @"pictureAlignment" ] intValue ];
}
- (void)setPictureAlignment:(int)anAlignment;
{
    [ dictionary setObject: [ NSNumber numberWithInt: anAlignment ] forKey: @"pictureAlignment" ];
}
- (int)NSPictureAlignment;
{
    switch ([ self pictureAlignment ])
    {
        case 1:
            return NSImageAlignTopLeft;
            break;
        case 2:
            return NSImageAlignTop;
            break;
        case 3:
            return NSImageAlignTopRight;
            break;
        case 4:
            return NSImageAlignLeft;
            break;
        case 5:
            return NSImageAlignCenter;
            break;
        case 6:
            return NSImageAlignRight;
            break;
        case 7:
            return NSImageAlignBottomLeft;
            break;
        case 8:
            return NSImageAlignBottom;
            break;
        case 9:
            return NSImageAlignBottomRight;
            break;
    }
    return NSImageAlignTopLeft;
}
- (NSString*)imageURL;
{
    if ([ dictionary objectForKey: @"imageURL" ])
        return [ dictionary objectForKey: @"imageURL" ];
    else
        return @"";
}
- (void)setImageURL:(NSString*)anURL;
{
    [ dictionary setObject: anURL forKey: @"imageURL" ];
}
- (float)transparency;
{
    return [[ dictionary objectForKey: @"transparency" ] floatValue ];
}
- (float)transparencyPercent;
{
    return [ self transparency ] / 100;
}
- (void)setTransparency:(float)aTransparency;
{
    [ dictionary setObject: [ NSNumber numberWithFloat: aTransparency ] forKey: @"transparency" ];
    if (windowController)
        [[ windowController window ] setAlphaValue: aTransparency ];

}
- (int)imageFit;
{
    return [[ dictionary objectForKey: @"imageFit" ] intValue ];
}
- (int)NSImageFit;
{
    switch ([ self imageFit ])
    {
        case 0 :
            return NSScaleProportionally;
            break;
        case 1 :
            return NSScaleToFit;
            break;
        case 2 :
            return NSScaleNone;
            break;
    }
    return NSScaleNone;
}
- (void)setImageFit:(int)fit;
{
    [ dictionary setObject: [ NSNumber numberWithInt: fit ] forKey: @"imageFit" ];
}
- (BOOL)crop;
{
    return [[ dictionary objectForKey: @"crop" ] boolValue ];
}
- (void)setCrop:(BOOL)aBool;
{
    [ dictionary setObject: [ NSNumber numberWithBool: aBool ] forKey: @"crop" ];
}

- (NSRect)cropRect;
{
    return NSMakeRect([[[ dictionary objectForKey: @"cropRect" ] objectForKey: @"x" ] intValue ],
                      [[[ dictionary objectForKey: @"cropRect" ] objectForKey: @"y" ] intValue ],
                      [[[ dictionary objectForKey: @"cropRect" ] objectForKey: @"w" ] intValue ],
                      [[[ dictionary objectForKey: @"cropRect" ] objectForKey: @"h" ] intValue ]);
}
- (NSRect)screenCropRect;
{
    return [ self newYPos: [ self cropRect ]];
}
- (void)setCropRect:(NSRect)aRect;
{
    [ dictionary setObject: [ NSDictionary dictionaryWithObjectsAndKeys:
        [ NSNumber numberWithInt: aRect.origin.x], @"x",
        [ NSNumber numberWithInt: aRect.origin.y], @"y",
        [ NSNumber numberWithInt: aRect.size.width ], @"w",
        [ NSNumber numberWithInt: aRect.size.height ], @"h",
        nil ]
                    forKey:@"cropRect" ];
}

- (NSRect)rect;
{
    return NSMakeRect([[[ dictionary objectForKey: @"rect" ] objectForKey: @"x" ] intValue ],
                      [[[ dictionary objectForKey: @"rect" ] objectForKey: @"y" ] intValue ],
                      [[[ dictionary objectForKey: @"rect" ] objectForKey: @"w" ] intValue ],
                      [[[ dictionary objectForKey: @"rect" ] objectForKey: @"h" ] intValue ]);
}
- (NSRect)screenRect;
{
    return [ self newYPos: [ self rect ]];
}
- (void)setRect:(NSRect)aRect;
{
    [ dictionary setObject: [ NSDictionary dictionaryWithObjectsAndKeys:
        [ NSNumber numberWithInt: aRect.origin.x], @"x",
        [ NSNumber numberWithInt: aRect.origin.y], @"y",
        [ NSNumber numberWithInt: aRect.size.width ], @"w",
        [ NSNumber numberWithInt: aRect.size.height ], @"h",
        nil ]
                    forKey:@"rect" ];
}
- (int)windowLevel
{
    if ([[ dictionary objectForKey: @"windowLevel" ] intValue ])
        return [[ dictionary objectForKey: @"windowLevel" ] intValue ];
    else
        return kCGDesktopWindowLevel;
}
- (void)setWindowLevel:(int)level
{
    [ dictionary setObject: [ NSNumber numberWithInt: level ] forKey: @"windowLevel" ];
}
- (int)frameType;
{
    return [[ dictionary objectForKey: @"frameType" ] intValue ];
}
- (int)NSFrameType;
{
    switch ([ self frameType ])
    {
        case 0 :
            return NSImageFrameNone;
            break;
        case 1 :
            return NSImageFramePhoto;
            break;
        case 2 :
            return NSImageFrameGrayBezel;
            break;
        case 3 :
            return NSImageFrameGroove;
            break;
        case 4 :
            return NSImageFrameButton;
            break;
    }
    return NSImageFrameGrayBezel;
}
- (void)setFrameType:(int)aFrameType;
{
    [ dictionary setObject: [ NSNumber numberWithInt: aFrameType ] forKey: @"frameType" ];
}

#pragma mark -
#pragma mark Logs operations

- (void) updateWindow
{
    NSAutoreleasePool *pool = [[ NSAutoreleasePool alloc ] init ];
    NSPipe *pipe;
    if ([ self enabled ] && ! windowController)
    {
        /*
        if ([ self type ] == 0 || [ self type ] == 1)
            windowController = [[ LogWindowController alloc ] initWithWindowNibName: @"logWindow" ];
        else if ([ self type ] == 2)
            windowController = [[ ImageLogWindowController alloc ] initWithWindowNibName: @"imageLogWindow" ];
*/
        switch ([ self type ])
        {
            case 0 :
                if ([[ self file ] isEqual: @"" ])
                    return;
            windowController = [[ LogWindowController alloc ] initWithWindowNibName: @"logWindow" ];

            task = [[ NSTask alloc ] init ];

            [ task setLaunchPath: @"/usr/bin/tail" ];
            [ task setArguments: [ NSArray arrayWithObjects: @"-n",@"50",@"-F", [ self file ], nil]];
            //if (pipe)
            //    [ pipe release ];
            pipe = [ NSPipe pipe ];
            [ task setStandardOutput: pipe ];
            [[ NSNotificationCenter defaultCenter ] addObserver: self
                                                       selector: @selector(newLines:)
                                                           name: @"NSFileHandleReadCompletionNotification"
                                                         object: [ pipe fileHandleForReading ] ];
            [[ NSNotificationCenter defaultCenter ] addObserver: self
                                                       selector: @selector(newLines:)
                                                           name: @"NSFileHandleDataAvailableNotification"
                                                         object: [ pipe fileHandleForReading ] ];
            [[ pipe fileHandleForReading ] waitForDataInBackgroundAndNotify ];
            [[ NSNotificationCenter defaultCenter ] addObserver: self
                                                       selector: @selector(taskEnd:)
                                                           name: @"NSTaskDidTerminateNotification"
                                                         object: task ];            
            [ task launch ];
                break;
            case 1 :
                if ([[ self command ] isEqual: @"" ])
                    return;
                windowController = [[ LogWindowController alloc ] initWithWindowNibName: @"logWindow" ];
                [ windowController setReady: YES ];
                break;
            case 2 :
                if ([[ self imageURL ] isEqual: @"" ])
                    return;

                windowController = [[ ImageLogWindowController alloc ] initWithWindowNibName: @"imageLogWindow" ];
                break;
        }
        
        NSWindow *window = [ windowController window ];

        [ window setHasShadow: [ self shadowWindow ]];
        [ window setLevel: [ self windowLevel ]];
        [ window setFrame: [ self screenRect ] display: NO ];
        [ (LogWindow*)window setClickThrough: YES ];

        if ([ self type ] == 0 || [ self type ] == 1 )
        {
            [ windowController setTextBackgroundColor: [ self backgroundColor ]];
            [ windowController setTextColor: [ self textColor ] ];
            [ windowController setFont: [ self font ]];
            [ windowController setShadowText: [ self shadowText ]];

            [ windowController setTextAlignment: [ self alignment ]];
            [ windowController scrollEnd ];
        }
            
        [ windowController showWindow: self ];
        
        if ([ self type] == 1 || [ self type] == 2)
        {
            if (timer)
            {
                [ timer invalidate ];
                [ timer release ];
                timer = nil;
            }
            if ([ self type ] == 1)
            {
                arguments = [[ NSArray alloc ] initWithObjects: @"-c",[ self command ], nil];
                clear = YES;
            }
            else if ([ self type ] == 2 )
            {
                [ (ImageLogWindowController*)windowController setStyle: [ self NSFrameType ]];
                [ (ImageLogWindowController*)windowController setPictureAlignment: [ self NSPictureAlignment ]];
                [[ windowController window ] setAlphaValue: [ self transparencyPercent ]];
                [ (ImageLogWindowController*)windowController setFit: [ self imageFit ]];
                //[ (ImageLogWindowController*)windowController setCrop: [ self crop ]];
            }
            
            timer = [[ NSTimer scheduledTimerWithTimeInterval: [ self refresh ]
                                                       target: self
                                                     selector: @selector(updateCommand:)
                                                     userInfo: nil
                                                      repeats: YES ] retain ];

            [ timer fire ];
        }
    }
    else if (! [ self enabled ] && windowController)
        [ self terminate ];

    [ pool release ];
}

-(void)updateCommand:(NSTimer*)timer
{
    NSAutoreleasePool *pool = [[ NSAutoreleasePool alloc ] init ];
    BOOL free = YES;
    NSURL *url;
    NSImage *myImage;
    NSMutableString *myUrl = [ NSMutableString stringWithString: [ self imageURL ]];
    NSPipe *pipe;
    
    switch ([ self type ])
    {
        case 1 :
            if ([ task isRunning ])
                free=NO;
            if ( windowController != nil && free)
            {
                [ windowController setReady: NO ];
                task = [[ NSTask alloc ] init ];
                [ task setLaunchPath: @"/bin/sh" ];
                [ task setArguments: arguments ];
                clear = YES;
                pipe = [[ NSPipe alloc ] init ];
                [[ NSNotificationCenter defaultCenter ] addObserver: self
                                                           selector: @selector(newLines:)
                                                               name: @"NSFileHandleReadToEndOfFileCompletionNotification"
                                                             object: [ pipe fileHandleForReading ] ];
                [[ pipe fileHandleForReading ] readToEndOfFileInBackgroundAndNotify ];

                [ task setStandardOutput: pipe ];

                [[ NSNotificationCenter defaultCenter ] addObserver: self
                                                           selector: @selector(taskEnd:)
                                                               name: @"NSTaskDidTerminateNotification"
                                                             object: task ];
                [ task launch ];
                [ pipe release ];
            }
                break;
        case 2:
            if (NSEqualRanges([ myUrl rangeOfString: @"?" ], NSMakeRange(NSNotFound, 0)))
                [myUrl appendString: @"?" ];
            else
                [myUrl appendString: @"&" ];

            [ myUrl appendString: [[NSNumber numberWithLong:random()] stringValue]];
            url = [ NSURL URLWithString: myUrl];
            myImage = [[NSImage alloc] initWithData: [url resourceDataUsingCache:NO]];
            [ (ImageLogWindowController*)windowController setImage: myImage ];
            [ myImage release ];
            break;
    }
    [ pool release ];
}
-(void)newLines:(NSNotification*)aNotification
{
    NSAutoreleasePool *pool = [[ NSAutoreleasePool alloc ] init ];
    NSData *newLines;
    NSString *newLinesString;

    if ([[ aNotification name ] isEqual : @"NSFileHandleReadToEndOfFileCompletionNotification" ])
    {
        newLines = [[ aNotification userInfo ] objectForKey: @"NSFileHandleNotificationDataItem" ];
        [[ NSNotificationCenter defaultCenter ] removeObserver: self
                                                          name: [ aNotification name ]
                                                        object: nil ];        
    }
    else
        newLines = [[ aNotification object ] availableData ];
    
    newLinesString = [[ NSString alloc ] initWithData: newLines encoding:NSASCIIStringEncoding ];
    if (! [ newLinesString isEqualTo: @"" ] || [ self type ] == 1)
    {
        [ windowController addText: newLinesString clear: [ self type ] ];
        if ([ self type ] == 0)
        {
            [ windowController scrollEnd ];
            [ windowController display ];
            [[ aNotification object ] waitForDataInBackgroundAndNotify ];
        }
        [ windowController setFont: [ self font ]];
        [ windowController display ];
    }
    clear = NO;
    [ newLinesString release ];
    [ pool release ];
}
-(void)taskEnd:(NSNotification*)aNotification
{
    [[ NSNotificationCenter defaultCenter ] removeObserver: self
                                                      name: [ aNotification name ]
                                                    object: nil ];
    if ([ self type ] == 0)
    {
        [ self terminate ];
    }
    if ([ self type ] == 1)
    {
        [ task release ];
        task = nil;
        //[ windowController display ];
    }
    return;
}

- (void)setHilighted:(BOOL)myHilight
{
    [ windowController setHilighted: myHilight ];
}

- (id)mutableCopyWithZone:(NSZone *)zone
{
    return [ self copyWithZone: zone ];
}

- (id)copyWithZone:(NSZone *)zone
{
    GTLog *copy = [[[self class] allocWithZone: zone]
            initWithDictionary:[self dictionary]];

    return copy;
}

- (void)terminate;
{
    [[ NSNotificationCenter defaultCenter ] removeObserver: self ];
    if (task)
    {
        [ task terminate ];
        [ task release ];
        //[ pipe release ];
        task = nil;
    }
    
    if (windowController)
    {
        [[ windowController window ] close ];
        windowController=nil;
    }

    if (timer)
    {
        [ timer invalidate ];
        [ timer release ];
        timer=nil;
    }
    if (arguments)
    {
        [ arguments release ];
        arguments = nil;
    }
}

- (bool)equals:(GTLog*)comp
{
    if ( [ dictionary isEqualTo: [ comp dictionary ]])
        return YES;
    return NO;
}

- (void)front
{
    [[ windowController window ] orderFront: self ];
}
#pragma mark -
#pragma mark Misc

- (NSRect)newYPos:(NSRect)rect
{
    NSRect screenSize = [[ NSScreen mainScreen ] frame ];
    return NSMakeRect(rect.origin.x,screenSize.size.height - rect.size.height - rect.origin.y, rect.size.width,rect.size.height);
}
- (NSString*)description
{
    return [ NSString stringWithFormat: @"%@",[ self dictionary ]];
}

- (void)dealloc
{
    [ self terminate ];
    [ dictionary release ];
    [ super dealloc ];
}
@end
