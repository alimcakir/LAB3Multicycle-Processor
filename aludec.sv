module aludec(
    input  logic       opb5,
    input  logic [2:0] funct3,
    input  logic       funct7b5,
    input  logic [1:0] ALUOp,
    output logic [2:0] ALUControl
);

    logic RtypeSub;
    assign RtypeSub = funct7b5 & opb5; // TRUE for R-type subtract instruction

    always_comb begin
        case (ALUOp)
            2'b00: ALUControl = 3'b010; // add
            2'b01: ALUControl = 3'b110; // sub
            default: begin
                case (funct3)
                    3'b000: begin
                        if (RtypeSub)
                            ALUControl = 3'b110; // sub
                        else
                            ALUControl = 3'b010; // add, addi
                    end
                    3'b010: ALUControl = 3'b111; // slt, slti
                    3'b110: ALUControl = 3'b001; // or, ori
                    3'b111: ALUControl = 3'b000; // and, andi
                    default: ALUControl = 3'b000;
                endcase
            end
        endcase
    end

endmodule