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
					//数据移动
					`MFHI:      alucontrol = `MFHI_CONTROL;
					`MTHI:      alucontrol = `MTHI_CONTROL;
					`MFLO:      alucontrol = `MFLO_CONTROL;
					`MTLO:      alucontrol = `MTLO_CONTROL;
					//算术运算
					`ADD:		alucontrol = `ADD_CONTROL;
					`ADDU:		alucontrol = `ADDU_CONTROL;
					`SUB:		alucontrol = `SUB_CONTROL;
					`SUBU:		alucontrol = `SUBU_CONTROL;
					`SLT:		alucontrol = `SLT_CONTROL;
					`SLTU:		alucontrol = `SLTU_CONTROL;
					`DIV:		alucontrol = `DIV_CONTROL;
					`DIVU:		alucontrol = `DIVU_CONTROL;
					`MULT:		alucontrol = `MULT_CONTROL;
					`MULTU:		alucontrol = `MULTU_CONTROL;
					//跳转指令      
					`JALR:      alucontrol = `ADDU_CONTROL;
					default:  alucontrol   = 5'b00000;
				endcase
			//逻辑运算
			`ANDI:		alucontrol = `AND_CONTROL;
			`LUI:		alucontrol = `LUI_CONTROL; 
			`ORI:		alucontrol = `OR_CONTROL;
			`XORI:		alucontrol = `XOR_CONTROL;
			//算术运算
			`ADDI:		alucontrol = `ADD_CONTROL;
			`ADDIU:		alucontrol = `ADDU_CONTROL;
			`SLTI:		alucontrol = `SLT_CONTROL;
			`SLTIU:		alucontrol = `SLTU_CONTROL;
				//跳转链接�?
			`REGIMM_INST:
				case(rt)		
					`BGEZAL, `BLTZAL:	alucontrol = `ADDU_CONTROL; //做加�?
					default:    alucontrol = 5'b00000;
				endcase	
			`JAL : alucontrol = `ADDU_CONTROL; //做加�?
			default:  alucontrol   = 5'b00000;
		endcase
	
	end
endmodule
