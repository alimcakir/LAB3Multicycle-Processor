module mainfsm(
    input  logic       clk,
    input  logic       reset,
    input  logic [6:0] op,
    output logic [1:0] alusrca,
    output logic [1:0] alusrcb,
    output logic [1:0] resultsrc,
    output logic       adrsrc,
    output logic [1:0] aluop,
    output logic       irwrite,
    output logic       pcupdate,
    output logic       regwrite,
    output logic       memwrite,
    output logic       branch
);

    typedef enum logic [3:0] {
        S0_FETCH    = 4'd0,
        S1_DECODE   = 4'd1,
        S2_MEMADR   = 4'd2,
        S3_MEMREAD  = 4'd3,
        S4_MEMWB    = 4'd4,
        S5_MEMWRITE = 4'd5,
        S6_EXECUTER = 4'd6,
        S7_ALUWB    = 4'd7,
        S8_EXECUTEI = 4'd8,
        S9_JAL      = 4'd9,
        S10_BEQ     = 4'd10
    } state_t;

    state_t state, nextstate;

    always_ff @(posedge clk or posedge reset) begin
        if (reset)
            state <= S0_FETCH;
        else
            state <= nextstate;
    end

    always_comb begin
        case (state)
            S0_FETCH:    nextstate = S1_DECODE;

            S1_DECODE: begin
                case (op)
                    7'b0000011: nextstate = S2_MEMADR;   // lw
                    7'b0100011: nextstate = S2_MEMADR;   // sw
                    7'b0110011: nextstate = S6_EXECUTER; // R-type
                    7'b0010011: nextstate = S8_EXECUTEI; // I-type ALU
                    7'b1101111: nextstate = S9_JAL;      // jal
                    7'b1100011: nextstate = S10_BEQ;     // beq
                    default:    nextstate = S0_FETCH;
                endcase
            end

            S2_MEMADR: begin
                if (op == 7'b0000011)
                    nextstate = S3_MEMREAD;   // lw
                else
                    nextstate = S5_MEMWRITE;  // sw
            end

            S3_MEMREAD:  nextstate = S4_MEMWB;
            S4_MEMWB:    nextstate = S0_FETCH;
            S5_MEMWRITE: nextstate = S0_FETCH;
            S6_EXECUTER: nextstate = S7_ALUWB;
            S7_ALUWB:    nextstate = S0_FETCH;
            S8_EXECUTEI: nextstate = S7_ALUWB;
            S9_JAL:      nextstate = S7_ALUWB;
            S10_BEQ:     nextstate = S0_FETCH;

            default:     nextstate = S0_FETCH;
        endcase
    end

    always_comb begin
        // deterministic defaults
        immsrc_dummy: assert (1); // ignored, just to avoid accidental implicit nets in some editors

        alusrca  = 2'b00;
        alusrcb  = 2'b00;
        resultsrc = 2'b00;
        adrsrc   = 1'b0;
        aluop    = 2'b00;
        irwrite  = 1'b0;
        pcupdate = 1'b0;
        regwrite = 1'b0;
        memwrite = 1'b0;
        branch   = 1'b0;

        case (state)
            S0_FETCH: begin
                adrsrc   = 1'b0;
                irwrite  = 1'b1;
                alusrca  = 2'b00;
                alusrcb  = 2'b10;
                aluop    = 2'b00;
                resultsrc = 2'b10;
                pcupdate = 1'b1;
            end

            S1_DECODE: begin
                alusrca  = 2'b01;
                alusrcb  = 2'b01;
                aluop    = 2'b00;
            end

            S2_MEMADR: begin
                alusrca  = 2'b10;
                alusrcb  = 2'b01;
                aluop    = 2'b00;
            end

            S3_MEMREAD: begin
                resultsrc = 2'b00;
                adrsrc   = 1'b1;
            end

            S4_MEMWB: begin
                resultsrc = 2'b01;
                regwrite = 1'b1;
            end

            S5_MEMWRITE: begin
                resultsrc = 2'b00;
                adrsrc   = 1'b1;
                memwrite = 1'b1;
            end

            S6_EXECUTER: begin
                alusrca  = 2'b10;
                alusrcb  = 2'b00;
                aluop    = 2'b10;
            end

            S7_ALUWB: begin
                resultsrc = 2'b00;
                regwrite = 1'b1;
            end

            S8_EXECUTEI: begin
                alusrca  = 2'b10;
                alusrcb  = 2'b01;
                aluop    = 2'b10;
            end

            S9_JAL: begin
                alusrca  = 2'b01;
                alusrcb  = 2'b10;
                aluop    = 2'b00;
                resultsrc = 2'b00;
                pcupdate = 1'b1;
            end

            S10_BEQ: begin
                alusrca  = 2'b10;
                alusrcb  = 2'b00;
                aluop    = 2'b01;
                resultsrc = 2'b00;
                branch   = 1'b1;
            end
        endcase
    end

endmodule