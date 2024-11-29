`timescale 1ns / 1ps

module top_module(
    input clk,
    input button,
    input reset,
    output [11:0] pixel,
    output v_sync, h_sync
);

// Wires for VGA display
wire v_disp, h_disp, clk_40;
wire [9:0] v_loc;
wire [10:0] h_loc;
reg [11:0] pixel_reg;
wire max_tick;
reg [9:0] v_head;
reg [10:0] h_head;
reg [5:0] h_drs [99:0]; // Positions of the snake body (horizontal)
reg [5:0] v_drs [99:0]; // Positions of the snake body (vertical)
reg [9:0] count;
wire db;
integer i;

// Initialize the snake body
initial begin
    count = 5;
    for(i = 5; i < 100; i = i + 1) begin
        v_drs[i] = 0;
        h_drs[i] = 0;
    end
    v_drs[0] = 10;
    h_drs[0] = 15;
    v_drs[1] = 10;
    h_drs[1] = 14;
    v_drs[2] = 10;
    h_drs[2] = 13;
    v_drs[3] = 10;
    h_drs[3] = 12;
    v_drs[4] = 10;
    h_drs[4] = 11;
end

// Update snake head position
always @(posedge clk_40) begin
    if (reset) begin
        v_head <= 200;  // Reset vertical head position
        h_head <= 300;  // Reset horizontal head position
    end else begin
        if (max_tick && db == 0) begin  // Move horizontally (right) if db == 0
            v_head <= v_head;  // No change in vertical position
            h_head <= h_head + 20;  // Move right by 20 pixels
            if (h_head > 639)  // If head exceeds visible area horizontally (0–639)
                h_head <= 20;  // Wrap to the left edge
        end else if (max_tick && db == 1) begin  // Move vertically (down) if db == 1
            v_head <= v_head + 20;  // Move down by 20 pixels vertically
            h_head <= h_head;  // No change in horizontal position
            if (v_head > 479)  // If head exceeds visible area vertically (0–479)
                v_head <= 20;  // Wrap to the top edge
        end else begin
            v_head <= v_head;  // No movement if no button pressed
            h_head <= h_head;
        end
    end
end

// Update snake body positions
always @(posedge clk_40) begin
    if (reset) begin
        v_drs[0] <= 10;
        h_drs[0] <= 15;
        v_drs[1] <= 10;
        h_drs[1] <= 14;
        v_drs[2] <= 10;
        h_drs[2] <= 13;
        v_drs[3] <= 10;
        h_drs[3] <= 12;
        v_drs[4] <= 10;
        h_drs[4] <= 11;
    end else if (max_tick) begin
        for (i = count - 1; i >= 0; i = i - 1) begin
            if (i == 0) begin
                v_drs[i] <= v_head / 20;
                h_drs[i] <= h_head / 20;
            end else begin
                v_drs[i] <= v_drs[i - 1];
                h_drs[i] <= h_drs[i - 1];
            end
        end
    end
end

// Collision detection (self-collision)
always @(*) begin
    // Initialize pixel color to green (background)
    pixel_reg = {4'b0000, 4'b1111, 4'b0000};  // RGB format: Green background
    
    if (v_disp && h_disp && ~reset) begin
        // Check if any part of the snake's body overlaps the head position
        for (i = 0; i < count; i = i + 1) begin
            if (h_loc > h_drs[i] * 20 - 10 && h_loc < h_drs[i] * 20 + 10 &&
                v_loc > v_drs[i] * 20 - 10 && v_loc < v_drs[i] * 20 + 10) begin
                pixel_reg = {4'b1111, 4'b0000, 4'b0000};  // Red for snake body
            end
        end
        
        // If head collides with body, game over logic can be triggered
        if ((h_loc > h_head * 20 - 10 && h_loc < h_head * 20 + 10) && 
            (v_loc > v_head * 20 - 10 && v_loc < v_head * 20 + 10)) begin
            pixel_reg = {4'b0000, 4'b0000, 4'b0000};  // Collision, pixel goes black (game over)
        end
    end else if (v_disp && h_disp) begin
        pixel_reg = {4'b0000, 4'b0000, 4'b1111};  // Blue for the border
    end else begin
        pixel_reg = {12'b000000000000};  // Blank (black)
    end
end

assign pixel = pixel_reg;

// Instantiate display synchronization (VGA timing and display logic)
disp_sync D0 (
    .clk(clk_40),
    .rst(reset),
    .v_sync(v_sync),
    .h_sync(h_sync),
    .v_disp(v_disp),
    .h_disp(h_disp),
    .h_loc(h_loc),
    .v_loc(v_loc)
);

// Instantiate mod_m_counter for the clock divider
mod_m_counter #(.M(20000000)) M0 (
    .clk(clk_40),
    .reset(reset),
    .max_tick(max_tick)
);

// Debounce circuit for the button press
button_circuit B0 (
    .clk(clk_40),
    .reset(reset),
    .db(db),
    .sw(button)
);

// Instantiate the clock generator (to generate clk_40)
clk_wiz_0 instance_name (
    .clk_out1(clk_40),   // output clk_40
    .reset(reset),       // input reset
    .locked(),           // output locked
    .clk_in(clk)         // input clk_in
);

endmodule
