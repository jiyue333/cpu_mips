`timescale 1ns / 1ps
`include "../utils/defines2.vh"

module exceptdec(
    input wire clk,
    input wire rst,
    input wire [5:0] ext_int,

    input wire cp0weW,
    input wire [4:0] waddrW,
    input wire [31:0] wdataW,

    input wire adel, ades,
    input wire instadel, syscall, break, eret, invalid, overflow,
    input wire [31:0] cp0_statusM, cp0_causeM, cp0_epcM,
    output reg [31:0] excepttypeM,
    output reg [31:0] newpcM,
    output reg isexceptM
);
    wire [31:0] cp0_status, cp0_cause, cp0_epc;

    reg [31:0] excepttypeM_reg;
    always @(*) begin
        if (rst) begin
            excepttypeM <= 32'b0;
            isexceptM <= 1'b0;
            newpcM <= 32'b0;
        end else begin
            excepttypeM <= ((({ext_int, cp0_causeM[9:8]} & cp0_statusM[15:8]) != 8'h00) &&
                            (cp0_statusM[1] == 1'b0) && (cp0_statusM[0] == 1'b1)) ? 32'h00000001 : // int
                           (instadel | adel) ? 32'h00000004 : // adel
                           (ades) ? 32'h00000005 : // ades
                           (syscall) ? 32'h00000008 : // syscall
                           (break) ? 32'h00000009 : // break
                           (eret) ? 32'h0000000e : // eret
                           (invalid) ? 32'h0000000a : // ri
                           (overflow) ? 32'h0000000c : // overflow
                           32'h0;

            isexceptM <= (excepttypeM == 32'h00000001) ? 1 :
                         (excepttypeM == 32'h00000004) ? 1 :
                         (excepttypeM == 32'h00000005) ? 1 :
                         (excepttypeM == 32'h00000008) ? 1 :
                         (excepttypeM == 32'h00000009) ? 1 :
                         (excepttypeM == 32'h0000000a) ? 1 :
                         (excepttypeM == 32'h0000000c) ? 1 :
                         (excepttypeM == 32'h0000000e) ? 1 :
                         0;

            newpcM <= (excepttypeM == 32'h00000001) ? 32'hbfc00380 :
                      (excepttypeM == 32'h00000004) ? 32'hbfc00380 :
                      (excepttypeM == 32'h00000005) ? 32'hbfc00380 :
                      (excepttypeM == 32'h00000008) ? 32'hbfc00380 :
                      (excepttypeM == 32'h00000009) ? 32'hbfc00380 :
                      (excepttypeM == 32'h0000000a) ? 32'hbfc00380 :
                      (excepttypeM == 32'h0000000c) ? 32'hbfc00380 :
                      (excepttypeM == 32'h0000000e) ? cp0_epcM :
                      32'b0;
        end
    end

endmodule
