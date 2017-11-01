#ifndef ETTERCAP_THREADS_H
#define ETTERCAP_THREADS_H

#include <ec_stdint.h>
#include <pthread.h>

struct ec_thread {
   char *name;
   char *description;
   int  detached;
   pthread_t id;
};

/* a value to be used to return errors in fuctcions using pthread_t values */
pthread_t EC_PTHREAD_NULL;
#define EC_PTHREAD_SELF EC_PTHREAD_NULL

/*
 * In pthreads-win32 ver 2.8.1 (and later), 'pthread_t' is a structure:
 *
 *  typedef struct {
 *    void * p;                // Pointer to actual object
 *    unsigned int x;          // Extra information - reuse count etc
 *  } ptw32_handle_t;
 *
 * typedef ptw32_handle_t pthread_t;
 *
 * Hence this doesn't work with MSVC (only gcc):
 *   pthread_cancel ((pthread_t)id);   // cast of struct to struct is not allowed.
 *
 * So for Windows, this PTHREAD_ID() macro will return something unique
 * since 'id->p' comes from a calloc() call in ptw32_new.c.
 */
#if defined(OS_WINDOWS)
    #define PTHREAD_ID(id)     (*(pthread_t*)&(id))

    #if defined(__MINGW32__)
      /*
       * Not all MinGW-built pthreads have the 'pthread_getunique_np()' function.
       * So just ass-um-e the calloc()'ed address shifted down 4 bits makes a
       * unique pthread number.
       */
      #define PTHREAD_NUM(id)  ((*(unsigned long*)&(id)) >> 4)
    #else
      #define PTHREAD_NUM(id)  ((unsigned long) pthread_getunique_np (id))
    #endif
#else
    #define PTHREAD_ID(id)     (*(unsigned long*)&(id))
    #define PTHREAD_NUM(id)    PTHREAD_ID (id)
#endif

#define EC_THREAD_FUNC(x) void * x(void *args)
#define EC_THREAD_PARAM  args

EC_API_EXTERN char * ec_thread_getname(pthread_t id);
EC_API_EXTERN pthread_t ec_thread_getpid(char *name);
EC_API_EXTERN char * ec_thread_getdesc(pthread_t id);
EC_API_EXTERN void ec_thread_register_detached(pthread_t id, char *name, char *desc, int detached);
EC_API_EXTERN void ec_thread_register(pthread_t id, char *name, char *desc);
EC_API_EXTERN pthread_t ec_thread_new(char *name, char *desc, void *(*function)(void *), void *args);
EC_API_EXTERN pthread_t ec_thread_new_detached(char *name, char *desc, void *(*function)(void *), void *args, int detached);
EC_API_EXTERN void ec_thread_destroy(pthread_t id);
EC_API_EXTERN void ec_thread_init(void);
EC_API_EXTERN void ec_thread_kill_all(void);
EC_API_EXTERN void ec_thread_exit(void);

#define RETURN_IF_NOT_MAIN() do{ if (strcmp(ec_thread_getname(EC_PTHREAD_SELF), GBL_PROGRAM)) return; }while(0)

#define CANCELLATION_POINT()  pthread_testcancel()

#if defined(OS_DARWIN) || defined(OS_WINDOWS) || defined(OS_CYGWIN)
   /* XXX - darwin and windows are broken, pthread_join hangs up forever */
   #define BROKEN_PTHREAD_JOIN
#endif

/* Mac OS X does not have it, and some other systems define it as enum */
#ifndef HAVE_MUTEX_RECURSIVE_NP
#define PTHREAD_MUTEX_RECURSIVE_NP PTHREAD_MUTEX_RECURSIVE
#endif

#endif

/* EOF */

// vim:ts=3:expandtab

