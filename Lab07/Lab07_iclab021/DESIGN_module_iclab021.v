module CLK_1_MODULE (
    clk,
    rst_n,
    in_valid,
    seed_in,
    out_idle,
    out_valid,
    seed_out,

    clk1_handshake_flag1,
    clk1_handshake_flag2,
    clk1_handshake_flag3,
    clk1_handshake_flag4
);

input clk;
input rst_n;
input in_valid;
input [31:0] seed_in;
input out_idle;
output reg out_valid;
output reg [31:0] seed_out;

// You can change the input / output of the custom flag ports
input clk1_handshake_flag1;
input clk1_handshake_flag2;
output clk1_handshake_flag3;
output clk1_handshake_flag4;

always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        seed_out <= 0;
    else 
        seed_out <= (in_valid) ? seed_in : seed_out ;

end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        out_valid <= 0;
    else 
        out_valid <= in_valid ? 1 : 0 ;
end


endmodule

module CLK_2_MODULE (
    clk,
    rst_n,
    in_valid,
    fifo_full,
    seed,
    out_valid,
    rand_num,
    busy,

    handshake_clk2_flag1,
    handshake_clk2_flag2,
    handshake_clk2_flag3,
    handshake_clk2_flag4,

    clk2_fifo_flag1,
    clk2_fifo_flag2,
    clk2_fifo_flag3,
    clk2_fifo_flag4
);

input clk;
input rst_n;
input in_valid;
input fifo_full;
input [31:0] seed;
output out_valid;
output [31:0] rand_num;
output busy;

// You can change the input / output of the custom flag ports
input handshake_clk2_flag1;
input handshake_clk2_flag2;
output handshake_clk2_flag3;
output handshake_clk2_flag4;

input clk2_fifo_flag1;
input clk2_fifo_flag2;  
output reg clk2_fifo_flag3; // !
output clk2_fifo_flag4;

reg flag;
reg [31:0] seed_reg, seed_temp;
reg in_valid_d1, in_valid_d2, in_valid_d3;
reg [31:0] X1, X2, X3, X4;
reg [1:0] c_state, n_state;
parameter IDLE = 0;
parameter STALL = 1;
parameter OUTPUT = 2;

assign rand_num = X4;

reg [7:0] cnt_256;

NDFF_BUS_syn #(32) U0 (.D(seed), .Q(seed_temp), .clk(clk), .rst_n(rst_n));

always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        cnt_256 <= 0;
    else 
        cnt_256 <= c_state == OUTPUT ? cnt_256 + 1 : cnt_256 ;
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        c_state <= IDLE;
    else 
        c_state <= n_state;
end

always @(*) begin
    n_state = c_state;
    case(c_state)
        IDLE: n_state = (in_valid_d3) ? OUTPUT : c_state ;
        STALL: n_state = (fifo_full) ? c_state : OUTPUT ;
        OUTPUT: n_state = (cnt_256 == 255) ? IDLE : STALL ;
    endcase
end


assign out_valid = (c_state == OUTPUT) && !fifo_full; // !


always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        seed_reg <= 0;
    else 
        seed_reg <= (in_valid_d3) ? seed_temp : (c_state == OUTPUT) ? X4 : seed_reg;
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        in_valid_d1 <= 0;
        in_valid_d2 <= 0;
        in_valid_d3 <= 0;
    end
    else begin
        in_valid_d1 <= in_valid;
        in_valid_d2 <= in_valid_d1;
        in_valid_d3 <= in_valid_d2;
    end
end

assign busy = in_valid & ~in_valid_d1;

always @(*) begin
    X1 = seed_reg;
    X2 = X1 ^ (X1 << 13);
    X3 = X2 ^ (X2 >> 17);
    X4 = X3 ^ (X3 << 5);
end


endmodule

module CLK_3_MODULE (
    clk,
    rst_n,
    fifo_empty,
    fifo_rdata,
    fifo_rinc,
    out_valid,
    rand_num,

    fifo_clk3_flag1,
    fifo_clk3_flag2,
    fifo_clk3_flag3,
    fifo_clk3_flag4
);

input clk;
input rst_n;
input fifo_empty;
input [31:0] fifo_rdata;
output fifo_rinc;
output reg out_valid;
output reg [31:0] rand_num;

// You can change the input / output of the custom flag ports
input fifo_clk3_flag1;
input fifo_clk3_flag2;
output fifo_clk3_flag3;
output fifo_clk3_flag4;

parameter NOT_EMPT = 0;
parameter READ = 1;
parameter OUTPUT = 2;

reg [1:0] c_state, n_state;

assign fifo_rinc = c_state == READ && !fifo_empty; // !

reg fifo_empty_d1, fifo_empty_d2;



always @(posedge clk or negedge rst_n) begin
    if(!rst_n) 
        c_state <= 0;
    else 
        c_state <= n_state;
end

always @(*) begin
    n_state = c_state;
    case(c_state)
        NOT_EMPT: 
            n_state = (fifo_empty) ? c_state : READ ;
        READ: 
            n_state = OUTPUT;
        OUTPUT: 
            n_state = (fifo_empty) ? NOT_EMPT : READ ;
    endcase
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) 
        out_valid <= 0;
    else 
        out_valid <= (c_state == OUTPUT) ? 1 : 0 ;
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) 
        rand_num <= 0;
    else 
        rand_num <= (c_state == OUTPUT) ? fifo_rdata : 0 ;
end



endmodule