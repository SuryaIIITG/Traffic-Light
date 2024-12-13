`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 13.12.2024 12:56:58
// Design Name: 
// Module Name: traffic_light
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module traffic_light (
    output reg [2:0] light_highway, light_farm,
    input wire C, clk, rst_n
);

// State Parameters
parameter HGRE_FRED  = 2'b00; // Highway green, farm red
parameter HYEL_FRED  = 2'b01; // Highway yellow, farm red
parameter HRED_FGRE  = 2'b10; // Highway red, farm green
parameter HRED_FYEL  = 2'b11; // Highway red, farm yellow

// Registers
reg [1:0] state, next_state;
reg [27:0] count = 0, count_delay = 0;
reg delay10s = 0, delay3s1 = 0, delay3s2 = 0;
reg RED_count_en = 0, YELLOW_count_en1 = 0, YELLOW_count_en2 = 0;
wire clk_enable;

// State Register
always @(posedge clk or negedge rst_n) begin
    if (~rst_n)
        state <= HGRE_FRED;
    else
        state <= next_state;
end

// Next State Logic
always @(*) begin
    case (state)
        HGRE_FRED: begin
            RED_count_en = 0;
            YELLOW_count_en1 = 0;
            YELLOW_count_en2 = 0;
            light_highway = 3'b001; // Green
            light_farm = 3'b100;   // Red
            next_state = (C) ? HYEL_FRED : HGRE_FRED;
        end

        HYEL_FRED: begin
            light_highway = 3'b010; // Yellow
            light_farm = 3'b100;   // Red
            RED_count_en = 0;
            YELLOW_count_en1 = 1;
            YELLOW_count_en2 = 0;
            next_state = (delay3s1) ? HRED_FGRE : HYEL_FRED;
        end

        HRED_FGRE: begin
            light_highway = 3'b100; // Red
            light_farm = 3'b001;   // Green
            RED_count_en = 1;
            YELLOW_count_en1 = 0;
            YELLOW_count_en2 = 0;
            next_state = (delay10s) ? HRED_FYEL : HRED_FGRE;
        end

        HRED_FYEL: begin
            light_highway = 3'b100; // Red
            light_farm = 3'b010;   // Yellow
            RED_count_en = 0;
            YELLOW_count_en1 = 0;
            YELLOW_count_en2 = 1;
            next_state = (delay3s2) ? HGRE_FRED : HRED_FYEL;
        end

        default: next_state = HGRE_FRED;
    endcase
end

// Delay Counters
always @(posedge clk) begin
    if (clk_enable) begin
        if (RED_count_en || YELLOW_count_en1 || YELLOW_count_en2)
            count_delay <= count_delay + 1;

        if (RED_count_en && count_delay == 10) begin
            delay10s <= 1;
            delay3s1 <= 0;
            delay3s2 <= 0;
            count_delay <= 0;
        end else if (YELLOW_count_en1 && count_delay == 3) begin
            delay10s <= 0;
            delay3s1 <= 1;
            delay3s2 <= 0;
            count_delay <= 0;
        end else if (YELLOW_count_en2 && count_delay == 3) begin
            delay10s <= 0;
            delay3s1 <= 0;
            delay3s2 <= 1;
            count_delay <= 0;
        end else begin
            delay10s <= 0;
            delay3s1 <= 0;
            delay3s2 <= 0;
        end
    end
end

// 1s Clock Enable Generation
always @(posedge clk) begin
    count <= count + 1;
    if (count == 50_000_000 - 1) // 50 MHz clock for FPGA
        count <= 0;
end

assign clk_enable = (count == 50_000_000 - 1);

endmodule
