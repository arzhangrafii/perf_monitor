#include "hls_stream.h"
#include "ap_int.h"
#define sync_period 1000

struct gulf_axis {
	ap_uint<512> data;
	ap_uint<64> keep;
	ap_uint<16> dest;
	ap_uint<1> last;
};


void ptp_master (
			ap_uint <64> current_time,
			hls::stream <gulf_axis> &packet_out,
			hls::stream <gulf_axis> packet_in,
			ap_uint <4> &state_out,
			ap_uint <1> init
		) {

#pragma HLS INTERFACE ap_ctrl_none port=return
#pragma HLS INTERFACE ap_none port=state_out
#pragma HLS resource core=AXI4Stream variable=packet_out
#pragma HLS DATA_PACK variable=packet_out
#pragma HLS resource core=AXI4Stream variable=packet_in
#pragma HLS DATA_PACK variable=packet_in


	static ap_uint<64> last_time = 0; //to ensure we synchronize clocks in the beginning
	gulf_axis packet_local;
	packet_local.data.range(511,448)= current_time;
	packet_local.data.range(447,0)= 0;

	static enum {SYNC, DELAY_REQ} state = SYNC;

	//static ap_uint<8> id_counter = 0;
	packet_local.dest = 7; //going to ptp_slave
	packet_local.last = 1;
	packet_local.keep = 0xFFFFFFFFFFFFFFFF;

	//id_counter++;

	state_out = state;

	if (init == 1) {
		if (!packet_out.full()) {
			switch(state) {
			case SYNC:
				if (current_time - last_time >= sync_period) { //time to sync clocks
					packet_local.data = current_time;
					packet_local.dest = 7;
					packet_local.last = 1;
					packet_out.write(packet_local);
					state = DELAY_REQ;
				}
				break;
			case DELAY_REQ:
				if (!packet_in.empty()) { //wait for delay request
					packet_local = packet_in.read();
					if (packet_local.data == 1) //delay request is here!
						packet_local.dest = 7;
						packet_local.last = 1;
						packet_out.write(packet_local); //send delay response (send back the same packet)
					last_time = current_time;
					state = SYNC;
				}
				break;
			}
		}
	}
}

