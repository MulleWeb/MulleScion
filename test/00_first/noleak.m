#import <MulleScion/MulleScion.h>

int  main( int argc, char *argv[])
{
#if defined( DEBUG) && defined( __MULLE_OBJC__)
   mulle_objc_global_check_universe( __MULLE_OBJC_UNIVERSENAME__);
#endif

   [MulleScionPrinter instance];

   return( 0);
}

