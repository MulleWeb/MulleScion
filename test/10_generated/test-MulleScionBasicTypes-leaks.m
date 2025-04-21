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

static void test_MulleScionPlainText_noleak(void)
{
   @autoreleasepool
   {
      @try
      {
         [[MulleScionPlainText newWithRetainedString:[@"test" copy] lineNumber:1] autorelease];
      }
      @catch( NSException *localException)
      {
         fprintf( stderr, "Threw a %s exception\n", [[localException name] UTF8String]);
         _exit( 1);
      }
   }
}

static void test_MulleScionSelector_noleak(void)
{
   @autoreleasepool
   {
      @try
      {
         [[MulleScionSelector newWithString:@"test" lineNumber:1] autorelease];
      }
      @catch( NSException *localException)
      {
         fprintf( stderr, "Threw a %s exception\n", [[localException name] UTF8String]);
         _exit( 1);
      }
   }
}

static void test_MulleScionDictionary_noleak(void)
{
   @autoreleasepool
   {
      @try
      {
         NSDictionary *dict = @{@"key": @"value"};
         [[MulleScionDictionary newWithDictionary:dict lineNumber:1] autorelease];
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

   test_MulleScionPlainText_noleak();
   test_MulleScionSelector_noleak();
   test_MulleScionDictionary_noleak();

   return 0;
}