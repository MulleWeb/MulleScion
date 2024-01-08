//
//  MulleScionLocals.m
//  MulleScion
//
//  Copyright (c) 2023 Nat! - Mulle kybernetiK.
//  All rights reserved.
//
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
#import "MulleScionLocals.h"

#import "import-private.h"



@implementation MulleScionLocals

- (instancetype) init
{
   self = [super init];

   _readOnlyKeys = [NSMutableSet new];
//   _dictionary   = [NSMutableDictionary new];
   return( self);
}


- (void) dealloc
{
//   [_dictionary release];
   [_readOnlyKeys release];
   [super dealloc];
}


- (id) copy
{
   MulleScionLocals   *copy;

   copy                = [self mutableCopy];
   copy->_readOnlyKeys = [[NSMutableSet alloc] initWithSet:_readOnlyKeys];
//   copy->_dictionary   = [[NSMutableDictionary alloc] initWithDictionary:_dictionary];
   return( copy);
}


#if 0
- (id) objectForKey:(NSString *) key
{
   return( [_dictionary objectForKey:key]);
}
#endif

- (void) setObject:(id) object
    forReadOnlyKey:(NSString *) key
{
   [_readOnlyKeys addObject:key];
//   [_dictionary setObject:object
//                   forKey:key];
   [super setObject:object
             forKey:key];
}


- (void) setObject:(id) object
            forKey:(NSString *) key
{
   if( [_readOnlyKeys member:key])
   {
      [NSException raise:NSInvalidArgumentException
                  format:@"\"%@\" is a readonly value", key];
   }
//   [_dictionary setObject:object
//                   forKey:key];
   [super setObject:object
             forKey:key];
}


- (void) removeAllObjects
{
//   [_dictionary removeAllObjects];
   [_readOnlyKeys removeAllObjects];
   [super removeAllObjects];
}

- (void) removeObjectForReadOnlyKey:(NSString *) key;
{
//   [_dictionary removeObjectForKey:key];
   [super removeObjectForKey:key];
}


- (void) removeObjectForKey:(NSString *) key
{
   if( [_readOnlyKeys member:key])
   {
      [NSException raise:NSInvalidArgumentException
                  format:@"\"%@\" is a readonly value", key];
   }
//   [_dictionary removeObjectForKey:key];
   [super removeObjectForKey:key];
}


- (void) addEntriesFromLocals:(id <MulleScionLocals>) other
{
   if( ! other)
      return;

   if( [other isKindOfClass:[MulleScionLocals class]])
   {
      [_readOnlyKeys unionSet:((MulleScionLocals *) other)->_readOnlyKeys];
      [self addEntriesFromDictionary:(NSDictionary *) other];
//      [self addEntriesFromDictionary:((MulleScionLocals *) other)->_dictionary];
      return;
   }

   if( [other isKindOfClass:[NSDictionary class]])
   {
      [self addEntriesFromDictionary:(NSDictionary *) other];
      return;
   }

   abort();
}

#if 0
- (id) valueForKeyPath:(NSString *) key
{
   return( [_dictionary valueForKeyPath:key]);
}


- (id) takeValue:(id) value
      forKeyPath:(NSString *) key
{
   return( [_dictionary takeValue:value
                       forKeyPath:key]);
}
#endif

@end


@implementation NSMutableDictionary( MulleScionLocals)

- (void) setObject:(id) object
    forReadOnlyKey:(NSString *) key
{
   [self setObject:object
            forKey:key];
}

- (void) removeObjectForReadOnlyKey:(NSString *) key
{
   return( [self removeObjectForKey:key]);
}


- (void) addEntriesFromLocals:(id <MulleScionLocals>) other
{
   // we can't do that
   abort();
}

@end

