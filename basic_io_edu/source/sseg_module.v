`timescale 1ns / 1ps

module sseg_module(
	input							clk,
   input 			[13:0] 	number,
   output reg 		[3:0] 	sseg_sel,
   output			[7:0] 	sseg_data
   );
	
	localparam 		freq_multiplier = 18; 			// 18 bits: count = 5ms per edge, sseg = 10ms per sseg, overall = 25Hz refresh
	
	reg	[freq_multiplier-1:0]	count = 0;
	reg 	[1:0]							digit = 0;

	always @(posedge clk)
			count <= count + 1;
	
	always @(posedge count[freq_multiplier-1])
		digit <= digit + 1;
		
	always @(digit)
		case(digit)
			2'd0: 	begin sseg_sel <= 4'b0001; end
			2'd1:		begin sseg_sel <= 4'b0010; end
			2'd2:		begin sseg_sel <= 4'b0100; end
			2'd3:		begin sseg_sel <= 4'b1000; end
			default:	begin sseg_sel <= 4'b1111; end
		endcase
	
	hex_encoder(number, digit, sseg_data);
	
endmodule
