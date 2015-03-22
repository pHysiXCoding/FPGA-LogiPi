`timescale 1ns / 1ps

module main(
	input 					clk,
	input 		[1:0] 	sw,
	input 		[1:0] 	btn_n,
	
	output 		[1:0] 	led,
	output 		[3:0]		an,
	output 		[7:0]		sseg
	);
		
	counter(clk, ~btn_n[1], ~btn_n[0], sw[1], led, an, sseg);
	
endmodule

