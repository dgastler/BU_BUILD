proc AXI_IP_FIFO {params} {

    # required values
    set_required_values $params {device_name axi_control}

    #optional values
    set_optional_values $params {axis_tkeep 0 tx_ctrl 0}
    set_optional_values $params {irq_port false}

    create_bd_cell -type ip -vlnv [get_ipdefs -filter {NAME == axi_fifo_mm_s}] $device_name

    set_property CONFIG.C_HAS_AXIS_TKEEP $axis_tkeep [get_bd_cells $device_name]
    set_property CONFIG.C_USE_TX_CTRL $tx_ctrl [get_bd_cells $device_name]
    
    #connect to AXI, clk, and reset between slave and mastre
    [AXI_DEV_CONNECT $params]

    #create bd interface ports for tx and rx paths
    make_bd_intf_pins_external  -name ${device_name}_TX [get_bd_intf_pins $device_name/AXI_STR_TXD]
    make_bd_intf_pins_external  -name ${device_name}_RX [get_bd_intf_pins $device_name/AXI_STR_RXD]
    
    #connect interrupt
    if {$irq_port != false} {
	CONNECT_IRQ ${device_name}/interrupt ${irq_port}
    }

    puts "Added Xilinx AXI FIFO Slave: $device_name"
}
