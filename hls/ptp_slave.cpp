#include "hls_stream.h"
#include "ap_int.h"
#define sync_period 20

/*struct kernel_axis {
	ap_uint<64> data;
	ap_uint<8> dest;
	ap_uint<1> last;
	ap_uint<8> keep;
	ap_uint<8> id;
	ap_uint<40> user;
};*/

struct gulf_axis {
	ap_uint<512> data;
	ap_uint<64> keep;
	ap_uint<16> dest;
	ap_uint<1> last;
};

void ptp_slave (
			ap_uint <64> current_time,
			ap_uint <64> &new_time,
			ap_uint <1> &set_time,
			hls::stream <gulf_axis> packet_in,
			hls::stream <gulf_axis> &packet_out
			//ap_uint <4> &state_out,
			//ap_uint<64> &delay_req_time_out,
			//ap_uint<64> &network_time_out
		) {

#pragma HLS INTERFACE ap_ctrl_none port=return
#pragma HLS INTERFACE ap_none port=set_time
#pragma HLS INTERFACE ap_none port=new_time
//#pragma HLS INTERFACE ap_none port=state_out
//#pragma HLS INTERFACE ap_none port=delay_req_time_out
//#pragma HLS INTERFACE ap_none port=network_time_out
#pragma HLS resource core=AXI4Stream variable=packet_in
#pragma HLS DATA_PACK variable=packet_in
#pragma HLS resource core=AXI4Stream variable=packet_out
#pragma HLS DATA_PACK variable=packet_out

	gulf_axis packet_local;
	static ap_uint<64> delay_req_time;
	static ap_uint<64> network_time;
	
	packet_local.data.range(511,448)= current_time;
	packet_local.data.range(447,0)= 0;

	//network_time_out = network_time;
	//delay_req_time_out = delay_req_time;

	static enum {SYNC, DELAY_REQ, DELAY_RES} state = SYNC;

	static ap_uint<8> id_counter = 0;
	packet_local.dest = 1; //arbitrary for now
	packet_local.last = 1;
	packet_local.keep = 0xFF;
	//packet_local.id = id_counter;
	//packet_local.user = 0;

	//state_out = state;

	switch (state) {
	case SYNC:
		if (!packet_in.empty()) { //wait for new sync time
			packet_local = packet_in.read();
			new_time = packet_local.data;
			set_time = 1;
			state = DELAY_REQ;
		}
		else
			set_time = 0;
		break;
	case DELAY_REQ:
		set_time = 0;
		//send delay request
		if (!packet_out.full()) {
			packet_local.data = 1; //representing the delay req
			packet_out.write(packet_local);
			delay_req_time = current_time;
			state = DELAY_RES;
		}
		break;
	case DELAY_RES:
		if (!packet_in.empty()) { //wait for delay response
			packet_local = packet_in.read();
			if (packet_local.data == 1) { //delay response is here!
				network_time = (current_time - delay_req_time)/2;
				new_time = current_time + network_time;
				set_time = 1;
				state = SYNC;
			}
		}
		else
			set_time = 0;
		break;
	}
}
