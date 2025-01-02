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


module maindec(
	input wire[5:0] op,
	input wire[5:0] funct,
	input wire[4:0] rs,
	input wire[4:0] rt,
	output wire memtoreg,memwrite,
	output wire branch,alusrc,
	output wire regdst,regwrite,
	output wire jump,
    );
	reg[6:0] controls;
	assign {regwrite,regdst,alusrc,branch,memwrite,memtoreg,jump} = controls;
	always @(*) begin
		case (op)
			`R_TYPE: 
			case(instrD)
            	32'b0: controls <= 7'b0000000;
            	default: controls <= 7'b1100000;	
			endcase
			`ANDI: controls <= 7'b1010000;
        	`XORI: controls <= 7'b1010000;
        	`LUI:  controls <= 7'b1010000;
        	`ORI:  controls <= 7'b1010000;
			default: controls <= 7'b0000000;
		endcase
	end
endmodule
