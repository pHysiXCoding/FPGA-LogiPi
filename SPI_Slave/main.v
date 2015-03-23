`timescale 1ns / 1ps
//=================================================
// SPI SLAVE MODULE
//=================================================
module slave(
	input 	[15:0]	DATA,
	input					SCK,
	input					MOSI,
	input					CSbar,
	output reg			MISO,
	output reg [1:0] 	LEDS
	);

	reg	[15:0]	data_out = 16'b0;
	reg 				finished = 1'b0;
	reg 	[4:0]		counter 	= 5'b0;
	
	always @(posedge SCK) begin
		if (CSbar) begin
			finished 		<= 1'b0;
			counter			<= 5'b0;
			data_out 		<= DATA;
			MISO 				<= 1'bz;
		end
		else if (~finished) begin
			MISO 				<= data_out[15];
			
			//data_in 		<= {data_in[14:0], MOSI};
			data_out 		<= {data_out[14:0], 1'b0};
			
			counter 			<= counter + 1;

			finished 		<= counter[4];
		end
		else			
			MISO				<= 1'bz;
	end
	
	always @(posedge SCK) begin
			LEDS[0] <= ~CSbar;
			LEDS[1] <= finished;
	end
endmodule
//=================================================
// END SPI SLAVE MODULE
//=================================================	
	



//=================================================
// TOP LEVEL MODULE
//=================================================
module main(
	input 			iCLK_50,
	output 	[1:0]	LED,
	inout 	[7:0] PMOD1
   );

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// User declarations & instantiations:
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	reg [21:0] cnt;
	reg [15:0] cnt_slow = 16'hA001;
	
	wire CLK_50;
	wire CLK_20;
	wire CLK_10;
	wire CLK_5;
	
	clk_wiz_v3_6 clknetwork(
		// Clock in ports
		.CLK_IN1            (iCLK_50),
		// Clock out ports
		.CLK_OUT1           (CLK_50),
		.CLK_OUT2           (CLK_20),
		.CLK_OUT3           (CLK_10),
		.CLK_OUT4           (CLK_5)
		);
		
	slave SPI_SLAVE_INSTANT(
		.DATA		( cnt_slow ),
		.SCK 		( PMOD1[3] ),
		.MOSI 	( PMOD1[0] ),
		.MISO 	( PMOD1[1] ),
		.CSbar 	( PMOD1[2] ),
		.LEDS 	( LED )
		);

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// User code:
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	always @(posedge CLK_50) begin
		if (cnt[21])
			cnt 	<= 0;
		else
			cnt 	<= cnt + 1;
	end
	
	always @(posedge cnt[21])
		cnt_slow <= cnt_slow + 1;

endmodule
//=================================================
// END TOP LEVEL MODULE
//=================================================
