//
//  GTLog.h
//  GeekTool
//
//  Created by Yann Bizeul on Sun Jan 26 2003.
//  Copyright (c) 2003 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>
#import "LogWindowController.h"
#import "ImageLogWindowController.h"

@interface GTLog : NSObject <NSCopying> {
    IBOutlet id logWindowController;

    NSMutableDictionary *dictionary;
    /*
    NSString *name;
    int type;
    int refresh;
    NSString *file;
    NSString *command;
    NSString *fontName;
    float fontSize;
    
    bool shadowText;
    bool shadowWindow;
    NSColor *textColor;
    NSColor *backgroundColor;
    int alignment;
    int pictureAlignment;
    NSRect rect;
    float transparency;
    NSString *imageURL;
    NSString* imageFit;
    bool enabled;
*/
    NSTask *task;
    bool running;
    LogWindowController *windowController;
    NSTimer *timer;
    BOOL clear;
    NSArray *arguments;
    bool empty;
//    NSString *frameType;

    int i;
    
}

- (id)initWithDictionary:(NSDictionary*)aDictionary;
- (NSDictionary*)dictionary;
- (void)setDictionary:(NSDictionary*)aDictionary;

#pragma mark -
#pragma mark Accessors
- (NSString*)name;
- (void)setName:(NSString*)aName;
- (BOOL)enabled;
- (NSNumber*)enabledAsNumber;
- (void)setEnabled:(BOOL)aBool;
- (int)type;
- (void)setType:(int)aType;
- (NSString*)file;
- (void)setFile:(NSString*)aFile;
- (NSString*)command;
- (void)setCommand:(NSString*)aCommand;
- (int)refresh;
- (void)setRefresh:(int)aRefresh;
- (NSColor*)textColor;
- (void)setTextColor:(NSColor*)aTextColor;
- (NSColor*)backgroundColor;
- (void)setBackgroundColor:(NSColor*)aBackgroundColor;
- (NSString*)fontName;
- (void)setFontName:(NSString*)aFontName;
- (float)fontSize;
- (void)setFontSize:(float)aFontSize;
- (NSFont*)font;
- (BOOL)shadowText;
- (NSNumber*)shadowTextAsInteger;
- (void)setShadowText:(BOOL)aBool;
- (float)shadowWindow;
- (NSNumber*)shadowWindowAsInteger;
- (void)setShadowWindow:(BOOL)aBool;
- (int)alignment;
- (void)setAlignment:(int)anAlignment;
- (int)pictureAlignment;
- (void)setPictureAlignment:(int)anAlignment;
- (int)NSPictureAlignment;
- (NSString*)imageURL;
- (void)setImageURL:(NSString*)anURL;
- (float)transparency;
- (float)transparencyPercent;
- (void)setTransparency:(float)aTransparency;
- (int)imageFit;
- (int)NSImageFit;
- (void)setImageFit:(int)fit;
- (BOOL)crop;
- (void)setCrop:(BOOL)aBool;
- (NSRect)cropRect;
- (NSRect)screenCropRect;
- (void)setCropRect:(NSRect)aRect;
- (NSRect)rect;
- (NSRect)screenRect;
- (void)setRect:(NSRect)aRect;
- (int)windowLevel;
- (void)setWindowLevel:(int)level;
- (int)frameType;
- (int)NSFrameType;
- (void)setFrameType:(int)aFrameType;

#pragma mark -
#pragma mark Logs operations

- (void) updateWindow;
-(void)updateCommand:(NSTimer*)timer;
-(void)newLines:(NSNotification*)aNotification;
-(void)taskEnd:(NSNotification*)aNotification;
- (void)setHilighted:(BOOL)myHilight;
- (id)mutableCopyWithZone:(NSZone *)zone;
- (id)copyWithZone:(NSZone *)zone;
- (void)terminate;
- (bool)equals:(GTLog*)comp;
- (void)front;

#pragma mark -
#pragma mark Misc

- (NSRect)newYPos:(NSRect)rect;

@end
