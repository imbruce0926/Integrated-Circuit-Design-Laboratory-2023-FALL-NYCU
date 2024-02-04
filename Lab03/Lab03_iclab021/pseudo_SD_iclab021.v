//############################################################################
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//   (C) Copyright Laboratory System Integration and Silicon Implementation
//   All Right Reserved
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//
//   2023 ICLAB Fall Course
//   Lab03      : BRIDGE
//   Author     : Ting-Yu Chang
//                
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//
//   File Name   : pseudo_SD.v
//   Module Name : pseudo_SD
//   Release version : v1.0 (Release Date: Sep-2023)
//
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//############################################################################

module pseudo_SD (
    clk,
    MOSI,
    MISO
);

input clk;
input MOSI;
output reg MISO;

parameter SD_p_r = "../00_TESTBED/SD_init.dat";

reg [63:0] SD [0:65535];
initial $readmemh(SD_p_r, SD);

integer pat_read;
integer PAT_NUM;
integer i_pat;
integer i;
integer t;

//////////////////////////////////////////////////////////////////////
// Write your own task here
//////////////////////////////////////////////////////////////////////


reg [5:0] command;
reg [31:0] addr;
reg [6:0] CRC_7, CRC_7_temp;
reg [15:0] CRC_16, CRC_16_temp;
reg [63:0] data;
reg [8:0] cnt;
reg endbit;

initial begin

    i_pat = 0;
    i = 0;

    while(1) begin
        MISO = 1;
        Command;
        Response;
        if(command === 17)
            Read;
        else if (command === 24)
            Write;
    end


end




task Command; begin

    command = 0;
    addr = 0;
    CRC_7 = 0;
    t = 0;
   
    while(MOSI === 1'b1 || MOSI === 1'bx) begin
        @(posedge clk);
        #(2);
    end
    
    
    @(posedge clk);
    #(2);
    

    if(MOSI === 0) begin
        $display("SPEC SD-1 FAIL");
        $display("***** Start Token *****");
        $finish;
    end


    for(i = 0; i < 6; i = i+1) begin
        @(posedge clk);
        #(2);

        if(MOSI === 1'bx) begin
            $display("SPEC SD-2 FAIL");
            $finish;
        end
        command = {command[4:0], MOSI};
    end

    if(!(command === 17 || command === 24)) begin
        $display("SPEC SD-1 FAIL");
        $display("***** command *****");
        $finish;
    end

    for(i = 0; i < 32; i = i+1) begin
        @(posedge clk);
        #(2);

        if(MOSI === 1'bx) begin
            $display("SPEC SD-2 FAIL");
            $finish;
        end
        addr = {addr[30:0], MOSI};
    end

    if(addr > 65535/* || addr === 'bx*/) begin              /* 0-65535 0以下應該不考慮 */
        $display("SPEC SD-2 FAIL");
        $finish;
    end

    for(i = 0; i < 7; i = i +1) begin
        @(posedge clk);
        #(2);

        if(MOSI === 1'bx) begin
            $display("SPEC SD-2 FAIL");
            $finish;
        end
        CRC_7 = {CRC_7[5:0], MOSI};
    end

    CRC_7_temp = CRC7({2'b01, command, addr});

    if(CRC_7 !== CRC_7_temp) begin
        $display("SPEC SD-3 FAIL");
        $finish;
    end


    @(posedge clk);
    #(2);
    if(MOSI === 0) begin
        $display("SPEC SD-1 FAIL");
        $display("SPEC End bit FAIL");
        $finish;
    end

    @(posedge clk);

end
endtask 

task Response; begin

    MISO = 0;

    for(i = 0; i < 8; i = i + 1) begin
        @(posedge clk);
    end

    MISO = 1;

end
endtask

task Read; begin
    repeat(8)@(posedge clk);

    MISO = 1;
    repeat(7)@(posedge clk);
    MISO = 0;
    @(posedge clk);

    data = SD[addr];

    for(i = 0; i < 64; i = i+1) begin
        MISO = data[63];
        data = {data[62:0], data[63]};
        @(posedge clk);
    end

    /* CRC */

    CRC_16 = CRC16_CCITT(data);

    for(i = 0; i < 16; i = i+1) begin
        MISO = CRC_16[15];
        CRC_16 = {CRC_16[14:0], CRC_16[15]};
        @(posedge clk);
    end

end
endtask

task Write; begin
    data = 0;
    CRC_16 = 0;
    cnt = 0;

    #(2);
    while(MOSI === 1) begin
        cnt = cnt + 1;
        @(posedge clk);
        #(2);
    end


    if(cnt < 15) begin
        $display("SPEC SD-5 FAIL");
        $finish;
    end

    if(cnt > 263) begin
        $display("SPEC SD-5 FAIL");
        $finish; 
    end

    if( ((cnt+1) % 8) !== 0) begin
        $display("SPEC SD-5 FAIL");
        $finish;
    end

    

    @(posedge clk);  // last bit of start token
    #(2);

    for(i = 0; i < 64; i = i + 1) begin
        data = {data[62:0], MOSI};
        @(posedge clk);
        #(2);
    end
    
    
    for(i = 0; i < 16; i = i + 1) begin
        CRC_16 = {CRC_16[14:0], MOSI};
        @(posedge clk);
        #(2);
    end

    CRC_16_temp = CRC16_CCITT(data);

    if(CRC_16 !== CRC_16_temp) begin
        $display("SPEC SD-4 FAIL");
        $finish;
    end

    MISO = 0;
    repeat(5)@(posedge clk);
    MISO = 1;
    @(posedge clk);
    MISO = 0;
    @(posedge clk);
    MISO = 1;
    @(posedge clk);
    
    MISO=0;
    repeat(8)@(posedge clk);
    SD[addr] = data;
    MISO=1;

end
endtask


task YOU_FAIL_task; begin
    $display("*                              FAIL!                                    *");
    $display("*                 Error message from pseudo_SD.v                        *");
end endtask

function automatic [6:0] CRC7;  // Return 7-bit result
    input [39:0] data;  // 40-bit data input
    reg [6:0] crc;
    integer i;
    reg data_in, data_out;
    parameter polynomial = 7'h9;  // x^7 + x^3 + 1

    begin
        crc = 7'd0;
        for (i = 0; i < 40; i = i + 1) begin
            data_in = data[39-i];
            data_out = crc[6];
            crc = crc << 1;  // Shift the CRC
            if (data_in ^ data_out) begin
                crc = crc ^ polynomial;
            end
        end
        CRC7 = crc;
    end
endfunction

function automatic [15:0] CRC16_CCITT;
    // Try to implement CRC-16-CCITT function by yourself.
    input [63:0] data;  // 64-bit data input
    reg [15:0] crc;
    integer i;
    reg data_in, data_out;
    parameter polynomial = 16'h1021;  // x^7 + x^3 + 1

    begin
        crc = 16'd0;
        for (i = 0; i < 64; i = i + 1) begin
            data_in = data[63-i];
            data_out = crc[15];
            crc = crc << 1;  // Shift the CRC
            if (data_in ^ data_out) begin
                crc = crc ^ polynomial;
            end
        end
        CRC16_CCITT = crc;
    end

endfunction

endmodule