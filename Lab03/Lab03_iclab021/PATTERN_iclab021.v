`ifdef RTL
    `define CYCLE_TIME 40.0
`endif
`ifdef GATE
    `define CYCLE_TIME 40.0
`endif

`include "../00_TESTBED/pseudo_DRAM.v"
`include "../00_TESTBED/pseudo_SD.v"

module PATTERN(
    // Input Signals
    clk,
    rst_n,
    in_valid,
    direction,
    addr_dram,
    addr_sd,
    // Output Signals
    out_valid,
    out_data,
    // DRAM Signals
    AR_VALID, AR_ADDR, R_READY, AW_VALID, AW_ADDR, W_VALID, W_DATA, B_READY,
	AR_READY, R_VALID, R_RESP, R_DATA, AW_READY, W_READY, B_VALID, B_RESP,
    // SD Signals
    MISO,
    MOSI
);

/* Input for design */
output reg        clk, rst_n;
output reg        in_valid;
output reg        direction;
output reg [12:0] addr_dram;
output reg [15:0] addr_sd;

/* Output for pattern */
input        out_valid;
input  [7:0] out_data; 

// DRAM Signals
// write address channel
input [31:0] AW_ADDR;
input AW_VALID;
output AW_READY;
// write data channel
input W_VALID;
input [63:0] W_DATA;
output W_READY;
// write response channel
output B_VALID;
output [1:0] B_RESP;
input B_READY;
// read address channel
input [31:0] AR_ADDR;
input AR_VALID;
output AR_READY;
// read data channel
output [63:0] R_DATA;
output R_VALID;
output [1:0] R_RESP;
input R_READY;

// SD Signals
output MISO;
input MOSI;

real CYCLE = `CYCLE_TIME;
integer pat_read;
integer PAT_NUM;
integer total_latency, latency;
integer i_pat;
integer i, j;
reg [3:0] count;

reg        direction_temp;
reg [12:0] addr_dram_temp;
reg [15:0] addr_sd_temp;

reg [63:0] dram_data, sd_data;
reg [63:0] DRAM_temp [0:8191];
reg [63:0] SD_temp [0:65535];

always #(CYCLE/2.0) clk = ~clk;

// always @(negedge clk) begin
//     if(out_valid === 1 && out_data !== 0) begin
        
//     end
// end

always @(negedge clk) begin
    if(out_valid === 0 && out_data !== 0) begin
        SPEC_2;
    end
end
// initial clk = 0;

initial begin
    clk = 0;
    pat_read = $fopen("../00_TESTBED/Input.txt", "r");
    reset_signal_task;

    count = 0;

    i=0;
    i_pat = 0;
    total_latency = 0;
    $fscanf(pat_read, "%d", PAT_NUM);
    for (i_pat = 1; i_pat <= PAT_NUM; i_pat = i_pat + 1) begin
        input_task;
        wait_out_valid_task;
        check_ans_task;
        total_latency = total_latency + latency;
        $display("PASS PATTERN NO.%4d", i_pat);
    end
    $fclose(pat_read);

    $writememh("../00_TESTBED/DRAM_final.dat", u_DRAM.DRAM);
    $writememh("../00_TESTBED/SD_final.dat", u_SD.SD);
    YOU_PASS_task;
end

//////////////////////////////////////////////////////////////////////
// Write your own task here
//////////////////////////////////////////////////////////////////////

task reset_signal_task; begin
    

    rst_n = 1'b1;

    in_valid = 1'b0;

    direction = 1'b0;

    addr_dram = 13'b0;

    addr_sd = 16'b0;

    total_latency = 0;

    force clk = 1'b0;
    
    #(CYCLE);

    rst_n = 1'b0;

    #(100);

    

    // #(100);
    rst_n = 1'b1;
    if( out_valid !== 0 || 
        out_data !== 0 ||
        AW_ADDR !== 0 || 
        AW_VALID !== 0 ||
        W_VALID !== 0 || 
        W_DATA !== 0 ||
        B_READY !== 0 || 
        AR_ADDR !== 0 ||
        AR_VALID !== 0 || 
        R_READY !== 0 ||
        MOSI !== 1
    ) begin
        SPEC_1;
    end

    #(120);
    release clk;
end
endtask


task input_task; begin
    
    repeat($urandom_range(3, 5)) @(negedge clk);
    in_valid = 1'b1;
    $fscanf(pat_read, "%d %d %d", direction, addr_dram, addr_sd);
    dram_data = u_DRAM.DRAM[addr_dram];
    sd_data = u_SD.SD[addr_sd];

    for(j = 0; j <= 8191; j++) begin
        DRAM_temp[j] = u_DRAM.DRAM[j];
    end
    for(j = 0; j <= 65535; j++) begin
        SD_temp[j] = u_SD.SD[j];
    end

    direction_temp = direction;
    addr_dram_temp = addr_dram;
    addr_sd_temp = addr_sd;
    // $display("%d", direction);
    // $display("%d", addr_dram);
    // $display("%d", addr_sd);


    @(negedge clk);
    in_valid = 1'b0;
    direction = 1'b0;
    addr_dram = 'b0;
    addr_sd = 'b0;


end
endtask

task wait_out_valid_task; begin
    latency = 0;
    while(out_valid === 0) begin

        // if(out_valid === 0 && out_data !== 0) begin
        //     SPEC_2;
        // end

        if(latency === 10000) begin
            SPEC_3;
        end
        latency = latency + 1;
        @(negedge clk);
    end
end
endtask

task check_ans_task; begin
    count = 0;
    while(out_valid === 1 /*&& out_data !== 0*/) begin

        // $display("%d, %d", u_DRAM.DRAM[addr_dram_temp], u_SD.SD[addr_sd_temp]);

        if(u_DRAM.DRAM[addr_dram_temp] != u_SD.SD[addr_sd_temp]) begin
            SPEC_6;
        end

        // for(j = 0; j <= 8191; j++) begin
        //     if(j !== addr_dram_temp) begin
        //         if(DRAM_temp[j] != u_DRAM.DRAM[j])
        //             SPEC_6;
        //     end
        // end

        // for(j = 0; j <= 65535; j++) begin
        //     if(j !== addr_sd_temp) begin
        //         if(SD_temp[j] != u_SD.SD[j])
        //             SPEC_6;
        //     end
        // end


        if(direction_temp == 0) begin
            if(dram_data != u_DRAM.DRAM[addr_dram_temp])
                SPEC_6;
        end
        else begin
            if(sd_data != u_DRAM.DRAM[addr_dram_temp])
                SPEC_6;
        end
        

        case(count)
            7: begin
                if(direction_temp == 0) begin
                    if(u_DRAM.DRAM[addr_dram_temp][7:0] != out_data) begin
                        SPEC_5;
                    end
                    
                end
                else if(direction_temp == 1) begin
                    if(u_SD.SD[addr_sd_temp][7:0] != out_data) begin
                        SPEC_5;
                    end
                end
            end
            6: begin
                if(direction_temp == 0) begin
                    if(u_DRAM.DRAM[addr_dram_temp][15:8] != out_data) begin
                        SPEC_5;
                    end
                end
                else if(direction_temp == 1) begin
                    if(u_SD.SD[addr_sd_temp][15:8] != out_data) begin
                        SPEC_5;
                    end
                end
            end
            5: begin
                if(direction_temp == 0) begin
                    if(u_DRAM.DRAM[addr_dram_temp][23:16] != out_data) begin
                        SPEC_5;
                    end
                end
                else if(direction_temp == 1) begin
                    if(u_SD.SD[addr_sd_temp][23:16] != out_data) begin
                        SPEC_5;
                    end
                end
            end
            4: begin
                if(direction_temp == 0) begin
                    if(u_DRAM.DRAM[addr_dram_temp][31:24] != out_data) begin
                        SPEC_5;
                    end
                end
                else if(direction_temp == 1) begin
                    if(u_SD.SD[addr_sd_temp][31:24] != out_data) begin
                        SPEC_5;
                    end
                end
            end
            3: begin
                if(direction_temp == 0) begin
                    if(u_DRAM.DRAM[addr_dram_temp][39:32] != out_data) begin
                        SPEC_5;
                    end
                end
                else if(direction_temp == 1) begin
                    if(u_SD.SD[addr_sd_temp][39:32] != out_data) begin
                        SPEC_5;
                    end
                end
            end
            2: begin
                if(direction_temp == 0) begin
                    if(u_DRAM.DRAM[addr_dram_temp][47:40] != out_data) begin
                        SPEC_5;
                    end
                end
                else if(direction_temp == 1) begin
                    if(u_SD.SD[addr_sd_temp][47:40] != out_data) begin
                        SPEC_5;
                    end
                end
            end
            1: begin
                if(direction_temp == 0) begin
                    if(u_DRAM.DRAM[addr_dram_temp][55:48] != out_data) begin
                        SPEC_5;
                    end
                end
                else if(direction_temp == 1) begin
                    if(u_SD.SD[addr_sd_temp][55:48] != out_data) begin
                        SPEC_5;
                    end
                end
            end
            0: begin
                if(direction_temp == 0) begin
                    if(u_DRAM.DRAM[addr_dram_temp][63:56] != out_data) begin
                        SPEC_5;
                    end
                end
                else if(direction_temp == 1) begin
                    if(u_SD.SD[addr_sd_temp][63:56] != out_data) begin
                        SPEC_5;
                    end
                end
            end

        endcase
        

        count = count + 1 ;



        @(posedge clk);
        #(2);
        if(count > 8) begin
            SPEC_4;
        end
    end

    if(count !== 8) begin
        SPEC_4;
    end

end
endtask

task SPEC_1; begin
    $display("**************************************************************************************************************");
    $display("SPEC MAIN-1 FAIL");
    $display("**************************************************************************************************************");
    $finish;
end
endtask

task SPEC_2; begin
    $display("**************************************************************************************************************");
    $display("SPEC MAIN-2 FAIL");
    $display("**************************************************************************************************************");
    $finish;
end
endtask

task SPEC_3; begin
    $display("**************************************************************************************************************");
    $display("SPEC MAIN-3 FAIL");
    $display("**************************************************************************************************************");
    $finish;
end
endtask

task SPEC_4; begin
    $display("**************************************************************************************************************");
    $display("SPEC MAIN-4 FAIL");
    $display("**************************************************************************************************************");
    $finish;
end
endtask

task SPEC_5; begin
    $display("**************************************************************************************************************");
    $display("SPEC MAIN-5 FAIL");
    $display("**************************************************************************************************************");
    $finish;
end
endtask

task SPEC_6; begin
    $display("**************************************************************************************************************");
    $display("SPEC MAIN-6 FAIL");
    $display("**************************************************************************************************************");
    $finish;
end
endtask





//////////////////////////////////////////////////////////////////////

task YOU_PASS_task; begin
    $display("*************************************************************************");
    $display("*                         Congratulations!                              *");
    $display("*                Your execution cycles = %5d cycles          *", total_latency);
    $display("*                Your clock period = %.1f ns          *", CYCLE);
    $display("*                Total Latency = %.1f ns          *", total_latency*CYCLE);
    $display("*************************************************************************");
    $finish;
end endtask

// task YOU_FAIL_task; begin
//     $display("*                              FAIL!                                    *");
//     $display("*                    Error message from PATTERN.v                       *");
// end endtask

pseudo_DRAM u_DRAM (
    .clk(clk),
    .rst_n(rst_n),
    // write address channel
    .AW_ADDR(AW_ADDR),
    .AW_VALID(AW_VALID),
    .AW_READY(AW_READY),
    // write data channel
    .W_VALID(W_VALID),
    .W_DATA(W_DATA),
    .W_READY(W_READY),
    // write response channel
    .B_VALID(B_VALID),
    .B_RESP(B_RESP),
    .B_READY(B_READY),
    // read address channel
    .AR_ADDR(AR_ADDR),
    .AR_VALID(AR_VALID),
    .AR_READY(AR_READY),
    // read data channel
    .R_DATA(R_DATA),
    .R_VALID(R_VALID),
    .R_RESP(R_RESP),
    .R_READY(R_READY)
);

pseudo_SD u_SD (
    .clk(clk),
    .MOSI(MOSI),
    .MISO(MISO)
);

endmodule