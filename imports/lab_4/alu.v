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
	output reg[63:0] hilo_out //����д��HI��LO�Ĵ���
	// output wire div_ready,  //�����Ƿ����
	// output reg div_stall,   //��������ˮ����ͣ����
);

	//div
	reg div_start;
	reg div_signed;
	reg [31:0] a_save; 
	reg [31:0] b_save;
	wire [63:0] div_result;

	always @(*) begin
		hilo_out = 64'b0;
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
			//�����ƶ�ָ��4��
			`MFHI_CONTROL  :  result = hilo_in[63:32]; //ָ��MFHI
			`MFLO_CONTROL  :  result = hilo_in[31:0]; //ָ��MFLO
			`MTHI_CONTROL  :  hilo_out = {a,hilo_in[31:0]}; //ָ��MTHI
			`MTLO_CONTROL  :  hilo_out = {hilo_in[63:32],a}; //ָ��MTLO
			//��������ָ��14��
			`ADD_CONTROL   :  result = a + b; //ָ��ADD��ADDI
			`ADDU_CONTROL  :  result = a + b; //ָ��ADDU��ADDIU
			`SUB_CONTROL   :  result = a - b; //ָ��SUB
			`SUBU_CONTROL  :  result = a - b; //ָ��SUBU
			`SLT_CONTROL   :  result = $signed(a) < $signed(b) ? 32'b1 : 32'b0;  //ָ��SLT��SLTI
			`SLTU_CONTROL  :  result = a < b ? 32'b1 : 32'b0; //ָ��SLTU��SLTIU
			`MULT_CONTROL  :  hilo_out = $signed(a) * $signed(b); //ָ��MULT 
			`MULTU_CONTROL :  hilo_out = {32'b0, a} * {32'b0, b}; //ָ��MULTU
			`DIV_CONTROL   :  hilo_out = {$signed(a) % $signed(b), $signed(a) / $signed(b)};
			`DIVU_CONTROL  :  hilo_out = {a % b, a / b}; 
			// `DIV_CONTROL   :  begin //ָ��DIV, ����������״̬���߼�
			// 	if(~div_ready & ~div_start) begin //~div_start : Ϊ�˱�֤�������й����У�����Դ����������ALU����ı�����±���ֵ
			// 		//�����������ֵ������ʱ�򲻶�
			// 		div_start <= 1'b1;
			// 		div_signed <= 1'b1;
			// 		div_stall <= 1'b1;
			// 		a_save <= a; //����ʱ��������������
			// 		b_save <= b;
			// 	end
			// 	else if(div_ready) begin
			// 		div_start <= 1'b0;
			// 		div_signed <= 1'b1;
			// 		div_stall <= 1'b0;
			// 		hilo_out <= div_result;
			// 	end
			// end
			// `DIVU_CONTROL  :  begin //ָ��DIVU, ����������״̬���߼�
			// 	if(~div_ready & ~div_start) begin //~div_start : Ϊ�˱�֤�������й����У�����Դ����������ALU����ı�����±���ֵ
			// 		//�����������ֵ������ʱ�򲻶�
			// 		div_start <= 1'b1;
			// 		div_signed <= 1'b0;
			// 		div_stall <= 1'b1;
			// 		a_save <= a; ////����ʱ��������������
			// 		b_save <= b;
			// 	end
			// 	else if(div_ready) begin
			// 		div_start <= 1'b0;
			// 		div_signed <= 1'b0;
			// 		div_stall <= 1'b0;
			// 		hilo_out <= div_result;
			// 	end
			// end
			default:  result <= 32'b0;
		endcase
	end
	// wire annul; //��ֹ�����ź�
	// assign annul = (op == `DIV_CONTROL)|(op == `DIVU_CONTROL);
	// div div(clk,rst,div_signed,a_save,b_save,div_start,annul,div_result,div_ready);
endmodule
