#include "hls_stream.h"
#include "ap_int.h"

struct gulf_axis {
	ap_uint<512> data;
	ap_uint<64> keep;
	ap_uint<16> dest;
	ap_uint<1> last;
};

void master_send (
		hls::stream <gulf_axis> &out_stream,
		ap_uint<64> time,
		ap_uint<16> num_flits,
		ap_uint<1> init
		) {
#pragma HLS INTERFACE ap_ctrl_none port=return
#pragma HLS resource core=AXI4Stream variable=out_stream //use this instead of INTERFACE (which is buggy)
#pragma HLS DATA_PACK variable=out_stream //concats the struct into one big block

	static ap_uint<16> cur_count = 0;
	gulf_axis flit_out;
	flit_out.data.range(511,496) = cur_count;
	//flit_out.data.range(496,433) = time;
	flit_out.data.range(431,0)= 0;
	flit_out.dest=0;
	//flit_out.keep=0xFF; //means all bytes are valid. each bit for every byte of TID
	flit_out.keep = 0xFFFFFFFFFFFFFFFF;
	if (!out_stream.full()) //checks if there's back pressure
	{
		switch (cur_count) {
		case 0:
			if (init == 1)
			{
				cur_count = 2;
			}
			break;
		case 1:
			if (init == 0)
			{
				cur_count = 0;
			}
			break;
		default:
			if (num_flits+2 == cur_count)
			{
				flit_out.last = 1;
				cur_count = 1;
			}
			else
			{
				flit_out.last = 0;
				cur_count ++;
			}
			flit_out.data.range(495,432) = time;
			out_stream.write(flit_out);
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
