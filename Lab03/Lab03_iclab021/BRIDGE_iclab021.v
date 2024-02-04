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
//   File Name   : BRIDGE_encrypted.v
//   Module Name : BRIDGE
//   Release version : v1.0 (Release Date: Sep-2023)
//
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//############################################################################

module BRIDGE(
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

// Input Signals
input clk, rst_n;
input in_valid;
input direction;
input [12:0] addr_dram;
input [15:0] addr_sd;

// Output Signals
output reg out_valid;
output reg [7:0] out_data;

// DRAM Signals
// write address channel
output reg [31:0] AW_ADDR;
output reg AW_VALID;
input AW_READY;
// write data channel
output reg W_VALID;
output reg [63:0] W_DATA;
input W_READY;
// write response channel
input B_VALID;
input [1:0] B_RESP;
output reg B_READY;
// read address channel
output reg [31:0] AR_ADDR;
output reg AR_VALID;
input AR_READY;
// read data channel
input [63:0] R_DATA;
input R_VALID;
input [1:0] R_RESP;
output reg R_READY;

// SD Signals
input MISO;
output reg MOSI;

//==============================================//
//       parameter & integer declaration        //
//==============================================//
parameter IDLE = 0;
parameter INPUT = 1;
parameter SD_READ_CMD = 2;
parameter SD_READ_RES_0 = 3;
parameter SD_READ_RES_1 = 4;
parameter SD_READ_DATA = 5;
parameter SD_WRITE_CMD = 6;
parameter SD_WRITE_RES_DATA = 7;
parameter SD_WRITE_BUSY_0 = 8;
parameter SD_WRITE_BUSY_1 = 9;
parameter SD_WRITE_BUSY_2 = 10;
parameter SD_WRITE_BUSY_3 = 11;
parameter SD_WRITE_BUSY_4 = 12;
parameter DRAM_READ = 13;
parameter DRAM_WRITE = 14;
parameter GO_OUTPUT = 15;
parameter OUTPUT = 16;

//==============================================//
//           reg & wire declaration             //
//==============================================//
reg dir;
reg [12:0] address_dram;
reg [31:0] address_sd;
reg [4:0] c_state, n_state;
reg [6:0] CRC_7;
reg [15:0] CRC_16, CRC_16_DFF;
reg [63:0] data;
reg [5:0] command;
reg [47:0] CMD;


reg [5:0] cnt_CMD;
reg [6:0] cnt_DATA;
reg [6:0] cnt_RES_DATA;
reg [2:0] cnt_OUTPUT;
reg [7:0] FE;

//==============================================//
//                  design                      //
//==============================================//

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) 
        c_state <= IDLE;
    else 
        c_state <= n_state;
end

always @(*) begin
    case (c_state)
        IDLE: begin
            case(in_valid)
                1'b0: n_state = c_state;
                1'b1: n_state = INPUT;
            endcase
        end
        INPUT: begin
            if(!CMD)
                n_state = c_state;
            else begin
                case(dir)
                    1'b0: n_state = DRAM_READ;
                    1'b1: n_state = SD_READ_CMD;
                endcase
            end
        end 
        SD_READ_CMD: begin
            case(MISO)
                1'b0: n_state = SD_READ_RES_0;
                1'b1: n_state = c_state;
            endcase
        end 
        SD_READ_RES_0: begin
            case(MISO)
                1'b0: n_state = c_state;
                1'b1: n_state = SD_READ_RES_1;
            endcase
        end
        SD_READ_RES_1: begin
            case(MISO)
                1'b0: n_state = SD_READ_DATA;
                1'b1: n_state = c_state;
            endcase
        end  
        SD_READ_DATA: begin
            if(cnt_DATA == 81)
                n_state = DRAM_WRITE;
            else
                n_state = c_state;
        end 
        SD_WRITE_CMD: begin
            case(MISO)
                1'b0: n_state = SD_WRITE_RES_DATA;
                1'b1: n_state = c_state;
            endcase
        end
        SD_WRITE_RES_DATA: begin
            /* to SD_WRITE_BUSY */
            if(cnt_RES_DATA == 103)
                n_state = SD_WRITE_BUSY_0;
            else
                n_state = c_state;
        end  
        SD_WRITE_BUSY_0: begin
            case(MISO)
                1'b0: n_state = c_state;
                1'b1: n_state = SD_WRITE_BUSY_1;
            endcase
        end 
        SD_WRITE_BUSY_1: begin
            case(MISO)
                1'b0: n_state = SD_WRITE_BUSY_2;
                1'b1: n_state = c_state;
            endcase
        end 
        SD_WRITE_BUSY_2: begin
            case(MISO)
                1'b0: n_state = SD_WRITE_BUSY_3;
                1'b1: n_state = GO_OUTPUT;
            endcase
        end 
        SD_WRITE_BUSY_3: begin
            case(MISO)
                1'b0: n_state = SD_WRITE_BUSY_4;
                1'b1: n_state = c_state;
            endcase
        end 
        SD_WRITE_BUSY_4: begin
            case(MISO)
                1'b0: n_state = c_state;
                1'b1: n_state = OUTPUT;
            endcase
        end 
        DRAM_READ: begin
            /* to SD_WRITE_CMD */
            case(R_VALID)
                1'b0: n_state = c_state;
                1'b1: n_state = SD_WRITE_CMD;
            endcase
        end 
        DRAM_WRITE: begin
            if(W_VALID == 1 && B_READY == 1 && B_VALID == 1)
                n_state = OUTPUT;
            else
                n_state = c_state;
        end 
        GO_OUTPUT: begin
            case(MISO)
                1'b0: n_state = SD_WRITE_BUSY_3;
                1'b1: n_state = OUTPUT;
            endcase
        end
        OUTPUT: begin
            if(cnt_OUTPUT == 7)
                n_state = IDLE;
            else
                n_state = c_state;
        end
        default:
            n_state = c_state;

    endcase
end

/* ------------------------------ DRAM READ SIGNAL ------------------------------ */

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) 
        AR_VALID <= 0;
    else begin
        if(c_state == INPUT && n_state == DRAM_READ) 
            AR_VALID <= 1;
        else if(n_state == DRAM_READ) begin
            if(AR_READY == 1) 
                AR_VALID <= 0;
        end
    end
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) 
        AR_ADDR <= 0;
    else begin
        if(c_state == INPUT && n_state == DRAM_READ) 
            AR_ADDR <= address_dram;
        else if(n_state == DRAM_READ) begin
            if(AR_READY == 1) 
                AR_ADDR <= 0;
        end
    end
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) 
        R_READY <= 0;
    else begin
        if(n_state == DRAM_READ) begin
            if(AR_READY == 1) 
                R_READY <= 1;
        end
        else if(c_state == DRAM_READ) begin
            if(R_VALID)
                R_READY <= 0;
        end
    end
end

/* ------------------------------ DRAM WRITE SIGNAL ------------------------------ */

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) 
        AW_ADDR <= 0;
    else begin
        if(c_state == SD_READ_DATA && n_state == DRAM_WRITE) 
            AW_ADDR <= address_dram;
        else if(n_state == DRAM_WRITE || c_state == DRAM_WRITE) begin
            if(AW_READY == 1) 
                AW_ADDR <= 0;
        end
    end
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) 
        AW_VALID <= 0;
    else begin
        if(c_state == SD_READ_DATA && n_state == DRAM_WRITE) 
            AW_VALID <= 1;
        
        else if(n_state == DRAM_WRITE || c_state == DRAM_WRITE) begin
            if(AW_READY == 1) 
                AW_VALID <= 0;
        end
    end
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) 
        W_DATA <= 0;
    else begin
        if(n_state == DRAM_WRITE || c_state == DRAM_WRITE) begin
            if(AW_READY == 1) 
                W_DATA <= data;
        end
    end
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) 
        W_VALID <= 0;
    else begin
        if(n_state == DRAM_WRITE || c_state == DRAM_WRITE) begin
            if(AW_READY == 1) 
                W_VALID <= 1;
            if(B_VALID == 1) 
                W_VALID <= 0;
        end
    end
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) 
        B_READY <= 0;
    else begin
        if(n_state == DRAM_WRITE || c_state == DRAM_WRITE) begin
            if(AW_READY == 1) 
                B_READY <= 1;
            if(B_VALID == 1) 
                B_READY <= 0;
        end
    end
end

/* ------------------------------ SD MOSI ------------------------------ */

always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        MOSI <= 1;
    else begin
        if(n_state == SD_READ_CMD || n_state == SD_WRITE_CMD) begin
            if(cnt_CMD < 48) 
                MOSI <= CMD[47];
            else
                MOSI <= 1;
        end
        else if(n_state == SD_WRITE_RES_DATA) begin
            if(cnt_RES_DATA >= 15 && cnt_RES_DATA <= 22) begin
                MOSI <= FE[7];
            end
            else if(cnt_RES_DATA >= 23 && cnt_RES_DATA <= 86) begin
                MOSI <= data[63];
            end
            else if(cnt_RES_DATA >= 87 && cnt_RES_DATA <= 102) begin
                MOSI <= CRC_16_DFF[15];
            end
            else
                MOSI <= 1;
        end
        else
            MOSI <= 1;
    end
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) 
        FE <= 0;
    else if(n_state == SD_WRITE_RES_DATA && c_state == SD_WRITE_CMD) 
        FE <= 8'b11111110;
    else if(n_state == SD_WRITE_RES_DATA) begin
        if(cnt_RES_DATA >= 15 && cnt_RES_DATA <= 22) 
            FE <= FE << 1;
    end
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) 
        CRC_16_DFF <= 0;
    else if(n_state == SD_WRITE_RES_DATA && c_state == SD_WRITE_CMD)
        CRC_16_DFF <= CRC_16;
    else if(n_state == SD_WRITE_RES_DATA) begin
        if(cnt_RES_DATA >= 87 && cnt_RES_DATA <= 102) 
            CRC_16_DFF <= CRC_16_DFF << 1;
    end
end

always @(*) begin
    CRC_7 = CRC7({2'b01, command, address_sd});
    CRC_16 = CRC16_CCITT(data);
end


/* ------------------------------ COMMAND ------------------------------ */

always @(*) begin
    if(dir == 0)
        command <= 24;
    else
        command <= 17;
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        CMD <= 0;
    else begin
        if(n_state == SD_READ_CMD || n_state == SD_WRITE_CMD) begin
            if(cnt_CMD <= 48) 
                CMD <= CMD << 1;
        end
        else if(c_state == INPUT) 
            CMD <= {2'b01, command, address_sd, CRC_7, 1'b1};
        else if(n_state == IDLE)
            CMD <= 0;

    end
end

/* ------------------------------ COUNT ------------------------------ */

always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        data <= 0;
    else begin
        if(n_state == SD_READ_DATA) begin
            if(cnt_DATA <= 64)
                data <= {data[62:0], MISO};
        end
        else if(c_state == DRAM_READ) begin
            if(R_VALID == 1) 
                data <= R_DATA;
        end
        else if(n_state == SD_WRITE_RES_DATA) begin
            if(cnt_RES_DATA >= 23 && cnt_RES_DATA <= 86) 
                data <= {data[62:0], data[63]};
        end
    end
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        cnt_DATA <= 0;
    else begin
        if(n_state == SD_READ_DATA)
            cnt_DATA <= cnt_DATA + 1;
        else
            cnt_DATA <= 0;
    end
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        cnt_CMD <= 0;
    else begin
        if((n_state == SD_READ_CMD || n_state == SD_WRITE_CMD) && cnt_CMD < 48)
            cnt_CMD <= cnt_CMD + 1;
        else if((n_state == SD_READ_CMD || n_state == SD_WRITE_CMD) && cnt_CMD == 48)
            cnt_CMD <= cnt_CMD;
        else
            cnt_CMD <= 0;
    end
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        cnt_RES_DATA <= 0;
    else begin
        if(n_state == SD_WRITE_RES_DATA && cnt_RES_DATA < 103)
            cnt_RES_DATA <= cnt_RES_DATA + 1;
        else
            cnt_RES_DATA <= 0;
    end
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        cnt_OUTPUT <= 0;
    else begin
        if(c_state == OUTPUT)
            cnt_OUTPUT <= cnt_OUTPUT + 1;
        else
            cnt_OUTPUT <= 0;
    end
end

/* ------------------------------ INPUT ------------------------------ */

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        dir <= 0;
        address_dram <= 0;
        address_sd <= 0;
    end
    else if(in_valid) begin
        dir <= direction;
        address_dram <= addr_dram;
        address_sd <= addr_sd;
    end
end




/* ------------------------------ OUTPUT ------------------------------ */


always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        out_valid <= 0;
        out_data <= 0;
    end
    else begin
        if(c_state == OUTPUT) begin
            out_valid <= 1;
            case(cnt_OUTPUT)
                0: out_data <= data[63:56];
                1: out_data <= data[55:48];
                2: out_data <= data[47:40];
                3: out_data <= data[39:32];
                4: out_data <= data[31:24];
                5: out_data <= data[23:16];
                6: out_data <= data[15:8];
                7: out_data <= data[7:0];
            endcase
        end
        else begin
            out_valid <= 0;
            out_data <= 0;
        end
    end
end


/* ------------------------------ CRC FUNCTION ------------------------------ */

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

