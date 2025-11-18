
//----------------------------------------------------------------------
// spi_4wire_agent_monitor
//----------------------------------------------------------------------
class spi_4wire_agent_monitor extends uvm_monitor;

   // factory registration macro
   `uvm_component_utils(spi_4wire_agent_monitor);
      
   // Configuration object
   spi_4wire_agent_config   m_cfg; 
   spi_4wire_agent_item     m_spi_4wire_item;
   spi_4wire_agent_item     t;  // Note: MUST be declared as object named "t" !!

   // external interfaces
   uvm_analysis_port  #(spi_4wire_agent_item) ap;
   
   //--------------------------------------------------------------------
   // new
   //--------------------------------------------------------------------    
   function new (string name = "spi_4wire_agent_monitor",
                 uvm_component parent = null);
      super.new(name,parent);
      ap= new("ap", this);
   endfunction: new


   //--------------------------------------------------------------------
   // build_phase
   //--------------------------------------------------------------------  
   virtual function void build_phase(uvm_phase phase);
     super.build_phase(phase);
     m_cfg= spi_4wire_agent_config::type_id::create("m_cfg");
   endfunction : build_phase
     

   //--------------------------------------------------------------------
   // run_phase
   //--------------------------------------------------------------------  
   virtual task run_phase(uvm_phase phase);

      m_spi_4wire_item = spi_4wire_agent_item::type_id::create("m_spi_4wire_item");
      monitor_dut();  // Use task monitor_dut to monitor device under test (DUT)
      
   endtask: run_phase
   

  task monitor_dut();
     
    // Monitor transactions from the 4 wire SPI interface
    forever begin
       
      @(posedge m_cfg.spi_4wire_if.ce);

      // Samples 8 address bits with MSB bit first
      for (int i=7; i>=0; i--) begin         
        @(posedge m_cfg.spi_4wire_if.sclk);
        m_spi_4wire_item.rw_address[i]= m_cfg.spi_4wire_if.sdi;         
      end

      for (int i=7; i>=0; i--) begin         
        @(posedge m_cfg.spi_4wire_if.sclk);
        if (m_spi_4wire_item.rw_address[7]==1) begin
          // Write access; read data from serial data input (sdi)
          m_spi_4wire_item.write_data[i]= m_cfg.spi_4wire_if.sdi;          
        end else begin
          // Read access; set write data to zero and use serial data out (sdo)
          m_spi_4wire_item.write_data[i]= 0;          
          m_spi_4wire_item.read_data[i]= m_cfg.spi_4wire_if.sdo;          
        end      
      end


      $cast(t, m_spi_4wire_item.clone());
         
      if (t.rw_address[7]==1) begin
        `uvm_info(get_type_name(),$psprintf(" Write 4-wire SPI monitor address value: 0x%0h", t.rw_address), UVM_MEDIUM);
        `uvm_info(get_type_name(),$psprintf(" Write 4-wire SPI monitor data value: 0x%0h", t.write_data), UVM_MEDIUM);
      end else
       `uvm_info(get_type_name(),$psprintf(" Read 4-wire SPI monitor address value: 0x%0h", t.rw_address), UVM_MEDIUM);
       `uvm_info(get_type_name(),$psprintf(" Read 4-wire SPI monitor data value: 0x%0h", t.read_data), UVM_MEDIUM);

  
      ap.write(t); // Write to all access port (i.e. ap) subscribers

           
    end
  endtask: monitor_dut

   
endclass: spi_4wire_agent_monitor

