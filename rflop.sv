`ifndef FLOP
`define FLOP

module flop
    #(
        parameter WIDTH = 1
    )
(
    input  logic Clk,
    input  logic En,
    input  logic Rst,
    input  logic [WIDTH-1:0] D,
    output logic [WIDTH-1:0] Q
);
    logic [WIDTH-1:0] Data;
    assign DataGated = ~{WIDTH{Rst}} & D;
    assign Q = Data;
    always @ (posedge Clk) begin
        priority if (Rst) Data = '0;
        else if (En) Data = D;
    end
endmodule : flop

`endif // FLOP