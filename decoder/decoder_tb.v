`timescale 1 ns / 100 ps
module decoder_tb;

reg i_s1;
reg i_s0;

decoder UUT (i_btn, i_start, i_s1, i_s0, o_y1, o_y2, o_y3, o_y4);
initial
     begin
        i_s1 = 0;
        i_s0 = 0;
        #10;
        i_s1 = 0;
        i_s0 = 1;
        #10;
        i_s1 = 1;
        i_s0 = 0;
        #10;
        i_s1 = 1;
        i_s0 = 1;
        #10;
    end
 endmodule