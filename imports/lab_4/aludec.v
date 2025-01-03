`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/10/23 15:27:24
// Design Name: 
// Module Name: aludec
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

module aludec(
	input wire[5:0] funct,
	input wire[5:0] op,
	input wire[4:0] rs,
	input wire[4:0] rt,
	output reg[4:0] alucontrol
    );
	always @(*) begin
		case (op)
			`R_TYPE:
				case (funct)
					//逻辑运算
					`AND:		alucontrol = `AND_CONTROL;
					`NOR:		alucontrol = `NOR_CONTROL;
					`OR:		alucontrol = `OR_CONTROL;
					`XOR:		alucontrol = `XOR_CONTROL;
					//移位
					`SLLV:		alucontrol = `SLLV_CONTROL;
					`SLL:		alucontrol = `SLL_CONTROL;
					`SRAV:		alucontrol = `SRAV_CONTROL;
					`SRA:		alucontrol = `SRA_CONTROL;
					`SRLV:		alucontrol = `SRLV_CONTROL;
					`SRL:		alucontrol = `SRL_CONTROL;
					default:  alucontrol   <= 5'b00000;
				endcase
			//逻辑运算
			`ANDI:		alucontrol = `AND_CONTROL;
			`LUI:		alucontrol = `LUI_CONTROL; 
			`ORI:		alucontrol = `OR_CONTROL;
			`XORI:		alucontrol = `XOR_CONTROL;

			default:  alucontrol   <= 5'b00000;
		endcase
	
	end
endmodule
