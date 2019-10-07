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

void ptp_master (
			ap_uint <64> current_time,
			hls::stream <kernel_axis> &packet_out,
			ap_uint <1> sync_out,
			ap_uint <1> delay_resp_out,
			ap_uint <1> req_in
		) {

	static ap_uint<64> last_time = 0;
	static ap_uint<64> delay_req_time = 0;
	sync_out = 0;
	delay_resp_out = 0;
	kernel_axis packet_local;
	//kernel_axis empty_packet = {0,0,0,0,0};

	static enum {IDLE, SYNC, DELAY_REQ_WAIT, DELAY_RESPONSE} state = IDLE;

	packet_local.dest = 1; //arbitrary for now
	packet_local.last = 1;
	packet_local.keep = 0xFF;
	packet_local.valid = 1;


	if (!packet_out.full()) {
		switch(state) {
		case IDLE:
			packet_local.data = 0;
			if (current_time - last_time >= sync_period) { //time to sync clocks
				state = SYNC;
				sync_out = 1;
			}
			break;
		case SYNC:
			packet_local.data = current_time;
			packet_out.write(packet_local);
			state = DELAY_REQ_WAIT;
			sync_out = 0;
			break;
		case DELAY_REQ_WAIT:
			sync_out = 0;
			if (req_in == 1) {
				delay_req_time = current_time;
				delay_resp_out = 1;
				state = DELAY_RESPONSE;
			}
			break;
		case DELAY_RESPONSE:
			delay_resp_out = 0;
			packet_local.data = delay_req_time;
			packet_out.write(packet_local);
			state = IDLE;
			last_time = current_time;
			break;
		}
	}
}

