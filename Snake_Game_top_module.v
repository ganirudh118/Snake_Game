`timescale 1ns / 1ps


module top_module(
    input clk,
    input button,
    input reset,
    output [11:0] pixel,
    output v_sync,h_sync
);


wire v_disp,h_disp,clk_40;
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


integer i;
initial begin
count=5;
for(i=5;i<100;i=i+1)
begin
    v_drs[i]=0;
    h_drs[i]=0;
end
v_drs[0]=10;
    h_drs[0]=15;
    v_drs[1]=10;
    h_drs[1]=14;
    v_drs[2]=10;
    h_drs[2]=13;
    v_drs[3]=10;
    h_drs[3]=12;
    v_drs[4]=10;
    h_drs[4]=11;
end



always@(posedge clk_40)
begin
if(reset)
begin
v_head<=200;
h_head<=300;
    
end
else
begin
    if(max_tick && db==0)
    begin
        v_head<=v_head;
        h_head<=h_head+20;
        if(h_head>799)
            h_head<=20;
    end
    else if(max_tick && db==1)
    begin
        v_head<=v_head+20;
        h_head<=h_head;
        if(v_head>599)
            v_head<=20;
    end
    else
    begin
        v_head<=v_head;
        h_head<=h_head;
    end
    
end
end


always@(posedge clk_40)
begin
if(reset)
begin
    v_drs[0]=10;
    h_drs[0]=15;
    v_drs[1]=10;
    h_drs[1]=14;
    v_drs[2]=10;
    h_drs[2]=13;
    v_drs[3]=10;
    h_drs[3]=12;
    v_drs[4]=10;
    h_drs[4]=11;    
end
    
    begin
    if(max_tick)
    begin
    for(i=count-1;i>=0;i=i-1)
    begin
        if(i==0)
        begin
            v_drs[i]=v_head/20;
            h_drs[i]=h_head/20;
            
        end
        else
        begin
            v_drs[i]=v_drs[i-1];
            h_drs[i]=h_drs[i-1];
        end
    end
    end
     
    end
    
end

always@(*)
begin
    if(v_disp && h_disp && ~reset)
    begin
        //if(h_loc>h_head && h_loc<h_head+20 && v_loc>v_head && v_loc<v_head+20)
          //  pixel_reg={4'b1111,4'b0000,4'b0000};
        //else
            pixel_reg={4'b0000,4'b1111,4'b0000};
            for(i=0;i<5;i=i+1)
            begin
               if(h_loc>h_drs[i]*20-10 && h_loc<h_drs[i]*20+10 && v_loc>v_drs[i]*20-10 && v_loc<v_drs[i]*20+10)
               //begin
                    pixel_reg={4'b1111,4'b0000,4'b0000};
               //if(h_loc>h_drs[1]*20-10 && h_loc<h_drs[1]*20+10 && v_loc>v_drs[1]*20-10 && v_loc<v_drs[1]*20+10)
               //begin
                 //   pixel_reg={4'b1111,4'b0000,4'b0000};
                    //break;
               //end 
            end         
            
    end
    else
        if(v_disp && h_disp)
        pixel_reg={4'b0000,4'b0000,4'b1111};
        else
        pixel_reg={12'b000000000000};

end
//assign pixel={4'b1111,4'b1011,4'b1000};
assign pixel=pixel_reg;
//pixeled_display P0(.pixel_r(4'b1011), .pixel_g(4'b1000), .pixel_b(4'b0110),.v_disp(v_disp),.h_disp(h_disp),.clk(clk),.reset(reset),.RGB());
disp_sync D0(.clk(clk_40),.rst(reset),.v_sync(v_sync),.h_sync(h_sync),.v_disp(v_disp),.h_disp(h_disp),.h_loc(h_loc),.v_loc(v_loc)); 
mod_m_counter #(.M(20000000)) M0(.clk(clk_40),.reset(reset),.max_tick(max_tick));

button_circuit B0(.clk(clk_40),.reset(reset),.db(db),.sw(button));
// The following must be inserted into your Verilog file for this
// core to be instantiated. Change the instance name and port connections
// (in parentheses) to your own signal names.

//----------- Begin Cut here for INSTANTIATION Template ---// INST_TAG

  clk_wiz_0 instance_name
   (
    // Clock out ports
    .clk_out1(clk_40),     // output clk_out1
    // Status and control signals
    .reset(reset), // input reset
    .locked(),      // output locked
   // Clock in ports
    .clk_in(clk)      // input clk_in
);

endmodule

