`timescale 1ns / 1ps
module incrementer#(
  parameter DATA_WIDTH = 8
)(
  input  logic signed [DATA_WIDTH - 1:0] data_i,
  output logic signed [DATA_WIDTH - 1:0] data_o
);

logic [DATA_WIDTH - 1:0] data;
logic pos_overflow;

genvar i;
generate
  for ( i = 0; i < DATA_WIDTH; i = i + 1 ) begin
    if ( i == 0 ) assign data[0] = ~data_i[0];
    else          assign data[i] = ~data_i[i] ^ ~(&data_i[i-1:0]);
  end
endgenerate

assign pos_overflow = data_i == {1'b0, {DATA_WIDTH - 1{1'b1}}}; // Переполняется в случае, если число и так является максимальным в разрядной сетке

assign data_o = ( pos_overflow ) ? data_i : // В случае переполнения возвращает его же
                                   data;

endmodule
