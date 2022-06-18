`ifndef FLOP
`define FLOP

module flop
    #(
        parameter WIDTH = 1
    )
(
    input  logic Clk,
    input  logic En,
    input  logic D,
    output logic Q
);
    logic Data;
    assign Q = Data;
    always @ (posedge Clk) begin
        if (En) Data <= D;
    end
endmodule : flop

`endif // FLOP