// ── Wallace Tree Multiplier (top) ──────────────────────────────
module wallace_multiplier_8x8 (
    input  wire [7:0]  a, b,
    output wire [15:0] product
);

    // ── Step 1: generate all 64 partial products ───────────────
    
    wire [15:0] pp [0:7];

    genvar i;
    generate
        for (i = 0; i < 8; i = i + 1) begin : gen_pp
            assign pp[i] = {{(8-i){1'b0}},
                            (a & {8{b[i]}}),
                            {i{1'b0}}};
        end
    endgenerate

    // ── Step 2: Wallace tree - reduce 8 rows to 2 

    // Level 1a: pp[0], pp[1], pp[2] → s1a, c1a
    wire [15:0] s1a, c1a_raw;
    csa_16bit csa1a (.a(pp[0]), .b(pp[1]), .c(pp[2]),
                     .sum(s1a), .carry(c1a_raw));
    wire [15:0] c1a = c1a_raw << 1;

    // pp[3], pp[4], pp[5] → s1b, c1b
    wire [15:0] s1b, c1b_raw;
    csa_16bit csa1b (.a(pp[3]), .b(pp[4]), .c(pp[5]),
                     .sum(s1b), .carry(c1b_raw));
    wire [15:0] c1b = c1b_raw << 1;

    // pp[6], pp[7] pass to next level
    // s1a, c1a, s1b, c1b, pp[6], pp[7]

    // s1a, c1a, s1b → s2a, c2a
    wire [15:0] s2a, c2a_raw;
    csa_16bit csa2a (.a(s1a), .b(c1a), .c(s1b),
                     .sum(s2a), .carry(c2a_raw));
    wire [15:0] c2a = c2a_raw << 1;

    // c1b, pp[6], pp[7] → s2b, c2b
    wire [15:0] s2b, c2b_raw;
    csa_16bit csa2b (.a(c1b), .b(pp[6]), .c(pp[7]),
                     .sum(s2b), .carry(c2b_raw));
    wire [15:0] c2b = c2b_raw << 1;

    // s2a, c2a, s2b, c2b
    // s2a, c2a, s2b → s3, c3
    wire [15:0] s3, c3_raw;
    csa_16bit csa3  (.a(s2a), .b(c2a), .c(s2b),
                     .sum(s3), .carry(c3_raw));
    wire [15:0] c3 = c3_raw << 1;

    //s3, c3, c2b
    //s3, c3, c2b → s4, c4
    wire [15:0] s4, c4_raw;
    csa_16bit csa4  (.a(s3), .b(c3), .c(c2b),
                     .sum(s4), .carry(c4_raw));
    wire [15:0] c4 = c4_raw << 1;

    // final CLA addition of the 2 remaining rows 
    wire cout_unused;
    cla_16bit final_add (
        .a    (s4),
        .b    (c4),
        .cin  (1'b0),
        .sum  (product),
        .cout (cout_unused)
    );

endmodule
