// ============================================================
//  Testbench - exhaustive 65536 combinations
// ============================================================
`timescale 1ns/1ps
module tb_wallace;
    reg  [7:0]  a, b;
    wire [15:0] product;
    integer     errors;

    wallace_multiplier_8x8 uut (.a(a), .b(b), .product(product));

    initial begin
        errors = 0;
        begin : sweep
            integer ai, bi;
            for (ai = 0; ai < 256; ai = ai + 1) begin
                for (bi = 0; bi < 256; bi = bi + 1) begin
                    a = ai; b = bi; #10;
                    if (product !== ai * bi) begin
                        $display("FAIL  %0d x %0d = %0d  (expected %0d)",
                                  ai, bi, product, ai * bi);
                        errors = errors + 1;
                    end
                end
            end
        end
        if (errors == 0)
            $display("ALL %0d TESTS PASSED", 256*256);
        else
            $display("%0d ERRORS", errors);
        $finish;
    end
endmodule