/////////////////////////////
//
// Test example 2
//
// @brief Useless module for add/sub operation. Divide logic to 2 part.
//
// @autor krt2019@yandex.ru
//
/////////////////////////////

module add #(
    parameter int DATA_WIDTH = 32,

    // derived_parameters

    parameter type data_t  = logic[DATA_WIDTH-1:0]
) (
    input   logic   clk,
    input   logic   reset_n,

    input   logic   op_type,    // Type of iperation: 1 -> add, 0 -> sub

    input   data_t  arg1,
    input   data_t  arg2,

    output  data_t  res,
    output  logic   ov
);

    data_t add_res, sub_res;
    logic add_ov;

    // Assign - one-line combinate block
    assign {add_ov, add_res} = arg1 + arg2;
    assign sub_res = arg1 - arg2;

    // Flip-flop (trigger) block, sync with posedge clk (from 0 -> 1 version)
    // Good practice -> divide logic to 2 part: combinatorial (assign or always_comb) and
    // sequential (triggers) logic
    always_ff @(posedge clk) begin
        if(~reset_n) begin
            {ov, res} <= '0;
        end
        else if (op_type) begin
            {ov, res} <= {add_ov, add_res};
        end
        else begin
            {{ov, res}} <= {1'b0, sub_res};
        end
    end

endmodule