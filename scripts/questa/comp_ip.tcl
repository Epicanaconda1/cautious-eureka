#!/usr/bin/tclsh

#Path to repo
set repo_path $::env(MLA_DESIGN)
set local_script_path "scripts/questa"
set scripts_path $repo_path/$local_script_path
set log_path $scripts_path/log

set local_lib_path "top/libs"
set lib_path $repo_path/$local_lib_path

set modelsimini $scripts_path/modelsim.ini

set logfilename $log_path/comp_ip_log.txt
set fileid [open $logfilename "w"]

puts "\r\n------- comp_ip.tcl -------"
puts $fileid "\r\n------- comp_ip.tcl -------"

set work_lib $lib_path/mla_lib

set vcom "vcom -2008 -nologo -linedebug +acc=nprv -fsmdebug +cover" 
set vcom_nocover "vcom -2008 -nologo -linedebug +acc=nprv -fsmdebug"

set vlog "vlog -timescale 1ns/1ps -L unisim -L unimacro -linedebug -assertdebug +acc=npr +cover"


# Read design IPs
set design_ip_path_vhdl $repo_path/
set design_ip_list_vhdl "if/psif/hdl/pif/axi4pifb/psif_axi4pifb_ent.vhd \
                         if/psif/hdl/pif/axi4pifb/psif_axi4pifb_rtl.vhd \
                         if/psif/hdl/pif/odi/psif_odi_reg_ent.vhd \
                         if/psif/hdl/pif/odi/psif_odi_reg_rtl.vhd \
                         if/psif/hdl/pif/dti/psif_dti_reg_ent.vhd \
                         if/psif/hdl/pif/dti/psif_dti_reg_rtl.vhd \
                         if/psif/hdl/pif/zu/psif_zu_reg_ent.vhd \
                         if/psif/hdl/pif/zu/psif_zu_reg_rtl.vhd \
                         if/psif/hdl/pif/scu/psif_scu_reg_ent.vhd \
                         if/psif/hdl/pif/scu/psif_scu_reg_rtl.vhd \
                         if/psif/hdl/pif/aui/psif_aui_reg_ent.vhd \
                         if/psif/hdl/pif/aui/psif_aui_reg_rtl.vhd"

# Read Chiper HLS IP
set inv_chiper_ip_path_vhdl $repo_path/core/zu/hdl/
set inv_chiper_ip_list_vhdl "
	aes_inv_cipher_aes_inv_cipher_Pipeline_VITIS_LOOP_210_1_VITIS_LOOP_211_210.vhd \
	aes_inv_cipher_aes_inv_cipher_Pipeline_VITIS_LOOP_210_1_VITIS_LOOP_211_21.vhd \
	aes_inv_cipher_aes_inv_cipher_Pipeline_VITIS_LOOP_210_1_VITIS_LOOP_211_2.vhd \
	aes_inv_cipher_aes_inv_cipher_Pipeline_VITIS_LOOP_256_22.vhd \
	aes_inv_cipher_aes_inv_cipher_Pipeline_VITIS_LOOP_256_24.vhd \
	aes_inv_cipher_aes_inv_cipher_Pipeline_VITIS_LOOP_256_26.vhd \
	aes_inv_cipher_aes_inv_cipher_Pipeline_VITIS_LOOP_256_2.vhd \
	aes_inv_cipher_aes_inv_cipher_Pipeline_VITIS_LOOP_263_33.vhd \
	aes_inv_cipher_aes_inv_cipher_Pipeline_VITIS_LOOP_263_35.vhd \
	aes_inv_cipher_aes_inv_cipher_Pipeline_VITIS_LOOP_263_37.vhd \
	aes_inv_cipher_aes_inv_cipher_Pipeline_VITIS_LOOP_263_3.vhd \
	aes_inv_cipher_aes_inv_cipher_Pipeline_VITIS_LOOP_304_28.vhd \
	aes_inv_cipher_aes_inv_cipher_Pipeline_VITIS_LOOP_304_2.vhd \
	aes_inv_cipher_aes_inv_cipher_Pipeline_VITIS_LOOP_345_1_VITIS_LOOP_346_29.vhd \
	aes_inv_cipher_aes_inv_cipher_Pipeline_VITIS_LOOP_345_1_VITIS_LOOP_346_2.vhd \
	aes_inv_cipher_aes_inv_cipher_Pipeline_VITIS_LOOP_512_1_VITIS_LOOP_513_2.vhd \ 
	aes_inv_cipher_aes_inv_cipher_Pipeline_VITIS_LOOP_531_4_VITIS_LOOP_532_5.vhd \
	aes_inv_cipher_aes_inv_cipher_Pipeline_VITIS_LOOP_540_6_VITIS_LOOP_541_7.vhd \
	aes_inv_cipher_coef_mult_int.vhd \
	aes_inv_cipher_flow_control_loop_pipe_sequential_init.vhd \
	aes_inv_cipher_inv_s_box_ROM_AUTO_1R.vhd \
	aes_inv_cipher_Multiply.vhd  \
	aes_inv_cipher_regslice_both.vhd \
	aes_inv_cipher_sparsemux_9_2_8_1_1.vhd \
	aes_inv_cipher_state_RAM_AUTO_1R1W.vhd \
	aes_inv_cipher.vhd "
	


# Read Xilinx IPs
set xilinx_ip_path $repo_path/ip/zedboard_xc7z020/
set xilinx_ip_list "clk_wiz_0/clk_wiz_0_sim_netlist.vhdl \
                    fifo_512x32bit/fifo_512x32bit_sim_netlist.vhdl \
                    fifo_512x16bit/fifo_512x16bit_sim_netlist.vhdl \
                    fifo_512x8bit/fifo_512x8bit_sim_netlist.vhdl \
                    bram_truedualport_512x32bit/bram_truedualport_512x32bit_sim_netlist.vhdl"


foreach design_ip_sourcefile_vhdl $design_ip_list_vhdl {
    set result [eval exec $vcom -modelsimini $modelsimini -work $work_lib $design_ip_path_vhdl$design_ip_sourcefile_vhdl]
    puts $result
    puts $fileid $result
}

foreach inv_chiper_ip_sourcefile_vhdl $inv_chiper_ip_list_vhdl {
    set result [eval exec $vcom -modelsimini $modelsimini -work $work_lib $inv_chiper_ip_path_vhdl$inv_chiper_ip_sourcefile_vhdl]
    puts $result
    puts $fileid $result
}

foreach xilinx_ip_sourcefile $xilinx_ip_list {
    set result [eval exec $vcom_nocover -modelsimini $modelsimini -work $work_lib $xilinx_ip_path$xilinx_ip_sourcefile]
    puts $result
    puts $fileid $result
}

close $fileid
