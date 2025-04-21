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

static void test_MulleScionElse_noleak(void)
{
   @autoreleasepool
   {
      @try
      {
         [[MulleScionElse newWithLineNumber:1] autorelease];
      }
      @catch( NSException *localException)
      {
         fprintf( stderr, "Threw a %s exception\n", [[localException name] UTF8String]);
         _exit( 1);
      }
   }
}

static void test_MulleScionEndIf_noleak(void)
{
   @autoreleasepool
   {
      @try
      {
         [[MulleScionEndIf newWithLineNumber:1] autorelease];
      }
      @catch( NSException *localException)
      {
         fprintf( stderr, "Threw a %s exception\n", [[localException name] UTF8String]);
         _exit( 1);
      }
   }
}

static void test_MulleScionEndWhile_noleak(void)
{
   @autoreleasepool
   {
      @try
      {
         [[MulleScionEndWhile newWithLineNumber:1] autorelease];
      }
      @catch( NSException *localException)
      {
         fprintf( stderr, "Threw a %s exception\n", [[localException name] UTF8String]);
         _exit( 1);
      }
   }
}

static void test_MulleScionEndBlock_noleak(void)
{
   @autoreleasepool
   {
      @try
      {
         [[MulleScionEndBlock newWithLineNumber:1] autorelease];
      }
      @catch( NSException *localException)
      {
         fprintf( stderr, "Threw a %s exception\n", [[localException name] UTF8String]);
         _exit( 1);
      }
   }
}

static void test_MulleScionParentBlock_noleak(void)
{
   @autoreleasepool
   {
      @try
      {
         [[MulleScionParentBlock newWithLineNumber:1] autorelease];
      }
      @catch( NSException *localException)
      {
         fprintf( stderr, "Threw a %s exception\n", [[localException name] UTF8String]);
         _exit( 1);
      }
   }
}

static void test_MulleScionEndFilter_noleak(void)
{
   @autoreleasepool
   {
      @try
      {
         [[MulleScionEndFilter newWithLineNumber:1] autorelease];
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

   test_MulleScionElse_noleak();
   test_MulleScionEndIf_noleak();
   test_MulleScionEndWhile_noleak();
   test_MulleScionEndBlock_noleak();
   test_MulleScionParentBlock_noleak();
   test_MulleScionEndFilter_noleak();

   return 0;
}