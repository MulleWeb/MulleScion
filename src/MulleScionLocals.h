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
#ifdef __has_include
# if __has_include( "NSMutableDictionary.h")
#  import "NSMutableDictionary.h"
# endif
#endif

#import "import.h"

//
// the only point of this construct is to be able to have readOnly variables
// maybe it was overkill to add this...
//
@protocol MulleScionLocals < NSObject, NSCopying>

- (void) setObject:(id) object
    forReadOnlyKey:(NSString *) key;
- (void) setObject:(id) object
            forKey:(NSString *) key;
- (id) objectForKey:(NSString *) key;
- (void) removeAllObjects;
- (void) removeObjectForKey:(NSString *) key;
- (void) removeObjectForReadOnlyKey:(NSString *) key;
- (id) valueForKeyPath:(NSString *) key;
- (id) takeValue:(id) value
      forKeyPath:(NSString *) key;

- (void) addEntriesFromLocals:(id <MulleScionLocals>) other;

@end


@interface NSMutableDictionary( MulleScionLocals) < MulleScionLocals>

// does not do readonly...
- (void) setObject:(id) object
    forReadOnlyKey:(NSString *) key;

// not supported on NSMutableDictionary, as locals don't enumerate
- (void) addEntriesFromLocals:(id <MulleScionLocals>) other;

@end


#import <MulleObjCContainerFoundation/_MulleObjCConcreteMutableDictionary.h>

//
// When based on NSObject, expectation is, that only MulleScionLocals protocol
// methods are used, though it is a NSMutableDictionary with respect to
// readOnly keys..
// Currently we subclass _MulleObjCConcreteMutableDictionary so that
// objectForKey: performance is identical to NSMutableDictionary, which was
// used previously instead
//
@interface MulleScionLocals : _MulleObjCConcreteMutableDictionary < MulleScionLocals>
{
//   NSMutableDictionary  *_dictionary;
   NSMutableSet         *_readOnlyKeys;
}

- (void) setObject:(id) object
    forReadOnlyKey:(NSString *) key;

@end


