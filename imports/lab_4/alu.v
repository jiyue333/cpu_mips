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
	input wire [4:0] sa,
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
			//移位指令6条
			`SLL_CONTROL   :  result = b << sa;  //指令SLL
			`SRL_CONTROL   :  result = b >> sa;  //指令SRL
			`SRA_CONTROL   :  result = ({32{b[31]}} << (6'd32-{1'b0, sa})) | b >> sa;  //指令SRA
			`SLLV_CONTROL  :  result = b << a[4:0];  //指令SLLV
			`SRLV_CONTROL  :  result = b >> a[4:0];  //指令SRLV
			`SRAV_CONTROL  :  result = $signed(b) >>> a[4:0]; //指令SRAV
			default:  result <= 32'b0;
		endcase
	end
endmodule
