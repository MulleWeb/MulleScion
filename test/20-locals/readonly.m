#import <MulleScion/MulleScion.h>


//
// noleak checks for alloc/dealloc/finalize
// and also load/unload initialize/deinitialize
// if the test environment sets MULLE_OBJC_PEDANTIC_EXIT
//
static void   test_set( id <MulleScionLocals> locals, NSString *key, id value)
{
   @try
   {
      [locals setObject:value
                 forKey:key];
   }
   @catch( NSException *localException)
   {
      mulle_printf( "test_set \"%@\" to \"%@\" threw a %@ exception\n", key, value, [localException name]);
   }
}


static void   test_set_readonly( id <MulleScionLocals> locals, NSString *key, id value)
{
   @try
   {
      [locals setObject:value
         forReadOnlyKey:key];
   }
   @catch( NSException *localException)
   {
      mulle_printf( "test_set \"%@\" to \"%@\" threw a %@ exception\n", key, value, [localException name]);
   }
}




int   main( int argc, char *argv[])
{
   MulleScionLocals   *locals;

   locals = [MulleScionLocals object];

   test_set( locals, @"a", @(1));
   test_set( locals, @"a", @(2));
   test_set_readonly( locals, @"a", @(3));
   test_set_readonly( locals, @"a", @(4));
   test_set( locals, @"a", @(5));

   return( 0);
}
