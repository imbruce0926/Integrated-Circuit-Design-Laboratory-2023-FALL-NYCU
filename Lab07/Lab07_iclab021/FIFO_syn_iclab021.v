module FIFO_syn #(parameter WIDTH=32, parameter WORDS=64) (
    wclk,
    rclk,
    rst_n,
    winc,
    wdata,
    wfull,
    rinc,
    rdata,
    rempty,

    clk2_fifo_flag1,
    clk2_fifo_flag2,
    clk2_fifo_flag3,
    clk2_fifo_flag4,

    fifo_clk3_flag1,
    fifo_clk3_flag2,
    fifo_clk3_flag3,
    fifo_clk3_flag4
);

input wclk, rclk;
input rst_n;
input winc;
input [WIDTH-1:0] wdata;
output wfull; // ! reg
input rinc;
output reg [WIDTH-1:0] rdata;
output rempty; // ! reg

// You can change the input / output of the custom flag ports
input clk2_fifo_flag1;
input clk2_fifo_flag2;
output clk2_fifo_flag3;
output clk2_fifo_flag4;

input fifo_clk3_flag1;
input fifo_clk3_flag2;
output fifo_clk3_flag3;
output fifo_clk3_flag4;

wire [WIDTH-1:0] rdata_q;
// reg [WIDTH-1:0] wdata_d;
wire [$clog2(WORDS)-1:0] waddr, raddr;
wire [$clog2(WORDS):0] wptr_rclk, rptr_wclk;
wire [$clog2(WORDS):0] wbin, rbin;

// Remember: 
//   wptr and rptr should be gray coded
//   Don't modify the signal name
wire [$clog2(WORDS):0] wptr; // ! reg
wire [$clog2(WORDS):0] rptr; // ! reg

// rdata
//  Add one more register stage to rdata
always @(posedge rclk) begin
    if (rinc)
        rdata <= rdata_q;
end

DUAL_64X32X1BM1 u_dual_sram (
    .CKA(wclk),
    .CKB(rclk),
    .WEAN(!winc),
    .WEBN(1'b1),
    .CSA(1'b1),
    .CSB(1'b1),
    .OEA(1'b1),
    .OEB(1'b1),
    .A0(waddr[0]),
    .A1(waddr[1]),
    .A2(waddr[2]),
    .A3(waddr[3]),
    .A4(waddr[4]),
    .A5(waddr[5]),
    .B0(raddr[0]),
    .B1(raddr[1]),
    .B2(raddr[2]),
    .B3(raddr[3]),
    .B4(raddr[4]),
    .B5(raddr[5]),
    .DIA0(wdata[0]),
    .DIA1(wdata[1]),
    .DIA2(wdata[2]),
    .DIA3(wdata[3]),
    .DIA4(wdata[4]),
    .DIA5(wdata[5]),
    .DIA6(wdata[6]),
    .DIA7(wdata[7]),
    .DIA8(wdata[8]),
    .DIA9(wdata[9]),
    .DIA10(wdata[10]),
    .DIA11(wdata[11]),
    .DIA12(wdata[12]),
    .DIA13(wdata[13]),
    .DIA14(wdata[14]),
    .DIA15(wdata[15]),
    .DIA16(wdata[16]),
    .DIA17(wdata[17]),
    .DIA18(wdata[18]),
    .DIA19(wdata[19]),
    .DIA20(wdata[20]),
    .DIA21(wdata[21]),
    .DIA22(wdata[22]),
    .DIA23(wdata[23]),
    .DIA24(wdata[24]),
    .DIA25(wdata[25]),
    .DIA26(wdata[26]),
    .DIA27(wdata[27]),
    .DIA28(wdata[28]),
    .DIA29(wdata[29]),
    .DIA30(wdata[30]),
    .DIA31(wdata[31]),
    .DIB0(1'b0),
    .DIB1(1'b0),
    .DIB2(1'b0),
    .DIB3(1'b0),
    .DIB4(1'b0),
    .DIB5(1'b0),
    .DIB6(1'b0),
    .DIB7(1'b0),
    .DIB8(1'b0),
    .DIB9(1'b0),
    .DIB10(1'b0),
    .DIB11(1'b0),
    .DIB12(1'b0),
    .DIB13(1'b0),
    .DIB14(1'b0),
    .DIB15(1'b0),
    .DIB16(1'b0),
    .DIB17(1'b0),
    .DIB18(1'b0),
    .DIB19(1'b0),
    .DIB20(1'b0),
    .DIB21(1'b0),
    .DIB22(1'b0),
    .DIB23(1'b0),
    .DIB24(1'b0),
    .DIB25(1'b0),
    .DIB26(1'b0),
    .DIB27(1'b0),
    .DIB28(1'b0),
    .DIB29(1'b0),
    .DIB30(1'b0),
    .DIB31(1'b0),
    .DOB0(rdata_q[0]),
    .DOB1(rdata_q[1]),
    .DOB2(rdata_q[2]),
    .DOB3(rdata_q[3]),
    .DOB4(rdata_q[4]),
    .DOB5(rdata_q[5]),
    .DOB6(rdata_q[6]),
    .DOB7(rdata_q[7]),
    .DOB8(rdata_q[8]),
    .DOB9(rdata_q[9]),
    .DOB10(rdata_q[10]),
    .DOB11(rdata_q[11]),
    .DOB12(rdata_q[12]),
    .DOB13(rdata_q[13]),
    .DOB14(rdata_q[14]),
    .DOB15(rdata_q[15]),
    .DOB16(rdata_q[16]),
    .DOB17(rdata_q[17]),
    .DOB18(rdata_q[18]),
    .DOB19(rdata_q[19]),
    .DOB20(rdata_q[20]),
    .DOB21(rdata_q[21]),
    .DOB22(rdata_q[22]),
    .DOB23(rdata_q[23]),
    .DOB24(rdata_q[24]),
    .DOB25(rdata_q[25]),
    .DOB26(rdata_q[26]),
    .DOB27(rdata_q[27]),
    .DOB28(rdata_q[28]),
    .DOB29(rdata_q[29]),
    .DOB30(rdata_q[30]),
    .DOB31(rdata_q[31])
);

wptr_full w0 (
    .wfull(wfull),
    .waddr(waddr),
    .wptr(wptr),
    .wbin(wbin),
    .rptr_wclk(rptr_wclk),
    .winc(winc),
    .wclk(wclk),
    .rst_n(rst_n),
    .clk2_fifo_flag3(clk2_fifo_flag3)
);

rptr_full r0 (
    .rempty(rempty),
    .raddr(raddr),
    .rptr(rptr),
    .rbin(rbin),
    .wptr_rclk(wptr_rclk),
    .rinc(rinc),
    .rclk(rclk),
    .rst_n(rst_n)
);

NDFF_BUS_syn #($clog2(WORDS) + 1) w_to_r (.D(wptr), .Q(wptr_rclk), .clk(rclk), .rst_n(rst_n));
NDFF_BUS_syn #($clog2(WORDS) + 1) r_to_w (.D(rptr), .Q(rptr_wclk), .clk(wclk), .rst_n(rst_n));


endmodule




module wptr_full #(parameter ADDR_SIZE = 6) (
    wfull,
    waddr,
    wptr,
    wbin,
    rptr_wclk,
    winc,
    wclk,
    rst_n,
    clk2_fifo_flag3
);

output reg wfull;
output [ADDR_SIZE-1:0] waddr;
output reg [ADDR_SIZE:0] wptr;
output reg [ADDR_SIZE:0] wbin;
input [ADDR_SIZE:0] rptr_wclk;
input winc, wclk, rst_n, clk2_fifo_flag3;

wire [ADDR_SIZE:0] wptr_nxt, wbin_nxt;

assign wbin_nxt = !wfull && winc ? wbin + 1 : wbin;
assign wptr_nxt = (wbin_nxt >> 1) ^ wbin_nxt;

always @(posedge wclk or negedge rst_n) begin
    if(!rst_n) 
        wbin <= 0;
    else 
        wbin <= wbin_nxt;
end

always @(posedge wclk or negedge rst_n) begin
    if(!rst_n) 
        wptr <= 0;
    else 
        wptr <= wptr_nxt;
end

assign waddr = wbin[ADDR_SIZE-1:0];

always @(posedge wclk or negedge rst_n) begin
    if(!rst_n)
        wfull <= 0;
    else begin
        if(~wptr_nxt[ADDR_SIZE] == rptr_wclk[ADDR_SIZE] && (wptr_nxt[ADDR_SIZE] ^ wptr_nxt[ADDR_SIZE-1]) == (rptr_wclk[ADDR_SIZE] ^ rptr_wclk[ADDR_SIZE-1]) && wptr_nxt[ADDR_SIZE-2:0] == rptr_wclk[ADDR_SIZE-2:0])
            wfull <= 1;
        else
            wfull <= 0;
    end
end


endmodule

module rptr_full #(parameter ADDR_SIZE = 6) (
    rempty,
    raddr,
    rptr,
    rbin,
    wptr_rclk,
    rinc,
    rclk,
    rst_n
);

output reg rempty;
output [ADDR_SIZE-1:0] raddr;
output reg [ADDR_SIZE:0] rptr;
output reg [ADDR_SIZE:0] rbin;
input [ADDR_SIZE:0] wptr_rclk;
input rinc, rclk, rst_n;

wire [ADDR_SIZE:0] rptr_nxt, rbin_nxt;

assign rbin_nxt = rinc ? rbin + 1 : rbin;
assign rptr_nxt = (rbin_nxt >> 1) ^ rbin_nxt;

always @(posedge rclk or negedge rst_n) begin
    if(!rst_n) 
        rbin <= 0;
    else 
        rbin <= rbin_nxt;
end

always @(posedge rclk or negedge rst_n) begin
    if(!rst_n) 
        rptr <= 0;
    else 
        rptr <= rptr_nxt;
end

assign raddr = rbin[ADDR_SIZE-1:0];

always @(posedge rclk or negedge rst_n) begin
    if(!rst_n)
        rempty <= 1;
    else begin
        if(rptr_nxt == wptr_rclk)
            rempty <= 1;
        else 
            rempty <= 0;
    end
end


endmodule