//
//  SdefDocumentation.m
//  SDef Editor
//
//  Created by Grayfox on 02/01/05.
//  Copyright 2005 Shadow Lab. All rights reserved.
//

#import "SdefDocumentation.h"
#import "SKExtensions.h"

#import "SdefDocument.h"

@implementation SdefDocumentation
#pragma mark Protocols Implementations
- (id)copyWithZone:(NSZone *)aZone {
  SdefDocumentation *copy = [super copyWithZone:aZone];
  copy->sd_content = [sd_content copyWithZone:aZone];
  return copy;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
  [super encodeWithCoder:aCoder];
  [aCoder encodeObject:sd_content forKey:@"SDContent"];
}

- (id)initWithCoder:(NSCoder *)aCoder {
  if (self = [super initWithCoder:aCoder]) {
    sd_content = [[aCoder decodeObjectForKey:@"SDContent"] retain];
  }
  return self;
}

#pragma mark -
+ (SdefObjectType)objectType {
  return kSdefDocumentationType;
}

+ (NSString *)defaultName {
  return NSLocalizedStringFromTable(@"Documentation", @"SdefLibrary", @"Documentation default name");
}

+ (NSString *)defaultIconName {
  return @"Bookmarks";
}

- (void)sdefInit {
  [super sdefInit];
  [self setRemovable:NO];
}

- (id)initWithAttributes:(NSDictionary *)attrs {
  if (self = [super init]) {
  }
  return self;
}

- (void)dealloc {
  [sd_content release];
  [super dealloc];
}

- (BOOL)isHtml {
  return sd_soFlags.reserved;
}

- (void)setHtml:(BOOL)flag {
  flag = flag ? 1 : 0;
  if (flag != sd_soFlags.reserved) {
    /* Undo */
    sd_soFlags.reserved = flag;
  }
}

- (NSString *)content {
  return sd_content;
}

- (void)setContent:(NSString *)newContent {
  if (sd_content != newContent) {
    [sd_content release];
    sd_content = [newContent retain];
  }
}

@end
