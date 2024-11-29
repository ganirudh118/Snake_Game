module mod_m_counter
#(parameter M=10)
(
input clk, reset,
//output [N-1:0] q,
output max_tick
); 
localparam N = $clog2 (M); // N is a constant representing number of necessary bits for the counter
// signal declaration
reg [N-1:0] r_next, r_reg;

// body
// [1] Register segment
always@(posedge clk)
begin
if (reset)
r_reg <= 0;
else
r_reg <=r_next;

end
// [2] next-state logic segment
always@(*)
begin
    r_next = (r_reg ==(M-1)) ? 0: r_reg + 1;
end

assign max_tick = (r_reg == (M-1)) ? 1'b1 : 1'b0;

endmodule
