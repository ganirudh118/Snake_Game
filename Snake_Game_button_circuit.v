`timescale 1ns / 1ps



module button_circuit(
input sw,reset,clk,
output db
    );
    
    wire m_tick;
    mod_m_counter #(.M(1_000_000)) M0(.clk(clk),.reset(reset),.max_tick(m_tick));
    //enum{zero,wait01,wait02,wait03,one,wait10,wait11,wait12} state_type;
    reg [2:0] state_next,state_reg;
    always@(posedge clk)
    begin
        if(reset)
        begin
            state_reg<=0;
        end
        else
        begin
            state_reg<=state_next;
        end
    end
    
    always@(*)
    begin
    case(state_reg)
    0:begin
    if(sw)
        state_next=1;
    else
        state_next=0;
    
    end
    
    1:begin
    if(sw==1 && m_tick==1)
        state_next=2;
    else if(sw==1 && m_tick==0)
        state_next=1;
    else
        state_next=0;
    end
    
    2:begin
    if(sw==1 && m_tick==1)
        state_next=3;
    else if(sw==1 && m_tick==0)
        state_next=2;
    else
        state_next=0;
    end

    3:begin
    if(sw==1 && m_tick==1)
        state_next=4;
    else if(sw==1 && m_tick==0)
        state_next=3;
    else
        state_next=0;
    end
    
    4:begin
    if(sw)
        state_next=4;
    else
        state_next=5;
    end
    
    5:begin
        if(sw==0 && m_tick==1)
        state_next=6;
        else if(sw==0 && m_tick==0)
        state_next=5;
    else
        state_next=4;
    end
    
    6:begin
        if(sw==0 && m_tick==1)
        state_next=7;
        else if(sw==0 && m_tick==0)
        state_next=6;
    else
        state_next=4;
    end
    
    7:begin
        if(sw==0 && m_tick==1)
        state_next=0;
        else if(sw==0 && m_tick==0)
        state_next=7;
    else
        state_next=4;
    end
    endcase
    end
    
    assign db=((state_reg==4)||(state_reg==5)||(state_reg==6)||(state_reg==7));
    
endmodule
