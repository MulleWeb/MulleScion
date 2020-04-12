//
//  MulleScionNull.m
//  MulleScion
//
//  Created by Nat! on 02.03.13.
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


#import "MulleScionNull.h"

#import "MulleCommonObjCRuntime.h"


@implementation _MulleScionNull

id   MulleScionNull;
id   MulleScionZero;


MULLE_OBJC_DEPENDS_ON_LIBRARY( MulleObjCValueFoundation);


+ (void) load
{
   MulleScionNull = self;
   MulleScionZero = [[NSNumber alloc] initWithInt:0];
}


+ (id) allocWithZone:(NSZone *) zone
{
#ifdef DEBUG
   abort();
#endif
   return( [MulleScionNull retain]);
}


+ (BOOL) mulleScionIsEqual:(id) other
{
   if( [other isKindOfClass:[NSNumber class]])
      return( [MulleScionZero isEqualToNumber:other]);
   // because it's zero
   return( NO);
}


+ (NSComparisonResult) mulleScionCompare:(id) other
{
   if( self == other)
      return( NSOrderedSame);
   if( [other isKindOfClass:[NSNumber class]])
      return( [MulleScionZero compare:other]);
   // NSOrderedSame because it's zero
   return( NSOrderedSame);
}


+ (id) valueForUndefinedKey:(NSString *) key
{
   return( nil);
}


+ (NSString *) description
{
   return( @"nil");
}


+ (NSInteger)  integerValue
{
   return( 0);
}


+ (BOOL)  boolValue
{
   return( NO);
}


@end
