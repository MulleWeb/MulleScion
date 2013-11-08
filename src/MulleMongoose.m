//
//  MulleMongoose.m
//  mulle-mongoose
//
//  Created by Nat! on 02.03.13.
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

#ifndef DONT_HAVE_WEBSERVER

#import "MulleMongoose.h"

#import <Foundation/Foundation.h>
#import <MulleScion/MulleScion.h>
#import "MulleScionObjectModel+MulleMongoose.h"
#import "NSString+HTMLEscape.h"

#include <sys/stat.h>
#include <stdio.h>
#include <stdlib.h>
#include <signal.h>
#include <string.h>
#include <errno.h>
#include <limits.h>
#include <stddef.h>
#include <stdarg.h>
#include <ctype.h>

#include "mongoose.h"


/* this code is just for demo purposes */
#pragma mark -
#pragma mark ObjC Interfacing

static void   mulle_write_response( struct mg_connection *conn, void *buf, size_t len)
{
   NSString  *header;
   NSData    *utf8Header;
   
   header = [NSString stringWithFormat:@"HTTP/1.1 200 OK\r\n"
                    "Date: %@\r\n"
                    "Content-Type: text/html\r\n"
                    "Content-Length: %lu\r\n\r\n",
                    [NSDate date],
                    (unsigned long) len];
   
   utf8Header = [header dataUsingEncoding:NSUTF8StringEncoding];
   mg_write( conn, [utf8Header bytes], [utf8Header length]);
             
   if( strcmp(  mg_get_request_info( conn)->request_method, "HEAD") != 0)
      mg_write( conn, buf, len);
}


static int   _mulle_mongoose_begin_request( struct mg_connection *conn)
{
   NSURL                    *url;
   NSString                 *s;
   NSString                 *ext;
   NSString                 *query;
   NSDictionary             *plist;
   NSBundle                 *bundle;
   struct mg_request_info   *info;
   Class                    cls;
   MulleScionTemplate       *template;
   NSString                 *response;
   NSData                   *utf8Data;
   
   info = mg_get_request_info( conn);
   s    = [NSString stringWithCString:info->uri];
   if( [s hasPrefix:@"/"])
      s = [s substringFromIndex:1];
   s    = [s urlEscapedString];
   url  = [NSURL URLWithString:s];
   ext  = [[url lastPathComponent] pathExtension];
   if( ! [ext hasSuffix:@"scion"])
      return( 0);


#if DONT_LINK_AGAINST_MULLE_SCION_TEMPLATES
   bundle   = [NSBundle bundleWithPath:@"/Library/Frameworks/MulleScion.framework"];
   if( ! [bundle load])
      response = @"mulle scion templates not installed";
   else
#endif
   {
      cls      = NSClassFromString( @"MulleScionTemplate");
      plist    = [NSDictionary dictionaryWithContentsOfFile:@"properties.plist"];
      if( ! plist)
         response = @"properties.plist not found";
      else
      {
         query    = [NSString stringWithCString:info->query_string ? info->query_string : ""];
         //NS_DURING
         template = [[[cls alloc] initWithContentsOfFile:[url path]
                                           optionsString:query] autorelease];
         response = [template descriptionWithDataSource:plist
                                         localVariables:nil];
         //      NS_HANDLER
         //         response = [localException description];
         //      NS_ENDHANDLER
         if( ! response)
            response = @"template not found";
      }
   }

   utf8Data = [response dataUsingEncoding:NSUTF8StringEncoding];
   mulle_write_response( conn, (void *) [utf8Data bytes], [utf8Data length]);
   
   return( 1);
}


static int   mulle_mongoose_begin_request( struct mg_connection *conn)
{
   NSAutoreleasePool   *pool;
   int                 rval;
   NSData              *utf8Data;
   NSString            *string;
   
   pool   = [NSAutoreleasePool new];
NS_DURING
   rval   = _mulle_mongoose_begin_request( conn);
NS_HANDLER
   string = [[localException description] htmlEscapedString];
   string = [string stringByReplacingOccurrencesOfString:@"\n"
                                              withString:@"<BR>"];
   utf8Data = [string dataUsingEncoding:NSUTF8StringEncoding];
   mulle_write_response( conn, (void *) [utf8Data bytes], [utf8Data length]);
   rval = 1;
NS_ENDHANDLER
   [pool release];
   return( rval);
}


static void   mulle_mongoose_end_request( struct mg_connection *conn, int reply_status_code)
{
}


#pragma mark - 
#pragma mark mulle-scion setup

/*
 * stuff stolen from main.c of mongoose
 */
static struct   mg_context *ctx;      // Set by start_mongoose()
static int     exit_flag;
static char    server_name[ 40];        // Set by init_server_name()


static void init_server_name(void)
{
   snprintf(server_name, sizeof(server_name), "mulle-scion web server (mongoose v. %s)",
            mg_version());
}


static void signal_handler( int sig_num)
{
   exit_flag = sig_num;
}


static int log_message( const struct mg_connection *conn, const char *message)
{
   NSLog(@"%s", message);
   return( 0);
}


static void start_mongoose()
{
   struct mg_callbacks callbacks;
   static char *options[] =
   {
      "document_root",   "/tmp",
      "listening_ports", "127.0.0.1:18048",
      "num_threads", "1",
      NULL
   };
   /* Setup signal handler: quit on Ctrl-C */
   signal(SIGTERM, signal_handler);
   signal(SIGINT, signal_handler);
   
   /* Start Mongoose */
   memset(&callbacks, 0, sizeof(callbacks));
   callbacks.log_message  = &log_message;
   callbacks.begin_request = mulle_mongoose_begin_request;
   callbacks.end_request   = (void *) mulle_mongoose_end_request;

   [[NSFileManager defaultManager] changeCurrentDirectoryPath:@"/tmp"];
   
   ctx = mg_start( &callbacks, NULL, (void *) options);
   if (ctx == NULL)
   {
      NSLog( @"Failed to start mulle-scion web server.");
      exit( 1);
   }
}


void    mulle_mongoose_main()
{
   init_server_name();

   start_mongoose();

   NSLog(@"%s started on port(s) %s",
          server_name, mg_get_option(ctx, "listening_ports"));

   while( exit_flag == 0)
      sleep( 1);

   NSLog(@"Exiting on signal %d, waiting for all threads to finish...",
          exit_flag);
   mg_stop( ctx);
   
   NSLog( @"%s", " done.\n");
}

#endif
