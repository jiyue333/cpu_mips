`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/11/22 10:23:13
// Design Name: 
// Module Name: hazard
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


module hazard (
    // Fetch stage
    output wire stallF,
    output wire flushF,
    
    // Decode stage
    input wire [4:0] rsD,
    input wire [4:0] rtD,
    input wire branchD,
	input wire jumpD,
    output wire forwardaD,
    output wire forwardbD,
    output wire stallD,
    output wire flushD,
    
    // Execute stage
    input wire [4:0] rsE,
    input wire [4:0] rtE,
    input wire [4:0] rdE,
    input wire [4:0] writeregE,
    input wire regwriteE,
    input wire memtoregE,
    output reg [1:0] forwardaE,
    output reg [1:0] forwardbE,
    output wire flushE,
    input wire cp0readE,
    output wire forwardcp0E,
    
    // Memory stage
    input wire [4:0] rdM,
    input wire [4:0] writeregM,
    input wire regwriteM,
    input wire memtoregM,
    output wire flushM,
    input wire cp0weM,
    input wire [31:0] excepttypeM,
	input isexceptM,
    // Write back stage
    input wire [4:0] writeregW,
    input wire regwriteW,
    output wire flushW,
    input wire cp0weW
);

	wire lwstallD,branchstallD;

	//forwarding sources to D stage (branch equality)
	assign forwardaD = (rsD != 0 & rsD == writeregM & regwriteM);
	assign forwardbD = (rtD != 0 & rtD == writeregM & regwriteM);
	
	//forwarding sources to E stage (ALU)

	always @(*) begin
		forwardaE = 2'b00;
		forwardbE = 2'b00;
		if(rsE != 0) begin
			/* code */
			if(rsE == writeregM & regwriteM) begin
				/* code */
				forwardaE = 2'b10;
			end else if(rsE == writeregW & regwriteW) begin
				/* code */
				forwardaE = 2'b01;
			end
		end
		if(rtE != 0) begin
			/* code */
			if(rtE == writeregM & regwriteM) begin
				/* code */
				forwardbE = 2'b10;
			end else if(rtE == writeregW & regwriteW) begin
				/* code */
				forwardbE = 2'b01;
			end
		end
	end

	assign forwardcp0E = ((cp0readE != 0) && cp0weM && rdM == rdE);

	//stalls
	assign  lwstallD = memtoregE & (rtE == rsD | rtE == rtD);
	assign  branchstallD = (branchD | jumpD) &
				(regwriteE & 
				(writeregE == rsD | writeregE == rtD) |
				memtoregM &
				(writeregM == rsD | writeregM == rtD));
	assign  stallD = lwstallD | branchstallD;
	assign  stallF = stallD;
		//stalling D stalls all previous stages
    assign flushF = isexceptM;
    assign flushD = isexceptM;
	assign flushE = isexceptM | lwstallD | branchstallD;
	assign flushM = isexceptM;
	assign flushW = isexceptM;
		//stalling D flushes next stage
	// Note: not necessary to stall D stage on store
  	//       if source comes from load;
  	//       instead, another bypass network could
  	//       be added from W to M
endmodule
