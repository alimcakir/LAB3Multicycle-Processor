module riscv(
    input  logic        clk,
    input  logic        reset,
    input  logic [31:0] ReadData,
    output logic [31:0] Adr,
    output logic [31:0] WriteData,
    output logic [31:0] DataAdr,
    output logic        MemWrite
);

    logic [31:0] Instr;
    logic [31:0] PC;
    logic [31:0] SrcA, SrcB;
    logic [31:0] ALUResult;
    logic [1:0]  ImmSrc;
    logic [1:0]  ALUSrcA, ALUSrcB;
    logic [1:0]  ResultSrc;
    logic        AdrSrc;
    logic [2:0]  ALUControl;
    logic        IRWrite, PCWrite, RegWrite;
    logic        Zero;

    controller c(
        .clk(clk),
        .reset(reset),
        .op(Instr[6:0]),
        .funct3(Instr[14:12]),
        .funct7b5(Instr[30]),
        .zero(Zero),
        .immsrc(ImmSrc),
        .alusrca(ALUSrcA),
        .alusrcb(ALUSrcB),
        .resultsrc(ResultSrc),
        .adrsrc(AdrSrc),
        .alucontrol(ALUControl),
        .irwrite(IRWrite),
        .pcwrite(PCWrite),
        .regwrite(RegWrite),
        .memwrite(MemWrite)
    );

    datapath dp(
        .clk(clk),
        .reset(reset),
        .ReadData(ReadData),
        .ImmSrc(ImmSrc),
        .ALUSrcA(ALUSrcA),
        .ALUSrcB(ALUSrcB),
        .ResultSrc(ResultSrc),
        .AdrSrc(AdrSrc),
        .ALUControl(ALUControl),
        .IRWrite(IRWrite),
        .PCWrite(PCWrite),
        .RegWrite(RegWrite),
        .Instr(Instr),
        .PC(PC),
        .Adr(Adr),
        .DataAdr(DataAdr),
        .WriteData(WriteData),
        .SrcA(SrcA),
        .SrcB(SrcB),
        .ALUResult(ALUResult),
        .Zero(Zero)
    );

endmodule