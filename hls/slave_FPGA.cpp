#include "hls_stream.h"
#include "ap_int.h"

using namespace std;

	struct kernel_axis {
		ap_uint<64> data;
		ap_uint<8> dest;
		ap_uint<1> last;
		ap_uint<8> keep;
		ap_uint<8> id;
		ap_uint<40> user;
	};

void slave_FPGA (
		hls::stream <kernel_axis> &out_stream,
		hls::stream <kernel_axis> &in_stream
		) {

#pragma HLS INTERFACE ap_ctrl_none port=return
#pragma HLS resource core=AXI4Stream variable=out_stream
#pragma HLS DATA_PACK variable=out_stream //concats the struct into one big block
#pragma HLS resource core=AXI4Stream variable=in_stream
#pragma HLS DATA_PACK variable=in_stream

	kernel_axis flit_temp;

	if (!in_stream.empty())
		flit_temp = in_stream.read();
	if (!out_stream.full())
		out_stream.write(flit_temp);

}
