`timescale 1ns / 1ps
//=================================================
// SPI SLAVE MODULE
//=================================================
module slave(
	input 	[11:0]	DATA,
	input					SCK,
	input					MOSI,
	input					CSbar,
	output reg			MISO,
	output reg [1:0] 	LEDS
	);
	
	reg	[15:0]	data_in 	= 16'b0;
	reg	[15:0]	data_out = 16'b0;
	reg	[1:0]		finished = 2'b00;			// [INPUT OUTPUT]
	reg	[4:0]		icounter = 5'b0;
	reg	[4:0]		ocounter = 5'b0;
	
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// MISO Component (Slave Output/Master Input):
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	
	always @(posedge SCK) begin
		case (CSbar)
		1'b1: begin
			finished[0] 	<= 1'b0;
			ocounter			<= 5'b0;
			//data_out 		<= {data_in};
			data_out			<= {data_in[10:7], DATA};
			MISO 				<= 1'bz;
		end
		1'b0: begin
			case (finished[0])
			1'b0: begin
				MISO 			<= data_out[15];
				data_out 	<= {data_out[14:0], 1'b0};
			
				ocounter 	<= ocounter + 1;
				finished[0] <= ocounter[4];
			end
			1'b1:			
				MISO			<= 1'bz;
			endcase
		end
		endcase
	end
	
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	
// MOSI Component (Slave Input/Master Output):
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	
	always @(posedge SCK) begin
		case (CSbar)
		1'b1: begin
			icounter 		<= 1'b0;
			finished[1] 	<= 1'b0;
		end

		1'b0: begin
			case (finished[1])
			1'b0: begin
				data_in 		<= {data_in[14:0], MOSI};
				
				icounter 	<= icounter + 1;
				finished[1]	<= icounter[4];
			end
			1'b1: begin
				finished[1] <= 1'b1;
			end
			endcase
		end
		endcase
	end

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	
// Module I/O:
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~		
	always @(posedge SCK) begin
		LEDS[0] <= data_in[12];
		LEDS[1] <= (finished[1] & finished[0]);
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
	reg [11:0] cnt_slow = 12'h000;
	
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
