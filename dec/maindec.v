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
	input wire[31:0] instr,
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
	output wire jbral,
	output wire break,syscall,cp0we,cp0read,eret,
	output reg invalid
    );
	reg[10:0] controls;

	// jbral ?¦â?luæ¾¶å‹¯?å¤‹å«¨pcæ¶??8æµ£æ»€è´???æ’³å??
	// jr é–«å¤‹å«¨ç?µå‹«ç“¨é?£ã„¤ç¶”æ¶“ç°†c??æ’³å??
	// jalr ?‚æ?¿î–ƒ 5'd31 æ¶“è™¹æ´°é?¨å‹«??ç€›æ¨ºæ«’é?¦æ?¿æ½ƒ 
	assign {regwrite,regdst,alusrc,branch,memwrite,memtoreg,jump,hilowirte,jalr,jr,jbral} = controls;
	always @(*) begin
		invalid = 1'b0;
		case (op)
			`R_TYPE: 
			case(funct)
				`ADD,`ADDU,`SUB,`SUBU,`SLT,`SLTU : 		controls <= 11'b11000000000;
				`DIV,`DIVU,`MULT,`MULTU, `MTHI,`MTLO: 	controls <= 11'b00000001000;
				`JR:									controls <= 11'b00000010010;
				`JALR:									controls <= 11'b11000010011;
				// todo 
				`BREAK: controls <= 11'b11000010011;
			    `SYSCALL: controls <= 11'b11000010011;
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
			`SPECIAL3_INST:
                case(instr[25:21])
					// todo
					`MFC0: 			controls <= 11'b10000000000;
                    `MTC0,`ERET:	controls <= 11'b00000000000;
                     default: invalid = 1; 
                endcase
			default:  begin
				controls <= 11'b00000000000;
				invalid = 1; 
			end
		endcase
	end
	// ????
    assign break = (op == `R_TYPE && funct == `BREAK); 
    assign syscall = (op == `R_TYPE && funct == `SYSCALL);
              
   // ????
   assign cp0we = (instr[31:21] == 11'b0100_0000_100 && instr[10:0] == 11'b00000000000); //MTC0
   assign cp0read = (instr[31:21] == 11'b01000000000 && instr[10:0] == 11'b00000000000); //MFC0 
   assign eret = (instr == 32'b01000010000000000000000000011000); //ERET
endmodule
