`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/12/12 11:26:03
// Design Name: 
// Module Name: hilo_reg
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


module hilo_reg(
	input  wire clk,rst,we,
	input wire[63:0] hilo_in, //写入值
	output wire[63:0] hilo_out //读出值
    );
	reg [63:0] hilo_reg; //HILO寄存器
	always @(negedge clk) begin
        if(rst)begin
            hilo_reg <= 0;
        end
		else if(we) begin
			 hilo_reg <= hilo_in;
		end
	end
	assign hilo_out = hilo_reg;
endmodule
