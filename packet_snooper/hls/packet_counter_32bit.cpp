#include "hls_stream.h"
#include "ap_int.h"

struct kernel_axis {
		ap_uint<32> data;
		ap_uint<1> last;
		ap_uint<4> keep;
	};

void packet_counter (
		hls::stream <kernel_axis> in_stream,
		hls::stream <kernel_axis> &number_of_flits,
		hls::stream <kernel_axis> &cycle_count,
		ap_uint <1> measure, //used to start and stop measurements
		ap_uint <32> &bandwidth,
		ap_uint <32> &packet_size,
		ap_uint <1> &packet_size_valid,
		ap_uint <32> &flit_bytes,
		ap_uint <1> &measure_prev
		//add Beta variable
					) {
#pragma HLS INTERFACE ap_none port=measure_prev
//#pragma HLS INTERFACE s_axilite port=measure
#pragma HLS INTERFACE ap_none port=flit_bytes
#pragma HLS INTERFACE ap_none port=packet_size
#pragma HLS INTERFACE ap_none port=packet_size_valid
#pragma HLS INTERFACE ap_ctrl_none port=return
#pragma HLS resource core=AXI4Stream variable=in_stream
#pragma HLS DATA_PACK variable=in_stream
#pragma HLS resource core=AXI4Stream variable=number_of_flits
#pragma HLS DATA_PACK variable=number_of_flits
#pragma HLS resource core=AXI4Stream variable=cycle_count
#pragma HLS DATA_PACK variable=cycle_count

	kernel_axis flit_temp;
	kernel_axis flit_temp_2;
	static ap_uint <32> counter = 0;
	static ap_uint <32> num_of_flits = 0;
	static ap_uint <32> bytes_in_flit = 0;
	static ap_uint <32> number_of_bytes = 0;
	static ap_uint <32> packet_size_reg = 0;
	static ap_uint <1> packet_size_valid_reg = 0;
	static ap_uint <32> bandwidth_reg;
	static ap_uint <32> bandwidth_prev;
	static ap_uint <4> flit_keep;
	static ap_uint <1> measure_old = measure;

	packet_size = packet_size_reg;
	packet_size_valid = packet_size_valid_reg;
	flit_bytes = bytes_in_flit;
	measure_prev = measure;

	//reset values on new measurement
	if (measure_old == 0 && measure == 1) {
		counter = 0;
		num_of_flits = 0;
	}

	flit_temp_2.keep = 0xF;
	flit_temp_2.last = 1;
	flit_temp_2.data = counter;
	//on the falling edge of the measure signal
	if (measure_old == 1 && measure == 0) {
		if (!cycle_count.full()) {
			cycle_count.write(flit_temp_2);
		}
	}

	//write the number of flits to the output
	flit_temp_2.data = num_of_flits;
	if (measure_old == 1 && measure == 0) {
		if (!number_of_flits.full()) {
			number_of_flits.write(flit_temp_2);
		}
	}


	//start measurement
	if (measure == 1) {
		counter++;

		//if in_stream is not empty and
		//read can be done, then valid and
		//ready are both high
		if (!in_stream.empty()) {
			flit_temp = in_stream.read();

			flit_keep = flit_temp.keep; //extract the keep side channel
			num_of_flits++; //increment the number of flits

			//create a mux to count # of 1s in the keep side channel
			switch (flit_keep) {
			case 0:
				bytes_in_flit = 0;
				break;
			case 1:
				bytes_in_flit = 1;
				break;
			case 3:
				bytes_in_flit = 2;
				break;
			case 7:
				bytes_in_flit = 3;
				break;
			case 15:
				bytes_in_flit = 4;
				break;
			case 14:
				bytes_in_flit = 3;
				break;
			case 12:
				bytes_in_flit = 2;
				break;
			case 8:
				bytes_in_flit = 1;
				break;
			}

			if (flit_temp.last == 1) {
				number_of_bytes += bytes_in_flit;
				packet_size_reg = number_of_bytes;
				number_of_bytes = 0;
				packet_size_valid_reg = 1;
			}
			else {
				number_of_bytes += bytes_in_flit;
				packet_size_valid_reg = 0;
			}
		} //end of measurement
	}
	measure_old = measure;
}
