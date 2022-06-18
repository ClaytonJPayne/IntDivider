module Comparator 
    # (
        parameter WIDTH = 8
    )
(
    input  logic [WIDTH-1:0] A,
    input  logic [WIDTH-1:0] B,
    output logic             AGTB
);
    logic                    AGTBOut;
    logic [WIDTH:0]          StgGaterOut;
    logic [WIDTH-1:0]        StgGaterIn;

    assign AGTB = AGTBOut;
    
    assign StgGaterOut[WIDTH] = 1'b0;

    always_comb begin
        for (int i=WIDTH-1; i>=0; i--) begin
            StgGaterIn[i]    = ~StgGaterOut[i+1];
            StgGaterOut[i]   = StgGaterIn[i]  & (A[i] ^ B[i]);
            AGTBOut         |= StgGaterOut[i] & A[i];
        end
    end

endmodule : Comparator