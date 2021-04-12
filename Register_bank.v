

`timescale 1ns / 100ps

module register_bank(
	phi1_clock
);

wire	read_bus_A_select;
wire	read_bus_B_select;
wire	[31:0]	read_bus_A;
wire	[31:0]	read_bus_B;
wire	write_bus;

/////////////////	Registers themselves !


reg		[31:0] x [24:0]	registers;

always @ (read_bus_A_select)
begin
	if (read_bus_A_select == 1) begin	//a revoir car dépend du bit
		read_bus_A <= registers;
	end
end

always @ (read_bus_B_select)
begin
	if (read_bus_B_select == 1) begin	//a revoir
		read_bus_B <= registers;
	end
end

always @ (write_select)
begin
	if (write_select == 1) begin
		registers <= saved_bus;
	end
end


/////////////////	 Décodage des registres - numéro du reg sur 4 bits

wire	[3:0]	reg_nb;
wire	[3:0]	reg_nb_inv;
wire	[24:0]	reg_decode;

assign reg_nb_inv = ~reg_nb;

assign reg_decode[0] = (reg_nb == 4'd0);
assign reg_decode[1] = (reg_nb == 4'd1);
assign reg_decode[2] = (reg_nb == 4'd2);
assign reg_decode[3] = (reg_nb == 4'd3);
assign reg_decode[4] = (reg_nb == 4'd4);
assign reg_decode[5] = (reg_nb == 4'd5);
assign reg_decode[6] = (reg_nb == 4'd6);
assign reg_decode[7] = (reg_nb == 4'd7);
assign reg_decode[8] = (reg_nb == 4'd8);
assign reg_decode[9] = (reg_nb == 4'd9);
assign reg_decode[10] =	(reg_nb == 4'd10);
assign reg_decode[11] =	(reg_nb == 4'd10);
assign reg_decode[12] =	(reg_nb == 4'd11);
assign reg_decode[13] =	(reg_nb == 4'd11);
assign reg_decode[14] =	(reg_nb == 4'd12);
assign reg_decode[15] =	(reg_nb == 4'd12);
assign reg_decode[16] =	(reg_nb == 4'd13);
assign reg_decode[17] =	(reg_nb == 4'd13);
assign reg_decode[18] =	(reg_nb == 4'd13);
assign reg_decode[19] =	(reg_nb == 4'd13);
assign reg_decode[20] =	(reg_nb == 4'd14);
assign reg_decode[21] =	(reg_nb == 4'd14);
assign reg_decode[22] =	(reg_nb == 4'd14);
assign reg_decode[23] =	(reg_nb == 4'd14);
assign reg_decode[24] =	(reg_nb == 4'd15);


//// register decoding processor - Mode du processeur

wire r1;
wire r0;
wire force_mode;
wire PLA2_8186;
wire [24:0] w_process_mode;

wire FIQ;
wire FIQ_n;
wire IRQ;
wire SVC;
wire USR;

wire [24:0] read_bus_B_select;


wire w_r1_fm;
wire w_r1_fm_n;
wire w_r0_fm;
wire w_r0_fm_n;

assign w_r1_fm = ~(force_mode & r1);
assign w_r1_fm_n = ~w_r1_fm;
assign w_r0_fm = ~(force_mode & r0);
assign w_r0_fm_n = ~w_r0_fm;


assign FIQ = w_r1_fm & w_r0_fm_n;
assign FIQ_n = ~FIQ;
assign IRQ = w_r1_fm_n & w_r0_fm;
assign SVC = w_r1_fm_n & w_r0_fm_n;
assign USR = w_r1_fm & w_r0_fm;


assign w_process_mode[0] = 0'b0;
assign w_process_mode[1] = 0'b0;
assign w_process_mode[2] = 0'b0;
assign w_process_mode[3] = 0'b0;
assign w_process_mode[4] = 0'b0;
assign w_process_mode[5] = 0'b0;
assign w_process_mode[6] = 0'b0;
assign w_process_mode[7] = 0'b0;
assign w_process_mode[8] = 0'b0;
assign w_process_mode[9] = 0'b0;
assign w_process_mode[10] = FIQ;
assign w_process_mode[11] = FIQ_n;
assign w_process_mode[12] = FIQ;
assign w_process_mode[13] = FIQ_n;
assign w_process_mode[14] = FIQ;
assign w_process_mode[15] = FIQ_n;
assign w_process_mode[16] = USR;
assign w_process_mode[17] = FIQ_n;
assign w_process_mode[18] = IRQ;
assign w_process_mode[19] = SVC;
assign w_process_mode[20] = USR;
assign w_process_mode[21] = FIQ_n;
assign w_process_mode[22] = IRQ;
assign w_process_mode[23] = SVC;
assign w_process_mode[24] = 0'b0;


//// register decoding processor - Read bus B (DIN, Barrel shift)

generate
	for (i = 0; i <= 24 ; i++) { 
		assign read_bus_B_select[i] = phi1_clock & ~(PLA2_8186 | reg_decode[i] | w_process_mode[i]);
	}
endgenerate

//// register decoding processor - Read bus A (ALU)

generate
	for (i = 0; i <= 24 ; i++) { 
		assign read_bus_A_select[i] = phi1_clock & ~((PLA2_8202 | PLA2_8201) | reg_decode[i] | w_process_mode[i]);
	}
endgenerate

//// register decoding processor - Write bus (DOUT)

wire nwen;

generate
	for (i = 0; i <= 24 ; i++) { 
		assign write_select[i] = phi2_clock & ~(nwen | reg_decode[i] | w_process_mode[i]);
	}
endgenerate







/////////////// Register Selection - Input Multiplexing (reg_nb)

wire PLA2_8042;
wire PLA2_8042_n;
wire PLA2_8041;
wire PLA2_8041_n;
wire PLA2_8040;
wire PLA2_8040_n;

wire [4:0] w_mux_Bus_A;
wire [4:0] w_mux_Bus_B;
wire [4:0] w_mux_Write;
 
assign w_mux_Bus_B[0] = PLA2_8042 & PLA2_8041_n & PLA2_8040_n;	//1
assign w_mux_Bus_B[1] = PLA2_8042_n & PLA2_8041 & PLA2_8040_n; //IReg r19
assign w_mux_Bus_B[2] = PLA2_8042_n & PLA2_8041_n & PLA2_8040; //IReg r15
assign w_mux_Bus_B[3] = PLA2_8042_n & PLA2_8041_n & PLA2_8040_n; //IReg r3
assign w_mux_Bus_B[4] = PLA2_8042_n & PLA2_8041 & PLA2_8040; //Priencoder




//// Register Selection - Read Bus B - Input Multiplexing (reg_nb)

assign reg_nb[3] = ~(w_mux_Bus_B[0] | (w_mux_Bus_B[1] & IReg_r19) | (w_mux_Bus_B[2] & IReg_r15) | (w_mux_Bus_B[3] & IReg_r3) | (w_mux_Bus_B[4] & Priencoder[3]));
//check si b3 est reg_nb[3]
assign reg_nb[2] = ~(w_mux_Bus_B[0] | (w_mux_Bus_B[1] & IReg_r18) | (w_mux_Bus_B[2] & IReg_r14) | (w_mux_Bus_B[3] & IReg_r2) | (w_mux_Bus_B[4] & Priencoder[2]));
assign reg_nb[1] = ~(w_mux_Bus_B[0] | (w_mux_Bus_B[1] & IReg_r17) | (w_mux_Bus_B[2] & IReg_r13) | (w_mux_Bus_B[3] & IReg_r1) | (w_mux_Bus_B[4] & Priencoder[1]));
assign reg_nb[0] = ~(~w_mux_Bus_B[0] | (w_mux_Bus_B[1] & IReg_r16) | (w_mux_Bus_B[2] & IReg_r12) | (w_mux_Bus_B[3] & IReg_r0) | (w_mux_Bus_B[4] & Priencoder[0]));




///// Register Selection - Read Bus A - Input Multiplexing

assign w_mux_Bus_A[0] =  PLA2_8041_n & PLA2_8040_n;	//IReg r19
assign w_mux_Bus_A[1] =  PLA2_8041_n & PLA2_8040; //IReg r11
assign w_mux_Bus_A[2] =  PLA2_8041; //1

assign reg_nb_bus_A[3] = ~((w_mux_Bus_A[0] & IReg_r19) | (w_mux_Bus_A[1] & IReg_r11) | w_mux_Bus_A[2]);
//check si b3 est reg_nb[3]
assign reg_nb_bus_A[3] = ~((w_mux_Bus_A[0] & IReg_r18) | (w_mux_Bus_A[1] & IReg_r10) | w_mux_Bus_A[2]);
assign reg_nb_bus_A[3] = ~((w_mux_Bus_A[0] & IReg_r17) | (w_mux_Bus_A[1] & IReg_r9) | w_mux_Bus_A[2]);
assign reg_nb_bus_A[3] = ~((w_mux_Bus_A[0] & IReg_r16) | (w_mux_Bus_A[1] & IReg_r8) | w_mux_Bus_A[2]);
 





/////////////// Register Selection - Write Bus - Input Multiplexing



endmodule
