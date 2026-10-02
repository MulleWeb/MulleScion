#ifdef __MULLE_OBJC__
# import <MulleScion/MulleScion.h>
# include <mulle-testallocator/mulle-testallocator.h>
#else
# import <Foundation/Foundation.h>
#endif
#include <stdio.h>
#include <stdlib.h>


//
// Methods taking or returning a C string ("char *") go through numberBuffer()
// on the argument side and through the return value switch on the other.
//
// Both used to be broken: numberBuffer rejected any argument that was not an
// NSValue (so an NSString could never become a char *) and the _C_CHARPTR
// return case read the characters out of the pointer itself instead of
// dereferencing it.
//
static void   test_utf8_template( char *template)
{
   NSString   *output;
   char       *s;

   output = [MulleScionTemplate descriptionWithUTF8Template:template
                                                 dataSource:(id <MulleScionDataSource>) [NSDictionary dictionary]];

   s = output ? (char *) [output UTF8String] : (char *) "<nil>";
   mulle_printf( "%s\n", s ? s : (char *) "<null>");
}


int   main( int argc, char *argv[])
{
#ifdef __MULLE_OBJC__
   if( mulle_objc_global_check_universe( __MULLE_OBJC_UNIVERSENAME__) !=
         mulle_objc_universe_is_ok)
      _exit( 1);
#endif

   // a "char *" return value must print the characters, not the pointer
   test_utf8_template( "{{ [@\"hello\" UTF8String] }}");

   // an NSString must be passable where a "char *" is expected
   test_utf8_template( "{{ [NSString stringWithUTF8String:@\"VfL\"] }}");

   return( 0);
}
