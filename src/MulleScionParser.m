//
//  MulleScionParser.m
//  MulleScion
//
//  Created by Nat! on 24.02.13.
//
//  Copyright (c) 2013 Nat! - Mulle kybernetiK
//  All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without
//  modification, are permitted provided that the following conditions are met:
//
//  Redistributions of source code must retain the above copyright notice, this
//  list of conditions and the following disclaimer.
//
//  Redistributions in binary form must reproduce the above copyright notice,
//  this list of conditions and the following disclaimer in the documentation
//  and/or other materials provided with the distribution.
//
//  Neither the name of Mulle kybernetiK nor the names of its contributors
//  may be used to endorse or promote products derived from this software
//  without specific prior written permission.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
//  AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
//  IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
//  ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
//  LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
//  CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
//  SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
//  INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
//  CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
//  ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
//  POSSIBILITY OF SUCH DAMAGE.
//


#import "MulleScionParser.h"

#import "MulleScionParser+Parsing.h"
#import "MulleScionObjectModel+Parsing.h"
#import "MulleScionObjectModel+BlockExpansion.h"
#import "NSFileHandle+MulleOutputFileHandle.h"
#import "MulleScionObjectModel+TraceDescription.h"
#if ! defined( TARGET_OS_IPHONE) || ! TARGET_OS_IPHONE
# ifndef __MULLE_OBJC__
#  import <Foundation/NSDebug.h>
# endif
#endif
#include "env-convenience.h"


#ifdef DEBUG
//# define DEBUG_DUMP
#endif


@implementation MulleScionParser

- (id) initWithData:(NSData *) data
           fileName:(NSString *) fileName
         searchPath:(NSArray *) searchPath
{
   NSString   *directory;
   NSString   *pwd;

   NSParameterAssert( [data isKindOfClass:[NSData class]]);
   NSParameterAssert( [fileName isKindOfClass:[NSString class]] && [fileName length]);

   data_           = [data retain];
   fileName_       = [fileName copy];
   if( ! searchPath)
   {
      directory    = [fileName stringByDeletingLastPathComponent];
      if( ! [fileName isAbsolutePath])
      {
         pwd       = [[NSFileManager defaultManager] currentDirectoryPath];
         directory = [pwd stringByAppendingPathComponent:directory];
      }
      searchPath   = [NSArray arrayWithObject:directory];
   }
   searchPath_     = [searchPath copy];
   debugFilePaths_ = getenv_yes_no( "MULLESCION_DUMP_FILE_INCLUDES") ? YES : NO;

   return( self);
}


- (void) dealloc
{
   [searchPath_ release];
   [preprocessor_ release];
   [fileName_ release];
   [data_ release];

   [super dealloc];
}


- (void) setPreprocessor:(NSObject <MulleScionPreprocessor> *) preprocessor
{
   [preprocessor_ autorelease];
   preprocessor_ = [preprocessor retain];
}


- (NSObject <MulleScionPreprocessor> *) preprocessor
{
   return( preprocessor_);
}


- (NSData *) preprocessedData:(NSData *) data
{
   if( preprocessor_)
      return( [preprocessor_ preprocessedData:data]);
   return( data);
}


+ (MulleScionParser *) parserWithContentsOfURL:(NSURL *) url
{
   NSData            *data;
   MulleScionParser  *parser;
   NSError           *error;

   error = nil;
   data  = [NSData dataWithContentsOfURL:url
                                 options:NSDataReadingMappedIfSafe
                                   error:&error];
   if( ! data)
   {
      NSLog( @"%@", error);
      return( nil);
   }

   parser = [[[self alloc] initWithData:data
                               fileName:[url path]
                             searchPath:nil] autorelease];
   return( parser);
}


+ (MulleScionParser *) parserWithUTF8String:(char *) s
                                 searchPath:(NSArray *) searchPath
{
   NSData            *data;
   MulleScionParser  *parser;

   if( ! s)
   {
      [self release];
      return( nil);
   }

   data = [[[NSData alloc] initWithBytesNoCopy:s
                                        length:strlen( s)
                                  freeWhenDone:NO] autorelease];
   parser = [[[self alloc] initWithData:data
                               fileName:@"unknown.scion"
                             searchPath:searchPath ? searchPath : @[ @"."]] autorelease];
   return( parser);
}


+ (MulleScionParser *) parserWithContentsOfFile:(NSString *) path
                                     searchPath:(NSArray *) searchPath
{
   NSData            *data;
   MulleScionParser  *parser;

   data = [NSData dataWithContentsOfFile:path];
   if( ! data)
   {
      NSLog( @"Could not open template file \"%@\" (%@)", path,
               [[NSFileManager defaultManager] currentDirectoryPath]);
      return( nil);
   }

   parser = [[[self alloc] initWithData:data
                               fileName:path
                             searchPath:searchPath] autorelease];
   return( parser);
}


#if DEBUG
- (id) autorelease
{
   return( [super autorelease]);
}
#endif


- (BOOL) debugFilePaths
{
   return( debugFilePaths_);
}


- (NSString *) fileName
{
   return( fileName_);
}


static void   _dump( MulleScionTemplate *self, NSString *path, NSString *blurb, SEL sel)
{
   NSFileHandle   *stream;
   NSData         *nl;
   NSData         *data;
   NSString       *s;

   stream = [NSFileHandle mulleErrorFileHandleWithFilename:path];
   if( ! stream)
   {
      NSLog( @"failed to create trace/dump file \"%@\"", path);
      return;
   }

   nl = [@"\n" dataUsingEncoding:NSUTF8StringEncoding];
   if( blurb)
   {
      data = [blurb dataUsingEncoding:NSUTF8StringEncoding];
      [stream writeData:data];
      [stream writeData:nl];
   }

   s    = [self performSelector:sel];
   data = [s dataUsingEncoding:NSUTF8StringEncoding];
   [stream writeData:data];
   [stream writeData:nl];

   if( blurb)
   {
      [stream writeData:nl];
      [stream writeData:nl];
   }
}


static void   dump( MulleScionTemplate *self, char *env, NSString *blurb, SEL sel)
{
   NSAutoreleasePool   *pool;
   char                *s;
   NSString            *path;

#ifndef DEBUG_DUMP
   s = getenv( env);
   if( ! s || ! *s)
      return;
#else
   s = "-";
#endif

   pool = [NSAutoreleasePool new];
   {
      path = [NSString stringWithCString:s];
      _dump( self, path, blurb, sel);
   }
   [pool release];
}


#define MULLE_SCION_DESCRIPTION_PRE_EXPAND  "MulleScionDescriptionPreBlockExpansion"
#define MULLE_SCION_DESCRIPTION_POST_EXPAND "MulleScionDescriptionPostBlockExpansion"
#define MULLE_SCION_DUMP_PRE_EXPAND         "MulleScionDumpPreBlockExpansion"
#define MULLE_SCION_DUMP_POST_EXPAND        "MulleScionDumpPostBlockExpansion"


- (MulleScionTemplate *) template
{
   MulleScionTemplate     *template;
   NSMutableDictionary    *blockTable;
   NSAutoreleasePool      *pool;

   pool       = [NSAutoreleasePool new];
   blockTable = [NSMutableDictionary dictionary];
   template   = [self templateParsedWithBlockTable:blockTable];

   dump( template, MULLE_SCION_DUMP_PRE_EXPAND,
                   @"BEFORE BLOCK EXPANSION:",
                   @selector( dumpDescription));
   dump( template, MULLE_SCION_DESCRIPTION_PRE_EXPAND,
                   @"BEFORE BLOCK EXPANSION:",
                   @selector( templateDescription));

   [template expandBlocksUsingTable:blockTable];

   dump( template, MULLE_SCION_DUMP_POST_EXPAND,
                   @"AFTER BLOCK EXPANSION:",
                   @selector( dumpDescription));
   dump( template, MULLE_SCION_DESCRIPTION_POST_EXPAND,
                   @"AFTER BLOCK EXPANSION:",
                   @selector( templateDescription));

   [template retain];
   [pool release];

   return( [template autorelease]);
}


- (MulleScionTemplate *) templateParsedWithBlockTable:(NSMutableDictionary *) blockTable
{
   MulleScionTemplate       *template;
   NSAutoreleasePool        *pool;
   MulleScionParserTables   tables;

   pool = [NSAutoreleasePool new];

   tables.definitionTable = [NSMutableDictionary dictionary];
   tables.macroTable      = [NSMutableDictionary dictionary];
   tables.blockTable      = blockTable;
   tables.dependencyTable = nil;

   template = [[self templateParsedWithTables:&tables] retain];

   [pool release];

   return( [template autorelease]);
}


- (NSDictionary *) dependencyTable
{
   NSAutoreleasePool        *pool;
   MulleScionParserTables   tables;
   MulleScionTemplate       *root;

   tables.dependencyTable = [NSMutableDictionary dictionary];

   pool = [NSAutoreleasePool new];

   tables.definitionTable = [NSMutableDictionary dictionary];
   tables.macroTable      = [NSMutableDictionary dictionary];
   tables.blockTable      = [NSMutableDictionary dictionary];

   root = [[[MulleScionTemplate alloc] initWithFilename:fileName_] autorelease];

   [self parseData:data_
    intoRootObject:root
            tables:&tables
      ignoreErrors:YES];

   [pool release];

   return( tables.dependencyTable);
}


static NSString   *output_line( NSString *fileName,
                                NSString *line,
                                NSUInteger lineNumber,
                                NSUInteger columnNumber,
                                NSString *reason)
{
   NSString         *s;
   NSMutableArray   *array;
   NSUInteger       lineNumberLength;

   array = [NSMutableArray array];
   s     = [NSString stringWithFormat:@"%@,%tu: %@",
                                      fileName ? fileName : @"template",
                                      lineNumber,
                                      reason];
   [array addObject:s];
   if( line)
   {
      s = [NSString stringWithFormat:@"   %tu | %@", lineNumber, line];
      [array addObject:s];

      if( columnNumber != (NSUInteger) -1)
      {
         // # is strlen... then
         // #s - (#"   " + #" | " + #line) ->  #lineNumber
         lineNumberLength = [s length] - 3 - 3 - [line length];
         s = [NSString stringWithFormat:@"   %*s | %*s%c",
                                        (int) lineNumberLength, "",
                                        (int) columnNumber, "",
                                        '^'];
         [array addObject:s];
      }
   }
   return( [array componentsJoinedByString:@"\n"]);
}


- (void)   parser:(void *) parser
          warning:(NSString *) reason
         fileName:(NSString *) fileName
             line:(NSString *) line
       lineNumber:(NSUInteger) lineNumber
     columnNumber:(NSUInteger) columnNumber
{
   NSLog( @"warning: %@", output_line( fileName, line, lineNumber, columnNumber, reason));
}


- (void)   parser:(void *) parser
            error:(NSString *) reason
         fileName:(NSString *) fileName
             line:(NSString *) line
       lineNumber:(NSUInteger) lineNumber
     columnNumber:(NSUInteger) columnNumber
{
   [NSException raise:NSInvalidArgumentException
               format:@"%@",
                       output_line( fileName, line, lineNumber, columnNumber, reason)];
}


- (void) setSearchPath:(NSArray *) array
{
   [searchPath_ autorelease];
   searchPath_ = [array copy];
}


- (NSArray *) searchPath
{
   return( searchPath_);
}

@end
