#include "hls_stream.h"
#include "ap_int.h"

struct kernel_axis {
	ap_uint<64> data;
	ap_uint<8> dest;
	ap_uint<1> last;
	ap_uint<8> keep;
	ap_uint<8> id;
	ap_uint<40> user;
};


void master_receive(
	hls::stream <kernel_axis> &in_stream,
	ap_uint<64> time
	)
{
#pragma HLS INTERFACE ap_ctrl_none port=return
#pragma HLS resource core=AXI4Stream variable=in_stream
#pragma HLS DATA_PACK variable=in_stream

	kernel_axis flit_in;

	if(!in_stream.empty()) {
		flit_in = in_stream.read();
	}
}
