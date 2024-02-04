module Handshake_syn #(parameter WIDTH=32) (
    sclk,
    dclk,
    rst_n,
    sready,
    din,
    dbusy,
    sidle,
    dvalid,
    dout,

    clk1_handshake_flag1,
    clk1_handshake_flag2,
    clk1_handshake_flag3,
    clk1_handshake_flag4,

    handshake_clk2_flag1,
    handshake_clk2_flag2,
    handshake_clk2_flag3,
    handshake_clk2_flag4
);

input sclk, dclk;
input rst_n;
input sready;
input [WIDTH-1:0] din;
input dbusy;
output sidle;
output reg dvalid;
output reg [WIDTH-1:0] dout;

// You can change the input / output of the custom flag ports
input clk1_handshake_flag1;
input clk1_handshake_flag2;
output clk1_handshake_flag3;
output clk1_handshake_flag4;

input handshake_clk2_flag1;
input handshake_clk2_flag2;
output handshake_clk2_flag3;
output handshake_clk2_flag4;

// Remember:
//   Don't modify the signal name
reg sreq;
wire dreq;
reg dack;
wire sack;

NDFF_syn NDFF0 (.D(sreq), .Q(dreq), .clk(dclk), .rst_n(rst_n));
NDFF_syn NDFF1 (.D(dack), .Q(sack), .clk(sclk), .rst_n(rst_n));

reg [WIDTH-1:0] temp_data, temp_data_2;
reg sCtrl, dCtrl, dCtrl_d1, dCtrl_d2;
reg dbusy_d1, dbusy_d2;

NDFF_BUS_syn  #(32) U0 (.D(temp_data), .Q(temp_data_2), .clk(dclk), .rst_n(rst_n));

always @(posedge dclk or negedge rst_n) begin
    if(!rst_n) begin
        dCtrl_d1 <= 0;
        dCtrl_d2 <= 0;
    end
    else begin
        dCtrl_d1 <= dCtrl;
        dCtrl_d2 <= dCtrl_d1;
    end
end

always @(posedge sclk or negedge rst_n) begin
    if(!rst_n)
        sreq <= 0;
    else 
        sreq <= sready ? 1 : 0 ; // sreq = sready;
end

always @(posedge sclk or negedge rst_n) begin // ! can be removed
    if(!rst_n)
        sCtrl <= 0;
    else 
        sCtrl <= sready ? 1 : 0 ; // sCtrl = sready;
end

always @(posedge sclk or negedge rst_n) begin
    if(!rst_n)
        temp_data <= 0;
    else 
        temp_data <= sCtrl ? din : temp_data ; // temp_data = din;
end

always @(posedge dclk or negedge rst_n) begin
    if(!rst_n)
        dCtrl <= 0;
    else 
        dCtrl <= dreq ? 1 : 0 ; // dCtrl <= dreq
end

always @(posedge dclk or negedge rst_n) begin
    if(!rst_n)
        dack <= 0;
    else 
        dack <= (dbusy || dbusy_d1 || dbusy_d2) ? 1 : (!dreq) ? 0 : dack ;
end

always @(posedge dclk or negedge rst_n) begin
    if(!rst_n) begin
        dbusy_d1 <= 0;
        dbusy_d2 <= 0;
    end
    else begin
        dbusy_d1 <= dbusy;
        dbusy_d2 <= dbusy_d1;
    end
end

always @(posedge dclk or negedge rst_n) begin
    if(!rst_n)
        dout <= 0;
    else
        dout <= dCtrl_d2 ? temp_data_2 : dout ;
end

always @(posedge dclk or negedge rst_n) begin
    if(!rst_n)
        dvalid <= 0;
    else 
        dvalid <= (dbusy || dack) ? 0 : (dCtrl_d2) ? 1 : dvalid;
end

assign sidle = sreq & sack;



endmodule