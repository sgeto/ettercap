#if defined(DEBUG) && !defined(ETTERCAP_DEBUG_H)
#define ETTERCAP_DEBUG_H

EC_API_EXTERN FILE *debug_file;
EC_API_EXTERN void debug_init(void);
EC_API_EXTERN void debug_msg(const char *message, ...);

#if defined(DETAILED_DEBUG)
  EC_API_EXTERN FILE       *debug_out;
  EC_API_EXTERN const char *debug_fname;
  EC_API_EXTERN unsigned    debug_line;

  EC_API_EXTERN void debug_console_init (void);
  EC_API_EXTERN void debug_console (const char *message, ...);

  #define DEBUG_INIT()      debug_console_init()
  #define DEBUG_MSG(x, ...) do {                               \
                             debug_fname = __FILE__;           \
                             debug_line = __LINE__;            \
                             debug_console ("%s(%u): " x,      \
                                            __FILE__, __LINE__, ## __VA_ARGS__); \
                         } while (0)
#else
  #define DEBUG_INIT()      debug_init()
  #define DEBUG_MSG(x, ...) do {                                 \
     if (debug_file == NULL) {                                   \
        fprintf(stderr, "DEBUG: "x"\n", ## __VA_ARGS__ );        \
     } else                                                      \
        debug_msg(x, ## __VA_ARGS__ );                           \
  } while(0)
#endif

#endif /* DEBUG && !ETTERCAP_DEBUG_H */

/*
 * if DEBUG is not defined we expand the macros to null instructions...
 */

#ifndef DEBUG
   #define DEBUG_INIT()
   #define DEBUG_MSG(x, ...)
#endif

/* EOF */

// vim:ts=3:expandtab

