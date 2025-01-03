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
	input wire [63:0] hilo_in,
	output reg[31:0] result,
	output reg[63:0] hilo_out //用于写入HI、LO寄存器
);
	always @(*) begin
		hilo_out = 64'b0;
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
			//数据移动指令4条
			`MFHI_CONTROL  :  result = hilo_in[63:32]; //指令MFHI
			`MFLO_CONTROL  :  result = hilo_in[31:0]; //指令MFLO
			`MTHI_CONTROL  :  hilo_out = {a,hilo_in[31:0]}; //指令MTHI
			`MTLO_CONTROL  :  hilo_out = {hilo_in[63:32],a}; //指令MTLO
			default:  result <= 32'b0;
		endcase
	end
endmodule
