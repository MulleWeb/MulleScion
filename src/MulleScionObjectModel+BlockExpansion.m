//
//  MulleScionObjectModel+BlockExpansion.m
//  MulleScion
//
//  Created by Nat! on 01.03.13.
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

#import "MulleScionObjectModel+BlockExpansion.h"

#import "MulleScionObjectModel+NSCoding.h"


@implementation MulleScionObject( BlockExpansion)

- (MulleScionObject *) nextOwnerOfBlockCommand
{
   MulleScionObject  *curr;

   for( curr = self; curr; curr = curr->next_)
      if( [curr->next_ isBlockType])
         break;
   return( curr);
}


- (MulleScionObject *) ownerOfBlockWithIdentifier:(NSString *) identifier
{
   MulleScionObject  *curr;

   for( curr = self; curr; curr = curr->next_)
      if( [curr->next_ isBlock])
         if( [identifier isEqualToString:[(MulleScionBlock *) curr->next_ identifier]])
            break;
   return( curr);
}


// replacement must be a copy
- (MulleScionBlock *) replaceOwnedBlockWithBlock:(MulleScionBlock *) NS_CONSUMED replacement
{
   MulleScionBlock    *block;
   MulleScionObject   *endBlock;
   MulleScionObject   *endReplacement;

   NSParameterAssert( [replacement isBlock]);
   NSParameterAssert( [self->next_ isBlock]);

   endReplacement = [replacement tail];
   block          = (MulleScionBlock *) self->next_;
   endBlock       = [block terminateToEnd:block->next_];

   NSParameterAssert( [block isBlock]);
   NSParameterAssert( [endBlock isEndBlock]);
   NSParameterAssert( [endReplacement isEndBlock]);

   self->next_           = replacement;
   endReplacement->next_ = endBlock->next_;
   endBlock->next_       = nil;

   [block autorelease];

   return( block);
}

@end


@implementation MulleScionTemplate (BlockExpansion)

- (void) expandBlocksUsingTable:(NSDictionary *) table
{
   NSString           *identifier;
   MulleScionBlock    *block;
   MulleScionObject   *tail;
   MulleScionObject   *owner;
   MulleScionBlock    *chain;
   MulleScionBlock    *oldChain;
   NSMutableArray     *stack;
   NSMutableArray     *chainStack;
   NSAutoreleasePool  *pool;
   NSUInteger         *level;

   pool  = [NSAutoreleasePool new];
   {
      stack      = [NSMutableArray array];
      chainStack = [NSMutableArray array];

      oldChain = nil;
      owner    = self;
      while( (owner = [owner nextOwnerOfBlockCommand]))
      {
         block = (MulleScionBlock *) owner->next_;

         if( [block isEndBlock])
         {
            if( [stack count] == 0)
               [NSException raise:NSInvalidArgumentException
                           format:@"%ld: stray endblock misses a preceeding block",
                (long) [block lineNumber]];

            oldChain = [chainStack mulleRemoveLastObject];
            [stack removeLastObject];
            owner = block;
            continue;
         }

         if( [block isParentBlock])
         {
            if( [stack count] == 0)
               [NSException raise:NSInvalidArgumentException
                           format:@"%ld: stray parent() call misses a preceeding block",
                (long) [block lineNumber]];

            // get rid of block
            owner->next_ = block->next_;
            block->next_ = nil;
            [block autorelease];

            if( oldChain)
            {
               chain = [oldChain copyWithZone:NULL];
               tail  = [chain tail];

               // problem is though, we are reexpanding here
               // we don't want to "rehit" the block though, but
               // we got then a stray EndBlock coming up...
               tail->next_         = owner->next_;
               owner->next_        = chain;

               // so skip BlockStart
               owner = chain->next_;

               // and fake up something on the stack for endBlock pop
               [chainStack addObject:[chainStack lastObject]];
               [stack addObject:[stack lastObject]];
            }
            // stay with owner
            continue;
         }

         // walking through our list we found a block, check that we haven't
         // done it yet (how anyway ?)
         identifier = [block identifier];
         if( [stack containsObject:identifier])
            [NSException raise:NSInvalidArgumentException
                        format:@"%ld: block \"%@\" has already been expanded by (%@)",
             (long) [block lineNumber], identifier, [stack componentsJoinedByString:@", "]];
         [stack addObject:identifier];

         // get the overriding block from the table, if any
         chain = [table objectForKey:identifier];
         if( ! chain)
         {
            owner = block;
            continue;
         }

         //
         // for the parent() call we remember the chain that we are replacing
         // so we can put it back in
         //
         chain    = [chain copyWithZone:NULL];
         oldChain = [owner replaceOwnedBlockWithBlock:chain];
         [chainStack addObject:oldChain];

         owner    = chain;
      }
   }
   [pool release];
}

@end
