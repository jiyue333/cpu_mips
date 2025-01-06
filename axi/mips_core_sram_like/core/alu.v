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
	input wire clk, rst,
	input wire[31:0] a,b,
	input wire[4:0] op,
	input wire [4:0] sa,
	input wire [63:0] hilo_in,
	input wire[31:0] cp0data, //读取的CP0寄存器的值
	input wire isexceptM, //异常信号
	output reg[31:0] result,
	output reg[63:0] hilo_out, //用于写入HI、LO寄存器
	output wire div_ready,  //除法是否完成
	output reg div_stall,   //除法的流水线暂停控制
	output wire overflow 	 //溢出判断 
	);

	//div
	reg div_start;
	reg div_signed;
	reg [31:0] a_save; 
	reg [31:0] b_save;
	wire [63:0] div_result;
	reg double_sign; //凑运算结果的双符号位，处理整型溢出
	assign overflow = (op==`ADD_CONTROL || op==`SUB_CONTROL) & (double_sign ^ result[31]); 

	always @(*) begin
		double_sign = 0;
		hilo_out = 64'b0;
		if(rst | isexceptM) begin
			div_stall = 1'b0;
			div_start = 1'b0;
		end
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
			`SRA_CONTROL   :  result = $signed(b) >>> sa;  //指令SRA
			`SLLV_CONTROL  :  result = b << a[4:0];  //指令SLLV
			`SRLV_CONTROL  :  result = b >> a[4:0];  //指令SRLV
			`SRAV_CONTROL  :  result = $signed(b) >>> a[4:0]; //指令SRAV
			//数据移动指令4条
			`MFHI_CONTROL  :  result = hilo_in[63:32]; //指令MFHI
			`MFLO_CONTROL  :  result = hilo_in[31:0]; //指令MFLO
			`MTHI_CONTROL  :  hilo_out = {a,hilo_in[31:0]}; //指令MTHI
			`MTLO_CONTROL  :  hilo_out = {hilo_in[63:32],a}; //指令MTLO
			//算数运算指令14条
			`ADD_CONTROL   :  {double_sign,result} = {a[31],a} + {b[31],b}; //指令ADD、ADDI
			`ADDU_CONTROL  :  result = a + b; //指令ADDU、ADDIU
			`SUB_CONTROL   :  {double_sign,result} = {a[31],a} - {b[31],b}; //指令SUBUB
			`SUBU_CONTROL  :  result = a - b; //指令SUBU
			`SLT_CONTROL   :  result = $signed(a) < $signed(b) ? 32'b1 : 32'b0;  //指令SLT、SLTI
			`SLTU_CONTROL  :  result = a < b ? 32'b1 : 32'b0; //指令SLTU、SLTIU
			`MULT_CONTROL  :  hilo_out = $signed(a) * $signed(b); //指令MULT 
			`MULTU_CONTROL :  hilo_out = {32'b0, a} * {32'b0, b}; //指令MULTU
			`DIV_CONTROL   :  begin //指令DIV, 除法器控制状态机逻辑
					if(~div_ready & ~div_start) begin //~div_start : 为了保证除法进行过程中，除法源操作数不因ALU输入改变而重新被赋值
						//必须非阻塞赋值，否则时序不对
						div_start <= 1'b1;
						div_signed <= 1'b1;
						div_stall <= 1'b1;
						a_save <= a; //除法时保存两个操作数
						b_save <= b;
					end
					else if(div_ready) begin
						div_start <= 1'b0;
						div_signed <= 1'b1;
						div_stall <= 1'b0;
						hilo_out <= div_result;
					end
				end
				`DIVU_CONTROL  :  begin //指令DIVU, 除法器控制状态机逻辑
					if(~div_ready & ~div_start) begin //~div_start : 为了保证除法进行过程中，除法源操作数不因ALU输入改变而重新被赋值
						//必须非阻塞赋值，否则时序不对
						div_start <= 1'b1;
						div_signed <= 1'b0;
						div_stall <= 1'b1;
						a_save <= a; ////除法时保存两个操作数
						b_save <= b;
					end
					else if(div_ready) begin
						div_start <= 1'b0;
						div_signed <= 1'b0;
						div_stall <= 1'b0;
						hilo_out <= div_result;
					end
				end
			//特权指令
            `MTC0_CONTROL: result = b;
            `MFC0_CONTROL: result = cp0data;
			default        :  result = `ZeroWord;
		endcase
	end
	wire annul; //终止除法信号
	assign annul = ((op == `DIV_CONTROL)|(op == `DIVU_CONTROL)) & isexceptM;
	//接入除法器
	div div(clk,rst,div_signed,a_save,b_save,div_start,annul,div_result,div_ready);
endmodule
