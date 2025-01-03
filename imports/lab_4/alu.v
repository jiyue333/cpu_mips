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
			//逻辑运算8�?
			`AND_CONTROL   :  result = a & b;  //指令AND、ANDI
			`OR_CONTROL    :  result = a | b;  //指令OR、ORI
			`XOR_CONTROL   :  result = a ^ b;  //指令XOR
			`NOR_CONTROL   :  result = ~(a | b);  //指令NOR、XORI
			`LUI_CONTROL   :  result = {b[15:0],16'b0}; //指令LUI
			//��λָ��6��
			`SLL_CONTROL   :  result = b << sa;  //ָ��SLL
			`SRL_CONTROL   :  result = b >> sa;  //ָ��SRL
			`SRA_CONTROL   :  result = ({32{b[31]}} << (6'd32-{1'b0, sa})) | b >> sa;  //ָ��SRA
			`SLLV_CONTROL  :  result = b << a[4:0];  //ָ��SLLV
			`SRLV_CONTROL  :  result = b >> a[4:0];  //ָ��SRLV
			`SRAV_CONTROL  :  result = $signed(b) >>> a[4:0]; //ָ��SRAV
			default:  result <= 32'b0;
		endcase
	end
endmodule
