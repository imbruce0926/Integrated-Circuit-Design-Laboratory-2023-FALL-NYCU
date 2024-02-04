

module BEV(input clk, INF.BEV_inf inf);
import usertype::*;


typedef enum logic [2:0]{
    IDLE_M,
    INPUT_M,
    DRAM_READ_M,
    CHECK_M,
    EMPTY_M,
    MAKE_M,
    DRAM_WRITE_M,
    OUTPUT_M
} state_make;

typedef enum logic [2:0]{
    IDLE_S,
    INPUT_S,
    DRAM_READ_S,
    EMPTY_S,
    SUPPLY_S,
    DRAM_WRITE_S,
    OUTPUT_S
} state_supply;

typedef enum logic [2:0]{
    IDLE_C,
    INPUT_C,
    DRAM_READ_C,
    CHECK_C,
    EMPTY_C,
    OUTPUT_C
} state_check;


// REGISTERS
state_make c_state_M, n_state_M;
state_supply c_state_S, n_state_S;
state_check c_state_C, n_state_C;

Bev_Type [2:0] input_Type;
Bev_Size [1:0] input_Size;
logic [3:0] input_Month;
logic [4:0] input_Day;
logic [7:0] input_Box_No;
logic [11:0] input_Black_Tea_supply, input_Green_Tea_supply, input_Milk_supply, input_Pineapple_Juice_supply;


logic [11:0] Black_Tea_ING, Green_Tea_ING, Milk_ING, Pineapple_Juice_ING;
logic [11:0] bt_ING_need, gt_ING_need, m_ING_need, pj_ING_need;
logic [11:0] bt_ING_need_reg, gt_ING_need_reg, m_ING_need_reg, pj_ING_need_reg;
logic [3:0] Expired_Month;
logic [4:0] Expired_Day;

logic Black_Tea_ENOUGH, Green_Tea_ENOUGH, Milk_ENOUGH, Pineapple_Juice_ENOUGH;
logic is_EXPIRED, is_NOT_ENOUGH;

logic [1:0] cnt_4;

logic Black_Tea_OVERFLOW, Green_Tea_OVERFLOW, Milk_OVERFLOW, Pineapple_Juice_OVERFLOW;
logic is_OVERFLOW;

logic [12:0] Black_Tea_TOTAL, Green_Tea_TOTAL, Milk_TOTAL, Pineapple_Juice_TOTAL;
// logic [12:0] Black_Tea_TOTAL_reg, Green_Tea_TOTAL_reg, Milk_TOTAL_reg, Pineapple_Juice_TOTAL_reg;


Error_Msg [1:0] err_msg_temp;

logic C_out_valid_d1, box_no_valid_d1;
// logic is_EXPIRED_reg;

always_ff @(posedge clk or negedge inf.rst_n) begin
    if (!inf.rst_n) C_out_valid_d1 <= 0;
    else C_out_valid_d1 <= inf.C_out_valid;
end

// always_ff @(posedge clk or negedge inf.rst_n) begin
//     if (!inf.rst_n) box_no_valid_d1 <= 0;
//     else box_no_valid_d1 <= inf.box_no_valid;
// end

// always_ff @(posedge clk or negedge inf.rst_n) begin
//     if (!inf.rst_n) is_EXPIRED_reg <= 0;
//     else is_EXPIRED_reg <= is_EXPIRED;
// end

////////////////////////////////////////////////////////////
//                       STATE MAKE                       //
////////////////////////////////////////////////////////////

always_ff @(posedge clk or negedge inf.rst_n) begin : MAKE_DRINK_FSM_SEQ
    if (!inf.rst_n) c_state_M <= IDLE_M;
    else c_state_M <= n_state_M;
end

always_comb begin : MAKE_DRINK_FSM_COMB
    n_state_M = c_state_M;
    case(c_state_M)
        IDLE_M: begin
            if(inf.sel_action_valid && inf.D.d_act[0] == Make_drink)
                n_state_M = INPUT_M;
        end
        INPUT_M: begin
            if(inf.box_no_valid)
                n_state_M = DRAM_READ_M;
        end
        DRAM_READ_M: begin
            if(C_out_valid_d1)
                n_state_M = CHECK_M;
        end
        CHECK_M: begin
            if(is_EXPIRED || is_NOT_ENOUGH)
                n_state_M = EMPTY_M;
            else
                n_state_M = MAKE_M;
        end
        MAKE_M: begin
            n_state_M = EMPTY_M;
        end
        EMPTY_M: begin
            if(inf.err_msg == No_Err)
                n_state_M = DRAM_WRITE_M;
            else
                n_state_M = OUTPUT_M;
        end
        DRAM_WRITE_M: begin
            if(C_out_valid_d1)
                n_state_M = OUTPUT_M;
        end
        OUTPUT_M: begin
            n_state_M = IDLE_M;
        end
    endcase
end

////////////////////////////////////////////////////////////
//                     STATE SUPPLY                       //
////////////////////////////////////////////////////////////
always_ff @(posedge clk or negedge inf.rst_n) begin
    if (!inf.rst_n) c_state_S <= IDLE_S;
    else c_state_S <= n_state_S;
end

always_comb begin
    n_state_S = c_state_S;
    case(c_state_S)
        IDLE_S: begin
            if(inf.sel_action_valid && inf.D.d_act[0] == Supply)
                n_state_S = INPUT_S;
        end
        INPUT_S: begin
            if(inf.box_sup_valid && cnt_4 == 3) // !
                n_state_S = DRAM_READ_S;
        end
        DRAM_READ_S: begin
            if(C_out_valid_d1)
                n_state_S = SUPPLY_S;
        end
        SUPPLY_S: begin
            n_state_S = EMPTY_S;
        end
        EMPTY_S: begin
            n_state_S = DRAM_WRITE_S;
        end
        DRAM_WRITE_S: begin
            if(C_out_valid_d1)
                n_state_S = OUTPUT_S;
        end
        OUTPUT_S: begin
            n_state_S = IDLE_S;
        end
    endcase
end

////////////////////////////////////////////////////////////
//                     STATE CHECK                       //
////////////////////////////////////////////////////////////
always_ff @(posedge clk or negedge inf.rst_n) begin
    if (!inf.rst_n) c_state_C <= IDLE_C;
    else c_state_C <= n_state_C;
end

always_comb begin
    n_state_C = c_state_C;
    case(c_state_C)
        IDLE_C: begin
            if(inf.sel_action_valid && inf.D.d_act[0] == Check_Valid_Date)
                n_state_C = INPUT_C;
        end
        INPUT_C: begin
            if(inf.box_no_valid)
                n_state_C = DRAM_READ_C;
        end
        DRAM_READ_C: begin
            if(C_out_valid_d1)
                n_state_C = CHECK_C;
        end
        CHECK_C: begin
            n_state_C = EMPTY_C;
        end
        EMPTY_C: begin
            n_state_C = OUTPUT_C;
        end
        OUTPUT_C: begin
            n_state_C = IDLE_C;
        end
    endcase
end


////////////////////////////////////////////////////////////
//                          INPUT                         //
////////////////////////////////////////////////////////////

always_ff @(posedge clk or negedge inf.rst_n) begin
    if(!inf.rst_n)
        input_Type <= Black_Tea;
    else begin
        if(inf.type_valid)
            input_Type <= inf.D.d_type[0];
    end
end

always_ff @(posedge clk or negedge inf.rst_n) begin
    if(!inf.rst_n)
        input_Size <= L;
    else begin
        if(inf.size_valid)
            input_Size <= inf.D.d_size[0];
    end
end

always_ff @(posedge clk or negedge inf.rst_n) begin
    if(!inf.rst_n) begin
        input_Month <= 0;
        input_Day <= 0;
    end
    else begin
        if(inf.date_valid) begin
            input_Month <= inf.D.d_date[0].M;
            input_Day <= inf.D.d_date[0].D;
        end
    end
end

always_ff @(posedge clk or negedge inf.rst_n) begin
    if(!inf.rst_n)
        input_Box_No <= 0;
    else begin
        if(inf.box_no_valid)
            input_Box_No <= inf.D.d_box_no[0];
    end
end

always_ff @(posedge clk or negedge inf.rst_n) begin
    if(!inf.rst_n)
        cnt_4 <= 0;
    else begin
        if(inf.box_sup_valid)
            cnt_4 <= cnt_4 + 1;
        else if(c_state_S == OUTPUT_S)
            cnt_4 <= 0;
    end
end

always_ff @(posedge clk or negedge inf.rst_n) begin
    if(!inf.rst_n) begin
        input_Black_Tea_supply <= 0;
        input_Green_Tea_supply <= 0;
        input_Milk_supply <= 0;
        input_Pineapple_Juice_supply <= 0;
    end
    else begin
        if(inf.box_sup_valid) begin
            case(cnt_4)
                0: input_Black_Tea_supply <= inf.D.d_ing[0];
                1: input_Green_Tea_supply <= inf.D.d_ing[0];
                2: input_Milk_supply <= inf.D.d_ing[0];
                3: input_Pineapple_Juice_supply <= inf.D.d_ing[0];
            endcase
        end
    end
end


////////////////////////////////////////////////////////////
//                        AXI CTRL                        //
////////////////////////////////////////////////////////////

always_ff @(posedge clk or negedge inf.rst_n) begin
    if(!inf.rst_n)  begin
        inf.C_in_valid <= 0;
        inf.C_r_wb <= 0;
        inf.C_addr <= 0;
        inf.C_data_w <= 0;
    end
    else begin
        if((c_state_M == INPUT_M && n_state_M == DRAM_READ_M) ||
           (c_state_C == INPUT_C && n_state_C == DRAM_READ_C)) begin
            inf.C_in_valid <= 1;
            inf.C_r_wb <= 1;
            inf.C_addr <= inf.D.d_box_no[0];
            // inf.C_addr <= input_Box_No;
        end
        else if(c_state_S == INPUT_S && n_state_S == DRAM_READ_S) begin
            inf.C_in_valid <= 1;
            inf.C_r_wb <= 1;
            inf.C_addr <= input_Box_No;
        end
        else if((c_state_M == EMPTY_M && n_state_M == DRAM_WRITE_M) ||
                (c_state_S == EMPTY_S && n_state_S == DRAM_WRITE_S)) begin
            inf.C_in_valid <= 1;
            inf.C_r_wb <= 0;
            inf.C_addr <= input_Box_No;
            inf.C_data_w <= {Black_Tea_ING, Green_Tea_ING, 4'd0, Expired_Month, Milk_ING, Pineapple_Juice_ING, 3'd0, Expired_Day};
        end
        else begin
            inf.C_in_valid <= 0;
            inf.C_r_wb <= 0;
            inf.C_addr <= 0;
            inf.C_data_w <= 0;
        end

    end
end

////////////////////////////////////////////////////////////
//                       BOX FROM DRAM                    //
////////////////////////////////////////////////////////////

always_ff @(posedge clk or negedge inf.rst_n) begin
    if(!inf.rst_n) begin
        Black_Tea_ING <= 0;
        Green_Tea_ING <= 0; 
        Milk_ING <= 0;
        Pineapple_Juice_ING <= 0;
        Expired_Month <= 0;
        Expired_Day <= 0;
    end
    else begin
        if((c_state_M == DRAM_READ_M) ||
           (c_state_S == DRAM_READ_S) ||
           (c_state_C == DRAM_READ_C)) begin
            if(inf.C_out_valid) begin
                Black_Tea_ING <= inf.C_data_r[63:52];
                Green_Tea_ING <= inf.C_data_r[51:40]; 
                Expired_Month <= inf.C_data_r[35:32];
                Milk_ING <= inf.C_data_r[31:20];
                Pineapple_Juice_ING <= inf.C_data_r[19:8];
                Expired_Day <= inf.C_data_r[4:0];
            end
        end
        else if(c_state_M == MAKE_M) begin
            Black_Tea_ING       <= Black_Tea_ING        - bt_ING_need_reg;
            Green_Tea_ING       <= Green_Tea_ING        - gt_ING_need_reg;
            Milk_ING            <= Milk_ING             - m_ING_need_reg;
            Pineapple_Juice_ING <= Pineapple_Juice_ING  - pj_ING_need_reg;
        end
        else if(c_state_S == SUPPLY_S) begin
            Black_Tea_ING <= Black_Tea_OVERFLOW ? 4095 : Black_Tea_TOTAL[11:0];
            Green_Tea_ING <= Green_Tea_OVERFLOW ? 4095 : Green_Tea_TOTAL[11:0];
            Milk_ING <= Milk_OVERFLOW ? 4095 : Milk_TOTAL[11:0];
            Pineapple_Juice_ING <= Pineapple_Juice_OVERFLOW ? 4095 : Pineapple_Juice_TOTAL[11:0];
            Expired_Month <= input_Month;
            Expired_Day <= input_Day;
        end
    end
end

////////////////////////////////////////////////////////////
//                  CHECK EXPIRED / ENOUGH                //
////////////////////////////////////////////////////////////


logic BT_flag, MT_flag, EMT_flag, GT_flag, GMT_flag, PJ_flag, SPT_flag, SPMT_flag;
logic L_flag, M_flag, S_flag;

always_ff @(posedge clk or negedge inf.rst_n)begin
    if(!inf.rst_n) begin
        BT_flag <= 0;
        MT_flag <= 0;
        EMT_flag <= 0;
        GT_flag <= 0;
        GMT_flag <= 0;
        PJ_flag <= 0;
        SPT_flag <= 0;
        SPMT_flag <= 0;
    end
    else begin
        BT_flag <= input_Type == Black_Tea;
        MT_flag <= input_Type == Milk_Tea;
        EMT_flag <= input_Type == Extra_Milk_Tea;
        GT_flag <= input_Type == Green_Tea;
        GMT_flag <= input_Type == Green_Milk_Tea;
        PJ_flag <= input_Type == Pineapple_Juice;
        SPT_flag <= input_Type == Super_Pineapple_Tea;
        SPMT_flag <= input_Type == Super_Pineapple_Milk_Tea;
    end
end

always_ff @(posedge clk or negedge inf.rst_n)begin
    if(!inf.rst_n) begin
        L_flag <= 0;
        M_flag <= 0;
        S_flag <= 0;
    end
    else begin
        L_flag <= input_Size == L;
        M_flag <= input_Size == M;
        S_flag <= input_Size == S;
    end
end
always_comb begin

    bt_ING_need = 0;
    gt_ING_need = 0;
    m_ING_need = 0;
    pj_ING_need = 0;

// ! 1 stages

    // if(BT_flag) begin
    //     if(input_Size == L)
    //         bt_ING_need = 960;
    //     else if(input_Size == M)
    //         bt_ING_need = 720;
    //     else 
    //         bt_ING_need = 480;
    // end  
    // else if(MT_flag) begin
    //     if(input_Size == L)
    //         bt_ING_need = 720;
    //     else if(input_Size == M)
    //         bt_ING_need = 540;
    //     else 
    //         bt_ING_need = 360;
    // end
    // else if(EMT_flag) begin
    //     if(input_Size == L)
    //         bt_ING_need = 480;
    //     else if(input_Size == M)
    //         bt_ING_need = 360;
    //     else 
    //         bt_ING_need = 240;
    // end
    // else if(SPT_flag) begin
    //     if(input_Size == L)
    //         bt_ING_need = 480;
    //     else if(input_Size == M)
    //         bt_ING_need = 360;
    //     else 
    //         bt_ING_need = 240;
    // end  
    // else if(SPMT_flag) begin
    //     if(input_Size == L)
    //         bt_ING_need = 480;
    //     else if(input_Size == M)
    //         bt_ING_need = 360;
    //     else 
    //         bt_ING_need = 240;
    // end

    // if(GT_flag) begin
    //     if(input_Size == L)
    //         gt_ING_need = 960;
    //     else if(input_Size == M)
    //         gt_ING_need = 720;
    //     else 
    //         gt_ING_need = 480;
    // end  
    // else if(GMT_flag) begin
    //     if(input_Size == L)
    //         gt_ING_need = 480;
    //     else if(input_Size == M)
    //         gt_ING_need = 360;
    //     else 
    //         gt_ING_need = 240;
    // end

    // if(MT_flag) begin
    //     if(input_Size == L)
    //         m_ING_need = 240;
    //     else if(input_Size == M)
    //         m_ING_need = 180;
    //     else 
    //         m_ING_need = 120;
    // end  
    // else if(EMT_flag) begin
    //     if(input_Size == L)
    //         m_ING_need = 480;
    //     else if(input_Size == M)
    //         m_ING_need = 360;
    //     else 
    //         m_ING_need = 240;
    // end
    // else if(GMT_flag) begin
    //     if(input_Size == L)
    //         m_ING_need = 480;
    //     else if(input_Size == M)
    //         m_ING_need = 360;
    //     else 
    //         m_ING_need = 240;
    // end
    // else if(SPMT_flag) begin
    //     if(input_Size == L)
    //         m_ING_need = 240;
    //     else if(input_Size == M)
    //         m_ING_need = 180;
    //     else 
    //         m_ING_need = 120;
    // end

    // if(PJ_flag) begin
    //     if(input_Size == L)
    //         pj_ING_need = 960;
    //     else if(input_Size == M)
    //         pj_ING_need = 720;
    //     else 
    //         pj_ING_need = 480;
    // end  
    // else if(SPT_flag) begin
    //     if(input_Size == L)
    //         pj_ING_need = 480;
    //     else if(input_Size == M)
    //         pj_ING_need = 360;
    //     else 
    //         pj_ING_need = 240;
    // end
    // else if(SPMT_flag) begin
    //     if(input_Size == L)
    //         pj_ING_need = 240;
    //     else if(input_Size == M)
    //         pj_ING_need = 180;
    //     else 
    //         pj_ING_need = 120;
    // end


// ! 2 stages

    if(BT_flag) begin
        if(L_flag)
            bt_ING_need = 960;
        else if(M_flag)
            bt_ING_need = 720;
        else 
            bt_ING_need = 480;
    end  
    else if(MT_flag) begin
        if(L_flag)
            bt_ING_need = 720;
        else if(M_flag)
            bt_ING_need = 540;
        else 
            bt_ING_need = 360;
    end
    else if(EMT_flag) begin
        if(L_flag)
            bt_ING_need = 480;
        else if(M_flag)
            bt_ING_need = 360;
        else 
            bt_ING_need = 240;
    end
    else if(SPT_flag) begin
        if(L_flag)
            bt_ING_need = 480;
        else if(M_flag)
            bt_ING_need = 360;
        else 
            bt_ING_need = 240;
    end
    else if(SPMT_flag) begin
        if(L_flag)
            bt_ING_need = 480;
        else if(M_flag)
            bt_ING_need = 360;
        else 
            bt_ING_need = 240;
    end

    if(GT_flag) begin
        if(L_flag)
            gt_ING_need = 960;
        else if(M_flag)
            gt_ING_need = 720;
        else 
            gt_ING_need = 480;
    end  
    else if(GMT_flag) begin
        if(L_flag)
            gt_ING_need = 480;
        else if(M_flag)
            gt_ING_need = 360;
        else 
            gt_ING_need = 240;
    end

    if(MT_flag) begin
        if(L_flag)
            m_ING_need = 240;
        else if(M_flag)
            m_ING_need = 180;
        else 
            m_ING_need = 120;
    end  
    else if(EMT_flag) begin
        if(L_flag)
            m_ING_need = 480;
        else if(M_flag)
            m_ING_need = 360;
        else 
            m_ING_need = 240;
    end
    else if(GMT_flag) begin
        if(L_flag)
            m_ING_need = 480;
        else if(M_flag)
            m_ING_need = 360;
        else 
            m_ING_need = 240;
    end
    else if(SPMT_flag) begin
        if(L_flag)
            m_ING_need = 240;
        else if(M_flag)
            m_ING_need = 180;
        else 
            m_ING_need = 120;
    end

    if(PJ_flag) begin
        if(L_flag)
            pj_ING_need = 960;
        else if(M_flag)
            pj_ING_need = 720;
        else 
            pj_ING_need = 480;
    end  
    else if(SPT_flag) begin
        if(L_flag)
            pj_ING_need = 480;
        else if(M_flag)
            pj_ING_need = 360;
        else 
            pj_ING_need = 240;
    end
    else if(SPMT_flag) begin
        if(L_flag)
            pj_ING_need = 240;
        else if(M_flag)
            pj_ING_need = 180;
        else 
            pj_ING_need = 120;
    end

// ! 0 stages

    // case(input_Type)
    //     Black_Tea: begin
    //         case(input_Size)
    //             L: bt_ING_need = 960;
    //             M: bt_ING_need = 720;
    //             S: bt_ING_need = 480;
    //         endcase
    //     end
    //     Milk_Tea: begin
    //         case(input_Size)
    //             L: begin
    //                 bt_ING_need = 720;
    //                 m_ING_need = 240;
    //             end
    //             M: begin
    //                 bt_ING_need = 540;
    //                 m_ING_need = 180;
    //             end
    //             S: begin
    //                 bt_ING_need = 360;
    //                 m_ING_need = 120;
    //             end
    //         endcase
    //     end
    //     Extra_Milk_Tea: begin
    //         case(input_Size)
    //             L: begin
    //                 bt_ING_need = 480;
    //                 m_ING_need = 480;
    //             end
    //             M: begin
    //                 bt_ING_need = 360;
    //                 m_ING_need = 360;
    //             end
    //             S: begin
    //                 bt_ING_need = 240;
    //                 m_ING_need = 240;
    //             end
    //         endcase
    //     end
    //     Green_Tea: begin
    //         case(input_Size)
    //             L: gt_ING_need = 960;
    //             M: gt_ING_need = 720;
    //             S: gt_ING_need = 480;
    //         endcase
    //     end
    //     Green_Milk_Tea: begin
    //         case(input_Size)
    //             L: begin
    //                 gt_ING_need = 480;
    //                 m_ING_need = 480;
    //             end
    //             M: begin
    //                 gt_ING_need = 360;
    //                 m_ING_need = 360;
    //             end
    //             S: begin
    //                 gt_ING_need = 240;
    //                 m_ING_need = 240;
    //             end
    //         endcase
    //     end
    //     Pineapple_Juice: begin
    //         case(input_Size)
    //             L: pj_ING_need = 960;
    //             M: pj_ING_need = 720;
    //             S: pj_ING_need = 480;
    //         endcase
    //     end
    //     Super_Pineapple_Tea: begin
    //         case(input_Size)
    //             L: begin
    //                 bt_ING_need = 480;
    //                 pj_ING_need = 480;
    //             end
    //             M: begin
    //                 bt_ING_need = 360;
    //                 pj_ING_need = 360;
    //             end
    //             S: begin
    //                 bt_ING_need = 240;
    //                 pj_ING_need = 240;
    //             end
    //         endcase
    //     end
    //     Super_Pineapple_Milk_Tea: begin
    //         case(input_Size)
    //             L: begin
    //                 bt_ING_need = 480;
    //                 m_ING_need = 240;
    //                 pj_ING_need = 240;
    //             end
    //             M: begin
    //                 bt_ING_need = 360;
    //                 m_ING_need = 180;
    //                 pj_ING_need = 180;
    //             end
    //             S: begin
    //                 bt_ING_need = 240;
    //                 m_ING_need = 120;
    //                 pj_ING_need = 120;
    //             end
    //         endcase
    //     end
    // endcase
end

always_ff @(posedge clk or negedge inf.rst_n) begin
    if(!inf.rst_n) begin
        bt_ING_need_reg <= 0; 
        gt_ING_need_reg <= 0; 
        m_ING_need_reg <= 0; 
        pj_ING_need_reg <= 0; 
    end 
    else begin
        bt_ING_need_reg <= bt_ING_need; 
        gt_ING_need_reg <= gt_ING_need; 
        m_ING_need_reg  <= m_ING_need; 
        pj_ING_need_reg <= pj_ING_need; 
    end
end

assign Black_Tea_ENOUGH         = Black_Tea_ING >= bt_ING_need_reg;
assign Green_Tea_ENOUGH         = Green_Tea_ING >= gt_ING_need_reg;
assign Milk_ENOUGH              = Milk_ING >= m_ING_need_reg;
assign Pineapple_Juice_ENOUGH   = Pineapple_Juice_ING >= pj_ING_need_reg;

// logic Black_Tea_ENOUGH_reg, Green_Tea_ENOUGH_reg, Milk_ENOUGH_reg, Pineapple_Juice_ENOUGH_reg;

// always_ff @(posedge clk or negedge inf.rst_n) begin
//     if(!inf.rst_n) begin
//         Black_Tea_ENOUGH_reg <= 0; 
//         Green_Tea_ENOUGH_reg <= 0; 
//         Milk_ENOUGH_reg <= 0; 
//         Pineapple_Juice_ENOUGH_reg <= 0; 
//     end 
//     else begin
//         Black_Tea_ENOUGH_reg <= Black_Tea_ENOUGH; 
//         Green_Tea_ENOUGH_reg <= Green_Tea_ENOUGH; 
//         Milk_ENOUGH_reg <= Milk_ENOUGH; 
//         Pineapple_Juice_ENOUGH_reg <= Pineapple_Juice_ENOUGH; 
//     end
// end

assign is_NOT_ENOUGH = !(Black_Tea_ENOUGH & Green_Tea_ENOUGH & Milk_ENOUGH & Pineapple_Juice_ENOUGH);
assign is_EXPIRED = (input_Month > Expired_Month) || (input_Month == Expired_Month && input_Day > Expired_Day);


////////////////////////////////////////////////////////////
//                      CHECK OVERFLOW                    //
////////////////////////////////////////////////////////////


assign Black_Tea_TOTAL          = Black_Tea_ING + input_Black_Tea_supply;
assign Green_Tea_TOTAL          = Green_Tea_ING + input_Green_Tea_supply;
assign Milk_TOTAL               = Milk_ING + input_Milk_supply;
assign Pineapple_Juice_TOTAL    = Pineapple_Juice_ING + input_Pineapple_Juice_supply;

// always_ff @(posedge clk or negedge inf.rst_n) begin
//     if(!inf.rst_n) begin
//         Black_Tea_TOTAL_reg <= 0;
//         Green_Tea_TOTAL_reg <= 0;
//         Milk_TOTAL_reg <= 0;
//         Pineapple_Juice_TOTAL_reg <= 0;
//     end
//     else begin
//         Black_Tea_TOTAL_reg <= Black_Tea_TOTAL;
//         Green_Tea_TOTAL_reg <= Green_Tea_TOTAL;
//         Milk_TOTAL_reg <= Milk_TOTAL;
//         Pineapple_Juice_TOTAL_reg <= Pineapple_Juice_TOTAL;
//     end
// end

// logic Black_Tea_OVERFLOW_reg, Green_Tea_OVERFLOW_reg, Milk_OVERFLOW_reg, Pineapple_Juice_OVERFLOW_reg;

// always_ff @(posedge clk or negedge inf.rst_n) begin
//     if(!inf.rst_n) begin
//         Black_Tea_OVERFLOW_reg <= 0;
//         Green_Tea_OVERFLOW_reg <= 0;
//         Milk_OVERFLOW_reg <= 0;
//         Pineapple_Juice_OVERFLOW_reg <= 0;
//     end
//     else begin
//         Black_Tea_OVERFLOW_reg <= Black_Tea_OVERFLOW;
//         Green_Tea_OVERFLOW_reg <= Green_Tea_OVERFLOW;
//         Milk_OVERFLOW_reg <= Milk_OVERFLOW;
//         Pineapple_Juice_OVERFLOW_reg <= Pineapple_Juice_OVERFLOW;
//     end
// end

assign Black_Tea_OVERFLOW       = Black_Tea_TOTAL[12];
assign Green_Tea_OVERFLOW       = Green_Tea_TOTAL[12];
assign Milk_OVERFLOW            = Milk_TOTAL[12];
assign Pineapple_Juice_OVERFLOW = Pineapple_Juice_TOTAL[12];

logic is_OVERFLOW_reg;

always_ff @(posedge clk or negedge inf.rst_n) begin
    if(!inf.rst_n)
        is_OVERFLOW_reg <= 0;
    else begin
        is_OVERFLOW_reg <= is_OVERFLOW;
    end
end

assign is_OVERFLOW = Black_Tea_OVERFLOW | Green_Tea_OVERFLOW | Milk_OVERFLOW | Pineapple_Juice_OVERFLOW;

////////////////////////////////////////////////////////////
//                         OUTPUT                         //
////////////////////////////////////////////////////////////

always_ff @(posedge clk or negedge inf.rst_n) begin
    if(!inf.rst_n)
        inf.err_msg <= No_Err;
    else begin
        // if(c_state_M == CHECK_M) begin
        //     if(is_EXPIRED)
        //         inf.err_msg <= No_Exp;
        //     else if(is_NOT_ENOUGH)
        //         inf.err_msg <= No_Ing;
        // end
        // else if(c_state_S == SUPPLY_S) begin
        //     if(is_OVERFLOW)
        //         inf.err_msg <= Ing_OF;
        // end
        // else if(c_state_C == CHECK_C) begin
        //     if(is_EXPIRED)
        //         inf.err_msg <= No_Exp;
        // end
        // else if((c_state_M == OUTPUT_M) ||
        //         (c_state_S == OUTPUT_S) ||
        //         (c_state_C == OUTPUT_C))
        //         inf.err_msg <= No_Err;
        if((n_state_M == OUTPUT_M) || 
           (n_state_S == OUTPUT_S) ||
           (n_state_C == OUTPUT_C))
           inf.err_msg <= err_msg_temp;
        else if((c_state_M == OUTPUT_M) ||
                (c_state_S == OUTPUT_S) ||
                (c_state_C == OUTPUT_C))
                inf.err_msg <= No_Err;
    end
end

always_ff @(posedge clk or negedge inf.rst_n) begin
    if(!inf.rst_n)
        err_msg_temp <= No_Err;
    else begin
        if(c_state_M == CHECK_M) begin
            if(is_EXPIRED)
                err_msg_temp <= No_Exp;
            else if(is_NOT_ENOUGH)
                err_msg_temp <= No_Ing;
        end
        else if(c_state_S == SUPPLY_S) begin
            if(is_OVERFLOW_reg)
                err_msg_temp <= Ing_OF;
        end
        else if(c_state_C == CHECK_C) begin
            if(is_EXPIRED)
                err_msg_temp <= No_Exp;
        end
        else if((c_state_M == OUTPUT_M) ||
                (c_state_S == OUTPUT_S) ||
                (c_state_C == OUTPUT_C))
                err_msg_temp <= No_Err;
    end
end

always_ff @(posedge clk or negedge inf.rst_n) begin
    if(!inf.rst_n)
        inf.complete <= 0;
    else begin
        if((n_state_M == OUTPUT_M) ||
           (n_state_S == OUTPUT_S) ||
           (n_state_C == OUTPUT_C)) begin
            // if(inf.err_msg == No_Err)
            if(err_msg_temp == No_Err)
                inf.complete <= 1;
        end
        else if((c_state_M == OUTPUT_M) ||
                (c_state_S == OUTPUT_S) ||
                (c_state_C == OUTPUT_C))
            inf.complete <= 0;
    end
end

always_ff @(posedge clk or negedge inf.rst_n) begin
    if(!inf.rst_n)
        inf.out_valid <= 0;
    else begin
        if((n_state_M == OUTPUT_M) ||
           (n_state_S == OUTPUT_S) ||
           (n_state_C == OUTPUT_C) ) begin
            inf.out_valid <= 1;
        end
        else if((c_state_M == OUTPUT_M) ||
                (c_state_S == OUTPUT_S) ||
                (c_state_C == OUTPUT_C))
            inf.out_valid <= 0;
    end
end

endmodule