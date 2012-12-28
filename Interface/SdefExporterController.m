/*
 *  SdefExporterController.m
 *  Sdef Editor
 *
 *  Created by Rainbow Team.
 *  Copyright © 2006 - 2007 Shadow Lab. All rights reserved.
 */

#import "SdefExporterController.h"
#import "SdefWindowController.h"
#import "SdefProcessor.h"
#import "SdefDocument.h"
#import "SdefEditor.h"

static NSString *SystemMajorVersion(void) {
//  SInt32 macVersion;
//  if (Gestalt(gestaltSystemVersion, &macVersion) == noErr) {
//    return [NSString stringWithFormat:@"%x.%x", (macVersion >> 8) & 0xff, (macVersion >> 4) & 0xf];
//  }
  return @"10.5";
}

@implementation SdefExporterController

- (id)init {
  if (self = [super initWithWindowNibName:@"SdefExport"]) {
    sbhFormat = YES;
    sbmFormat = YES;
    [self setVersion:SystemMajorVersion()];
  }
  return self;
}

- (void)dealloc {
  [sd_version release];
  [super dealloc];
}

#pragma mark -

- (NSString *)version {
  return sd_version;
}

- (void)setVersion:(NSString *)version {
  if (sd_version != version) {
    [sd_version release];
    sd_version = [version retain];
  }
}

- (SdefDocument *)sdefDocument {
  return sd_document;
}

- (void)setSdefDocument:(SdefDocument *)aDocument {
  sd_document = aDocument;
}

- (IBAction)close:(id)sender {
  if ([[self window] isSheet]) {
    [NSApp endSheet:[self window]];
  }
  [self close];
}

- (IBAction)next:(id)sender {
  [NSApp endSheet:[self window]];
  [[self window] close];
  NSOpenPanel *openPanel = [NSOpenPanel openPanel];
  [openPanel setPrompt:NSLocalizedString(@"Choose", @"Choose an export folder Prompt.")];
  [openPanel setMessage:NSLocalizedString(@"Choose a destination folder", @"Choose an export folder Message.")];
  [openPanel setCanChooseFiles:NO];
  [openPanel setCanCreateDirectories:YES];
  [openPanel setCanChooseDirectories:YES];
  [openPanel setAllowsMultipleSelection:NO];
  [openPanel setTreatsFilePackagesAsDirectories:YES];
  [openPanel beginSheetModalForWindow:[[sd_document documentWindow] window]
                    completionHandler:^(NSInteger code) {
                      if ((code == NSOKButton) && ([[openPanel URLs] count] > 0)) {
                        SdefProcessor *proc = [[SdefProcessor alloc] initWithSdefDocument:[self sdefDocument]];
                        [proc setOutput:[[[openPanel URLs] objectAtIndex:0] path]];
                        
                        NSMutableArray *defs = [[NSMutableArray alloc] init];
                        if ([[includes arrangedObjects] count]) {
                          id item;
                          id items = [[includes arrangedObjects] objectEnumerator];
                          while (item = [items nextObject]) {
                            [defs addObject:[item valueForKey:@"path"]];
                          }
                        }
                        if (includeCore) [defs addObject:[[NSBundle mainBundle] pathForResource:@"NSCoreSuite" ofType:@"sdef"]];
                        if (includeText) [defs addObject:[[NSBundle mainBundle] pathForResource:@"NSTextSuite" ofType:@"sdef"]];
                        
                        if ([defs count])
                          [proc setIncludes:defs];
                        [defs release];
                        
                        SdefProcessorFormat format = 0;
                        if (resourceFormat || rsrcFormat) format |= kSdefResourceFormat;
                        if (cocoaFormat) format |= (kSdefScriptSuiteFormat | kSdefScriptTerminologyFormat);
                        if (sbmFormat) format |= kSdefScriptBridgeImplementationFormat;
                        if (sbhFormat) format |= kSdefScriptBridgeHeaderFormat;
                        
                        [proc setFormat:format];
                        
                        [proc setVersion:sd_version ? : SystemMajorVersion()];
                        @try {
                          NSString *result = [proc process];
                          if (result) {
                            NSRunAlertPanel(NSLocalizedString(@"Warning: Scripting Definition Processor says:", @"sdp return a value: message title"),
                                            result,
                                            NSLocalizedString(@"OK", @"Default Button"), nil, nil);
                          }
                          if (rsrcFormat) {
                            [self compileResourceFile:[proc output]];
                            if (!resourceFormat) {
                              [[NSFileManager defaultManager] removeItemAtPath:[[proc output] stringByAppendingPathComponent:@"Scripting.r"] error:NULL];
                            }
                          }
                        } @catch (id exception) {
                          [proc release];
                          proc = nil;
                          SPXLogException(exception);
                          NSRunAlertPanel(NSLocalizedString(@"Undefined error while exporting", @"sdp exception"),
                                          NSLocalizedString(@"An Undefined error prevent exportation: %@", @"sdp exception"),
                                          NSLocalizedString(@"OK", @"Default Button"), nil, nil, exception);  
                        }
                        [proc release];
                      }
                      [self close];
                    }];
}

- (void)close {
  [controller setContent:nil];
  [super close];
}

//- (IBAction)export:(id)sender {
//  NSOpenPanel *openPanel = [NSOpenPanel openPanel];
//  [openPanel setPrompt:NSLocalizedString(@"Choose", @"Choose an export folder Prompt.")];
//  [openPanel setMessage:NSLocalizedString(@"Choose a destination folder", @"Choose an export folder Message.")];
//  [openPanel setCanChooseFiles:NO];
//  [openPanel setCanCreateDirectories:YES];
//  [openPanel setCanChooseDirectories:YES];
//  [openPanel setAllowsMultipleSelection:NO];
//  [openPanel setTreatsFilePackagesAsDirectories:YES];
//  switch ([openPanel runModalForTypes:nil]) {
//    case NSCancelButton:
//      return;
//  }
//  if (![[openPanel filenames] count]) return;
//  
//  SdefProcessor *proc = [[SdefProcessor alloc] initWithSdefDocument:[self sdefDocument]];
//  [proc setOutput:[[openPanel filenames] objectAtIndex:0]];
//  
//  id defs = [[NSMutableArray alloc] init];
//  if ([[includes arrangedObjects] count]) {
//    id items = [[includes arrangedObjects] objectEnumerator];
//    id item;
//    while (item = [items nextObject]) {
//      [defs addObject:[item valueForKey:@"path"]];
//    }
//  }
//  if (includeCore) [defs addObject:[[NSBundle mainBundle] pathForResource:@"NSCoreSuite" ofType:@"sdef"]];
//  if (includeText) [defs addObject:[[NSBundle mainBundle] pathForResource:@"NSTextSuite" ofType:@"sdef"]];
//  
//  if ([defs count])
//    [proc setIncludes:defs];
//  [defs release];
//  
//  SdefProcessorFormat format = 0;
//  if (resourceFormat || rsrcFormat) format |= kSdefResourceFormat;
//  if (cocoaFormat) format |= (kSdefScriptSuiteFormat | kSdefScriptTerminologyFormat);
//	if (sbmFormat) format |= kSdefScriptBridgeImplementationFormat;
//	if (sbhFormat) format |= kSdefScriptBridgeHeaderFormat;
//  [proc setFormat:format];
//  
//  [proc setVersion:sd_version ? : SystemMajorVersion()];
//  @try {
//    NSString *result = [proc process];
//    if (result) {
//      NSRunAlertPanel(NSLocalizedString(@"Warning: Scripting Definition Processor says:", @"sdp return a value: message title"),
//                      result,
//                      NSLocalizedString(@"OK", @"Default Button"), nil, nil);
//    }
//    if (rsrcFormat) {
//      [self compileResourceFile:[proc output]];
//      if (!resourceFormat) {
//        [[NSFileManager defaultManager] removeFileAtPath:[[proc output] stringByAppendingPathComponent:@"Scripting.r"] handler:nil];
//      }
//    }
//  } @catch (id exception) {
//    [proc release];
//    proc = nil;
//    SPXLogException(exception);
//    NSRunAlertPanel(NSLocalizedString(@"Undefined error while exporting", @"sdp exception"),
//                    NSLocalizedString(@"An Undefined error prevent exportation: %@", @"sdp exception"),
//                    NSLocalizedString(@"OK", @"Default Button"), nil, nil, exception);  
//  }
//  [proc release];
//  [self close:sender];
//}

- (void)compileResourceFile:(NSString *)folder {
  NSString *resource = [folder stringByAppendingPathComponent:@"Scripting.r"];
  if (![[NSFileManager defaultManager] fileExistsAtPath:resource]) {
    return;
  }
	NSString *rezTool = nil;
  NSString *dest = [folder stringByAppendingPathComponent:@"Scripting.rsrc"];
  // The path to the binary is the first argument that was passed in
	rezTool = [[NSUserDefaults standardUserDefaults] stringForKey:@"SdefRezToolPath"];
	if (![[NSFileManager defaultManager] fileExistsAtPath:rezTool]) {
		NSRunAlertPanel(@"Rez not found", @"Set the Rez tool path in Sdef Editor Preferences", @"OK", nil, nil);
	} else {
		NSTask *rez = [NSTask launchedTaskWithLaunchPath:rezTool
																					 arguments:[NSArray arrayWithObjects:resource, @"-o", dest, @"-useDF", nil]];
		[rez waitUntilExit];
	}
}

- (IBAction)include:(id)sender {
  NSOpenPanel *openPanel = [NSOpenPanel openPanel];
  [openPanel setPrompt:@"Include"];
  [openPanel setCanChooseFiles:YES];
  [openPanel setCanCreateDirectories:NO];
  [openPanel setCanChooseDirectories:NO];
  [openPanel setAllowsMultipleSelection:YES];
  [openPanel setTreatsFilePackagesAsDirectories:YES];
  [openPanel setAllowedFileTypes:[NSArray arrayWithObjects:@"sdef", ScriptingDefinitionFileUTI,
                                  NSFileTypeForHFSTypeCode(kScriptingDefinitionHFSType), nil]];
  switch ([openPanel runModal]) {
    case NSCancelButton:
      return;
  }
  for (NSURL *file in [openPanel URLs]) {
    NSString *path = [file path];
    NSDictionary *dico = [[NSDictionary alloc] initWithObjectsAndKeys:
                          path, @"path",
                          [[NSFileManager defaultManager] displayNameAtPath:path], @"name",
                          [[NSWorkspace sharedWorkspace] iconForFile:path], @"icon", nil];
    [includes addObject:dico];
    [dico release];
  }
}

+ (NSSet *)keyPathsForValuesAffectingCanExport {
  return [NSSet setWithObjects:@"resourceFormat", @"cocoaFormat", @"rsrcFormat", @"sbhFormat", @"sbmFormat", nil];
}

- (BOOL)canExport {
  return resourceFormat | cocoaFormat | rsrcFormat | sbhFormat | sbmFormat;
}

@end
