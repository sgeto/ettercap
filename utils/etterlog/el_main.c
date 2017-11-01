/*
    etterlog -- log analyzer for ettercap log file

    Copyright (C) ALoR & NaGA

    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program; if not, write to the Free Software
    Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.

*/

#include <el.h>
#include <el_functions.h>
#include <ec_version.h>

#include <fcntl.h>
#include <assert.h>

#define GBL_FREE(x) do{ if (x != NULL) { free(x); x = NULL; } }while(0)

/* global options */
struct globals *gbls;

#ifdef _WIN32

#define DIM(array)  (sizeof(array) / sizeof(array[0]))

static CONSOLE_SCREEN_BUFFER_INFO console_info;

static HANDLE console_hnd = INVALID_HANDLE_VALUE;

static WORD color_map [7];
static BOOL color_okay = FALSE;

static void init_color (void)
{
  int  i;
  WORD bg;
  static BOOL done = FALSE;

  if (done)
     return;

  console_hnd = GetStdHandle (STD_OUTPUT_HANDLE);
  color_okay = (console_hnd != INVALID_HANDLE_VALUE &&
                GetConsoleScreenBufferInfo(console_hnd, &console_info) &&
                GetFileType(console_hnd) == FILE_TYPE_CHAR);
  if (!color_okay)
     return;

  for (i = 1; i < DIM(color_map); i++)
      color_map[i] = console_info.wAttributes;

  bg = console_info.wAttributes & ~7;

  color_map[0] = 0;
  color_map[1] = (bg + 3) | FOREGROUND_INTENSITY;  /* bright cyan */
  color_map[2] = (bg + 2) | FOREGROUND_INTENSITY;  /* bright green */
  color_map[3] = (bg + 6) | FOREGROUND_INTENSITY;  /* bright yellow */
  color_map[4] = (bg + 5) | FOREGROUND_INTENSITY;  /* bright magenta */
  color_map[5] = (bg + 4) | FOREGROUND_INTENSITY;  /* bright red */
  color_map[6] = (bg + 7) | FOREGROUND_INTENSITY;  /* bright white */
  done = TRUE;
}

/*
 * Set console foreground and optionally background color.
 * FG is in the low 4 bits.
 * BG is in the upper 4 bits of the BYTE.
 * If 'col == 0', set default console colour.
 */
static void C_set (WORD col)
{
  BYTE   fg, bg;
  WORD   attr;
  static WORD last_attr = (WORD)-1;

  if (col == 0)     /* restore to default colour */
  {
    attr = console_info.wAttributes;
    fg   = LOBYTE (attr);
    bg   = HIBYTE (attr);
  }
  else
  {
    attr = col;
    fg   = LOBYTE (attr);
    bg   = HIBYTE (attr);

    if (bg == (BYTE)-1)
         attr = console_info.wAttributes & ~7;
    else attr = bg << 4;

    attr |= fg;
  }

  if (attr != last_attr && color_okay)
     SetConsoleTextAttribute (console_hnd, attr);
  last_attr = attr;
}
#endif   /* _WIN32 */

/*******************************************/

int main(int argc, char *argv[])
{
   int ret;
   /* etterlog copyright */
   globals_alloc();
   fprintf(stdout, "\n" EC_COLOR_BOLD "%s %s" EC_COLOR_END " copyright %s %s\n\n",
                      GBL_PROGRAM, EC_VERSION, EC_COPYRIGHT, EC_AUTHORS);


   /* allocate the global target */
   SAFE_CALLOC(GBL_TARGET, 1, sizeof(struct target_env));

   /* initialize to all target */
   GBL_TARGET->all_mac = 1;
   GBL_TARGET->all_ip = 1;
#ifdef WITH_IPV6
   GBL_TARGET->all_ip6 = 1;
#endif
   GBL_TARGET->all_port = 1;

   /* getopt related parsing...  */
   parse_options(argc, argv);

   /* get the global header */
   ret = get_header(&GBL->hdr);
   if (ret == -E_INVALID)
      FATAL_ERROR("Invalid log file");

   fprintf(stderr, "Log file version    : %s\n", GBL->hdr.version);
   /* display the date. ec_ctime() has no newline at end. */
   fprintf(stderr, "Timestamp           : %s [%lu]\n", ec_ctime(&GBL->hdr.tv), GBL->hdr.tv.tv_usec);
   fprintf(stderr, "Type                : %s\n\n", (GBL->hdr.type == LOG_PACKET) ? "LOG_PACKET" : "LOG_INFO" );


   /* analyze the logfile */
   if (GBL_OPTIONS->analyze)
      analyze();

   /* rewind the log file and skip the global header */
   gzrewind(GBL_LOG_FD);
   get_header(&GBL->hdr);

   /* create the connection table (respecting the filters) */
   if (GBL_OPTIONS->connections)
      conn_table_create();

   /* display the connection table */
   if (GBL_OPTIONS->connections && !GBL_OPTIONS->decode)
      conn_table_display();

   /* extract files from the connections */
   if (GBL_OPTIONS->decode)
      conn_decode();

   /* not interested in the content... only analysis */
   if (GBL_OPTIONS->analyze || GBL_OPTIONS->connections)
      return 0;

   /* display the content of the logfile */
   display();

   globals_free();

   return 0;
}

/* ANSI color escapes */

void set_color(int color)
{
#ifdef OS_WINDOWS
   init_color();
   if (color > 30) {
     assert (color-30 < DIM(color_map));
     C_set (color_map[color-30]);
   }
   else
     C_set (0);
#else
   char str[8];

   sprintf(str, "\033[%dm", color);
   fflush(stdout);
   write(fileno(stdout), str, strlen(str));
#endif
}

/* reset the color to default */

void reset_color(void)
{
#ifdef OS_WINDOWS
   init_color();
   C_set (0);
#else
   fflush(stdout);
   write(fileno(stdout), EC_COLOR_END, 4);
#endif
}

void globals_alloc(void)
{

   SAFE_CALLOC(gbls, 1, sizeof(struct globals));
   SAFE_CALLOC(gbls->options, 1, sizeof(struct el_options));
   SAFE_CALLOC(gbls->regex, 1, sizeof(regex_t));
   SAFE_CALLOC(gbls->t, 1, sizeof(struct target_env));

   return;
}

void globals_free(void)
{
   SAFE_FREE(gbls->user);
   SAFE_FREE(gbls->logfile);
   SAFE_FREE(gbls->options);
   SAFE_FREE(gbls->regex);
   SAFE_FREE(gbls->t);

   SAFE_FREE(gbls);

   return;

}


// vim:ts=3:expandtab

