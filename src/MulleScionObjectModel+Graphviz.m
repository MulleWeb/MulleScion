//
//  MulleScionObjectModel+Graphviz.m
//  MulleScion
//
//  Copyright (c) 2013 Nat! - Mulle kybernetiK.
//  Copyright (c) 2013 Mulle kybernetiK. All rights reserved.
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
#import "MulleScionObjectModel.h"


@interface NSObject( MulleGraphvizSubclassing)

- (NSMutableDictionary *) mulleGraphvizAttributes;
- (NSMutableDictionary *) mulleGraphvizChildrenByName;
- (NSString *) mulleGraphvizDescription;
- (NSString *) mulleGraphvizName;

- (NSString *) mulleGraphvizHeaderBackgroundColorName;
- (NSString *) mulleGraphvizHeaderTextColorName;

@end


// a beginning, not the end
@implementation MulleScionObject( MulleGraphviz)

- (NSMutableDictionary *) mulleGraphvizChildrenByName
{
   NSMutableDictionary   *lut;
   
   lut = [super mulleGraphvizChildrenByName];
   if( next_)
      [lut setObject:[NSArray arrayWithObject:next_]
              forKey:@"next"];
   return( lut);
}


- (NSMutableDictionary *) _mulleGraphvizAttributes
{
   NSMutableDictionary   *dict;
   
   dict = [super mulleGraphvizAttributes];
   [dict setObject:[NSNumber numberWithUnsignedInteger:lineNumber_]
            forKey:@"lineNumber"];
   return( dict);
}


- (NSMutableDictionary *) mulleGraphvizAttributes
{
   return( [self _mulleGraphvizAttributes]);
}

@end



@implementation MulleScionValueObject( MulleGraphviz)

- (NSMutableDictionary *) mulleGraphvizAttributes
{
   NSMutableDictionary   *dict;
   
   dict = [super mulleGraphvizAttributes];
   [dict setObject:[value_ description]
            forKey:@"value"];
   return( dict);
}

@end


@implementation MulleScionBinaryOperatorExpression( Graphviz)

- (NSMutableDictionary *) mulleGraphvizAttributes
{
   return( [self _mulleGraphvizAttributes]);
}


- (NSMutableDictionary *) mulleGraphvizChildrenByName
{
   NSMutableDictionary   *lut;
   
   lut = [super mulleGraphvizChildrenByName];
   
   [lut setObject:[NSArray arrayWithObject:self->value_]
           forKey:@"left"];
   [lut setObject:[NSArray arrayWithObject:self->right_]
           forKey:@"right"];
   return( lut);
}

@end


@implementation MulleScionComparison( MulleGraphviz)

- (NSMutableDictionary *) mulleGraphvizAttributes
{
   NSMutableDictionary  *dict;
   
   dict = [super _mulleGraphvizAttributes];
   [dict setObject:[NSNumber numberWithInteger:self->comparison_]
            forKey:@"comparison"];
   return( dict);
}

@end

NSString  *MulleScionGraphviz = @"VfL Bochum 1848";  // keep linker happy ?
