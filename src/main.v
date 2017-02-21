
`include "u_driver.v"
`include "addr_dev.v"
`include "spi_device.v"
`include "dev_driver_x1.v"
`include "dev_driver_x2.v"
`include "spi_gpo.v"
`include "spi_gpio.v"
`include "shift_reg_module.v"
`include "spi_uart_mux.v"

module main(
            // Base signal    
            input  clk,
				
				// Heartbeat
				output heartbeat,
				
            // SPI device signals
            input  cs_addr_u,
            input  cs_u,
            input  ck_u,
            input  mo_u,
            output mi_u,
            input  o0_u,
            input  o1_u,
            output i0_u,
            output i1_u,

            // SPI ADC
            output cs_adc,
            output ck_adc,
            output mo_adc,
            input  mi_adc,
            output o0_adc,
            output o1_adc,
            input  i0_adc,
            input  i1_adc,
	    
            // SPI DAC
            output cs_dac,
            output ck_dac,
            output mo_dac,
            input  mi_dac,
            output o0_dac,
            output o1_dac,
            input  i0_dac,
            input  i1_dac,
			
				// LOW SPEED SPI
            output ck_lwsp,
            output mo_lwsp,
            input  mi_lwsp,

				// VCCO POTS
				output cs_vcco_pot,
				output o0_vcco_pot,
            output o1_vcco_pot,
				input  i0_vcco_pot,
            input  i1_vcco_pot,
				
				// SPI DUT POTS
            output cs_pot,
            output o0_pot,
            output o1_pot,
            input  i0_pot,
            input  i1_pot,

				// VBAT VGEN POT
				output cs_vbat_vgen_pot,
				output o0_vbat_vgen_pot,
            output o1_vbat_vgen_pot,
				input  i0_vbat_vgen_pot,
            input  i1_vbat_vgen_pot,			

				// IVMeter VBAT 
				output cs_ivmeter_vbat,
				output o0_ivmeter_vbat,
            output o1_ivmeter_vbat,
				input  i0_ivmeter_vbat,
            input  i1_ivmeter_vbat,

				// IVMeter VGEN 
				output cs_ivmeter_vgen,
				output o0_ivmeter_vgen,
            output o1_ivmeter_vgen,
				input  i0_ivmeter_vgen,
            input  i1_ivmeter_vgen,				
				
				// GPO 
				// 0 - PWR_TOOL_GEN_CMD0     (Sheet 6 U601)
				// 1 - PWR_TOOL_GEN_CMD1     (Sheet 6 U602)
				// 2 - PWR_TOOL_GEN_CMD2     (Sheet 6 U605)
				// 3 - PWR_TOOL_GEN_CMD3     (Sheet 6 U606)
				// 4 - PWR_TOOL_VBAT_INT_CMD (Sheet 6 U609)
				// 5 - TBD
				// 6 - LSW_ON_1              (Sheet 7 U705)
				// 7 - LSW_ON_2              (Sheet 7 U706)
				output [7:0]     gpo_out,
				
				
				// GPO1
				// 0 - AMUX_A                (Sheet 7 U708)
				// 1 - AMUX_B                (Sheet 7 U708)
				// 2 - AMUX_IH               (Sheet 7 U708) 
				// 3 - ASW_LO_IN_1           (Sheet 7 U703) 
            // 4 - ASW_LO_IN_2           (Sheet 7 U704)
				// 5 - T7                    FPGA pin (Sheet 8 camera connector pin 4)
				// 6 - N6                    FPGA pin (Sheet 8 camera connector pin 5)
				// 7 - P7                    FPGA pin (Sheet 8 camera connector pin 6)
				output [7:0]     gpo1_out,

				// GPIO0, GPIO1, GPIO2, GPIO3, GPIO4
				inout [7:0] gpio0_lines,
				inout [7:0] gpio1_lines,
				inout [7:0] gpio2_lines,
				inout [7:0] gpio3_lines,
				inout [7:0] gpio4_lines,
				
				// Shift register
				input         shreg_oe,
				input         shreg_clk,
				input         shreg_data,
				output [39:0] shreg_q,
				
				
				// Main UART
				
				// from/to DTE
				input  m_txd_from_dte_in ,
				output m_rxd_to_dte_out  ,
				input  m_rts_from_dte_in ,
				output m_cts_to_dte_out  ,
				input  m_dtr_from_dte_in ,
				output m_dsr_to_dte_out  ,
				output m_dcd_to_dte_out  ,
				output m_ri_to_dte_out   ,
				
				// from/to DCE
				output m_txd_to_dce_out  ,
				input  m_rxd_from_dce_in ,
				output m_rts_to_dce_out  ,
				input  m_cts_from_dce_in ,
				output m_dtr_to_dce_out  ,
				input  m_dsr_from_dce_in ,
				input  m_dcd_from_dce_in ,
				input  m_ri_from_dce_in  ,
				
				// Aux UART
				
				// from/to DTE
				input  s_txd_from_dte_in ,
				output s_rxd_to_dte_out  ,
				input  s_rts_from_dte_in ,
				output s_cts_to_dte_out  ,
				input  s_dtr_from_dte_in ,
				output s_dsr_to_dte_out  ,
				output s_dcd_to_dte_out  ,
				output s_ri_to_dte_out   ,
				
				// from/to DCE
				output s_txd_to_dce_out  ,
				input  s_rxd_from_dce_in ,
				output s_rts_to_dce_out  ,
				input  s_cts_from_dce_in ,
				output s_dtr_to_dce_out  ,
				input  s_dsr_from_dce_in ,
				input  s_dcd_from_dce_in ,
				input  s_ri_from_dce_in
				
/*				// frquency meter
				input  freq_meter_in,
				output square_out*/
				
				
            );
   // --------------------------------------------------------------------------

   // **************************************************************************
   // Heartbeat
   // **************************************************************************
	reg [26:0] hear_prescaler; // Was 24
	always @(posedge clk) begin
		hear_prescaler <= (hear_prescaler + 1'b1);
	end
	assign heartbeat = hear_prescaler[26]; // Was 24

	// SPI device signals from DEV ADDR
   wire w_mi_addr;
	wire w_en_addr;
	
	// SPI signals from ADC
	wire w_mi_adc; 
	wire w_i0_adc;
	wire w_i1_adc;
	wire w_en_adc;
	
	// SPI signals from DAC
	wire w_mi_dac; 
	wire w_i0_dac;
	wire w_i1_dac;
	wire w_en_dac;
	
	// VCCO POTS
	wire w_mi_lwsp;
	wire w_i0_vcco_pot;
	wire w_i1_vcco_pot;
	wire w_en_vcco_pot;
	// DUT POT
	wire w_mi_lwsp_pot;
	wire w_i0_pot;
	wire w_i1_pot;
	wire w_en_pot;
	// VBAT VGEN POT
	wire w_mi_lwsp_vbat_vgen_pot;
	wire w_i0_vbat_vgen_pot;
	wire w_i1_vbat_vgen_pot;
	wire w_en_vbat_vgen_pot;
	// IVMETER VBAT
	wire w_mi_lwsp_ivmeter_vbat;
	wire w_i0_ivmeter_vbat;
	wire w_i1_ivmeter_vbat;
	wire w_en_ivmeter_vbat;	
	// IVMETER VGEN
	wire w_mi_lwsp_ivmeter_vgen;
	wire w_i0_ivmeter_vgen;
	wire w_i1_ivmeter_vgen;
	wire w_en_ivmeter_vgen;	

	// GPO
	wire w_mi_gpo;
   wire w_en_gpo;	

	// GPO1
	wire w_mi_gpo1;
   wire w_en_gpo1;	
	
	// GPIO0
	wire w_mi_gpio0;
   wire w_en_gpio0;

	// GPIO1
	wire w_mi_gpio1;
   wire w_en_gpio1;

	// GPIO2
	wire w_mi_gpio2;
   wire w_en_gpio2;	
	
	// GPIO3
	wire w_mi_gpio3;
   wire w_en_gpio3;

	// GPIO4
	wire w_mi_gpio4;
   wire w_en_gpio4;
	
	// UART_MUX
	wire w_mi_uart_mux;
   wire w_en_uart_mux;
	
	// **************************************************************************
   // Driver to microcontroller
   // **************************************************************************
	u_driver u_driver1(
	         .clk(clk),
            // SPI device signals to uC
            .mi_u(mi_u),
            .i0_u(i0_u),
            .i1_u(i1_u),
				
				//-------------------

            // SPI device signals from DEV ADDR
            .mi_addr(w_mi_addr),
				.en_addr(w_en_addr),
				
				// SPI signals from ADC
				.mi_adc(w_mi_adc), 
				.i0_adc(w_i0_adc),
				.i1_adc(w_i1_adc),
				.en_adc(w_en_adc),
				
				// SPI signals from DAC
				.mi_dac(w_mi_dac), 
				.i0_dac(w_i0_dac),
				.i1_dac(w_i1_dac),
				.en_dac(w_en_dac),

				// VCCO POTS
            .mi_lwsp(w_mi_lwsp),				
				.i0_vcco_pot(w_i0_vcco_pot),
            .i1_vcco_pot(w_i1_vcco_pot),
				.en_vcco_pot(w_en_vcco_pot),
				
				// DUT POT
				.mi_lwsp_pot(w_mi_lwsp_pot),
				.i0_pot(w_i0_pot),
            .i1_pot(w_i1_pot),
				.en_pot(w_en_pot),
				
				// VBAT VGEN POT
				.mi_lwsp_vbat_vgen_pot(w_mi_lwsp_vbat_vgen_pot),
				.i0_vbat_vgen_pot(w_i0_vbat_vgen_pot),
				.i1_vbat_vgen_pot(w_i1_vbat_vgen_pot),
				.en_vbat_vgen_pot(w_en_vbat_vgen_pot),

				// IVMSTER VBAT
				.mi_lwsp_ivmeter_vbat(w_mi_lwsp_ivmeter_vbat),
				.i0_ivmeter_vbat(w_i0_ivmeter_vbat),
				.i1_ivmeter_vbat(w_i1_ivmeter_vbat),
				.en_ivmeter_vbat(w_en_ivmeter_vbat),				
				
				// IVMSTER VGEN
				.mi_lwsp_ivmeter_vgen(w_mi_lwsp_ivmeter_vgen),
				.i0_ivmeter_vgen(w_i0_ivmeter_vgen),
				.i1_ivmeter_vgen(w_i1_ivmeter_vgen),
				.en_ivmeter_vgen(w_en_ivmeter_vgen),

				// GPO
				.mi_gpo(w_mi_gpo),
            .en_gpo(w_en_gpo),	

				// GPO
				.mi_gpo1(w_mi_gpo1),
            .en_gpo1(w_en_gpo1),

				// GPIO0
				.mi_gpio0(w_mi_gpio0),
            .en_gpio0(w_en_gpio0),

				// GPIO1
				.mi_gpio1(w_mi_gpio1),
            .en_gpio1(w_en_gpio1),

				// GPIO2
				.mi_gpio2(w_mi_gpio2),
            .en_gpio2(w_en_gpio2),	

				// GPIO3
				.mi_gpio3(w_mi_gpio3),
            .en_gpio3(w_en_gpio3),		

				// GPIO4
				.mi_gpio4(w_mi_gpio4),
            .en_gpio4(w_en_gpio4),

				// UART MUX 
				.mi_uart_mux(w_mi_uart_mux),
            .en_uart_mux(w_en_uart_mux)				
	);
   
	// **************************************************************************
   // SPI address loader              
   // **************************************************************************
   wire [7:0]      w_addr;            
   addr_dev u1(                       
               .clk (clk),            
               .cs  (cs_addr_u),      
               .ck  (ck_u),      
               .mo  (mo_u),      
               .mi  (w_mi_addr),
					.en  (w_en_addr),
               .addr(w_addr)
               );

   // **************************************************************************
   // ADC              
   // **************************************************************************	
	wire w_cs_adc;
	wire w_ck_adc;
	wire w_mo_adc;
	wire w_o0_adc;
	wire w_o1_adc;
	defparam adc_u1.device_addr = 8'h08;
	spi_device adc_u1(
              .clk (clk),
              .addr(w_addr),
   
              .cs_u(cs_u), .ck_u(ck_u), .mo_u(mo_u), .mi_u(w_mi_adc),           
              .o0_u(o0_u), .o1_u(o1_u), .i0_u(w_i0_adc), .i1_u(w_i1_adc),

              .cs_dev(w_cs_adc), .ck_dev(w_ck_adc), .mo_dev(w_mo_adc), .mi_dev(mi_adc),
              .o0_dev(w_o0_adc), .o1_dev(w_o1_adc), .i0_dev(i0_adc), .i1_dev(i1_adc),
   
              .driver_latch_en(w_en_adc)
   
              );
				  
	dev_driver_x1 dev_driver_u1(
				.clk(clk),
				// Input
				.cs(w_cs_adc),
				.ck(w_ck_adc),
				.mo(w_mo_adc),
				.o0(w_o0_adc),
				.o1(w_o1_adc),
				.en(w_en_adc),
				// Output
				.cs_latch(cs_adc),
				.ck_latch(ck_adc),
				.mo_latch(mo_adc),
				.o0_latch(o0_adc),
				.o1_latch(o1_adc)
				
	);
	
   // **************************************************************************
   // DAC              
   // **************************************************************************
	wire w_cs_dac;
	wire w_ck_dac;
	wire w_mo_dac;
	wire w_o0_dac;
	wire w_o1_dac;	
	defparam dac_u1.device_addr = 8'h04;
	spi_device dac_u1(
              .clk (clk),
              .addr(w_addr),
   
              .cs_u(cs_u), .ck_u(ck_u), .mo_u(mo_u), .mi_u(w_mi_dac),           
              .o0_u(o0_u), .o1_u(o1_u), .i0_u(w_i0_dac), .i1_u(w_i1_dac),

              .cs_dev(w_cs_dac), .ck_dev(w_ck_dac), .mo_dev(w_mo_dac), .mi_dev(mi_dac),
              .o0_dev(w_o0_dac), .o1_dev(w_o1_dac), .i0_dev(i0_dac), .i1_dev(i1_dac),
   
              .driver_latch_en(w_en_dac)
   
              );
	dev_driver_x1 dev_driver_u2(
				.clk(clk),
				// Input
				.cs(w_cs_dac),
				.ck(w_ck_dac),
				.mo(w_mo_dac),
				.o0(w_o0_dac),
				.o1(w_o1_dac),
				.en(w_en_dac),
				// Output
				.cs_latch(cs_dac),
				.ck_latch(ck_dac),
				.mo_latch(mo_dac),
				.o0_latch(o0_dac),
				.o1_latch(o1_dac)
				
	);
				  
   // **************************************************************************
   // VCCO POT              
   // **************************************************************************	
	wire w_cs_vcco_pot;
	wire w_ck_vcco_pot;
	wire w_mo_vcco_pot;
	wire w_o0_vcco_pot;
	wire w_o1_vcco_pot;	
	defparam vcco_pot_u1.device_addr = 8'h11;
	spi_device vcco_pot_u1(
              .clk (clk),
              .addr(w_addr),
   
              .cs_u(cs_u), .ck_u(ck_u), .mo_u(mo_u), .mi_u(w_mi_lwsp),           
              .o0_u(o0_u), .o1_u(o1_u), .i0_u(w_i0_vcco_pot), .i1_u(w_i1_vcco_pot),

              .cs_dev(w_cs_vcco_pot), .ck_dev(w_ck_vcco_pot), .mo_dev(w_mo_vcco_pot), .mi_dev(mi_lwsp),
              .o0_dev(w_o0_vcco_pot), .o1_dev(w_o1_vcco_pot), .i0_dev(i0_vcco_pot), .i1_dev(i1_vcco_pot),
   
              .driver_latch_en(w_en_vcco_pot)
   
              );

   // **************************************************************************
   // DUT POT              
   // **************************************************************************
	wire w_cs_pot;
	wire w_ck_pot;
	wire w_mo_pot;
	wire w_o0_pot;
	wire w_o1_pot;	
	defparam dut_pot_u1.device_addr = 8'h20;
	spi_device dut_pot_u1(
              .clk (clk),
              .addr(w_addr),
   
              .cs_u(cs_u), .ck_u(ck_u), .mo_u(mo_u), .mi_u(w_mi_lwsp_pot),           
              .o0_u(o0_u), .o1_u(o1_u), .i0_u(w_i0_pot), .i1_u(w_i1_pot),

              .cs_dev(w_cs_pot), .ck_dev(w_ck_pot), .mo_dev(w_mo_pot), .mi_dev(mi_lwsp),
              .o0_dev(w_o0_pot), .o1_dev(w_o1_pot), .i0_dev(i0_pot), .i1_dev(i1_pot),
   
              .driver_latch_en(w_en_pot)
   
              );
				  
   // **************************************************************************
   // VBAT VGEN POT              
   // **************************************************************************				  
	wire w_cs_vbat_vgen_pot;
	wire w_ck_vbat_vgen_pot;
	wire w_mo_vbat_vgen_pot;
	wire w_o0_vbat_vgen_pot;
	wire w_o1_vbat_vgen_pot;	
	defparam vbat_vgen_pot_u1.device_addr = 8'h0C;
	spi_device vbat_vgen_pot_u1(
              .clk (clk),
              .addr(w_addr),
   
              .cs_u(cs_u), .ck_u(ck_u), .mo_u(mo_u), .mi_u(w_mi_lwsp_vbat_vgen_pot),           
              .o0_u(o0_u), .o1_u(o1_u), .i0_u(w_i0_vbat_vgen_pot), .i1_u(w_i1_vbat_vgen_pot),

              .cs_dev(w_cs_vbat_vgen_pot), .ck_dev(w_ck_vbat_vgen_pot), .mo_dev(w_mo_vbat_vgen_pot), .mi_dev(mi_lwsp),
              .o0_dev(w_o0_vbat_vgen_pot), .o1_dev(w_o1_vbat_vgen_pot), .i0_dev(i0_vbat_vgen_pot), .i1_dev(i1_vbat_vgen_pot),
   
              .driver_latch_en(w_en_vbat_vgen_pot)
   
              );	
				  

   // **************************************************************************
   // IVMETER VBAT               
   // **************************************************************************
	wire w_cs_ivmeter_vbat;
	wire w_ck_ivmeter_vbat;
	wire w_mo_ivmeter_vbat;
	wire w_o0_ivmeter_vbat;
	wire w_o1_ivmeter_vbat;	
	defparam ivmeter_vbat_u1.device_addr = 8'h0D;
	spi_device ivmeter_vbat_u1(
              .clk (clk),
              .addr(w_addr),
   
              .cs_u(cs_u), .ck_u(ck_u), .mo_u(mo_u), .mi_u(w_mi_lwsp_ivmeter_vbat),           
              .o0_u(o0_u), .o1_u(o1_u), .i0_u(w_i0_ivmeter_vbat), .i1_u(w_i1_ivmeter_vbat),

              .cs_dev(w_cs_ivmeter_vbat), .ck_dev(w_ck_ivmeter_vbat), .mo_dev(w_mo_ivmeter_vbat), .mi_dev(mi_lwsp),
              .o0_dev(w_o0_ivmeter_vbat), .o1_dev(w_o1_ivmeter_vbat), .i0_dev(i0_ivmeter_vbat), .i1_dev(i1_ivmeter_vbat),
   
              .driver_latch_en(w_en_ivmeter_vbat)
   
              );		  

   // **************************************************************************
   // IVMETER VGEN               
   // **************************************************************************
	wire w_cs_ivmeter_vgen;
	wire w_ck_ivmeter_vgen;
	wire w_mo_ivmeter_vgen;
	wire w_o0_ivmeter_vgen;
	wire w_o1_ivmeter_vgen;	
	defparam ivmeter_vgen_u1.device_addr = 8'h0F;
	spi_device ivmeter_vgen_u1(
              .clk (clk),
              .addr(w_addr),
   
              .cs_u(cs_u), .ck_u(ck_u), .mo_u(mo_u), .mi_u(w_mi_lwsp_ivmeter_vgen),           
              .o0_u(o0_u), .o1_u(o1_u), .i0_u(w_i0_ivmeter_vgen), .i1_u(w_i1_ivmeter_vgen),

              .cs_dev(w_cs_ivmeter_vgen), .ck_dev(w_ck_ivmeter_vgen), .mo_dev(w_mo_ivmeter_vgen), .mi_dev(mi_lwsp),
              .o0_dev(w_o0_ivmeter_vgen), .o1_dev(w_o1_ivmeter_vgen), .i0_dev(i0_ivmeter_vgen), .i1_dev(i1_ivmeter_vgen),
   
              .driver_latch_en(w_en_ivmeter_vgen)
   
              );				 

   // **************************************************************************
   // LOW SPEED SPI BUS DRIVER               
   // **************************************************************************				  
	dev_driver_x5 dev_driver_u4(
				.clk(clk),
				// Input VCCO POT
				.cs(w_cs_vcco_pot),
				.ck(w_ck_vcco_pot),
				.mo(w_mo_vcco_pot),
				.o0(w_o0_vcco_pot),
				.o1(w_o1_vcco_pot),
				.en(w_en_vcco_pot),
				// Input DUT POT
				.cs1(w_cs_pot),
				.ck1(w_ck_pot),
				.mo1(w_mo_pot),
				.o01(w_o0_pot),
				.o11(w_o1_pot),
				.en1(w_en_pot),
				// Input VGEN VBAT POT
				.cs2(w_cs_vbat_vgen_pot),
				.ck2(w_ck_vbat_vgen_pot),
				.mo2(w_mo_vbat_vgen_pot),
				.o02(w_o0_vbat_vgen_pot),
				.o12(w_o1_vbat_vgen_pot),
				.en2(w_en_vbat_vgen_pot),
				// Input IVMETER VBAT
				.cs3(w_cs_ivmeter_vbat),
				.ck3(w_ck_ivmeter_vbat),
				.mo3(w_mo_ivmeter_vbat),
				.o03(w_o0_ivmeter_vbat),
				.o13(w_o1_ivmeter_vbat),
				.en3(w_en_ivmeter_vbat),
				// Input IVMETER VGEN
				.cs4(w_cs_ivmeter_vgen),
				.ck4(w_ck_ivmeter_vgen),
				.mo4(w_mo_ivmeter_vgen),
				.o04(w_o0_ivmeter_vgen),
				.o14(w_o1_ivmeter_vgen),
				.en4(w_en_ivmeter_vgen),
				// Output
				.cs_latch(cs_vcco_pot),
				.ck_latch(ck_lwsp),
				.mo_latch(mo_lwsp),
				.o0_latch(o0_vcco_pot),
				.o1_latch(o1_vcco_pot),
				
				.cs_latch1(cs_pot),
				.o0_latch1(o0_pot),
				.o1_latch1(o1_pot),
				
				.cs_latch2(cs_vbat_vgen_pot),
				.o0_latch2(o0_vbat_vgen_pot),
				.o1_latch2(o1_vbat_vgen_pot),
				
				.cs_latch3(cs_ivmeter_vbat),
				.o0_latch3(o0_ivmeter_vbat),
				.o1_latch3(o1_ivmeter_vbat),
				
				.cs_latch4(cs_ivmeter_vgen),
				.o0_latch4(o0_ivmeter_vgen),
				.o1_latch4(o1_ivmeter_vgen)
				
	);	

   // **************************************************************************
   // GPO               
   // **************************************************************************

	defparam gpo_u1.device_addr = 8'h30;
	defparam gpo_u1.default_output = 8'h00;
	spi_gpo gpo_u1(
              .clk (clk),
              .addr(w_addr),
   
              .cs_u(cs_u), .ck_u(ck_u), .mo_u(mo_u), .mi_u(w_mi_gpo),           
				  
              .driver_latch_en(w_en_gpo),
				  
				  .gpo_out(gpo_out)
   
              );

   // **************************************************************************
   // GPO1               
   // **************************************************************************

	defparam gpo1_u1.device_addr = 8'h31;
	defparam gpo1_u1.default_output = 8'h04;
	spi_gpo gpo1_u1(
              .clk (clk),
              .addr(w_addr),
   
              .cs_u(cs_u), .ck_u(ck_u), .mo_u(mo_u), .mi_u(w_mi_gpo1),           
				  
              .driver_latch_en(w_en_gpo1),
				  
				  .gpo_out(gpo1_out)
   
              );	
				  
   // **************************************************************************
   // GPIO0               
   // **************************************************************************

	defparam gpio0_u1.device_addr = 8'h40;
	spi_gpio gpio0_u1(
              .clk (clk),
              .addr(w_addr),
   
              .cs_u(cs_u), .ck_u(ck_u), .mo_u(mo_u), .mi_u(w_mi_gpio0),           
				  
              .driver_latch_en(w_en_gpio0),
				  
				  .outputs(gpio0_lines)
   
              );	

   // **************************************************************************
   // GPIO1               
   // **************************************************************************

	defparam gpio1_u1.device_addr = 8'h41;
	spi_gpio gpio1_u1(
              .clk (clk),
              .addr(w_addr),
   
              .cs_u(cs_u), .ck_u(ck_u), .mo_u(mo_u), .mi_u(w_mi_gpio1),           
				  
              .driver_latch_en(w_en_gpio1),
				  
				  .outputs(gpio1_lines)
   
              );
				  
   // **************************************************************************
   // GPIO2               
   // **************************************************************************

	defparam gpio2_u1.device_addr = 8'h42;
	spi_gpio gpio2_u1(
              .clk (clk),
              .addr(w_addr),
   
              .cs_u(cs_u), .ck_u(ck_u), .mo_u(mo_u), .mi_u(w_mi_gpio2),           
				  
              .driver_latch_en(w_en_gpio2),
				  
				  .outputs(gpio2_lines)
   
              );
				  
   // **************************************************************************
   // GPIO3               
   // **************************************************************************

	defparam gpio3_u1.device_addr = 8'h43;
	spi_gpio gpio3_u1(
              .clk (clk),
              .addr(w_addr),
   
              .cs_u(cs_u), .ck_u(ck_u), .mo_u(mo_u), .mi_u(w_mi_gpio3),           
				  
              .driver_latch_en(w_en_gpio3),
				  
				  .outputs(gpio3_lines)
   
              );

   // **************************************************************************
   // GPIO4               
   // **************************************************************************

	defparam gpio4_u1.device_addr = 8'h44;
	spi_gpio gpio4_u1(
              .clk (clk),
              .addr(w_addr),
   
              .cs_u(cs_u), .ck_u(ck_u), .mo_u(mo_u), .mi_u(w_mi_gpio4),           
				  
              .driver_latch_en(w_en_gpio4),
				  
				  .outputs(gpio4_lines)
   
              );
				  
   // **************************************************************************
   // SHIFT REGISTER               
   // **************************************************************************				  
   shift_register shreg_u0(
                  .clk(clk),
						.shreg_oe(shreg_oe),
						.shreg_clk(shreg_clk),
						.shreg_data(shreg_data),
						.shreg_q(shreg_q)
              );

   // **************************************************************************
   // UART MUX               
   // **************************************************************************
	
	defparam uart_mux_u0.device_addr = 8'h54;
   spi_uart_mux uart_mux_u0(

		.clk(clk),
		.addr(w_addr),
		.cs_u(cs_u), 
		.ck_u(ck_u), 
		.mo_u(mo_u), 
		.mi_u(w_mi_uart_mux),

		.driver_latch_en(w_en_uart_mux),
		
		// Main UART

		// from/to DTE
		.m_txd_from_dte_in (m_txd_from_dte_in),
		.m_rxd_to_dte_out  (m_rxd_to_dte_out ),
		.m_rts_from_dte_in (m_rts_from_dte_in),
		.m_cts_to_dte_out  (m_cts_to_dte_out ),
		.m_dtr_from_dte_in (m_dtr_from_dte_in),
		.m_dsr_to_dte_out  (m_dsr_to_dte_out ),
		.m_dcd_to_dte_out  (m_dcd_to_dte_out ),
		.m_ri_to_dte_out   (m_ri_to_dte_out  ),

		// from/to DCE
		.m_txd_to_dce_out  (m_txd_to_dce_out ),
		.m_rxd_from_dce_in (m_rxd_from_dce_in),
		.m_rts_to_dce_out  (m_rts_to_dce_out ),
		.m_cts_from_dce_in (m_cts_from_dce_in),
		.m_dtr_to_dce_out  (m_dtr_to_dce_out ),
		.m_dsr_from_dce_in (m_dsr_from_dce_in),
		.m_dcd_from_dce_in (m_dcd_from_dce_in),
		.m_ri_from_dce_in  (m_ri_from_dce_in ),

		// Aux UART

		// from/to DTE
		.s_txd_from_dte_in (s_txd_from_dte_in),
		.s_rxd_to_dte_out  (s_rxd_to_dte_out ),
		.s_rts_from_dte_in (s_rts_from_dte_in),
		.s_cts_to_dte_out  (s_cts_to_dte_out ),
		.s_dtr_from_dte_in (s_dtr_from_dte_in),
		.s_dsr_to_dte_out  (s_dsr_to_dte_out ),
		.s_dcd_to_dte_out  (s_dcd_to_dte_out ),
		.s_ri_to_dte_out   (s_ri_to_dte_out  ),

		// from/to DCE
		.s_txd_to_dce_out  (s_txd_to_dce_out  ),
		.s_rxd_from_dce_in (s_rxd_from_dce_in ),
		.s_rts_to_dce_out  (s_rts_to_dce_out  ),
		.s_cts_from_dce_in (s_cts_from_dce_in ),
		.s_dtr_to_dce_out  (s_dtr_to_dce_out  ),
		.s_dsr_from_dce_in (s_dsr_from_dce_in ),
		.s_dcd_from_dce_in (s_dcd_from_dce_in ),
		.s_ri_from_dce_in	 (s_ri_from_dce_in  )				  

);
endmodule
