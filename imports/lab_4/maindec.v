`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/10/23 15:21:30
// Design Name: 
// Module Name: maindec
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


module maindec(
	input wire[5:0] op,
	input wire[5:0] funct,
	input wire[4:0] rs,
	input wire[4:0] rt,
	output wire memtoreg,memwrite,
	output wire branch,alusrc,
	output wire regdst,regwrite,
	output wire jump,
	output wire hilowirte
    );
	reg[7:0] controls;
	assign {regwrite,regdst,alusrc,branch,memwrite,memtoreg,jump,hilowirte} = controls;
	always @(*) begin
		case (op)
			`R_TYPE: 
			case(funct)
				`ADD,`ADDU,`SUB,`SUBU,`SLT,`SLTU,
				`DIV,`DIVU,`MULT,`MULTU: controls <= 8'b11000000;
				`MTHI,`MTLO: 	controls <= 8'b00000001;
            	default: 		controls <= 8'b11000000;	
			endcase
			`ADDI,`ADDIU,`SLTI,`SLTIU: controls <= 8'b10100000; 
			`ANDI: controls <= 8'b10100000;
        	`XORI: controls <= 8'b10100000;
        	`LUI:  controls <= 8'b10100000;
        	`ORI:  controls <= 8'b10100000;
			default: controls <= 8'b00000000;
		endcase
	end
endmodule
