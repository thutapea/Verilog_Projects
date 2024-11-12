module vga_controller ( // this design references https://vanhunteradams.com/DE1/VGA_Driver/Driver.html
    input wire clk;
    input wire rst;
    input [7:0] i_rgb;
    output [9:0] o_x;
    output [9:0] o_y;
    output wire hsync;
    output wire vsync;
    output [7:0] red;
    output [7:0] green;
    output [7:0] blue;
    output sync;
    output o_clk;
    output blank;
)

// Parameters
parameter [9:0] H_active =  10'd_639;
parameter [9:0] H_front =   10'd_15;
parameter [9:0] H_pulse =   10'd_95;
parameter [9:0] H_back =    10'd_47;

parameter [9:0] V_active =  10'd_479;
parameter [9:0] V_front =   10'd_9;
parameter [9:0] V_pulse =   10'd_1;
parameter [9:0] V_back =    10'd_32;

parameter low   1'b_0;
parameter high  1'b_1;

parameter STATE_H_active =  8'd_0;
parameter STATE_H_front =   8'd_1;
parameter STATE_H_pulse =   8'd_2;
parameter STATE_H_back =    8'd_3;

parameter STATE_V_active =  8'd_0;
parameter STATE_V_front =   8'd_1;
parameter STATE_V_pulse =   8'd_2;
parameter STATE_V_back =    8'd_3;

reg         hsync_reg;
reg         vsync_reg;
reg [7:0]   red_reg;
reg [7:0]   blue_reg;
reg [7:0]   green_reg;
reg         line_done;

reg [9:0] h_cnt;
reg [9:0] v_cnt;

reg [7:0] h_state;
reg [7:0] v_state;

//vga state machine

always@ (posedge clk) begin
  if (rst) begin
  h_cnt <= 10'd_0;
  v_cnt <= 10'd_0;
  h_state <= H_active;
  v_state <= V_active;
  line_done <= low; end
  else begin 
    if (h_state == STATE_H_active) begin
    h_cnt <= (h_cnt==H_active) ? 10'd_0: (h_cnt + 10'd_1);
    hsync_reg <= high;
    line_done <= low; 
    h_state <= (h_cnt == H_active) ? STATE_H_front: STATE_H_active;
    end

    if(h_state == STATE_H_front)begin
    h_cnt <= (h_cnt==H_front) ? 10'd_0: (h_cnt + 10'd_1);
    hsync_reg <= high;
    h_state <= (h_cnt == H_front) ? STATE_H_pulse: STATE_H_front;
    end

    if (h_state == STATE_H_pulse)begin
    h_cnt <= (h_cnt==H_pulse) ? 10'd_0: (h_cnt + 10'd_1);
    hsync_reg <=  low;
    h_state <= (h_cnt == H_pulse) ? STATE_H_back: STATE_H_pulse;
    end

    if (h_state == STATE_H_back)begin
    h_cnt <= (h_cnt==H_back) ? 10'd_0: (h_cnt + 10'd_1);
    hsync_reg <= high;
    h_state <= (h_cnt == H_back) ? STATE_H_active: STATE_H_back;
    line_done <= (h_cnt == (H_back-1))? high:low;
    end

    // vertical
    if(v_state == STATE_V_active)begin
    v_cnt <= (line_done == high)? ((v_cnt == V_active)? 10'd_0:(v_cnt +10'd_1)): v_cnt;
    vsync_reg <= high;
    v_state <= (line_done == high)? ((v_cnt == V_active)? STATE_V_front:STATE_V_active):STATE_V_active;
    end

    if(v_state == STATE_V_front)begin
    v_cnt <= (line_done == high)? ((v_cnt == V_front)? 10'd_0:(v_cnt +10'd_1)): v_cnt;
    vsync_reg = high;
    v_state <= (line_done == high)? ((v_cnt == V_front)? STATE_V_pulse:STATE_V_front):STATE_V_front;
    end

    if(v_state == STATE_V_pulse)begin
    v_cnt <= (line_done == high)? ((v_cnt == V_pulse)? 10'd_0:(v_cnt +10'd_1)): v_cnt;
    vsync_reg <= low;
    v_state <= (line_done == high)? ((v_cnt == V_pulse)? STATE_V_back:STATE_V_pulse):STATE_V_pulse;
    end

    if(v_state == STATE_V_back)begin
    v_cnt <= (line_done == high)? ((v_cnt == V_back)? 10'd_0:(v_cnt +10'd_1)): v_cnt;
    vsync_reg <= high;
    v_state <= (line_done == high)? ((v_cnt == V_back)? STATE_V_active:STATE_V_back):STATE_V_back;
    end

    red_reg     <= (h_state==STATE_H_active)? ((v_state == STATE_V_active)? {i_rgb[7:5],5'd_0}:8'd_0):8'd_0;
    green_reg   <= (h_state==STATE_H_active)? ((v_state == STATE_V_active)? {i_rgb[4:2],5'd_0}:8'd_0):8'd_0;
    blue_reg   <= (h_state==STATE_H_active)? ((v_state == STATE_V_active)? {i_rgb[1:0],6'd_0}:8'd_0):8'd_0;
    end // end of else
end // end of always

assign hsync = hsync_reg;
assign vsync = vsync_reg;
assign red = red_reg;
assign green = green_reg;
assign blue = blue_reg;
assign o_clk = clk;
assign sync = 1'b_0;
assign blank = hsync_reg & vsync_reg;

assign o_x = (h_state == STATE_H_active)? h_cnt:10'd_0;
assign o_y = (v_state == STATE_V_active)? v_cnt:10'd_0;

endmodule