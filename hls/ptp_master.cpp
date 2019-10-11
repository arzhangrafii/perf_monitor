#include "hls_stream.h"
#include "ap_int.h"
#define sync_period 20

struct kernel_axis {
	ap_uint<64> data;
	ap_uint<8> dest;
	ap_uint<1> last;
	ap_uint<8> keep;
	ap_uint<8> id;
	ap_uint<40> user;
};

void ptp_master (
			ap_uint <64> current_time,
			hls::stream <kernel_axis> &packet_out,
			hls::stream <kernel_axis> packet_in,
			ap_uint <4> &state_out
		) {

#pragma HLS INTERFACE ap_ctrl_none port=return
#pragma HLS INTERFACE ap_none port=state_out
#pragma HLS resource core=AXI4Stream variable=packet_out
#pragma HLS DATA_PACK variable=packet_out
#pragma HLS resource core=AXI4Stream variable=packet_in
#pragma HLS DATA_PACK variable=packet_in

	static ap_uint<64> last_time = 0;
	kernel_axis packet_local;

	static enum {SYNC, DELAY_REQ} state = SYNC;

	static ap_uint<8> id_counter = 0;
	packet_local.dest = 1; //arbitrary for now
	packet_local.last = 1;
	packet_local.keep = 0xFF;
	packet_local.id = id_counter;
	packet_local.user = 0;

	id_counter++;

	state_out = state;

	if (!packet_out.full()) {
		switch(state) {
		case SYNC:
			if (current_time - last_time >= sync_period) { //time to sync clocks
				packet_local.data = current_time;
				packet_out.write(packet_local);
				state = DELAY_REQ;
			}
			break;
		case DELAY_REQ:
			if (!packet_in.empty()) { //wait for delay request
				packet_local = packet_in.read();
				if (packet_local.data == 1) //delay request is here!
					packet_out.write(packet_local); //send delay response (send back the same packet)
				last_time = current_time;
				state = SYNC;
			}
			break;
		}
	}
}

