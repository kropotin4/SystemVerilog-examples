/////////////////////////////
//
// Test example 1
//
// @brief Testbanch for add mudule
//
// @autor krt2019@yandex.ru
//
/////////////////////////////


module tb;

    parameter DATA_WIDTH = 32;

    parameter CLK_FREQ = 100;


    typedef logic[DATA_WIDTH-1:0] data_t;

    //////////
    // Define clk signal with CLK_FREQ frequency

    bit clk = '0;
    initial begin
        #(1000.0/(2*CLK_FREQ));
        forever #(1000.0/(2*CLK_FREQ)) clk =~ clk;
    end

    //////////
    // Define reset signal

    bit reset_n = '0;
    default clocking cb @(posedge clk);
        output reset_n;
    endclocking
    initial begin
        /* For Vivado post-synthesis simulation reset should be held active */
        /* for at least 100ns to perform FPGA Global Set/Reset. */
        /* See http://www.xilinx.com/support/answers/6537.html */
        #200ns;
        cb.reset_n <= '1;
    end
    initial $timeformat(-9, 1, " ns", 13); /* 8.1f ns time format */

    //////////
    // Define "add" module

    // Declare signals
    logic op_type;
    data_t arg1, arg2;
    data_t res;
    logic overflow;

    // Insert mudule + link ports and signals
    add #(
        .DATA_WIDTH (DATA_WIDTH)
    ) add_u (
        .clk        (clk),
        .reset_n    (reset_n),

        .op_type    (op_type),

        .arg1       (arg1),
        .arg2       (arg2),

        .res        (res),
        .ov         (overflow)
    );

    //////////

    initial begin
        @(posedge reset_n);

        // Num formats:
        // 12'd123 -> 12 bit, decimal, 123
        // 'd200 -> undefine bit number, decimal, 200
        // 8'hFF -> 8 bit, hex, FF (255)
        // 4'b0110 -> 4 bit, bin, 0110
        // '1 -> all ones; '0 -> all zeroes

        op_type = '1;
        arg1 = 'd120;
        arg2 = 'd12;

        ##2; // Wait 2 cycles

        $display("%d + %d = %d", arg1, arg2, res);
        ##1;

        op_type = '0;
        arg1 = 'd120;
        arg2 = 'd12;

        @(posedge clk); // Wait 2 cycles (another form)
        @(posedge clk);

        $display("%d - %d = %d", arg1, arg2, res);
        ##1;


        ##10;
        $finish;
    end


endmodule