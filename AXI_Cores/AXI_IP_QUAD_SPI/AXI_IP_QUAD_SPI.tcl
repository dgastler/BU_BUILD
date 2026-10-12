proc AXI_IP_QUAD_SPI {params} {

    # required values
    set_required_values $params {device_name axi_control}

    #optional values
    set_optional_values $params {irq_port false}

    create_bd_cell -type ip -vlnv [get_ipdefs -filter {NAME == axi_quad_spi}] $device_name

    #connect to AXI, clk, and reset between slave and mastre
    [AXI_DEV_CONNECT $params]

    #this may need to be a default option that can be overridden. 
    connect_bd_net [get_bd_pins ${axi_clk}] [get_bd_pins ${device_name}/ext_spi_clk]

    make_bd_intf_pins_external -name ${device_name}_spi [get_bd_intf_pins ${device_name}/SPI_0]

    if {$irq_port ne false} {
	#connect interrupt
	CONNECT_IRQ ${device_name}/interrupt ${irq_port}
    }

    puts "Added Xilinx SPI Axi Slave: $device_name"
}
