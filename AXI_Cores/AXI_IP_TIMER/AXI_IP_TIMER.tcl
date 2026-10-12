proc AXI_IP_TIMER {params} {

    # required values
    set_required_values $params {device_name axi_control}

    #optional values
    set_optional_values $params {irq_port false}


    create_bd_cell -type ip -vlnv [get_ipdefs -filter {NAME == axi_timer}] $device_name

    #connect to AXI, clk, and reset between slave and mastre
    [AXI_DEV_CONNECT $params]

    if {$irq_port ne false} {
	#connect interrupt
	CONNECT_IRQ ${device_name}/interrupt ${irq_port}
    }

    puts "Added Xilinx Timer Axi Slave: $device_name"
}
