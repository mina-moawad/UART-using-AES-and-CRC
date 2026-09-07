module subBytes(in,out);
input [127:0] in;
output [127:0] out;

genvar i;
generate 
for(i=0;i<16;i=i+1) begin :sub_Bytes 
	sbox s(in [127 - (i*8) -: 8],
            out[127 - (i*8) -: 8]);
	end
endgenerate


endmodule