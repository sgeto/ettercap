
/* $Id: ec_proto.h,v 1.8 2003/10/27 20:54:43 alor Exp $ */

#ifndef EC_PROTO_H
#define EC_PROTO_H

#include <ec_inet.h>

/* interface layer types */
enum {
   IL_TYPE_ETH  = 0x01,   /* ethernet */
   IL_TYPE_TR   = 0x06,   /* token ring */
   IL_TYPE_FDDI = 0x0a,   /* fiber distributed data interface */
   IL_TYPE_WIFI = 0x69,   /* wireless */
};
   
/* link layer types */
enum {
   LL_TYPE_IP   = 0x0800,
   LL_TYPE_IP6  = 0x86DD,
   LL_TYPE_ARP  = 0x0806,
};

/* network layer types */
enum {
   NL_TYPE_ICMP  = 0x01,
   NL_TYPE_ICMP6 = 0x3a,
   NL_TYPE_TCP   = 0x06,
   NL_TYPE_UDP   = 0x11,
   NL_TYPE_OSPF  = 0x59,
   NL_TYPE_VRRP  = 0x70,
};

/* proto layer types */
enum {
   PL_DEFAULT  = 0x0000,
};

/* IPv6 options types */
/* NOTE: they may (but should not) conflict with network layer types!   */
/*       double check new definitions of either types.                  */

enum {
   LO6_TYPE_HBH = 0,   /* Hop-By-Hop */
   LO6_TYPE_RT  = 43,  /* Routing */
   LO6_TYPE_FR  = 44,  /* Fragment */
   LO6_TYPE_DST = 60,  /* Destination */
   LO6_TYPE_NO  = 59,  /* No Next Header */
};


/* TCP flags */
enum {
   TH_FIN = 0x01,
   TH_SYN = 0x02,
   TH_RST = 0x04,
   TH_PSH = 0x08,
   TH_ACK = 0x10,
   TH_URG = 0x20,
};

/* ICMP types */
enum {
   ICMP_ECHOREPLY       = 0,
   ICMP_DEST_UNREACH    = 3,
   ICMP_REDIRECT        = 5,
   ICMP_ECHO            = 8,
   ICMP_TIME_EXCEEDED   = 11,
   ICMP_NET_UNREACH     = 0,
   ICMP_HOST_UNREACH    = 1,
};

#endif

/* EOF */

// vim:ts=3:expandtab

