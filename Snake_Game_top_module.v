`timescale 1ns / 1ps

module top_module(
    input clk,
    input button,
    input reset,
    output [11:0] pixel,
    output v_sync, h_sync
);

wire v_disp, h_disp, clk_40;
wire [9:0] v_loc;
wire [10:0] h_loc;
reg [11:0] pixel_reg;
wire max_tick;
reg [9:0] v_head;
reg [10:0] h_head;
reg [3:0] count;
reg [5:0] h_drs [99:0];
reg [5:0] v_drs [99:0];
wire db;
reg [5:0] fruit_h, fruit_v; // Fruit position (in grid coordinates)
wire [4:0] random_value;    // Random number generated for fruit position

integer i;

// Initialize snake and variables
initial begin
    count = 5;
    for (i = 5; i < 100; i = i + 1) begin
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
    fruit_h = 10;
    fruit_v = 10;
end

// Head position update
always @(posedge clk_40) begin
    if (reset) begin
        v_head <= 200;
        h_head <= 300;
    end else begin
        if (max_tick && db == 0) begin
            h_head <= h_head + 20;
            if (h_head >= 639) // Wrap around horizontally
                h_head <= 0;
        end else if (max_tick && db == 1) begin
            v_head <= v_head + 20;
            if (v_head >= 479) // Wrap around vertically
                v_head <= 0;
        end else begin
            v_head <= v_head;
            h_head <= h_head;
        end
    end
end

// Body position update
always @(posedge clk_40) begin
    if (reset) begin
        count <= 5;
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
    end else if (max_tick) begin
        for (i = count - 1; i >= 0; i = i - 1) begin
            if (i == 0) begin
                v_drs[i] = v_head / 20;
                h_drs[i] = h_head / 20;
            end else begin
                v_drs[i] = v_drs[i - 1];
                h_drs[i] = h_drs[i - 1];
            end
        end
    end
end

// Check for fruit collision and increase snake length
always @(posedge clk_40) begin
    if (reset) begin
        fruit_h <= 10;
        fruit_v <= 10;
    end else if (h_head / 20 == fruit_h && v_head / 20 == fruit_v) begin
        // Snake eats the fruit
        count <= count + 1;
        fruit_h <= random_value % 32; // New random horizontal position
        fruit_v <= random_value % 24; // New random vertical position
    end
end

// Pixel rendering logic
always @(*) begin
    pixel_reg = {4'b0000, 4'b1111, 4'b0000}; // Default to green background
    
    if (v_disp && h_disp && ~reset) begin
        // Render snake body
        for (i = 0; i < count; i = i + 1) begin
            if (h_loc > h_drs[i] * 20 - 10 && h_loc < h_drs[i] * 20 + 10 &&
                v_loc > v_drs[i] * 20 - 10 && v_loc < v_drs[i] * 20 + 10) begin
                pixel_reg = {4'b1111, 4'b0000, 4'b0000}; // Snake body (red)
            end
        end

        // Render fruit
        if (h_loc > fruit_h * 20 - 10 && h_loc < fruit_h * 20 + 10 &&
            v_loc > fruit_v * 20 - 10 && v_loc < fruit_v * 20 + 10) begin
            pixel_reg = {4'b1111, 4'b1111, 4'b0000}; // Fruit (yellow)
        end
    end else if (v_disp && h_disp) begin
        pixel_reg = {4'b0000, 4'b0000, 4'b1111}; // Border (blue)
    end else begin
        pixel_reg = {12'b000000000000}; // Blank (black)
    end
end

// Assign outputs
assign pixel = pixel_reg;

// Instantiate modules
disp_sync D0(
    .clk(clk_40),
    .rst(reset),
    .v_sync(v_sync),
    .h_sync(h_sync),
    .v_disp(v_disp),
    .h_disp(h_disp),
    .h_loc(h_loc),
    .v_loc(v_loc)
);

mod_m_counter #(.M(20000000)) M0(
    .clk(clk_40),
    .reset(reset),
    .max_tick(max_tick)
);

button_circuit B0(
    .clk(clk_40),
    .reset(reset),
    .db(db),
    .sw(button)
);

random_num_generator RNG0(
    .clk(clk_40),
    .reset(reset),
    .vh(v_disp),
    .hh(h_disp),
    .rand(random_value)
);

clk_wiz_0 instance_name (
    .clk_out1(clk_40),     // output clk_out1
    .reset(reset),         // input reset
    .locked(),             // output locked
    .clk_in(clk)           // input clk_in
);

endmodule

