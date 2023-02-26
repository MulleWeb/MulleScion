#ifndef env_convenience_h__
#define env_convenience_h__

static int   getenv_yes_no_default( char *name, int default_value)
{
   char   *s;

   s = getenv( name);
   if( ! s)
      return( default_value);

   switch( *s)
   {
   case 'f' :
   case 'F' :
   case 'n' :
   case 'N' :
   case '0' : return( 0);
   }

   return( 1);
}


static inline int  getenv_yes_no( char *name)
{
   return( getenv_yes_no_default( name, 0));
}

#endif
