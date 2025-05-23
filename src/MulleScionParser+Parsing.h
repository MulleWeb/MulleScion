//
//  MulleScionParser+Parsing.h
//  MulleScion
//
//  Created by Nat! on 26.02.13.
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


@class MulleScionObject;


typedef struct
{
   __unsafe_unretained NSMutableDictionary   *blockTable;
   __unsafe_unretained NSMutableDictionary   *definitionTable;
   __unsafe_unretained NSMutableDictionary   *macroTable;
   __unsafe_unretained NSMutableDictionary   *dependencyTable;
} MulleScionParserTables;


@interface MulleScionParser( Parsing)

- (void) parseData:(NSData *) data
    intoRootObject:(MulleScionObject *) root
            tables:(MulleScionParserTables *) tables
      ignoreErrors:(BOOL) ignoreErrors;

- (MulleScionTemplate *) templateParsedWithTables:(MulleScionParserTables *) tables;

- (MulleScionTemplate *) templateWithContentsOfFile:(NSString *) fileName
                                             tables:(MulleScionParserTables *) tables
                                          converter:(SEL) converterSel
                                         searchPath:(NSArray *) searchPath
                                           optional:(BOOL) optional;

@end


typedef struct
{
   void                             *parser;
   __unsafe_unretained NSString     *fileName;
   NSUInteger                       lineNumber;
   NSUInteger                       columnNumber;
   __unsafe_unretained NSString     *message;
   __unsafe_unretained NSString     *line;
} parser_warning_info;

typedef parser_warning_info   parser_error_info;

