source -notrace ${BD_PATH}/AXI_Cores/Helpers/Xilinx_AXI_Endpoints_Helpers.tcl
source -notrace ${BD_PATH}/AXI_Cores/AXI_IP_DRP_INTF/AXI_DRP_include.tcl

proc AXI_IP_DRP_INTF {params} {
    # required values
    set_required_values $params {device_name axi_control drp_count}
    
    # optional values
    set_optional_values $params [dict create addr {offset -1 range 4K} remote_slave 0 drp_addr_width 9 drp_data_width 16]

    #Create drp interface
    create_bd_cell -type ip -vlnv [get_ipdefs -filter {NAME == drp_bridge }] $device_name
      
    #set the number of DRP interfaces
    set_property CONFIG.DRP_COUNT $drp_count [get_bd_cells $device_name]

    set_property CONFIG.DRP_ADDR_WIDTH $drp_addr_width [get_bd_cells $device_name]
    set_property CONFIG.DRP_DATA_WIDTH $drp_data_width [get_bd_cells $device_name]    
    #connect this to the interconnect
    [AXI_DEV_CONNECT $params]

    for {set i 0} {$i < $drp_count} {incr i} {
	make_bd_intf_pins_external  -name ${device_name}_DRP_$i [get_bd_intf_pins $device_name/DRP$i]
    }
    
}
