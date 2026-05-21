module csa_16bit (
    input  wire [15:0] a, b, c,
    output wire [15:0] sum,
    output wire [15:0] carry   // carry[i] has weight 2^(i+1)
);
    assign sum   = a ^ b ^ c;
    assign carry = (a & b) | (b & c) | (a & c);
endmodule