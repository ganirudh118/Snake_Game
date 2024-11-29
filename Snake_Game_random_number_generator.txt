`timescale 1ns / 1ps


module random_num_generator(
input clk,reset, vh,hh,
output [4:0] rand
    );
    reg [4:0] rand_next,rand_reg;
    initial
    begin
        rand_next=5'b10110;
    end
    
    always@(posedge clk)
    begin
        if(reset)
        begin
            rand_reg<=5'b10110;
        end
        else
        begin
            rand_reg<=rand_next;
        end
    end
    
    always@(*)
    begin
    rand_next=rand_reg;
        case({vh,hh})
        2'b00:
        begin
            rand_next={rand_reg[3]^rand_reg[0],rand_reg[1],~rand_reg[4]^~rand_reg[2],rand_reg[1]^rand_reg[2]^(~rand_reg[3]),~rand_reg[3]};
        end
        2'b01:
        begin
            rand_next={~rand_reg[2],rand_reg[1]^rand_reg[2],~rand_reg[0]^rand_reg[3]^rand_reg[1],rand_reg[4]^rand_reg[3],rand_reg[1]};
        end
        2'b10:
        begin
            rand_next={rand_reg[4]^rand_reg[0]^(~rand_reg[1]),rand_reg[1]^rand_reg[2],~rand_reg[4]^rand_reg[3],rand_reg[2]^rand_reg[3],~rand_reg[0]^rand_reg[1]};
        end
        2'b11:
        begin
            rand_next={rand_reg[0]^(~rand_reg[1]),rand_reg[4]^(~rand_reg[3]),~rand_reg[4]^~rand_reg[1]^rand_reg[0],rand_reg[1],~rand_reg[1]^rand_reg[2]};
        end
        endcase
    end
    
    assign rand=rand_reg;
endmodule
