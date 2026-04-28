module datapath(
    input  logic        clk,
    input  logic        reset,
    input  logic [31:0] ReadData,
    input  logic [1:0]  ImmSrc,
    input  logic [1:0]  ALUSrcA,
    input  logic [1:0]  ALUSrcB,
    input  logic [1:0]  ResultSrc,
    input  logic        AdrSrc,
    input  logic [2:0]  ALUControl,
    input  logic        IRWrite,
    input  logic        PCWrite,
    input  logic        RegWrite,

    output logic [31:0] Instr,
    output logic [31:0] PC,
    output logic [31:0] Adr,
    output logic [31:0] DataAdr,
    output logic [31:0] WriteData,
    output logic [31:0] SrcA,
    output logic [31:0] SrcB,
    output logic [31:0] ALUResult,
    output logic        Zero
);

    logic [31:0] OldPC;
    logic [31:0] Data;
    logic [31:0] A;
    logic [31:0] RD1, RD2;
    logic [31:0] ImmExt;
    logic [31:0] Result;
    logic [31:0] ALUOut;

    // PC register
    flopenr #(32) pcreg(
        .clk(clk),
        .reset(reset),
        .en(PCWrite),
        .d(Result),
        .q(PC)
    );

    flopenr #(32) oldpcreg(
    .clk(clk),
    .reset(reset),
    .en(IRWrite),
    .d(PC),
    .q(OldPC)
);

    // Instruction register
    flopenr #(32) instrreg(
        .clk(clk),
        .reset(reset),
        .en(IRWrite),
        .d(ReadData),
        .q(Instr)
    );

    // Data register
    flopr #(32) datareg(
        .clk(clk),
        .reset(reset),
        .d(ReadData),
        .q(Data)
    );

    // Register file
    regfile rf(
        .clk(clk),
        .we3(RegWrite),
        .a1(Instr[19:15]),
        .a2(Instr[24:20]),
        .a3(Instr[11:7]),
        .wd3(Result),
        .rd1(RD1),
        .rd2(RD2)
    );

    // A and B registers
    flopr #(32) areg(
        .clk(clk),
        .reset(reset),
        .d(RD1),
        .q(A)
    );

    flopr #(32) breg(
        .clk(clk),
        .reset(reset),
        .d(RD2),
        .q(WriteData)
    );

    // Immediate extender
    extend ext(
        .instr(Instr[31:7]),
        .immsrc(ImmSrc),
        .immext(ImmExt)
    );

    // ALU source muxes
    mux3 #(32) srcamux(
        .d0(PC),
        .d1(OldPC),
        .d2(A),
        .s(ALUSrcA),
        .y(SrcA)
    );

    mux3 #(32) srcbmux(
        .d0(WriteData),
        .d1(ImmExt),
        .d2(32'd4),
        .s(ALUSrcB),
        .y(SrcB)
    );

    // ALU
    alu aluunit(
        .a(SrcA),
        .b(SrcB),
        .alucontrol(ALUControl),
        .result(ALUResult),
        .zero(Zero)
    );

    // ALUOut register
    flopr #(32) aluoutreg(
        .clk(clk),
        .reset(reset),
        .d(ALUResult),
        .q(ALUOut)
    );

    // Result mux: 00=ALUOut, 01=Data, 10=ALUResult
    mux3 #(32) resultmux(
        .d0(ALUOut),
        .d1(Data),
        .d2(ALUResult),
        .s(ResultSrc),
        .y(Result)
    );

    // Address mux for unified memory
    assign Adr = AdrSrc ? Result : PC;

    // testbench için tap-out
    assign DataAdr = Adr;

endmodule