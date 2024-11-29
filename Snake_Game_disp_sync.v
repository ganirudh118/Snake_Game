`timescale 1ns / 1ps

module disp_sync(
  input clk, rst,
  output reg v_sync, h_sync, v_disp, h_disp,
  output reg [9:0] v_loc,
  output reg [10:0] h_loc
);
  
  always @(posedge clk) begin    
  
    // Horizontal counter
    if(rst)
      h_loc <= 11'b00000000001;
    else if(h_loc >= 11'b11001000000)  // 800, end of horizontal line
      h_loc <= 11'b0000000001;  // Reset to start of line
    else
      h_loc <= h_loc + 11'b00000000001;  // Increment for horizontal position
      
    // Vertical counter
    if(rst)
      v_loc <= 10'b0000000001;
    else if(h_loc == 11'b11001000000 && v_loc >= 10'b1000001101)  // 525, end of frame
      v_loc <= 10'b0000000001;  // Reset to start of frame
    else if(h_loc == 11'b11001000000)  // End of one horizontal line
      v_loc <= v_loc + 10'b0000000001;  // Increment for vertical position
    else
      v_loc <= v_loc;
  
    // Horizontal sync signal (active low, 96 cycles)
    if(rst)
      h_sync <= 1'b0;
    else if(h_loc == 11'b1010010000)  // 656, start of sync pulse
      h_sync <= 1'b1;
    else if(h_loc == 11'b1011111000)  // 752, end of sync pulse
      h_sync <= 1'b0;
    
    // Vertical sync signal (active low, 2 lines)
    if(rst)
      v_sync <= 1'b0;
    else if(v_loc == 10'b1111011011)  // 491, start of vertical sync pulse
      v_sync <= 1'b1;
    else if(v_loc == 10'b1111011111)  // 493, end of vertical sync pulse
      v_sync <= 1'b0;
    
    // Horizontal display enable signal (active high, 640 pixels)
    if(rst)
      h_disp <= 1'b1;
    else if(h_loc == 11'b10100010000)  // 640, end of visible area
      h_disp <= 1'b0;
    else if(h_loc == 11'b0000000001)  // 1, start of visible area
      h_disp <= 1'b1;
  
    // Vertical display enable signal (active high, 480 lines)
    if(rst)
      v_disp <= 1'b1;
    else if(v_loc == 10'b1111001000)  // 480, end of visible area
      v_disp <= 1'b0;
    else if(v_loc == 10'b0000000001)  // 1, start of visible area
      v_disp <= 1'b1;

  end
  
endmodule

