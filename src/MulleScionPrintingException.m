//
//  MulleScionPrintingException.m
//  MulleScion
//
//  Created by Nat! on 27.02.13.
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
#import "MulleScionPrintingException.h"

#import "MulleScionObjectModel+Printing.h"
#import "MulleScionNull.h"
#import "MulleScionLocals.h"


void  MULLE_NO_RETURN   MulleScionPrintingException( NSString *exceptionName, id <MulleScionLocals> locals, NSString *format, ...)
{
   va_list        args;
   NSString       *s;

   NSCParameterAssert( [exceptionName isKindOfClass:[NSString class]]);
   NSCParameterAssert( [locals conformsToProtocol:@protocol( MulleScionLocals)]);
   NSCParameterAssert( [format isKindOfClass:[NSString class]]);

   va_start( args, format);

   s = [[[NSString alloc] initWithFormat:format
                               arguments:args] autorelease];

   va_end( args);

   [NSException raise:exceptionName
               format:@"%@ %@: %@",
    [locals valueForKeyPath:MulleScionCurrentFileKey],
    [locals valueForKeyPath:MulleScionCurrentLineKey],
    s];
   abort();
}


void  MulleScionPrintingValidateArgumentCount( NSArray *arguments, NSUInteger n,  id <MulleScionLocals> locals)
{
   NSUInteger   count;

   count = [arguments count];
   if( count == n)
      return;

   MulleScionPrintingException( NSInvalidArgumentException, locals,
                               @"%@ expects %ld arguments (got %ld)",
                               [locals valueForKeyPath:MulleScionCurrentFunctionKey],
                               (long) n,
                               (long) count,
                               locals);
}


id   MulleScionPrintingValidatedArgument( NSArray *arguments, NSUInteger i,  Class cls, id <MulleScionLocals> locals)
{
   id   value;

   value = [arguments objectAtIndex:i];
   if( value == MulleScionNull)
      return( nil);

   if( ! cls || [value isKindOfClass:cls])
      return( value);

   MulleScionPrintingException( NSInvalidArgumentException, locals,
                               @"%@ expects a %@ as argument #%ld",
                               [locals valueForKeyPath:MulleScionCurrentFunctionKey],
                               cls,
                               (long) i);
}
