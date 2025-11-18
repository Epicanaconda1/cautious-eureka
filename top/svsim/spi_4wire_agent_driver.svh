
//----------------------------------------------------------------------
// spi_4wire_agent_driver
//----------------------------------------------------------------------
class spi_4wire_agent_driver extends uvm_driver #(spi_4wire_agent_item);

   // factory registration macro
   `uvm_component_utils(spi_4wire_agent_driver);
      
   // Configuration object
   spi_4wire_agent_config   m_cfg; 
   spi_4wire_agent_item     m_req;

   logic [7:0] address;

   
   //--------------------------------------------------------------------
   // new
   //--------------------------------------------------------------------    
   function new (string name = "spi_4wire_agent_driver",
                 uvm_component parent = null);
      super.new(name,parent);
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

      // Calls init_signals task (see below)
      init_signals();

      forever begin

   	seq_item_port.get_next_item(m_req);
         
        @(posedge m_cfg.spi_4wire_if.ce);
    
        for (int i=7; i>=0; i--) begin         
          @(posedge m_cfg.spi_4wire_if.sclk);
          address[i]= m_cfg.spi_4wire_if.sdi;         
        end

        m_req.rw_address <= address;
         
	seq_item_port.item_done();
         

   	seq_item_port.get_next_item(m_req);

        m_req.rw_address <= address;

        for (int i=7; i>=0; i--) begin         
          if (address[7]==1) begin
            @(posedge m_cfg.spi_4wire_if.sclk);
            m_req.write_data[i]= m_cfg.spi_4wire_if.sdi;          
          end else begin 
            @(negedge m_cfg.spi_4wire_if.sclk);
            m_cfg.spi_4wire_if.sdo <= m_req.read_data[i];          
          end      
        end

 	seq_item_port.item_done();
         
      end
      
   endtask: run_phase
   

   task init_signals();
     m_cfg.spi_4wire_if.sdo <= 0;
   endtask // init_signals

   
endclass: spi_4wire_agent_driver

