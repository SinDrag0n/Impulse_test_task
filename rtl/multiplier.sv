module multiplier #(
  parameter DATA_WIDTH = 16
)(
  input  logic signed [DATA_WIDTH - 1:0]      a_in,
  input  logic signed [DATA_WIDTH - 1:0]      b_in,
  output logic signed [DATA_WIDTH - 1:0]      res_o
);  

logic [2 * DATA_WIDTH - 1:0] res;
assign res = a_in * b_in;

assign res_o = ( ~res[2 * DATA_WIDTH - 1] & |res[ 2 * DATA_WIDTH - 2:DATA_WIDTH] ) ? {1'b0, {DATA_WIDTH - 1{1'b1}}} : // Переполняется если в старших разрядах есть хотя бы одна единица
               ( res[2 * DATA_WIDTH - 1] & ~&res[ 2 * DATA_WIDTH - 2:DATA_WIDTH] ) ? {1'b1, {DATA_WIDTH - 1{1'b0}}} : // Переполняется если в старших разрядах есть хотя бы один ноль
                                                                                     res[DATA_WIDTH - 1:0];           // Иначе просто младшие n бит


endmodule