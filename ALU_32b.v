

`timescale 1ns / 100ps

module ALU_32b(
	output_enable,
	bus_A,
	bus_B,
	bus_output,
	opcode,
	overflow,
	zero,
	negative
);
input 	[31:0]	bus_A;
input 	[31:0]	bus_B;
output	[31:0]	bus_output;
input	[3:0]	operation_code;
output	overflow;
output	zero;
output	negative;

wire	[31:0]	w_zero;
wire			first_cry_in;


ALU_1b ALU_1_inst (zero_in, w_zero[0], n_OP1_in, OP2_in, first_cry_in, OP_out, n_zero_out, n_carry_out, inversion_OP1, select_OP2_to_A, select_OP2_to_A_inv, select_OP2_to_B, select_OP2_to_B_inv, en_carry, OP1_latch_n, OP1_latch_p, OP2_latch_n, OP2_latch_p);

generate
	for (i = 0; i<=29; i=i+1) begin
		ALU_1b ALU_1b_inst (w_zero[i], w_zero[i+1], n_OP1_in, OP2_in, carry_in, OP_out, n_zero_out, n_carry_out, inversion_OP1, select_OP2_to_A, select_OP2_to_A_inv, select_OP2_to_B, select_OP2_to_B_inv, en_carry, OP1_latch_n, OP1_latch_p, OP2_latch_n, OP2_latch_p););
	end
end generate

ALU_1b ALU_32_inst (w_zero[30], zero_out, n_OP1_in, OP2_in, carry_in, OP_out, n_zero_out, n_carry_out, inversion_OP1, select_OP2_to_A, select_OP2_to_A_inv, select_OP2_to_B, select_OP2_to_B_inv, en_carry, OP1_latch_n, OP1_latch_p, OP2_latch_n, OP2_latch_p);




always @(*) 
	begin
		if (bus_output = 32'b0) begin
			zero <= 1'b1;
		end
		else 
			zero <= 1'b0;
		end
		
		if (bus_output[31] = 1'b0) begin
			zero <= 1'b1;
		end
		else 
			zero <= 1'b0;
		end
	end

endmodule
