#ifdef __MULLE_OBJC__
# import <MulleScion/MulleScion.h>
# include <mulle-testallocator/mulle-testallocator.h>
#else
# import <Foundation/Foundation.h>
#endif
#include <stdio.h>
#include <stdlib.h>
#if defined(__unix__) || defined(__unix) || (defined(__APPLE__) && defined(__MACH__))
# include <unistd.h>
#endif

static void test_MulleScionConcat_noleak(void)
{
   @autoreleasepool
   {
      @try
      {
         MulleScionExpression *left = [MulleScionString newWithString:@"Hello" lineNumber:1];
         MulleScionExpression *right = [MulleScionString newWithString:@"World" lineNumber:1];
         [[MulleScionConcat newWithRetainedLeftExpression:left
                               retainedRightExpression:right
                                          lineNumber:1] autorelease];
      }
      @catch( NSException *localException)
      {
         fprintf( stderr, "Threw a %s exception\n", [[localException name] UTF8String]);
         _exit( 1);
      }
   }
}

int main(int argc, char *argv[])
{
#ifdef __MULLE_OBJC__
   // check that no classes are "stuck"
   if( mulle_objc_global_check_universe( __MULLE_OBJC_UNIVERSENAME__) !=
         mulle_objc_universe_is_ok)
      _exit( 1);
#endif

   test_MulleScionConcat_noleak();
   return 0;
}