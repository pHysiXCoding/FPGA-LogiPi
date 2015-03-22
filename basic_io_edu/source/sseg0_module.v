`timescale 1ns / 1ps

module sseg0_module(
   input 			[3:0] 	number,
   output 					 	sseg_sel,
   output reg		[7:0] 	sseg_data
   );
	
	assign sseg_sel = 1;
	
	hex_encoder(number, sseg_data);
		
endmodule
