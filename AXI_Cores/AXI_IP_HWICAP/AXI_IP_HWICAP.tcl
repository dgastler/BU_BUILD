proc AXI_IP_HWICAP {params} {

    # required values
    set_required_values $params {device_name axi_control}

    #optional values
    set_optional_values $params {irq_port false}

    create_bd_cell -type ip -vlnv [get_ipdefs -filter {NAME == axi_hwicap}] $device_name

    #connect to AXI, clk, and reset between slave and mastre
    [AXI_DEV_CONNECT $params]

    connect_bd_net [get_bd_pins ${axi_clk}] [get_bd_pins ${device_name}/icap_clk]

    if {$irq_port ne false} {
	#connect interrupt
	CONNECT_IRQ ${device_name}/interrupt ${irq_port}
    }

    puts "Added Xilinx HWICAP Axi Slave: $device_name"
}
