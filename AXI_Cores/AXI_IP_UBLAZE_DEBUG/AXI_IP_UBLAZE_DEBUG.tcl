proc AXI_IP_UBLAZE_DEBUG {params} {

    # required values
    set_required_values $params {device_name debug_sys_rst debug_port}
    # optional values
    set_optional_values $params [dict create axi_control false addr {offset -1 range 64K} remote_slave 0]

    #optional values
    set_optional_values $params {irq_port false use_uart false}


    create_bd_cell -type ip -vlnv [get_ipdefs -filter {NAME == mdm}] $device_name

    connect_bd_intf_net [get_bd_intf_pins ${device_name}/MBDEBUG_0] [get_bd_intf_pins ${debug_port}]

    connect_bd_net [get_bd_pins ${device_name}/Debug_SYS_Rst] [get_bd_pins ${debug_sys_rst}]
    
    if {$use_uart} {
	set_property CONFIG.C_USE_UART {1}  [get_bd_cells ${device_name}]
	#connect to AXI, clk, and reset between slave and mastre
	[AXI_DEV_CONNECT $params]
    }
    
    if {$irq_port ne false} {
	#connect interrupt
	CONNECT_IRQ ${device_name}/interrupt ${irq_port}
    }


    
    puts "Added Xilinx uBlaze Debug Slave: $device_name"
}

