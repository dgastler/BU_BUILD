proc AXI_IP_EPC {params} {

    # required values
    set_required_values $params {device_name axi_control}

    #optional values
    set_optional_values $params {irq_port false}

    create_bd_cell -type ip -vlnv [get_ipdefs -filter {NAME == axi_epc}] $device_name

    #connect to AXI, clk, and reset between slave and mastre
    [AXI_DEV_CONNECT $params]

    make_bd_intf_pins_external -name ${device_name}_epc [get_bd_intf_pins ${device_name}/EPC_INTF]

    if {$irq_port ne false} {
	#connect interrupt
	CONNECT_IRQ ${device_name}/interrupt ${irq_port}
    }

    puts "Added Xilinx EPC Axi Slave: $device_name"
}
