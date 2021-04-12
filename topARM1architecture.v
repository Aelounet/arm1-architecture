

`timescale 1ns / 100ps

module topARM1architecture(
	ADDR_BUS,
	DATA_BUS,
	BW,
	RW,
	PHI1,
	PHI2,
	IRQ,
	FIQ,
	RESET,
	ABORT,
	OPC,
	TRANS,
	MREQ,
	M,
	SEQ,
	DBE,
	ABE,
	ALE
);
inout	ADDR_BUS;
inout	DATA_BUS;
output	BW;
output	RW;
input	PHI1;
input	PHI2;
input	IRQ;
input	FIQ;
input	RESET;
input	ABORT;
output	OPC;
output	TRANS;
output	MREQ;
output [1:0]	M;
output	SEQ;		//Incrément d'adresse utilisé
input	DBE;
input	ABE;
input	ALE;




//reg   	;
wire	[31:0] 	bus_A;
wire	[31:0] 	bus_B;
wire	[31:0] 	bus_B_shifted;
wire 	[31:0]	bus_ALU;
wire	[31:0]	bus_PC;
wire	[31:0]	increment_PC;

always @(posedge clk) 
	begin
		if (rst) begin
			//sign <= 0;
			
		end
		else if (enable) begin
			//sign <= opa[63];
		end
	end

endmodule
