`timescale 10 ns/ 1 ps

module traffic_light_tb;

    // Parameter definitions
    parameter ENDTIME = 400000;

    // DUT Input regs
    reg clk;
    reg rst_n;
    reg C;

    // DUT Output wires
    wire [2:0] light_highway;
    wire [2:0] light_farm;

    // DUT Instantiation
    traffic_light uut (
        .light_highway(light_highway),
        .light_farm(light_farm),
        .C(C),
        .clk(clk),
        .rst_n(rst_n)
    );

    // Initial Conditions
    initial begin
        clk = 1'b0;
        rst_n = 1'b0;
        C = 1'b0;
    end

    // Main Test Sequence
    initial begin
        main;
    end

    task main;
        fork
            clock_gen;
            reset_gen;
            operation_flow;
            debug_output;
            endsimulation;
        join
    endtask

    // Clock Generation Task
    task clock_gen;
        begin
            forever #1 clk = ~clk; // 10 ns clock period
        end
    endtask

    // Reset Generation Task
    task reset_gen;
        begin
            rst_n = 0;
            #20 rst_n = 1;
        end
    endtask

    // Operation Flow Task
    task operation_flow;
        begin
            C = 0;
            #60 C = 1;
            #120 C = 0;
            #120 C = 1;
        end
    endtask

    // Debug Output Task
    task debug_output;
        begin
            $display("----------------------------------------------");
            $display("------------------     -----------------------");
            $display("----------- SIMULATION RESULT ----------------");
            $display("--------------             -------------------");
            $display("----------------         ---------------------");
            $display("----------------------------------------------");
            $monitor("TIME = %0t | reset = %b | C = %b | light_highway = %b | light_farm = %b", $time, rst_n, C, light_highway, light_farm);
        end
    endtask

    // End Simulation Task
    task endsimulation;
        begin
            #ENDTIME;
            $display("-------------- THE SIMULATION END ------------");
            $finish;
        end
    endtask

endmodule
