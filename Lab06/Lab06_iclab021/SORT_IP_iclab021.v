//############################################################################
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//    (C) Copyright System Integration and Silicon Implementation Laboratory
//    All Right Reserved
//		Date		: 2023/10
//		Version		: v1.0
//   	File Name   : SORT_IP.v
//   	Module Name : SORT_IP
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//############################################################################
module SORT_IP #(parameter IP_WIDTH = 8) (
    // Input signals
    IN_character, IN_weight,
    // Output signals
    OUT_character
);

// ===============================================================
// Input & Output
// ===============================================================
input [IP_WIDTH*4-1:0]  IN_character;
input [IP_WIDTH*5-1:0]  IN_weight;

output [IP_WIDTH*4-1:0] OUT_character;

// ===============================================================
// Design
// ===============================================================




generate
    case(IP_WIDTH)
        3: begin
            wire [3:0] index [0:2]; /* index 4 bits */
            wire [4:0] weight [0:2]; /* weight 5 bits */
            assign index[2] = IN_character[11:8];
            assign index[1] = IN_character[7:4];
            assign index[0] = IN_character[3:0];
            assign weight[2] = IN_weight[14:10];
            assign weight[1] = IN_weight[9:5];
            assign weight[0] = IN_weight[4:0];

            wire [3:0] i [0:5]; 
            wire [4:0] w [0:5];
            
            compartor C0 (.weight_a(weight[0]), .weight_b(weight[2]), .index_a(index[0]), .index_b(index[2]), .weight_A(w[0]), .weight_B(w[1]), .index_A(i[0]), .index_B(i[1]));
            
            compartor C1 (.weight_a(w[0]), .weight_b(weight[1]), .index_a(i[0]), .index_b(index[1]), .weight_A(w[2]), .weight_B(w[3]), .index_A(i[2]), .index_B(i[3]));
            
            compartor C2 (.weight_a(w[3]), .weight_b(w[1]), .index_a(i[3]), .index_b(i[1]), .weight_A(w[4]), .weight_B(w[5]), .index_A(i[4]), .index_B(i[5]));

            assign OUT_character = {i[2], i[4], i[5]};
        end
        4: begin
            wire [3:0] index [0:3]; /* index 4 bits */
            wire [4:0] weight [0:3]; /* weight 5 bits */
            assign index[3] = IN_character[15:12];
            assign index[2] = IN_character[11:8];
            assign index[1] = IN_character[7:4];
            assign index[0] = IN_character[3:0];
            assign weight[3] = IN_weight[19:15];
            assign weight[2] = IN_weight[14:10];
            assign weight[1] = IN_weight[9:5];
            assign weight[0] = IN_weight[4:0];
            
            wire [3:0] i [0:9]; 
            wire [4:0] w [0:9];

            compartor C0 (.weight_a(weight[0]), .weight_b(weight[2]), .index_a(index[0]), .index_b(index[2]), .weight_A(w[0]), .weight_B(w[1]), .index_A(i[0]), .index_B(i[1]));
            compartor C1 (.weight_a(weight[1]), .weight_b(weight[3]), .index_a(index[1]), .index_b(index[3]), .weight_A(w[2]), .weight_B(w[3]), .index_A(i[2]), .index_B(i[3]));
            
            compartor C2 (.weight_a(w[0]), .weight_b(w[2]), .index_a(i[0]), .index_b(i[2]), .weight_A(w[4]), .weight_B(w[5]), .index_A(i[4]), .index_B(i[5]));
            compartor C3 (.weight_a(w[1]), .weight_b(w[3]), .index_a(i[1]), .index_b(i[3]), .weight_A(w[6]), .weight_B(w[7]), .index_A(i[6]), .index_B(i[7]));
            
            compartor C4 (.weight_a(w[5]), .weight_b(w[6]), .index_a(i[5]), .index_b(i[6]), .weight_A(w[8]), .weight_B(w[9]), .index_A(i[8]), .index_B(i[9]));

            assign OUT_character = {i[4], i[8], i[9], i[7]};
        end
        5: begin
            wire [3:0] index [0:4]; /* index 4 bits */
            wire [4:0] weight [0:4]; /* weight 5 bits */
            assign index[4] = IN_character[19:16];
            assign index[3] = IN_character[15:12];
            assign index[2] = IN_character[11:8];
            assign index[1] = IN_character[7:4];
            assign index[0] = IN_character[3:0];
            assign weight[4] = IN_weight[24:20];
            assign weight[3] = IN_weight[19:15];
            assign weight[2] = IN_weight[14:10];
            assign weight[1] = IN_weight[9:5];
            assign weight[0] = IN_weight[4:0];

            wire [3:0] i [0:17]; 
            wire [4:0] w [0:17];

            compartor C0 (.weight_a(weight[0]), .weight_b(weight[3]), .index_a(index[0]), .index_b(index[3]), .weight_A(w[0]), .weight_B(w[1]), .index_A(i[0]), .index_B(i[1]));
            compartor C1 (.weight_a(weight[1]), .weight_b(weight[4]), .index_a(index[1]), .index_b(index[4]), .weight_A(w[2]), .weight_B(w[3]), .index_A(i[2]), .index_B(i[3]));
            
            compartor C2 (.weight_a(w[0]), .weight_b(weight[2]), .index_a(i[0]), .index_b(index[2]), .weight_A(w[4]), .weight_B(w[5]), .index_A(i[4]), .index_B(i[5]));
            compartor C3 (.weight_a(w[2]), .weight_b(w[1]), .index_a(i[2]), .index_b(i[1]), .weight_A(w[6]), .weight_B(w[7]), .index_A(i[6]), .index_B(i[7]));
            
            compartor C4 (.weight_a(w[4]), .weight_b(w[6]), .index_a(i[4]), .index_b(i[6]), .weight_A(w[8]), .weight_B(w[9]), .index_A(i[8]), .index_B(i[9]));
            compartor C5 (.weight_a(w[5]), .weight_b(w[3]), .index_a(i[5]), .index_b(i[3]), .weight_A(w[10]), .weight_B(w[11]), .index_A(i[10]), .index_B(i[11]));
            
            compartor C6 (.weight_a(w[9]), .weight_b(w[10]), .index_a(i[9]), .index_b(i[10]), .weight_A(w[12]), .weight_B(w[13]), .index_A(i[12]), .index_B(i[13]));
            compartor C7 (.weight_a(w[7]), .weight_b(w[11]), .index_a(i[7]), .index_b(i[11]), .weight_A(w[14]), .weight_B(w[15]), .index_A(i[14]), .index_B(i[15]));
            
            compartor C8 (.weight_a(w[13]), .weight_b(w[14]), .index_a(i[13]), .index_b(i[14]), .weight_A(w[16]), .weight_B(w[17]), .index_A(i[16]), .index_B(i[17]));
        
            assign OUT_character = {i[8], i[12], i[16], i[17], i[15]};
        end
        6: begin
            wire [3:0] index [0:5]; /* index 4 bits */
            wire [4:0] weight [0:5]; /* weight 5 bits */
            assign index[5] = IN_character[23:20];
            assign index[4] = IN_character[19:16];
            assign index[3] = IN_character[15:12];
            assign index[2] = IN_character[11:8];
            assign index[1] = IN_character[7:4];
            assign index[0] = IN_character[3:0];
            assign weight[5] = IN_weight[29:25];
            assign weight[4] = IN_weight[24:20];
            assign weight[3] = IN_weight[19:15];
            assign weight[2] = IN_weight[14:10];
            assign weight[1] = IN_weight[9:5];
            assign weight[0] = IN_weight[4:0];

            wire [3:0] i [0:23]; 
            wire [4:0] w [0:23];


            compartor C0 (.weight_a(weight[1]), .weight_b(weight[3]), .index_a(index[1]), .index_b(index[3]), .weight_A(w[0]), .weight_B(w[1]), .index_A(i[0]), .index_B(i[1]));
            compartor C1 (.weight_a(weight[0]), .weight_b(weight[5]), .index_a(index[0]), .index_b(index[5]), .weight_A(w[2]), .weight_B(w[3]), .index_A(i[2]), .index_B(i[3]));
            compartor C2 (.weight_a(weight[2]), .weight_b(weight[4]), .index_a(index[2]), .index_b(index[4]), .weight_A(w[4]), .weight_B(w[5]), .index_A(i[4]), .index_B(i[5]));
            
            compartor C3 (.weight_a(w[0]), .weight_b(w[4]), .index_a(i[0]), .index_b(i[4]), .weight_A(w[6]), .weight_B(w[7]), .index_A(i[6]), .index_B(i[7]));
            compartor C4 (.weight_a(w[1]), .weight_b(w[5]), .index_a(i[1]), .index_b(i[5]), .weight_A(w[8]), .weight_B(w[9]), .index_A(i[8]), .index_B(i[9]));
            
            compartor C5 (.weight_a(w[2]), .weight_b(w[8]), .index_a(i[2]), .index_b(i[8]), .weight_A(w[10]), .weight_B(w[11]), .index_A(i[10]), .index_B(i[11]));
            compartor C6 (.weight_a(w[7]), .weight_b(w[3]), .index_a(i[7]), .index_b(i[3]), .weight_A(w[12]), .weight_B(w[13]), .index_A(i[12]), .index_B(i[13]));
            
            compartor C7 (.weight_a(w[10]), .weight_b(w[6]), .index_a(i[10]), .index_b(i[6]), .weight_A(w[14]), .weight_B(w[15]), .index_A(i[14]), .index_B(i[15]));
            compartor C8 (.weight_a(w[12]), .weight_b(w[11]), .index_a(i[12]), .index_b(i[11]), .weight_A(w[16]), .weight_B(w[17]), .index_A(i[16]), .index_B(i[17]));
            compartor C9 (.weight_a(w[9]), .weight_b(w[13]), .index_a(i[9]), .index_b(i[13]), .weight_A(w[18]), .weight_B(w[19]), .index_A(i[18]), .index_B(i[19]));
            
            compartor C10 (.weight_a(w[15]), .weight_b(w[16]), .index_a(i[15]), .index_b(i[16]), .weight_A(w[20]), .weight_B(w[21]), .index_A(i[20]), .index_B(i[21]));
            compartor C11 (.weight_a(w[17]), .weight_b(w[18]), .index_a(i[17]), .index_b(i[18]), .weight_A(w[22]), .weight_B(w[23]), .index_A(i[22]), .index_B(i[23]));

            assign OUT_character = {i[14], i[20], i[21], i[22], i[23], i[19]};
        end
        7: begin
            wire [3:0] index [0:6]; /* index 4 bits */
            wire [4:0] weight [0:6]; /* weight 5 bits */
            assign index[6] = IN_character[27:24];
            assign index[5] = IN_character[23:20];
            assign index[4] = IN_character[19:16];
            assign index[3] = IN_character[15:12];
            assign index[2] = IN_character[11:8];
            assign index[1] = IN_character[7:4];
            assign index[0] = IN_character[3:0];
            assign weight[6] = IN_weight[34:30];
            assign weight[5] = IN_weight[29:25];
            assign weight[4] = IN_weight[24:20];
            assign weight[3] = IN_weight[19:15];
            assign weight[2] = IN_weight[14:10];
            assign weight[1] = IN_weight[9:5];
            assign weight[0] = IN_weight[4:0];

            wire [3:0] i [0:32]; 
            wire [4:0] w [0:32];

            compartor C0 (.weight_a(weight[0]), .weight_b(weight[6]), .index_a(index[0]), .index_b(index[6]), .weight_A(w[0]), .weight_B(w[1]), .index_A(i[0]), .index_B(i[1]));
            compartor C1 (.weight_a(weight[2]), .weight_b(weight[3]), .index_a(index[2]), .index_b(index[3]), .weight_A(w[2]), .weight_B(w[3]), .index_A(i[2]), .index_B(i[3]));
            compartor C2 (.weight_a(weight[4]), .weight_b(weight[5]), .index_a(index[4]), .index_b(index[5]), .weight_A(w[4]), .weight_B(w[5]), .index_A(i[4]), .index_B(i[5]));
            
            compartor C3 (.weight_a(weight[1]), .weight_b(w[4]), .index_a(index[1]), .index_b(i[4]), .weight_A(w[6]), .weight_B(w[7]), .index_A(i[6]), .index_B(i[7]));
            compartor C4 (.weight_a(w[0]), .weight_b(w[2]), .index_a(i[0]), .index_b(i[2]), .weight_A(w[8]), .weight_B(w[9]), .index_A(i[8]), .index_B(i[9]));
            compartor C5 (.weight_a(w[3]), .weight_b(w[1]), .index_a(i[3]), .index_b(i[1]), .weight_A(w[10]), .weight_B(w[11]), .index_A(i[10]), .index_B(i[11]));

            compartor C6 (.weight_a(w[8]), .weight_b(w[6]), .index_a(i[8]), .index_b(i[6]), .weight_A(w[12]), .weight_B(w[13]), .index_A(i[12]), .index_B(i[13]));
            compartor C7 (.weight_a(w[10]), .weight_b(w[7]), .index_a(i[10]), .index_b(i[7]), .weight_A(w[14]), .weight_B(w[15]), .index_A(i[14]), .index_B(i[15]));
            compartor C8 (.weight_a(w[9]), .weight_b(w[5]), .index_a(i[9]), .index_b(i[5]), .weight_A(w[16]), .weight_B(w[17]), .index_A(i[16]), .index_B(i[17]));

            compartor C9 (.weight_a(w[13]), .weight_b(w[16]), .index_a(i[13]), .index_b(i[16]), .weight_A(w[18]), .weight_B(w[19]), .index_A(i[18]), .index_B(i[19]));
            compartor C10 (.weight_a(w[15]), .weight_b(w[11]), .index_a(i[15]), .index_b(i[11]), .weight_A(w[20]), .weight_B(w[21]), .index_A(i[20]), .index_B(i[21]));

            compartor C11 (.weight_a(w[19]), .weight_b(w[14]), .index_a(i[19]), .index_b(i[14]), .weight_A(w[22]), .weight_B(w[23]), .index_A(i[22]), .index_B(i[23]));
            compartor C12 (.weight_a(w[20]), .weight_b(w[17]), .index_a(i[20]), .index_b(i[17]), .weight_A(w[24]), .weight_B(w[25]), .index_A(i[24]), .index_B(i[25]));

            compartor C13 (.weight_a(w[18]), .weight_b(w[22]), .index_a(i[18]), .index_b(i[22]), .weight_A(w[26]), .weight_B(w[27]), .index_A(i[26]), .index_B(i[27]));
            compartor C14 (.weight_a(w[23]), .weight_b(w[24]), .index_a(i[23]), .index_b(i[24]), .weight_A(w[28]), .weight_B(w[29]), .index_A(i[28]), .index_B(i[29]));
            compartor C15 (.weight_a(w[25]), .weight_b(w[21]), .index_a(i[25]), .index_b(i[21]), .weight_A(w[30]), .weight_B(w[31]), .index_A(i[30]), .index_B(i[31]));

            assign OUT_character = {i[12], i[26], i[27], i[28], i[29], i[30], i[31]};
        end
        8: begin
            wire [3:0] index [0:7]; /* index 4 bits */
            wire [4:0] weight [0:7]; /* weight 5 bits */
            assign index[7] = IN_character[31:28];
            assign index[6] = IN_character[27:24];
            assign index[5] = IN_character[23:20];
            assign index[4] = IN_character[19:16];
            assign index[3] = IN_character[15:12];
            assign index[2] = IN_character[11:8];
            assign index[1] = IN_character[7:4];
            assign index[0] = IN_character[3:0];
            assign weight[7] = IN_weight[39:35];
            assign weight[6] = IN_weight[34:30];
            assign weight[5] = IN_weight[29:25];
            assign weight[4] = IN_weight[24:20];
            assign weight[3] = IN_weight[19:15];
            assign weight[2] = IN_weight[14:10];
            assign weight[1] = IN_weight[9:5];
            assign weight[0] = IN_weight[4:0];

            wire [3:0] i [0:37]; 
            wire [4:0] w [0:37];


            compartor C0 (.weight_a(weight[1]), .weight_b(weight[3]), .index_a(index[1]), .index_b(index[3]), .weight_A(w[0]), .weight_B(w[1]), .index_A(i[0]), .index_B(i[1]));
            compartor C1 (.weight_a(weight[4]), .weight_b(weight[6]), .index_a(index[4]), .index_b(index[6]), .weight_A(w[2]), .weight_B(w[3]), .index_A(i[2]), .index_B(i[3]));
            compartor C2 (.weight_a(weight[0]), .weight_b(weight[2]), .index_a(index[0]), .index_b(index[2]), .weight_A(w[4]), .weight_B(w[5]), .index_A(i[4]), .index_B(i[5]));
            compartor C3 (.weight_a(weight[5]), .weight_b(weight[7]), .index_a(index[5]), .index_b(index[7]), .weight_A(w[6]), .weight_B(w[7]), .index_A(i[6]), .index_B(i[7]));

            compartor C4 (.weight_a(w[4]), .weight_b(w[2]), .index_a(i[4]), .index_b(i[2]), .weight_A(w[8]), .weight_B(w[9]), .index_A(i[8]), .index_B(i[9]));
            compartor C5 (.weight_a(w[0]), .weight_b(w[6]), .index_a(i[0]), .index_b(i[6]), .weight_A(w[10]), .weight_B(w[11]), .index_A(i[10]), .index_B(i[11]));
            compartor C6 (.weight_a(w[5]), .weight_b(w[3]), .index_a(i[5]), .index_b(i[3]), .weight_A(w[12]), .weight_B(w[13]), .index_A(i[12]), .index_B(i[13]));
            compartor C7 (.weight_a(w[1]), .weight_b(w[7]), .index_a(i[1]), .index_b(i[7]), .weight_A(w[14]), .weight_B(w[15]), .index_A(i[14]), .index_B(i[15]));

            compartor C8 (.weight_a(w[8]), .weight_b(w[10]), .index_a(i[8]), .index_b(i[10]), .weight_A(w[16]), .weight_B(w[17]), .index_A(i[16]), .index_B(i[17]));
            compartor C9 (.weight_a(w[12]), .weight_b(w[14]), .index_a(i[12]), .index_b(i[14]), .weight_A(w[18]), .weight_B(w[19]), .index_A(i[18]), .index_B(i[19]));
            compartor C10 (.weight_a(w[9]), .weight_b(w[11]), .index_a(i[9]), .index_b(i[11]), .weight_A(w[20]), .weight_B(w[21]), .index_A(i[20]), .index_B(i[21]));
            compartor C11 (.weight_a(w[13]), .weight_b(w[15]), .index_a(i[13]), .index_b(i[15]), .weight_A(w[22]), .weight_B(w[23]), .index_A(i[22]), .index_B(i[23]));

            compartor C12 (.weight_a(w[18]), .weight_b(w[20]), .index_a(i[18]), .index_b(i[20]), .weight_A(w[24]), .weight_B(w[25]), .index_A(i[24]), .index_B(i[25]));
            compartor C13 (.weight_a(w[19]), .weight_b(w[21]), .index_a(i[19]), .index_b(i[21]), .weight_A(w[26]), .weight_B(w[27]), .index_A(i[26]), .index_B(i[27]));

            compartor C14 (.weight_a(w[17]), .weight_b(w[25]), .index_a(i[17]), .index_b(i[25]), .weight_A(w[28]), .weight_B(w[29]), .index_A(i[28]), .index_B(i[29]));
            compartor C15 (.weight_a(w[26]), .weight_b(w[22]), .index_a(i[26]), .index_b(i[22]), .weight_A(w[30]), .weight_B(w[31]), .index_A(i[30]), .index_B(i[31]));

            compartor C16 (.weight_a(w[28]), .weight_b(w[24]), .index_a(i[28]), .index_b(i[24]), .weight_A(w[32]), .weight_B(w[33]), .index_A(i[32]), .index_B(i[33]));
            compartor C17 (.weight_a(w[30]), .weight_b(w[29]), .index_a(i[30]), .index_b(i[29]), .weight_A(w[34]), .weight_B(w[35]), .index_A(i[34]), .index_B(i[35]));
            compartor C18 (.weight_a(w[27]), .weight_b(w[31]), .index_a(i[27]), .index_b(i[31]), .weight_A(w[36]), .weight_B(w[37]), .index_A(i[36]), .index_B(i[37]));
            
            assign OUT_character = {i[16], i[32], i[33], i[34], i[35], i[36], i[37], i[23]};
        end
        default: begin
            wire [3:0] index [0:7]; /* index 4 bits */
            wire [4:0] weight [0:7]; /* weight 5 bits */
            assign index[7] = IN_character[31:28];
            assign index[6] = IN_character[27:24];
            assign index[5] = IN_character[23:20];
            assign index[4] = IN_character[19:16];
            assign index[3] = IN_character[15:12];
            assign index[2] = IN_character[11:8];
            assign index[1] = IN_character[7:4];
            assign index[0] = IN_character[3:0];
            assign weight[7] = IN_weight[39:35];
            assign weight[6] = IN_weight[34:30];
            assign weight[5] = IN_weight[29:25];
            assign weight[4] = IN_weight[24:20];
            assign weight[3] = IN_weight[19:15];
            assign weight[2] = IN_weight[14:10];
            assign weight[1] = IN_weight[9:5];
            assign weight[0] = IN_weight[4:0];

            wire [3:0] i [0:37]; 
            wire [4:0] w [0:37];


            compartor C0 (.weight_a(weight[1]), .weight_b(weight[3]), .index_a(index[1]), .index_b(index[3]), .weight_A(w[0]), .weight_B(w[1]), .index_A(i[0]), .index_B(i[1]));
            compartor C1 (.weight_a(weight[4]), .weight_b(weight[6]), .index_a(index[4]), .index_b(index[6]), .weight_A(w[2]), .weight_B(w[3]), .index_A(i[2]), .index_B(i[3]));
            compartor C2 (.weight_a(weight[0]), .weight_b(weight[2]), .index_a(index[0]), .index_b(index[2]), .weight_A(w[4]), .weight_B(w[5]), .index_A(i[4]), .index_B(i[5]));
            compartor C3 (.weight_a(weight[5]), .weight_b(weight[7]), .index_a(index[5]), .index_b(index[7]), .weight_A(w[6]), .weight_B(w[7]), .index_A(i[6]), .index_B(i[7]));

            compartor C4 (.weight_a(w[4]), .weight_b(w[2]), .index_a(i[4]), .index_b(i[2]), .weight_A(w[8]), .weight_B(w[9]), .index_A(i[8]), .index_B(i[9]));
            compartor C5 (.weight_a(w[0]), .weight_b(w[6]), .index_a(i[0]), .index_b(i[6]), .weight_A(w[10]), .weight_B(w[11]), .index_A(i[10]), .index_B(i[11]));
            compartor C6 (.weight_a(w[5]), .weight_b(w[3]), .index_a(i[5]), .index_b(i[3]), .weight_A(w[12]), .weight_B(w[13]), .index_A(i[12]), .index_B(i[13]));
            compartor C7 (.weight_a(w[1]), .weight_b(w[7]), .index_a(i[1]), .index_b(i[7]), .weight_A(w[14]), .weight_B(w[15]), .index_A(i[14]), .index_B(i[15]));

            compartor C8 (.weight_a(w[8]), .weight_b(w[10]), .index_a(i[8]), .index_b(i[10]), .weight_A(w[16]), .weight_B(w[17]), .index_A(i[16]), .index_B(i[17]));
            compartor C9 (.weight_a(w[12]), .weight_b(w[14]), .index_a(i[12]), .index_b(i[14]), .weight_A(w[18]), .weight_B(w[19]), .index_A(i[18]), .index_B(i[19]));
            compartor C10 (.weight_a(w[9]), .weight_b(w[11]), .index_a(i[9]), .index_b(i[11]), .weight_A(w[20]), .weight_B(w[21]), .index_A(i[20]), .index_B(i[21]));
            compartor C11 (.weight_a(w[13]), .weight_b(w[15]), .index_a(i[13]), .index_b(i[15]), .weight_A(w[22]), .weight_B(w[23]), .index_A(i[22]), .index_B(i[23]));

            compartor C12 (.weight_a(w[18]), .weight_b(w[20]), .index_a(i[18]), .index_b(i[20]), .weight_A(w[24]), .weight_B(w[25]), .index_A(i[24]), .index_B(i[25]));
            compartor C13 (.weight_a(w[19]), .weight_b(w[21]), .index_a(i[19]), .index_b(i[21]), .weight_A(w[26]), .weight_B(w[27]), .index_A(i[26]), .index_B(i[27]));

            compartor C14 (.weight_a(w[17]), .weight_b(w[25]), .index_a(i[17]), .index_b(i[25]), .weight_A(w[28]), .weight_B(w[29]), .index_A(i[28]), .index_B(i[29]));
            compartor C15 (.weight_a(w[26]), .weight_b(w[22]), .index_a(i[26]), .index_b(i[22]), .weight_A(w[30]), .weight_B(w[31]), .index_A(i[30]), .index_B(i[31]));

            compartor C16 (.weight_a(w[28]), .weight_b(w[24]), .index_a(i[28]), .index_b(i[24]), .weight_A(w[32]), .weight_B(w[33]), .index_A(i[32]), .index_B(i[33]));
            compartor C17 (.weight_a(w[30]), .weight_b(w[29]), .index_a(i[30]), .index_b(i[29]), .weight_A(w[34]), .weight_B(w[35]), .index_A(i[34]), .index_B(i[35]));
            compartor C18 (.weight_a(w[27]), .weight_b(w[31]), .index_a(i[27]), .index_b(i[31]), .weight_A(w[36]), .weight_B(w[37]), .index_A(i[36]), .index_B(i[37]));
            
            assign OUT_character = {i[16], i[32], i[33], i[34], i[35], i[36], i[37], i[23]};
        end

    endcase
endgenerate

endmodule

module compartor(weight_a, weight_b, index_a, index_b, weight_A, weight_B, index_A, index_B);
input [4:0] weight_a, weight_b;
input [3:0] index_a, index_b;
output reg [4:0] weight_A, weight_B;
output reg [3:0] index_A, index_B;

always @(*) begin
    if(weight_a > weight_b || (weight_a == weight_b && index_a > index_b)) begin
        weight_A = weight_a;
        weight_B = weight_b;
        index_A = index_a;
        index_B = index_b;
    end
    else begin
        weight_A = weight_b;
        weight_B = weight_a;
        index_A = index_b;
        index_B = index_a;
    end
end

endmodule