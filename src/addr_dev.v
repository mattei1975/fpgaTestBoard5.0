
module addr_dev(
		input 		 clk,
		input 		 cs,
		input 		 ck,
		input 		 mo,
		output 		 mi,
		output       en,
		output reg [7:0] addr = 8'h00
		);
	
	assign en = ~cs_sync;

	reg cs_sync_reg0 = 1'b0;
	reg ck_sync_reg0 = 1'b0;
	reg mo_sync_reg0 = 1'b0;
	reg cs_sync_reg1 = 1'b0;
	reg ck_sync_reg1 = 1'b0;
	reg mo_sync_reg1 = 1'b0;
	reg cs_sync_reg2 = 1'b0;
	reg ck_sync_reg2 = 1'b0;
	reg mo_sync_reg2 = 1'b0;
	
	
	wire cs_rise;
	wire cs_fall;
	wire cs_sync;

	wire ck_rise;
	wire ck_fall;
	
	wire mo_sync;
	
	
	reg [7:0] addr_to_line = 8'hAA;
	reg [7:0] addr_from_line = 8'h00;
	
	always @(posedge clk) begin
	
		cs_sync_reg2 <= cs_sync_reg1;
		cs_sync_reg1 <= cs_sync_reg0;
		cs_sync_reg0 <= cs;
		
		ck_sync_reg2 <= ck_sync_reg1;
		ck_sync_reg1 <= ck_sync_reg0;
		ck_sync_reg0 <= ck;

		mo_sync_reg2 <= mo_sync_reg1;
		mo_sync_reg1 <= mo_sync_reg0;
		mo_sync_reg0 <= mo;
		
	end;
	
	
	assign cs_rise  =  ~cs_sync_reg2 && cs_sync_reg1;
	assign cs_fall  =  cs_sync_reg2 &&  ~cs_sync_reg1;
	assign cs_sync  =  cs_sync_reg2;
	
	assign ck_rise  =  ~ck_sync_reg2 && ck_sync_reg1;
	assign ck_fall  =  ck_sync_reg2 &&  ~ck_sync_reg1;
	
	assign mo_sync  =  mo_sync_reg2;
	
	
	always @(posedge clk) begin
	
		if(cs_fall) begin
			addr_to_line   <= addr;
			addr_from_line <= 8'h00;
		end else if(cs_rise) begin
			addr <= addr_from_line;
		end
	
		if(~cs_sync && ck_fall) begin
			addr_to_line <= {addr_to_line[6:0],addr_to_line[7]};
		end
		
		if(~cs_sync && ck_rise) begin		
			addr_from_line <= {addr_from_line[6:0],mo_sync};
		end
	
	end
	
   assign mi = (~cs_sync) ? addr_to_line[7]	 : 1'b1;
		
endmodule
