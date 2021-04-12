

`timescale 1ns / 100ps

module ALU_1b(
	zero_in,
	zero_out,
	n_OP1_in,
	OP2_in,
	carry_in,
	OP_out,
	n_zero_out,
	n_carry_out,
	inversion_OP1,
	select_OP2_to_A,
	select_OP2_to_A_inv,
	select_OP2_to_B,
	select_OP2_to_B_inv,
	en_carry,
	OP1_latch_n,
	OP1_latch_p,
	OP2_latch_n,
	OP2_latch_p
);
	
input	zero_in;
output	zero_out;
input	n_OP1_in;
input	OP2_in;
input	carry_in;
output	OP_out;
output	n_zero_out;
output	n_carry_out;
input	inversion_OP1;
input	select_OP2_to_A;
input	select_OP2_to_A_inv;
input	select_OP2_to_B;
input	select_OP2_to_B_inv;
input	en_carry;
input	OP1_latch_n;
input	OP1_latch_p;
input	OP2_latch_n;
input	OP2_latch_p;

wire	w_OP_out, w_OP1_in;
wire	w_A_wire, w_B_wire, w_C_wire, w_D_wire;
wire	w_OP1_bf_FET, w_OP1_af_FET, w_OP2_bf_FET, w_OP2_af_FET;


assign n_zero_out	= ~(zero_in | OP_out);
assign OP_out		= w_OP_out;
assign w_OP_out		= w_C_wire ^ w_D_wire;
assign w_C_wire		= ~w_A_wire ^ w_B_wire;
assign w_D_wire		= ~(en_carry & carry_in);
assign n_carry_out	= ~(~(w_B_wire | carry_in) & w_A_wire);
assign w_A_wire		= ~((select_OP2_to_A_inv & w_OP1_af_FET & ~w_OP2_af_FET)|(select_OP2_to_A & w_OP1_af_FET & w_OP2_af_FET));
assign w_B_wire		= ~(w_OP1_af_FET | (~w_OP2_af_FET & select_OP2_to_B_inv) | (w_OP2_af_FET & select_OP2_to_B));
assign w_OP1_af_FET	= ~(w_OP1_bf_FET & (OP1_latch_p | ~OP1_latch_n));
assign w_OP1_bf_FET	= ~(~(n_OP1_in & inversion_OP1) & ~(n_OP1_in | inversion_OP1));
assign w_OP2_af_FET = (w_OP2_bf_FET & (OP2_latch_p | ~OP2_latch_n));
assign w_OP2_bf_FET	= OP2_in;


endmodule
