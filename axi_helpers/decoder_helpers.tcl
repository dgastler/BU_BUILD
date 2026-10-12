## \file decoder_helpers.tcl

# Global variable \c decoders
global decoders;    if {![info exists decoders]}    {set decoders [dict create]}
global addr_tables; if {![info exists addr_tables]} {set addr_tables [dict create]}

proc UPDATE_DECODERS {device_name device_offset device_mask decoder_node} {
    #set_required_values $decoder_node {TEMPLATE}
    set_optional_values $decoder_node [dict create TEMPLATE { }]
    pdict $decoder_node
    
    #set proper name DECODER_name (override if requested)
    if { [dict exists $decoder_node NAME] } {
	set decoder_name [dict get $decoder_node NAME]
    } else {
	#set decoder_name "DECODER_$decoder_name"
	#set decoder_name "DECODER_$device_name"
	set decoder_name "$device_name"
    }

    #access the global decoders variable
    global decoders

    if { ! [dict exists $decoders $decoder_name] } {
	#create entry if one doesn't exist
	dict append decoders $decoder_name [dict create]
	#create an emtpy TABLES list if it doesn't exists
	#we don't want to overwrite any existing entries
	dict set decoders $decoder_name TABLES [dict create]
	puts "Creating new entry for ${decoder_name}"
    }
    #set decoder construction values
    if { [dict exists $decoder_node TEMPLATE] } {
	set template [dict get $decoder_node TEMPLATE]
	dict set decoders $decoder_name TEMPLATE ${template}
	puts "Updating TEMPLATE for ${decoder_name} to ${template}"
    }
    dict set decoders $decoder_name NAME $decoder_name
    puts "Updating NAME for ${decoder_name} to ${decoder_name}"
    dict set decoders $decoder_name BASE_ADDR $device_offset
    puts "Updating BASE_ADDR for ${decoder_name} to ${device_offset}"
    dict set decoders $decoder_name BASE_MASK $device_mask
    puts "Updating BASE_MASK for ${decoder_name} to ${device_mask}"
}

proc PROCESS_ADDR_SPACE {space_name space_node} {
    set_required_values $space_node FILE
    set_optional_values $space_node {DECODER false OFFSET 0 SEARCH_PATH false}
    
    if { $DECODER != false } {
	global decoders

	if { ! [dict exists $decoders $DECODER] } {
	    dict append decoders $DECODER [dict create ]
	    dict set decoders $DECODER NAME $DECODER
	    dict set decoders $DECODER TEMPLATE ""
	    dict set decoders $DECODER TABLES [dict create]
	}

	dict set decoders $DECODER TABLES $space_name [dict create OFFSET $OFFSET FILENAME $FILE]
	if {$SEARCH_PATH != false} {
	    dict set decoders $DECODER TABLES $space_name SEARCH_PATH $SEARCH_PATH
	}
    }

    global addr_tables
    dict set addr_tables $space_name [dict create OFFSET $OFFSET FILENAME $FILE]
    if {$SEARCH_PATH != false} {
	dict set addr_tables $space_name SEARCH_PATH $SEARCH_PATH
    }
    
}

proc PROCESS_ADDR_SPACES {addr_spaces_node} {
    dict for {space_name space_node} $addr_spaces_node {
	PROCESS_ADDR_SPACE $space_name $space_node
    }
}


proc GENERATE_ADDRESS_TABLE {output_path output_filename {decoder_filter ""} } {    
    #create the output path if needed
    file mkdir $output_path

    #open the output file
    set output_filename "$output_path/$output_filename"
    set outfile [open $output_filename w]

    global decoders
    global addr_tables
    pdict $decoders
    pdict $addr_tables

    #Find the longest name
    set name_length 0
    dict for {decoder obj} $decoders {
	if {[string equal $decoder_filter ""] ||
	    [string equal $decoder_filter $decoder]} {
	    dict for {name table} $obj {
		if {[string length $name] > $name_length } {
		    set name_length [string length $name]
		}
	    }
	}
    }
    set name_length [expr (($name_length/10)+2)*10 ]

    dict for {decoder obj} $decoders {
	if {[string equal $decoder_filter ""] ||
	    [string equal $decoder_filter $decoder]} {
	    #get the axi byte based offset
	    set decoder_offset [dict get $obj "BASE_ADDR"]
	    #get the 32bit version of the offset
	    set decoder_offset32 [expr {$decoder_offset >> 2}]
	    dict for {name table} [dict get $obj TABLES ] {
		set offset [expr $decoder_offset32 + [dict get $table OFFSET]]
		#apply subst to force variable substitution
		set table_filename [subst [dict get $table FILENAME]]
		puts -nonewline $outfile [format "%-*s0x%08X          %s" $name_length $name $offset $table_filename]
		if { [dict exists $table "SEARCH_PATH"] } {
		    puts $outfile [format "   search_path=%s" [subst [dict get $table "SEARCH_PATH"]]]
		} else {
		    puts $outfile ""
		}
	    }
	}
    }
    
    
    close $outfile
    return $output_filename
}
