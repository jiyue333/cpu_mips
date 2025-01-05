`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/11/07 10:58:03
// Design Name: 
// Module Name: mips
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


module mips(
	input wire clk,rst,
	input wire [5:0]ext_int,
	output wire[31:0] pcF,
	input wire[31:0] instrF,
	output wire memwriteM,
	output wire[31:0] aluoutM,writedataM,
	input wire[31:0] readdataM, 
	output wire[3:0] selectM,
	output memreadM,
	//for debug
    output [31:0] debug_wb_pc     ,
    output [3:0] debug_wb_rf_wen  ,
    output [4:0] debug_wb_rf_wnum ,
    output [31:0] debug_wb_rf_wdata
    );
	
	wire breakD,syscallD,invalidD,eretD;
	wire [5:0] opD,functD;
	wire regdstE,alusrcE,pcsrcD,memtoregE,memtoregM,memtoregW,
			regwriteE,regwriteM,regwriteW;
	wire [4:0] alucontrolE;
	wire flushE,equalD;
	wire [31:0] instrD;
	wire [4:0] saE;
	wire hilowirteE;
	wire jrD;
	wire jalrD;
	wire jbralD;
	wire jalrE;
	wire jbralE;
	wire cp0readE;
	wire flushM;
    wire flushW;
	wire cp0weW;
	wire cp0weM;

	controller c(
		clk,rst,
		//decode stage
		instrD,
		pcsrcD,branchD,equalD,jumpD,
		jrD,		
		breakD,syscallD,invalidD,eretD,jalrD,jbralD,
		//execute stage
		flushE,
		memtoregE,alusrcE,
		regdstE,regwriteE,	
		alucontrolE,
		saE,
		hilowirteE,
		jalrE,
		jbralE,
		cp0readE,
		//mem stage
		flushM,
		memtoregM,memwriteM,
		regwriteM,
		cp0weM,
		memreadM,
		//write back stage
		flushW,
		memtoregW,regwriteW,
		cp0weW
		);
	datapath dp(
		clk,rst,
		ext_int,
		//fetch stage
		pcF,
		instrF,
		//decode stage
		pcsrcD,branchD,
		jumpD,
		equalD,
		opD,functD,
		instrD,
		jrD,
		breakD,syscallD,invalidD,eretD,jalrD,jbralD,
		//execute stage
		memtoregE,
		alusrcE,regdstE,
		regwriteE,
		alucontrolE,
		saE,
		hilowirteE,
		jalrE,
		jbralE,
		flushE,
		cp0readE,
		//mem stage
		memtoregM,
		regwriteM,
		aluoutM,writedataM,
		readdataM,
		selectM,
		cp0weM,
		flushM,
		//writeback stage
		memtoregW,
		regwriteW,
		cp0weW,
		flushW,
		debug_wb_pc,
		debug_wb_rf_wen,
		debug_wb_rf_wnum,
		debug_wb_rf_wdata
	    );
	
endmodule
