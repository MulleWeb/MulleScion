//
//  MulleScionDataSourceProtocol.m
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


#import "MulleScionDataSourceProtocol.h"

#import "MulleScionLocals.h"
#import "MulleScionObjectModel+Printing.h"
#import "MulleScionPrintingException.h"
#import <MulleObjC/NSDebug.h>


@interface NSObject( OldMethods)

+ (void) poseAs:(Class) cls;

@end


//
// execution of arbitrary methods, can be a huge security hole if the template
// is writable for users
// Your dataSource can override this method and check if the keyPath is OK.
// If not, raise an exception otherwise call super.
//
@implementation NSObject( MulleScionDataSourceSupport)

- (id) mulleScionValueForKeyPath:(NSString *) keyPath
                  localVariables:(id <MulleScionLocals>) locals
{
   NSParameterAssert( [keyPath isKindOfClass:[NSString class]]);
   NSParameterAssert( [locals conformsToProtocol:@protocol( MulleScionLocals)]);

   return( [self valueForKeyPath:keyPath]);
}


- (id) mulleScionValueForKeyPath:(NSString *) keyPath
                          target:(id) target
                  localVariables:(id <MulleScionLocals>) locals
{
   NSParameterAssert( [keyPath isKindOfClass:[NSString class]]);
   NSParameterAssert( [locals conformsToProtocol:@protocol( MulleScionLocals)]);

   if( target == self)
      return( [self mulleScionValueForKeyPath:keyPath
                               localVariables:locals]);
   return( [target valueForKeyPath:keyPath]);
}

//
// you can protect local variables too, but why ?
//
- (id) mulleScionValueForKeyPath:(NSString *) keyPath
                inLocalVariables:(id <MulleScionLocals>) locals
{
   NSParameterAssert( [keyPath isKindOfClass:[NSString class]]);
   NSParameterAssert( [locals conformsToProtocol:@protocol( MulleScionLocals)]);

   return( [locals valueForKeyPath:keyPath]);
}


//
// here you can intercept all method calls
//
- (id) mulleScionMethodSignatureForSelector:(SEL) sel
                                     target:(id) target
{
   if( sel == @selector( poseAs:) || sel == @selector( poseAsClass:))
      [NSException raise:NSInvalidArgumentException
                  format:@"death to all posers :)"];

   return( [target methodSignatureForSelector:sel]);
}

//
// here you can intercept factory calls like [NSDate date]
// it's OK to return nil here, it's not sure that 's' is really
// the name of a class. It could be an unknown variable
//
- (Class) mulleScionClassFromString:(NSString *) s
{
   Class        cls;
   unichar      c;
   NSUInteger   length;

   cls = NSClassFromString( s);
   if( ! cls)
   {
      // produce a warning if s starts with uppercase letter,
      // which looks like a class...
      length = [s length];
      if( length)
      {
         c = [s characterAtIndex:0];
         if( NSDebugEnabled && c >= 'A' && c <= 'Z')
            NSLog( @"MulleScion did not find a class \"%@\"", s);
      }
   }
   return( cls);
}


- (id) mulleScionPipeString:(NSString *) s
              throughMethod:(NSString *) identifier
             localVariables:(id <MulleScionLocals>) locals
{
   SEL   sel;

   NSParameterAssert( ! s || [s isKindOfClass:[NSString class]]);
   NSParameterAssert( [identifier isKindOfClass:[NSString class]]);
   NSParameterAssert( [locals conformsToProtocol:@protocol( MulleScionLocals)]);

   if( ! [identifier length])
      MulleScionPrintingException( NSInvalidArgumentException, locals, @"empty pipe identifier is invalid");

   sel = NSSelectorFromString( identifier);
   if( ! [s respondsToSelector:sel] && s)
      MulleScionPrintingException( NSInvalidArgumentException, locals, @"NSString does not respond to %@",
                                  identifier);;

   // assume extra parameter is harmless...
   s = [s performSelector:sel
               withObject:locals];
   return( s);
}


- (id) mulleScionFunction:(NSString *) identifier
          evaledArguments:(NSArray *) evaledArguments
                arguments:(NSArray *) arguments
           localVariables:(id <MulleScionLocals>) locals
{
   id             (*f)( id, NSArray *, NSArray *, id <MulleScionLocals>);
   NSDictionary   *functions;

   NSParameterAssert( [identifier isKindOfClass:[NSString class]]);
   NSParameterAssert( ! evaledArguments || [evaledArguments isKindOfClass:[NSArray class]]);
   NSParameterAssert( ! arguments || [arguments isKindOfClass:[NSArray class]]);
   NSParameterAssert( [locals conformsToProtocol:@protocol( MulleScionLocals)]);

   [locals setObject:identifier
      forReadOnlyKey:MulleScionCurrentFunctionKey];

   functions = [locals objectForKey:MulleScionFunctionTableKey];
   f = [[functions objectForKey:identifier] pointerValue];
   if( f)
      return( (*f)( self, evaledArguments, arguments, locals));

   [NSException raise:NSInvalidArgumentException
               format:@"\"%@\" %@: unknown function \"%@\"",
    [locals valueForKeyPath:MulleScionCurrentFileKey],
    [locals valueForKeyPath:MulleScionCurrentLineKey],
    [locals valueForKeyPath:MulleScionCurrentFunctionKey]];

   return( nil);
}

@end
