#include "hls_stream.h"
#include "ap_int.h"
#include "hls_math.h"

using namespace std;

	struct kernel_axis {
		ap_uint<32> data;
		ap_uint<1> last;
		ap_uint<4> keep;
	};

void packet_sink (
		hls::stream <kernel_axis> in_stream
		) {

#pragma HLS INTERFACE ap_ctrl_none port=return
#pragma HLS resource core=AXI4Stream variable=in_stream
#pragma HLS DATA_PACK variable=in_stream


	kernel_axis flit_temp;

	if (!in_stream.empty())
		flit_temp = in_stream.read();
}
