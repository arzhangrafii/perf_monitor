#include "hls_stream.h"
#include "ap_int.h"
#define sync_period 20

struct kernel_axis {
	ap_uint<64> data;
	ap_uint<8> dest;
	ap_uint<1> last;
	ap_uint<8> keep;
	ap_uint<40> valid;
};

void ptp_slave (
			ap_uint <64> current_time,
			hls::stream <kernel_axis> &packet_in,
			ap_uint <1> req_out,
			ap_uint <1> sync_in,
			ap_uint <1> delay_resp_in
		) {

	static ap_uint<64> new_time;
	kernel_axis packet_local;
	ap_uint<64> current_time;
	ap_uint<64> new_time;
	ap_uint<64> delay_req_start;
	ap_uint<64> network_time;

	req_out = 0;
	network_time = 0;

	static enum {IDLE, DELAY_REQ, DELAY_RESPONSE} state = IDLE;

	switch(state) {
	case IDLE:
		if (sync_in == 1)
			state = DELAY_REQ;
		break;
	case DELAY_REQ:
		if (!packet_in.empty())
			packet_local = packet_in.read();
		new_time = packet_local.data;

		//send delay_req
		req_out = 1;
		delay_req_start = current_time;
		if (delay_resp_in == 1)
			state = DELAY_RESPONSE;
		break;
	case DELAY_RESPONSE:
			req_out = 0;
			network_time = (current_time - delay_req_start)/2;
			new_time = current_time + network_time;
			state = IDLE;
	}


}
