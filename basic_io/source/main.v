`timescale 1ns / 1ps

module main(OSC_FPGA, LED, PB, SW);
   input 				OSC_FPGA;
	input 	[1:0] 	PB;
   input 	[1:0] 	SW;
	 
	output 	[1:0] 	LED;
    
	reg		[31:0] 	counter;
	reg		[1:0]		counter_pb;
	
//	always @(posedge PB[0])
//	begin
//		counter_pb = counter_pb + 1;
//	end
	
//	always @(posedge OSC_FPGA)
//	begin
		//counter = counter + 1;
		
//		if (counter_pb > 3)		
//		begin
//			counter = 0;
//		end
//	end
	
	//always @(posedge SW[0])
	//begin
	//	counter_pb = SW[1:0];
	//end
	
	//assign LED = counter_pb;
	
	//assign LED = SW;
	assign LED[0] = 1;
	assign LED[1] = 0;
	
endmodule
