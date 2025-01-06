`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/11/02 15:12:22
// Design Name: 
// Module Name: datapath
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

`include "./utils/defines2.vh"


module datapath(
	input wire clk,rst,
	input wire [5:0]ext_int,
	input wire instrStall,
	input wire dataStall,
	output wire longest_stall,
	//fetch stage
	output wire[31:0] pcF,
	input wire[31:0] instrF,
	output wire instr_enF,
	//decode stage
	input wire pcsrcD,branchD,
	input wire jumpD,
	output wire equalD,
	output wire[5:0] opD,functD,
	output wire [31:0] instrD,
	input wire jrD,
	input wire breakD,syscallD,invalidD,eretD,jalrD,jbralD,
	//execute stage
	input wire memtoregE,
	input wire alusrcE,regdstE,
	input wire regwriteE,
	input wire[4:0] alucontrolE,
	input wire[4:0] saE,
	input wire hilowirteE,
	input wire jalrE,
	input wire jbralE,
	output wire flushE,
	output wire stallE,
	input wire cp0readE,
	//mem stage
	input wire memtoregM,
	input wire regwriteM,
	output wire[31:0] aluoutM,writedata_o,
	input wire[31:0] readdataM,
	output wire[3:0] selectM,
	input wire cp0weM,
	output wire flushM,
	output wire stallM,
	output wire mem_enM,
	//writeback stage
	input wire memtoregW,
	input wire regwriteW,
	input wire cp0weW,
	output wire flushW,
	output wire stallW,

	//for debug
    output [31:0] debug_wb_pc     ,
    output [3:0] debug_wb_rf_wen  ,
    output [4:0] debug_wb_rf_wnum ,
    output [31:0] debug_wb_rf_wdata
    );

//----------------------------------------------for debug begin----------------------------------------------------	
    wire [31:0] pcW;
   	wire [31:0] instrE,instrM,instrW;
    flopenrc #(32) rinstrE(clk,rst,~stallE, flushE, instrD,instrE);
    flopenrc #(32) rinstrM(clk,rst,~stallM, flushM, instrE,instrM);
    flopenrc #(32) rinstrW(clk,rst,~stallW, flushW, instrM,instrW); 
    flopenrc #(32) rpcW(clk,rst,~stallW, flushW, pcM,pcW);


    assign debug_wb_pc          = pcW;
    assign debug_wb_rf_wen      = {4{regwriteW & ~stallW}};
    assign debug_wb_rf_wnum     = writeregW;
    assign debug_wb_rf_wdata    = resultW;
//----------------------------------------------for debug end----------------------------------------------------

	
	//fetch stage
	wire stallF,flushF;
	wire instadelF,is_in_delayslotF;
	//FD
	wire [31:0] pcnextFD,pcnextbrFD,pcplus4F,pcbranchD,pc4branchjFD;
	//decode stage
	wire [31:0] pcplus4D;
	wire forwardaD,forwardbD;
	wire [4:0] rsD,rtD,rdD;
	wire flushD,stallD; 
	wire [31:0] signimmD,signimmshD;
	wire [31:0] srcaD,srca2D,srcbD,srcb2D;
	wire [31:0] pcD;
	wire instadelD,is_in_delayslotD;
	//execute stage
	wire [1:0] forwardaE,forwardbE;
	wire [4:0] rsE,rtE,rdE;
	wire [4:0] writeregE;
	wire [31:0] signimmE;
	wire [31:0] srcaE,srca2E,srca3E, srcbE,srcb2E,srcb3E,srcb4E;
	wire [31:0] aluoutE;
	wire [63:0] hilo_read, hilo_write;//HILO读写数据
	wire [31:0] pcE;
	wire [5:0]opE;
	wire forwardcp0E;
	wire overflowE;
	wire breakE,syscallE,invalidE,eretE;
	wire instadelE,is_in_delayslotE;
	wire [31:0]cp0dataE,cp0data2E;
	wire div_stallE;
	wire div_readyE;
	wire hilo_write2E;
	//mem stage
	wire [4:0] writeregM;
	wire [31:0] writedataM, readdata_o;
	wire [5:0] opM;
	wire [4:0] rdM;
	wire breakM,syscallM,invalidM,eretM,overflowM;
	wire adelM,adesM;
	wire isexceptM;
	// pc指令地址是否对齐
	wire instadelM;
	wire [31:0] bad_addrM;
	wire [31:0] pcM,newpcM;
	wire is_in_delayslotM;
	wire [31:0] excepttypeM,count_oM,compare_oM,status_oM,cause_oM,epc_oM, config_oM,prid_oM,badvaddrM;
	//writeback stage
	wire [4:0] writeregW;
	wire [31:0] aluoutW,readdataW,resultW;

	// Hazard detection module instance
	hazard h (
		// Fetch stage
		.stallF(stallF),
		.flushF(flushF),
		.instrStall(instrStall),	
		// Decode stage
		.rsD(rsD),
		.rtD(rtD),
		.branchD(branchD),
		.jumpD(jumpD),
		.forwardaD(forwardaD),
		.forwardbD(forwardbD),
		.stallD(stallD),
		.flushD(flushD),
		
		// Execute stage
		.rsE(rsE),
		.rtE(rtE),
		.rdE(rdE),
		.writeregE(writeregE),
		.regwriteE(regwriteE),
		.memtoregE(memtoregE),
		.forwardaE(forwardaE),
		.forwardbE(forwardbE),
		.div_stallE(div_stallE),
		.stallE(stallE),
		.flushE(flushE),
		.cp0readE(cp0readE),
		.forwardcp0E(forwardcp0E),
		
		// Memory stage
		.dataStall(dataStall),
		.rdM(rdM),
		.writeregM(writeregM),
		.regwriteM(regwriteM),
		.memtoregM(memtoregM),
		.flushM(flushM),
		.cp0weM(cp0weM),
		.excepttypeM(excepttypeM),
		.isexceptM(isexceptM),	
		.stallM(stallM),
		// Write back stage
		.writeregW(writeregW),
		.regwriteW(regwriteW),
		.flushW(flushW),
		.cp0weW(cp0weW),
		.longest_stall(longest_stall),
		.stallW(stallW)
	);

	//next PC logic (operates in fetch an decode)
	// branch
	mux2 #(32) pcbrmux(pcplus4F,pcbranchD,pcsrcD,pcnextbrFD);
	// jump
	mux2 #(32) pcjumpmux(pcnextbrFD,
		{pcplus4D[31:28],instrD[25:0],2'b00},
		jumpD,pc4branchjFD);
	mux2 #(32) pc_jr_mux(pc4branchjFD,srca2D,jrD,pcnextFD);

	//regfile (operates in decode and writeback)
	regfile rf(clk,regwriteW,rsD,rtD,writeregW,resultW,srcaD,srcbD);

	//fetch stage logic
	pc #(32) pcreg(clk,rst,~stallF,flushF,pcnextFD,newpcM,pcF);
	adder pcadd1(pcF,32'b100,pcplus4F);
	assign instadelF = (pcF[1:0] != 2'b00);
	assign is_in_delayslotF = jumpD|jalrD|jrD|jbralD|branchD;
	assign instr_enF = ~isexceptM;

	//decode stage
	flopenrc #(32) r1D(clk,rst,~stallD,flushD,pcplus4F,pcplus4D);
	flopenrc #(32) r2D(clk,rst,~stallD,flushD,instrF,instrD);
	flopenrc #(32) r3D(clk,rst,~stallD,flushD,pcF,pcD);
	flopenrc #(1) r4D(clk,rst,~stallD,flushD,instadelF,instadelD);
	flopenrc #(1) r5D(clk,rst,~stallD,flushD,is_in_delayslotF,is_in_delayslotD);
	signext se(instrD[15:0], opD[3:2], signimmD);
	sl2 immsh(signimmD,signimmshD);
	adder pcadd2(pcplus4D,signimmshD,pcbranchD);
	mux2 #(32) forwardamux(srcaD,aluoutM,forwardaD,srca2D);
	mux2 #(32) forwardbmux(srcbD,aluoutM,forwardbD,srcb2D);
	eqcmp comp(srca2D,srcb2D,opD,rtD,equalD);

	assign opD = instrD[31:26];
	assign functD = instrD[5:0];
	assign rsD = instrD[25:21];
	assign rtD = instrD[20:16];
	assign rdD = instrD[15:11];

	//execute stage
	flopenrc #(32) r1E(clk,rst,~stallE,flushE,srcaD,srcaE);
	flopenrc #(32) r2E(clk,rst,~stallE,flushE,srcbD,srcbE);
	flopenrc #(32) r3E(clk,rst,~stallE,flushE,signimmD,signimmE);
	flopenrc #(5) r4E(clk,rst,~stallE,flushE,rsD,rsE);
	flopenrc #(5) r5E(clk,rst,~stallE,flushE,rtD,rtE);
	flopenrc #(5) r6E(clk,rst,~stallE,flushE,rdD,rdE);
	flopenrc #(32) r7E(clk,rst,~stallE,flushE,pcD,pcE);
	flopenrc #(6) r8E(clk,rst,~stallE,flushE,opD,opE);
	flopenrc #(32) r10E(clk,rst,~stallE,flushE,{instadelD,syscallD,breakD,eretD,invalidD},{instadelE,syscallE,breakE,eretE,invalidE});
    flopenrc #(1) r11E(clk,rst,~stallE,flushE,is_in_delayslotD,is_in_delayslotE);

	mux3 #(32) forwardaemux(srcaE,resultW,aluoutM,forwardaE,srca2E);
	mux3 #(32) forwardbemux(srcbE,resultW,aluoutM,forwardbE,srcb2E);
	mux2 #(32) srcbmux(srcb2E,signimmE,alusrcE,srcb3E);
	//跳转链接类指�???,复用ALU,ALU源操作数选择分别为pcE and 8
	mux2 #(32) alusrcamux(srca2E,pcE,jbralE,srca3E);
	mux2 #(32) alusrcbmux(srcb3E,32'h00000008,jbralE,srcb4E);
	alu alu(clk, rst, srca3E,srcb4E,alucontrolE,saE,hilo_read,cp0data2E,isexceptM,aluoutE,hilo_write,div_readyE,div_stallE,overflowE);
	assign hilo_write2E = (alucontrolE == `DIV_CONTROL | alucontrolE == `DIVU_CONTROL) ? 
							(div_readyE & hilowirteE) : (hilowirteE); 
	hilo_reg hilo(clk,rst,(hilo_write2E & ~isexceptM),hilo_write,hilo_read);	
	// {jalr, regdst}
	mux3 #(5) wrmux(rtE,rdE,5'd31,{jalrE, regdstE},writeregE);	
 	mux2 #(32) forwardcp0mux(cp0dataE,aluoutM,forwardcp0E,cp0data2E);
	//mem stage
	flopenrc #(32) r1M(clk,rst,~stallM,flushM,srcb2E,writedataM);
	flopenrc #(32) r2M(clk,rst,~stallM,flushM,aluoutE,aluoutM);
	flopenrc #(5) r3M(clk,rst,~stallM,flushM,writeregE,writeregM);
	flopenrc #(6) r4M(clk,rst,~stallM,flushM, opE,opM);
	flopenrc #(5) r6M(clk,rst,~stallM,flushM,rdE,rdM);
	flopenrc #(6) r7M(clk,rst,~stallM,flushM,{instadelE,syscallE,breakE,eretE,invalidE,overflowE},{instadelM,syscallM,breakM,eretM,invalidM,overflowM});
	flopenrc #(1) r8M(clk,rst,~stallM,flushM,is_in_delayslotE,is_in_delayslotM);
	flopenrc #(32) r9M(clk,rst,~stallM,flushM,pcE,pcM);
	mem_ctrl mem_ctrl(opM,aluoutM[1:0],readdataM,writedataM,readdata_o,writedata_o,selectM, adelM, adesM);
	assign bad_addrM = (instadelM)? pcM:aluoutM;
    assign mem_enM = (~adelM & ~adesM);

	wire [31:0] current_inst_addr;
	flopr #(32) except_inst_addr(clk,rst,pcE,current_inst_addr);	
	exceptdec exception(clk, rst,ext_int,cp0weM,rdM,aluoutM,adelM,adesM,instadelM,syscallM,breakM,eretM,invalidM,overflowM,status_oM,cause_oM,epc_oM,excepttypeM,newpcM,isexceptM);
 	cp0_reg CP0(clk,rst,cp0weM,rdM,rdE,aluoutM,6'b000000,excepttypeM,current_inst_addr,is_in_delayslotM,
    bad_addrM,cp0dataE,count_oM,compare_oM,status_oM,cause_oM,epc_oM,config_oM,prid_oM,badvaddrM);

	//writeback stage
	flopenrc #(32) r1W(clk,rst,~stallM,flushW,aluoutM,aluoutW);
	flopenrc #(32) r2W(clk,rst,~stallM,flushW,readdata_o,readdataW);
	flopenrc #(5) r3W(clk,rst,~stallM,flushW,writeregM,writeregW);
	mux2 #(32) resmux(aluoutW,readdataW,memtoregW,resultW);
endmodule
