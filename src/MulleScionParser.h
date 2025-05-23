//
//  MulleScionParser.h
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


#import "import.h"


@class MulleScionTemplate;


@protocol MulleScionPreprocessor < MulleObjCThreadSafe>

- (NSData *) preprocessedData:(NSData *) data;

@end


@interface MulleScionParser : NSObject
{
   NSData                              *data_;
   NSString                            *fileName_;
   NSObject <MulleScionPreprocessor>   *preprocessor_;
   NSArray                             *searchPath_;
   BOOL                                debugFilePaths_;
}


+ (MulleScionParser *) parserWithContentsOfFile:(NSString *) fileName
                                     searchPath:(NSArray *) searchPath;
+ (MulleScionParser *) parserWithUTF8String:(char *) s
                                 searchPath:(NSArray *) searchPath;
+ (MulleScionParser *) parserWithContentsOfURL:(NSURL *) url;

- (id) initWithData:(NSData *) data
           fileName:(NSString *) fileName
         searchPath:(NSArray *) searchPath;

- (MulleScionTemplate *) template;
- (NSDictionary *) dependencyTable;

- (void) parser:(void *) parser
          error:(NSString *) reason
       fileName:(NSString *) fileName
           line:(NSString *) line
     lineNumber:(NSUInteger) lineNumber
    columnNumber:(NSUInteger) lineNumber;

- (void)   parser:(void *) parser
          warning:(NSString *) reason
         fileName:(NSString *) fileName
             line:(NSString *) line
       lineNumber:(NSUInteger) lineNumber
     columnNumber:(NSUInteger) lineNumber;

- (NSString *) fileName;

// Preprocessor support:
//
// The preprocessor will be called from the parser. So it must be
// installed before calling -template; The preprocessor will be
// inherited across includes, regardless of them being HTML files or
// not!
//
- (void) setPreprocessor:(NSObject <MulleScionPreprocessor> *) preprocessor;
- (NSObject <MulleScionPreprocessor> *) preprocessor;
- (NSData *) preprocessedData:(NSData *) data;

- (void) setSearchPath:(NSArray *) array;
- (NSArray *) searchPath;

- (BOOL) debugFilePaths;

@end
