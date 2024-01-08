//
//  MulleScionPrinter.m
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


#import "MulleScionPrinter.h"

#import "MulleScionLocals.h"
#import "MulleScionObjectModel.h"
#import "MulleScionObjectModel+Printing.h"
#import "MulleCommonObjCRuntime.h"



@implementation MulleScionPrinter

- (id) initWithDataSource:(id) dataSource
{
   // NSLog( @"<%@ %p lives>", MulleGetClass( self), self);

   if( ! dataSource)
   {
      [self release];
      return( nil);
   }
   dataSource_  = dataSource;
   [dataSource retain];

   return( self);
}


- (void) dealloc
{
   [dataSource_ release];
   [defaultLocals_ release];

   // Instruments apparently lies cold blooded :)
   //NSLog( @"<%@ %p is dead>", MulleGetClass( self), self);
   [super dealloc];
}


- (id <MulleScionLocals>) defaultLocalVariables
{
   return( defaultLocals_);
}


- (void) setDefaultLocalVariables:(id <MulleScionLocals>) dictionary
{
   [defaultLocals_ autorelease];
   defaultLocals_ = [dictionary copy];
}


- (void) addSingleLetterInstancesToLocalVariables:(id <MulleScionLocals>) locals
{
   char                   name[ 2];
   char                   c;
   SEL                    sel;
   id                     instance;
   Class                  class;
   mulle_objc_classid_t   classID;

   name[ 1] = 0;
   for( c = 'A'; c <= 'Z'; c++)
   {
      name[ 0] = c;
      // could use a static array for this really
      classID = mulle_objc_classid_from_string( name);
      class   = MulleObjCLookupClassByClassID( classID);
      if( ! class)
         continue;

      sel = @selector( objectWithMulleScionLocalVariables:dataSource:);
      if( ! [class respondsToSelector:sel])
         continue;
      instance = [class performSelector:sel
                             withObject:locals
                             withObject:dataSource_];
      if( ! instance)
      {
         mulle_fprintf( stderr, "Class %@ didn't give an instance for %@",
                                name,
                                NSStringFromSelector( sel));
         continue;
      }

      assert( [instance respondsToSelector:@selector( :)]);

      // make accessible through locals... this means you can't access the
      // class though anymore from script, as locals should have precedence
      [locals setObject:instance
         forReadOnlyKey:[NSString stringWithCString:name]];
   }
}


- (void) writeToOutput:(id <MulleScionOutput>) output
              template:(MulleScionTemplate *) template
{
   id <MulleScionLocals>   locals;
   MulleScionObject        *curr;
   extern char             MulleScionFrameworkVersion[];

   NSParameterAssert( [template isKindOfClass:[MulleScionTemplate class]]);

   @autoreleasepool
   {
      locals = [template localVariablesWithDefaultValues:[self defaultLocalVariables]];

      [locals setObject:output
                 forKey:MulleScionRenderOutputKey];
#if __MULLE_OBJC__
      [locals setObject:@"Mulle"
         forReadOnlyKey:MulleScionFoundationKey];
#else
      [locals setObject:@"Apple"
        forReadOnlyKey:MulleScionFoundationKey];
#endif
      [locals setObject:[NSString stringWithCString:MulleScionFrameworkVersion]
         forReadOnlyKey:MulleScionVersionKey];

      // look through single uppercase letter classes, try to find one which
      // responds to our method, if yes generate a lowercase letter instance and
      // plop it into locals

      NSParameterAssert( locals);  // could raise if Apple starts hating on nil

      [self addSingleLetterInstancesToLocalVariables:locals];

      for( curr = template; curr ;)
         curr = [curr renderInto:output
                  localVariables:locals
                      dataSource:dataSource_];

      // so now references to single class should be cut, so those
      // are free to die, which in turn can now release locals and
      // the dataSource_
      [locals removeAllObjects];
   }
}


- (NSString *) describeWithTemplate:(MulleScionTemplate *) template
{
   NSMutableString   *output;
   
   output = [NSMutableString stringWithCapacity:0x8000];
   [self writeToOutput:output
              template:template];
   return( output);
}

@end
