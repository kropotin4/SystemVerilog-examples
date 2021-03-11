/////////////////////////////
//
// Test example 3
//
// @brief Testbanch for alu-lite mudule
//
// @autor krt2019@yandex.ru
//
/////////////////////////////


module tb;

    parameter int DATA_WIDTH = 32;
    parameter bit N_CYCLE = '0;     // Number of alu work cycle

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
    // Define "alu-lite" module

    // Declare signals
    logic[31:0] chunk;
    data_t arg1, arg2;
    data_t res;

    // Insert mudule + link ports and signals
    alu_lite #(
        .DATA_WIDTH (DATA_WIDTH),
        .N_CYCLE    (N_CYCLE)
    ) alu_u (
        .clk        (clk),
        .reset_n    (reset_n),

        .chunk      (chunk),

        .arg1       (arg1),
        .arg2       (arg2),

        .res        (res)
    );

    //////////

    // Enumerate for release insn
    typedef enum {
        ADD,
        SUB,
        SHIFT_LEFT,
        SHIFT_RIGHT,
        MUL_LOW,
        MUL_HIGH,
        DIV
    } insn_t;

    function automatic logic[31:0] get_chunk(input insn_t insn);
        case (insn)
            ADD:            return 32'b0000001_xxxxxxxxxx_000_xxxxxxxxxxxx;
            SUB:            return 32'b0000001_xxxxxxxxxx_010_xxxxxxxxxxxx;
            SHIFT_LEFT:     return 32'b0000010_xxxxxxxxxx_000_xxxxxxxxxxxx;
            SHIFT_RIGHT:    return 32'b0000010_xxxxxxxxxx_010_xxxxxxxxxxxx;
            MUL_LOW:        return 32'b0001000_xxxxxxxxxx_000_xxxxxxxxxxxx;
            MUL_HIGH:       return 32'b0001000_xxxxxxxxxx_001_xxxxxxxxxxxx;
            DIV:            return 32'b0001000_xxxxxxxxxx_010_xxxxxxxxxxxx;
            default : return 'x;
        endcase
    endfunction

    // Function must return data + can't execute time operation
    function automatic data_t ref_alu(input insn_t insn, data_t arg1, data_t arg2);
        logic[2*DATA_WIDTH-1:0] mul = arg1 * arg2;

        case (insn)
            ADD:            return arg1 + arg2;
            SUB:            return arg1 - arg2;
            SHIFT_LEFT:     return arg1 << arg2;
            SHIFT_RIGHT:    return arg1 >> arg2;
            MUL_LOW:        return mul[DATA_WIDTH-1:0];
            MUL_HIGH:       return mul[2*DATA_WIDTH-1:DATA_WIDTH];
            DIV:            return arg1 / arg2;
            default : return 'x;
        endcase
    endfunction

    // No return like function -> output argument instead of return
    // + can execute time operation
    task automatic check_case(input insn_t insn, data_t arg1_, data_t arg2_);
        data_t ref_res = ref_alu(insn, arg1_, arg2_);

        arg1 = arg1_;
        arg2 = arg2_;
        chunk = get_chunk(insn);

        ##1;

        // Assert check module and ref results
        assert(res == ref_res)
            $display("Success: %s(%0d, %0d)",
                    insn.name(),
                    arg1_, arg2_);
        else
            $error("%s(%0d, %0d): expected %0d, get %0d",
                    insn.name(),
                    arg1_, arg2_, ref_res, res);
    endtask

    insn_t cur_insn;
    data_t arg_rand1, arg_rand2;
    initial begin
        @(posedge reset_n);

        // Num formats:
        // 12'd123 -> 12 bit, decimal, 123
        // 'd200 -> undefine bit number, decimal, 200
        // 8'hFF -> 8 bit, hex, FF (255)
        // 4'b0110 -> 4 bit, bin, 0110
        // '1 -> all ones; '0 -> all zeroes

        check_case(ADD, 'd120, 'd12);

        ##1;

        check_case(SUB, 'd120, 'd12);


        // Attempt for some automatic test set (random test -> bad tests)

        cur_insn = cur_insn.first(); // First insn in enumerate
        for (int insn_n = 0; insn_n < cur_insn.num(); ++insn_n) begin
            for (int cases = 0; cases < 10; ++ cases) begin
                arg_rand1 = {$urandom(), $urandom()}; // $urandom() return 32-bit value ->
                arg_rand2 = {$urandom(), $urandom()}; // -> 2 $urandom() return 64-bit value
                // Why 2? Just in case

                check_case(cur_insn, arg_rand1, arg_rand2);
            end

            cur_insn = cur_insn.next(); // Next insn in enumerate
        end

        ##10;
        $finish;
    end


endmodule