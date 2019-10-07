#include <ap_int.h>

typedef long unsigned u64;

void asynchronous_timer (u64& time) {
#pragma HLS LATENCY max=0 min=0
#pragma HLS INTERFACE ap_none port=time
#pragma HLS INTERFACE ap_ctrl_none port=return

	static u64 count = 0;
	time = count;

	count++;
}
