#include "ap_int.h"
#include "ap_fixed.h"
#include "float.h"

#define MEASUREMENT_PERIOD 10

typedef ap_ufixed<32,16> ap_f;

void bandwidth_calculator (
		ap_f Beta,
		ap_uint <32> packet_size,
		ap_uint <1> packet_size_valid,
		ap_f &bandwidth_out,
		ap_f &internal_bw_out,
		ap_uint <64> &counter_out
					) {
	
#pragma HLS INTERFACE ap_ctrl_none port=return
#pragma HLS INTERFACE ap_none port=packet_size
#pragma HLS INTERFACE ap_none port=packet_size_valid
#pragma HLS INTERFACE ap_none port=bandwidth_out
#pragma HLS INTERFACE ap_none port=internal_bw_out
#pragma HLS INTERFACE ap_none port=counter_out
#pragma HLS INTERFACE ap_none port=Beta

	static ap_f bandwidth_old = 0;
	static ap_f bandwidth;
	static ap_f bandwidth_out_reg;
	static ap_uint <64> counter = 0;

	counter++;
	counter_out = counter;
	bandwidth_out = bandwidth_out_reg;
	internal_bw_out = bandwidth;

	if (packet_size_valid) {
		bandwidth = Beta*(bandwidth_old) + (ap_f(1.0)-Beta)*(ap_f(packet_size));
		bandwidth_old = bandwidth;
	}

	//output the bandwidth value
	if (counter == MEASUREMENT_PERIOD) {
		bandwidth_out_reg = bandwidth;
		counter = 0;
	}
}
