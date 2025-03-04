module mycpu_top(
    input clk,
    input resetn,  //low active
	input [5:0]ext_int,
    //cpu inst sram
    output        inst_sram_en   ,
    output [3 :0] inst_sram_wen  ,
    output [31:0] inst_sram_addr ,
    output [31:0] inst_sram_wdata,
    input  [31:0] inst_sram_rdata,
    //cpu data sram
    output        data_sram_en   ,
    output [3 :0] data_sram_wen  ,
    output [31:0] data_sram_addr ,
    output [31:0] data_sram_wdata,
    input  [31:0] data_sram_rdata,

    //for debug
    output [31:0] debug_wb_pc     ,
    output [3:0] debug_wb_rf_wen  ,
    output [4:0] debug_wb_rf_wnum ,
    output [31:0] debug_wb_rf_wdata
);

// �?个例�?
	wire [31:0] pc;
	wire [31:0] instr;
	wire memwrite;
    wire memreadM;
	wire [3:0] select;
	wire [31:0] aluout, writedata, readdata;
	wire no_dcache;
    mips mips(
        .clk(~clk),
        .rst(~resetn),
        .ext_int(ext_int),
        //instr
        // .inst_en(inst_en),
        .pcF(pc),                    //pcF
        .instrF(instr),              //instrF
        //data
        // .data_en(data_en),
        .memwriteM(memwrite),
        .aluoutM(aluout),
        .writedataM(writedata),
        .readdataM(readdata),
        .selectM(select),
        .memreadM(memreadM),
        //for debug
        .debug_wb_pc       (debug_wb_pc       ),  
        .debug_wb_rf_wen   (debug_wb_rf_wen   ),  
        .debug_wb_rf_wnum  (debug_wb_rf_wnum  ),  
        .debug_wb_rf_wdata (debug_wb_rf_wdata )
    );
    mmu mmu(
        .inst_vaddr(pc),
        .inst_paddr(inst_sram_addr),
        .data_vaddr(aluout),
        .data_paddr(data_sram_addr),
        .no_dcache(no_dcache)
    );

    assign inst_sram_en = 1'b1;     //如果有inst_en，就用inst_en
    assign inst_sram_wen = 4'b0;
    assign inst_sram_wdata = 32'b0;
    // assign inst_sram_addr = pc;
    assign instr = inst_sram_rdata;

    assign data_sram_en = (memreadM|memwrite);     //如果有data_en，就用data_en
    assign data_sram_wen = select;
    // assign data_sram_addr = aluout;
    assign data_sram_wdata = writedata;
    assign readdata = data_sram_rdata;

    //ascii
    instdec instdec(
        .instr(instr)
    );

endmodule