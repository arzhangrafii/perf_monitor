#include "hls_stream.h"
#include "ap_int.h"
#define PACKET_OUT_PERIOD 4


struct gulf_axis {
	ap_uint<512> data;
	ap_uint<64> keep;
	ap_uint<16> dest;
	ap_uint<1> last;
	ap_uint<32> user; //to hold the remote_ip_tx
};

void packet_generator (
		hls::stream <gulf_axis> &out_stream,
		ap_uint<64> time,
		ap_uint<1> init,
		ap_uint<32> remote_ip_tx,
		ap_uint<16> remote_port_tx
		) {
#pragma HLS INTERFACE ap_ctrl_none port=return
#pragma HLS resource core=AXI4Stream variable=out_stream //use this instead of INTERFACE (which is buggy)
#pragma HLS DATA_PACK variable=out_stream //concats the struct into one big block

	static ap_uint <16> cur_count = 0;
	gulf_axis flit_out;
	flit_out.data.range(511,496) = cur_count;
	flit_out.data.range(431,0)= 0;
	flit_out.dest=remote_port_tx;
	flit_out.last = 1;
	flit_out.keep = 0xFFFFFFFFFFFFFFFF;
	flit_out.user = remote_ip_tx;

	if (init == 0) {
		cur_count = 0;
	}
	else if (!out_stream.full() && init == 1) {
		if (time%PACKET_OUT_PERIOD == 0) {
			flit_out.data.range(495,432) = time;
			out_stream.write(flit_out);
			cur_count++;
		}
	}
}
