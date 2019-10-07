#include "hls_stream.h"
#include "ap_int.h"
#define num_flits 10

struct kernel_axis {
	ap_uint<64> data;
	ap_uint<8> dest;
	ap_uint<1> last;
	ap_uint<8> keep;
	ap_uint<8> id;
	ap_uint<40> user;
};

void master_send (
		hls::stream <kernel_axis> &out_stream,
		ap_uint<64> time
		) {
#pragma HLS INTERFACE ap_ctrl_none port=return
#pragma HLS resource core=AXI4Stream variable=out_stream //use this instead of INTERFACE (which is buggy)
#pragma HLS DATA_PACK variable=out_stream //concats the struct into one big block
	static ap_uint<8> cur_count = 0;
	kernel_axis flit_out;
	flit_out.id=cur_count;
	flit_out.dest=1;
	flit_out.keep=0xFF; //means all bytes are valid. each bit for every byte of TID
	flit_out.user=time;

	if (!out_stream.full()) //checks if there's back pressure
	{
		switch (cur_count) {
		case (num_flits-1):
			flit_out.last=1;
			cur_count++;
			out_stream.write(flit_out);
			break;
		case (num_flits):
			break;
		default:
			flit_out.last=0;
			out_stream.write(flit_out);
			cur_count++;
			break;
		}
	}
}
/*void kernal_all (
		hls::stream <kernel_axis> &in_stream,
		hls::stream <kernel_axis> &out_stream,
		ap_uint<64> time
		) {
#pragma HLS DATAFLOW //lets the functions run simultaneously
#pragma HLS INTERFACE ap_ctrl_none port=return
#pragma HLS resource core=AXI4Stream variable=out_stream //use this instead of INTERFACE (which is buggy)
#pragma HLS DATA_PACK variable=out_stream //concats the struct into one big block
#pragma HLS resource core=AXI4Stream variable=in_stream
#pragma HLS DATA_PACK variable=in_stream
	kernel_receive(in_stream,time);
	kernel_send(out_stream,time);
}*/
