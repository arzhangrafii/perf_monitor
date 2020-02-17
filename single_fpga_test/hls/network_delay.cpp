#include "hls_stream.h"
#include "ap_int.h"
#define delay 3

struct kernel_axis {
	ap_uint<64> data;
	ap_uint<8> dest;
	ap_uint<1> last;
	ap_uint<8> keep;
	ap_uint<8> id;
	ap_uint<40> user;
};

void network_delay (
		hls::stream <kernel_axis> &to_slave,
		hls::stream <kernel_axis> &from_master,
		hls::stream <kernel_axis> &to_master,
		hls::stream <kernel_axis> &from_slave
		) {
#pragma HLS INTERFACE ap_ctrl_none port=return
#pragma HLS resource core=AXI4Stream variable=to_slave //use this instead of INTERFACE (which is buggy)
#pragma HLS DATA_PACK variable=to_slave //concats the struct into one big block
#pragma HLS resource core=AXI4Stream variable=from_master
#pragma HLS DATA_PACK variable=from_master
#pragma HLS resource core=AXI4Stream variable=to_master //use this instead of INTERFACE (which is buggy)
#pragma HLS DATA_PACK variable=to_master //concats the struct into one big block
#pragma HLS resource core=AXI4Stream variable=from_slave
#pragma HLS DATA_PACK variable=from_slave

	//static ap_uint<8> cur_count = 0;
	kernel_axis temp_s_to_m;
	kernel_axis temp_m_to_s;

	if (!from_master.empty())
		temp_m_to_s = from_master.read();
	if (!to_slave.full())
		to_slave.write(temp_m_to_s);

	if (!from_slave.empty())
		temp_s_to_m = from_slave.read();
	if (!to_master.full())
		to_master.write(temp_s_to_m);
}
