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

static void test_MulleScionUnaryOperatorExpression_noleak(void)
{
   @autoreleasepool
   {
      @try
      {
         MulleScionExpression *expr = [MulleScionNumber newWithNumber:@1 lineNumber:1];
         [[MulleScionUnaryOperatorExpression newWithRetainedExpression:expr lineNumber:1] autorelease];
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

   test_MulleScionUnaryOperatorExpression_noleak();
   return 0;
}