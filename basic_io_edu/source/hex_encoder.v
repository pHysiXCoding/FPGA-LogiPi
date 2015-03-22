`timescale 1ns / 1ps

module hex_encoder(
   input 			[13:0] 	number,
	input				[1:0]		digit,
   output reg		[7:0] 	code
   );
	
	reg 				[3:0]		temp;
	
	always @(number or digit or temp)
	begin
		case(digit)
			2'd0: 		temp = number 			% 10;
			2'd1:			temp = (number/10)  	% 10;
			2'd2:			temp = (number/100)	% 10;
			2'd3:			temp = (number/1000) % 10;
			default:	;
		endcase
	
		case(temp)
			4'b0000: 	code <= 7'b0111111;
			4'b0001: 	code <= 7'b0000110;
			4'b0010: 	code <= 7'b1011011;
			4'b0011: 	code <= 7'b1001111;
			4'b0100: 	code <= 7'b1100110;
			4'b0101: 	code <= 7'b1101101;
			4'b0110: 	code <= 7'b1111101;
			4'b0111: 	code <= 7'b0000111;
			4'b1000: 	code <= 7'b1111111;
			4'b1001: 	code <= 7'b1101111;
			4'b1010: 	code <= 7'b1110111;
			4'b1011: 	code <= 7'b1111100;
			4'b1100: 	code <= 7'b0111001;
			4'b1101: 	code <= 7'b1011110;
			4'b1110: 	code <= 7'b1111001;
			4'b1111: 	code <= 7'b1110001;
			default: 	code <= 7'b1000000;
		endcase
	end
	
endmodule
