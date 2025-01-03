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
	output wire hilowirte,
	output wire jalr,
	output wire jr,
	output wire jbral
    );
	reg[10:0] controls;

	// jbral ?��?lu澶勯?夋嫨pc�??8浣滀�???撳�??
	// jr 閫夋嫨�?�勫瓨�?�ㄤ綔涓簆c??撳�??
	// jalr ?��?� 5'd31 涓虹洰�?�勫??瀛樺櫒�?��?�潃 
	assign {regwrite,regdst,alusrc,branch,memwrite,memtoreg,jump,hilowirte,jalr,jr,jbral} = controls;
	always @(*) begin
		case (op)
			`R_TYPE: 
			case(funct)
				`ADD,`ADDU,`SUB,`SUBU,`SLT,`SLTU : 		controls <= 11'b11000000000;
				`DIV,`DIVU,`MULT,`MULTU, `MTHI,`MTLO: 	controls <= 11'b00000001000;
				`JR:									controls <= 11'b00000010010;
				`JALR:									controls <= 11'b11000010011;
				default: 								controls <= 11'b11000000000;	
			endcase
			`ADDI,`ADDIU,`SLTI,`SLTIU: controls <= 11'b10100000000; 
			`ANDI: controls <= 11'b10100000000;
        	`XORI: controls <= 11'b10100000000;
        	`LUI:  controls <= 11'b10100000000;
        	`ORI:  controls <= 11'b10100000000;
			`BEQ,`BNE,`BGTZ,`BLEZ:		controls <= 11'b00010000000;
			`REGIMM_INST:
				case (rt)
					`BGEZ,`BLTZ:		controls <= 11'b00010000000;
					`BGEZAL,`BLTZAL:	controls <= 11'b10010000101;
					default: 	controls <= 11'b00000000000;
				endcase
			// J-type
			`J:							controls <= 11'b00000010000;
			`JAL:						controls <= 11'b10000010101;
			`LB,`LBU,`LH,`LHU,`LW:		controls <= 11'b10100100000;
			`SB,`SH,`SW:				controls <= 11'b00101000000;
			default: 					controls <= 11'b00000000000;
		endcase
	end
endmodule
