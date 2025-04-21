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

static void test_MulleScionNot_noleak(void)
{
   @autoreleasepool
   {
      @try
      {
         MulleScionExpression *expr = [MulleScionNumber newWithNumber:@1 lineNumber:1];
         [[MulleScionNot newWithRetainedExpression:expr lineNumber:1] autorelease];
      }
      @catch( NSException *localException)
      {
         fprintf( stderr, "Threw a %s exception\n", [[localException name] UTF8String]);
         _exit( 1);
      }
   }
}

static void test_MulleScionParenthesis_noleak(void)
{
   @autoreleasepool
   {
      @try
      {
         MulleScionExpression *expr = [MulleScionNumber newWithNumber:@1 lineNumber:1];
         [[MulleScionParenthesis newWithRetainedExpression:expr lineNumber:1] autorelease];
      }
      @catch( NSException *localException)
      {
         fprintf( stderr, "Threw a %s exception\n", [[localException name] UTF8String]);
         _exit( 1);
      }
   }
}

static void test_MulleScionAnd_noleak(void)
{
   @autoreleasepool
   {
      @try
      {
         MulleScionExpression *left = [MulleScionNumber newWithNumber:@1 lineNumber:1];
         MulleScionExpression *right = [MulleScionNumber newWithNumber:@1 lineNumber:1];
         [[MulleScionAnd newWithRetainedLeftExpression:left
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

static void test_MulleScionOr_noleak(void)
{
   @autoreleasepool
   {
      @try
      {
         MulleScionExpression *left = [MulleScionNumber newWithNumber:@1 lineNumber:1];
         MulleScionExpression *right = [MulleScionNumber newWithNumber:@1 lineNumber:1];
         [[MulleScionOr newWithRetainedLeftExpression:left
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

static void test_MulleScionPipe_noleak(void)
{
   @autoreleasepool
   {
      @try
      {
         MulleScionExpression *left = [MulleScionString newWithString:@"test" lineNumber:1];
         MulleScionExpression *right = [MulleScionString newWithString:@"test" lineNumber:1];
         [[MulleScionPipe newWithRetainedLeftExpression:left
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

static void test_MulleScionIndexing_noleak(void)
{
   @autoreleasepool
   {
      @try
      {
         MulleScionExpression *left = [MulleScionArray newWithArray:@[@1] lineNumber:1];
         MulleScionExpression *right = [MulleScionNumber newWithNumber:@0 lineNumber:1];
         [[MulleScionIndexing newWithRetainedLeftExpression:left
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

   test_MulleScionNot_noleak();
   test_MulleScionParenthesis_noleak();
   test_MulleScionAnd_noleak();
   test_MulleScionOr_noleak();
   test_MulleScionPipe_noleak();
   test_MulleScionIndexing_noleak();

   return 0;
}