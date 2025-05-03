module adder #(
  parameter DATA_WIDTH = 16
)(
  input  logic signed [DATA_WIDTH - 1:0]  a_in,
  input  logic signed [DATA_WIDTH - 1:0]  b_in,
  output logic signed [DATA_WIDTH - 1:0]  res_o
);  


logic [DATA_WIDTH:0] res;
assign res   = a_in + b_in;

assign res_o = (  ~a_in[DATA_WIDTH - 1] && ~b_in[DATA_WIDTH - 1] && res[DATA_WIDTH - 1] )  ? {1'b0, {DATA_WIDTH - 1{1'b1}}} :
               ( a_in[DATA_WIDTH - 1] && b_in[DATA_WIDTH - 1] && ~res[DATA_WIDTH - 1] )    ? {1'b1, {DATA_WIDTH - 1{1'b0}}} :
                                                                                  res[DATA_WIDTH - 1:0];

endmodule