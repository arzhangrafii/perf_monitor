
################################################################
# This is a generated script based on design: perf_monitor_s
#
# Though there are limitations about the generated script,
# the main purpose of this utility is to make learning
# IP Integrator Tcl commands easier.
################################################################

namespace eval _tcl {
proc get_script_folder {} {
   set script_path [file normalize [info script]]
   set script_folder [file dirname $script_path]
   return $script_folder
}
}
variable script_folder
set script_folder [_tcl::get_script_folder]

################################################################
# Check if script is running in correct Vivado version.
################################################################
set scripts_vivado_version 2018.1
set current_vivado_version [version -short]

if { [string first $scripts_vivado_version $current_vivado_version] == -1 } {
   puts ""
   catch {common::send_msg_id "BD_TCL-109" "ERROR" "This script was generated using Vivado <$scripts_vivado_version> and is being run in <$current_vivado_version> of Vivado. Please run the script in Vivado <$scripts_vivado_version> then open the design in Vivado <$current_vivado_version>. Upgrade the design by running \"Tools => Report => Report IP Status...\", then run write_bd_tcl to create an updated script."}

   return 1
}

################################################################
# START
################################################################

# To test this script, run the following commands from Vivado Tcl console:
# source perf_monitor_s_script.tcl

# If there is no project opened, this script will create a
# project, but make sure you do not have an existing project
# <./myproj/project_1.xpr> in the current working folder.

set list_projs [get_projects -quiet]
if { $list_projs eq "" } {
   create_project project_1 myproj -part xczu19eg-ffvc1760-2-i
}


# CHANGE DESIGN NAME HERE
variable design_name
set design_name perf_monitor_s

# If you do not already have an existing IP Integrator design open,
# you can create a design using the following command:
#    create_bd_design $design_name

# Creating design if needed
set errMsg ""
set nRet 0

set cur_design [current_bd_design -quiet]
set list_cells [get_bd_cells -quiet]

if { ${design_name} eq "" } {
   # USE CASES:
   #    1) Design_name not set

   set errMsg "Please set the variable <design_name> to a non-empty value."
   set nRet 1

} elseif { ${cur_design} ne "" && ${list_cells} eq "" } {
   # USE CASES:
   #    2): Current design opened AND is empty AND names same.
   #    3): Current design opened AND is empty AND names diff; design_name NOT in project.
   #    4): Current design opened AND is empty AND names diff; design_name exists in project.

   if { $cur_design ne $design_name } {
      common::send_msg_id "BD_TCL-001" "INFO" "Changing value of <design_name> from <$design_name> to <$cur_design> since current design is empty."
      set design_name [get_property NAME $cur_design]
   }
   common::send_msg_id "BD_TCL-002" "INFO" "Constructing design in IPI design <$cur_design>..."

} elseif { ${cur_design} ne "" && $list_cells ne "" && $cur_design eq $design_name } {
   # USE CASES:
   #    5) Current design opened AND has components AND same names.

   set errMsg "Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 1
} elseif { [get_files -quiet ${design_name}.bd] ne "" } {
   # USE CASES: 
   #    6) Current opened design, has components, but diff names, design_name exists in project.
   #    7) No opened design, design_name exists in project.

   set errMsg "Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 2

} else {
   # USE CASES:
   #    8) No opened design, design_name not in project.
   #    9) Current opened design, has components, but diff names, design_name not in project.

   common::send_msg_id "BD_TCL-003" "INFO" "Currently there is no design <$design_name> in project, so creating one..."

   create_bd_design $design_name

   common::send_msg_id "BD_TCL-004" "INFO" "Making design <$design_name> as current_bd_design."
   current_bd_design $design_name

}

common::send_msg_id "BD_TCL-005" "INFO" "Currently the variable <design_name> is equal to \"$design_name\"."

if { $nRet != 0 } {
   catch {common::send_msg_id "BD_TCL-114" "ERROR" $errMsg}
   return $nRet
}

set bCheckIPsPassed 1
##################################################################
# CHECK IPs
##################################################################
set bCheckIPs 1
if { $bCheckIPs == 1 } {
   set list_check_ips "\ 
clarkshen.com:user:GULF_Stream:1.0\
xilinx.com:ip:axis_data_fifo:1.1\
xilinx.com:ip:axis_switch:1.1\
xilinx.com:ip:debug_bridge:3.0\
clarkshen.com:user:lbus_axis_converter:1.0\
xilinx.com:ip:proc_sys_reset:5.0\
xilinx.com:ip:util_ds_buf:2.1\
xilinx.com:ip:zynq_ultra_ps_e:3.2\
xilinx.com:ip:cmac_usplus:2.4\
xilinx.com:ip:xlconstant:1.1\
xilinx.com:hls:asynchronous_timer:1.0\
xilinx.com:hls:latency_axilite_bridge:1.0\
xilinx.com:hls:ptp_slave:1.0\
xilinx.com:hls:slave_FPGA:1.0\
"

   set list_ips_missing ""
   common::send_msg_id "BD_TCL-006" "INFO" "Checking if the following IPs exist in the project's IP catalog: $list_check_ips ."

   foreach ip_vlnv $list_check_ips {
      set ip_obj [get_ipdefs -all $ip_vlnv]
      if { $ip_obj eq "" } {
         lappend list_ips_missing $ip_vlnv
      }
   }

   if { $list_ips_missing ne "" } {
      catch {common::send_msg_id "BD_TCL-115" "ERROR" "The following IPs are not found in the IP Catalog:\n  $list_ips_missing\n\nResolution: Please add the repository containing the IP(s) to the project." }
      set bCheckIPsPassed 0
   }

}

if { $bCheckIPsPassed != 1 } {
  common::send_msg_id "BD_TCL-1003" "WARNING" "Will not continue with creation of design due to the error(s) above."
  return 3
}

##################################################################
# DESIGN PROCs
##################################################################


# Hierarchical cell: receiver_kernel
proc create_hier_cell_receiver_kernel { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_msg_id "BD_TCL-102" "ERROR" "create_hier_cell_receiver_kernel() - Empty argument(s)!"}
     return
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_msg_id "BD_TCL-100" "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_msg_id "BD_TCL-101" "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj

  # Create cell and set as current instance
  set hier_obj [create_bd_cell -type hier $nameHier]
  current_bd_instance $hier_obj

  # Create interface pins
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:axis_rtl:1.0 in_stream_V
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:axis_rtl:1.0 packet_in_V
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:axis_rtl:1.0 packet_out_V

  # Create pins
  create_bd_pin -dir I -type clk aclk
  create_bd_pin -dir I -type rst aresetn

  # Create instance: asynchronous_timer_0, and set properties
  set asynchronous_timer_0 [ create_bd_cell -type ip -vlnv xilinx.com:hls:asynchronous_timer:1.0 asynchronous_timer_0 ]

  # Create instance: latency_axilite_brid_0, and set properties
  set latency_axilite_brid_0 [ create_bd_cell -type ip -vlnv xilinx.com:hls:latency_axilite_bridge:1.0 latency_axilite_brid_0 ]

  set_property -dict [ list \
   CONFIG.NUM_READ_OUTSTANDING {1} \
   CONFIG.NUM_WRITE_OUTSTANDING {1} \
 ] [get_bd_intf_pins /receiver_kernel/latency_axilite_brid_0/s_axi_AXILiteS]

  # Create instance: ptp_slave_0, and set properties
  set ptp_slave_0 [ create_bd_cell -type ip -vlnv xilinx.com:hls:ptp_slave:1.0 ptp_slave_0 ]

  # Create instance: slave_FPGA_0, and set properties
  set slave_FPGA_0 [ create_bd_cell -type ip -vlnv xilinx.com:hls:slave_FPGA:1.0 slave_FPGA_0 ]

  # Create interface connections
  connect_bd_intf_net -intf_net Conn1 [get_bd_intf_pins in_stream_V] [get_bd_intf_pins slave_FPGA_0/in_stream_V]
  connect_bd_intf_net -intf_net Conn2 [get_bd_intf_pins packet_in_V] [get_bd_intf_pins ptp_slave_0/packet_in_V]
  connect_bd_intf_net -intf_net Conn3 [get_bd_intf_pins packet_out_V] [get_bd_intf_pins ptp_slave_0/packet_out_V]

  # Create port connections
  connect_bd_net -net Net1 [get_bd_pins aresetn] [get_bd_pins asynchronous_timer_0/ap_rst_n] [get_bd_pins latency_axilite_brid_0/ap_rst_n] [get_bd_pins ptp_slave_0/aresetn] [get_bd_pins slave_FPGA_0/aresetn]
  connect_bd_net -net asynchronous_timer_0_time_V [get_bd_pins aclk] [get_bd_pins asynchronous_timer_0/ap_clk] [get_bd_pins latency_axilite_brid_0/ap_clk] [get_bd_pins ptp_slave_0/aclk] [get_bd_pins slave_FPGA_0/aclk]
  connect_bd_net -net asynchronous_timer_0_time_V1 [get_bd_pins asynchronous_timer_0/time_V] [get_bd_pins ptp_slave_0/current_time_V] [get_bd_pins slave_FPGA_0/time_V]
  connect_bd_net -net ptp_slave_0_new_time_V [get_bd_pins asynchronous_timer_0/new_time_V] [get_bd_pins ptp_slave_0/new_time_V]
  connect_bd_net -net ptp_slave_0_set_time_V [get_bd_pins asynchronous_timer_0/set_time_V] [get_bd_pins ptp_slave_0/set_time_V]
  connect_bd_net -net slave_FPGA_0_latency_V [get_bd_pins latency_axilite_brid_0/latency_V] [get_bd_pins slave_FPGA_0/latency_V]

  # Restore current instance
  current_bd_instance $oldCurInst
}

# Hierarchical cell: QSFP0
proc create_hier_cell_QSFP0 { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_msg_id "BD_TCL-102" "ERROR" "create_hier_cell_QSFP0() - Empty argument(s)!"}
     return
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_msg_id "BD_TCL-100" "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_msg_id "BD_TCL-101" "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj

  # Create cell and set as current instance
  set hier_obj [create_bd_cell -type hier $nameHier]
  current_bd_instance $hier_obj

  # Create interface pins
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:diff_clock_rtl:1.0 gt_ref_clk
  create_bd_intf_pin -mode Master -vlnv xilinx.com:display_cmac_usplus:lbus_ports:2.0 lbus_rx
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:display_cmac_usplus:lbus_ports:2.0 lbus_tx

  # Create pins
  create_bd_pin -dir I init_clk
  create_bd_pin -dir O qsfp0_clk

  # Create instance: cmac_usplus_0, and set properties
  set cmac_usplus_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:cmac_usplus:2.4 cmac_usplus_0 ]
  set_property -dict [ list \
   CONFIG.CMAC_CAUI4_MODE {1} \
   CONFIG.CMAC_CORE_SELECT {CMACE4_X0Y1} \
   CONFIG.ENABLE_AXI_INTERFACE {0} \
   CONFIG.GT_DRP_CLK {200.00} \
   CONFIG.GT_GROUP_SELECT {X0Y12~X0Y15} \
   CONFIG.GT_REF_CLK_FREQ {322.265625} \
   CONFIG.LANE10_GT_LOC {NA} \
   CONFIG.LANE1_GT_LOC {X0Y12} \
   CONFIG.LANE2_GT_LOC {X0Y13} \
   CONFIG.LANE3_GT_LOC {X0Y14} \
   CONFIG.LANE4_GT_LOC {X0Y15} \
   CONFIG.LANE5_GT_LOC {NA} \
   CONFIG.LANE6_GT_LOC {NA} \
   CONFIG.LANE7_GT_LOC {NA} \
   CONFIG.LANE8_GT_LOC {NA} \
   CONFIG.LANE9_GT_LOC {NA} \
   CONFIG.NUM_LANES {4} \
   CONFIG.RX_CHECK_PREAMBLE {1} \
   CONFIG.RX_CHECK_SFD {1} \
   CONFIG.RX_FLOW_CONTROL {0} \
   CONFIG.TX_FLOW_CONTROL {0} \
 ] $cmac_usplus_0

  # Create instance: one, and set properties
  set one [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 one ]

  # Create instance: zero, and set properties
  set zero [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 zero ]
  set_property -dict [ list \
   CONFIG.CONST_VAL {0} \
 ] $zero

  # Create instance: zero_x10, and set properties
  set zero_x10 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 zero_x10 ]
  set_property -dict [ list \
   CONFIG.CONST_VAL {0} \
   CONFIG.CONST_WIDTH {10} \
 ] $zero_x10

  # Create instance: zero_x12, and set properties
  set zero_x12 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 zero_x12 ]
  set_property -dict [ list \
   CONFIG.CONST_VAL {0} \
   CONFIG.CONST_WIDTH {12} \
 ] $zero_x12

  # Create instance: zero_x16, and set properties
  set zero_x16 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 zero_x16 ]
  set_property -dict [ list \
   CONFIG.CONST_VAL {0} \
   CONFIG.CONST_WIDTH {16} \
 ] $zero_x16

  # Create instance: zero_x56, and set properties
  set zero_x56 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 zero_x56 ]
  set_property -dict [ list \
   CONFIG.CONST_VAL {0} \
   CONFIG.CONST_WIDTH {56} \
 ] $zero_x56

  # Create interface connections
  connect_bd_intf_net -intf_net cmac_usplus_0_lbus_rx [get_bd_intf_pins lbus_rx] [get_bd_intf_pins cmac_usplus_0/lbus_rx]
  connect_bd_intf_net -intf_net gt_ref_clk_1 [get_bd_intf_pins gt_ref_clk] [get_bd_intf_pins cmac_usplus_0/gt_ref_clk]
  connect_bd_intf_net -intf_net lbus_tx_1 [get_bd_intf_pins lbus_tx] [get_bd_intf_pins cmac_usplus_0/lbus_tx]

  # Create port connections
  connect_bd_net -net cmac_usplus_0_gt_txusrclk2 [get_bd_pins qsfp0_clk] [get_bd_pins cmac_usplus_0/gt_txusrclk2] [get_bd_pins cmac_usplus_0/rx_clk]
  connect_bd_net -net init_clk_1 [get_bd_pins init_clk] [get_bd_pins cmac_usplus_0/init_clk]
  connect_bd_net -net one_dout [get_bd_pins cmac_usplus_0/ctl_rx_enable] [get_bd_pins cmac_usplus_0/ctl_tx_enable] [get_bd_pins one/dout]
  connect_bd_net -net zero_dout [get_bd_pins cmac_usplus_0/core_drp_reset] [get_bd_pins cmac_usplus_0/core_rx_reset] [get_bd_pins cmac_usplus_0/core_tx_reset] [get_bd_pins cmac_usplus_0/ctl_rx_force_resync] [get_bd_pins cmac_usplus_0/ctl_rx_test_pattern] [get_bd_pins cmac_usplus_0/ctl_tx_send_idle] [get_bd_pins cmac_usplus_0/ctl_tx_send_lfi] [get_bd_pins cmac_usplus_0/ctl_tx_send_rfi] [get_bd_pins cmac_usplus_0/ctl_tx_test_pattern] [get_bd_pins cmac_usplus_0/drp_clk] [get_bd_pins cmac_usplus_0/drp_en] [get_bd_pins cmac_usplus_0/drp_we] [get_bd_pins cmac_usplus_0/gtwiz_reset_rx_datapath] [get_bd_pins cmac_usplus_0/gtwiz_reset_tx_datapath] [get_bd_pins cmac_usplus_0/sys_reset] [get_bd_pins zero/dout]
  connect_bd_net -net zero_x10_dout [get_bd_pins cmac_usplus_0/drp_addr] [get_bd_pins zero_x10/dout]
  connect_bd_net -net zero_x12_dout [get_bd_pins cmac_usplus_0/gt_loopback_in] [get_bd_pins zero_x12/dout]
  connect_bd_net -net zero_x16_dout [get_bd_pins cmac_usplus_0/drp_di] [get_bd_pins zero_x16/dout]
  connect_bd_net -net zero_x56_dout [get_bd_pins cmac_usplus_0/tx_preamblein] [get_bd_pins zero_x56/dout]

  # Restore current instance
  current_bd_instance $oldCurInst
}


# Procedure to create entire design; Provide argument to make
# procedure reusable. If parentCell is "", will use root.
proc create_root_design { parentCell } {

  variable script_folder
  variable design_name

  if { $parentCell eq "" } {
     set parentCell [get_bd_cells /]
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_msg_id "BD_TCL-100" "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_msg_id "BD_TCL-101" "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj


  # Create interface ports
  set gt_ref_clk_0 [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:diff_clock_rtl:1.0 gt_ref_clk_0 ]
  set_property -dict [ list \
   CONFIG.FREQ_HZ {322265625} \
   ] $gt_ref_clk_0
  set init_diff_clk [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:diff_clock_rtl:1.0 init_diff_clk ]

  # Create ports

  # Create instance: GULF_Stream_0, and set properties
  set GULF_Stream_0 [ create_bd_cell -type ip -vlnv clarkshen.com:user:GULF_Stream:1.0 GULF_Stream_0 ]

  # Create instance: QSFP0
  create_hier_cell_QSFP0 [current_bd_instance .] QSFP0

  # Create instance: axi_interconnect_0, and set properties
  set axi_interconnect_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_interconnect:2.1 axi_interconnect_0 ]
  set_property -dict [ list \
   CONFIG.NUM_MI {1} \
 ] $axi_interconnect_0

  # Create instance: axis_data_fifo_0, and set properties
  set axis_data_fifo_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axis_data_fifo:1.1 axis_data_fifo_0 ]
  set_property -dict [ list \
   CONFIG.FIFO_DEPTH {16} \
   CONFIG.HAS_TKEEP {1} \
   CONFIG.HAS_TLAST {1} \
   CONFIG.IS_ACLK_ASYNC {1} \
   CONFIG.SYNCHRONIZATION_STAGES {4} \
   CONFIG.TDATA_NUM_BYTES {64} \
 ] $axis_data_fifo_0

  # Create instance: axis_data_fifo_1, and set properties
  set axis_data_fifo_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axis_data_fifo:1.1 axis_data_fifo_1 ]
  set_property -dict [ list \
   CONFIG.FIFO_DEPTH {16} \
   CONFIG.HAS_TKEEP {1} \
   CONFIG.HAS_TLAST {1} \
   CONFIG.IS_ACLK_ASYNC {1} \
   CONFIG.SYNCHRONIZATION_STAGES {4} \
   CONFIG.TDATA_NUM_BYTES {64} \
 ] $axis_data_fifo_1

  # Create instance: axis_data_fifo_2, and set properties
  set axis_data_fifo_2 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axis_data_fifo:1.1 axis_data_fifo_2 ]
  set_property -dict [ list \
   CONFIG.FIFO_DEPTH {16} \
   CONFIG.HAS_TKEEP {1} \
   CONFIG.HAS_TLAST {1} \
   CONFIG.IS_ACLK_ASYNC {1} \
   CONFIG.SYNCHRONIZATION_STAGES {4} \
   CONFIG.TDATA_NUM_BYTES {64} \
 ] $axis_data_fifo_2

  # Create instance: axis_switch_0, and set properties
  set axis_switch_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axis_switch:1.1 axis_switch_0 ]
  set_property -dict [ list \
   CONFIG.DECODER_REG {1} \
   CONFIG.HAS_TKEEP {1} \
   CONFIG.HAS_TLAST {1} \
   CONFIG.NUM_MI {2} \
   CONFIG.NUM_SI {1} \
   CONFIG.TDATA_NUM_BYTES {64} \
   CONFIG.TDEST_WIDTH {16} \
 ] $axis_switch_0

  # Create instance: debug_bridge_0, and set properties
  set debug_bridge_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:debug_bridge:3.0 debug_bridge_0 ]
  set_property -dict [ list \
   CONFIG.C_DEBUG_MODE {2} \
 ] $debug_bridge_0

  # Create instance: lbus_axis_converter_0, and set properties
  set lbus_axis_converter_0 [ create_bd_cell -type ip -vlnv clarkshen.com:user:lbus_axis_converter:1.0 lbus_axis_converter_0 ]

  # Create instance: proc_sys_reset_0, and set properties
  set proc_sys_reset_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 proc_sys_reset_0 ]

  # Create instance: proc_sys_reset_1, and set properties
  set proc_sys_reset_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 proc_sys_reset_1 ]

  # Create instance: receiver_kernel
  create_hier_cell_receiver_kernel [current_bd_instance .] receiver_kernel

  # Create instance: util_ds_buf_0, and set properties
  set util_ds_buf_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:util_ds_buf:2.1 util_ds_buf_0 ]

  # Create instance: zynq_ultra_ps_e_1, and set properties
  set zynq_ultra_ps_e_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:zynq_ultra_ps_e:3.2 zynq_ultra_ps_e_1 ]

  # Create interface connections
  connect_bd_intf_net -intf_net CLK_IN_D_0_1 [get_bd_intf_ports init_diff_clk] [get_bd_intf_pins util_ds_buf_0/CLK_IN_D]
  connect_bd_intf_net -intf_net GULF_Stream_0_m_axis [get_bd_intf_pins GULF_Stream_0/m_axis] [get_bd_intf_pins lbus_axis_converter_0/s_axis]
  connect_bd_intf_net -intf_net QSFP0_lbus_rx [get_bd_intf_pins QSFP0/lbus_rx] [get_bd_intf_pins lbus_axis_converter_0/lbus_rx]
  connect_bd_intf_net -intf_net axi_interconnect_0_M00_AXI [get_bd_intf_pins axi_interconnect_0/M00_AXI] [get_bd_intf_pins debug_bridge_0/S_AXI]
  connect_bd_intf_net -intf_net axis_data_fifo_0_M_AXIS [get_bd_intf_pins GULF_Stream_0/payload_from_user] [get_bd_intf_pins axis_data_fifo_0/M_AXIS]
  connect_bd_intf_net -intf_net axis_data_fifo_1_M_AXIS [get_bd_intf_pins axis_data_fifo_1/M_AXIS] [get_bd_intf_pins receiver_kernel/in_stream_V]
  connect_bd_intf_net -intf_net axis_data_fifo_2_M_AXIS [get_bd_intf_pins axis_data_fifo_2/M_AXIS] [get_bd_intf_pins receiver_kernel/packet_in_V]
  connect_bd_intf_net -intf_net axis_switch_0_M00_AXIS [get_bd_intf_pins axis_data_fifo_1/S_AXIS] [get_bd_intf_pins axis_switch_0/M00_AXIS]
  connect_bd_intf_net -intf_net axis_switch_0_M01_AXIS [get_bd_intf_pins axis_data_fifo_2/S_AXIS] [get_bd_intf_pins axis_switch_0/M01_AXIS]
  connect_bd_intf_net -intf_net gt_ref_clk_0_1 [get_bd_intf_ports gt_ref_clk_0] [get_bd_intf_pins QSFP0/gt_ref_clk]
  connect_bd_intf_net -intf_net lbus_axis_converter_0_lbus_tx [get_bd_intf_pins QSFP0/lbus_tx] [get_bd_intf_pins lbus_axis_converter_0/lbus_tx]
  connect_bd_intf_net -intf_net lbus_axis_converter_0_m_axis [get_bd_intf_pins GULF_Stream_0/s_axis] [get_bd_intf_pins lbus_axis_converter_0/m_axis]
  connect_bd_intf_net -intf_net receiver_kernel_packet_out_V [get_bd_intf_pins axis_data_fifo_0/S_AXIS] [get_bd_intf_pins receiver_kernel/packet_out_V]
  connect_bd_intf_net -intf_net zynq_ultra_ps_e_1_M_AXI_HPM0_LPD [get_bd_intf_pins axi_interconnect_0/S00_AXI] [get_bd_intf_pins zynq_ultra_ps_e_1/M_AXI_HPM0_LPD]

  # Create port connections
  connect_bd_net -net ACLK_2 [get_bd_pins axi_interconnect_0/ACLK] [get_bd_pins axi_interconnect_0/M00_ACLK] [get_bd_pins axi_interconnect_0/S00_ACLK] [get_bd_pins axis_data_fifo_0/s_axis_aclk] [get_bd_pins axis_data_fifo_1/m_axis_aclk] [get_bd_pins axis_data_fifo_2/m_axis_aclk] [get_bd_pins debug_bridge_0/s_axi_aclk] [get_bd_pins proc_sys_reset_1/slowest_sync_clk] [get_bd_pins receiver_kernel/aclk] [get_bd_pins zynq_ultra_ps_e_1/pl_clk0]
  connect_bd_net -net GULF_Stream_0_payload_to_user_data [get_bd_pins GULF_Stream_0/payload_to_user_data] [get_bd_pins axis_switch_0/s_axis_tdata]
  connect_bd_net -net GULF_Stream_0_payload_to_user_keep [get_bd_pins GULF_Stream_0/payload_to_user_keep] [get_bd_pins axis_switch_0/s_axis_tkeep]
  connect_bd_net -net GULF_Stream_0_payload_to_user_last [get_bd_pins GULF_Stream_0/payload_to_user_last] [get_bd_pins axis_switch_0/s_axis_tlast]
  connect_bd_net -net GULF_Stream_0_payload_to_user_valid [get_bd_pins GULF_Stream_0/payload_to_user_valid] [get_bd_pins axis_switch_0/s_axis_tvalid]
  connect_bd_net -net GULF_Stream_0_remote_port_rx [get_bd_pins GULF_Stream_0/remote_port_rx] [get_bd_pins axis_switch_0/s_axis_tdest]
  connect_bd_net -net M00_ARESETN_1 [get_bd_pins axi_interconnect_0/ARESETN] [get_bd_pins axi_interconnect_0/M00_ARESETN] [get_bd_pins axi_interconnect_0/S00_ARESETN] [get_bd_pins proc_sys_reset_1/interconnect_aresetn]
  connect_bd_net -net Net [get_bd_pins axis_data_fifo_0/m_axis_aresetn] [get_bd_pins axis_data_fifo_1/s_axis_aresetn] [get_bd_pins axis_data_fifo_2/s_axis_aresetn] [get_bd_pins proc_sys_reset_0/interconnect_aresetn]
  connect_bd_net -net QSFP0_qsfp0_clk [get_bd_pins GULF_Stream_0/clk] [get_bd_pins QSFP0/qsfp0_clk] [get_bd_pins axis_data_fifo_0/m_axis_aclk] [get_bd_pins axis_data_fifo_1/s_axis_aclk] [get_bd_pins axis_data_fifo_2/s_axis_aclk] [get_bd_pins lbus_axis_converter_0/clk] [get_bd_pins proc_sys_reset_0/slowest_sync_clk]
  connect_bd_net -net aresetn_1 [get_bd_pins axis_data_fifo_0/s_axis_aresetn] [get_bd_pins axis_data_fifo_1/m_axis_aresetn] [get_bd_pins axis_data_fifo_2/m_axis_aresetn] [get_bd_pins receiver_kernel/aresetn]
  connect_bd_net -net proc_sys_reset_0_peripheral_reset [get_bd_pins GULF_Stream_0/rst] [get_bd_pins lbus_axis_converter_0/rst] [get_bd_pins proc_sys_reset_0/peripheral_reset]
  connect_bd_net -net util_ds_buf_0_IBUF_OUT [get_bd_pins QSFP0/init_clk] [get_bd_pins util_ds_buf_0/IBUF_OUT]
  connect_bd_net -net zynq_ultra_ps_e_1_pl_resetn0 [get_bd_pins proc_sys_reset_0/ext_reset_in] [get_bd_pins proc_sys_reset_1/ext_reset_in] [get_bd_pins zynq_ultra_ps_e_1/pl_resetn0]

  # Create address segments


  # Restore current instance
  current_bd_instance $oldCurInst

  save_bd_design
}
# End of create_root_design()


##################################################################
# MAIN FLOW
##################################################################

create_root_design ""


common::send_msg_id "BD_TCL-1000" "WARNING" "This Tcl script was generated from a block design that has not been validated. It is possible that design <$design_name> may result in errors during validation."

