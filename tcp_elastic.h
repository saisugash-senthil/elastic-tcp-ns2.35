#include <stdbool.h>
/*
 * Elastic TCP congestion control interface
 */
#ifndef __TCP_ELASTIC_H
#define __TCP_ELASTIC_H 1

/* Elastic variables */
struct elastic {
    //u32	beg_snd_nxt;	/* right edge during last RTT */
    //u32	beg_snd_una;	/* left edge  during last RTT */
    //u32	beg_snd_cwnd;	/* saves the size of the cwnd */
    //u8	doing_elastic_now;/* if true, do elastic for this RTT */
    //u16	cntRTT;		/* # of RTTs measured within last RTT */
    u32	minRTT;		/* RTT measured within last RTT (in usec) */
    u32	baseRTT;	/* the min of all Elastic RTT measurements seen (in usec) */
    u32 maxRTT;		/* the max of all Elastic RTT measurements seen (in usec) */
    bool alt;       /* updates every other ack*/
};

extern void tcp_elastic_init(struct sock *sk);
extern void tcp_elastic_state(struct sock *sk, u8 ca_state);
extern void tcp_elastic_pkts_acked(struct sock *sk, u32 cnt, ktime_t last);
extern void tcp_elastic_cwnd_event(struct sock *sk, enum tcp_ca_event event);
extern void tcp_elastic_get_info(struct sock *sk, u32 ext, struct sk_buff *skb);

#endif	/* __TCP_ELASTIC_H */
