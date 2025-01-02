`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/11/02 14:52:16
// Design Name: 
// Module Name: alu
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

`include "../utils/defines2.vh"

module alu(
	input wire[31:0] a,b,
	input wire[4:0] op,
	output reg[31:0] result
);
	always @(*) begin
		case(op)
			//閫昏緫杩愮畻8鏉?
			`AND_CONTROL   :  result = a & b;  //鎸囦护AND銆丄NDI
			`OR_CONTROL    :  result = a | b;  //鎸囦护OR銆丱RI
			`XOR_CONTROL   :  result = a ^ b;  //鎸囦护XOR
			`NOR_CONTROL   :  result = ~(a | b);  //鎸囦护NOR銆乆ORI
			`LUI_CONTROL   :  result = {b[15:0],16'b0}; //鎸囦护LUI
			default:  result <= 32'b0;
		endcase
	end
endmodule
