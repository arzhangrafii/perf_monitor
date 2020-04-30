#include "hls_stream.h"
#include "ap_int.h"
#include "hls_math.h"

using namespace std;

struct gulf_axis {
	ap_uint<512> data;
	ap_uint<64> keep;
	ap_uint<16> dest;
	ap_uint<1> last;
};

/*	struct kernel_axis {
		ap_uint<64> data;
		ap_uint<8> dest;
		ap_uint<1> last;
		ap_uint<8> keep;
		ap_uint<8> id;
		ap_uint<40> user;
	};*/

void slave_FPGA (
		hls::stream <gulf_axis> &out_stream,
		hls::stream <gulf_axis> &in_stream,
		ap_uint <64> time,
		ap_uint <64> &latency,
		ap_uint <64> &time_sent //the time being read here, for debug purposes
		) {

#pragma HLS INTERFACE ap_ctrl_none port=return
#pragma HLS resource core=AXI4Stream variable=out_stream
#pragma HLS DATA_PACK variable=out_stream //concats the struct into one big block
#pragma HLS resource core=AXI4Stream variable=in_stream
#pragma HLS DATA_PACK variable=in_stream
#pragma HLS INTERFACE ap_none port=latency
#pragma HLS INTERFACE ap_none port=time_sent


	gulf_axis flit_temp;
	static ap_uint<64> latency_reg = 0;
	static ap_uint<64> packet_time_sent = 0;

	latency = latency_reg;
	time_sent = packet_time_sent;
	if (!in_stream.empty()) {
		flit_temp = in_stream.read();
		packet_time_sent = flit_temp.data.range(495,432);
		latency_reg = abs(packet_time_sent - time);

		if (!out_stream.full()) { //send packets back towards master only when new packets still arrive
			flit_temp.last = 1;
			flit_temp.dest = 3;
			out_stream.write(flit_temp);
		}
	}
}
