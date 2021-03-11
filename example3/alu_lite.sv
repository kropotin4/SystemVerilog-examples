/////////////////////////////
//
// Test example 3
//
// @brief ALU (arithmetic logic unit), lite version.
//
// @autor krt2019@yandex.ru
//
/////////////////////////////


module alu_lite #(
    parameter int DATA_WIDTH = 32,

    parameter bit N_CYCLE   = '1,     // 0 -> combinatorial work, 1 -> 1 cycle work

    // derived_parameters

    parameter type data_t  = logic[DATA_WIDTH-1:0]
) (
    input   logic       clk,
    input   logic       reset_n,

    input   logic[31:0] chunk,      // Insn opcode

    input   data_t  arg1,
    input   data_t  arg2,

    output  data_t  res
);

    typedef struct packed {
        logic add;
        logic sub;
        logic shift_l;
        logic shift_r;
        logic mul_l;
        logic mul_h;
        logic div;
    } insn_t;


    ////////////////
    // Decoding instructions

    insn_t dec; // One of possible decoder releases
    always_comb begin
        // In RISC-V architecture all instruction (often) coding with 32-bit word - chunk.
        // All bits in chunk may be divided in 2 part:
        // 1. Decoding bits -> this bits take part in decoding insn (this always_comb block about it)
        // 2. Argument bits -> reference for registers (assembler example "add rd, rs1, rs2" -> rd, rs1, rs2)

        dec = '0;
        case ({chunk[31:25], chunk[14:12]})
            10'b0000001_000: dec.add = '1;
            10'b0000001_010: dec.sub = '1;
            10'b0000010_000: dec.shift_l = '1;
            10'b0000010_010: dec.shift_r = '1;
            10'b0001000_000: dec.mul_l = '1;
            10'b0001000_001: dec.mul_h = '1;
            10'b0001000_010: dec.div = '1;
            default : /* default */;
        endcase
    end


    ////////////////
    // Execute insn

    // Add/Sub

    data_t addsub_res;

    // If add -> arg1 + (arg2 XOR 0) + 0 = arg1 + arg2
    // if sub -> arg1 + (arg2 XOR 1) + 1 = arg1 + (INVERT arg2) + 1 = arg1 - arg2
    // Economy!
    assign addsub_res = arg1 + (arg2 ^ {DATA_WIDTH{dec.sub}}) + dec.sub;

    // Shift

    data_t shift_res;
    always_comb begin
        if (dec.shift_l)
            shift_res = arg1 << arg2;
        else
            shift_res = arg1 >> arg2;
    end

    // Multiple

    logic[2*DATA_WIDTH-1:0] mul_res;
    assign mul_res = arg1 * arg2;

    // Division

    data_t div_res;
    assign div_res = arg1 / arg2;


    ////////////////
    // Result

    data_t result;
    always_comb begin
        if (dec.add || dec.sub)
            result = addsub_res;
        else if (dec.shift_l || dec.shift_r)
            result = shift_res;
        else if (dec.mul_l)
            result = mul_res[DATA_WIDTH-1:0];
        else if (dec.mul_h)
            result = mul_res[2*DATA_WIDTH-1:DATA_WIDTH];
        else
            result = div_res;
    end


    // If processor frequency high and alu "speed" low, we can split alu work into 2 cycle
    // -> so, in other words, in the end of alu we say stop and continue to work in the next cycle
    if (N_CYCLE == '1) begin
        always_ff @(posedge clk)
            res <= result;
    end
    else begin
        assign res = result;
    end

endmodule