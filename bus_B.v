

`timescale 1ns / 100ps

module bus_B(
	phi2_clk,
	RB_in,			//data from Register Bank
	instr_in,		//data from instruction register or data pins (data IN)
	instr_in_en,	//enable data from instruction reg or data pins
	data_pc_in,		//data from PC reading
	data_pc_in_en,	//enable data from PC reading
	barrel_shifter_out,
	data_out
);
	
input			phi2_clk;
input	[31:0]	RB_in;
input	[31:0]	instr_in;
input	[4:0]	instr_in_en;
input	[31:0]	data_pc_in;
input			data_pc_in_en;
output	[31:0]	barrel_shifter_out;
output	[31:0]	data_out;

reg	[31:0]	bus_b;




assign data_out <= bus_b;
assign barrel_shifter_out <= bus_b;


always @(phi2_clk) 
	begin
		if (phi2_clk = 1'b1) begin
			bus_b <= 32'hFFFFFFFF;
		end
		else
			bus_b[31:24] <= ~(data_pc_in_en & data_pc_in[31:24]) | (instr_in_en[4] & instr_in[31:24]) | RB_in[31:24]);
			bus_b[23:16] <= ~(data_pc_in_en & data_pc_in[23:16]) | (instr_in_en[3] & instr_in[23:16]) | RB_in[26:16]);
			bus_b[15:12] <= ~(data_pc_in_en & data_pc_in[15:12]) | (instr_in_en[2] & instr_in[15:12]) | RB_in[15:12]);
			bus_b[11:8] <= ~(data_pc_in_en & data_pc_in[11:8]) | (instr_in_en[1] & instr_in[11:8]) | RB_in[11:8]);
			bus_b[7:0] <= ~(data_pc_in_en & data_pc_in[7:0]) | (instr_in_en[0] & instr_in[7:0]) | RB_in[7:0]);
		end
		
	end


	///////////////  Circuit 1 - ENABLE signals
	
	wire BW;
	wire [1:0]	PLA2_cmd_mux;
	wire [1:0]	PLA2_cmd_and;
	wire [4:0]	w_mux_to_and;
	wire [3:0]	w_or_to_mux;
	wire pipe_stat;
	wire pipe_stat_inv;
	wire inst_decode;
	wire inst_decode_inv;
	
	assign pipe_stat_inv = ~pipe_stat;
	assign inst_decode_inv = ~inst_decode;
	
	assign w_or_to_mux[0] = BW | (pipe_stat_inv & inst_decode_inv);
	assign w_or_to_mux[1] = BW | (pipe_stat & inst_decode_inv);
	assign w_or_to_mux[2] = BW | (pipe_stat_inv & inst_decode);
	assign w_or_to_mux[3] = BW | (pipe_stat & inst_decode);
	
	assign w_mux_to_and[0] = PLA2_cmd_mux
	
	//multiplexeurs
	
	always @ (PLA2_cmd_mux[0] or w_or_to_mux[0]or w_mux_to_and[0])
		begin
		case (PLA2_cmd_mux[0])
			2'b00 : w_mux_to_and[0] <= 0;
			2'b01 : w_mux_to_and[0] <= 0;
			2'b10 : w_mux_to_and[0] <= 0;
			2'b11 : w_mux_to_and[0] <= w_or_to_mux[0];
		endcase
	end
	
	always @ (PLA2_cmd_mux[1] or w_or_to_mux[1]or w_mux_to_and[1])
		begin
		case (PLA2_cmd_mux[1])
			2'b00 : w_mux_to_and[1] <= 0;
			2'b01 : w_mux_to_and[1] <= 0;
			2'b10 : w_mux_to_and[1] <= 0;
			2'b11 : w_mux_to_and[1] <= w_or_to_mux[1];
		endcase
	end
	
	always @ (PLA2_cmd_mux[2] or w_or_to_mux[1]or w_mux_to_and[2])
		begin
		case (PLA2_cmd_mux[2])
			2'b00 : w_mux_to_and[2] <= 0;
			2'b01 : w_mux_to_and[2] <= 0;
			2'b10 : w_mux_to_and[2] <= 0;
			2'b11 : w_mux_to_and[2] <= w_or_to_mux[1];
		endcase
	end
	
	always @ (PLA2_cmd_mux[3] or w_or_to_mux[2]or w_mux_to_and[3])
		begin
		case (PLA2_cmd_mux[3])
			2'b00 : w_mux_to_and[3] <= 0;
			2'b01 : w_mux_to_and[3] <= 0;
			2'b10 : w_mux_to_and[3] <= 0;
			2'b11 : w_mux_to_and[3] <= w_or_to_mux[2];
		endcase
	end
	
	always @ (PLA2_cmd_mux[4] or w_or_to_mux[3]or w_mux_to_and[4])
		begin
		case (PLA2_cmd_mux[4])
			2'b00 : w_mux_to_and[4] <= 0;
			2'b01 : w_mux_to_and[4] <= 0;
			2'b10 : w_mux_to_and[4] <= 0;
			2'b11 : w_mux_to_and[4] <= w_or_to_mux[3];
		endcase
	end
	
	//ANDs finaux
	
	assign PLA_cmd_and = ~(~PLA2_8186 | PLA2_8272);
	
	assign instr_in_en[0] = phi1_clk & PLA2_cmd_and & w_mux_to_and[0];
	assign instr_in_en[1] = phi1_clk & PLA2_cmd_and & w_mux_to_and[1];
	assign instr_in_en[2] = phi1_clk & PLA2_cmd_and & w_mux_to_and[2];
	assign instr_in_en[3] = phi1_clk & PLA2_cmd_and & w_mux_to_and[3];
	assign instr_in_en[4] = phi1_clk & PLA2_cmd_and & w_mux_to_and[4];
	
	
	
	
	//////////////	Circuit 1 - Decoding & MUX  : I-Reg / Data IN
	
	wire cond_seq;		//signaux de multiplexage
	wire PLA2_8111;		//signaux de multiplexage
	
	wire [31:0]	data_in;	//	Le fameux DATA IN (from circuit 5)
	wire [31:0] Instr_Reg;	// Venant du registre d'Instruction
	
	
	reg PLA2_8111_clked;
	
	reg	cmd_data_in;
	reg	cmd_instr_reg;
	
	always @ (phi1_clk)
		begin
			if (phi1_clk == 1'b1) begin
				PLA2_8111_clked <= PLA2_8111;
			end
	end
	
	assign cmd_data_in = PLA2_8111_clked & phi2_clk;
	assign cmd_instr_in = cond_seq & phi2_clk;
	
	generate        
		for (i = 0; i <= 31 ; i++) {        
		  assign instr_in[i] = (cmd_data_in & data_in[i]) | (cmd_instr_reg & Instr_Reg[i]);
		}        
	endgenerate 
	
	
	
	//////////////	Circuit 2/3 - Decoding : I-reg
	
	wire w_8187;
	wire w_8187_cmd;
	wire w_8187_cmd_inv;
	wire w_4616;
	wire w_4616_cmd;
	wire w_4585;		//come from opc pin (processor is fetching an instruction)
	wire w_4585_cmd;

	assign w_8187_cmd = w_8187 & ~phi1_clk;
	assign w_8187_cmd_inv = ~w_8187 & ~phi1_clk;
	assign w_4616_cmd = ~(w_4616 & phi2_clk);
	assign w_4585_cmd = ~(w_4585 & phi2_clk);
	
	wire [31:0]	Read;
	wire [31:0]	Read_af_4585;
	wire [31:0]	Read_af_4616;
	wire [31:0]	Read_af_8187;
	wire [31:0]	Some_bits_only;
	wire [31:0]	Instr_Reg;
	
	generate        // Revoir la bascule et les exceptions
					// bits 25, 26 et 27 non connectés
					//bits 4, 20 ,24, 25, 26, et 27 (???) sont prises de l'autre coté de la bascule
		for (i = 0; i <= 31 ; i++) { 
			assign Read_af_4585[i] = ~(w_4585_cmd & Read[i]);
			assign Read_af_4616[i] = ~(w_4616_cmd & Read_af_4585[i]);
			assign Read_af_8187[i] = (Instr_Reg[i] & w_8187_cmd_inv) | (w_8187_cmd & Read_af_4616[i]);
			assign Some_bits_only[i] = ~Read_af_8187[i];
			assign Instr_Reg[i] = ~(phi2_clk & Some_bits_only[i]);
		}
	endgenerate
	
	
	
	
	//////////////	Circuit 4 - processing : DATA OUT
	//// Le choix se fait avec la broche BW pour sortir soit un mot de 32bit soit un octet
	
	wire w_bw_cmd;
	wire w_bw_cmd_inv;
	wire [31:0]	nbus;
	wire [7:0] first_byte;
	wire bw ;// à raccorder
	
	assign w_bw_cmd = bw & phi2_clk;
	assign w_bw_cmd_inv = ~bw & phi2_clk;
	
	
	generate
		for (i = 31; i >= 8 ; i--) { 
			assign nbus[i] = ~((w_bw_cmd & ~bus_b[i]) | (w_bw_cmd_inv & first_byte[i%4]));
		}
	endgenerate
	
	generate
		for (i = 7; i >= 0 ; i--) { 
			assign first_byte[i] = bus_b[i];
			assign nbus[i] = ~(~bus_b[i] & phi2_clk);
		}
	endgenerate
	
	
	
	
	//////////////	Circuit 5 - Data Lines (DATA IN & DATA OUT)
	//// Port de lecture/ecriture
	
	//TODO : envie de passer à autre chose
	
	wire w_DBE;
	wire w_RW;
	wire [31:0] w_dPad;	//Data pins
	reg w_RW_cmd;
	
	assign w_RW_cmd = w_DBE & (~w_RW & ~phi1_clk);
	assign data_in = w_dPad; //Data pins normalement double inversion
	
	always @ (*)
	begin
		if (w_RW_cmd & n
		
		
	end
	
	
	
endmodule
