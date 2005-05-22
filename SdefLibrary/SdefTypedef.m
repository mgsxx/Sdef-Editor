//
//  SdefEnumeration.m
//  SDef Editor
//
//  Created by Grayfox on 02/01/05.
//  Copyright 2005 Shadow Lab. All rights reserved.
//

#import "SdefTypedef.h"

@implementation SdefEnumeration
#pragma mark Protocols Implementations
- (id)copyWithZone:(NSZone *)aZone {
  SdefEnumeration *copy = [super copyWithZone:aZone];
  copy->sd_inline = sd_inline;
  return copy;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
  [super encodeWithCoder:aCoder];
  [aCoder encodeInt:sd_inline forKey:@"SEInline"];
}

- (id)initWithCoder:(NSCoder *)aCoder {
  if (self = [super initWithCoder:aCoder]) {
    sd_inline = [aCoder decodeIntForKey:@"SEInline"];  
  }
  return self;
}

#pragma mark Values
+ (SdefObjectType)objectType {
  return kSdefEnumerationType;
}

+ (NSString *)defaultName {
  return NSLocalizedStringFromTable(@"enumeration", @"SdefLibrary", @"Enumeration default name");
}

+ (NSString *)defaultIconName {
  return @"Enum";
}

- (void)sdefInit {
  [super sdefInit];
  sd_inline = kSdefInlineAll;
}

#pragma mark Inline
- (int)inlineValue {
  return sd_inline;
}

- (void)setInlineValue:(int)value {
  if (value != sd_inline) {
    [[[self undoManager] prepareWithInvocationTarget:self] setInlineValue:sd_inline];
    [[self undoManager] setActionName:@"Change Inline"];
    sd_inline = value;
  }
}

@end

#pragma mark -
@implementation SdefEnumerator
#pragma mark Protocols Implementations
- (id)copyWithZone:(NSZone *)aZone {
  SdefEnumerator *copy = [super copyWithZone:aZone];
  return copy;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
  [super encodeWithCoder:aCoder];
}

- (id)initWithCoder:(NSCoder *)aCoder {
  if (self = [super initWithCoder:aCoder]) {
  }
  return self;
}

#pragma mark Values
+ (SdefObjectType)objectType {
  return kSdefEnumeratorType;
}

+ (NSString *)defaultName {
  return NSLocalizedStringFromTable(@"enumerator", @"SdefLibrary", @"Enumerator default name");
}

+ (NSString *)defaultIconName {
  return @"Enum";
}

- (void)sdefInit {
  [super sdefInit];
  sd_soFlags.hasDocumentation = 0;
}

@end

#pragma mark -
@implementation SdefValue
#pragma mark Protocols Implementations
- (id)copyWithZone:(NSZone *)aZone {
  SdefValue *copy = [super copyWithZone:aZone];
  return copy;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
  [super encodeWithCoder:aCoder];
}

- (id)initWithCoder:(NSCoder *)aCoder {
  if (self = [super initWithCoder:aCoder]) {
  }
  return self;
}

#pragma mark Values
+ (SdefObjectType)objectType {
  return kSdefValueType;
}

+ (NSString *)defaultName {
  return NSLocalizedStringFromTable(@"value", @"SdefLibrary", @"Value default name");
}

+ (NSString *)defaultIconName {
  return @"Value";
}

@end

#pragma mark -
@implementation SdefRecord
#pragma mark Protocols Implementations
- (id)copyWithZone:(NSZone *)aZone {
  SdefRecord *copy = [super copyWithZone:aZone];
  return copy;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
  [super encodeWithCoder:aCoder];
}

- (id)initWithCoder:(NSCoder *)aCoder {
  if (self = [super initWithCoder:aCoder]) {
  }
  return self;
}

#pragma mark Values
+ (SdefObjectType)objectType {
  return kSdefRecordType;
}

+ (NSString *)defaultName {
  return NSLocalizedStringFromTable(@"record", @"SdefLibrary", @"Record default name");
}

+ (NSString *)defaultIconName {
  return @"Record";
}

@end
