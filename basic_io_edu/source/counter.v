`timescale 1ns / 1ps

module counter(
   input 						clk,
	input							reset,
	input							en,
	input 						dir,
	output reg		[1:0]		leds,
	output 			[3:0]		sseg_sel,
	output			[7:0]		sseg_data
   );
	 
	localparam		clk_multiplier = 26; 						// 26 bits approx 1.3422Hz
	reg	[clk_multiplier-1:0]	clk_slow 	= 0;				// slow clock
	
	reg prev = 0;														// edge detection
	reg enable = 0;
	
	reg 	[13:0] 	counter = 14'd9990;							// counter
			
	always @(posedge clk)
	begin
		clk_slow <= clk_slow + 1;
		
		if (en && ~enable)
		begin
			enable 	<= 1;
			leds[0] 	<= 1;
		end
		
		else if (en && enable)
		begin
			enable 	<= 0;
			leds[0] 	<= 0;
		end
		else ;
		
		leds[1] <= dir ? 1 : 0;
			
		if (reset) 														// reset
			counter <= 14'd0;

		else if (clk_slow[clk_multiplier-1] && ~prev)		// posedge clk_slow
		begin
		
			prev <= 1;
			
			if (enable)													// enable
				if (dir)													// direction
					counter <= (counter == 0) 		? 9999 	: counter - 1;
				else
					counter <= (counter == 9999) 	? 0 		: counter + 1;
			else ;
		end
		
		else if (~clk_slow[clk_multiplier-1] && prev)		// negedge clk_slow
			prev <= 0;
			
		else ;
	end
	
	sseg_module(clk, counter, sseg_sel, sseg_data);

endmodule
