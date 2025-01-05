`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/10/23 15:21:30
// Design Name: 
// Module Name: controller
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


module controller(
	input wire clk,rst,
	//decode stage
	input wire [31:0] instrD,
	output wire pcsrcD,branchD,equalD,jumpD,
	output wire jrD,
	output wire breakD,syscallD,invalidD,eretD,jalrD,jbralD,
	//execute stage
	input wire flushE,
	output wire memtoregE,alusrcE,
	output wire regdstE,regwriteE,	
	output wire[4:0] alucontrolE,
	output wire[4:0] saE,
	output wire hilowirteE,
	output wire jalrE, 
	output wire jbralE,
	output wire cp0readE,
	//mem stage
	input wire flushM,
	output wire memtoregM,memwriteM,
				regwriteM,
	output wire cp0weM,
	//write back stage
	input wire flushW,
	output wire memtoregW,regwriteW,
	output cp0weW
    );
	
	//decode stage
	wire memtoregD,memwriteD,alusrcD,
		regdstD,regwriteD,hilowirteD;
	wire[4:0] alucontrolD;
		wire [5:0] opD;
	wire [5:0] functD;
	wire [4:0] rsD;
	wire [4:0] rtD;
	wire [4:0] saD;

	assign opD = instrD[31:26];
	assign functD = instrD[5:0];
	assign rsD = instrD[25:21];
	assign rtD = instrD[20:16];
	assign saD = instrD[10:6];
	wire cp0weD,cp0readD;

	//execute stage
	wire memwriteE;
	wire cp0weE;
	wire eretE;

	maindec md(
		instrD,
		opD,
		functD,
		rsD,
		rtD,
		memtoregD,memwriteD,
		branchD,alusrcD,
		regdstD,regwriteD,
		jumpD,
		hilowirteD,
		jalrD,
		jrD,
		jbralD,
		breakD,syscallD,
        cp0weD,cp0readD,eretD,invalidD
		);
	aludec ad(functD,opD,rsD,rtD,alucontrolD);

	assign pcsrcD = branchD & equalD;

	//pipeline registers
	floprc #(32) regE(
		clk,
		rst,
		flushE,
		{memtoregD,memwriteD,alusrcD,regdstD,regwriteD,saD,alucontrolD,hilowirteD,jalrD,jbralD,cp0weD,cp0readD,eretD},
		{memtoregE,memwriteE,alusrcE,regdstE,regwriteE,saE,alucontrolE,hilowirteE,jalrE,jbralE,cp0weE,cp0readE,eretE}
		);
	floprc #(32) regM(
		clk,rst,flushM,
		{memtoregE,memwriteE,regwriteE,cp0weE},
		{memtoregM,memwriteM,regwriteM,cp0weM}
		);
	floprc #(32) regW(
		clk,rst,flushW,
		{memtoregM,regwriteM,cp0weM},
		{memtoregW,regwriteW,cp0weW}
		);
endmodule
