/* Modified Linux module source code from /home/weixl/linux-2.6.22.6 */
#define NS_PROTOCOL "tcp_elastic.c"
#include "../ns-linux-c.h"
#include "../ns-linux-util.h"
#include "tcp_elastic.h"
#include <math.h>
#include <stdbool.h>
/* crude Elastic TCP built on top of TCP Vegas implementation of Stephen Hemminger */


/* TCP Elastic Congestion Control

This congestion control mechanism is based on the Elastic-TCP algorithm, 
which dynamically adjusts the congestion window based on round-trip time (RTT)
variations to optimize throughput and network stability.

Key aspects of this algorithm include:

* RTT Adaptation: The algorithm maintains and updates RTT values 
(RTT_base, RTT_current, and RTT_max) upon receiving ACKs to estimate network conditions accurately.

* Congestion Window Adjustment:
In the Slow Start phase, the congestion window (cwnd) grows linearly.
In Congestion Avoidance, the algorithm calculates the weighted window factor (WWF) 
using the ratio of RTT_max to RTT_current and updates cwnd accordingly.

* Multiplicative Decrease on Loss: When a duplicated ACK is detected, 
the algorithm applies multiplicative decrease to cwnd to handle congestion.

* Responsiveness to RTT Fluctuations: If the measured RTT is lower than RTT_base, 
the network conditions are improving, and RTT_base is updated. If RTT exceeds RTT_max, 
it signifies increased delay, and RTT_max is updated to track congestion trends.

*/


// Not keeping state

// static void elastic_enable(struct sock *sk)
// {
// 	const struct tcp_sock *tp = tcp_sk(sk);
// 	struct elastic *elastic = inet_csk_ca(sk);

// 	/* Begin taking elastic samples next time we send something. */
// 	elastic->doing_elastic_now = 1;

// 	/* Set the beginning of the next send window. */
// 	elastic->beg_snd_nxt = tp->snd_nxt;

// 	elastic->cntRTT = 0;
// 	elastic->minRTT = 0x7fffffff;
// }

// /* Stop taking Elastic samples for now. */
// static inline void elastic_disable(struct sock *sk)
// {
// 	struct elastic *elastic = inet_csk_ca(sk);
// 	elastic->doing_elastic_now = 0;
// }
// void tcp_elastic_state(struct sock *sk, u8 ca_state)
// {

// 	if (ca_state == TCP_CA_Open)
// 		elastic_enable(sk);
// 	else
// 		elastic_disable(sk);
// }
// EXPORT_SYMBOL_GPL(tcp_elastic_state);



void tcp_elastic_init(struct sock *sk)
{
	struct elastic *elastic = inet_csk_ca(sk);
	elastic->baseRTT = 0x7fffffff;
	elastic->maxRTT = 0;
	elastic->alt = true;
}
EXPORT_SYMBOL_GPL(tcp_elastic_init);

/* Do RTT sampling needed for ELastic.
 * Basically we:
 *   o update baseRTT, maxRTT w.r.t. current RTT
 */

void tcp_elastic_pkts_acked(struct sock *sk, u32 cnt, ktime_t last)
{
	cnt = cnt;

	struct elastic *elastic = inet_csk_ca(sk);
	u32 vrtt;

	if (ktime_equal(last, net_invalid_timestamp()))
		return;

	/* Never allow zero rtt or baseRTT */
	vrtt = ktime_to_us(net_timedelta(last)) + 1;

	/* Filter to find propagation delay: */
	if (vrtt < elastic->baseRTT)
		elastic->baseRTT = vrtt;

	if (vrtt > elastic->maxRTT)
		elastic->maxRTT = vrtt;

	elastic->minRTT = vrtt;//min(elastic->minRTT, vrtt);
	//printf("MIN RTT :%d \n",elastic->minRTT);
	//elastic->cntRTT++;
}
EXPORT_SYMBOL_GPL(tcp_elastic_pkts_acked);


/*
 * If the connection is idle and we are restarting,
 * then we don't want to do any Vegas calculations
 * until we get fresh RTT samples.  So when we
 * restart, we reset our Vegas state to a clean
 * slate. After we get acks for this flight of
 * packets, _then_ we can make Vegas calculations
 * again.
 */
void tcp_elastic_cwnd_event(struct sock *sk, enum tcp_ca_event event)
{
	if (event == CA_EVENT_CWND_RESTART ||
	    event == CA_EVENT_TX_START)
		tcp_elastic_init(sk);
}
EXPORT_SYMBOL_GPL(tcp_elastic_cwnd_event);

static void tcp_elastic_cong_avoid(struct sock *sk, u32 ack,
				 u32 seq_rtt, u32 in_flight, int flag)
{
	struct tcp_sock *tp = tcp_sk(sk);
	struct elastic *elastic = inet_csk_ca(sk);

	elastic->alt = !elastic->alt;
	if(!elastic->alt){
		return;
	}

	// if (!elastic->doing_elastic_now)
	// 	return tcp_reno_cong_avoid(sk, ack, seq_rtt, in_flight, flag);


	//if (after(ack, elastic->beg_snd_nxt)) {
		/* Do the Vegas once-per-RTT cwnd adjustment. */
		// u32 old_wnd, old_snd_cwnd;


		// /* Here old_wnd is essentially the window of data that was
		//  * sent during the previous RTT, and has all
		//  * been acknowledged in the course of the RTT that ended
		//  * with the ACK we just received. Likewise, old_snd_cwnd
		//  * is the cwnd during the previous RTT.
		//  */
		// old_wnd = (elastic->beg_snd_nxt - elastic->beg_snd_una) /
		// 	tp->mss_cache;
		// old_snd_cwnd = elastic->beg_snd_cwnd;

		// /* Save the extent of the current window so we can use this
		//  * at the end of the next RTT.
		//  */
		// elastic->beg_snd_una  = elastic->beg_snd_nxt;
		// elastic->beg_snd_nxt  = tp->snd_nxt;
		// elastic->beg_snd_cwnd = tp->snd_cwnd;

		/* We do the Vegas calculations only if we got enough RTT
		 * samples that we can be reasonably sure that we got
		 * at least one RTT sample that wasn't from a delayed ACK.
		 * If we only had 2 samples total,
		 * then that means we're getting only 1 ACK per RTT, which
		 * means they're almost certainly delayed ACKs.
		 * If  we have 3 samples, we should be OK.
		 */
		//if (elastic->cntRTT <= 2) {
			/* We don't have enough RTT samples to do the Vegas
			 * calculation, so we'll behave like Reno.
			 */
		//	tcp_reno_cong_avoid(sk, ack, seq_rtt, in_flight, flag);
		//} else{
		
			u32 rtt;

			/* We have enough RTT samples, so, using the Vegas
			 * algorithm, we determine if we should increase or
			 * decrease cwnd, and by how much.
			 */

			/* Pluck out the RTT we are using for the Vegas
			 * calculations. This is the min RTT seen during the
			 * last RTT. Taking the min filters out the effects
			 * of delayed ACKs, at the cost of noticing congestion
			 * a bit later.
			 */
			rtt = elastic->minRTT;

            double WWF = sqrt((elastic->maxRTT * tp->snd_cwnd) / rtt);
			//printf("WWF :%f \n",WWF);

			if (tp->snd_cwnd <= tp->snd_ssthresh) {
				/* Slow start.  */
				tcp_slow_start(tp);
				//tp->snd_cwnd = tp->snd_cwnd + 1; 

			} else {
				/* increment the ai counter */
                tp->snd_cwnd_cnt += ((int)WWF);

				/* increase cwnd using ai counter
				 */
				while (tp->snd_cwnd_cnt >= tp->snd_cwnd){
					tp->snd_cwnd_cnt -= tp->snd_cwnd;
					tp->snd_cwnd++;
				}

			}

			//if (tp->snd_cwnd < 2)
			//	tp->snd_cwnd = 2;
			// else if (tp->snd_cwnd > tp->snd_cwnd_clamp)
			// 	tp->snd_cwnd = tp->snd_cwnd_clamp;
		
		//}
		/* Wipe the slate clean for the next RTT. */
		//elastic->cntRTT = 0;
		//elastic->minRTT = 0x7fffffff;
	//}
	/* Use normal slow start */
	//else if (tp->snd_cwnd <= tp->snd_ssthresh)
		//tcp_slow_start(tp);

}

/* Extract info for Tcp socket info provided via netlink. */
void tcp_elastic_get_info(struct sock *sk, u32 ext, struct sk_buff *skb)
{
	sk = sk;
	ext = ext;
	skb = skb;
}
EXPORT_SYMBOL_GPL(tcp_elastic_get_info);

/* Slow start threshold is .875 times the congestion window (min 2) */
u32 tcp_elastic_ssthresh(struct sock *sk)
{
	const struct tcp_sock *tp = tcp_sk(sk);
	return max(tp->snd_cwnd * 0.875 - 1U, 2U);
}

EXPORT_SYMBOL_GPL(tcp_elastic_ssthresh);
/* Called after ssthresh adjustment */
u32 tcp_elastic_min_cwnd(const struct sock *sk)
{
	const struct tcp_sock *tp = tcp_sk(sk);

	return tp->snd_ssthresh + 1U;
}
EXPORT_SYMBOL_GPL(tcp_elastic_min_cwnd);

static struct tcp_congestion_ops tcp_elastic = {
	.flags		= TCP_CONG_RTT_STAMP,
	.init		= tcp_elastic_init,
	.ssthresh	= tcp_elastic_ssthresh,
	.cong_avoid	= tcp_elastic_cong_avoid,
	.min_cwnd	= tcp_elastic_min_cwnd,
	.pkts_acked	= tcp_elastic_pkts_acked,
	.cwnd_event	= tcp_elastic_cwnd_event,
	//.set_state	= tcp_elastic_state,
	.get_info	= tcp_elastic_get_info,

	.owner		= THIS_MODULE,
	.name		= "elastic",
};

static int __init tcp_elastic_register(void)
{
	BUILD_BUG_ON(sizeof(struct elastic) > ICSK_CA_PRIV_SIZE);
	tcp_register_congestion_control(&tcp_elastic);
	return 0;
}

static void __exit tcp_elastic_unregister(void)
{
	tcp_unregister_congestion_control(&tcp_elastic);
}

module_init(tcp_elastic_register);
module_exit(tcp_elastic_unregister);

MODULE_AUTHOR("");
MODULE_LICENSE("GPL");
MODULE_DESCRIPTION("TCP Elastic");
#undef NS_PROTOCOL
