module mem(
    input  logic        clk,
    input  logic        we,
    input  logic [31:0] a,
    input  logic [31:0] wd,
    output logic [31:0] rd
);

    logic [31:0] RAM [0:63];

    initial
        $readmemh("memfile.txt", RAM);

    always_ff @(posedge clk) begin
        if (we)
            RAM[a[31:2]] <= wd;
    end

    assign rd = RAM[a[31:2]];

endmodule