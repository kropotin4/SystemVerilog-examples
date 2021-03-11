/////////////////////////////
//
// Test example 2
//
// @brief Testbanch for add mudule
//
// @autor krt2019@yandex.ru
//
/////////////////////////////


module tb;

    parameter int DATA_WIDTH = 32;

    parameter int CLK_FREQ = 100;


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

    // Function must return data + can't execute time operation
    function automatic data_t ref_add(input data_t arg1, data_t arg2, logic op_type);
        return op_type ? arg1 + arg2 : arg1 - arg2;
    endfunction

    // No return like function -> output argument instead of return
    // + can execute time operation
    task automatic check_case(input data_t arg1_, data_t arg2_, logic op_type_);
        data_t ref_res = ref_add(arg1_, arg2_, op_type_);

        arg1 = arg1_;
        arg2 = arg2_;
        op_type = op_type_;

        ##1;

        // Assert check module and ref results
        assert(res == ref_res)
            $display("Success: %s(%0d, %0d)",
                    op_type_ ? "sum" : "sub",
                    arg1_, arg2_);
        else
            $error("%s(%0d, %0d): expected %0d, get %0d",
                    op_type_ ? "sum" : "sub",
                    arg1_, arg2_, ref_res, res);
    endtask

    initial begin
        @(posedge reset_n);

        // Num formats:
        // 12'd123 -> 12 bit, decimal, 123
        // 'd200 -> undefine bit number, decimal, 200
        // 8'hFF -> 8 bit, hex, FF (255)
        // 4'b0110 -> 4 bit, bin, 0110
        // '1 -> all ones; '0 -> all zeroes

        check_case('d120, 'd12, '1);

        ##1;

        check_case('d120, 'd12, '0);


        ##10;
        $finish;
    end


endmodule