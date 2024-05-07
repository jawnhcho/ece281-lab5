# 
# Synthesis run script generated by Vivado
# 

set TIME_start [clock seconds] 
proc create_report { reportName command } {
  set status "."
  append status $reportName ".fail"
  if { [file exists $status] } {
    eval file delete [glob $status]
  }
  send_msg_id runtcl-4 info "Executing : $command"
  set retval [eval catch { $command } msg]
  if { $retval != 0 } {
    set fp [open $status w]
    close $fp
    send_msg_id runtcl-5 warning "$msg"
  }
}
set_param xicom.use_bs_reader 1
create_project -in_memory -part xc7a35tcpg236-1

set_param project.singleFileAddWarning.threshold 0
set_param project.compositeFile.enableAutoGeneration 0
set_param synth.vivado.isSynthRun true
set_property webtalk.parent_dir C:/Users/akeny/Downloads/ece281-lab5/basic_cpu.cache/wt [current_project]
set_property parent.project_path C:/Users/akeny/Downloads/ece281-lab5/basic_cpu.xpr [current_project]
set_property default_lib xil_defaultlib [current_project]
set_property target_language VHDL [current_project]
set_property board_part digilentinc.com:basys3:part0:1.1 [current_project]
set_property ip_output_repo c:/Users/akeny/Downloads/ece281-lab5/basic_cpu.cache/ip [current_project]
set_property ip_cache_permissions {read write} [current_project]
read_vhdl -library xil_defaultlib {
  C:/Users/akeny/Downloads/ece281-lab5/src/hdl/ALU.vhd
  C:/Users/akeny/Downloads/ece281-lab5/src/hdl/TDM4.vhd
  C:/Users/akeny/Downloads/ece281-lab5/src/hdl/clock_divider.vhd
  C:/Users/akeny/Downloads/ece281-lab5/basic_cpu.srcs/sources_1/new/controller_fsm.vhd
  C:/Users/akeny/Downloads/ece281-lab5/basic_cpu.srcs/sources_1/new/eightBitRegister.vhd
  C:/Users/akeny/Downloads/ece281-lab5/basic_cpu.srcs/sources_1/new/sevenSeg.vhd
  C:/Users/akeny/Downloads/ece281-lab5/src/hdl/twoscomp_decimal.vhd
  C:/Users/akeny/Downloads/ece281-lab5/src/hdl/top_basys3.vhd
}
# Mark all dcp files as not used in implementation to prevent them from being
# stitched into the results of this synthesis run. Any black boxes in the
# design are intentionally left as such for best results. Dcp files will be
# stitched into the design at a later time, either when this synthesis run is
# opened, or when it is stitched into a dependent implementation run.
foreach dcp [get_files -quiet -all -filter file_type=="Design\ Checkpoint"] {
  set_property used_in_implementation false $dcp
}
read_xdc C:/Users/akeny/Downloads/ece281-lab5/src/hdl/Basys3_Master.xdc
set_property used_in_implementation false [get_files C:/Users/akeny/Downloads/ece281-lab5/src/hdl/Basys3_Master.xdc]

set_param ips.enableIPCacheLiteLoad 0
close [open __synthesis_is_running__ w]

synth_design -top top_basys3 -part xc7a35tcpg236-1


# disable binary constraint mode for synth run checkpoints
set_param constraints.enableBinaryConstraints false
write_checkpoint -force -noxdef top_basys3.dcp
create_report "synth_1_synth_report_utilization_0" "report_utilization -file top_basys3_utilization_synth.rpt -pb top_basys3_utilization_synth.pb"
file delete __synthesis_is_running__
close [open __synthesis_is_complete__ w]
