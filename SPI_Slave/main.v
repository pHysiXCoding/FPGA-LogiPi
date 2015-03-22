`timescale 1ns / 1ps

module main(
	iCLK_50,

			
	LED,
	PB,
	SW,

	PMOD1,
	
	SCK,
	SSEL,
	MOSI,
	MISO
   );
//================================================
// Ports:
//================================================
	input 				iCLK_50;

	output reg 	[1:0] 	LED;
	input 	[1:0] 	PB;
	input 	[1:0] 	SW;

	inout  	[7:0] 	PMOD1;
	
	
	wire clk;
	wire clk_50;
	
	clk_wiz_v3_6 clknetwork
   (// Clock in ports
    .CLK_IN1            (iCLK_50),
    // Clock out ports
    .CLK_OUT1           (clk_50),
    .CLK_OUT2           (clk)
	 );
	
	
//================================================
// SPI:
//================================================
	wire  				CS_SPI;
	wire  				SDI_SPI;
	reg 					SDO_SPI;
	wire 					SCLK_SPI;
	
	assign 				CS_SPI 			= PMOD1[0];
	assign 				SDI_SPI 			= PMOD1[1];
	//assign 				PMOD1[2] 		= SDO_SPI;
	assign 				SCLK_SPI 		= PMOD1[3];
	
	reg		[15:0]	test 				= 16'h0000;

	//assign 				LED[0] 			= CS_SPI;
	
	input SCK, SSEL, MOSI;
	output MISO;

	
//================================================
// User declarations & Instantiations:
//================================================

	
//================================================
// User code:
//================================================

// Negedge ~CS = new frame: FRAME N

	// sync SCK to the FPGA clock using a 3-bits shift register
	reg [2:0] SCKr;  
	always @(posedge clk) 
		SCKr <= {SCKr[1:0], SCLK_SPI};
		
	wire SCK_risingedge = (SCKr[2:1]==2'b01);  // now we can detect SCK rising edges
	wire SCK_fallingedge = (SCKr[2:1]==2'b10);  // and falling edges

	// same thing for SSEL
	reg [2:0] SSELr;  
	
	always @(posedge clk) 
		SSELr <= {SSELr[1:0], CS_SPI};
	
	wire SSEL_active = ~SSELr[1];  // SSEL is active low
	wire SSEL_startmessage = (SSELr[2:1]==2'b10);  // message starts at falling edge
	wire SSEL_endmessage = (SSELr[2:1]==2'b01);  // message stops at rising edge

	// and for MOSI
	reg [1:0] MOSIr;  
	always @(posedge clk) 
		MOSIr <= {MOSIr[0], SDI_SPI};
	
	wire MOSI_data = MOSIr[1];
	
	
	
	always @(posedge clk) begin
		if (SSEL_active)
			LED[0] = 1;
		else 
			LED[0] = 0;
	end
	
	
	always @(posedge clk) begin
		if(byte_two_received) 
			LED[1] <= 1;
		else
			LED[1] <= 0;
	end
	
	
	always @(posedge clk)
		LED[0] <= SSEL_active;
	
//	reg [23:0] testx = 24'b0;
//	always @(posedge clk)
//		testx = testx + 1;
//	
//	assign LED[0] = testx[23];
//	
//	assign LED[1] = counter_slow[25];
	
	reg 		[11:0] 	counter 			= 12'hF0FA;
	reg		[26:0]	counter_slow  	= 27'b0;
	
	always @(posedge clk_50) begin
		// Sample for FRAME N-1:
		if (counter_slow[26])
			counter_slow <= 0;
		else
			counter_slow <= counter_slow + 1;
	end
	
	always @(posedge counter_slow[26])
		counter = counter + 1;
	
	//assign LED[0] = 1;
	
	
	
	

	// we handle SPI in 16-bits format, so we need a 4 bits counter to count the bits as they come in
	reg [3:0] bitcnt;

//	reg byte_two_received;  // high when a byte has been received
//	reg [15:0] byte_data_received = 16'h0000;

////	always @(posedge clk)
////	begin
////	  if(~SSEL_active)
////		 bitcnt <= 4'b0000;
////	  else
////	  if(SCK_risingedge)
////	  begin
////		 bitcnt <= bitcnt + 4'b0001;
////
////		 // implement a shift-left register (since we receive the data MSB first)
////		 byte_data_received <= {byte_data_received[14:0], MOSI_data};
////	  end
////	end
////
//
////	always @(posedge clk) 
////		byte_two_received <= SSEL_active && SCK_risingedge && (bitcnt==4'b1111);
//
//
//
//
//
//
//
//
//
//
	reg [15:0] byte_data_sent;

	always @(posedge clk) begin
		if(SSEL_active) begin
			if(SSEL_startmessage)
				byte_data_sent <= {byte_data_received[10:7], 12'hAAA};  // first byte sent in a message is the message count
			else
				//if(SCK_fallingedge) begin
					//if(bitcnt==4'b0000)
					//	byte_data_sent <= 16'h0000;  // after that, we send 0s
					//else
						byte_data_sent <= {byte_data_sent[14:0], 1'b0};
		  end
	end

	assign PMOD1[2] = byte_data_sent[15];  // send MSB first
	// we assume that there is only one slave on the SPI bus
	// so we don't bother with a tri-state buffer for MISO
	// otherwise we would need to tri-state MISO when SSEL is inactive



		
	
endmodule
