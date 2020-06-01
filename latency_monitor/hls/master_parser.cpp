#include "hls_stream.h"
#include "ap_int.h"
#include "hls_math.h"

struct gulf_axis {
	ap_uint<512> data;
	ap_uint<64> keep;
	ap_uint<16> dest;
	ap_uint<1> last;
	ap_uint<32> user;
};

void master_parser(
	hls::stream <gulf_axis> in_stream,
	ap_uint<64> time,
	ap_uint<64> &time_sent, //the time packet was initially sent. for debug purposes
	ap_uint<64> &latency_round_trip,
	ap_uint<64> &latency
	)
{
#pragma HLS INTERFACE ap_ctrl_none port=return
#pragma HLS resource core=AXI4Stream variable=in_stream
#pragma HLS DATA_PACK variable=in_stream
#pragma HLS INTERFACE ap_none port=latency_round_trip
#pragma HLS INTERFACE ap_none port=latency
#pragma HLS INTERFACE ap_none port=time_sent

	static ap_uint<64> latency_rt_save = 0; //to force it to be a register
	static ap_uint<64> latency_save = 0;
	static ap_uint<64> packet_time_sent = 0;
	gulf_axis flit_in;
	
	latency_round_trip = latency_rt_save;
	latency = latency_save;
	time_sent = packet_time_sent;

	if(!in_stream.empty()) {
		flit_in = in_stream.read();
		packet_time_sent = flit_in.data.range(495,432);
		latency_rt_save = abs(packet_time_sent - time);
		latency_save = (abs(packet_time_sent - time))/2;
	}
	
}
