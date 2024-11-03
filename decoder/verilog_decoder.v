`timescale 1 ns / 100ps

module decoder (i_btn, i_start, i_s1, i_s0, o_y1, o_y2, o_y3, o_y4);

input i_btn, i_start, i_s1, i_s0;
output o_y1, o_y2, o_y3, o_y4;

assign o_y1 = ~i_s1 & ~i_s0;
assign o_y2 = ~i_s1 & i_s0;
assign o_y3 = i_s1 & ~i_s0;
assign o_y4 = i_s1 & i_s0;

endmodule