`default_nettype wire
`ifdef SIM			//se sto simulando 
	`define POTENTIAL
	//`define IEEG
	`define EMG

	`ifdef IEEG
		`define PATH "ieeg"
		`define CONFIG_PATH "rtl/config/ieeg/config.txt"
	`elsif EMG
		 `define PATH "emg"
		 `define CONFIG_PATH "rtl/config/emg/config.txt"
	`endif

	//`define CONFIGURABILITY
	`define ACCESSIBILITY
	//`define UART_HP
	`define LOW_POWER

`else				//se sto facendo la sintesi con ORFS
	`define RTL
	`define POTENTIAL
	//`define IEEG
	`define EMG

	`ifdef IEEG
		`define PATH "ieeg"
		`define CONFIG_PATH "rtl/config/ieeg/config.txt"
	`elsif EMG
		 `define PATH "emg"
		 `define CONFIG_PATH "rtl/config/emg/config.txt"
	`endif

	//`define CONFIGURABILITY
	`define ACCESSIBILITY
	//`define UART_HP
	`define LOW_POWER
`endif
`define FUNCTIONAL
(* use_dsp = "yes" *) module accumulator (
	clk,
	ce1,
	ce2,
	ce3,
	rst,
	clear_and_go,
	clear,
	a,
	b,
	presubmult_out
);
	parameter SIZEIN = 16;
	input clk;
	input ce1;
	input ce2;
	input ce3;
	input rst;
	input clear_and_go;
	input clear;
	input signed [SIZEIN - 1:0] a;
	input signed [SIZEIN - 1:0] b;
	output wire signed [(2 * SIZEIN) - 1:0] presubmult_out;
	reg signed [SIZEIN - 1:0] a_reg;
	reg signed [SIZEIN - 1:0] b_reg;
	reg signed [SIZEIN:0] add_reg;
	reg signed [2 * SIZEIN:0] p_reg;
	always @(posedge clk)
		if (rst | clear) begin
			a_reg <= 0;
			b_reg <= 0;
			add_reg <= 0;
			p_reg <= 0;
		end
		else begin
			if (ce1) begin
				a_reg <= a;
				b_reg <= b;
			end
			if (ce2)
				add_reg <= a_reg + b_reg;
			if (ce3) begin
				if (clear_and_go)
					p_reg <= add_reg;
				else
					p_reg <= p_reg + add_reg;
			end
		end
	assign presubmult_out = p_reg;
endmodule
(* use_dsp = "simd" *) module adder_simd (
	clk,
	en,
	a_0,
	a_1,
	b_0,
	b_1,
	out_0,
	out_1
);
	parameter N = 2;
	parameter W = 15;
	input clk;
	input en;
	input [W - 1:0] a_0;
	input [W - 1:0] a_1;
	input [W - 1:0] b_0;
	input [W - 1:0] b_1;
	output reg signed [W:0] out_0;
	output reg signed [W:0] out_1;
	integer i;
	reg signed [W - 1:0] a_r [N - 1:0];
	reg signed [W - 1:0] b_r [N - 1:0];
	always @(posedge clk)
		if (en) begin
			a_r[0] <= a_0;
			b_r[0] <= b_0;
			out_0 <= a_r[0] + b_r[0];
			a_r[1] <= a_1;
			b_r[1] <= b_1;
			out_1 <= a_r[1] + b_r[1];
		end
endmodule
module bram_fifo (
	clk,
	rst,
	DI,
	rden,
	wren,
	DO
);
	parameter DATA_WIDTH = 25;
	parameter DEPTH = 256;
	input clk;
	input rst;
	input [DATA_WIDTH - 1:0] DI;
	input rden;
	input wren;
	output wire [DATA_WIDTH - 1:0] DO;
	function integer clogb2;
		input integer depth;
		for (clogb2 = 0; depth > 0; clogb2 = clogb2 + 1)
			depth = depth >> 1;
	endfunction
	reg [clogb2(DEPTH - 1) - 1:0] rd_cnt;
	reg [clogb2(DEPTH - 1) - 1:0] wr_cnt;
	always @(posedge clk)
		if (rst)
			rd_cnt <= 0;
		else if (rden) begin
			if (rd_cnt < (DEPTH - 1))
				rd_cnt <= rd_cnt + 1'b1;
			else
				rd_cnt <= 0;
		end
	always @(posedge clk)
		if (rst)
			wr_cnt <= 0;
		else if (wren) begin
			if (wr_cnt < (DEPTH - 1))
				wr_cnt <= wr_cnt + 1'b1;
			else
				wr_cnt <= 0;
		end
	ihp_dualport_256x48_dualmem #(
		.RAM_WIDTH(DATA_WIDTH),
		.RAM_DEPTH(DEPTH),
		.RAM_PERFORMANCE("LOW_LATENCY"),
		.INIT_FILE("")
	) fifo_ram(
		.addra(wr_cnt),
		.addrb(rd_cnt),
		.dina(DI),
		.clk(clk),
		.wea(wren),
		.ena(wren),
		.enb(rden),
		.rst(rst),
		.regceb(1'b1),
		.doutb(DO)
	);
endmodule
module BRAM_singlePort_readFirst (
	addra,
	addrb,
	dina,
	clk,
	wea,
	ena,
	enb,
	rst,
	regceb,
	doutb
);
	parameter RAM_WIDTH = 4;
	parameter RAM_DEPTH = 64;
	parameter RAM_PERFORMANCE = "HIGH_PERFORMANCE";
	parameter INIT_FILE = "";
	function integer clogb2;
		input integer depth;
		for (clogb2 = 0; depth > 0; clogb2 = clogb2 + 1)
			depth = depth >> 1;
	endfunction
	input [clogb2(RAM_DEPTH - 1) - 1:0] addra;
	input [clogb2(RAM_DEPTH - 1) - 1:0] addrb;
	input [RAM_WIDTH - 1:0] dina;
	input clk;
	input wea;
	input ena;
	input enb;
	input rst;
	input regceb;
	output wire [RAM_WIDTH - 1:0] doutb;
	reg [RAM_WIDTH - 1:0] ram [RAM_DEPTH - 1:0];
	reg [RAM_WIDTH - 1:0] ram_data_b = {RAM_WIDTH {1'b0}};
	genvar _gv_idx_1;
	generate
		for (_gv_idx_1 = 0; _gv_idx_1 < 16; _gv_idx_1 = _gv_idx_1 + 1) begin : genblk1
			localparam idx = _gv_idx_1;
			wire [RAM_WIDTH - 1:0] tmp;
			assign tmp = ram[idx];
		end
		if (INIT_FILE != "") begin : use_init_file
			initial $readmemh(INIT_FILE, ram, 0, RAM_DEPTH - 1);
		end
		else begin : init_bram_to_zero
			integer ram_index;
			initial for (ram_index = 0; ram_index < RAM_DEPTH; ram_index = ram_index + 1)
				ram[ram_index] = {RAM_WIDTH {1'b0}};
		end
	endgenerate
	always @(posedge clk)
		if (ena) begin
			if (wea)
				ram[addra] <= dina;
		end
	always @(posedge clk)
		if (enb)
			ram_data_b <= ram[addrb];
	generate
		if (RAM_PERFORMANCE == "LOW_LATENCY") begin : no_output_register
			assign doutb = ram_data_b;
		end
		else begin : output_register
			reg [RAM_WIDTH - 1:0] doutb_reg = {RAM_WIDTH {1'b0}};
			always @(posedge clk)
				if (rst)
					doutb_reg <= {RAM_WIDTH {1'b0}};
				else if (regceb)
					doutb_reg <= ram_data_b;
			assign doutb = doutb_reg;
		end
	endgenerate
endmodule
module conv (
	clk,
	rst,
	en,
	acc_clear_and_go,
	acc_clear,
	weights_in,
	spikes,
	out,
	valid
);
	parameter WEIGHTS = 4;
	parameter DATA_WIDTH = 15;
	input clk;
	input rst;
	input en;
	input acc_clear_and_go;
	input acc_clear;
	input signed [(WEIGHTS * DATA_WIDTH) - 1:0] weights_in;
	input [WEIGHTS - 1:0] spikes;
	output wire [(2 * (DATA_WIDTH + 1)) - 1:0] out;
	output wire valid;
	localparam SUM = WEIGHTS / 2;
	localparam PIPE = 5;
	wire signed [DATA_WIDTH - 1:0] weights [WEIGHTS - 1:0];
	assign weights[0] = weights_in[DATA_WIDTH - 1:0];
	assign weights[1] = weights_in[(2 * DATA_WIDTH) - 1:DATA_WIDTH];
	assign weights[2] = weights_in[(3 * DATA_WIDTH) - 1:2 * DATA_WIDTH];
	assign weights[3] = weights_in[(4 * DATA_WIDTH) - 1:3 * DATA_WIDTH];
	reg [4:0] en_shift;
	integer i;
	always @(posedge clk)
		if (rst)
			en_shift <= 0;
		else begin
			en_shift[0] <= en;
			for (i = 1; i < PIPE; i = i + 1)
				en_shift[i] <= en_shift[i - 1];
		end
	wire signed [DATA_WIDTH - 1:0] weights_a [SUM - 1:0];
	wire signed [DATA_WIDTH - 1:0] weights_b [SUM - 1:0];
	assign weights_a[0] = weights[2];
	assign weights_a[1] = weights[3];
	assign weights_b[0] = weights[0];
	assign weights_b[1] = weights[1];
	wire [DATA_WIDTH - 1:0] spike_a [SUM - 1:0];
	wire [DATA_WIDTH - 1:0] spike_b [SUM - 1:0];
	assign spike_a[1] = {DATA_WIDTH {spikes[WEIGHTS - 1]}};
	assign spike_a[0] = {DATA_WIDTH {spikes[WEIGHTS - 2]}};
	assign spike_b[1] = {DATA_WIDTH {spikes[WEIGHTS - 3]}};
	assign spike_b[0] = {DATA_WIDTH {spikes[WEIGHTS - 4]}};
	wire [DATA_WIDTH - 1:0] anded_weights_a [SUM - 1:0];
	wire [DATA_WIDTH - 1:0] anded_weights_b [SUM - 1:0];
	assign anded_weights_a[0] = weights_a[0] & spike_a[0];
	assign anded_weights_a[1] = weights_a[1] & spike_a[1];
	assign anded_weights_b[0] = weights_b[0] & spike_b[0];
	assign anded_weights_b[1] = weights_b[1] & spike_b[1];
	wire signed [DATA_WIDTH:0] double_adder_out [SUM - 1:0];
	wire double_adder_en;
	assign double_adder_en = en | en_shift[0];
	adder_simd #(
		.N(SUM),
		.W(DATA_WIDTH)
	) double_adder(
		.clk(clk),
		.en(double_adder_en),
		.a_0(anded_weights_a[0]),
		.a_1(anded_weights_a[1]),
		.b_0(anded_weights_b[0]),
		.b_1(anded_weights_b[1]),
		.out_0(double_adder_out[0]),
		.out_1(double_adder_out[1])
	);
	wire [(2 * (DATA_WIDTH + 1)) - 1:0] acc_out;
	accumulator #(.SIZEIN(DATA_WIDTH + 1)) acc(
		.clk(clk),
		.ce1(en_shift[1]),
		.ce2(en_shift[2]),
		.ce3(en_shift[3]),
		.rst(rst),
		.clear_and_go(acc_clear_and_go),
		.clear(acc_clear),
		.a(double_adder_out[0]),
		.b(double_adder_out[1]),
		.presubmult_out(acc_out)
	);
	assign valid = en_shift[4];
	assign out = (valid ? acc_out : 0);
endmodule
module encoding_slot (
	clk,
	rst,
	en,
	data_in,
	detect,
	spike_bin,
	valid_bin,
	active_group_out_bin,
	inference_done,
	o_sample_mem_dat,
	i_sample_mem_adr,
	i_sample_mem_rd_en,
	i_sample_mem_wr_en,
	i_sample_mem_dat,
	bypass,
	enb_debug
);
	parameter BYPASS = 0;
	parameter CHANNELS = 128;
	parameter ORDER = 2;
	parameter WINDOW = 8192;
	parameter REF_PERIOD = 16;
	parameter DW = 15;
	input clk;
	input rst;
	input en;
	input signed [15:0] data_in;
	input detect;
	output reg [3:0] spike_bin;
	output reg valid_bin;
	output reg active_group_out_bin;
	input inference_done;
	output wire [15:0] o_sample_mem_dat;
	function integer clogb2;
		input integer depth;
		for (clogb2 = 0; depth > 0; clogb2 = clogb2 + 1)
			depth = depth >> 1;
	endfunction
	input wire [clogb2(CHANNELS - 1) - 1:0] i_sample_mem_adr;
	input wire i_sample_mem_rd_en;
	input wire i_sample_mem_wr_en;
	input wire [15:0] i_sample_mem_dat;
	input wire bypass;
	input wire enb_debug;
	wire signed [DW - 1:0] data_out_buffer;
	wire input_buffer_valid;
	input_buffer #(
		.CHANNELS(CHANNELS),
		.DW(DW)
	) input_buffer_i(
		.clk(clk),
		.rst(rst),
		.en(en),
		.data_in(data_in),
		.valid(input_buffer_valid),
		.data_out(data_out_buffer),
		.external_access_en(i_sample_mem_rd_en),
		.external_addr(i_sample_mem_adr),
		.external_data_out(o_sample_mem_dat),
		.external_access_wren(i_sample_mem_wr_en),
		.external_data_in(i_sample_mem_dat),
		.enb_debug(enb_debug)
	);
	wire [3:0] spike_bin_int;
	wire valid_bin_int;
	wire active_group_out_bin_int;
	generate
		if (BYPASS) begin : genblk1
			always @(posedge clk) begin
				spike_bin <= spike_bin_int;
				valid_bin <= valid_bin_int;
				active_group_out_bin <= active_group_out_bin_int;
			end
		end
		else begin : genblk1
			always @(posedge clk)
				if (bypass) begin
					spike_bin <= data_out_buffer[3:0];
					valid_bin <= input_buffer_valid;
					active_group_out_bin <= |data_out_buffer[3:0];
				end
				else begin
					spike_bin <= spike_bin_int;
					valid_bin <= valid_bin_int;
					active_group_out_bin <= active_group_out_bin_int;
				end
		end
	endgenerate
endmodule
module encoding_slot_emg (
	clk,
	rst,
	en,
	data_in,
	spike_bin,
	valid_bin,
	active_group_out_bin
);
	parameter CHANNELS = 128;
	parameter DW = 8;
	input clk;
	input rst;
	input en;
	input signed [DW - 1:0] data_in;
	output wire [3:0] spike_bin;
	output wire valid_bin;
	output wire active_group_out_bin;
	localparam SPIKE = 4;
	function integer clogb2;
		input integer depth;
		for (clogb2 = 0; depth > 0; clogb2 = clogb2 + 1)
			depth = depth >> 1;
	endfunction
	localparam CHANNELS_L2 = clogb2(CHANNELS - 1);
	wire [1:0] dm_spike;
	wire pos_spike;
	wire neg_spike;
	wire dm_valid;
	delta_modulator_multichannel #(
		.CHANNELS(CHANNELS),
		.WIDTH(DW)
	) delta_modulator_1(
		.clk(clk),
		.rst(rst),
		.en(en),
		.samples(data_in),
		.pos_spike(pos_spike),
		.neg_spike(neg_spike),
		.valid(dm_valid)
	);
	wire ag1;
	wire ag2;
	wire [1:0] s2p_out_1;
	wire [1:0] s2p_out_2;
	s2p #(.P(2)) s2p_1(
		.clk(clk),
		.rst(rst),
		.en(dm_valid),
		.spike_s(pos_spike),
		.spike_p(s2p_out_1),
		.valid(valid_bin),
		.active_group(ag1)
	);
	s2p #(.P(2)) s2p_2(
		.clk(clk),
		.rst(rst),
		.en(dm_valid),
		.spike_s(neg_spike),
		.spike_p(s2p_out_2),
		.valid(),
		.active_group(ag2)
	);
	assign active_group_out_bin = ag1 | ag2;
	assign spike_bin = {s2p_out_1[1], s2p_out_2[1], s2p_out_1[0], s2p_out_2[0]};
endmodule
module input_buffer (
	clk,
	rst,
	en,
	data_in,
	valid,
	data_out,
	external_access_en,
	external_addr,
	external_data_out,
	external_access_wren,
	external_data_in,
	enb_debug
);
	parameter CHANNELS = 128;
	parameter DW = 15;
	input clk;
	input rst;
	input en;
	input signed [15:0] data_in;
	output reg valid;
	output wire signed [DW - 1:0] data_out;
	input external_access_en;
	function integer clogb2;
		input integer depth;
		for (clogb2 = 0; depth > 0; clogb2 = clogb2 + 1)
			depth = depth >> 1;
	endfunction
	input [clogb2(CHANNELS - 1) - 1:0] external_addr;
	output wire signed [15:0] external_data_out;
	input external_access_wren;
	input signed [15:0] external_data_in;
	input enb_debug;
	localparam SIMD = (DW == 8 ? 1 : 0);
	localparam CHANNELS_INT = (SIMD ? CHANNELS / 2 : CHANNELS);
	reg [clogb2(CHANNELS_INT - 1) - 1:0] pointer;
	reg read_flag;
	reg slow_stream_out;
	generate
		if (SIMD) begin : genblk1
			always @(posedge clk)
				if (rst)
					slow_stream_out <= 0;
				else if (read_flag)
					slow_stream_out <= ~slow_stream_out;
		end
		else begin : genblk1
			always @(*) slow_stream_out = 1;
		end
	endgenerate
	wire [15:0] data_in_mux;
	assign data_in_mux = (external_access_wren ? external_data_in : data_in);
	wire wr_en;
	assign wr_en = en | external_access_wren;
	wire [15:0] mem_out;
	wire [clogb2(CHANNELS_INT - 1) - 1:0] adr;
	ihp_single_port_256x48 #(
		.RAM_WIDTH(16),
		.RAM_DEPTH(CHANNELS_INT),
		.RAM_PERFORMANCE("LOW_LATENCY"),
		.INIT_FILE("")
	) buffer(
		.addra(adr),
		.addrb(adr),
		.dina(data_in_mux),
		.clk(clk),
		.wea(wr_en),
		.ena(wr_en),
		.enb(enb_debug),
		.rst(rst),
		.regceb(1'b1),
		.doutb(mem_out)
	);
	assign adr = (external_access_en | external_access_wren ? external_addr : pointer);
	always @(posedge clk)
		if (rst)
			pointer <= 0;
		else if (wr_en) begin
			if (pointer < CHANNELS_INT)
				pointer <= pointer + 1'b1;
			else
				pointer <= 0;
		end
		else if (read_flag && slow_stream_out) begin
			if (pointer < CHANNELS_INT)
				pointer <= pointer + 1'b1;
			else
				pointer <= 0;
		end
	always @(posedge clk)
		if (rst)
			read_flag <= 1'b0;
		else if (wr_en && (pointer == (CHANNELS_INT - 1)))
			read_flag <= 1'b1;
		else if ((read_flag && slow_stream_out) && (pointer == (CHANNELS_INT - 1)))
			read_flag <= 1'b0;
	always @(posedge clk)
		if (rst)
			valid <= 0;
		else
			valid <= read_flag;
	generate
		if (SIMD) begin : genblk2
			assign data_out = (slow_stream_out ? mem_out[15:8] : mem_out[7:0]);
		end
		else begin : genblk2
			assign data_out = mem_out;
		end
	endgenerate
	assign external_data_out = mem_out;
endmodule
module integrator (
	clk,
	rst,
	en,
	detection,
	output_old,
	decay,
	stimolo,
	threshold,
	valid,
	spike,
	output_new
);
	parameter WIDTH = 25;
	input clk;
	input rst;
	input en;
	input detection;
	input [WIDTH - 1:0] output_old;
	input [13:0] decay;
	input [WIDTH - 1:0] stimolo;
	input [WIDTH - 1:0] threshold;
	output wire valid;
	output wire spike;
	output wire [WIDTH - 1:0] output_new;
	localparam P_SIZE = WIDTH + 13;
	reg signed [WIDTH - 1:0] r_output_old;
	reg signed [13:0] r_decay;
	reg signed [P_SIZE - 1:0] p;
	reg signed [WIDTH - 1:0] p_shift;
	reg signed [WIDTH - 1:0] r_stimolo [2:0];
	reg signed [WIDTH - 1:0] r_threshold [3:0];
	(* use_dsp = "yes" *) reg signed [WIDTH - 1:0] comparator_in;
	reg [3:0] en_shift;
	reg [P_SIZE - 1:0] supporto_1;
	reg [P_SIZE - 1:0] supporto_2;
	integer i;
	always @(posedge clk)
		if (rst) begin
			en_shift <= 0;
			r_output_old <= 0;
			r_decay <= 0;
			p <= 0;
			p_shift <= 0;
			comparator_in <= 0;
			for (i = 0; i < 4; i = i + 1)
				r_threshold[i] <= 0;
			for (i = 0; i < 3; i = i + 1)
				r_stimolo[i] <= 0;
		end
		else begin
			en_shift[0] <= en;
			r_output_old <= output_old;
			r_decay <= decay;
			r_stimolo[0] <= stimolo;
			r_threshold[0] <= threshold;
			en_shift[1] <= en_shift[0];
			p <= r_output_old * r_decay;
			r_stimolo[1] <= r_stimolo[0];
			r_threshold[1] <= r_threshold[0];
			en_shift[2] <= en_shift[1];
			if (p[P_SIZE - 1]) begin
				supporto_1 = ~p + 1'b1;
				supporto_2 = supporto_1[P_SIZE - 1:12];
				p_shift <= ~supporto_2 + 1'b1;
			end
			else
				p_shift <= p[P_SIZE - 1:12];
			r_stimolo[2] <= r_stimolo[1];
			r_threshold[2] <= r_threshold[1];
			en_shift[3] <= en_shift[2];
			comparator_in <= p_shift + r_stimolo[2];
			r_threshold[3] <= r_threshold[2];
		end
	assign spike = ((comparator_in >= r_threshold[3]) & detection ? 1'b1 : 1'b0);
	assign output_new = (spike ? 0 : comparator_in);
	assign valid = en_shift[3];
endmodule
module integrator_and_fifo (
	clk,
	rst,
	en,
	detection,
	decay,
	stimolo,
	threshold,
	valid,
	spike,
	output_new
);
	parameter DEPTH = 256;
	parameter WIDTH = 25;
	input clk;
	input rst;
	input en;
	input detection;
	input [13:0] decay;
	input [WIDTH - 1:0] stimolo;
	input [WIDTH - 1:0] threshold;
	output wire valid;
	output wire spike;
	output wire [WIDTH - 1:0] output_new;
	wire [WIDTH - 1:0] output_old;
	bram_fifo #(
		.DATA_WIDTH(WIDTH),
		.DEPTH(DEPTH)
	) fifo_i(
		.clk(clk),
		.rst(rst),
		.DI(output_new),
		.rden(en),
		.wren(valid),
		.DO(output_old)
	);
	reg en_d;
	reg [WIDTH - 1:0] stimolo_d;
	always @(posedge clk)
		if (rst) begin
			en_d <= 0;
			stimolo_d <= 0;
		end
		else begin
			en_d <= en;
			if (en)
				stimolo_d <= stimolo;
		end
	integrator #(.WIDTH(WIDTH)) integrator_i(
		.clk(clk),
		.rst(rst),
		.en(en_d),
		.detection(detection),
		.output_old(output_old),
		.decay(decay),
		.stimolo(stimolo_d),
		.threshold(threshold),
		.valid(valid),
		.spike(spike),
		.output_new(output_new)
	);
endmodule
module layer_lp (
	clk,
	rst,
	en,
	spike_in,
	active_group_in,
	weight_rd_addr,
	acc_clear,
	acc_clear_and_go,
	convolution_pipe_full,
	layer_id,
	valid,
	spike_out,
	active_group_out,
	valid_potential,
	neuron_lp_voltage,
	integrated_neuron,
	weight_mem_L1_wren,
	weight_mem_L1_wr_addr,
	weight_mem_L1_data_in,
	weight_mem_L1_data_out,
	weight_mem_L1_ena,
	weight_mem_L2_wren,
	weight_mem_L2_wr_addr,
	weight_mem_L2_data_in,
	weight_mem_L2_data_out,
	weight_mem_L2_ena,
	weight_debug,
	weight_en_debug,
	enb_debug
);
	parameter WIDTH = 25;
	parameter NEURON = 256;
	parameter LAYERS = 4;
	parameter WEIGHTS_FILE_1 = "weights_1.txt";
	parameter WEIGHTS_FILE_2 = "weights_2.txt";
	parameter [13:0] current_decay_1 = 0;
	parameter [13:0] current_decay_2 = 0;
	parameter [13:0] current_decay_3 = 0;
	parameter [13:0] current_decay_4 = 0;
	parameter [13:0] voltage_decay_1 = 3681;
	parameter [13:0] voltage_decay_2 = 3681;
	parameter [13:0] voltage_decay_3 = 3681;
	parameter [13:0] voltage_decay_4 = 3681;
	parameter [WIDTH - 1:0] threshold_1 = 6;
	parameter [WIDTH - 1:0] threshold_2 = 6;
	parameter [WIDTH - 1:0] threshold_3 = 6;
	parameter [WIDTH - 1:0] threshold_4 = 6;
	parameter WEIGHT_DEPTH = 8192;
	input clk;
	input rst;
	input en;
	input [3:0] spike_in;
	input active_group_in;
	function integer clogb2;
		input integer depth;
		for (clogb2 = 0; depth > 0; clogb2 = clogb2 + 1)
			depth = depth >> 1;
	endfunction
	input [clogb2(WEIGHT_DEPTH - 1) - 1:0] weight_rd_addr;
	input acc_clear;
	input acc_clear_and_go;
	output wire convolution_pipe_full;
	input [clogb2(LAYERS - 1) - 1:0] layer_id;
	output wire valid;
	output wire [1:0] spike_out;
	output wire active_group_out;
	output reg valid_potential;
	output wire signed [WIDTH - 1:0] neuron_lp_voltage;
	output wire integrated_neuron;
	input [7:0] weight_mem_L1_wren;
	input [clogb2(WEIGHT_DEPTH - 1) - 1:0] weight_mem_L1_wr_addr;
	input [15:0] weight_mem_L1_data_in;
	output wire [15:0] weight_mem_L1_data_out;
	input weight_mem_L1_ena;
	input [7:0] weight_mem_L2_wren;
	input [clogb2(WEIGHT_DEPTH - 1) - 1:0] weight_mem_L2_wr_addr;
	input [15:0] weight_mem_L2_data_in;
	output wire [15:0] weight_mem_L2_data_out;
	input weight_mem_L2_ena;
	output wire [7:0] weight_debug;
	output wire weight_en_debug;
	input enb_debug;
	assign weight_en_debug = en;
	assign weight_debug = weight_rd_addr[7:0];
	localparam WEIGHT = 8;
	wire signed [31:0] weights;
	weights_mem_ihp #(
		.RAM_WIDTH(16),
		.RAM_DEPTH(WEIGHT_DEPTH)
	) weight_mem(
		.addra1(weight_mem_L1_wr_addr),
		.dina1(weight_mem_L1_data_in),
		.wea1(weight_mem_L1_wren[0]),
		.ena1(weight_mem_L1_ena),
		.addra2(weight_mem_L2_wr_addr),
		.dina2(weight_mem_L2_data_in),
		.wea2(weight_mem_L2_wren[0]),
		.ena2(weight_mem_L2_ena),
		.enb(enb_debug),
		.clk(clk),
		.rst(rst),
		.regceb(1'b1),
		.addrb(weight_rd_addr),
		.doutb(weights)
	);
	wire [17:0] stimulus;
	conv #(
		.WEIGHTS(4),
		.DATA_WIDTH(WEIGHT)
	) conv_i(
		.clk(clk),
		.rst(rst),
		.en(en),
		.acc_clear_and_go(acc_clear_and_go),
		.acc_clear(acc_clear),
		.weights_in(weights),
		.spikes(spike_in),
		.out(stimulus),
		.valid(convolution_pipe_full)
	);
	neuron_lp #(
		.DEPTH(NEURON),
		.WIDTH(WIDTH),
		.WEIGHT(WEIGHT),
		.LAYERS(LAYERS)
	) neuron_lp_i(
		.clk(clk),
		.rst(rst),
		.en(acc_clear_and_go),
		.current_decay_1(current_decay_1),
		.voltage_decay_1(voltage_decay_1),
		.threshold_1(threshold_1),
		.current_decay_2(current_decay_2),
		.voltage_decay_2(voltage_decay_2),
		.threshold_2(threshold_2),
		.current_decay_3(current_decay_3),
		.voltage_decay_3(voltage_decay_3),
		.threshold_3(threshold_3),
		.current_decay_4(current_decay_4),
		.voltage_decay_4(voltage_decay_4),
		.threshold_4(threshold_4),
		.synaptic_current(stimulus),
		.layer_id(layer_id),
		.valid(valid),
		.spike_p(spike_out),
		.active_group(active_group_out),
		.voltage_ready(integrated_neuron),
		.voltage(neuron_lp_voltage)
	);
	function integer max;
		input integer a;
		input integer b;
		if (a > b)
			max = a;
		else
			max = b;
	endfunction
endmodule
module neuron_lp (
	clk,
	rst,
	en,
	current_decay_1,
	voltage_decay_1,
	threshold_1,
	current_decay_2,
	voltage_decay_2,
	threshold_2,
	current_decay_3,
	voltage_decay_3,
	threshold_3,
	current_decay_4,
	voltage_decay_4,
	threshold_4,
	synaptic_current,
	layer_id,
	valid,
	spike_p,
	active_group,
	voltage_ready,
	voltage
);
	parameter DEPTH = 256;
	parameter WIDTH = 25;
	parameter WEIGHT = 8;
	parameter LAYERS = 4;
	input clk;
	input rst;
	input en;
	input [13:0] current_decay_1;
	input [13:0] voltage_decay_1;
	input [WIDTH - 1:0] threshold_1;
	input [13:0] current_decay_2;
	input [13:0] voltage_decay_2;
	input [WIDTH - 1:0] threshold_2;
	input [13:0] current_decay_3;
	input [13:0] voltage_decay_3;
	input [WIDTH - 1:0] threshold_3;
	input [13:0] current_decay_4;
	input [13:0] voltage_decay_4;
	input [WIDTH - 1:0] threshold_4;
	input [(2 * (WEIGHT + 1)) - 1:0] synaptic_current;
	function integer clogb2;
		input integer depth;
		for (clogb2 = 0; depth > 0; clogb2 = clogb2 + 1)
			depth = depth >> 1;
	endfunction
	input [clogb2(LAYERS - 1) - 1:0] layer_id;
	output wire valid;
	output wire [1:0] spike_p;
	output wire active_group;
	output wire voltage_ready;
	output wire [WIDTH - 1:0] voltage;
	localparam CURRENT_WIDTH = 2 * (WEIGHT + 1);
	wire [13:0] current_decay;
	wire [13:0] voltage_decay;
	wire [WIDTH - 1:0] threshold;
	assign current_decay = (layer_id == 0 ? current_decay_1 : (layer_id == 1 ? current_decay_2 : (layer_id == 2 ? current_decay_3 : current_decay_4)));
	assign voltage_decay = (layer_id == 0 ? voltage_decay_1 : (layer_id == 1 ? voltage_decay_2 : (layer_id == 2 ? voltage_decay_3 : voltage_decay_4)));
	assign threshold = (layer_id == 0 ? threshold_1 : (layer_id == 1 ? threshold_2 : (layer_id == 2 ? threshold_3 : threshold_4)));
	wire [WIDTH - 1:0] current;
	wire [WIDTH - 1:0] synaptic_current_ext;
	wire spike_s;
	integrator_and_fifo #(
		.DEPTH(DEPTH),
		.WIDTH(WIDTH)
	) Voltage_i(
		.clk(clk),
		.rst(rst),
		.en(en),
		.detection(1'b1),
		.decay(voltage_decay),
		.stimolo(synaptic_current),
		.threshold(threshold),
		.valid(voltage_ready),
		.spike(spike_s),
		.output_new(voltage)
	);
	s2p #(.P(2)) s2p_i(
		.clk(clk),
		.rst(rst),
		.en(voltage_ready),
		.spike_s(spike_s),
		.spike_p(spike_p),
		.valid(valid),
		.active_group(active_group)
	);
endmodule
module s2p (
	clk,
	rst,
	en,
	spike_s,
	spike_p,
	valid,
	active_group
);
	parameter P = 2;
	input clk;
	input rst;
	input en;
	input spike_s;
	output reg [P - 1:0] spike_p;
	output reg valid;
	output reg active_group;
	wire end_cnt;
	always @(posedge clk)
		if (rst)
			valid <= 0;
		else
			valid <= end_cnt;
	function integer clogb2;
		input integer depth;
		for (clogb2 = 0; depth > 0; clogb2 = clogb2 + 1)
			depth = depth >> 1;
	endfunction
	reg [clogb2(P - 1) - 1:0] cnt;
	always @(posedge clk)
		if (rst)
			cnt <= 0;
		else if (en)
			cnt <= cnt + 1'b1;
	assign end_cnt = (cnt == (P - 1)) & en;
	integer i;
	always @(posedge clk)
		if (rst)
			spike_p <= 0;
		else if (en) begin
			spike_p[0] <= spike_s;
			for (i = 1; i < P; i = i + 1)
				spike_p[i] <= spike_p[i - 1];
		end
		else if (valid)
			spike_p <= 0;
	always @(posedge clk)
		if (rst)
			active_group <= 0;
		else if (en)
			active_group <= (active_group && ~valid) | spike_s;
		else if (valid)
			active_group <= 0;
endmodule
module snn_lp (
	clk,
	rst,
	en,
	spike_in,
	active_group_in,
	valid,
	valid_spike,
	spike_out,
	integrated_neuron,
	weight_mem_L1_wren,
	weight_mem_L1_wr_addr,
	weight_mem_L1_data_in,
	weight_mem_L1_data_out,
	weight_mem_L1_ena,
	weight_mem_L2_wren,
	weight_mem_L2_wr_addr,
	weight_mem_L2_data_in,
	weight_mem_L2_data_out,
	weight_mem_L2_ena,
	weight_mem_L3_wren,
	weight_mem_L3_wr_addr,
	weight_mem_L3_data_in,
	weight_mem_L3_data_out,
	weight_mem_L3_ena,
	weight_mem_L4_wren,
	weight_mem_L4_wr_addr,
	weight_mem_L4_data_in,
	weight_mem_L4_data_out,
	weight_mem_L4_ena,
	o_spike_mem_dat,
	i_spike_mem_adr,
	i_spike_mem_rd_en,
	i_spike_mem_wr_en,
	i_spike_mem_dat,
	snn_input_channels,
	neuron_1,
	neuron_2,
	neuron_3,
	neuron_4,
	layers,
	output_buffer_ren,
	output_buffer_addr,
	output_buffer_out,
	output_buffer_wr_en_debug,
	p1,
	p2,
	enb_debug
);
	parameter WIDTH = 16;
	parameter MAX_SYNAPSES = 128;
	parameter MAX_NEURONS = 128;
	parameter LAYERS = 4;
	parameter INPUT_SPIKE_1 = 32;
	parameter NEURON_1 = 64;
	parameter WEIGHTS_FILE_1 = "weights_1.txt";
	parameter [13:0] current_decay_1 = 0;
	parameter [13:0] voltage_decay_1 = 4054;
	parameter [WIDTH - 1:0] threshold_1 = 19;
	parameter INPUT_SPIKE_2 = NEURON_1;
	parameter NEURON_2 = 128;
	parameter WEIGHTS_FILE_2 = "weights_2.txt";
	parameter [13:0] current_decay_2 = 0;
	parameter [13:0] voltage_decay_2 = 4054;
	parameter [WIDTH - 1:0] threshold_2 = 17;
	parameter INPUT_SPIKE_3 = NEURON_2;
	parameter NEURON_3 = 64;
	parameter WEIGHTS_FILE_3 = "weights_3.txt";
	parameter [13:0] current_decay_3 = 0;
	parameter [13:0] voltage_decay_3 = 4054;
	parameter [WIDTH - 1:0] threshold_3 = 11;
	parameter INPUT_SPIKE_4 = NEURON_3;
	parameter NEURON_4 = 16;
	parameter WEIGHTS_FILE_4 = "weights_4.txt";
	parameter [13:0] current_decay_4 = 0;
	parameter [13:0] voltage_decay_4 = 4055;
	parameter [WIDTH - 1:0] threshold_4 = 32767;
	parameter WEIGHT_DEPTH_12 = 8192;
	parameter WEIGHT_DEPTH_34 = 8192;
	input clk;
	input rst;
	input en;
	input [3:0] spike_in;
	input active_group_in;
	output wire valid;
	output wire valid_spike;
	output wire [3:0] spike_out;
	output wire integrated_neuron;
	input [7:0] weight_mem_L1_wren;
	function integer clogb2;
		input integer depth;
		for (clogb2 = 0; depth > 0; clogb2 = clogb2 + 1)
			depth = depth >> 1;
	endfunction
	input [clogb2(WEIGHT_DEPTH_12 - 1) - 1:0] weight_mem_L1_wr_addr;
	input [15:0] weight_mem_L1_data_in;
	output wire [15:0] weight_mem_L1_data_out;
	input weight_mem_L1_ena;
	input [7:0] weight_mem_L2_wren;
	input [clogb2(WEIGHT_DEPTH_12 - 1) - 1:0] weight_mem_L2_wr_addr;
	input [15:0] weight_mem_L2_data_in;
	output wire [15:0] weight_mem_L2_data_out;
	input weight_mem_L2_ena;
	input [7:0] weight_mem_L3_wren;
	input [clogb2(WEIGHT_DEPTH_34 - 1) - 1:0] weight_mem_L3_wr_addr;
	input [15:0] weight_mem_L3_data_in;
	output wire [15:0] weight_mem_L3_data_out;
	input weight_mem_L3_ena;
	input [7:0] weight_mem_L4_wren;
	input [clogb2(WEIGHT_DEPTH_34 - 1) - 1:0] weight_mem_L4_wr_addr;
	input [15:0] weight_mem_L4_data_in;
	output wire [15:0] weight_mem_L4_data_out;
	input weight_mem_L4_ena;
	output wire [7:0] o_spike_mem_dat;
	input wire [7:0] i_spike_mem_adr;
	input wire [1:0] i_spike_mem_rd_en;
	input wire [1:0] i_spike_mem_wr_en;
	input wire [3:0] i_spike_mem_dat;
	input wire [clogb2(MAX_SYNAPSES - 1) - 1:0] snn_input_channels;
	input wire [clogb2(MAX_NEURONS - 1) - 1:0] neuron_1;
	input wire [clogb2(MAX_NEURONS - 1) - 1:0] neuron_2;
	input wire [clogb2(MAX_NEURONS - 1) - 1:0] neuron_3;
	input wire [clogb2(MAX_NEURONS - 1) - 1:0] neuron_4;
	input wire [2:0] layers;
	input output_buffer_ren;
	input [7:0] output_buffer_addr;
	output wire [31:0] output_buffer_out;
	output wire output_buffer_wr_en_debug;
	output wire signed [WIDTH - 1:0] p1;
	output wire signed [WIDTH - 1:0] p2;
	input enb_debug;
	wire output_buffer_wr_en;
	assign output_buffer_wr_en_debug = output_buffer_wr_en;
	wire signed [WIDTH - 1:0] voltage_1;
	assign p1 = voltage_1;
	wire signed [WIDTH - 1:0] voltage_2;
	assign p2 = voltage_2;
	localparam LAYERS_LOG2 = clogb2(LAYERS - 1);
	localparam TOTAL_NEURONS = ((NEURON_1 + NEURON_2) + NEURON_3) + NEURON_4;
	localparam SYN_G1_L2 = clogb2((INPUT_SPIKE_1 / 4) - 1);
	localparam SYN_G2_L2 = clogb2((INPUT_SPIKE_2 / 4) - 1);
	localparam SYN_G3_L2 = clogb2((INPUT_SPIKE_3 / 4) - 1);
	localparam SYN_G4_L2 = clogb2((INPUT_SPIKE_4 / 4) - 1);
	function integer max4;
		input integer a;
		input integer b;
		input integer c;
		input integer d;
		max4 = ((a > b ? a : b) > (c > d ? c : d) ? (a > b ? a : b) : (c > d ? c : d));
	endfunction
	localparam MAX_LAYER = max4(INPUT_SPIKE_1 * NEURON_1, INPUT_SPIKE_2 * NEURON_2, INPUT_SPIKE_3 * NEURON_3, INPUT_SPIKE_4 * NEURON_4) / 8;
	localparam P1 = clogb2(MAX_LAYER) - clogb2((NEURON_1 * INPUT_SPIKE_1) / 8);
	localparam P2 = clogb2(MAX_LAYER) - clogb2((NEURON_2 * INPUT_SPIKE_2) / 8);
	localparam P3 = clogb2(MAX_LAYER) - clogb2((NEURON_3 * INPUT_SPIKE_3) / 8);
	localparam P4 = clogb2(MAX_LAYER) - clogb2((NEURON_4 * INPUT_SPIKE_4) / 8);
	localparam WEIGHT_ADDRESS_SIZE = (clogb2((MAX_NEURONS / 2) - 1) + clogb2((MAX_SYNAPSES / 4) - 1)) + clogb2(LAYERS - 1);
	wire v1;
	wire v2;
	wire [1:0] s1;
	wire [1:0] s2;
	wire ag1;
	wire ag2;
	wire convolution_valid;
	wire integrated_neuron_1;
	reg [LAYERS_LOG2 - 1:0] layer_counter;
	reg layer_enable_dd;
	wire [3:0] spike_mem_out;
	wire [WEIGHT_ADDRESS_SIZE - 1:0] weight_rd_addr;
	wire layer_integrated;
	wire convolution_pipe_full;
	layer_lp #(
		.WIDTH(WIDTH),
		.NEURON(TOTAL_NEURONS / 2),
		.LAYERS(LAYERS),
		.WEIGHTS_FILE_1(WEIGHTS_FILE_1),
		.WEIGHTS_FILE_2(WEIGHTS_FILE_2),
		.current_decay_1(current_decay_1),
		.current_decay_2(current_decay_2),
		.current_decay_3(current_decay_3),
		.current_decay_4(current_decay_4),
		.voltage_decay_1(voltage_decay_1),
		.voltage_decay_2(voltage_decay_2),
		.voltage_decay_3(voltage_decay_3),
		.voltage_decay_4(voltage_decay_4),
		.threshold_1(threshold_1),
		.threshold_2(threshold_2),
		.threshold_3(threshold_3),
		.threshold_4(threshold_4),
		.WEIGHT_DEPTH(2 ** WEIGHT_ADDRESS_SIZE)
	) layer_lp_l1_i(
		.clk(clk),
		.rst(rst),
		.en(layer_enable_dd),
		.spike_in(spike_mem_out),
		.active_group_in(),
		.weight_rd_addr(weight_rd_addr),
		.acc_clear(layer_integrated),
		.acc_clear_and_go(convolution_valid),
		.convolution_pipe_full(convolution_pipe_full),
		.layer_id(layer_counter),
		.valid(v1),
		.spike_out(s1),
		.active_group_out(ag1),
		.integrated_neuron(integrated_neuron_1),
		.neuron_lp_voltage(voltage_1),
		.weight_mem_L1_wren(weight_mem_L1_wren),
		.weight_mem_L1_wr_addr(weight_mem_L1_wr_addr),
		.weight_mem_L1_data_in(weight_mem_L1_data_in),
		.weight_mem_L1_data_out(weight_mem_L1_data_out),
		.weight_mem_L1_ena(weight_mem_L1_ena),
		.weight_mem_L2_wren(weight_mem_L2_wren),
		.weight_mem_L2_wr_addr(weight_mem_L2_wr_addr),
		.weight_mem_L2_data_in(weight_mem_L2_data_in),
		.weight_mem_L2_data_out(weight_mem_L2_data_out),
		.weight_mem_L2_ena(weight_mem_L2_ena),
		.enb_debug(enb_debug)
	);
	wire integrated_neuron_2;
	layer_lp #(
		.WIDTH(WIDTH),
		.NEURON(TOTAL_NEURONS / 2),
		.LAYERS(LAYERS),
		.WEIGHTS_FILE_1(WEIGHTS_FILE_3),
		.WEIGHTS_FILE_2(WEIGHTS_FILE_4),
		.current_decay_1(current_decay_1),
		.current_decay_2(current_decay_2),
		.current_decay_3(current_decay_3),
		.current_decay_4(current_decay_4),
		.voltage_decay_1(voltage_decay_1),
		.voltage_decay_2(voltage_decay_2),
		.voltage_decay_3(voltage_decay_3),
		.voltage_decay_4(voltage_decay_4),
		.threshold_1(threshold_1),
		.threshold_2(threshold_2),
		.threshold_3(threshold_3),
		.threshold_4(threshold_4),
		.WEIGHT_DEPTH(2 ** WEIGHT_ADDRESS_SIZE)
	) layer_lp_l2_i(
		.clk(clk),
		.rst(rst),
		.en(layer_enable_dd),
		.spike_in(spike_mem_out),
		.active_group_in(),
		.weight_rd_addr(weight_rd_addr),
		.acc_clear(layer_integrated),
		.acc_clear_and_go(convolution_valid),
		.convolution_pipe_full(convolution_pipe_full),
		.layer_id(layer_counter),
		.valid(v2),
		.spike_out(s2),
		.active_group_out(ag2),
		.neuron_lp_voltage(voltage_2),
		.integrated_neuron(integrated_neuron_2),
		.weight_mem_L1_wren(weight_mem_L3_wren),
		.weight_mem_L1_wr_addr(weight_mem_L3_wr_addr),
		.weight_mem_L1_data_in(weight_mem_L3_data_in),
		.weight_mem_L1_data_out(weight_mem_L3_data_out),
		.weight_mem_L1_ena(weight_mem_L3_ena),
		.weight_mem_L2_wren(weight_mem_L4_wren),
		.weight_mem_L2_wr_addr(weight_mem_L4_wr_addr),
		.weight_mem_L2_data_in(weight_mem_L4_data_in),
		.weight_mem_L2_data_out(weight_mem_L4_data_out),
		.weight_mem_L2_ena(weight_mem_L4_ena),
		.enb_debug(enb_debug)
	);
	wire [3:0] spike12;
	assign spike12 = {s1[1], s2[1], s1[0], s2[0]};
	wire valid12;
	assign valid12 = v1 && v2;
	assign spike_out = spike12;
	reg [clogb2((MAX_NEURONS / 2) - 1) - 1:0] neuron_cnt;
	reg [clogb2((MAX_SYNAPSES / 4) - 1) - 1:0] spike_wr_addr;
	reg spike_written;
	reg [clogb2(LAYERS - 1) - 1:0] spike_written_counter;
	wire [clogb2((MAX_SYNAPSES / 4) - 1) - 1:0] SYNAPSES;
	assign SYNAPSES = (spike_written_counter == 0 ? (INPUT_SPIKE_1 / 4) - 1 : (spike_written_counter == 1 ? (INPUT_SPIKE_2 / 4) - 1 : (spike_written_counter == 2 ? (INPUT_SPIKE_3 / 4) - 1 : (INPUT_SPIKE_4 / 4) - 1)));
	wire spike_cnt_en;
	assign spike_cnt_en = en | (v1 & (layer_counter != (LAYERS - 1)));
	always @(posedge clk)
		if (rst)
			spike_wr_addr <= 0;
		else if (spike_cnt_en) begin
			if (spike_wr_addr == SYNAPSES)
				spike_wr_addr <= 0;
			else
				spike_wr_addr <= spike_wr_addr + 1'b1;
		end
	always @(posedge clk)
		if (rst)
			spike_written <= 0;
		else if (spike_cnt_en && (spike_wr_addr == SYNAPSES))
			spike_written <= 1;
		else
			spike_written <= 0;
	always @(posedge clk)
		if (rst)
			spike_written_counter <= 0;
		else if (spike_written)
			spike_written_counter <= spike_written_counter + 1'b1;
	wire [clogb2((MAX_NEURONS / 2) - 1) - 1:0] NEURON;
	assign NEURON = (layer_counter == 0 ? (NEURON_1 / 2) - 1 : (layer_counter == 1 ? (NEURON_2 / 2) - 1 : (layer_counter == 2 ? (NEURON_3 / 2) - 1 : (NEURON_4 / 2) - 1)));
	wire stream_out_done;
	wire stream_out_done_1;
	wire stream_out_done_2;
	assign stream_out_done = stream_out_done_2 || stream_out_done_1;
	always @(posedge clk)
		if (rst)
			neuron_cnt <= 0;
		else if (stream_out_done) begin
			if (neuron_cnt < NEURON)
				neuron_cnt <= neuron_cnt + 1'b1;
			else
				neuron_cnt <= 0;
		end
	wire layer_dispatched;
	assign layer_dispatched = stream_out_done && (neuron_cnt == NEURON);
	wire inference_done;
	always @(posedge clk)
		if (rst)
			layer_counter <= 0;
		else if (layer_integrated) begin
			if (layer_counter < LAYERS)
				layer_counter = layer_counter + 1'b1;
		end
	assign inference_done = (layer_counter == LAYERS) && layer_integrated;
	reg layer_enable;
	reg layer_enable_d;
	wire stream_out_1;
	wire stream_out_2;
	always @(posedge clk)
		if (rst)
			layer_enable <= 0;
		else if (stream_out_1 | stream_out_2)
			layer_enable <= 1;
		else if (stream_out_done && (neuron_cnt == NEURON))
			layer_enable <= 0;
	always @(posedge clk)
		if (rst) begin
			layer_enable_d <= 0;
			layer_enable_dd <= 0;
		end
		else begin
			layer_enable_d <= layer_enable;
			layer_enable_dd <= layer_enable_d;
		end
	wire [clogb2((MAX_SYNAPSES / 4) - 1) - 1:0] words_to_read;
	wire [clogb2((MAX_SYNAPSES / 4) - 1) - 1:0] words_to_read_1;
	wire [clogb2((MAX_SYNAPSES / 4) - 1) - 1:0] words_to_read_2;
	assign words_to_read = (layer_counter[0] ? words_to_read_2 : words_to_read_1);
	reg [clogb2((MAX_SYNAPSES / 4) - 1) - 1:0] convolution_valid_cnt;
	always @(posedge clk)
		if (rst)
			convolution_valid_cnt <= 0;
		else if (convolution_pipe_full) begin
			if (convolution_valid_cnt < words_to_read)
				convolution_valid_cnt <= convolution_valid_cnt + 1'b1;
			else
				convolution_valid_cnt <= 0;
		end
	assign convolution_valid = (convolution_valid_cnt == words_to_read) && convolution_pipe_full;
	assign integrated_neuron = integrated_neuron_1;
	reg integrated_neuron_r;
	always @(posedge clk)
		if (rst)
			integrated_neuron_r <= integrated_neuron;
		else
			integrated_neuron_r <= integrated_neuron;
	reg [clogb2((MAX_NEURONS / 2) - 1) - 1:0] integrated_neurons_cnt;
	reg [clogb2((MAX_NEURONS / 2) - 1) - 1:0] integrated_neurons_cnt_d;
	always @(posedge clk)
		if (rst)
			integrated_neurons_cnt <= 0;
		else if (integrated_neuron) begin
			if (integrated_neurons_cnt < NEURON)
				integrated_neurons_cnt <= integrated_neurons_cnt + 1'b1;
			else
				integrated_neurons_cnt <= 0;
		end
	always @(posedge clk)
		if (rst)
			integrated_neurons_cnt_d <= 0;
		else
			integrated_neurons_cnt_d <= integrated_neurons_cnt;
	assign layer_integrated = integrated_neuron_r && (integrated_neurons_cnt_d == NEURON);
	wire empty;
	wire empty_1;
	wire empty_2;
	wire stack_en_1;
	assign stack_en_1 = (((v1 && v2) && (ag1 || ag2)) && layer_counter[0]) || (en & active_group_in);
	assign stream_out_1 = (spike_written && ~spike_written_counter[0]) || (stream_out_done_1 && (neuron_cnt != NEURON));
	wire [clogb2((MAX_SYNAPSES / 4) - 1) - 1:0] spike_rd_addr_1;
	stack #(
		.DATA_WIDTH(clogb2((MAX_SYNAPSES / 4) - 1)),
		.DEPTH(MAX_SYNAPSES / 4)
	) stack_1(
		.clk(clk),
		.rst(rst),
		.din(spike_wr_addr),
		.wr_en(stack_en_1),
		.clear(layer_integrated && ~layer_counter[0]),
		.stream_out(stream_out_1),
		.dout(spike_rd_addr_1),
		.done(stream_out_done_1),
		.active_entries(words_to_read_1),
		.empty(empty_1)
	);
	wire stack_en_2;
	assign stack_en_2 = ((v1 && v2) && (ag1 || ag2)) && ~layer_counter[0];
	assign stream_out_2 = (spike_written && spike_written_counter[0]) || (stream_out_done_2 && (neuron_cnt != NEURON));
	wire [clogb2((MAX_SYNAPSES / 4) - 1) - 1:0] spike_rd_addr_2;
	stack #(
		.DATA_WIDTH(clogb2((MAX_SYNAPSES / 4) - 1)),
		.DEPTH(MAX_SYNAPSES / 4)
	) stack_2(
		.clk(clk),
		.rst(rst),
		.din(spike_wr_addr),
		.wr_en(stack_en_2),
		.clear(layer_integrated && layer_counter[0]),
		.stream_out(stream_out_2),
		.dout(spike_rd_addr_2),
		.done(stream_out_done_2),
		.active_entries(words_to_read_2),
		.empty(empty_2)
	);
	wire [clogb2((MAX_SYNAPSES / 4) - 1) - 1:0] spike_rd_addr;
	assign spike_rd_addr = (layer_counter[0] ? spike_rd_addr_2 : spike_rd_addr_1);
	assign empty = (layer_counter[0] ? empty_2 : empty_1);
	wire [3:0] spike_mem_out_1;
	wire spike_wr_en_1;
	wire [3:0] spike_mem_out_2;
	wire spike_wr_en_2;
	assign spike_wr_en_1 = ((v1 && v2) && layer_counter[0]) || (en & active_group_in);
	assign spike_wr_en_2 = (v1 && v2) && ~layer_counter[0];
	wire [3:0] spike_mem_in_1;
	assign spike_mem_in_1 = (en ? spike_in : spike12);
	wire [clogb2((MAX_SYNAPSES / 4) - 1) - 1:0] spike_rd_addr_1_mux;
	wire [clogb2((MAX_SYNAPSES / 4) - 1) - 1:0] spike_rd_addr_2_mux;
	wire [clogb2((MAX_SYNAPSES / 4) - 1) - 1:0] spike_wr_addr_mux;
	assign spike_rd_addr_1_mux = (i_spike_mem_rd_en[0] ? i_spike_mem_adr : spike_rd_addr_1);
	assign spike_rd_addr_2_mux = (i_spike_mem_rd_en[1] ? i_spike_mem_adr : spike_rd_addr_2);
	assign o_spike_mem_dat = {spike_mem_out_2, spike_mem_out_1};
	assign spike_wr_addr_mux = spike_wr_addr;
	BRAM_singlePort_readFirst #(
		.RAM_WIDTH(4),
		.RAM_DEPTH(MAX_SYNAPSES / 4),
		.RAM_PERFORMANCE("HIGH_PERFORMANCE"),
		.INIT_FILE("")
	) spike_mem_1(
		.addra(spike_wr_addr_mux),
		.addrb(spike_rd_addr_1_mux),
		.dina(spike_mem_in_1),
		.clk(clk),
		.wea(spike_wr_en_1),
		.ena(spike_wr_en_1),
		.enb(1'b1),
		.rst(rst),
		.regceb(1'b1),
		.doutb(spike_mem_out_1)
	);
	BRAM_singlePort_readFirst #(
		.RAM_WIDTH(4),
		.RAM_DEPTH(MAX_SYNAPSES / 4),
		.RAM_PERFORMANCE("HIGH_PERFORMANCE"),
		.INIT_FILE("")
	) spike_mem_2(
		.addra(spike_wr_addr_mux),
		.addrb(spike_rd_addr_2_mux),
		.dina(spike12),
		.clk(clk),
		.wea(spike_wr_en_2),
		.ena(spike_wr_en_2),
		.enb(1'b1),
		.rst(rst),
		.regceb(1'b1),
		.doutb(spike_mem_out_2)
	);
	assign spike_mem_out = (empty ? 4'b0000 : (layer_counter[0] ? spike_mem_out_2 : spike_mem_out_1));
	assign weight_rd_addr = (layer_counter == 0 ? {layer_counter, {P1 {1'b0}}, neuron_cnt[clogb2((NEURON_1 / 2) - 1) - 1:0], spike_rd_addr[SYN_G1_L2 - 1:0]} : (layer_counter == 1 ? {layer_counter, {P2 {1'b0}}, neuron_cnt[clogb2((NEURON_2 / 2) - 1) - 1:0], spike_rd_addr[SYN_G2_L2 - 1:0]} : (layer_counter == 2 ? {layer_counter, {P3 {1'b0}}, neuron_cnt[clogb2((NEURON_3 / 2) - 1) - 1:0], spike_rd_addr[SYN_G3_L2 - 1:0]} : {layer_counter, {P4 {1'b0}}, neuron_cnt[clogb2((NEURON_4 / 2) - 1) - 1:0], spike_rd_addr[SYN_G4_L2 - 1:0]})));
	wire [31:0] output_buffer_din;
	assign output_buffer_wr_en = integrated_neuron && (layer_counter == 3);
	assign output_buffer_din = {voltage_2, voltage_1};
	ihp_single_port_256x48 #(
		.RAM_WIDTH(2 * WIDTH),
		.RAM_DEPTH(NEURON_4 / 2),
		.RAM_PERFORMANCE("LOW_LATENCY"),
		.INIT_FILE("")
	) output_buffer(
		.addra(integrated_neurons_cnt),
		.addrb(output_buffer_addr),
		.dina(output_buffer_din),
		.clk(clk),
		.wea(output_buffer_wr_en),
		.ena(output_buffer_wr_en),
		.enb(output_buffer_ren),
		.rst(rst),
		.regceb(1'b1),
		.doutb(output_buffer_out)
	);
	assign valid = (integrated_neuron_r && (integrated_neurons_cnt_d == NEURON)) && (layer_counter == (LAYERS - 1));
	assign valid_spike = valid12 && (layer_counter == (LAYERS - 1));
	function integer max;
		input integer j;
		input integer k;
		if (j > k)
			max = j;
	endfunction
endmodule
module Syntzulu (
	clk_enc,
	clk_snn,
	rst,
	en,
	data_in,
	detect,
	encoding_bypass,
	valid,
	v,
	f1,
	f2,
	f3,
	f4,
	neuron_lp_voltage,
	integrated_neuron,
	weight_mem_L1_wren,
	weight_mem_L1_wr_addr,
	weight_mem_L1_data_in,
	weight_mem_L1_data_out,
	weight_mem_L1_ena,
	weight_mem_L2_wren,
	weight_mem_L2_wr_addr,
	weight_mem_L2_data_in,
	weight_mem_L2_data_out,
	weight_mem_L2_ena,
	weight_mem_L3_wren,
	weight_mem_L3_wr_addr,
	weight_mem_L3_data_in,
	weight_mem_L3_data_out,
	weight_mem_L3_ena,
	weight_mem_L4_wren,
	weight_mem_L4_wr_addr,
	weight_mem_L4_data_in,
	weight_mem_L4_data_out,
	weight_mem_L4_ena,
	o_spike_mem_dat,
	i_spike_mem_adr,
	i_spike_mem_rd_en,
	i_spike_mem_wr_en,
	i_spike_mem_dat,
	o_sample_mem_dat,
	i_sample_mem_adr,
	i_sample_mem_rd_en,
	i_sample_mem_wr_en,
	i_sample_mem_dat,
	snn_input_channels,
	neuron_1,
	neuron_2,
	neuron_3,
	neuron_4,
	layers,
	output_buffer_ren,
	output_buffer_addr,
	output_buffer_out,
	output_buffer_wr_en_debug,
	p1,
	p2,
	enb_debug
);
	parameter ENCODING_BYPASS = 0;
	parameter CHANNELS = 16;
	parameter ORDER = 2;
	parameter WINDOW = 8192;
	parameter REF_PERIOD = 1024;
	parameter DW = 8;
	parameter WIDTH = 16;
	parameter MAX_SYNAPSES = 128;
	parameter MAX_NEURONS = 128;
	parameter LAYERS = 4;
	parameter INPUT_SPIKE_1 = 32;
	parameter NEURON_1 = 64;
	parameter WEIGHTS_FILE_1 = "weights_1.txt";
	parameter [13:0] current_decay_1 = 0;
	parameter [13:0] voltage_decay_1 = 4054;
	parameter [WIDTH - 1:0] threshold_1 = 19;
	parameter INPUT_SPIKE_2 = NEURON_1;
	parameter NEURON_2 = 128;
	parameter WEIGHTS_FILE_2 = "weights_2.txt";
	parameter [13:0] current_decay_2 = 0;
	parameter [13:0] voltage_decay_2 = 4054;
	parameter [WIDTH - 1:0] threshold_2 = 17;
	parameter INPUT_SPIKE_3 = NEURON_2;
	parameter NEURON_3 = 64;
	parameter WEIGHTS_FILE_3 = "weights_3.txt";
	parameter [13:0] current_decay_3 = 0;
	parameter [13:0] voltage_decay_3 = 4054;
	parameter [WIDTH - 1:0] threshold_3 = 11;
	parameter INPUT_SPIKE_4 = NEURON_3;
	parameter NEURON_4 = 16;
	parameter WEIGHTS_FILE_4 = "weights_4.txt";
	parameter [13:0] current_decay_4 = 0;
	parameter [13:0] voltage_decay_4 = 4055;
	parameter [WIDTH - 1:0] threshold_4 = 32767;
	parameter WEIGHT_DEPTH_12 = 8192;
	parameter WEIGHT_DEPTH_34 = 8192;
	input clk_enc;
	input clk_snn;
	input rst;
	input en;
	input signed [15:0] data_in;
	input detect;
	input encoding_bypass;
	output wire valid;
	output wire signed [WIDTH - 1:0] v;
	output wire signed [WIDTH - 1:0] f1;
	output wire signed [WIDTH - 1:0] f2;
	output wire signed [WIDTH - 1:0] f3;
	output wire signed [WIDTH - 1:0] f4;
	output wire signed [WIDTH - 1:0] neuron_lp_voltage;
	output wire integrated_neuron;
	input [7:0] weight_mem_L1_wren;
	function integer clogb2;
		input integer depth;
		for (clogb2 = 0; depth > 0; clogb2 = clogb2 + 1)
			depth = depth >> 1;
	endfunction
	input [clogb2(WEIGHT_DEPTH_12 - 1) - 1:0] weight_mem_L1_wr_addr;
	input [15:0] weight_mem_L1_data_in;
	output wire [15:0] weight_mem_L1_data_out;
	input weight_mem_L1_ena;
	input [7:0] weight_mem_L2_wren;
	input [clogb2(WEIGHT_DEPTH_12 - 1) - 1:0] weight_mem_L2_wr_addr;
	input [15:0] weight_mem_L2_data_in;
	output wire [15:0] weight_mem_L2_data_out;
	input weight_mem_L2_ena;
	input [7:0] weight_mem_L3_wren;
	input [clogb2(WEIGHT_DEPTH_34 - 1) - 1:0] weight_mem_L3_wr_addr;
	input [15:0] weight_mem_L3_data_in;
	output wire [15:0] weight_mem_L3_data_out;
	input weight_mem_L3_ena;
	input [7:0] weight_mem_L4_wren;
	input [clogb2(WEIGHT_DEPTH_34 - 1) - 1:0] weight_mem_L4_wr_addr;
	input [15:0] weight_mem_L4_data_in;
	output wire [15:0] weight_mem_L4_data_out;
	input weight_mem_L4_ena;
	output wire [7:0] o_spike_mem_dat;
	input wire [7:0] i_spike_mem_adr;
	input wire [1:0] i_spike_mem_rd_en;
	input wire [1:0] i_spike_mem_wr_en;
	input wire [3:0] i_spike_mem_dat;
	output wire [15:0] o_sample_mem_dat;
	input wire [7:0] i_sample_mem_adr;
	input wire i_sample_mem_rd_en;
	input wire i_sample_mem_wr_en;
	input wire [15:0] i_sample_mem_dat;
	input wire [clogb2(MAX_SYNAPSES - 1) - 1:0] snn_input_channels;
	input wire [clogb2(MAX_NEURONS - 1) - 1:0] neuron_1;
	input wire [clogb2(MAX_NEURONS - 1) - 1:0] neuron_2;
	input wire [clogb2(MAX_NEURONS - 1) - 1:0] neuron_3;
	input wire [clogb2(MAX_NEURONS - 1) - 1:0] neuron_4;
	input wire [2:0] layers;
	input output_buffer_ren;
	input [7:0] output_buffer_addr;
	output wire [31:0] output_buffer_out;
	output wire output_buffer_wr_en_debug;
	output wire signed [WIDTH - 1:0] p1;
	output wire signed [WIDTH - 1:0] p2;
	input enb_debug;
	localparam SPIKE = 4;
	wire [3:0] spike_bin;
	wire valid_bin;
	wire active_group_out_bin;
	wire valid_potential;
	encoding_slot #(
		.BYPASS(ENCODING_BYPASS),
		.CHANNELS(CHANNELS),
		.ORDER(ORDER),
		.WINDOW(WINDOW),
		.REF_PERIOD(REF_PERIOD),
		.DW(DW)
	) encoding_slot_i(
		.clk(clk_enc),
		.rst(rst),
		.en(en),
		.data_in(data_in),
		.detect(detect),
		.spike_bin(spike_bin),
		.valid_bin(valid_bin),
		.active_group_out_bin(active_group_out_bin),
		.inference_done(valid_potential),
		.o_sample_mem_dat(o_sample_mem_dat),
		.i_sample_mem_adr(i_sample_mem_adr),
		.i_sample_mem_rd_en(i_sample_mem_rd_en),
		.i_sample_mem_wr_en(i_sample_mem_wr_en),
		.i_sample_mem_dat(i_sample_mem_dat),
		.bypass(encoding_bypass),
		.enb_debug(enb_debug)
	);
	wire [3:0] spike_out_snn;
	wire valid_spike;
	snn_lp #(
		.WIDTH(WIDTH),
		.MAX_SYNAPSES(MAX_SYNAPSES),
		.MAX_NEURONS(MAX_SYNAPSES),
		.INPUT_SPIKE_1(INPUT_SPIKE_1),
		.NEURON_1(NEURON_1),
		.WEIGHTS_FILE_1(WEIGHTS_FILE_1),
		.current_decay_1(current_decay_1),
		.voltage_decay_1(voltage_decay_1),
		.threshold_1(threshold_1),
		.INPUT_SPIKE_2(INPUT_SPIKE_2),
		.NEURON_2(NEURON_2),
		.WEIGHTS_FILE_2(WEIGHTS_FILE_2),
		.current_decay_2(current_decay_2),
		.voltage_decay_2(voltage_decay_2),
		.threshold_2(threshold_2),
		.INPUT_SPIKE_3(INPUT_SPIKE_3),
		.NEURON_3(NEURON_3),
		.WEIGHTS_FILE_3(WEIGHTS_FILE_3),
		.current_decay_3(current_decay_3),
		.voltage_decay_3(voltage_decay_3),
		.threshold_3(threshold_3),
		.INPUT_SPIKE_4(INPUT_SPIKE_4),
		.NEURON_4(NEURON_4),
		.WEIGHTS_FILE_4(WEIGHTS_FILE_4),
		.current_decay_4(current_decay_4),
		.voltage_decay_4(voltage_decay_4),
		.threshold_4(threshold_4),
		.WEIGHT_DEPTH_12(WEIGHT_DEPTH_12),
		.WEIGHT_DEPTH_34(WEIGHT_DEPTH_34)
	) snn_lp_i(
		.clk(clk_snn),
		.rst(rst),
		.en(valid_bin),
		.spike_in(spike_bin),
		.active_group_in(active_group_out_bin),
		.valid(valid_potential),
		.valid_spike(valid_spike),
		.spike_out(spike_out_snn),
		.integrated_neuron(integrated_neuron),
		.weight_mem_L1_wren(weight_mem_L1_wren),
		.weight_mem_L1_wr_addr(weight_mem_L1_wr_addr),
		.weight_mem_L1_data_in(weight_mem_L1_data_in),
		.weight_mem_L1_data_out(weight_mem_L1_data_out),
		.weight_mem_L1_ena(weight_mem_L1_ena),
		.weight_mem_L2_wren(weight_mem_L2_wren),
		.weight_mem_L2_wr_addr(weight_mem_L2_wr_addr),
		.weight_mem_L2_data_in(weight_mem_L2_data_in),
		.weight_mem_L2_data_out(weight_mem_L2_data_out),
		.weight_mem_L2_ena(weight_mem_L2_ena),
		.weight_mem_L3_wren(weight_mem_L3_wren),
		.weight_mem_L3_wr_addr(weight_mem_L3_wr_addr),
		.weight_mem_L3_data_in(weight_mem_L3_data_in),
		.weight_mem_L3_data_out(weight_mem_L3_data_out),
		.weight_mem_L3_ena(weight_mem_L3_ena),
		.weight_mem_L4_wren(weight_mem_L4_wren),
		.weight_mem_L4_wr_addr(weight_mem_L4_wr_addr),
		.weight_mem_L4_data_in(weight_mem_L4_data_in),
		.weight_mem_L4_data_out(weight_mem_L4_data_out),
		.weight_mem_L4_ena(weight_mem_L4_ena),
		.o_spike_mem_dat(o_spike_mem_dat),
		.i_spike_mem_adr(i_spike_mem_adr),
		.i_spike_mem_rd_en(i_spike_mem_rd_en),
		.i_spike_mem_wr_en(i_spike_mem_wr_en),
		.i_spike_mem_dat(i_spike_mem_dat),
		.snn_input_channels(snn_input_channels),
		.neuron_1(neuron_1),
		.neuron_2(neuron_2),
		.neuron_3(neuron_3),
		.neuron_4(neuron_4),
		.layers(layers),
		.output_buffer_ren(output_buffer_ren),
		.output_buffer_addr(output_buffer_addr),
		.output_buffer_out(output_buffer_out),
		.output_buffer_wr_en_debug(output_buffer_wr_en_debug),
		.p1(p1),
		.p2(p2),
		.enb_debug(enb_debug)
	);
	assign valid = valid_potential;
endmodule
////////////////////////////////////////////////////////////////////////
//
// Copyright 2023 IHP PDK Authors
// 
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
// 
//    https://www.apache.org/licenses/LICENSE-2.0
// 
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
////////////////////////////////////////////////////////////////////////

`celldefine
module RM_IHPSG13_1P_1024x64_c2_bm_bist #(parameter INIT_FILE="") (
    A_CLK,
    A_MEN,
    A_WEN,
    A_REN,
    A_ADDR,
    A_DIN,
    A_DLY,
    A_DOUT,
    A_BM,
    A_BIST_CLK,
    A_BIST_EN,
    A_BIST_MEN,
    A_BIST_WEN,
    A_BIST_REN,
    A_BIST_ADDR,
    A_BIST_DIN,
    A_BIST_BM
);

    input A_CLK;
    input A_MEN;
    input A_WEN;
    input A_REN;
    input [9:0] A_ADDR;
    input [63:0] A_DIN;
    input A_DLY;
    output [63:0] A_DOUT;
    input [63:0] A_BM;
    input A_BIST_CLK;
    input A_BIST_EN;
    input A_BIST_MEN;
    input A_BIST_WEN;
    input A_BIST_REN;
    input [9:0] A_BIST_ADDR;
    input [63:0] A_BIST_DIN;
    input [63:0] A_BIST_BM;


`ifdef FUNCTIONAL  //  functional //


    SRAM_1P_behavioral_bm_bist #(
	.P_DATA_WIDTH(64),
	.P_ADDR_WIDTH(10),
	.INIT_FILE(INIT_FILE),
	.DEPTH(1024)
	) i_SRAM_1P_behavioral_bm_bist (
                    .A_CLK(A_CLK),
                    .A_MEN(A_MEN),
                    .A_WEN(A_WEN),
                    .A_REN(A_REN),
                    .A_ADDR(A_ADDR),
                    .A_DLY(A_DLY),
                    .A_DIN(A_DIN),
                    .A_DOUT(A_DOUT), 
                    .A_BM(A_BM), 
                    .A_BIST_CLK(A_BIST_CLK),
                    .A_BIST_EN(A_BIST_EN),
                    .A_BIST_MEN(A_BIST_MEN),
                    .A_BIST_WEN(A_BIST_WEN),
                    .A_BIST_REN(A_BIST_REN),
                    .A_BIST_ADDR(A_BIST_ADDR),
                    .A_BIST_DIN(A_BIST_DIN), 
                    .A_BIST_BM(A_BIST_BM)
		);

`else

    wire A_CLK_DELAY;
    wire A_MEN_DELAY;
    wire A_WEN_DELAY;
    wire A_REN_DELAY;
    wire [9:0] A_ADDR_DELAY;
    wire [63:0] A_DIN_DELAY;
    wire [63:0] A_BM_DELAY;
    wire A_BIST_CLK_DELAY;
    wire A_BIST_MEN_DELAY;
    wire A_BIST_WEN_DELAY;
    wire A_BIST_REN_DELAY;
    wire [9:0] A_BIST_ADDR_DELAY;
    wire [63:0] A_BIST_DIN_DELAY;
    wire [63:0] A_BIST_BM_DELAY;

    reg notifier;

    wire A_RW_ACCESS = (A_WEN || A_REN) && A_MEN;
    wire A_W_ACCESS  = A_WEN && A_MEN;
    wire A_BIST_RW_ACCESS = (A_BIST_WEN || A_BIST_REN) && A_BIST_MEN;
    wire A_BIST_W_ACCESS  = A_BIST_WEN && A_BIST_MEN;



    SRAM_1P_behavioral_bm_bist #(
	.P_DATA_WIDTH(64),
	.P_ADDR_WIDTH(10),
	.INIT_FILE(INIT_FILE),
	.DEPTH(1024)
	) i_SRAM_1P_behavioral_bm_bist (
                    .A_CLK(A_CLK_DELAY),
                    .A_MEN(A_MEN_DELAY),
                    .A_WEN(A_WEN_DELAY),
                    .A_REN(A_REN_DELAY),
                    .A_ADDR(A_ADDR_DELAY),
                    .A_DLY(A_DLY),
                    .A_DIN(A_DIN_DELAY),
                    .A_DOUT(A_DOUT), 
                    .A_BM(A_BM_DELAY), 
                    .A_BIST_CLK(A_BIST_CLK_DELAY),
                    .A_BIST_EN(A_BIST_EN),
                    .A_BIST_MEN(A_BIST_MEN_DELAY),
                    .A_BIST_WEN(A_BIST_WEN_DELAY),
                    .A_BIST_REN(A_BIST_REN_DELAY),
                    .A_BIST_ADDR(A_BIST_ADDR_DELAY),
                    .A_BIST_DIN(A_BIST_DIN_DELAY), 
                    .A_BIST_BM(A_BIST_BM_DELAY)
		);


    specify

      (posedge A_CLK *> (A_DOUT : A_DIN)) = (1.0, 1.0);
      $width(posedge A_CLK, 1.0,0,notifier);
      $setuphold(posedge A_CLK &&& A_MEN, posedge A_MEN, 1.0, 1.0,notifier,,,A_CLK_DELAY, A_MEN_DELAY);
      $setuphold(posedge A_CLK &&& A_MEN, posedge A_REN, 1.0, 1.0,notifier,,,A_CLK_DELAY, A_REN_DELAY);
      $setuphold(posedge A_CLK &&& A_MEN, posedge A_WEN, 1.0, 1.0,notifier,,,A_CLK_DELAY, A_WEN_DELAY);
      $setuphold(posedge A_CLK &&& A_MEN, negedge A_MEN, 1.0, 1.0,notifier,,,A_CLK_DELAY, A_MEN_DELAY);
      $setuphold(posedge A_CLK &&& A_MEN, negedge A_REN, 1.0, 1.0,notifier,,,A_CLK_DELAY, A_REN_DELAY);
      $setuphold(posedge A_CLK &&& A_MEN, negedge A_WEN, 1.0, 1.0,notifier,,,A_CLK_DELAY, A_WEN_DELAY);
      $setuphold(posedge A_CLK &&& A_RW_ACCESS, posedge A_ADDR, 1.0 ,1.0, notifier,,,A_CLK_DELAY, A_ADDR_DELAY);
      $setuphold(posedge A_CLK &&& A_RW_ACCESS, negedge A_ADDR, 1.0 ,1.0, notifier,,,A_CLK_DELAY, A_ADDR_DELAY);

      $setuphold(posedge A_CLK &&& A_W_ACCESS, posedge A_DIN, 1.0 ,1.0, notifier,,,A_CLK_DELAY, A_DIN_DELAY);
      $setuphold(posedge A_CLK &&& A_W_ACCESS, negedge A_DIN, 1.0 ,1.0, notifier,,,A_CLK_DELAY, A_DIN_DELAY);
      $setuphold(posedge A_CLK &&& A_W_ACCESS, posedge A_BM, 1.0 ,1.0, notifier,,,A_CLK_DELAY, A_BM_DELAY);
      $setuphold(posedge A_CLK &&& A_W_ACCESS, negedge A_BM, 1.0 ,1.0, notifier,,,A_CLK_DELAY, A_BM_DELAY);
      (posedge A_BIST_CLK *> (A_DOUT : A_BIST_DIN)) = (1.0, 1.0);
      $width(posedge A_BIST_CLK, 1.0,0,notifier);
      $setuphold(posedge A_BIST_CLK &&& A_BIST_MEN, posedge A_BIST_MEN, 1.0, 1.0,notifier,,,A_BIST_CLK_DELAY, A_BIST_MEN_DELAY);
      $setuphold(posedge A_BIST_CLK &&& A_BIST_MEN, posedge A_BIST_REN, 1.0, 1.0,notifier,,,A_BIST_CLK_DELAY, A_BIST_REN_DELAY);
      $setuphold(posedge A_BIST_CLK &&& A_BIST_MEN, posedge A_BIST_WEN, 1.0, 1.0,notifier,,,A_BIST_CLK_DELAY, A_BIST_WEN_DELAY);
      $setuphold(posedge A_BIST_CLK &&& A_BIST_MEN, negedge A_BIST_MEN, 1.0, 1.0,notifier,,,A_BIST_CLK_DELAY, A_BIST_MEN_DELAY);
      $setuphold(posedge A_BIST_CLK &&& A_BIST_MEN, negedge A_BIST_REN, 1.0, 1.0,notifier,,,A_BIST_CLK_DELAY, A_BIST_REN_DELAY);
      $setuphold(posedge A_BIST_CLK &&& A_BIST_MEN, negedge A_BIST_WEN, 1.0, 1.0,notifier,,,A_BIST_CLK_DELAY, A_BIST_WEN_DELAY);
      $setuphold(posedge A_BIST_CLK &&& A_BIST_RW_ACCESS, posedge A_BIST_ADDR, 1.0 ,1.0, notifier,,,A_BIST_CLK_DELAY, A_BIST_ADDR_DELAY);
      $setuphold(posedge A_BIST_CLK &&& A_BIST_RW_ACCESS, negedge A_BIST_ADDR, 1.0 ,1.0, notifier,,,A_BIST_CLK_DELAY, A_BIST_ADDR_DELAY);

      $setuphold(posedge A_BIST_CLK &&& A_BIST_W_ACCESS, posedge A_BIST_DIN, 1.0 ,1.0, notifier,,,A_BIST_CLK_DELAY, A_BIST_DIN_DELAY);
      $setuphold(posedge A_BIST_CLK &&& A_BIST_W_ACCESS, negedge A_BIST_DIN, 1.0 ,1.0, notifier,,,A_BIST_CLK_DELAY, A_BIST_DIN_DELAY);
      $setuphold(posedge A_BIST_CLK &&& A_BIST_W_ACCESS, posedge A_BIST_BM, 1.0 ,1.0, notifier,,,A_BIST_CLK_DELAY, A_BIST_BM_DELAY);
      $setuphold(posedge A_BIST_CLK &&& A_BIST_W_ACCESS, negedge A_BIST_BM, 1.0 ,1.0, notifier,,,A_BIST_CLK_DELAY, A_BIST_BM_DELAY);


    endspecify

`endif

endmodule
`endcelldefine
////////////////////////////////////////////////////////////////////////
//
// Copyright 2023 IHP PDK Authors
// 
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
// 
//    https://www.apache.org/licenses/LICENSE-2.0
// 
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
////////////////////////////////////////////////////////////////////////

`celldefine
module RM_IHPSG13_1P_2048x64_c2_bm_bist #(parameter INIT_FILE="") (
    A_CLK,
    A_MEN,
    A_WEN,
    A_REN,
    A_ADDR,
    A_DIN,
    A_DLY,
    A_DOUT,
    A_BM,
    A_BIST_CLK,
    A_BIST_EN,
    A_BIST_MEN,
    A_BIST_WEN,
    A_BIST_REN,
    A_BIST_ADDR,
    A_BIST_DIN,
    A_BIST_BM
);

    input A_CLK;
    input A_MEN;
    input A_WEN;
    input A_REN;
    input [10:0] A_ADDR;
    input [63:0] A_DIN;
    input A_DLY;
    output [63:0] A_DOUT;
    input [63:0] A_BM;
    input A_BIST_CLK;
    input A_BIST_EN;
    input A_BIST_MEN;
    input A_BIST_WEN;
    input A_BIST_REN;
    input [10:0] A_BIST_ADDR;
    input [63:0] A_BIST_DIN;
    input [63:0] A_BIST_BM;
    
`ifdef FUNCTIONAL  //  functional //


    SRAM_1P_behavioral_bm_bist #(
	.P_DATA_WIDTH(64),
	.P_ADDR_WIDTH(11),
	.INIT_FILE(INIT_FILE),
	.DEPTH(2048)
	) i_SRAM_1P_behavioral_bm_bist (
                    .A_CLK(A_CLK),
                    .A_MEN(A_MEN),
                    .A_WEN(A_WEN),
                    .A_REN(A_REN),
                    .A_ADDR(A_ADDR),
                    .A_DLY(A_DLY),
                    .A_DIN(A_DIN),
                    .A_DOUT(A_DOUT), 
                    .A_BM(A_BM), 
                    .A_BIST_CLK(A_BIST_CLK),
                    .A_BIST_EN(A_BIST_EN),
                    .A_BIST_MEN(A_BIST_MEN),
                    .A_BIST_WEN(A_BIST_WEN),
                    .A_BIST_REN(A_BIST_REN),
                    .A_BIST_ADDR(A_BIST_ADDR),
                    .A_BIST_DIN(A_BIST_DIN), 
                    .A_BIST_BM(A_BIST_BM)
		);

`else

    wire A_CLK_DELAY;
    wire A_MEN_DELAY;
    wire A_WEN_DELAY;
    wire A_REN_DELAY;
    wire [10:0] A_ADDR_DELAY;
    wire [63:0] A_DIN_DELAY;
    wire [63:0] A_BM_DELAY;
    wire A_BIST_CLK_DELAY;
    wire A_BIST_MEN_DELAY;
    wire A_BIST_WEN_DELAY;
    wire A_BIST_REN_DELAY;
    wire [10:0] A_BIST_ADDR_DELAY;
    wire [63:0] A_BIST_DIN_DELAY;
    wire [63:0] A_BIST_BM_DELAY;

    reg notifier;

    wire A_RW_ACCESS = (A_WEN || A_REN) && A_MEN;
    wire A_W_ACCESS  = A_WEN && A_MEN;
    wire A_BIST_RW_ACCESS = (A_BIST_WEN || A_BIST_REN) && A_BIST_MEN;
    wire A_BIST_W_ACCESS  = A_BIST_WEN && A_BIST_MEN;



    SRAM_1P_behavioral_bm_bist #(
	.P_DATA_WIDTH(64),
	.P_ADDR_WIDTH(11),
	.INIT_FILE(INIT_FILE),
	.DEPTH(2048)
	) i_SRAM_1P_behavioral_bm_bist (
                    .A_CLK(A_CLK_DELAY),
                    .A_MEN(A_MEN_DELAY),
                    .A_WEN(A_WEN_DELAY),
                    .A_REN(A_REN_DELAY),
                    .A_ADDR(A_ADDR_DELAY),
                    .A_DLY(A_DLY),
                    .A_DIN(A_DIN_DELAY),
                    .A_DOUT(A_DOUT), 
                    .A_BM(A_BM_DELAY), 
                    .A_BIST_CLK(A_BIST_CLK_DELAY),
                    .A_BIST_EN(A_BIST_EN),
                    .A_BIST_MEN(A_BIST_MEN_DELAY),
                    .A_BIST_WEN(A_BIST_WEN_DELAY),
                    .A_BIST_REN(A_BIST_REN_DELAY),
                    .A_BIST_ADDR(A_BIST_ADDR_DELAY),
                    .A_BIST_DIN(A_BIST_DIN_DELAY), 
                    .A_BIST_BM(A_BIST_BM_DELAY)
		);


    specify

      (posedge A_CLK *> (A_DOUT : A_DIN)) = (1.0, 1.0);
      $width(posedge A_CLK, 1.0,0,notifier);
      $setuphold(posedge A_CLK &&& A_MEN, posedge A_MEN, 1.0, 1.0,notifier,,,A_CLK_DELAY, A_MEN_DELAY);
      $setuphold(posedge A_CLK &&& A_MEN, posedge A_REN, 1.0, 1.0,notifier,,,A_CLK_DELAY, A_REN_DELAY);
      $setuphold(posedge A_CLK &&& A_MEN, posedge A_WEN, 1.0, 1.0,notifier,,,A_CLK_DELAY, A_WEN_DELAY);
      $setuphold(posedge A_CLK &&& A_MEN, negedge A_MEN, 1.0, 1.0,notifier,,,A_CLK_DELAY, A_MEN_DELAY);
      $setuphold(posedge A_CLK &&& A_MEN, negedge A_REN, 1.0, 1.0,notifier,,,A_CLK_DELAY, A_REN_DELAY);
      $setuphold(posedge A_CLK &&& A_MEN, negedge A_WEN, 1.0, 1.0,notifier,,,A_CLK_DELAY, A_WEN_DELAY);
      $setuphold(posedge A_CLK &&& A_RW_ACCESS, posedge A_ADDR, 1.0 ,1.0, notifier,,,A_CLK_DELAY, A_ADDR_DELAY);
      $setuphold(posedge A_CLK &&& A_RW_ACCESS, negedge A_ADDR, 1.0 ,1.0, notifier,,,A_CLK_DELAY, A_ADDR_DELAY);

      $setuphold(posedge A_CLK &&& A_W_ACCESS, posedge A_DIN, 1.0 ,1.0, notifier,,,A_CLK_DELAY, A_DIN_DELAY);
      $setuphold(posedge A_CLK &&& A_W_ACCESS, negedge A_DIN, 1.0 ,1.0, notifier,,,A_CLK_DELAY, A_DIN_DELAY);
      $setuphold(posedge A_CLK &&& A_W_ACCESS, posedge A_BM, 1.0 ,1.0, notifier,,,A_CLK_DELAY, A_BM_DELAY);
      $setuphold(posedge A_CLK &&& A_W_ACCESS, negedge A_BM, 1.0 ,1.0, notifier,,,A_CLK_DELAY, A_BM_DELAY);
      (posedge A_BIST_CLK *> (A_DOUT : A_BIST_DIN)) = (1.0, 1.0);
      $width(posedge A_BIST_CLK, 1.0,0,notifier);
      $setuphold(posedge A_BIST_CLK &&& A_BIST_MEN, posedge A_BIST_MEN, 1.0, 1.0,notifier,,,A_BIST_CLK_DELAY, A_BIST_MEN_DELAY);
      $setuphold(posedge A_BIST_CLK &&& A_BIST_MEN, posedge A_BIST_REN, 1.0, 1.0,notifier,,,A_BIST_CLK_DELAY, A_BIST_REN_DELAY);
      $setuphold(posedge A_BIST_CLK &&& A_BIST_MEN, posedge A_BIST_WEN, 1.0, 1.0,notifier,,,A_BIST_CLK_DELAY, A_BIST_WEN_DELAY);
      $setuphold(posedge A_BIST_CLK &&& A_BIST_MEN, negedge A_BIST_MEN, 1.0, 1.0,notifier,,,A_BIST_CLK_DELAY, A_BIST_MEN_DELAY);
      $setuphold(posedge A_BIST_CLK &&& A_BIST_MEN, negedge A_BIST_REN, 1.0, 1.0,notifier,,,A_BIST_CLK_DELAY, A_BIST_REN_DELAY);
      $setuphold(posedge A_BIST_CLK &&& A_BIST_MEN, negedge A_BIST_WEN, 1.0, 1.0,notifier,,,A_BIST_CLK_DELAY, A_BIST_WEN_DELAY);
      $setuphold(posedge A_BIST_CLK &&& A_BIST_RW_ACCESS, posedge A_BIST_ADDR, 1.0 ,1.0, notifier,,,A_BIST_CLK_DELAY, A_BIST_ADDR_DELAY);
      $setuphold(posedge A_BIST_CLK &&& A_BIST_RW_ACCESS, negedge A_BIST_ADDR, 1.0 ,1.0, notifier,,,A_BIST_CLK_DELAY, A_BIST_ADDR_DELAY);

      $setuphold(posedge A_BIST_CLK &&& A_BIST_W_ACCESS, posedge A_BIST_DIN, 1.0 ,1.0, notifier,,,A_BIST_CLK_DELAY, A_BIST_DIN_DELAY);
      $setuphold(posedge A_BIST_CLK &&& A_BIST_W_ACCESS, negedge A_BIST_DIN, 1.0 ,1.0, notifier,,,A_BIST_CLK_DELAY, A_BIST_DIN_DELAY);
      $setuphold(posedge A_BIST_CLK &&& A_BIST_W_ACCESS, posedge A_BIST_BM, 1.0 ,1.0, notifier,,,A_BIST_CLK_DELAY, A_BIST_BM_DELAY);
      $setuphold(posedge A_BIST_CLK &&& A_BIST_W_ACCESS, negedge A_BIST_BM, 1.0 ,1.0, notifier,,,A_BIST_CLK_DELAY, A_BIST_BM_DELAY);


    endspecify

`endif

endmodule
`endcelldefine
////////////////////////////////////////////////////////////////////////
//
// Copyright 2023 IHP PDK Authors
// 
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
// 
//    https://www.apache.org/licenses/LICENSE-2.0
// 
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
////////////////////////////////////////////////////////////////////////

`celldefine
module RM_IHPSG13_1P_256x48_c2_bm_bist #(parameter INIT_FILE="") (
    A_CLK,
    A_MEN,
    A_WEN,
    A_REN,
    A_ADDR,
    A_DIN,
    A_DLY,
    A_DOUT,
    A_BM,
    A_BIST_CLK,
    A_BIST_EN,
    A_BIST_MEN,
    A_BIST_WEN,
    A_BIST_REN,
    A_BIST_ADDR,
    A_BIST_DIN,
    A_BIST_BM
);

    input A_CLK;
    input A_MEN;
    input A_WEN;
    input A_REN;
    input [7:0] A_ADDR;
    input [47:0] A_DIN;
    input A_DLY;
    output [47:0] A_DOUT;
    input [47:0] A_BM;
    input A_BIST_CLK;
    input A_BIST_EN;
    input A_BIST_MEN;
    input A_BIST_WEN;
    input A_BIST_REN;
    input [7:0] A_BIST_ADDR;
    input [47:0] A_BIST_DIN;
    input [47:0] A_BIST_BM;
    
    wire [47:0] debug;
    assign debug = A_DIN;
    
    

`ifdef FUNCTIONAL  //  functional //

	
    SRAM_1P_behavioral_bm_bist #(
	.P_DATA_WIDTH(48),
	.P_ADDR_WIDTH(8),
	.INIT_FILE(INIT_FILE),
	.DEPTH(256)
	) i_SRAM_1P_behavioral_bm_bist (
                    .A_CLK(A_CLK),
                    .A_MEN(A_MEN),
                    .A_WEN(A_WEN),
                    .A_REN(A_REN),
                    .A_ADDR(A_ADDR),
                    .A_DLY(A_DLY),
                    .A_DIN(A_DIN),
                    .A_DOUT(A_DOUT), 
                    .A_BM(A_BM), 
                    .A_BIST_CLK(A_BIST_CLK),
                    .A_BIST_EN(A_BIST_EN),
                    .A_BIST_MEN(A_BIST_MEN),
                    .A_BIST_WEN(A_BIST_WEN),
                    .A_BIST_REN(A_BIST_REN),
                    .A_BIST_ADDR(A_BIST_ADDR),
                    .A_BIST_DIN(A_BIST_DIN), 
                    .A_BIST_BM(A_BIST_BM)
		);

`else

    wire A_CLK_DELAY;
    wire A_MEN_DELAY;
    wire A_WEN_DELAY;
    wire A_REN_DELAY;
    wire [7:0] A_ADDR_DELAY;
    wire [47:0] A_DIN_DELAY;
    wire [47:0] A_BM_DELAY;
    wire A_BIST_CLK_DELAY;
    wire A_BIST_MEN_DELAY;
    wire A_BIST_WEN_DELAY;
    wire A_BIST_REN_DELAY;
    wire [7:0] A_BIST_ADDR_DELAY;
    wire [47:0] A_BIST_DIN_DELAY;
    wire [47:0] A_BIST_BM_DELAY;

    reg notifier;

    wire A_RW_ACCESS = (A_WEN || A_REN) && A_MEN;
    wire A_W_ACCESS  = A_WEN && A_MEN;
    wire A_BIST_RW_ACCESS = (A_BIST_WEN || A_BIST_REN) && A_BIST_MEN;
    wire A_BIST_W_ACCESS  = A_BIST_WEN && A_BIST_MEN;



    SRAM_1P_behavioral_bm_bist #(
	.P_DATA_WIDTH(48),
	.P_ADDR_WIDTH(8),
	.INIT_FILE(INIT_FILE)
	) i_SRAM_1P_behavioral_bm_bist (
                    .A_CLK(A_CLK_DELAY),
                    .A_MEN(A_MEN_DELAY),
                    .A_WEN(A_WEN_DELAY),
                    .A_REN(A_REN_DELAY),
                    .A_ADDR(A_ADDR_DELAY),
                    .A_DLY(A_DLY),
                    .A_DIN(A_DIN_DELAY),
                    .A_DOUT(A_DOUT), 
                    .A_BM(A_BM_DELAY), 
                    .A_BIST_CLK(A_BIST_CLK_DELAY),
                    .A_BIST_EN(A_BIST_EN),
                    .A_BIST_MEN(A_BIST_MEN_DELAY),
                    .A_BIST_WEN(A_BIST_WEN_DELAY),
                    .A_BIST_REN(A_BIST_REN_DELAY),
                    .A_BIST_ADDR(A_BIST_ADDR_DELAY),
                    .A_BIST_DIN(A_BIST_DIN_DELAY), 
                    .A_BIST_BM(A_BIST_BM_DELAY)
		);


    specify

      (posedge A_CLK *> (A_DOUT : A_DIN)) = (1.0, 1.0);
      $width(posedge A_CLK, 1.0,0,notifier);
      $setuphold(posedge A_CLK &&& A_MEN, posedge A_MEN, 1.0, 1.0,notifier,,,A_CLK_DELAY, A_MEN_DELAY);
      $setuphold(posedge A_CLK &&& A_MEN, posedge A_REN, 1.0, 1.0,notifier,,,A_CLK_DELAY, A_REN_DELAY);
      $setuphold(posedge A_CLK &&& A_MEN, posedge A_WEN, 1.0, 1.0,notifier,,,A_CLK_DELAY, A_WEN_DELAY);
      $setuphold(posedge A_CLK &&& A_MEN, negedge A_MEN, 1.0, 1.0,notifier,,,A_CLK_DELAY, A_MEN_DELAY);
      $setuphold(posedge A_CLK &&& A_MEN, negedge A_REN, 1.0, 1.0,notifier,,,A_CLK_DELAY, A_REN_DELAY);
      $setuphold(posedge A_CLK &&& A_MEN, negedge A_WEN, 1.0, 1.0,notifier,,,A_CLK_DELAY, A_WEN_DELAY);
      $setuphold(posedge A_CLK &&& A_RW_ACCESS, posedge A_ADDR, 1.0 ,1.0, notifier,,,A_CLK_DELAY, A_ADDR_DELAY);
      $setuphold(posedge A_CLK &&& A_RW_ACCESS, negedge A_ADDR, 1.0 ,1.0, notifier,,,A_CLK_DELAY, A_ADDR_DELAY);

      $setuphold(posedge A_CLK &&& A_W_ACCESS, posedge A_DIN, 1.0 ,1.0, notifier,,,A_CLK_DELAY, A_DIN_DELAY);
      $setuphold(posedge A_CLK &&& A_W_ACCESS, negedge A_DIN, 1.0 ,1.0, notifier,,,A_CLK_DELAY, A_DIN_DELAY);
      $setuphold(posedge A_CLK &&& A_W_ACCESS, posedge A_BM, 1.0 ,1.0, notifier,,,A_CLK_DELAY, A_BM_DELAY);
      $setuphold(posedge A_CLK &&& A_W_ACCESS, negedge A_BM, 1.0 ,1.0, notifier,,,A_CLK_DELAY, A_BM_DELAY);
      (posedge A_BIST_CLK *> (A_DOUT : A_BIST_DIN)) = (1.0, 1.0);
      $width(posedge A_BIST_CLK, 1.0,0,notifier);
      $setuphold(posedge A_BIST_CLK &&& A_BIST_MEN, posedge A_BIST_MEN, 1.0, 1.0,notifier,,,A_BIST_CLK_DELAY, A_BIST_MEN_DELAY);
      $setuphold(posedge A_BIST_CLK &&& A_BIST_MEN, posedge A_BIST_REN, 1.0, 1.0,notifier,,,A_BIST_CLK_DELAY, A_BIST_REN_DELAY);
      $setuphold(posedge A_BIST_CLK &&& A_BIST_MEN, posedge A_BIST_WEN, 1.0, 1.0,notifier,,,A_BIST_CLK_DELAY, A_BIST_WEN_DELAY);
      $setuphold(posedge A_BIST_CLK &&& A_BIST_MEN, negedge A_BIST_MEN, 1.0, 1.0,notifier,,,A_BIST_CLK_DELAY, A_BIST_MEN_DELAY);
      $setuphold(posedge A_BIST_CLK &&& A_BIST_MEN, negedge A_BIST_REN, 1.0, 1.0,notifier,,,A_BIST_CLK_DELAY, A_BIST_REN_DELAY);
      $setuphold(posedge A_BIST_CLK &&& A_BIST_MEN, negedge A_BIST_WEN, 1.0, 1.0,notifier,,,A_BIST_CLK_DELAY, A_BIST_WEN_DELAY);
      $setuphold(posedge A_BIST_CLK &&& A_BIST_RW_ACCESS, posedge A_BIST_ADDR, 1.0 ,1.0, notifier,,,A_BIST_CLK_DELAY, A_BIST_ADDR_DELAY);
      $setuphold(posedge A_BIST_CLK &&& A_BIST_RW_ACCESS, negedge A_BIST_ADDR, 1.0 ,1.0, notifier,,,A_BIST_CLK_DELAY, A_BIST_ADDR_DELAY);

      $setuphold(posedge A_BIST_CLK &&& A_BIST_W_ACCESS, posedge A_BIST_DIN, 1.0 ,1.0, notifier,,,A_BIST_CLK_DELAY, A_BIST_DIN_DELAY);
      $setuphold(posedge A_BIST_CLK &&& A_BIST_W_ACCESS, negedge A_BIST_DIN, 1.0 ,1.0, notifier,,,A_BIST_CLK_DELAY, A_BIST_DIN_DELAY);
      $setuphold(posedge A_BIST_CLK &&& A_BIST_W_ACCESS, posedge A_BIST_BM, 1.0 ,1.0, notifier,,,A_BIST_CLK_DELAY, A_BIST_BM_DELAY);
      $setuphold(posedge A_BIST_CLK &&& A_BIST_W_ACCESS, negedge A_BIST_BM, 1.0 ,1.0, notifier,,,A_BIST_CLK_DELAY, A_BIST_BM_DELAY);


    endspecify

`endif

endmodule
`endcelldefine
////////////////////////////////////////////////////////////////////////
//
// Copyright 2023 IHP PDK Authors
// 
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
// 
//    https://www.apache.org/licenses/LICENSE-2.0
// 
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
////////////////////////////////////////////////////////////////////////

`celldefine
module RM_IHPSG13_1P_256x64_c2_bm_bist #(parameter INIT_FILE="") (
    A_CLK,
    A_MEN,
    A_WEN,
    A_REN,
    A_ADDR,
    A_DIN,
    A_DLY,
    A_DOUT,
    A_BM,
    A_BIST_CLK,
    A_BIST_EN,
    A_BIST_MEN,
    A_BIST_WEN,
    A_BIST_REN,
    A_BIST_ADDR,
    A_BIST_DIN,
    A_BIST_BM
);

    input A_CLK;
    input A_MEN;
    input A_WEN;
    input A_REN;
    input [7:0] A_ADDR;
    input [63:0] A_DIN;
    input A_DLY;
    output [63:0] A_DOUT;
    input [63:0] A_BM;
    input A_BIST_CLK;
    input A_BIST_EN;
    input A_BIST_MEN;
    input A_BIST_WEN;
    input A_BIST_REN;
    input [7:0] A_BIST_ADDR;
    input [63:0] A_BIST_DIN;
    input [63:0] A_BIST_BM;


`ifdef FUNCTIONAL  //  functional //


    SRAM_1P_behavioral_bm_bist #(
	.P_DATA_WIDTH(64),
	.P_ADDR_WIDTH(8),
	.INIT_FILE(INIT_FILE)
	) i_SRAM_1P_behavioral_bm_bist (
                    .A_CLK(A_CLK),
                    .A_MEN(A_MEN),
                    .A_WEN(A_WEN),
                    .A_REN(A_REN),
                    .A_ADDR(A_ADDR),
                    .A_DLY(A_DLY),
                    .A_DIN(A_DIN),
                    .A_DOUT(A_DOUT), 
                    .A_BM(A_BM), 
                    .A_BIST_CLK(A_BIST_CLK),
                    .A_BIST_EN(A_BIST_EN),
                    .A_BIST_MEN(A_BIST_MEN),
                    .A_BIST_WEN(A_BIST_WEN),
                    .A_BIST_REN(A_BIST_REN),
                    .A_BIST_ADDR(A_BIST_ADDR),
                    .A_BIST_DIN(A_BIST_DIN), 
                    .A_BIST_BM(A_BIST_BM)
		);

`else

    wire A_CLK_DELAY;
    wire A_MEN_DELAY;
    wire A_WEN_DELAY;
    wire A_REN_DELAY;
    wire [7:0] A_ADDR_DELAY;
    wire [63:0] A_DIN_DELAY;
    wire [63:0] A_BM_DELAY;
    wire A_BIST_CLK_DELAY;
    wire A_BIST_MEN_DELAY;
    wire A_BIST_WEN_DELAY;
    wire A_BIST_REN_DELAY;
    wire [7:0] A_BIST_ADDR_DELAY;
    wire [63:0] A_BIST_DIN_DELAY;
    wire [63:0] A_BIST_BM_DELAY;

    reg notifier;

    wire A_RW_ACCESS = (A_WEN || A_REN) && A_MEN;
    wire A_W_ACCESS  = A_WEN && A_MEN;
    wire A_BIST_RW_ACCESS = (A_BIST_WEN || A_BIST_REN) && A_BIST_MEN;
    wire A_BIST_W_ACCESS  = A_BIST_WEN && A_BIST_MEN;



    SRAM_1P_behavioral_bm_bist #(
	.P_DATA_WIDTH(64),
	.P_ADDR_WIDTH(8),
	.INIT_FILE(INIT_FILE)
	) i_SRAM_1P_behavioral_bm_bist (
                    .A_CLK(A_CLK_DELAY),
                    .A_MEN(A_MEN_DELAY),
                    .A_WEN(A_WEN_DELAY),
                    .A_REN(A_REN_DELAY),
                    .A_ADDR(A_ADDR_DELAY),
                    .A_DLY(A_DLY),
                    .A_DIN(A_DIN_DELAY),
                    .A_DOUT(A_DOUT), 
                    .A_BM(A_BM_DELAY), 
                    .A_BIST_CLK(A_BIST_CLK_DELAY),
                    .A_BIST_EN(A_BIST_EN),
                    .A_BIST_MEN(A_BIST_MEN_DELAY),
                    .A_BIST_WEN(A_BIST_WEN_DELAY),
                    .A_BIST_REN(A_BIST_REN_DELAY),
                    .A_BIST_ADDR(A_BIST_ADDR_DELAY),
                    .A_BIST_DIN(A_BIST_DIN_DELAY), 
                    .A_BIST_BM(A_BIST_BM_DELAY)
		);


    specify

      (posedge A_CLK *> (A_DOUT : A_DIN)) = (1.0, 1.0);
      $width(posedge A_CLK, 1.0,0,notifier);
      $setuphold(posedge A_CLK &&& A_MEN, posedge A_MEN, 1.0, 1.0,notifier,,,A_CLK_DELAY, A_MEN_DELAY);
      $setuphold(posedge A_CLK &&& A_MEN, posedge A_REN, 1.0, 1.0,notifier,,,A_CLK_DELAY, A_REN_DELAY);
      $setuphold(posedge A_CLK &&& A_MEN, posedge A_WEN, 1.0, 1.0,notifier,,,A_CLK_DELAY, A_WEN_DELAY);
      $setuphold(posedge A_CLK &&& A_MEN, negedge A_MEN, 1.0, 1.0,notifier,,,A_CLK_DELAY, A_MEN_DELAY);
      $setuphold(posedge A_CLK &&& A_MEN, negedge A_REN, 1.0, 1.0,notifier,,,A_CLK_DELAY, A_REN_DELAY);
      $setuphold(posedge A_CLK &&& A_MEN, negedge A_WEN, 1.0, 1.0,notifier,,,A_CLK_DELAY, A_WEN_DELAY);
      $setuphold(posedge A_CLK &&& A_RW_ACCESS, posedge A_ADDR, 1.0 ,1.0, notifier,,,A_CLK_DELAY, A_ADDR_DELAY);
      $setuphold(posedge A_CLK &&& A_RW_ACCESS, negedge A_ADDR, 1.0 ,1.0, notifier,,,A_CLK_DELAY, A_ADDR_DELAY);

      $setuphold(posedge A_CLK &&& A_W_ACCESS, posedge A_DIN, 1.0 ,1.0, notifier,,,A_CLK_DELAY, A_DIN_DELAY);
      $setuphold(posedge A_CLK &&& A_W_ACCESS, negedge A_DIN, 1.0 ,1.0, notifier,,,A_CLK_DELAY, A_DIN_DELAY);
      $setuphold(posedge A_CLK &&& A_W_ACCESS, posedge A_BM, 1.0 ,1.0, notifier,,,A_CLK_DELAY, A_BM_DELAY);
      $setuphold(posedge A_CLK &&& A_W_ACCESS, negedge A_BM, 1.0 ,1.0, notifier,,,A_CLK_DELAY, A_BM_DELAY);
      (posedge A_BIST_CLK *> (A_DOUT : A_BIST_DIN)) = (1.0, 1.0);
      $width(posedge A_BIST_CLK, 1.0,0,notifier);
      $setuphold(posedge A_BIST_CLK &&& A_BIST_MEN, posedge A_BIST_MEN, 1.0, 1.0,notifier,,,A_BIST_CLK_DELAY, A_BIST_MEN_DELAY);
      $setuphold(posedge A_BIST_CLK &&& A_BIST_MEN, posedge A_BIST_REN, 1.0, 1.0,notifier,,,A_BIST_CLK_DELAY, A_BIST_REN_DELAY);
      $setuphold(posedge A_BIST_CLK &&& A_BIST_MEN, posedge A_BIST_WEN, 1.0, 1.0,notifier,,,A_BIST_CLK_DELAY, A_BIST_WEN_DELAY);
      $setuphold(posedge A_BIST_CLK &&& A_BIST_MEN, negedge A_BIST_MEN, 1.0, 1.0,notifier,,,A_BIST_CLK_DELAY, A_BIST_MEN_DELAY);
      $setuphold(posedge A_BIST_CLK &&& A_BIST_MEN, negedge A_BIST_REN, 1.0, 1.0,notifier,,,A_BIST_CLK_DELAY, A_BIST_REN_DELAY);
      $setuphold(posedge A_BIST_CLK &&& A_BIST_MEN, negedge A_BIST_WEN, 1.0, 1.0,notifier,,,A_BIST_CLK_DELAY, A_BIST_WEN_DELAY);
      $setuphold(posedge A_BIST_CLK &&& A_BIST_RW_ACCESS, posedge A_BIST_ADDR, 1.0 ,1.0, notifier,,,A_BIST_CLK_DELAY, A_BIST_ADDR_DELAY);
      $setuphold(posedge A_BIST_CLK &&& A_BIST_RW_ACCESS, negedge A_BIST_ADDR, 1.0 ,1.0, notifier,,,A_BIST_CLK_DELAY, A_BIST_ADDR_DELAY);

      $setuphold(posedge A_BIST_CLK &&& A_BIST_W_ACCESS, posedge A_BIST_DIN, 1.0 ,1.0, notifier,,,A_BIST_CLK_DELAY, A_BIST_DIN_DELAY);
      $setuphold(posedge A_BIST_CLK &&& A_BIST_W_ACCESS, negedge A_BIST_DIN, 1.0 ,1.0, notifier,,,A_BIST_CLK_DELAY, A_BIST_DIN_DELAY);
      $setuphold(posedge A_BIST_CLK &&& A_BIST_W_ACCESS, posedge A_BIST_BM, 1.0 ,1.0, notifier,,,A_BIST_CLK_DELAY, A_BIST_BM_DELAY);
      $setuphold(posedge A_BIST_CLK &&& A_BIST_W_ACCESS, negedge A_BIST_BM, 1.0 ,1.0, notifier,,,A_BIST_CLK_DELAY, A_BIST_BM_DELAY);


    endspecify

`endif

endmodule
`endcelldefine
////////////////////////////////////////////////////////////////////////
//
// Copyright 2023 IHP PDK Authors
// 
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
// 
//    https://www.apache.org/licenses/LICENSE-2.0
// 
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
////////////////////////////////////////////////////////////////////////

`celldefine
module RM_IHPSG13_1P_512x64_c2_bm_bist (
    A_CLK,
    A_MEN,
    A_WEN,
    A_REN,
    A_ADDR,
    A_DIN,
    A_DLY,
    A_DOUT,
    A_BM,
    A_BIST_CLK,
    A_BIST_EN,
    A_BIST_MEN,
    A_BIST_WEN,
    A_BIST_REN,
    A_BIST_ADDR,
    A_BIST_DIN,
    A_BIST_BM
);

    input A_CLK;
    input A_MEN;
    input A_WEN;
    input A_REN;
    input [8:0] A_ADDR;
    input [63:0] A_DIN;
    input A_DLY;
    output [63:0] A_DOUT;
    input [63:0] A_BM;
    input A_BIST_CLK;
    input A_BIST_EN;
    input A_BIST_MEN;
    input A_BIST_WEN;
    input A_BIST_REN;
    input [8:0] A_BIST_ADDR;
    input [63:0] A_BIST_DIN;
    input [63:0] A_BIST_BM;


`ifdef FUNCTIONAL  //  functional //


    SRAM_1P_behavioral_bm_bist #(
	.P_DATA_WIDTH(64),
	.P_ADDR_WIDTH(9)
	) i_SRAM_1P_behavioral_bm_bist (
                    .A_CLK(A_CLK),
                    .A_MEN(A_MEN),
                    .A_WEN(A_WEN),
                    .A_REN(A_REN),
                    .A_ADDR(A_ADDR),
                    .A_DLY(A_DLY),
                    .A_DIN(A_DIN),
                    .A_DOUT(A_DOUT), 
                    .A_BM(A_BM), 
                    .A_BIST_CLK(A_BIST_CLK),
                    .A_BIST_EN(A_BIST_EN),
                    .A_BIST_MEN(A_BIST_MEN),
                    .A_BIST_WEN(A_BIST_WEN),
                    .A_BIST_REN(A_BIST_REN),
                    .A_BIST_ADDR(A_BIST_ADDR),
                    .A_BIST_DIN(A_BIST_DIN), 
                    .A_BIST_BM(A_BIST_BM)
		);

`else

    wire A_CLK_DELAY;
    wire A_MEN_DELAY;
    wire A_WEN_DELAY;
    wire A_REN_DELAY;
    wire [8:0] A_ADDR_DELAY;
    wire [63:0] A_DIN_DELAY;
    wire [63:0] A_BM_DELAY;
    wire A_BIST_CLK_DELAY;
    wire A_BIST_MEN_DELAY;
    wire A_BIST_WEN_DELAY;
    wire A_BIST_REN_DELAY;
    wire [8:0] A_BIST_ADDR_DELAY;
    wire [63:0] A_BIST_DIN_DELAY;
    wire [63:0] A_BIST_BM_DELAY;

    reg notifier;

    wire A_RW_ACCESS = (A_WEN || A_REN) && A_MEN;
    wire A_W_ACCESS  = A_WEN && A_MEN;
    wire A_BIST_RW_ACCESS = (A_BIST_WEN || A_BIST_REN) && A_BIST_MEN;
    wire A_BIST_W_ACCESS  = A_BIST_WEN && A_BIST_MEN;



    SRAM_1P_behavioral_bm_bist #(
	.P_DATA_WIDTH(64),
	.P_ADDR_WIDTH(9)
	) i_SRAM_1P_behavioral_bm_bist (
                    .A_CLK(A_CLK_DELAY),
                    .A_MEN(A_MEN_DELAY),
                    .A_WEN(A_WEN_DELAY),
                    .A_REN(A_REN_DELAY),
                    .A_ADDR(A_ADDR_DELAY),
                    .A_DLY(A_DLY),
                    .A_DIN(A_DIN_DELAY),
                    .A_DOUT(A_DOUT), 
                    .A_BM(A_BM_DELAY), 
                    .A_BIST_CLK(A_BIST_CLK_DELAY),
                    .A_BIST_EN(A_BIST_EN),
                    .A_BIST_MEN(A_BIST_MEN_DELAY),
                    .A_BIST_WEN(A_BIST_WEN_DELAY),
                    .A_BIST_REN(A_BIST_REN_DELAY),
                    .A_BIST_ADDR(A_BIST_ADDR_DELAY),
                    .A_BIST_DIN(A_BIST_DIN_DELAY), 
                    .A_BIST_BM(A_BIST_BM_DELAY)
		);


    specify

      (posedge A_CLK *> (A_DOUT : A_DIN)) = (1.0, 1.0);
      $width(posedge A_CLK, 1.0,0,notifier);
      $setuphold(posedge A_CLK &&& A_MEN, posedge A_MEN, 1.0, 1.0,notifier,,,A_CLK_DELAY, A_MEN_DELAY);
      $setuphold(posedge A_CLK &&& A_MEN, posedge A_REN, 1.0, 1.0,notifier,,,A_CLK_DELAY, A_REN_DELAY);
      $setuphold(posedge A_CLK &&& A_MEN, posedge A_WEN, 1.0, 1.0,notifier,,,A_CLK_DELAY, A_WEN_DELAY);
      $setuphold(posedge A_CLK &&& A_MEN, negedge A_MEN, 1.0, 1.0,notifier,,,A_CLK_DELAY, A_MEN_DELAY);
      $setuphold(posedge A_CLK &&& A_MEN, negedge A_REN, 1.0, 1.0,notifier,,,A_CLK_DELAY, A_REN_DELAY);
      $setuphold(posedge A_CLK &&& A_MEN, negedge A_WEN, 1.0, 1.0,notifier,,,A_CLK_DELAY, A_WEN_DELAY);
      $setuphold(posedge A_CLK &&& A_RW_ACCESS, posedge A_ADDR, 1.0 ,1.0, notifier,,,A_CLK_DELAY, A_ADDR_DELAY);
      $setuphold(posedge A_CLK &&& A_RW_ACCESS, negedge A_ADDR, 1.0 ,1.0, notifier,,,A_CLK_DELAY, A_ADDR_DELAY);

      $setuphold(posedge A_CLK &&& A_W_ACCESS, posedge A_DIN, 1.0 ,1.0, notifier,,,A_CLK_DELAY, A_DIN_DELAY);
      $setuphold(posedge A_CLK &&& A_W_ACCESS, negedge A_DIN, 1.0 ,1.0, notifier,,,A_CLK_DELAY, A_DIN_DELAY);
      $setuphold(posedge A_CLK &&& A_W_ACCESS, posedge A_BM, 1.0 ,1.0, notifier,,,A_CLK_DELAY, A_BM_DELAY);
      $setuphold(posedge A_CLK &&& A_W_ACCESS, negedge A_BM, 1.0 ,1.0, notifier,,,A_CLK_DELAY, A_BM_DELAY);
      (posedge A_BIST_CLK *> (A_DOUT : A_BIST_DIN)) = (1.0, 1.0);
      $width(posedge A_BIST_CLK, 1.0,0,notifier);
      $setuphold(posedge A_BIST_CLK &&& A_BIST_MEN, posedge A_BIST_MEN, 1.0, 1.0,notifier,,,A_BIST_CLK_DELAY, A_BIST_MEN_DELAY);
      $setuphold(posedge A_BIST_CLK &&& A_BIST_MEN, posedge A_BIST_REN, 1.0, 1.0,notifier,,,A_BIST_CLK_DELAY, A_BIST_REN_DELAY);
      $setuphold(posedge A_BIST_CLK &&& A_BIST_MEN, posedge A_BIST_WEN, 1.0, 1.0,notifier,,,A_BIST_CLK_DELAY, A_BIST_WEN_DELAY);
      $setuphold(posedge A_BIST_CLK &&& A_BIST_MEN, negedge A_BIST_MEN, 1.0, 1.0,notifier,,,A_BIST_CLK_DELAY, A_BIST_MEN_DELAY);
      $setuphold(posedge A_BIST_CLK &&& A_BIST_MEN, negedge A_BIST_REN, 1.0, 1.0,notifier,,,A_BIST_CLK_DELAY, A_BIST_REN_DELAY);
      $setuphold(posedge A_BIST_CLK &&& A_BIST_MEN, negedge A_BIST_WEN, 1.0, 1.0,notifier,,,A_BIST_CLK_DELAY, A_BIST_WEN_DELAY);
      $setuphold(posedge A_BIST_CLK &&& A_BIST_RW_ACCESS, posedge A_BIST_ADDR, 1.0 ,1.0, notifier,,,A_BIST_CLK_DELAY, A_BIST_ADDR_DELAY);
      $setuphold(posedge A_BIST_CLK &&& A_BIST_RW_ACCESS, negedge A_BIST_ADDR, 1.0 ,1.0, notifier,,,A_BIST_CLK_DELAY, A_BIST_ADDR_DELAY);

      $setuphold(posedge A_BIST_CLK &&& A_BIST_W_ACCESS, posedge A_BIST_DIN, 1.0 ,1.0, notifier,,,A_BIST_CLK_DELAY, A_BIST_DIN_DELAY);
      $setuphold(posedge A_BIST_CLK &&& A_BIST_W_ACCESS, negedge A_BIST_DIN, 1.0 ,1.0, notifier,,,A_BIST_CLK_DELAY, A_BIST_DIN_DELAY);
      $setuphold(posedge A_BIST_CLK &&& A_BIST_W_ACCESS, posedge A_BIST_BM, 1.0 ,1.0, notifier,,,A_BIST_CLK_DELAY, A_BIST_BM_DELAY);
      $setuphold(posedge A_BIST_CLK &&& A_BIST_W_ACCESS, negedge A_BIST_BM, 1.0 ,1.0, notifier,,,A_BIST_CLK_DELAY, A_BIST_BM_DELAY);


    endspecify

`endif

endmodule
`endcelldefine
////////////////////////////////////////////////////////////////////////
//
// Copyright 2023 IHP PDK Authors
// 
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
// 
//    https://www.apache.org/licenses/LICENSE-2.0
// 
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
////////////////////////////////////////////////////////////////////////

`celldefine
module RM_IHPSG13_1P_64x64_c2_bm_bist (
    A_CLK,
    A_MEN,
    A_WEN,
    A_REN,
    A_ADDR,
    A_DIN,
    A_DLY,
    A_DOUT,
    A_BM,
    A_BIST_CLK,
    A_BIST_EN,
    A_BIST_MEN,
    A_BIST_WEN,
    A_BIST_REN,
    A_BIST_ADDR,
    A_BIST_DIN,
    A_BIST_BM
);

    input A_CLK;
    input A_MEN;
    input A_WEN;
    input A_REN;
    input [5:0] A_ADDR;
    input [63:0] A_DIN;
    input A_DLY;
    output [63:0] A_DOUT;
    input [63:0] A_BM;
    input A_BIST_CLK;
    input A_BIST_EN;
    input A_BIST_MEN;
    input A_BIST_WEN;
    input A_BIST_REN;
    input [5:0] A_BIST_ADDR;
    input [63:0] A_BIST_DIN;
    input [63:0] A_BIST_BM;


`ifdef FUNCTIONAL  //  functional //


    SRAM_1P_behavioral_bm_bist #(
	.P_DATA_WIDTH(64),
	.P_ADDR_WIDTH(6)
	) i_SRAM_1P_behavioral_bm_bist (
                    .A_CLK(A_CLK),
                    .A_MEN(A_MEN),
                    .A_WEN(A_WEN),
                    .A_REN(A_REN),
                    .A_ADDR(A_ADDR),
                    .A_DLY(A_DLY),
                    .A_DIN(A_DIN),
                    .A_DOUT(A_DOUT), 
                    .A_BM(A_BM), 
                    .A_BIST_CLK(A_BIST_CLK),
                    .A_BIST_EN(A_BIST_EN),
                    .A_BIST_MEN(A_BIST_MEN),
                    .A_BIST_WEN(A_BIST_WEN),
                    .A_BIST_REN(A_BIST_REN),
                    .A_BIST_ADDR(A_BIST_ADDR),
                    .A_BIST_DIN(A_BIST_DIN), 
                    .A_BIST_BM(A_BIST_BM)
		);

`else

    wire A_CLK_DELAY;
    wire A_MEN_DELAY;
    wire A_WEN_DELAY;
    wire A_REN_DELAY;
    wire [5:0] A_ADDR_DELAY;
    wire [63:0] A_DIN_DELAY;
    wire [63:0] A_BM_DELAY;
    wire A_BIST_CLK_DELAY;
    wire A_BIST_MEN_DELAY;
    wire A_BIST_WEN_DELAY;
    wire A_BIST_REN_DELAY;
    wire [5:0] A_BIST_ADDR_DELAY;
    wire [63:0] A_BIST_DIN_DELAY;
    wire [63:0] A_BIST_BM_DELAY;

    reg notifier;

    wire A_RW_ACCESS = (A_WEN || A_REN) && A_MEN;
    wire A_W_ACCESS  = A_WEN && A_MEN;
    wire A_BIST_RW_ACCESS = (A_BIST_WEN || A_BIST_REN) && A_BIST_MEN;
    wire A_BIST_W_ACCESS  = A_BIST_WEN && A_BIST_MEN;



    SRAM_1P_behavioral_bm_bist #(
	.P_DATA_WIDTH(64),
	.P_ADDR_WIDTH(6)
	) i_SRAM_1P_behavioral_bm_bist (
                    .A_CLK(A_CLK_DELAY),
                    .A_MEN(A_MEN_DELAY),
                    .A_WEN(A_WEN_DELAY),
                    .A_REN(A_REN_DELAY),
                    .A_ADDR(A_ADDR_DELAY),
                    .A_DLY(A_DLY),
                    .A_DIN(A_DIN_DELAY),
                    .A_DOUT(A_DOUT), 
                    .A_BM(A_BM_DELAY), 
                    .A_BIST_CLK(A_BIST_CLK_DELAY),
                    .A_BIST_EN(A_BIST_EN),
                    .A_BIST_MEN(A_BIST_MEN_DELAY),
                    .A_BIST_WEN(A_BIST_WEN_DELAY),
                    .A_BIST_REN(A_BIST_REN_DELAY),
                    .A_BIST_ADDR(A_BIST_ADDR_DELAY),
                    .A_BIST_DIN(A_BIST_DIN_DELAY), 
                    .A_BIST_BM(A_BIST_BM_DELAY)
		);


    specify

      (posedge A_CLK *> (A_DOUT : A_DIN)) = (1.0, 1.0);
      $width(posedge A_CLK, 1.0,0,notifier);
      $setuphold(posedge A_CLK &&& A_MEN, posedge A_MEN, 1.0, 1.0,notifier,,,A_CLK_DELAY, A_MEN_DELAY);
      $setuphold(posedge A_CLK &&& A_MEN, posedge A_REN, 1.0, 1.0,notifier,,,A_CLK_DELAY, A_REN_DELAY);
      $setuphold(posedge A_CLK &&& A_MEN, posedge A_WEN, 1.0, 1.0,notifier,,,A_CLK_DELAY, A_WEN_DELAY);
      $setuphold(posedge A_CLK &&& A_MEN, negedge A_MEN, 1.0, 1.0,notifier,,,A_CLK_DELAY, A_MEN_DELAY);
      $setuphold(posedge A_CLK &&& A_MEN, negedge A_REN, 1.0, 1.0,notifier,,,A_CLK_DELAY, A_REN_DELAY);
      $setuphold(posedge A_CLK &&& A_MEN, negedge A_WEN, 1.0, 1.0,notifier,,,A_CLK_DELAY, A_WEN_DELAY);
      $setuphold(posedge A_CLK &&& A_RW_ACCESS, posedge A_ADDR, 1.0 ,1.0, notifier,,,A_CLK_DELAY, A_ADDR_DELAY);
      $setuphold(posedge A_CLK &&& A_RW_ACCESS, negedge A_ADDR, 1.0 ,1.0, notifier,,,A_CLK_DELAY, A_ADDR_DELAY);

      $setuphold(posedge A_CLK &&& A_W_ACCESS, posedge A_DIN, 1.0 ,1.0, notifier,,,A_CLK_DELAY, A_DIN_DELAY);
      $setuphold(posedge A_CLK &&& A_W_ACCESS, negedge A_DIN, 1.0 ,1.0, notifier,,,A_CLK_DELAY, A_DIN_DELAY);
      $setuphold(posedge A_CLK &&& A_W_ACCESS, posedge A_BM, 1.0 ,1.0, notifier,,,A_CLK_DELAY, A_BM_DELAY);
      $setuphold(posedge A_CLK &&& A_W_ACCESS, negedge A_BM, 1.0 ,1.0, notifier,,,A_CLK_DELAY, A_BM_DELAY);
      (posedge A_BIST_CLK *> (A_DOUT : A_BIST_DIN)) = (1.0, 1.0);
      $width(posedge A_BIST_CLK, 1.0,0,notifier);
      $setuphold(posedge A_BIST_CLK &&& A_BIST_MEN, posedge A_BIST_MEN, 1.0, 1.0,notifier,,,A_BIST_CLK_DELAY, A_BIST_MEN_DELAY);
      $setuphold(posedge A_BIST_CLK &&& A_BIST_MEN, posedge A_BIST_REN, 1.0, 1.0,notifier,,,A_BIST_CLK_DELAY, A_BIST_REN_DELAY);
      $setuphold(posedge A_BIST_CLK &&& A_BIST_MEN, posedge A_BIST_WEN, 1.0, 1.0,notifier,,,A_BIST_CLK_DELAY, A_BIST_WEN_DELAY);
      $setuphold(posedge A_BIST_CLK &&& A_BIST_MEN, negedge A_BIST_MEN, 1.0, 1.0,notifier,,,A_BIST_CLK_DELAY, A_BIST_MEN_DELAY);
      $setuphold(posedge A_BIST_CLK &&& A_BIST_MEN, negedge A_BIST_REN, 1.0, 1.0,notifier,,,A_BIST_CLK_DELAY, A_BIST_REN_DELAY);
      $setuphold(posedge A_BIST_CLK &&& A_BIST_MEN, negedge A_BIST_WEN, 1.0, 1.0,notifier,,,A_BIST_CLK_DELAY, A_BIST_WEN_DELAY);
      $setuphold(posedge A_BIST_CLK &&& A_BIST_RW_ACCESS, posedge A_BIST_ADDR, 1.0 ,1.0, notifier,,,A_BIST_CLK_DELAY, A_BIST_ADDR_DELAY);
      $setuphold(posedge A_BIST_CLK &&& A_BIST_RW_ACCESS, negedge A_BIST_ADDR, 1.0 ,1.0, notifier,,,A_BIST_CLK_DELAY, A_BIST_ADDR_DELAY);

      $setuphold(posedge A_BIST_CLK &&& A_BIST_W_ACCESS, posedge A_BIST_DIN, 1.0 ,1.0, notifier,,,A_BIST_CLK_DELAY, A_BIST_DIN_DELAY);
      $setuphold(posedge A_BIST_CLK &&& A_BIST_W_ACCESS, negedge A_BIST_DIN, 1.0 ,1.0, notifier,,,A_BIST_CLK_DELAY, A_BIST_DIN_DELAY);
      $setuphold(posedge A_BIST_CLK &&& A_BIST_W_ACCESS, posedge A_BIST_BM, 1.0 ,1.0, notifier,,,A_BIST_CLK_DELAY, A_BIST_BM_DELAY);
      $setuphold(posedge A_BIST_CLK &&& A_BIST_W_ACCESS, negedge A_BIST_BM, 1.0 ,1.0, notifier,,,A_BIST_CLK_DELAY, A_BIST_BM_DELAY);


    endspecify

`endif

endmodule
`endcelldefine
////////////////////////////////////////////////////////////////////////
//
// Copyright 2023 IHP PDK Authors
// 
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
// 
//    https://www.apache.org/licenses/LICENSE-2.0
// 
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
////////////////////////////////////////////////////////////////////////

//aggiunto da me, di default non lo aveva aggiunto

module SRAM_1P_behavioral_bm_bist (

                                A_ADDR,
                                A_DIN,
                                A_BM,
                                A_MEN,	// Memory enable input	-> if disabled, the memory is deactivated
                                A_WEN,	// Common write enable input (bytes maskable with BM[23:0])
                                A_REN,	// Read enable input ->  if enabled for read access when WEN=1 --> Write-through
                                A_CLK,	// Clock input
                                A_DLY,	// Delay selection signals
                                A_DOUT,

                                A_BIST_EN,
                                A_BIST_ADDR,
                                A_BIST_DIN,
                                A_BIST_BM,
                                A_BIST_MEN,
                                A_BIST_WEN,
                                A_BIST_REN,
                                A_BIST_CLK
                                
                                );

parameter  P_DATA_WIDTH=24;
parameter  P_ADDR_WIDTH=14;
parameter  DEPTH = 256;
parameter  INIT_FILE="";

input wire  [P_ADDR_WIDTH-1:0]	A_ADDR;
input wire  [P_DATA_WIDTH-1:0] 	A_DIN;
input wire  [P_DATA_WIDTH-1:0]	A_BM;	    // write bit mask, write enabled on bit [i] if BM[i]=1'b1
input wire                      A_MEN;	// Memory enable input	-> if disabled, the memory is deactivated
input wire                      A_WEN;	// Common write enable input (bytes maskable with BM[23:0])
input wire                      A_REN;	// Read enable input ->  if enabled for read access when WEN=1 --> Write-through
input wire                      A_CLK;	// Clock input
input wire                      A_DLY;	// Delay selection signals
output wire [P_DATA_WIDTH-1:0]  A_DOUT;	// 24 Data outputs

input wire                      A_BIST_EN;
input wire  [P_ADDR_WIDTH-1:0]	A_BIST_ADDR;
input wire  [P_DATA_WIDTH-1:0] 	A_BIST_DIN;
input wire  [P_DATA_WIDTH-1:0]	A_BIST_BM;
input wire                      A_BIST_MEN;
input wire                      A_BIST_WEN;
input wire                      A_BIST_REN;
input wire                      A_BIST_CLK;



//
// reg [P_DATA_WIDTH-1:0]    memory [0:2**(P_ADDR_WIDTH)-1]; // memory
// reg [P_DATA_WIDTH-1:0]    dr_r;
//
// wire [63:0] debug1, debug2, debug3;
// assign debug1 = memory[0];
// assign debug2 = memory[2048];
// assign debug3 = memory[3000];

wire  [P_ADDR_WIDTH-1:0]	ADDR_MUX;
wire  [P_DATA_WIDTH-1:0] 	DIN_MUX;
wire  [P_DATA_WIDTH-1:0]	BM_MUX;
wire                        MEN_MUX;
wire                        WEN_MUX;
wire                        REN_MUX;
wire                        CLK_MUX;

//BIST-MUX
assign ADDR_MUX =(A_BIST_EN==1'b1)? A_BIST_ADDR:A_ADDR;
assign DIN_MUX  =(A_BIST_EN==1'b1)? A_BIST_DIN :A_DIN;
assign BM_MUX   =(A_BIST_EN==1'b1)? A_BIST_BM  :A_BM;
assign MEN_MUX  =(A_BIST_EN==1'b1)? A_BIST_MEN :A_MEN;
assign WEN_MUX  =(A_BIST_EN==1'b1)? A_BIST_WEN :A_WEN;
assign REN_MUX  =(A_BIST_EN==1'b1)? A_BIST_REN :A_REN;
assign CLK_MUX  =(A_BIST_EN==1'b1)? A_BIST_CLK :A_CLK;

generate
    if (P_ADDR_WIDTH == 6 && P_DATA_WIDTH == 64) begin : gen_fakeram_64x64
        fakeram_64x64_1rw i_fakeram (
            .rw0_clk      (CLK_MUX),
            .rw0_ce_in    (MEN_MUX),
            .rw0_addr_in  (ADDR_MUX),
            .rw0_we_in    (WEN_MUX),
            .rw0_wd_in    (DIN_MUX),
            .rw0_wmask_in (BM_MUX),
            .rw0_rd_out   (A_DOUT)
        );
    end
    else if (P_ADDR_WIDTH == 8 && P_DATA_WIDTH == 48) begin : gen_fakeram_48x256
        fakeram_48x256_1rw i_fakeram (
            .rw0_clk      (CLK_MUX),
            .rw0_ce_in    (MEN_MUX),
            .rw0_addr_in  (ADDR_MUX),
            .rw0_we_in    (WEN_MUX),
            .rw0_wd_in    (DIN_MUX),
            .rw0_wmask_in (BM_MUX),
            .rw0_rd_out   (A_DOUT)
        );
    end
    else if (P_ADDR_WIDTH == 8 && P_DATA_WIDTH == 64) begin : gen_fakeram_64x256
        fakeram_64x256_1rw i_fakeram (
            .rw0_clk      (CLK_MUX),
            .rw0_ce_in    (MEN_MUX),
            .rw0_addr_in  (ADDR_MUX),
            .rw0_we_in    (WEN_MUX),
            .rw0_wd_in    (DIN_MUX),
            .rw0_wmask_in (BM_MUX),
            .rw0_rd_out   (A_DOUT)
        );
    end
    else if (P_ADDR_WIDTH == 9 && P_DATA_WIDTH == 64) begin : gen_fakeram_64x512
        fakeram_64x512_1rw i_fakeram (
            .rw0_clk      (CLK_MUX),
            .rw0_ce_in    (MEN_MUX),
            .rw0_addr_in  (ADDR_MUX),
            .rw0_we_in    (WEN_MUX),
            .rw0_wd_in    (DIN_MUX),
            .rw0_wmask_in (BM_MUX),
            .rw0_rd_out   (A_DOUT)
        );
    end
    else if (P_ADDR_WIDTH == 10 && P_DATA_WIDTH == 64) begin : gen_fakeram_64x1024
        fakeram_64x1024_1rw i_fakeram (
            .rw0_clk      (CLK_MUX),
            .rw0_ce_in    (MEN_MUX),
            .rw0_addr_in  (ADDR_MUX),
            .rw0_we_in    (WEN_MUX),
            .rw0_wd_in    (DIN_MUX),
            .rw0_wmask_in (BM_MUX),
            .rw0_rd_out   (A_DOUT)
        );
    end
    else if (P_ADDR_WIDTH == 11 && P_DATA_WIDTH == 64) begin : gen_fakeram_64x2048
        fakeram_64x2048_1rw i_fakeram (
            .rw0_clk      (CLK_MUX),
            .rw0_ce_in    (MEN_MUX),
            .rw0_addr_in  (ADDR_MUX),
            .rw0_we_in    (WEN_MUX),
            .rw0_wd_in    (DIN_MUX),
            .rw0_wmask_in (BM_MUX),
            .rw0_rd_out   (A_DOUT)
        );
    end
    else begin : gen_unsupported
        initial begin
            $error("SRAM_1P_behavioral_bm_bist: Unsupported configuration P_ADDR_WIDTH=%0d P_DATA_WIDTH=%0d",
                   P_ADDR_WIDTH, P_DATA_WIDTH);
            $fatal(1, "Unsupported SRAM configuration, aborting simulation.");
        end
    end
endgenerate


  // The following code either initializes the memory values to a specified file or to all zeros to match hardware
  // generate
  //   if (INIT_FILE != "") begin: use_init_file
  //     initial
  //       $readmemh(INIT_FILE, memory, 0, DEPTH-1);
  //   end else begin: init_bram_to_zero
  //     integer ram_index;
  //     initial
  //       for (ram_index = 0; ram_index < DEPTH; ram_index = ram_index + 1)
  //         memory[ram_index] = {P_DATA_WIDTH{1'b0}};
  //   end
  // endgenerate


//
// wire [63:0] debug200;
// wire [63:0] debug400;

// assign debug200 = memory[200];
// assign debug400 = memory[400];

endmodule
module ihp_dualport_256x48_dualmem #(
  parameter RAM_WIDTH = 4,                  
  parameter RAM_DEPTH = 64,                 
  parameter RAM_PERFORMANCE = "HIGH_PERFORMANCE", 
  parameter INIT_FILE = ""                       
)
(
  input [10:0] addra,  
  input [10:0] addrb,  
  input [31:0] dina,           
  input clk,                           
  input wea,                            
  input ena,                            
  input enb,                            
  input rst,                           
  input regceb,                         
  
  output reg [31:0] doutb                 
);


wire en_w;
assign en_w = ena && wea;

parameter R0_W1 = 0, WAIT_1 = 1, R1_W0 = 2, WAIT_2 = 3, INIT = 4;
reg [2:0] state, state_next;
wire NEXT;

always@(posedge clk) begin
	if(rst)
		state <= INIT;
	else
		state <= state_next;
end

always@(*) begin
	case(state)
		INIT:    state_next = NEXT ? R0_W1 : INIT;
		
		R0_W1:   state_next = NEXT ? WAIT_1 : R0_W1;
		WAIT_1:  state_next = R1_W0;
		R1_W0:   state_next = NEXT ? WAIT_2 : R1_W0;
		WAIT_2:  state_next = R0_W1;
		default: state_next = INIT;
	endcase
end

reg [5:0] control;
reg [9:0] AD_0, AD_1;
wire [31:0] DO_0, DO_1;

wire en_0, ren0, wren0, en_1, ren1, wren1;
assign {en_0, ren0, wren0, en_1, ren1, wren1} = control;

always@(*) begin
	case(state)
	
		INIT:    begin  control = {1'b0, 1'b0, 1'b0, en_w, 1'b0, en_w}; AD_0 = addrb; AD_1 = addra; doutb =  32'b0; end
			
		R0_W1:   begin  control = {enb, enb, 1'b0, en_w, 1'b0, en_w}; AD_0 = addrb; AD_1 = addra; doutb = DO_0; end
		WAIT_1:  begin  control = {enb, enb, 1'b0, en_w, 1'b0, en_w}; AD_0 = addrb; AD_1 = addra; doutb = DO_0; end
		
		R1_W0:   begin  control = {en_w, 1'b0, en_w, enb, enb, 1'b0}; AD_0 = addra; AD_1 = addrb; doutb = DO_1; end
		WAIT_2:  begin  control = {en_w, 1'b0, en_w, enb, enb, 1'b0}; AD_0 = addra; AD_1 = addrb; doutb = DO_1; end
		
		default: begin  control = {1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0}; AD_0 = 10'b0; AD_1 = 10'b0; doutb = 32'b0; end
	endcase
end




RM_IHPSG13_1P_256x48_c2_bm_bist mem0(
    .A_CLK(clk),
    .A_MEN(en_0),
    .A_WEN(wren0),
    .A_REN(ren0),
    .A_ADDR(AD_0),
    .A_DIN(dina),
    .A_DLY(1'b0),
    .A_DOUT(DO_0),
    .A_BM(48'hFFFFFFFFFFFF),
    
    
    .A_BIST_CLK(1'b0),
    .A_BIST_EN(1'b0),
    .A_BIST_MEN(1'b0),
    .A_BIST_WEN(1'b0),
    .A_BIST_REN(1'b0),
    .A_BIST_ADDR(1'b0),
    .A_BIST_DIN(1'b0),
    .A_BIST_BM(1'b0)
);

RM_IHPSG13_1P_256x48_c2_bm_bist mem1(
    .A_CLK(clk),
    .A_MEN(en_1),
    .A_WEN(wren1),
    .A_REN(ren1),
    .A_ADDR(AD_1),
    .A_DIN(dina),
    .A_DLY(1'b0),
    .A_DOUT(DO_1),
    .A_BM(48'hFFFFFFFFFFFF),
    
    
    .A_BIST_CLK(1'b0),
    .A_BIST_EN(1'b0),
    .A_BIST_MEN(1'b0),
    .A_BIST_WEN(1'b0),
    .A_BIST_REN(1'b0),
    .A_BIST_ADDR(1'b0),
    .A_BIST_DIN(1'b0),
    .A_BIST_BM(1'b0)
);

parameter IDLE = 0, WAIT = 1, FINISH = 2;
reg [1:0] state2, state2_next;

always@(posedge clk) begin
	if(rst) 
		state2 <= IDLE;
	else 
		state2 <= state2_next;
end 

always@(state, addra, addrb) begin
	case(state2)
		IDLE: state2_next = ((addra == 0) && (addrb == 0)) ? IDLE : WAIT;
		WAIT: state2_next = ((addra == 0) && (addrb == 0)) ? FINISH : WAIT;
		FINISH: state2_next = IDLE;
		default state2_next = IDLE;
	endcase
end

assign NEXT = (state2 == FINISH) ? 1 : 0;


endmodule

/*
  _______ ____  
 |__   __|  _ \ 
    | |  | |_) |
    | |  |  _ < 
    | |  | |_) |
    |_|  |____/ 
                
*/                



module ihp_dualport_256x48_dualmem_tb #(
  parameter RAM_WIDTH = 4,                  
  parameter RAM_DEPTH = 64,                 
  parameter RAM_PERFORMANCE = "HIGH_PERFORMANCE", 
  parameter INIT_FILE = ""                       
)
(
  input [10:0] addra,  
  input [10:0] addrb,  
  input [31:0] dina,           
  input clk,                           
  input wea,                            
  input ena,                            
  input enb,                            
  input rst,                           
  input regceb,                         
  
  output reg [31:0] doutb                 
);



assign en_w = ena && wea;

parameter R0_W1 = 0, WAIT_1 = 1, R1_W0 = 2, WAIT_2 = 3;
reg [1:0] state, state_next;
wire NEXT;

always@(posedge clk) begin
	if(rst)
		state <= R0_W1;
	else
		state <= state_next;
end

always@(*) begin
	case(state)
		R0_W1:   state_next = NEXT ? WAIT_1 : R0_W1;
		WAIT_1:  state_next = R1_W0;
		R1_W0:   state_next = NEXT ? WAIT_2 : R1_W0;
		WAIT_2:  state_next = R0_W1;
	endcase
end

reg [5:0] control;
reg [9:0] AD_0, AD_1;
wire [31:0] DO_0, DO_1;


wire en_0, ren0, wren0, en_1, ren1, wren1;
assign {en_0, ren0, wren0, en_1, ren1, wren1} = control;

always@(*) begin
	case(state)

		R0_W1:   begin  control = {enb, enb, 1'b0, en_w, 1'b0, en_w}; AD_0 = addrb; AD_1 = addra; doutb = DO_0; end
		WAIT_1:  begin  control = {enb, enb, 1'b0, en_w, 1'b0, en_w}; AD_0 = addrb; AD_1 = addra; doutb = DO_0; end
		
		R1_W0:   begin  control = {en_w, 1'b0, en_w, enb, enb, 1'b0}; AD_0 = addra; AD_1 = addrb; doutb = DO_1; end
		WAIT_2:  begin  control = {en_w, 1'b0, en_w, enb, enb, 1'b0}; AD_0 = addra; AD_1 = addrb; doutb = DO_1; end
		
	endcase
end




RM_IHPSG13_1P_256x48_c2_bm_bist #(.INIT_FILE(INIT_FILE)) mem0(
    .A_CLK(clk),
    .A_MEN(en_0),
    .A_WEN(wren0),
    .A_REN(ren0),
    .A_ADDR(AD_0),
    .A_DIN(dina),
    .A_DLY(1'b0),
    .A_DOUT(DO_0),
    .A_BM(48'hFFFFFFFFFFFF),
    
    
    .A_BIST_CLK(1'b0),
    .A_BIST_EN(1'b0),
    .A_BIST_MEN(1'b0),
    .A_BIST_WEN(1'b0),
    .A_BIST_REN(1'b0),
    .A_BIST_ADDR(1'b0),
    .A_BIST_DIN(1'b0),
    .A_BIST_BM(1'b0)
);

RM_IHPSG13_1P_256x48_c2_bm_bist mem1(
    .A_CLK(clk),
    .A_MEN(en_1),
    .A_WEN(wren1),
    .A_REN(ren1),
    .A_ADDR(AD_1),
    .A_DIN(dina),
    .A_DLY(1'b0),
    .A_DOUT(DO_1),
    .A_BM(48'hFFFFFFFFFFFF),
    
    
    .A_BIST_CLK(1'b0),
    .A_BIST_EN(1'b0),
    .A_BIST_MEN(1'b0),
    .A_BIST_WEN(1'b0),
    .A_BIST_REN(1'b0),
    .A_BIST_ADDR(1'b0),
    .A_BIST_DIN(1'b0),
    .A_BIST_BM(1'b0)
);

parameter IDLE = 0, WAIT = 1, FINISH = 2;
reg [1:0] state2, state2_next;

always@(posedge clk) begin
	if(rst) 
		state2 <= IDLE;
	else 
		state2 <= state2_next;
end 

always@(state, addra, addrb) begin
	case(state2)
		IDLE: state2_next = ((addra == 0) && (addrb == 0)) ? IDLE : WAIT;
		WAIT: state2_next = ((addra == 0) && (addrb == 0)) ? FINISH : WAIT;
		FINISH: state2_next = IDLE;
		default state2_next = IDLE;
	endcase
end

assign NEXT = (state2 == FINISH) ? 1 : 0;



endmodule





module ihp_ram # (parameter memfile="") 
(
	input wire clk,
	input wire [3:0] we,
	input wire [9:0] addr,
	input wire [63:0] dina,
	output wire [63:0] dout,
	input wire enb_debug	

);

	wire [31:0] BM;
	reg [7:0] B1, B2, B3, B4;


    wire wea;
    
	assign wea = (|we);
	//bitmask
	always @(posedge clk) begin
	    if (we[0]) B1 = 8'hFF; else B1 = 8'h00;
	    if (we[1]) B2 = 8'hFF; else B2 = 8'h00;
	    if (we[2]) B3 = 8'hFF; else B3 = 8'h00;
	    if (we[3]) B4 = 8'hFF; else B4 = 8'h00;
	end
	
	assign BM = wea ? {32'hFFFFFFFF, B4, B3, B2, B1} : 32'hFFFFFFFF;



`ifdef SIM
RM_IHPSG13_1P_1024x64_c2_bm_bist #(.INIT_FILE(memfile)) ram(
    .A_CLK(clk),
    
    .A_MEN(enb_debug),
    .A_WEN(wea),
    .A_REN(enb_debug),
    
    .A_ADDR(addr),
    .A_DIN(dina),
    .A_DLY(1'b0),
    .A_DOUT(dout),
    .A_BM(BM),
    
    
    .A_BIST_CLK(1'b0),
    .A_BIST_EN(1'b0),
    .A_BIST_MEN(1'b0),
    .A_BIST_WEN(1'b0),
    .A_BIST_REN(1'b0),
    .A_BIST_ADDR(1'b0),
    .A_BIST_DIN(1'b0),
    .A_BIST_BM(1'b0)
);


`else

RM_IHPSG13_1P_1024x64_c2_bm_bist  ram(

    .A_CLK(clk),
    
    .A_MEN(enb_debug),
    .A_WEN(wea),
    .A_REN(enb_debug),
    
    .A_ADDR(addr),
    .A_DIN(dina),
    .A_DLY(1'b0),
    .A_DOUT(dout),
    .A_BM(BM),
    
    
    .A_BIST_CLK(1'b0),
    .A_BIST_EN(1'b0),
    .A_BIST_MEN(1'b0),
    .A_BIST_WEN(1'b0),
    .A_BIST_REN(1'b0),
    .A_BIST_ADDR(1'b0),
    .A_BIST_DIN(1'b0),
    .A_BIST_BM(1'b0)
    
);

`endif		
		
	

endmodule
module ihp_single_port_256x48 #(
  parameter RAM_WIDTH = 4,                  
  parameter RAM_DEPTH = 64,                 
  parameter RAM_PERFORMANCE = "HIGH_PERFORMANCE", 
  parameter INIT_FILE = ""                       
)
(
  input [7:0] addra,  
  input [7:0] addrb,  
  input [47:0] dina,           
  input clk,                           
  input wea,                            
  input ena,                            
  input enb,                            
  input rst,                           
  input regceb,                         
  
  output [47:0] doutb                 
);

wire MEN;
wire WEN;
wire REN;

assign MEN = ena || enb ;
assign WEN = ena || wea ;
assign REN = enb ;

wire [7:0] ADDR;
assign ADDR = WEN ? addra : addrb;

wire [47:0] ram_data_b;

`ifdef SIM
RM_IHPSG13_1P_256x48_c2_bm_bist #(.INIT_FILE(INIT_FILE)) single_port(
    .A_CLK(clk),
    .A_MEN(MEN),
    .A_WEN(WEN),
    .A_REN(REN),
    .A_ADDR(ADDR),
    .A_DIN(dina),
    .A_DLY(1'b0),
    .A_DOUT(ram_data_b),
    .A_BM(48'hFFFFFFFFFFFF),
    
    
    .A_BIST_CLK(1'b0),
    .A_BIST_EN(1'b0),
    .A_BIST_MEN(1'b0),
    .A_BIST_WEN(1'b0),
    .A_BIST_REN(1'b0),
    .A_BIST_ADDR(1'b0),
    .A_BIST_DIN(1'b0),
    .A_BIST_BM(1'b0)
);


`else

RM_IHPSG13_1P_256x48_c2_bm_bist single_port(
    .A_CLK(clk),
    .A_MEN(MEN),
    .A_WEN(WEN),
    .A_REN(REN),
    .A_ADDR(ADDR),
    .A_DIN(dina),
    .A_DLY(1'b0),
    .A_DOUT(ram_data_b),
    .A_BM(48'hFFFFFFFFFFFF),
    
    
    .A_BIST_CLK(1'b0),
    .A_BIST_EN(1'b0),
    .A_BIST_MEN(1'b0),
    .A_BIST_WEN(1'b0),
    .A_BIST_REN(1'b0),
    .A_BIST_ADDR(1'b0),
    .A_BIST_DIN(1'b0),
    .A_BIST_BM(1'b0)
);

`endif



  //  The following code generates HIGH_PERFORMANCE (use output register) or LOW_LATENCY (no output register)
  generate
    if (RAM_PERFORMANCE == "LOW_LATENCY") begin: no_output_register

      // The following is a 1 clock cycle read latency at the cost of a longer clock-to-out timing
       assign doutb = ram_data_b;

    end else begin: output_register

      // The following is a 2 clock cycle read latency with improve clock-to-out timing

      reg [RAM_WIDTH-1:0] doutb_reg = {RAM_WIDTH{1'b0}};

      always @(posedge clk)
        if (rst)
          doutb_reg <= {RAM_WIDTH{1'b0}};
        else if (regceb)
          doutb_reg <= ram_data_b;

      assign doutb = doutb_reg;

    end
  endgenerate

endmodule

module ihp_single_port_256x64 #(
  parameter RAM_WIDTH = 4,                  
  parameter RAM_DEPTH = 64,                 
  parameter RAM_PERFORMANCE = "HIGH_PERFORMANCE", 
  parameter INIT_FILE = ""                       
)
(
  input [7:0] addra,  
  input [7:0] addrb,  
  input [63:0] dina,           
  input clk,                           
  input wea,                            
  input ena,                            
  input enb,                            
  input rst,                           
  input regceb,                         
  
  output [63:0] doutb                 
);


assign MEN = ena || enb ;
assign WEN = ena || wea ;
assign REN = enb ;

wire [7:0] ADDR;
assign ADDR = WEN ? addra : addrb;

wire [47:0] ram_data_b;

`ifdef SIM
RM_IHPSG13_1P_256x64_c2_bm_bist #(.INIT_FILE(INIT_FILE)) single_port(
    .A_CLK(clk),
    .A_MEN(MEN),
    .A_WEN(WEN),
    .A_REN(REN),
    .A_ADDR(ADDR),
    .A_DIN(dina),
    .A_DLY(1'b0),
    .A_DOUT(ram_data_b),
    .A_BM(64'hFFFFFFFFFFFFFFFF),
    
    
    .A_BIST_CLK(1'b0),
    .A_BIST_EN(1'b0),
    .A_BIST_MEN(1'b0),
    .A_BIST_WEN(1'b0),
    .A_BIST_REN(1'b0),
    .A_BIST_ADDR(1'b0),
    .A_BIST_DIN(1'b0),
    .A_BIST_BM(1'b0)
);


`else

RM_IHPSG13_1P_256x64_c2_bm_bist single_port(
    .A_CLK(clk),
    .A_MEN(MEN),
    .A_WEN(WEN),
    .A_REN(REN),
    .A_ADDR(ADDR),
    .A_DIN(dina),
    .A_DLY(1'b0),
    .A_DOUT(ram_data_b),
    .A_BM(64'hFFFFFFFFFFFFFFFF),
    
    
    .A_BIST_CLK(1'b0),
    .A_BIST_EN(1'b0),
    .A_BIST_MEN(1'b0),
    .A_BIST_WEN(1'b0),
    .A_BIST_REN(1'b0),
    .A_BIST_ADDR(1'b0),
    .A_BIST_DIN(1'b0),
    .A_BIST_BM(1'b0)
);

`endif



  //  The following code generates HIGH_PERFORMANCE (use output register) or LOW_LATENCY (no output register)
  generate
    if (RAM_PERFORMANCE == "LOW_LATENCY") begin: no_output_register

      // The following is a 1 clock cycle read latency at the cost of a longer clock-to-out timing
       assign doutb = ram_data_b;

    end else begin: output_register

      // The following is a 2 clock cycle read latency with improve clock-to-out timing

      reg [RAM_WIDTH-1:0] doutb_reg = {RAM_WIDTH{1'b0}};

      always @(posedge clk)
        if (rst)
          doutb_reg <= {RAM_WIDTH{1'b0}};
        else if (regceb)
          doutb_reg <= ram_data_b;

      assign doutb = doutb_reg;

    end
  endgenerate

endmodule



















module weights_mem_ihp #(
    parameter RAM_DEPTH = 4096,
    parameter RAM_WIDTH = 32,
    parameter INIT_FILE = ""
)
(
  input [11:0] addra1,   
  input [15:0] dina1,
  input ena1,
  input wea1,
  
  input [11:0] addra2,
  input [15:0] dina2,  
  input ena2, 
  input wea2,
  
  input [11:0] addrb,         
  input clk,                                                      
  input enb,                            
  input rst,                           
  input regceb,                         
  
  output reg [31:0] doutb                   
    );
    
    wire [31:0] doutb_tmp;
    wire A_MEN;
    wire A_WEN;
    wire A_REN;
    reg  [10:0] A_ADDR;
    reg  [63:0] A_BM;
    wire [63:0] A_DOUT;
    reg  [63:0] A_DIN;
    
    assign A_MEN  = ena1 || ena2 || enb ;
    assign A_WEN  = ena1 || ena2;
    assign A_REN  = enb;
    
    assign doutb_tmp = addrb[11] ? A_DOUT[63:32] : A_DOUT[31:0];
    
    
    //MASCHERA
    always@(*) begin 
       	
    	if(ena1) begin   		
    		if (addra1[11]) begin 
    			A_BM = 64'hFFFF000000000000;
    			A_DIN = {dina1, 48'h000000000000}; end
    		else begin
    			A_BM = 64'h00000000FFFF0000;
    			A_DIN = {32'h000000000000, dina1, 16'h0000}; end
    	end		
    				
    	else if (ena2) begin
    		if (addra2[11]) begin
    			A_BM = 64'h0000FFFF00000000;
    			A_DIN = {16'h0000, dina2, 32'h00000000}; end
    		else begin
    			A_BM = 64'h000000000000FFFF;
    			A_DIN = {48'h000000000000, dina2}; end
    	end
    	
    	else begin
    			A_BM  = 64'h0000000000000000;
    			A_DIN = 64'h0000000000000000; end		
         
    end
    
    //INDIRIZZO
    always@(*) begin    	
    	if(ena1)   		
		A_ADDR = addra1[10:0];
		
    	else if(ena2)
    		A_ADDR = addra2[10:0];
    		
    	else 
    		A_ADDR = addrb[10:0];
    end    
    


	RM_IHPSG13_1P_2048x64_c2_bm_bist mem(
	    .A_CLK(clk),
	    .A_MEN(A_MEN),		//Memory enable, activates memory for read/write.
	    .A_WEN(A_WEN),		//Write enable, triggers write operation to memory.
	    .A_REN(A_REN),		//Read enable, triggers read operation from memory.
	    .A_ADDR(A_ADDR),
	    .A_DIN(A_DIN),
	    .A_DLY(1'b0),		//Delay control, possibly for timing adjustments.
	    .A_DOUT(A_DOUT),
	    .A_BM(A_BM),
	    .A_BIST_CLK(1'b0),
	    .A_BIST_EN(1'b0),
	    .A_BIST_MEN(1'b0),
	    .A_BIST_WEN(1'b0),
	    .A_BIST_REN(1'b0),
	    .A_BIST_ADDR(1'b0),
	    .A_BIST_DIN(1'b0),
	    .A_BIST_BM(1'b0)
	);
	

always@(posedge clk) begin
	if(rst) 
		doutb <= 0;
	else
		doutb <= doutb_tmp;
end



endmodule




module weights_mem_ihp_qc #(
    parameter RAM_DEPTH = 4096,
    parameter RAM_WIDTH = 32,
    parameter INIT_FILE = ""
)
(
  input [10:0] addra1,   
  input [15:0] dina1,
  input ena1,
  input wea1,
  
  input [10:0] addrb,         
  input clk,                                                      
  input enb,                            
  input rst,                           
  input regceb,                         
  
  output reg [31:0] doutb                   
);
    
    wire [31:0] doutb_tmp;
    wire A_MEN;
    wire A_WEN;
    wire A_REN;
    reg  [10:0] A_ADDR;
    reg  [63:0] A_BM;
    wire [63:0] A_DOUT;
    reg  [63:0] A_DIN;
    
    assign A_MEN  = ena1 || enb ;
    assign A_WEN  = ena1;
    assign A_REN  = enb;
    
    assign doutb_tmp = addrb[10] ? A_DOUT[63:32] : A_DOUT[31:0];
    
    
    //MASCHERA
    always@(*) begin 
       	
    	if(ena1) begin   		
    		if (addra1[10]) begin 
    			A_BM = 64'hFFFF000000000000;
    			A_DIN = {dina1, 48'h000000000000}; end
    		else begin
    			A_BM = 64'h00000000FFFF0000;
    			A_DIN = {32'h000000000000, dina1, 16'h0000}; end
    	end    	
    	else begin
    			A_BM  = 64'h0000000000000000;
    			A_DIN = 64'h0000000000000000; end		     
    end
    
    //INDIRIZZO
    always@(*) begin    	
    	if(ena1)   		
		A_ADDR = addra1[9:0];
    	else 
    		A_ADDR = addrb[9:0];
    end    
    
`ifdef SIM

	RM_IHPSG13_1P_1024x64_c2_bm_bist #(.INIT_FILE(INIT_FILE)) mem(
	    .A_CLK(clk),
	    .A_MEN(A_MEN),		//Memory enable, activates memory for read/write.
	    .A_WEN(A_WEN),		//Write enable, triggers write operation to memory.
	    .A_REN(A_REN),		//Read enable, triggers read operation from memory.
	    .A_ADDR(A_ADDR),
	    .A_DIN(A_DIN),
	    .A_DLY(1'b0),		//Delay control, possibly for timing adjustments.
	    .A_DOUT(A_DOUT),
	    .A_BM(A_BM),
	    .A_BIST_CLK(1'b0),
	    .A_BIST_EN(1'b0),
	    .A_BIST_MEN(1'b0),
	    .A_BIST_WEN(1'b0),
	    .A_BIST_REN(1'b0),
	    .A_BIST_ADDR(1'b0),
	    .A_BIST_DIN(1'b0),
	    .A_BIST_BM(1'b0)
	);
`else	
	RM_IHPSG13_1P_1024x64_c2_bm_bist mem(
	    .A_CLK(clk),
	    .A_MEN(A_MEN),		//Memory enable, activates memory for read/write.
	    .A_WEN(A_WEN),		//Write enable, triggers write operation to memory.
	    .A_REN(A_REN),		//Read enable, triggers read operation from memory.
	    .A_ADDR(A_ADDR),
	    .A_DIN(A_DIN),
	    .A_DLY(1'b0),		//Delay control, possibly for timing adjustments.
	    .A_DOUT(A_DOUT),
	    .A_BM(A_BM),
	    .A_BIST_CLK(1'b0),
	    .A_BIST_EN(1'b0),
	    .A_BIST_MEN(1'b0),
	    .A_BIST_WEN(1'b0),
	    .A_BIST_REN(1'b0),
	    .A_BIST_ADDR(1'b0),
	    .A_BIST_DIN(1'b0),
	    .A_BIST_BM(1'b0)
	);


`endif

always@(posedge clk) begin
	if(rst) 
		doutb <= 0;
	else
		doutb <= doutb_tmp;
end



endmodule


module weights_mem_ihp_qc_2048x64 #(
    parameter RAM_DEPTH = 4096,
    parameter RAM_WIDTH = 32,
    parameter INIT_FILE = ""
)
(
  input [10:0] addra1,   
  input [15:0] dina1,
  input ena1,
  input wea1,
  
  input [10:0] addrb,         
  input clk,                                                      
  input enb,                            
  input rst,                           
  input regceb,                         
  
  output reg [63:0] doutb                   
);
    
    //wire [31:0] doutb_tmp;
    wire A_MEN;
    wire A_WEN;
    wire A_REN;
    //reg  [10:0] A_ADDR;
    //reg  [63:0] A_BM;
    wire [63:0] A_DOUT;
    reg  [63:0] A_DIN;
    
    assign A_MEN  = ena1 || enb ;
    assign A_WEN  = ena1;
    assign A_REN  = enb;
      
    
`ifdef SIM

	RM_IHPSG13_1P_2048x64_c2_bm_bist #(.INIT_FILE(INIT_FILE)) mem(
	    .A_CLK(clk),
	    .A_MEN(A_MEN),		//Memory enable, activates memory for read/write.
	    .A_WEN(A_WEN),		//Write enable, triggers write operation to memory.
	    .A_REN(A_REN),		//Read enable, triggers read operation from memory.
	    .A_ADDR(addrb),
	    .A_DIN(A_DIN),
	    .A_DLY(1'b0),		//Delay control, possibly for timing adjustments.
	    .A_DOUT(A_DOUT),
	    .A_BM(64'hFFFFFFFFFFFFFFFF),
	    .A_BIST_CLK(1'b0),
	    .A_BIST_EN(1'b0),
	    .A_BIST_MEN(1'b0),
	    .A_BIST_WEN(1'b0),
	    .A_BIST_REN(1'b0),
	    .A_BIST_ADDR(1'b0),
	    .A_BIST_DIN(1'b0),
	    .A_BIST_BM(1'b0)
	);
`else	
	RM_IHPSG13_1P_2048x64_c2_bm_bist mem(
	    .A_CLK(clk),
	    .A_MEN(A_MEN),		//Memory enable, activates memory for read/write.
	    .A_WEN(A_WEN),		//Write enable, triggers write operation to memory.
	    .A_REN(A_REN),		//Read enable, triggers read operation from memory.
	    .A_ADDR(addrb),
	    .A_DIN(A_DIN),
	    .A_DLY(1'b0),		//Delay control, possibly for timing adjustments.
	    .A_DOUT(A_DOUT),
	    .A_BM(64'hFFFFFFFFFFFFFFFF),
	    .A_BIST_CLK(1'b0),
	    .A_BIST_EN(1'b0),
	    .A_BIST_MEN(1'b0),
	    .A_BIST_WEN(1'b0),
	    .A_BIST_REN(1'b0),
	    .A_BIST_ADDR(1'b0),
	    .A_BIST_DIN(1'b0),
	    .A_BIST_BM(1'b0)
	);


`endif

always@(posedge clk) begin
	if(rst) 
		doutb <= 0;
	else
		doutb <= A_DOUT;
end



endmodule



module serv_aligner 
   (
    input wire clk,
    input wire rst,
    // serv_top
    input  wire [31:0]  i_ibus_adr,
    input  wire         i_ibus_cyc,
    output wire [31:0]  o_ibus_rdt,
    output wire         o_ibus_ack,
    // serv_rf_top
    output wire [31:0]  o_wb_ibus_adr,
    output wire         o_wb_ibus_cyc,
    input  wire [31:0]  i_wb_ibus_rdt,
    input  wire         i_wb_ibus_ack);

    wire [31:0] ibus_rdt_concat;
    wire        ack_en;
    
    reg  [15:0] lower_hw;    
    reg         ctrl_misal ; 

    /* From SERV core to Memory

    o_wb_ibus_adr: Carries address of instruction to memory. In case of misaligned access, 
    which is caused by pc+2 due to compressed instruction, next instruction is fetched 
    by pc+4 and concatenation is done to make the instruction aligned.

    o_wb_ibus_cyc: Simply forwarded from SERV to Memory and is only altered by memory or SERV core.
    */
    assign o_wb_ibus_adr = ctrl_misal ? (i_ibus_adr+32'b100) : i_ibus_adr;
    assign o_wb_ibus_cyc = i_ibus_cyc;

    /* From Memory to SERV core

        o_ibus_ack: Instruction bus acknowledge is send to SERV only when the aligned instruction,
        either compressed or un-compressed, is ready to dispatch.

        o_ibus_rdt: Carries the instruction from memory to SERV core. It can be either aligned
        instruction coming from memory or made aligned by two bus transactions and concatenation.
    */
    assign o_ibus_ack = i_wb_ibus_ack & ack_en;
    assign o_ibus_rdt = ctrl_misal ? ibus_rdt_concat : i_wb_ibus_rdt;

    /* 16-bit register used to hold the upper half word of the current instruction in-case
       concatenation will be required with the upper half word of upcoming instruction
    */        
    always @(posedge clk) begin
        if(i_wb_ibus_ack)begin
            lower_hw <= i_wb_ibus_rdt[31:16];
        end
    end

    assign ibus_rdt_concat = {i_wb_ibus_rdt[15:0],lower_hw};
    
    /* Two control signals: ack_en, ctrl_misal are set to control the bus transactions between
    SERV core and the memory
    */
    assign ack_en   = !(i_ibus_adr[1] & !ctrl_misal); 

    always @(posedge clk ) begin
        if(rst)
            ctrl_misal <= 0;
        else if(i_wb_ibus_ack & i_ibus_adr[1])
            ctrl_misal <= !ctrl_misal;
    end

endmodule
`default_nettype none
module serv_alu
  (
   input wire 	    clk,
   //State
   input wire 	    i_en,
   input wire 	    i_cnt0,
   output wire 	    o_cmp,
   //Control
   input wire 	    i_sub,
   input wire [1:0] i_bool_op,
   input wire 	    i_cmp_eq,
   input wire 	    i_cmp_sig,
   input wire [2:0] i_rd_sel,
   //Data
   input wire 	    i_rs1,
   input wire 	    i_op_b,
   input wire 	    i_buf,
   output wire 	    o_rd);

   wire        result_add;

   reg 	       cmp_r;

   wire        add_cy;
   reg 	       add_cy_r;

   //Sign-extended operands
   wire rs1_sx  = i_rs1 & i_cmp_sig;
   wire op_b_sx = i_op_b  & i_cmp_sig;

   wire add_b = i_op_b^i_sub;

   assign {add_cy,result_add}   = i_rs1+add_b+add_cy_r;

   wire result_lt = rs1_sx + ~op_b_sx + add_cy;

   wire result_eq = !result_add & (cmp_r | i_cnt0);

   assign o_cmp = i_cmp_eq ? result_eq : result_lt;

   /*
    The result_bool expression implements the following operations between
    i_rs1 and i_op_b depending on the value of i_bool_op

    00 xor
    01 0
    10 or
    11 and

    i_bool_op will be 01 during shift operations, so by outputting zero under
    this condition we can safely or result_bool with i_buf
    */
   wire result_bool = ((i_rs1 ^ i_op_b) & ~ i_bool_op[0]) | (i_bool_op[1] & i_op_b & i_rs1);

   assign o_rd = i_buf |
                 (i_rd_sel[0] & result_add) |
                 (i_rd_sel[1] & cmp_r & i_cnt0) |
                 (i_rd_sel[2] & result_bool);

   always @(posedge clk) begin
      add_cy_r <= i_en ? add_cy : i_sub;

      if (i_en)
	cmp_r <= o_cmp;
   end

endmodule
module serv_bufreg #(
      parameter [0:0] MDU = 0
)(
   input wire 	      i_clk,
   //State
   input wire 	      i_cnt0,
   input wire 	      i_cnt1,
   input wire 	      i_en,
   input wire 	      i_init,
   input wire           i_mdu_op,
   output wire [1:0]    o_lsb,
   //Control
   input wire 	      i_rs1_en,
   input wire 	      i_imm_en,
   input wire 	      i_clr_lsb,
   input wire 	      i_sh_signed, 
   //Data
   input wire 	      i_rs1,
   input wire 	      i_imm,
   output wire 	      o_q,
   //External
   output wire [31:0] o_dbus_adr,
   //Extension
   output wire [31:0] o_ext_rs1);

   wire 	      c, q;
   reg 		      c_r;
   reg [31:2] 	      data;
   reg [1:0]            lsb;

   wire 	      clr_lsb = i_cnt0 & i_clr_lsb;

   assign {c,q} = {1'b0,(i_rs1 & i_rs1_en)} + {1'b0,(i_imm & i_imm_en & !clr_lsb)} + c_r;

   always @(posedge i_clk) begin
      //Make sure carry is cleared before loading new data
      c_r <= c & i_en;

      if (i_en)
	data <= {i_init ? q : (data[31] & i_sh_signed), data[31:3]};

      if (i_init ? (i_cnt0 | i_cnt1) : i_en)
	lsb <= {i_init ? q : data[2],lsb[1]};
   end

   assign o_q = lsb[0] & i_en;
   assign o_dbus_adr = {data, 2'b00};
   assign o_ext_rs1  = {o_dbus_adr[31:2],lsb};
   assign o_lsb = (MDU & i_mdu_op) ? 2'b00 : lsb;

endmodule
module serv_bufreg2
  (
   input wire 	      i_clk,
   //State
   input wire 	      i_en,
   input wire 	      i_init,
   input wire 	      i_cnt_done,
   input wire [1:0]   i_lsb,
   input wire 	      i_byte_valid,
   output wire 	      o_sh_done,
   output wire 	      o_sh_done_r,
   //Control
   input wire 	      i_op_b_sel,
   input wire 	      i_shift_op,
   //Data
   input wire 	      i_rs2,
   input wire 	      i_imm,
   output wire 	      o_op_b,
   output wire 	      o_q,
   //External
   output wire [31:0] o_dat,
   input wire 	      i_load,
   input wire [31:0]  i_dat);

   reg [31:0] 	 dat;

   assign o_op_b = i_op_b_sel ? i_rs2 : i_imm;

   wire 	 dat_en = i_shift_op | (i_en & i_byte_valid);

   /* The dat register has three different use cases for store, load and
    shift operations.
    store : Data to be written is shifted to the correct position in dat during
            init by dat_en and is presented on the data bus as o_wb_dat
    load  : Data from the bus gets latched into dat during i_wb_ack and is then
            shifted out at the appropriate time to end up in the correct
            position in rd
    shift : Data is shifted in during init. After that, the six LSB are used as
            a downcounter (with bit 5 initially set to 0) that triggers
            o_sh_done and o_sh_done_r when they wrap around to indicate that
            the requested number of shifts have been performed
    */
   wire [5:0] dat_shamt = (i_shift_op & !i_init) ?
	      //Down counter mode
	      dat[5:0]-1 :
	      //Shift reg mode with optional clearing of bit 5
	      {dat[6] & !(i_shift_op & i_cnt_done),dat[5:1]};

   assign o_sh_done = dat_shamt[5];
   assign o_sh_done_r = dat[5];

   assign o_q =
	       ((i_lsb == 2'd3) & dat[24]) |
	       ((i_lsb == 2'd2) & dat[16]) |
	       ((i_lsb == 2'd1) & dat[8]) |
	       ((i_lsb == 2'd0) & dat[0]);

   assign o_dat = dat;

   always @(posedge i_clk) begin
      if (dat_en | i_load)
	dat <= i_load ? i_dat : {o_op_b, dat[31:7], dat_shamt};
   end

endmodule
/* Copyright lowRISC contributors.
Copyright 2018 ETH Zurich and University of Bologna, see also CREDITS.md.
Licensed under the Apache License, Version 2.0, see LICENSE for details.
SPDX-License-Identifier: Apache-2.0 

* Adapted to SERV by @Abdulwadoodd as part of the project under spring '22 LFX Mentorship program */

/* Decodes RISC-V compressed instructions into their RV32i equivalent. */

module serv_compdec 
  (
   input wire i_clk,
   input  wire [31:0] i_instr,
   input  wire i_ack,
   output wire [31:0] o_instr,
   output reg o_iscomp);

  localparam OPCODE_LOAD     = 7'h03;
  localparam OPCODE_OP_IMM   = 7'h13;
  localparam OPCODE_STORE    = 7'h23;
  localparam OPCODE_OP       = 7'h33;
  localparam OPCODE_LUI      = 7'h37;
  localparam OPCODE_BRANCH   = 7'h63;
  localparam OPCODE_JALR     = 7'h67;
  localparam OPCODE_JAL      = 7'h6f;

  reg  [31:0] comp_instr;
  reg  illegal_instr;

  assign o_instr = illegal_instr ? i_instr : comp_instr;

  always @(posedge i_clk) begin
    if(i_ack)
      o_iscomp <= !illegal_instr; 
  end

  always @ (*) begin
    // By default, forward incoming instruction, mark it as legal.
    comp_instr    = i_instr;
    illegal_instr = 1'b0;

    // Check if incoming instruction is compressed.
    case (i_instr[1:0])
      // C0
      2'b00: begin
        case (i_instr[15:14])
          2'b00: begin
            // c.addi4spn -> addi rd', x2, imm
            comp_instr = {2'b0, i_instr[10:7], i_instr[12:11], i_instr[5],
                      i_instr[6], 2'b00, 5'h02, 3'b000, 2'b01, i_instr[4:2], {OPCODE_OP_IMM}};
          end

          2'b01: begin
            // c.lw -> lw rd', imm(rs1')
            comp_instr = {5'b0, i_instr[5], i_instr[12:10], i_instr[6],
                      2'b00, 2'b01, i_instr[9:7], 3'b010, 2'b01, i_instr[4:2], {OPCODE_LOAD}};
          end

          2'b11: begin
            // c.sw -> sw rs2', imm(rs1')
            comp_instr = {5'b0, i_instr[5], i_instr[12], 2'b01, i_instr[4:2],
                      2'b01, i_instr[9:7], 3'b010, i_instr[11:10], i_instr[6],
                      2'b00, {OPCODE_STORE}};
          end

          2'b10: begin
            illegal_instr = 1'b1;
          end

        endcase
      end

      // C1
 
      // Register address checks for RV32E are performed in the regular instruction decoder.
      // If this check fails, an illegal instruction exception is triggered and the controller
      // writes the actual faulting instruction to mtval.
      2'b01: begin
        case (i_instr[15:13])
          3'b000: begin
            // c.addi -> addi rd, rd, nzimm
            // c.nop
            comp_instr = {{6 {i_instr[12]}}, i_instr[12], i_instr[6:2],
                      i_instr[11:7], 3'b0, i_instr[11:7], {OPCODE_OP_IMM}};
          end

          3'b001, 3'b101: begin
            // 001: c.jal -> jal x1, imm
            // 101: c.j   -> jal x0, imm
            comp_instr = {i_instr[12], i_instr[8], i_instr[10:9], i_instr[6],
                      i_instr[7], i_instr[2], i_instr[11], i_instr[5:3],
                      {9 {i_instr[12]}}, 4'b0, ~i_instr[15], {OPCODE_JAL}};
          end

          3'b010: begin
            // c.li -> addi rd, x0, nzimm
            // (c.li hints are translated into an addi hint)
            comp_instr = {{6 {i_instr[12]}}, i_instr[12], i_instr[6:2], 5'b0,
                      3'b0, i_instr[11:7], {OPCODE_OP_IMM}};
          end

          3'b011: begin
            // c.lui -> lui rd, imm
            // (c.lui hints are translated into a lui hint)
            comp_instr = {{15 {i_instr[12]}}, i_instr[6:2], i_instr[11:7], {OPCODE_LUI}};

            if (i_instr[11:7] == 5'h02) begin
              // c.addi16sp -> addi x2, x2, nzimm
              comp_instr = {{3 {i_instr[12]}}, i_instr[4:3], i_instr[5], i_instr[2],
                        i_instr[6], 4'b0, 5'h02, 3'b000, 5'h02, {OPCODE_OP_IMM}};
            end

          end

          3'b100: begin
            case (i_instr[11:10])
              2'b00,
              2'b01: begin
                // 00: c.srli -> srli rd, rd, shamt
                // 01: c.srai -> srai rd, rd, shamt
                // (c.srli/c.srai hints are translated into a srli/srai hint)
                comp_instr = {1'b0, i_instr[10], 5'b0, i_instr[6:2], 2'b01, i_instr[9:7],
                          3'b101, 2'b01, i_instr[9:7], {OPCODE_OP_IMM}};
              end

              2'b10: begin
                // c.andi -> andi rd, rd, imm
                comp_instr = {{6 {i_instr[12]}}, i_instr[12], i_instr[6:2], 2'b01, i_instr[9:7],
                          3'b111, 2'b01, i_instr[9:7], {OPCODE_OP_IMM}};
              end

              2'b11: begin
                case (i_instr[6:5])
                  2'b00: begin
                    // c.sub -> sub rd', rd', rs2'
                    comp_instr = {2'b01, 5'b0, 2'b01, i_instr[4:2], 2'b01, i_instr[9:7],
                                  3'b000, 2'b01, i_instr[9:7], {OPCODE_OP}};
                  end

                  2'b01: begin
                    // c.xor -> xor rd', rd', rs2'
                    comp_instr = {7'b0, 2'b01, i_instr[4:2], 2'b01, i_instr[9:7], 3'b100,
                              2'b01, i_instr[9:7], {OPCODE_OP}};
                  end

                  2'b10: begin
                    // c.or  -> or  rd', rd', rs2'
                    comp_instr = {7'b0, 2'b01, i_instr[4:2], 2'b01, i_instr[9:7], 3'b110,
                              2'b01, i_instr[9:7], {OPCODE_OP}};
                  end

                  2'b11: begin
                    // c.and -> and rd', rd', rs2'
                    comp_instr = {7'b0, 2'b01, i_instr[4:2], 2'b01, i_instr[9:7], 3'b111,
                              2'b01, i_instr[9:7], {OPCODE_OP}};
                  end
                endcase
              end
            endcase
          end

          3'b110, 3'b111: begin
            // 0: c.beqz -> beq rs1', x0, imm
            // 1: c.bnez -> bne rs1', x0, imm
            comp_instr = {{4 {i_instr[12]}}, i_instr[6:5], i_instr[2], 5'b0, 2'b01,
                      i_instr[9:7], 2'b00, i_instr[13], i_instr[11:10], i_instr[4:3],
                      i_instr[12], {OPCODE_BRANCH}};
          end
        endcase
      end

      // C2

      // Register address checks for RV32E are performed in the regular instruction decoder.
      // If this check fails, an illegal instruction exception is triggered and the controller
      // writes the actual faulting instruction to mtval.
      2'b10: begin
        case (i_instr[15:14])
          2'b00: begin
            // c.slli -> slli rd, rd, shamt
            // (c.ssli hints are translated into a slli hint)
            comp_instr = {7'b0, i_instr[6:2], i_instr[11:7], 3'b001, i_instr[11:7], {OPCODE_OP_IMM}};
          end

          2'b01: begin
            // c.lwsp -> lw rd, imm(x2)
            comp_instr = {4'b0, i_instr[3:2], i_instr[12], i_instr[6:4], 2'b00, 5'h02,
                      3'b010, i_instr[11:7], OPCODE_LOAD};
          end

          2'b10: begin
            if (i_instr[12] == 1'b0) begin
              if (i_instr[6:2] != 5'b0) begin
                // c.mv -> add rd/rs1, x0, rs2
                // (c.mv hints are translated into an add hint)
                comp_instr = {7'b0, i_instr[6:2], 5'b0, 3'b0, i_instr[11:7], {OPCODE_OP}};
              end else begin
                // c.jr -> jalr x0, rd/rs1, 0
                comp_instr = {12'b0, i_instr[11:7], 3'b0, 5'b0, {OPCODE_JALR}};
              end
            end else begin
              if (i_instr[6:2] != 5'b0) begin
                // c.add -> add rd, rd, rs2
                // (c.add hints are translated into an add hint)
                comp_instr = {7'b0, i_instr[6:2], i_instr[11:7], 3'b0, i_instr[11:7], {OPCODE_OP}};
              end else begin
                if (i_instr[11:7] == 5'b0) begin
                  // c.ebreak -> ebreak
                  comp_instr = {32'h00_10_00_73};
                end else begin
                  // c.jalr -> jalr x1, rs1, 0
                  comp_instr = {12'b0, i_instr[11:7], 3'b000, 5'b00001, {OPCODE_JALR}};
                end
              end
            end
          end

          2'b11: begin
            // c.swsp -> sw rs2, imm(x2)
            comp_instr = {4'b0, i_instr[8:7], i_instr[12], i_instr[6:2], 5'h02, 3'b010,
                      i_instr[11:9], 2'b00, {OPCODE_STORE}};
          end
        endcase
      end

      // Incoming instruction is not compressed.
      2'b11: illegal_instr = 1'b1;

    endcase
  end
  
  endmodule


`default_nettype none
module serv_csr
  #(parameter RESET_STRATEGY = "MINI")
  (
   input wire 	    i_clk,
   input wire 	    i_rst,
   //State
   input wire 	    i_init,
   input wire 	    i_en,
   input wire 	    i_cnt0to3,
   input wire 	    i_cnt3,
   input wire 	    i_cnt7,
   input wire 	    i_cnt_done,
   input wire 	    i_mem_op,
   input wire 	    i_mtip,
   input wire 	    i_trap,
   output reg 	    o_new_irq,
   //Control
   input wire 	    i_e_op,
   input wire 	    i_ebreak,
   input wire 	    i_mem_cmd,
   input wire 	    i_mstatus_en,
   input wire 	    i_mie_en,
   input wire 	    i_mcause_en,
   input wire [1:0] i_csr_source,
   input wire 	    i_mret,
   input wire 	    i_csr_d_sel,
   //Data
   input wire 	    i_rf_csr_out,
   output wire 	    o_csr_in,
   input wire 	    i_csr_imm,
   input wire 	    i_rs1,
   output wire 	    o_q);

   localparam [1:0]
     CSR_SOURCE_CSR = 2'b00,
     CSR_SOURCE_EXT = 2'b01,
     CSR_SOURCE_SET = 2'b10,
     CSR_SOURCE_CLR = 2'b11;

   reg 		    mstatus_mie;
   reg 		    mstatus_mpie;
   reg 		    mie_mtie;

   reg 		mcause31;
   reg [3:0] 	mcause3_0;
   wire 	mcause;

   wire 	csr_in;
   wire 	csr_out;

   reg 		timer_irq_r;

   wire 	d = i_csr_d_sel ? i_csr_imm : i_rs1;

   assign csr_in = (i_csr_source == CSR_SOURCE_EXT) ? d :
		   (i_csr_source == CSR_SOURCE_SET) ? csr_out | d :
		   (i_csr_source == CSR_SOURCE_CLR) ? csr_out & ~d :
		   (i_csr_source == CSR_SOURCE_CSR) ? csr_out :
		   1'bx;

   assign csr_out = (i_mstatus_en & mstatus_mie & i_cnt3) |
		    i_rf_csr_out |
		    (i_mcause_en & i_en & mcause);

   assign o_q = csr_out;

   wire 	timer_irq = i_mtip & mstatus_mie & mie_mtie;

   assign mcause = i_cnt0to3 ? mcause3_0[0] : //[3:0]
		   i_cnt_done ? mcause31 //[31]
		   : 1'b0;

   assign o_csr_in = csr_in;

   always @(posedge i_clk) begin
      if (!i_init & i_cnt_done) begin
	 timer_irq_r <= timer_irq;
	 o_new_irq   <= timer_irq & !timer_irq_r;
      end

      if (i_mie_en & i_cnt7)
	mie_mtie <= csr_in;

      /*
       The mie bit in mstatus gets updated under three conditions

       When a trap is taken, the bit is cleared
       During an mret instruction, the bit is restored from mpie
       During a mstatus CSR access instruction it's assigned when
        bit 3 gets updated

       These conditions are all mutually exclusibe
       */
      if ((i_trap & i_cnt_done) | i_mstatus_en & i_cnt3 | i_mret)
	mstatus_mie <= !i_trap & (i_mret ?  mstatus_mpie : csr_in);

      /*
       Note: To save resources mstatus_mpie (mstatus bit 7) is not
       readable or writable from sw
       */
      if (i_trap & i_cnt_done)
	mstatus_mpie <= mstatus_mie;

      /*
       The four lowest bits in mcause hold the exception code

       These bits get updated under three conditions

       During an mcause CSR access function, they are assigned when
       bits 0 to 3 gets updated

       During an external interrupt the exception code is set to
       7, since SERV only support timer interrupts

       During an exception, the exception code is assigned to indicate
       if it was caused by an ebreak instruction (3),
       ecall instruction (11), misaligned load (4), misaligned store (6)
       or misaligned jump (0)

       The expressions below are derived from the following truth table
       irq  => 0111 (timer=7)
       e_op => x011 (ebreak=3, ecall=11)
       mem  => 01x0 (store=6, load=4)
       ctrl => 0000 (jump=0)
       */
      if (i_mcause_en & i_en & i_cnt0to3 | (i_trap & i_cnt_done)) begin
	 mcause3_0[3] <= (i_e_op & !i_ebreak) | (!i_trap & csr_in);
	 mcause3_0[2] <= o_new_irq | i_mem_op | (!i_trap & mcause3_0[3]);
	 mcause3_0[1] <= o_new_irq | i_e_op | (i_mem_op & i_mem_cmd) | (!i_trap & mcause3_0[2]);
	 mcause3_0[0] <= o_new_irq | i_e_op | (!i_trap & mcause3_0[1]);
      end
      if (i_mcause_en & i_cnt_done | i_trap)
	mcause31 <= i_trap ? o_new_irq : csr_in;
      if (i_rst)
	if (RESET_STRATEGY != "NONE") begin
	   o_new_irq <= 1'b0;
	   mie_mtie <= 1'b0;
	end
   end

endmodule
`default_nettype none
module serv_ctrl
  #(parameter RESET_STRATEGY = "MINI",
    parameter RESET_PC = 32'd0,
    parameter WITH_CSR = 1)
  (
   input wire 	     clk,
   input wire 	     i_rst,
   //State
   input wire 	     i_pc_en,
   input wire 	     i_cnt12to31,
   input wire 	     i_cnt0,
   input wire        i_cnt1,
   input wire 	     i_cnt2,
   //Control
   input wire 	     i_jump,
   input wire 	     i_jal_or_jalr,
   input wire 	     i_utype,
   input wire 	     i_pc_rel,
   input wire 	     i_trap,
   input wire        i_iscomp,
   //Data
   input wire 	     i_imm,
   input wire 	     i_buf,
   input wire 	     i_csr_pc,
   output wire 	     o_rd,
   output wire 	     o_bad_pc,
   //External
   output reg [31:0] o_ibus_adr);

   wire       pc_plus_4;
   wire       pc_plus_4_cy;
   reg 	      pc_plus_4_cy_r;
   wire       pc_plus_offset;
   wire       pc_plus_offset_cy;
   reg 	      pc_plus_offset_cy_r;
   wire       pc_plus_offset_aligned;
   wire       plus_4;

   wire       pc = o_ibus_adr[0];

   wire       new_pc;

   wire       offset_a;
   wire       offset_b;

  /*  If i_iscomp=1: increment pc by 2 else increment pc by 4  */

   assign plus_4        = i_iscomp ? i_cnt1 : i_cnt2;

   assign o_bad_pc = pc_plus_offset_aligned;

   assign {pc_plus_4_cy,pc_plus_4} = pc+plus_4+pc_plus_4_cy_r;

   generate
      if (|WITH_CSR)
	assign new_pc = i_trap ? (i_csr_pc & !i_cnt0) : i_jump ? pc_plus_offset_aligned : pc_plus_4;
      else
	assign new_pc = i_jump ? pc_plus_offset_aligned : pc_plus_4;
   endgenerate
   assign o_rd  = (i_utype & pc_plus_offset_aligned) | (pc_plus_4 & i_jal_or_jalr);

   assign offset_a = i_pc_rel & pc;
   assign offset_b = i_utype ? (i_imm & i_cnt12to31): i_buf;
   assign {pc_plus_offset_cy,pc_plus_offset} = offset_a+offset_b+pc_plus_offset_cy_r;

   assign pc_plus_offset_aligned = pc_plus_offset & !i_cnt0;

   initial if (RESET_STRATEGY == "NONE") o_ibus_adr = RESET_PC;

   always @(posedge clk) begin
      pc_plus_4_cy_r <= i_pc_en & pc_plus_4_cy;
      pc_plus_offset_cy_r <= i_pc_en & pc_plus_offset_cy;

      if (RESET_STRATEGY == "NONE") begin
	 if (i_pc_en)
	   o_ibus_adr <= {new_pc, o_ibus_adr[31:1]};
      end else begin
	 if (i_pc_en | i_rst)
	   o_ibus_adr <= i_rst ? RESET_PC : {new_pc, o_ibus_adr[31:1]};
      end
   end
endmodule
`default_nettype none
module serv_decode
  #(parameter [0:0] PRE_REGISTER = 1,
    parameter [0:0] MDU = 0)
  (
   input wire        clk,
   //Input
   input wire [31:2] i_wb_rdt,
   input wire        i_wb_en,
   //To state
   output reg       o_sh_right,
   output reg       o_bne_or_bge,
   output reg       o_cond_branch,
   output reg       o_e_op,
   output reg       o_ebreak,
   output reg       o_branch_op,
   output reg       o_shift_op,
   output reg       o_slt_or_branch,
   output reg       o_rd_op,
   output reg       o_two_stage_op,
   output reg       o_dbus_en,
   //MDU
   output reg       o_mdu_op,
   //Extension
   output reg [2:0] o_ext_funct3,
   //To bufreg
   output reg       o_bufreg_rs1_en,
   output reg       o_bufreg_imm_en,
   output reg       o_bufreg_clr_lsb,
   output reg       o_bufreg_sh_signed,
   //To ctrl
   output reg       o_ctrl_jal_or_jalr,
   output reg       o_ctrl_utype,
   output reg       o_ctrl_pc_rel,
   output reg       o_ctrl_mret,
   //To alu
   output reg       o_alu_sub,
   output reg [1:0] o_alu_bool_op,
   output reg       o_alu_cmp_eq,
   output reg       o_alu_cmp_sig,
   output reg [2:0] o_alu_rd_sel,
   //To mem IF
   output reg       o_mem_signed,
   output reg       o_mem_word,
   output reg       o_mem_half,
   output reg       o_mem_cmd,
   //To CSR
   output reg       o_csr_en,
   output reg [1:0] o_csr_addr,
   output reg       o_csr_mstatus_en,
   output reg       o_csr_mie_en,
   output reg       o_csr_mcause_en,
   output reg [1:0] o_csr_source,
   output reg       o_csr_d_sel,
   output reg       o_csr_imm_en,
   output reg       o_mtval_pc,
   //To top
   output reg [3:0] o_immdec_ctrl,
   output reg [3:0] o_immdec_en,
   output reg       o_op_b_source,
   //To RF IF
   output reg       o_rd_mem_en,
   output reg       o_rd_csr_en,
   output reg       o_rd_alu_en);

   reg [4:0] opcode;
   reg [2:0] funct3;
   reg        op20;
   reg        op21;
   reg        op22;
   reg        op26;

   reg       imm25;
   reg       imm30;

   wire co_mdu_op     = MDU & (opcode == 5'b01100) & imm25;

   wire co_two_stage_op =
	~opcode[2] | (funct3[0] & ~funct3[1] & ~opcode[0] & ~opcode[4]) |
	(funct3[1] & ~funct3[2] & ~opcode[0] & ~opcode[4]) | co_mdu_op;
   wire co_shift_op = (opcode[2] & ~funct3[1]) & !co_mdu_op;
   wire co_slt_or_branch = (opcode[4] | (funct3[1] & opcode[2]) | (imm30 & opcode[2] & opcode[3] & ~funct3[2])) & !co_mdu_op;
   wire co_branch_op = opcode[4];
   wire co_dbus_en    = ~opcode[2] & ~opcode[4];
   wire co_mtval_pc   = opcode[4];   
   wire co_mem_word   = funct3[1];
   wire co_rd_alu_en  = !opcode[0] & opcode[2] & !opcode[4] & !co_mdu_op;
   wire co_rd_mem_en  = (!opcode[2] & !opcode[0]) | co_mdu_op;
   wire [2:0] co_ext_funct3 = funct3;

   //jal,branch =     imm
   //jalr       = rs1+imm
   //mem        = rs1+imm
   //shift      = rs1
   wire co_bufreg_rs1_en = !opcode[4] | (!opcode[1] & opcode[0]);
   wire co_bufreg_imm_en = !opcode[2];

   //Clear LSB of immediate for BRANCH and JAL ops
   //True for BRANCH and JAL
   //False for JALR/LOAD/STORE/OP/OPIMM?
   wire co_bufreg_clr_lsb = opcode[4] & ((opcode[1:0] == 2'b00) | (opcode[1:0] == 2'b11));

   //Conditional branch
   //True for BRANCH
   //False for JAL/JALR
   wire co_cond_branch = !opcode[0];

   wire co_ctrl_utype       = !opcode[4] & opcode[2] & opcode[0];
   wire co_ctrl_jal_or_jalr = opcode[4] & opcode[0];

   //PC-relative operations
   //True for jal, b* auipc, ebreak
   //False for jalr, lui
   wire co_ctrl_pc_rel = (opcode[2:0] == 3'b000)  |
                          (opcode[1:0] == 2'b11)  |
                          (opcode[4] & opcode[2]) & op20|
                          (opcode[4:3] == 2'b00);
   //Write to RD
   //True for OP-IMM, AUIPC, OP, LUI, SYSTEM, JALR, JAL, LOAD
   //False for STORE, BRANCH, MISC-MEM
   wire co_rd_op = (opcode[2] |
                     (!opcode[2] & opcode[4] & opcode[0]) |
                     (!opcode[2] & !opcode[3] & !opcode[0]));

   //
   //funct3
   //

   wire co_sh_right   = funct3[2];
   wire co_bne_or_bge = funct3[0];

   //Matches system ops except eceall/ebreak/mret
   wire csr_op = opcode[4] & opcode[2] & (|funct3);


   //op20
   wire co_ebreak = op20;


   //opcode & funct3 & op21

   wire co_ctrl_mret = opcode[4] & opcode[2] & op21 & !(|funct3);
   //Matches system opcodes except CSR accesses (funct3 == 0)
   //and mret (!op21)
   wire co_e_op = opcode[4] & opcode[2] & !op21 & !(|funct3);

   //opcode & funct3 & imm30

   wire co_bufreg_sh_signed = imm30;

   /*
    True for sub, b*, slt*
    False for add*
    op    opcode f3  i30
    b*    11000  xxx x   t
    addi  00100  000 x   f
    slt*  0x100  01x x   t
    add   01100  000 0   f
    sub   01100  000 1   t
    */
   wire co_alu_sub = funct3[1] | funct3[0] | (opcode[3] & imm30) | opcode[4];

   /*
    Bits 26, 22, 21 and 20 are enough to uniquely identify the eight supported CSR regs
    mtvec, mscratch, mepc and mtval are stored externally (normally in the RF) and are
    treated differently from mstatus, mie and mcause which are stored in serv_csr.

    The former get a 2-bit address as seen below while the latter get a
    one-hot enable signal each.

    Hex|2 222|Reg     |csr
    adr|6 210|name    |addr
    ---|-----|--------|----
    300|0_000|mstatus | xx
    304|0_100|mie     | xx
    305|0_101|mtvec   | 01
    340|1_000|mscratch| 00
    341|1_001|mepc    | 10
    342|1_010|mcause  | xx
    343|1_011|mtval   | 11

    */

   //true  for mtvec,mscratch,mepc and mtval
   //false for mstatus, mie, mcause
   wire csr_valid = op20 | (op26 & !op21);

   wire co_rd_csr_en = csr_op;

   wire co_csr_en         = csr_op & csr_valid;
   wire co_csr_mstatus_en = csr_op & !op26 & !op22;
   wire co_csr_mie_en     = csr_op & !op26 &  op22 & !op20;
   wire co_csr_mcause_en  = csr_op         &  op21 & !op20;

   wire [1:0] co_csr_source = funct3[1:0];
   wire co_csr_d_sel = funct3[2];
   wire co_csr_imm_en = opcode[4] & opcode[2] & funct3[2];
   wire [1:0] co_csr_addr = {op26 & op20, !op26 | op21};

   wire co_alu_cmp_eq = funct3[2:1] == 2'b00;

   wire co_alu_cmp_sig = ~((funct3[0] & funct3[1]) | (funct3[1] & funct3[2]));

   wire co_mem_cmd  = opcode[3];
   wire co_mem_signed = ~funct3[2];
   wire co_mem_half   = funct3[0];

   wire [1:0] co_alu_bool_op = funct3[1:0];

   wire [3:0] co_immdec_ctrl;
   //True for S (STORE) or B (BRANCH) type instructions
   //False for J type instructions
   assign co_immdec_ctrl[0] = opcode[3:0] == 4'b1000;
   //True for OP-IMM, LOAD, STORE, JALR  (I S)
   //False for LUI, AUIPC, JAL           (U J)
   assign co_immdec_ctrl[1] = (opcode[1:0] == 2'b00) | (opcode[2:1] == 2'b00);
   assign co_immdec_ctrl[2] = opcode[4] & !opcode[0];
   assign co_immdec_ctrl[3] = opcode[4];

   wire [3:0] co_immdec_en;
   assign co_immdec_en[3] = opcode[4] | opcode[3] | opcode[2] | !opcode[0];                 //B I J S U
   assign co_immdec_en[2] = (opcode[4] & opcode[2]) | !opcode[3] | opcode[0];               //  I J   U
   assign co_immdec_en[1] = (opcode[2:1] == 2'b01) | (opcode[2] & opcode[0]) | co_csr_imm_en;//    J   U
   assign co_immdec_en[0] = ~co_rd_op;                                                       //B     S

   wire [2:0] co_alu_rd_sel;
   assign co_alu_rd_sel[0] = (funct3 == 3'b000); // Add/sub
   assign co_alu_rd_sel[1] = (funct3[2:1] == 2'b01); //SLT*
   assign co_alu_rd_sel[2] = funct3[2]; //Bool

   //0 (OP_B_SOURCE_IMM) when OPIMM
   //1 (OP_B_SOURCE_RS2) when BRANCH or OP
   wire co_op_b_source = opcode[3];

   generate
      if (PRE_REGISTER) begin

         always @(posedge clk) begin
            if (i_wb_en) begin
               funct3 <= i_wb_rdt[14:12];
               imm30  <= i_wb_rdt[30];
               imm25  <= i_wb_rdt[25];
               opcode <= i_wb_rdt[6:2];
               op20   <= i_wb_rdt[20];
               op21   <= i_wb_rdt[21];
               op22   <= i_wb_rdt[22];
               op26   <= i_wb_rdt[26];
            end
         end

         always @(*) begin
            o_sh_right         = co_sh_right;
            o_bne_or_bge       = co_bne_or_bge;
            o_cond_branch      = co_cond_branch;
            o_dbus_en          = co_dbus_en;
            o_mtval_pc         = co_mtval_pc;
	    o_two_stage_op     = co_two_stage_op;
            o_e_op             = co_e_op;
            o_ebreak           = co_ebreak;
            o_branch_op        = co_branch_op;
            o_shift_op         = co_shift_op;
            o_slt_or_branch    = co_slt_or_branch;
            o_rd_op            = co_rd_op;
            o_mdu_op           = co_mdu_op;
            o_ext_funct3       = co_ext_funct3;
            o_bufreg_rs1_en    = co_bufreg_rs1_en;
            o_bufreg_imm_en    = co_bufreg_imm_en;
            o_bufreg_clr_lsb   = co_bufreg_clr_lsb;
            o_bufreg_sh_signed = co_bufreg_sh_signed;
            o_ctrl_jal_or_jalr = co_ctrl_jal_or_jalr;
            o_ctrl_utype       = co_ctrl_utype;
            o_ctrl_pc_rel      = co_ctrl_pc_rel;
            o_ctrl_mret        = co_ctrl_mret;
            o_alu_sub          = co_alu_sub;
            o_alu_bool_op      = co_alu_bool_op;
            o_alu_cmp_eq       = co_alu_cmp_eq;
            o_alu_cmp_sig      = co_alu_cmp_sig;
            o_alu_rd_sel       = co_alu_rd_sel;
            o_mem_signed       = co_mem_signed;
            o_mem_word         = co_mem_word;
            o_mem_half         = co_mem_half;
            o_mem_cmd          = co_mem_cmd;
            o_csr_en           = co_csr_en;
            o_csr_addr         = co_csr_addr;
            o_csr_mstatus_en   = co_csr_mstatus_en;
            o_csr_mie_en       = co_csr_mie_en;
            o_csr_mcause_en    = co_csr_mcause_en;
            o_csr_source       = co_csr_source;
            o_csr_d_sel        = co_csr_d_sel;
            o_csr_imm_en       = co_csr_imm_en;
            o_immdec_ctrl      = co_immdec_ctrl;
            o_immdec_en        = co_immdec_en;
            o_op_b_source      = co_op_b_source;
            o_rd_csr_en        = co_rd_csr_en;
            o_rd_alu_en        = co_rd_alu_en;
            o_rd_mem_en        = co_rd_mem_en;
         end

      end else begin

         always @(*) begin
            funct3  = i_wb_rdt[14:12];
            imm30   = i_wb_rdt[30];
            imm25   = i_wb_rdt[25];
            opcode  = i_wb_rdt[6:2];
            op20    = i_wb_rdt[20];
            op21    = i_wb_rdt[21];
            op22    = i_wb_rdt[22];
            op26    = i_wb_rdt[26];
         end

         always @(posedge clk) begin
            if (i_wb_en) begin
               o_sh_right         <= co_sh_right;
               o_bne_or_bge       <= co_bne_or_bge;
               o_cond_branch      <= co_cond_branch;
               o_e_op             <= co_e_op;
               o_ebreak           <= co_ebreak;
               o_two_stage_op     <= co_two_stage_op;
               o_dbus_en          <= co_dbus_en;
               o_mtval_pc         <= co_mtval_pc;
               o_branch_op        <= co_branch_op;
               o_shift_op         <= co_shift_op;
               o_slt_or_branch    <= co_slt_or_branch;
               o_rd_op            <= co_rd_op;
               o_mdu_op           <= co_mdu_op;
               o_ext_funct3       <= co_ext_funct3;
               o_bufreg_rs1_en    <= co_bufreg_rs1_en;
               o_bufreg_imm_en    <= co_bufreg_imm_en;
               o_bufreg_clr_lsb   <= co_bufreg_clr_lsb;
               o_bufreg_sh_signed <= co_bufreg_sh_signed;
               o_ctrl_jal_or_jalr <= co_ctrl_jal_or_jalr;
               o_ctrl_utype       <= co_ctrl_utype;
               o_ctrl_pc_rel      <= co_ctrl_pc_rel;
               o_ctrl_mret        <= co_ctrl_mret;
               o_alu_sub          <= co_alu_sub;
               o_alu_bool_op      <= co_alu_bool_op;
               o_alu_cmp_eq       <= co_alu_cmp_eq;
               o_alu_cmp_sig      <= co_alu_cmp_sig;
               o_alu_rd_sel       <= co_alu_rd_sel;
               o_mem_signed       <= co_mem_signed;
               o_mem_word         <= co_mem_word;
               o_mem_half         <= co_mem_half;
               o_mem_cmd          <= co_mem_cmd;
               o_csr_en           <= co_csr_en;
               o_csr_addr         <= co_csr_addr;
               o_csr_mstatus_en   <= co_csr_mstatus_en;
               o_csr_mie_en       <= co_csr_mie_en;
               o_csr_mcause_en    <= co_csr_mcause_en;
               o_csr_source       <= co_csr_source;
               o_csr_d_sel        <= co_csr_d_sel;
               o_csr_imm_en       <= co_csr_imm_en;
               o_immdec_ctrl      <= co_immdec_ctrl;
               o_immdec_en        <= co_immdec_en;
               o_op_b_source      <= co_op_b_source;
               o_rd_csr_en        <= co_rd_csr_en;
               o_rd_alu_en        <= co_rd_alu_en;
               o_rd_mem_en        <= co_rd_mem_en;
            end
         end

      end
   endgenerate

endmodule
`default_nettype none
module serv_immdec
  #(parameter SHARED_RFADDR_IMM_REGS = 1)
  (
   input wire 	     i_clk,
   //State
   input wire 	     i_cnt_en,
   input wire 	     i_cnt_done,
   //Control
   input wire [3:0]  i_immdec_en,
   input wire 	     i_csr_imm_en,
   input wire [3:0]  i_ctrl,
   output wire [4:0] o_rd_addr,
   output wire [4:0] o_rs1_addr,
   output wire [4:0] o_rs2_addr,
   //Data
   output wire 	     o_csr_imm,
   output wire 	     o_imm,
   //External
   input wire 	     i_wb_en,
   input wire [31:7] i_wb_rdt);

   reg 		     imm31;

   reg [8:0]  imm19_12_20;
   reg 	      imm7;
   reg [5:0]  imm30_25;
   reg [4:0]  imm24_20;
   reg [4:0]  imm11_7;

   assign o_csr_imm = imm19_12_20[4];

   wire       signbit = imm31 & !i_csr_imm_en;

   generate
      if (SHARED_RFADDR_IMM_REGS) begin
	 assign o_rs1_addr = imm19_12_20[8:4];
	 assign o_rs2_addr = imm24_20;
	 assign o_rd_addr  = imm11_7;

	 always @(posedge i_clk) begin
	    if (i_wb_en) begin
	       /* CSR immediates are always zero-extended, hence clear the signbit */
	       imm31     <= i_wb_rdt[31];
	    end
	    if (i_wb_en | (i_cnt_en & i_immdec_en[1]))
	      imm19_12_20 <= i_wb_en ? {i_wb_rdt[19:12],i_wb_rdt[20]} : {i_ctrl[3] ? signbit : imm24_20[0], imm19_12_20[8:1]};
	    if (i_wb_en | (i_cnt_en))
	      imm7        <= i_wb_en ? i_wb_rdt[7]                    : signbit;

	    if (i_wb_en | (i_cnt_en & i_immdec_en[3]))
	      imm30_25    <= i_wb_en ? i_wb_rdt[30:25] : {i_ctrl[2] ? imm7 : i_ctrl[1] ? signbit : imm19_12_20[0], imm30_25[5:1]};

	    if (i_wb_en | (i_cnt_en & i_immdec_en[2]))
	      imm24_20    <= i_wb_en ? i_wb_rdt[24:20] : {imm30_25[0], imm24_20[4:1]};

	    if (i_wb_en | (i_cnt_en & i_immdec_en[0]))
	      imm11_7     <= i_wb_en ? i_wb_rdt[11:7] : {imm30_25[0], imm11_7[4:1]};
	 end
      end else begin
	 reg [4:0]  rd_addr;
	 reg [4:0]  rs1_addr;
	 reg [4:0]  rs2_addr;

	 assign o_rd_addr  = rd_addr;
	 assign o_rs1_addr = rs1_addr;
	 assign o_rs2_addr = rs2_addr;
	 always @(posedge i_clk) begin
	    if (i_wb_en) begin
	       /* CSR immediates are always zero-extended, hence clear the signbit */
	       imm31       <= i_wb_rdt[31];
	       imm19_12_20 <= {i_wb_rdt[19:12],i_wb_rdt[20]};
	       imm7        <= i_wb_rdt[7];
	       imm30_25    <= i_wb_rdt[30:25];
	       imm24_20    <= i_wb_rdt[24:20];
	       imm11_7     <= i_wb_rdt[11:7];

               rd_addr  <= i_wb_rdt[11:7];
               rs1_addr <= i_wb_rdt[19:15];
               rs2_addr <= i_wb_rdt[24:20];
	    end
	    if (i_cnt_en) begin
	       imm19_12_20 <= {i_ctrl[3] ? signbit : imm24_20[0], imm19_12_20[8:1]};
	       imm7        <= signbit;
	       imm30_25    <= {i_ctrl[2] ? imm7 : i_ctrl[1] ? signbit : imm19_12_20[0], imm30_25[5:1]};
	       imm24_20    <= {imm30_25[0], imm24_20[4:1]};
	       imm11_7     <= {imm30_25[0], imm11_7[4:1]};
	    end
	 end
      end
   endgenerate

	 assign o_imm = i_cnt_done ? signbit : i_ctrl[0] ? imm11_7[0] : imm24_20[0];
	 
endmodule
`default_nettype none
module serv_mem_if
  #(parameter [0:0] WITH_CSR = 1)
  (
   input wire 	     i_clk,
   //State
   input wire [1:0]  i_bytecnt,
   input wire [1:0]  i_lsb,
   output wire 	     o_byte_valid,
   output wire 	     o_misalign,
   //Control
   input wire 	     i_signed,
   input wire 	     i_word,
   input wire 	     i_half,
   //MDU
   input wire 	     i_mdu_op,
   //Data
   input wire 	     i_bufreg2_q,
   output wire 	     o_rd,
   //External interface
   output wire [3:0] o_wb_sel);

   reg           signbit;

   /*
    Before a store operation, the data to be written needs to be shifted into
    place. Depending on the address alignment, we need to shift different
    amounts. One formula for calculating this is to say that we shift when
    i_lsb + i_bytecnt < 4. Unfortunately, the synthesis tools don't seem to be
    clever enough so the hideous expression below is used to achieve the same
    thing in a more optimal way.
    */
   assign o_byte_valid
     = (!i_lsb[0] & !i_lsb[1])         |
       (!i_bytecnt[0] & !i_bytecnt[1]) |
       (!i_bytecnt[1] & !i_lsb[1])     |
       (!i_bytecnt[1] & !i_lsb[0])     |
       (!i_bytecnt[0] & !i_lsb[1]);

   wire dat_valid =
	i_mdu_op |
	i_word |
	(i_bytecnt == 2'b00) |
	(i_half & !i_bytecnt[1]);

   assign o_rd = dat_valid ? i_bufreg2_q : signbit & i_signed;

   assign o_wb_sel[3] = (i_lsb == 2'b11) | i_word | (i_half & i_lsb[1]);
   assign o_wb_sel[2] = (i_lsb == 2'b10) | i_word;
   assign o_wb_sel[1] = (i_lsb == 2'b01) | i_word | (i_half & !i_lsb[1]);
   assign o_wb_sel[0] = (i_lsb == 2'b00);

   always @(posedge i_clk) begin
      if (dat_valid)
        signbit <= i_bufreg2_q;
   end

   /*
    mem_misalign is checked after the init stage to decide whether to do a data
    bus transaction or go to the trap state. It is only guaranteed to be correct
    at this time
    */
   assign o_misalign = WITH_CSR & ((i_lsb[0] & (i_word | i_half)) | (i_lsb[1] & i_word));

endmodule
`default_nettype none
module serv_rf_if
  #(parameter WITH_CSR = 1)
  (//RF Interface
   input wire 		      i_cnt_en,
   output wire [4+WITH_CSR:0] o_wreg0,
   output wire [4+WITH_CSR:0] o_wreg1,
   output wire 		      o_wen0,
   output wire 		      o_wen1,
   output wire 		      o_wdata0,
   output wire 		      o_wdata1,
   output wire [4+WITH_CSR:0] o_rreg0,
   output wire [4+WITH_CSR:0] o_rreg1,
   input wire 		      i_rdata0,
   input wire 		      i_rdata1,

   //Trap interface
   input wire 		      i_trap,
   input wire 		      i_mret,
   input wire 		      i_mepc,
   input wire 		      i_mtval_pc,
   input wire 		      i_bufreg_q,
   input wire 		      i_bad_pc,
   output wire 		      o_csr_pc,
   //CSR interface
   input wire 		      i_csr_en,
   input wire [1:0] 	      i_csr_addr,
   input wire 		      i_csr,
   output wire 		      o_csr,
   //RD write port
   input wire 		      i_rd_wen,
   input wire [4:0] 	      i_rd_waddr,
   input wire 		      i_ctrl_rd,
   input wire 		      i_alu_rd,
   input wire 		      i_rd_alu_en,
   input wire 		      i_csr_rd,
   input wire 		      i_rd_csr_en,
   input wire 		      i_mem_rd,
   input wire 		      i_rd_mem_en,

   //RS1 read port
   input wire [4:0] 	      i_rs1_raddr,
   output wire 		      o_rs1,
   //RS2 read port
   input wire [4:0] 	      i_rs2_raddr,
   output wire 		      o_rs2);


   /*
    ********** Write side ***********
    */

   wire 	     rd_wen = i_rd_wen & (|i_rd_waddr);

   generate
   if (|WITH_CSR) begin
   wire 	     rd = (i_ctrl_rd ) |
			  (i_alu_rd & i_rd_alu_en) |
			  (i_csr_rd & i_rd_csr_en) |
			  (i_mem_rd & i_rd_mem_en);

   wire 	     mtval = i_mtval_pc ? i_bad_pc : i_bufreg_q;

   assign 	     o_wdata0 = i_trap ? mtval  : rd;
   assign	     o_wdata1 = i_trap ? i_mepc : i_csr;

   /* Port 0 handles writes to mtval during traps and rd otherwise
    * Port 1 handles writes to mepc during traps and csr accesses otherwise
    *
    * GPR registers are mapped to address 0-31 (bits 0xxxxx).
    * Following that are four CSR registers
    * mscratch 100000
    * mtvec    100001
    * mepc     100010
    * mtval    100011
    */

   assign o_wreg0 = i_trap ? {6'b100011} : {1'b0,i_rd_waddr};
   assign o_wreg1 = i_trap ? {6'b100010} : {4'b1000,i_csr_addr};

   assign       o_wen0 = i_cnt_en & (i_trap | rd_wen);
   assign       o_wen1 = i_cnt_en & (i_trap | i_csr_en);

   /*
    ********** Read side ***********
    */

   //0 : RS1
   //1 : RS2 / CSR

   assign o_rreg0 = {1'b0, i_rs1_raddr};

   /*
    The address of the second read port (o_rreg1) can get assigned from four
    different sources

    Normal operations : i_rs2_raddr
    CSR access        : i_csr_addr
    trap              : MTVEC
    mret              : MEPC

    Address 0-31 in the RF are assigned to the GPRs. After that follows the four
    CSRs on addresses 32-35

    32 MSCRATCH
    33 MTVEC
    34 MEPC
    35 MTVAL

    The expression below is an optimized version of this logic
    */
   wire sel_rs2 = !(i_trap | i_mret | i_csr_en);
   assign o_rreg1 = {~sel_rs2,
		     i_rs2_raddr[4:2] & {3{sel_rs2}},
		     {1'b0,i_trap} | {i_mret,1'b0} | ({2{i_csr_en}} & i_csr_addr) | ({2{sel_rs2}} & i_rs2_raddr[1:0])};

   assign o_rs1 = i_rdata0;
   assign o_rs2 = i_rdata1;
   assign o_csr = i_rdata1 & i_csr_en;
   assign o_csr_pc = i_rdata1;

   end else begin
      wire 	     rd = (i_ctrl_rd ) |
			  (i_alu_rd & i_rd_alu_en) |
			  (i_mem_rd & i_rd_mem_en);

      assign 	     o_wdata0 = rd;
      assign	     o_wdata1 = 1'b0;

      assign o_wreg0 = i_rd_waddr;
      assign o_wreg1 = 5'd0;

      assign       o_wen0 = i_cnt_en & rd_wen;
      assign       o_wen1 = 1'b0;

   /*
    ********** Read side ***********
    */

      assign o_rreg0 = i_rs1_raddr;
      assign o_rreg1 = i_rs2_raddr;

      assign o_rs1 = i_rdata0;
      assign o_rs2 = i_rdata1;
      assign o_csr = 1'b0;
      assign o_csr_pc = 1'b0;
   end // else: !if(WITH_CSR)
   endgenerate
endmodule
module serv_rf_ram
  #(parameter width=0,
    parameter csr_regs=4,
    parameter depth=32*(32+csr_regs)/width)
   (input wire i_clk,
    input wire [$clog2(depth)-1:0] i_waddr,
    input wire [width-1:0] 	   i_wdata,
    input wire 			   i_wen,
    input wire [$clog2(depth)-1:0] i_raddr,
    input wire			   i_ren,
    output wire [width-1:0] 	   o_rdata);

   reg [width-1:0] 		   memory [0:depth-1];
   reg [width-1:0] 		   rdata ;

   always @(posedge i_clk) begin
      if (i_wen)
	memory[i_waddr] <= i_wdata;
      rdata <= i_ren ? memory[i_raddr] : {width{1'bx}};
   end

   /* Reads from reg x0 needs to return 0
    Check that the part of the read address corresponding to the register
    is zero and gate the output
    width LSB of reg index $clog2(width)
    2     4                1
    4     3                2
    8     2                3
    16    1                4
    32    0                5
    */
   reg regzero;

   always @(posedge i_clk)
     regzero <= !(|i_raddr[$clog2(depth)-1:5-$clog2(width)]);

   assign o_rdata = rdata & ~{width{regzero}};

`ifdef SERV_CLEAR_RAM
   integer i;
   initial
     for (i=0;i<depth;i=i+1)
       memory[i] = {width{1'd0}};
`endif
endmodule
`default_nettype none
module serv_rf_ram_if
  #(//Data width. Adjust to preferred width of SRAM data interface
    parameter width=8,

    //Select reset strategy.
    // "MINI" for resetting minimally required FFs
    // "NONE" for relying on FFs having a defined value on startup
    parameter reset_strategy="MINI",

    //Number of CSR registers. These are allocated after the normal
    // GPR registers in the RAM.
    parameter csr_regs=4,

    //Internal parameters calculated from above values. Do not change
    parameter raw=$clog2(32+csr_regs), //Register address width
    parameter l2w=$clog2(width), //log2 of width
    parameter aw=5+raw-l2w) //Address width
  (
   //SERV side
   input wire		   i_clk,
   input wire		   i_rst,
   input wire		   i_wreq,
   input wire		   i_rreq,
   output wire		   o_ready,
   input wire [raw-1:0]	   i_wreg0,
   input wire [raw-1:0]	   i_wreg1,
   input wire		   i_wen0,
   input wire		   i_wen1,
   input wire		   i_wdata0,
   input wire		   i_wdata1,
   input wire [raw-1:0]	   i_rreg0,
   input wire [raw-1:0]	   i_rreg1,
   output wire		   o_rdata0,
   output wire		   o_rdata1,
   //RAM side
   output wire [aw-1:0]	   o_waddr,
   output wire [width-1:0] o_wdata,
   output wire		   o_wen,
   output wire [aw-1:0]	   o_raddr,
   output wire		   o_ren,
   input wire [width-1:0]  i_rdata);

   reg 				   rgnt;
   assign o_ready = rgnt | i_wreq;
   reg [4:0] 	  rcnt;

   reg 		  rtrig1;
   /*
    ********** Write side ***********
    */

   wire [4:0] 	     wcnt;

   reg [width-1:0]   wdata0_r;
   reg [width-0:0]   wdata1_r;

   reg 		     wen0_r;
   reg 		     wen1_r;
   wire 	     wtrig0;
   wire 	     wtrig1;

   assign wtrig0 = rtrig1;

   generate if (width == 2) begin
      assign wtrig1 =  wcnt[0];
   end else begin
      reg wtrig0_r;
      always @(posedge i_clk) wtrig0_r <= wtrig0;
      assign wtrig1 = wtrig0_r;
   end
   endgenerate

   assign 	     o_wdata = wtrig1 ?
			       wdata1_r[width-1:0] :
			       wdata0_r;

   wire [raw-1:0] wreg  = wtrig1 ? i_wreg1 : i_wreg0;
   generate if (width == 32)
     assign o_waddr = wreg;
   else
     assign o_waddr = {wreg, wcnt[4:l2w]};
   endgenerate

   assign o_wen = (wtrig0 & wen0_r) | (wtrig1 & wen1_r);

   assign wcnt = rcnt-4;

   always @(posedge i_clk) begin
      if (wcnt[0]) begin
	 wen0_r    <= i_wen0;
	 wen1_r    <= i_wen1;
      end

      wdata0_r  <= {i_wdata0,wdata0_r[width-1:1]};
      wdata1_r  <= {i_wdata1,wdata1_r[width-0:1]};

   end

   /*
    ********** Read side ***********
    */


   wire 	  rtrig0;

   wire [raw-1:0] rreg = rtrig0 ? i_rreg1 : i_rreg0;
   generate if (width == 32)
     assign o_raddr = rreg;
   else
     assign o_raddr = {rreg, rcnt[4:l2w]};
   endgenerate

   reg [width-1:0]  rdata0;
   reg [width-2:0]  rdata1;

   reg 		    rgate;

   assign o_rdata0 = rdata0[0];
   assign o_rdata1 = rtrig1 ? i_rdata[0] : rdata1[0];

   assign rtrig0 = (rcnt[l2w-1:0] == 1);

   generate if (width == 2)
     assign o_ren = rgate;
   else
     assign o_ren = rgate & (rcnt[l2w-1:1] == 0);
   endgenerate

   reg 	      rreq_r;

   generate if (width>2)
     always @(posedge i_clk) begin
	rdata1 <= {1'b0,rdata1[width-2:1]}; //Optimize?
	if (rtrig1)
	  rdata1[width-2:0] <= i_rdata[width-1:1];
     end
   else
     always @(posedge i_clk) if (rtrig1) rdata1 <= i_rdata[1];
   endgenerate

   always @(posedge i_clk) begin
      if (&rcnt | i_rreq)
	rgate <= i_rreq;

      rtrig1 <= rtrig0;
      rcnt <= rcnt+5'd1;
      if (i_rreq | i_wreq)
	 rcnt <= {3'd0,i_wreq,1'b0};

      rreq_r <= i_rreq;
      rgnt <= rreq_r;

      rdata0 <= {1'b0,rdata0[width-1:1]};
      if (rtrig0)
	rdata0 <= i_rdata;

      if (i_rst) begin
	 if (reset_strategy != "NONE") begin
	    rgate <= 1'b0;
	    rgnt <= 1'b0;
	    rreq_r <= 1'b0;
	    rcnt <= 5'd0;
	 end
      end
   end



endmodule
`default_nettype none

module serv_rf_top
  #(parameter RESET_PC = 32'd0,
    /*  COMPRESSED=1: Enable the compressed decoder and allowed misaligned jump of pc
        COMPRESSED=0: Disable the compressed decoder and does not allow the misaligned jump of pc
    */
    parameter [0:0] COMPRESSED = 0,
    /*  
      ALIGN = 1: Fetch the aligned instruction by making two bus transactions if the misaligned address 
      is given to the instruction bus.  
    */
    parameter [0:0] ALIGN = COMPRESSED,
    /* Multiplication and Division Unit
       This parameter enables the interface for connecting SERV and MDU
    */
    parameter [0:0] MDU = 0,
    /* Register signals before or after the decoder
       0 : Register after the decoder. Faster but uses more resources
       1 : (default) Register before the decoder. Slower but uses less resources
     */
    parameter PRE_REGISTER = 1,
    /* Amount of reset applied to design
       "NONE" : No reset at all. Relies on a POR to set correct initialization
                 values and that core isn't reset during runtime
       "MINI" : Standard setting. Resets the minimal amount of FFs needed to
                 restart execution from the instruction at RESET_PC
     */
    parameter RESET_STRATEGY = "MINI",
    parameter WITH_CSR = 1,
    parameter RF_WIDTH = 4,
	parameter RF_L2D   = $clog2((32+(WITH_CSR*4))*32/RF_WIDTH))
  (
   input wire 	      clk,
   input wire 	      i_rst,
   input wire 	      i_timer_irq,
`ifdef RISCV_FORMAL
   output wire 	      rvfi_valid,
   output wire [63:0] rvfi_order,
   output wire [31:0] rvfi_insn,
   output wire 	      rvfi_trap,
   output wire 	      rvfi_halt,
   output wire 	      rvfi_intr,
   output wire [1:0]  rvfi_mode,
   output wire [1:0]  rvfi_ixl,
   output wire [4:0]  rvfi_rs1_addr,
   output wire [4:0]  rvfi_rs2_addr,
   output wire [31:0] rvfi_rs1_rdata,
   output wire [31:0] rvfi_rs2_rdata,
   output wire [4:0]  rvfi_rd_addr,
   output wire [31:0] rvfi_rd_wdata,
   output wire [31:0] rvfi_pc_rdata,
   output wire [31:0] rvfi_pc_wdata,
   output wire [31:0] rvfi_mem_addr,
   output wire [3:0]  rvfi_mem_rmask,
   output wire [3:0]  rvfi_mem_wmask,
   output wire [31:0] rvfi_mem_rdata,
   output wire [31:0] rvfi_mem_wdata,
`endif
   output wire [31:0] o_ibus_adr,
   output wire 	      o_ibus_cyc,
   input wire [31:0]  i_ibus_rdt,
   input wire 	      i_ibus_ack,
   output wire [31:0] o_dbus_adr,
   output wire [31:0] o_dbus_dat,
   output wire [3:0]  o_dbus_sel,
   output wire 	      o_dbus_we ,
   output wire 	      o_dbus_cyc,
   input wire [31:0]  i_dbus_rdt,
   input wire 	      i_dbus_ack,
   
   // Extension
   output wire [31:0] o_ext_rs1,
   output wire [31:0] o_ext_rs2,
   output wire [ 2:0] o_ext_funct3,
   input  wire [31:0] i_ext_rd,
   input  wire        i_ext_ready,
   // MDU
   output wire        o_mdu_valid);
   
   localparam CSR_REGS = WITH_CSR*4;

   wire 	      rf_wreq;
   wire 	      rf_rreq;
   wire [4+WITH_CSR:0] wreg0;
   wire [4+WITH_CSR:0] wreg1;
   wire 	      wen0;
   wire 	      wen1;
   wire 	      wdata0;
   wire 	      wdata1;
   wire [4+WITH_CSR:0] rreg0;
   wire [4+WITH_CSR:0] rreg1;
   wire 	      rf_ready;
   wire 	      rdata0;
   wire 	      rdata1;

   wire [RF_L2D-1:0]   waddr;
   wire [RF_WIDTH-1:0] wdata;
   wire 	       wen;
   wire [RF_L2D-1:0]   raddr;
   wire 	       ren;
   wire [RF_WIDTH-1:0] rdata;

   serv_rf_ram_if
     #(.width    (RF_WIDTH),
       .reset_strategy (RESET_STRATEGY),
       .csr_regs (CSR_REGS))
   rf_ram_if
     (.i_clk    (clk),
      .i_rst    (i_rst),
      .i_wreq   (rf_wreq),
      .i_rreq   (rf_rreq),
      .o_ready  (rf_ready),
      .i_wreg0  (wreg0),
      .i_wreg1  (wreg1),
      .i_wen0   (wen0),
      .i_wen1   (wen1),
      .i_wdata0 (wdata0),
      .i_wdata1 (wdata1),
      .i_rreg0  (rreg0),
      .i_rreg1  (rreg1),
      .o_rdata0 (rdata0),
      .o_rdata1 (rdata1),
      .o_waddr  (waddr),
      .o_wdata  (wdata),
      .o_wen    (wen),
      .o_raddr  (raddr),
      .o_ren    (ren),
      .i_rdata  (rdata));

   serv_rf_ram
     #(.width (RF_WIDTH),
       .csr_regs (CSR_REGS))
   rf_ram
     (.i_clk    (clk),
      .i_waddr (waddr),
      .i_wdata (wdata),
      .i_wen   (wen),
      .i_raddr (raddr),
      .i_ren    (ren),
      .o_rdata (rdata));

   serv_top
     #(.RESET_PC (RESET_PC),
       .PRE_REGISTER (PRE_REGISTER),
       .RESET_STRATEGY (RESET_STRATEGY),
       .WITH_CSR (WITH_CSR),
       .MDU(MDU),
       .COMPRESSED(COMPRESSED),
       .ALIGN(ALIGN))
   cpu
     (
      .clk      (clk),
      .i_rst    (i_rst),
      .i_timer_irq  (i_timer_irq),
`ifdef RISCV_FORMAL
      .rvfi_valid     (rvfi_valid    ),
      .rvfi_order     (rvfi_order    ),
      .rvfi_insn      (rvfi_insn     ),
      .rvfi_trap      (rvfi_trap     ),
      .rvfi_halt      (rvfi_halt     ),
      .rvfi_intr      (rvfi_intr     ),
      .rvfi_mode      (rvfi_mode     ),
      .rvfi_ixl       (rvfi_ixl      ),
      .rvfi_rs1_addr  (rvfi_rs1_addr ),
      .rvfi_rs2_addr  (rvfi_rs2_addr ),
      .rvfi_rs1_rdata (rvfi_rs1_rdata),
      .rvfi_rs2_rdata (rvfi_rs2_rdata),
      .rvfi_rd_addr   (rvfi_rd_addr  ),
      .rvfi_rd_wdata  (rvfi_rd_wdata ),
      .rvfi_pc_rdata  (rvfi_pc_rdata ),
      .rvfi_pc_wdata  (rvfi_pc_wdata ),
      .rvfi_mem_addr  (rvfi_mem_addr ),
      .rvfi_mem_rmask (rvfi_mem_rmask),
      .rvfi_mem_wmask (rvfi_mem_wmask),
      .rvfi_mem_rdata (rvfi_mem_rdata),
      .rvfi_mem_wdata (rvfi_mem_wdata),
`endif
      .o_rf_rreq   (rf_rreq),
      .o_rf_wreq   (rf_wreq),
      .i_rf_ready  (rf_ready),
      .o_wreg0     (wreg0),
      .o_wreg1     (wreg1),
      .o_wen0      (wen0),
      .o_wen1      (wen1),
      .o_wdata0    (wdata0),
      .o_wdata1    (wdata1),
      .o_rreg0     (rreg0),
      .o_rreg1     (rreg1),
      .i_rdata0    (rdata0),
      .i_rdata1    (rdata1),

      .o_ibus_adr   (o_ibus_adr),
      .o_ibus_cyc   (o_ibus_cyc),
      .i_ibus_rdt   (i_ibus_rdt),
      .i_ibus_ack   (i_ibus_ack),

      .o_dbus_adr   (o_dbus_adr),
      .o_dbus_dat   (o_dbus_dat),
      .o_dbus_sel   (o_dbus_sel),
      .o_dbus_we    (o_dbus_we),
      .o_dbus_cyc   (o_dbus_cyc),
      .i_dbus_rdt   (i_dbus_rdt),
      .i_dbus_ack   (i_dbus_ack),
      
      //Extension
      .o_ext_funct3 (o_ext_funct3),
      .i_ext_ready  (i_ext_ready),
      .i_ext_rd     (i_ext_rd),
      .o_ext_rs1    (o_ext_rs1),
      .o_ext_rs2    (o_ext_rs2),
      //MDU
      .o_mdu_valid  (o_mdu_valid));

endmodule
`default_nettype wire
module serv_state
  #(parameter RESET_STRATEGY = "MINI",
    parameter [0:0] WITH_CSR = 1,
    parameter [0:0] ALIGN =0,
    parameter [0:0] MDU = 0)
  (
   input wire 	     i_clk,
   input wire 	     i_rst,
   //State
   input wire 	     i_new_irq,
   input wire 	     i_alu_cmp,
   output wire 	     o_init,
   output wire 	     o_cnt_en,
   output wire 	     o_cnt0to3,
   output wire 	     o_cnt12to31,
   output wire 	     o_cnt0,
   output wire 	     o_cnt1,
   output wire 	     o_cnt2,
   output wire 	     o_cnt3,
   output wire 	     o_cnt7,
   output reg 	     o_cnt_done,
   output wire 	     o_bufreg_en,
   output wire 	     o_ctrl_pc_en,
   output reg 	     o_ctrl_jump,
   output wire 	     o_ctrl_trap,
   input wire 	     i_ctrl_misalign,
   input wire 	     i_sh_done,
   input wire 	     i_sh_done_r,
   output wire [1:0] o_mem_bytecnt,
   input wire 	     i_mem_misalign,
   //Control
   input wire 	     i_bne_or_bge,
   input wire 	     i_cond_branch,
   input wire 	     i_dbus_en,
   input wire 	     i_two_stage_op,
   input wire 	     i_branch_op,
   input wire 	     i_shift_op,
   input wire 	     i_sh_right,
   input wire 	     i_slt_or_branch,
   input wire 	     i_e_op,
   input wire 	     i_rd_op,
   //MDU
   input wire 	     i_mdu_op,
   output wire 	     o_mdu_valid,
   //Extension
   input wire 	     i_mdu_ready,
   //External
   output wire 	     o_dbus_cyc,
   input wire 	     i_dbus_ack,
   output wire 	     o_ibus_cyc,
   input wire 	     i_ibus_ack,
   //RF Interface
   output wire 	     o_rf_rreq,
   output wire 	     o_rf_wreq,
   input wire 	     i_rf_ready,
   output wire 	     o_rf_rd_en);

   reg 	stage_two_req;
   reg 	init_done;
   wire misalign_trap_sync;

   reg [4:2] o_cnt;
   reg [3:0] o_cnt_r;

   reg 	     ibus_cyc;
   //Update PC in RUN or TRAP states
   assign o_ctrl_pc_en  = o_cnt_en & !o_init;

   assign o_cnt_en = |o_cnt_r;

   assign o_mem_bytecnt = o_cnt[4:3];

   assign o_cnt0to3   = (o_cnt[4:2] == 3'd0);
   assign o_cnt12to31 = (o_cnt[4] | (o_cnt[3:2] == 2'b11));
   assign o_cnt0 = (o_cnt[4:2] == 3'd0) & o_cnt_r[0];
   assign o_cnt1 = (o_cnt[4:2] == 3'd0) & o_cnt_r[1];
   assign o_cnt2 = (o_cnt[4:2] == 3'd0) & o_cnt_r[2];
   assign o_cnt3 = (o_cnt[4:2] == 3'd0) & o_cnt_r[3];
   assign o_cnt7 = (o_cnt[4:2] == 3'd1) & o_cnt_r[3];

   //Take branch for jump or branch instructions (opcode == 1x0xx) if
   //a) It's an unconditional branch (opcode[0] == 1)
   //b) It's a conditional branch (opcode[0] == 0) of type beq,blt,bltu (funct3[0] == 0) and ALU compare is true
   //c) It's a conditional branch (opcode[0] == 0) of type bne,bge,bgeu (funct3[0] == 1) and ALU compare is false
   //Only valid during the last cycle of INIT, when the branch condition has
   //been calculated.
   wire      take_branch = i_branch_op & (!i_cond_branch | (i_alu_cmp^i_bne_or_bge));

   //valid signal for mdu
   assign o_mdu_valid = MDU & !o_cnt_en & init_done & i_mdu_op;

   //Prepare RF for writes when everything is ready to enter stage two
   // and the first stage didn't cause a misalign exception
   assign o_rf_wreq = !misalign_trap_sync & !o_cnt_en & init_done &
	   	      ((i_shift_op & (i_sh_done | !i_sh_right)) |
	   	       i_dbus_ack | (MDU & i_mdu_ready) |
	   	       i_slt_or_branch);

   assign o_dbus_cyc = !o_cnt_en & init_done & i_dbus_en & !i_mem_misalign;

   //Prepare RF for reads when a new instruction is fetched
   // or when stage one caused an exception (rreq implies a write request too)
   assign o_rf_rreq = i_ibus_ack | (stage_two_req & misalign_trap_sync);

   assign o_rf_rd_en = i_rd_op & !o_init;

   /*
    bufreg is used during mem. branch and shift operations

    mem : bufreg is used for dbus address. Shift in data during phase 1.
          Shift out during phase 2 if there was an misalignment exception.

    branch : Shift in during phase 1. Shift out during phase 2

    shift : Shift in during phase 1. Continue shifting between phases (except
            for the first cycle after init). Shift out during phase 2
    */
   assign o_bufreg_en = (o_cnt_en & (o_init | ((o_ctrl_trap | i_branch_op) & i_two_stage_op))) | (i_shift_op & !stage_two_req & (i_sh_right | i_sh_done_r) & init_done);

   assign o_ibus_cyc = ibus_cyc & !i_rst;

   assign o_init = i_two_stage_op & !i_new_irq & !init_done;

   always @(posedge i_clk) begin
      //ibus_cyc changes on three conditions.
      //1. i_rst is asserted. Together with the async gating above, o_ibus_cyc
      //   will be asserted as soon as the reset is released. This is how the
      //   first instruction is fetced
      //2. o_cnt_done and o_ctrl_pc_en are asserted. This means that SERV just
      //   finished updating the PC, is done with the current instruction and
      //   o_ibus_cyc gets asserted to fetch a new instruction
      //3. When i_ibus_ack, a new instruction is fetched and o_ibus_cyc gets
      //   deasserted to finish the transaction
      if (i_ibus_ack | o_cnt_done | i_rst)
	ibus_cyc <= o_ctrl_pc_en | i_rst;

      if (o_cnt_done) begin
	 init_done <= o_init & !init_done;
	 o_ctrl_jump <= o_init & take_branch;
      end
      o_cnt_done <= (o_cnt[4:2] == 3'b111) & o_cnt_r[2];

      //Need a strobe for the first cycle in the IDLE state after INIT
      stage_two_req <= o_cnt_done & o_init;

      /*
       Because SERV is 32-bit bit-serial we need a counter than can count 0-31
       to keep track of which bit we are currently processing. o_cnt and o_cnt_r
       are used together to create such a counter.
       The top three bits (o_cnt) are implemented as a normal counter, but
       instead of the two LSB, o_cnt_r is a 4-bit shift register which loops 0-3
       When o_cnt_r[3] is 1, o_cnt will be increased.

       The counting starts when the core is idle and the i_rf_ready signal
       comes in from the RF module by shifting in the i_rf_ready bit as LSB of
       the shift register. Counting is stopped by using o_cnt_done to block the
       bit that was supposed to be shifted into bit 0 of o_cnt_r.

       There are two benefit of doing the counter this way
       1. We only need to check four bits instead of five when we want to check
       if the counter is at a certain value. For 4-LUT architectures this means
       we only need one LUT instead of two for each comparison.
       2. We don't need a separate enable signal to turn on and off the counter
       between stages, which saves an extra FF and a unique control signal. We
       just need to check if o_cnt_r is not zero to see if the counter is
       currently running
       */
      o_cnt <= o_cnt + {2'd0,o_cnt_r[3]};
      o_cnt_r <= {o_cnt_r[2:0],(o_cnt_r[3] & !o_cnt_done) | (i_rf_ready & !o_cnt_en)};
      if (i_rst) begin
	 if (RESET_STRATEGY != "NONE") begin
	    o_cnt   <= 3'd0;
	    init_done <= 1'b0;
	    o_ctrl_jump <= 1'b0;
	    o_cnt_done <= 1'b0;
	    o_cnt_r <= 4'b0000;
	    stage_two_req <= 1'b0;
	 end
      end
   end

   assign o_ctrl_trap = WITH_CSR & (i_e_op | i_new_irq | misalign_trap_sync);

   generate
      if (WITH_CSR) begin
	 reg 	misalign_trap_sync_r;

	 //trap_pending is only guaranteed to have correct value during the
	 // last cycle of the init stage
	 wire trap_pending = WITH_CSR & ((take_branch & i_ctrl_misalign & !ALIGN) |
					 (i_dbus_en   & i_mem_misalign));

	 always @(posedge i_clk) begin
	    if (o_cnt_done)
	      misalign_trap_sync_r <= trap_pending & o_init;
	    if (i_rst)
	      if (RESET_STRATEGY != "NONE")
		misalign_trap_sync_r <= 1'b0;
	 end
	 assign misalign_trap_sync = misalign_trap_sync_r;
      end else
	assign misalign_trap_sync = 1'b0;
   endgenerate
endmodule
`default_nettype none

module serv_top
  #(parameter WITH_CSR = 1,
    parameter PRE_REGISTER = 1,
    parameter RESET_STRATEGY = "MINI",
    parameter RESET_PC = 32'd0,
    parameter [0:0] MDU = 1'b0,
    parameter [0:0] COMPRESSED=0,
    parameter [0:0] ALIGN = COMPRESSED)
   (
   input wire 		      clk,
   input wire 		      i_rst,
   input wire 		      i_timer_irq,
`ifdef RISCV_FORMAL
   output reg 		      rvfi_valid = 1'b0,
   output reg [63:0] 	      rvfi_order = 64'd0,
   output reg [31:0] 	      rvfi_insn = 32'd0,
   output reg 		      rvfi_trap = 1'b0,
   output reg 		      rvfi_halt = 1'b0,
   output reg 		      rvfi_intr = 1'b0,
   output reg [1:0] 	      rvfi_mode = 2'b11,
   output reg [1:0] 	      rvfi_ixl = 2'b01,
   output reg [4:0] 	      rvfi_rs1_addr,
   output reg [4:0] 	      rvfi_rs2_addr,
   output reg [31:0] 	      rvfi_rs1_rdata,
   output reg [31:0] 	      rvfi_rs2_rdata,
   output reg [4:0] 	      rvfi_rd_addr,
   output reg [31:0] 	      rvfi_rd_wdata,
   output reg [31:0] 	      rvfi_pc_rdata,
   output reg [31:0] 	      rvfi_pc_wdata,
   output reg [31:0] 	      rvfi_mem_addr,
   output reg [3:0] 	      rvfi_mem_rmask,
   output reg [3:0] 	      rvfi_mem_wmask,
   output reg [31:0] 	      rvfi_mem_rdata,
   output reg [31:0] 	      rvfi_mem_wdata,
`endif
   //RF Interface
   output wire 		      o_rf_rreq,
   output wire 		      o_rf_wreq,
   input wire 		      i_rf_ready,
   output wire [4+WITH_CSR:0] o_wreg0,
   output wire [4+WITH_CSR:0] o_wreg1,
   output wire 		      o_wen0,
   output wire 		      o_wen1,
   output wire 		      o_wdata0,
   output wire 		      o_wdata1,
   output wire [4+WITH_CSR:0] o_rreg0,
   output wire [4+WITH_CSR:0] o_rreg1,
   input wire 		      i_rdata0,
   input wire 		      i_rdata1,

   output wire [31:0] 	      o_ibus_adr,
   output wire 		      o_ibus_cyc,
   input wire [31:0] 	      i_ibus_rdt,
   input wire 		      i_ibus_ack,
   output wire [31:0] 	      o_dbus_adr,
   output wire [31:0] 	      o_dbus_dat,
   output wire [3:0] 	      o_dbus_sel,
   output wire 		      o_dbus_we ,
   output wire 		      o_dbus_cyc,
   input wire [31:0] 	      i_dbus_rdt,
   input wire 		      i_dbus_ack,
   //Extension
   output wire [ 2:0] o_ext_funct3,
   input  wire        i_ext_ready,
   input wire  [31:0] i_ext_rd,
   output wire [31:0] o_ext_rs1,
   output wire [31:0] o_ext_rs2,
   //MDU
   output wire        o_mdu_valid);

   wire [4:0]    rd_addr;
   wire [4:0]    rs1_addr;
   wire [4:0]    rs2_addr;

   wire [3:0] 	 immdec_ctrl;
   wire [3:0] 	immdec_en;

   wire          sh_right;
   wire 	 bne_or_bge;
   wire 	 cond_branch;
   wire 	 two_stage_op;
   wire 	 e_op;
   wire 	 ebreak;
   wire 	 branch_op;
   wire 	 shift_op;
   wire 	 slt_or_branch;
   wire 	 rd_op;
   wire   mdu_op;

   wire 	 rd_alu_en;
   wire 	 rd_csr_en;
   wire 	 rd_mem_en;
   wire          ctrl_rd;
   wire          alu_rd;
   wire          mem_rd;
   wire          csr_rd;
   wire 	 mtval_pc;

   wire          ctrl_pc_en;
   wire          jump;
   wire          jal_or_jalr;
   wire          utype;
   wire 	 mret;
   wire          imm;
   wire 	 trap;
   wire 	 pc_rel;
   wire          iscomp;

   wire          init;
   wire          cnt_en;
   wire 	 cnt0to3;
   wire 	 cnt12to31;
   wire          cnt0;
   wire          cnt1;
   wire          cnt2;
   wire          cnt3;
   wire          cnt7;

   wire 	 cnt_done;

   wire 	 bufreg_en;
   wire          bufreg_sh_signed;
   wire 	 bufreg_rs1_en;
   wire 	 bufreg_imm_en;
   wire 	 bufreg_clr_lsb;
   wire 	 bufreg_q;
   wire 	 bufreg2_q;
   wire [31:0] dbus_rdt;
   wire        dbus_ack;

   wire          alu_sub;
   wire [1:0] 	 alu_bool_op;
   wire          alu_cmp_eq;
   wire          alu_cmp_sig;
   wire          alu_cmp;
   wire [2:0]    alu_rd_sel;

   wire          rs1;
   wire          rs2;
   wire          rd_en;

   wire          op_b;
   wire          op_b_sel;

   wire          mem_signed;
   wire          mem_word;
   wire          mem_half;
   wire [1:0] 	 mem_bytecnt;
   wire 	 sh_done;
   wire 	 sh_done_r;
   wire 	 byte_valid;

   wire 	 mem_misalign;

   wire 	 bad_pc;

   wire 	 csr_mstatus_en;
   wire 	 csr_mie_en;
   wire 	 csr_mcause_en;
   wire [1:0]	 csr_source;
   wire 	 csr_imm;
   wire 	 csr_d_sel;
   wire 	 csr_en;
   wire [1:0] 	 csr_addr;
   wire 	 csr_pc;
   wire 	 csr_imm_en;
   wire 	 csr_in;
   wire 	 rf_csr_out;
   wire 	 dbus_en;

   wire 	 new_irq;

   wire [1:0]   lsb;

   wire [31:0] i_wb_rdt;

   wire [31:0] wb_ibus_adr;
   wire        wb_ibus_cyc;
   wire [31:0] wb_ibus_rdt;
   wire        wb_ibus_ack;

   generate
      if (ALIGN) begin
         serv_aligner  align
           (
            .clk(clk),
            .rst(i_rst),
            // serv_rf_top
            .i_ibus_adr(wb_ibus_adr),
            .i_ibus_cyc(wb_ibus_cyc),
            .o_ibus_rdt(wb_ibus_rdt),
            .o_ibus_ack(wb_ibus_ack),
            // servant_arbiter
            .o_wb_ibus_adr(o_ibus_adr),
            .o_wb_ibus_cyc(o_ibus_cyc),
            .i_wb_ibus_rdt(i_ibus_rdt),
            .i_wb_ibus_ack(i_ibus_ack));
      end else begin
         assign  o_ibus_adr  = wb_ibus_adr;
         assign  o_ibus_cyc  = wb_ibus_cyc;
         assign  wb_ibus_rdt = i_ibus_rdt;
         assign  wb_ibus_ack = i_ibus_ack;
        end
   endgenerate

   generate 
      if (COMPRESSED) begin
         serv_compdec compdec
           (
            .i_clk(clk),
            .i_instr(wb_ibus_rdt),
            .i_ack(wb_ibus_ack),
            .o_instr(i_wb_rdt),
            .o_iscomp(iscomp));
      end else begin
         assign i_wb_rdt =  wb_ibus_rdt;
         assign iscomp   =  1'b0;
      end
   endgenerate

   serv_state
     #(.RESET_STRATEGY (RESET_STRATEGY),
       .WITH_CSR (WITH_CSR[0:0]),
       .MDU(MDU),
       .ALIGN(ALIGN))
   state
     (
      .i_clk (clk),
      .i_rst          (i_rst),
      //State
      .i_new_irq      (new_irq),
      .i_alu_cmp      (alu_cmp),
      .o_init         (init),
      .o_cnt_en       (cnt_en),
      .o_cnt0to3      (cnt0to3),
      .o_cnt12to31    (cnt12to31),
      .o_cnt0         (cnt0),
      .o_cnt1         (cnt1),
      .o_cnt2         (cnt2),
      .o_cnt3         (cnt3),
      .o_cnt7         (cnt7),
      .o_cnt_done     (cnt_done),
      .o_bufreg_en    (bufreg_en),
      .o_ctrl_pc_en   (ctrl_pc_en),
      .o_ctrl_jump    (jump),
      .o_ctrl_trap    (trap),
      .i_ctrl_misalign(lsb[1]),
      .i_sh_done      (sh_done),
      .i_sh_done_r    (sh_done_r),
      .o_mem_bytecnt  (mem_bytecnt),
      .i_mem_misalign (mem_misalign),
      //Control
      .i_bne_or_bge   (bne_or_bge),
      .i_cond_branch  (cond_branch),
      .i_dbus_en      (dbus_en),
      .i_two_stage_op (two_stage_op),
      .i_branch_op    (branch_op),
      .i_shift_op     (shift_op),
      .i_sh_right     (sh_right),
      .i_slt_or_branch (slt_or_branch),
      .i_e_op         (e_op),
      .i_rd_op        (rd_op),
      //MDU
      .i_mdu_op       (mdu_op),
      .o_mdu_valid    (o_mdu_valid),
      //Extension
      .i_mdu_ready    (i_ext_ready),
      //External
      .o_dbus_cyc     (o_dbus_cyc),
      .i_dbus_ack     (i_dbus_ack),
      .o_ibus_cyc     (wb_ibus_cyc),
      .i_ibus_ack     (wb_ibus_ack),
      //RF Interface
      .o_rf_rreq      (o_rf_rreq),
      .o_rf_wreq      (o_rf_wreq),
      .i_rf_ready     (i_rf_ready),
      .o_rf_rd_en     (rd_en));

   serv_decode
     #(.PRE_REGISTER (PRE_REGISTER),
       .MDU(MDU))
   decode
     (
      .clk (clk),
      //Input
      .i_wb_rdt           (i_wb_rdt[31:2]),
      .i_wb_en            (wb_ibus_ack),
      //To state
      .o_bne_or_bge       (bne_or_bge),
      .o_cond_branch      (cond_branch),
      .o_dbus_en          (dbus_en),
      .o_e_op             (e_op),
      .o_ebreak           (ebreak),
      .o_branch_op        (branch_op),
      .o_shift_op         (shift_op),
      .o_slt_or_branch    (slt_or_branch),
      .o_rd_op            (rd_op),
      .o_sh_right         (sh_right),
      .o_mdu_op           (mdu_op),
      .o_two_stage_op     (two_stage_op),
      //Extension
      .o_ext_funct3       (o_ext_funct3),

      //To bufreg
      .o_bufreg_rs1_en    (bufreg_rs1_en),
      .o_bufreg_imm_en    (bufreg_imm_en),
      .o_bufreg_clr_lsb   (bufreg_clr_lsb),
      .o_bufreg_sh_signed (bufreg_sh_signed),
      //To bufreg2
      .o_op_b_source      (op_b_sel),
      //To ctrl
      .o_ctrl_jal_or_jalr (jal_or_jalr),
      .o_ctrl_utype       (utype),
      .o_ctrl_pc_rel      (pc_rel),
      .o_ctrl_mret        (mret),
      //To alu
      .o_alu_sub          (alu_sub),
      .o_alu_bool_op      (alu_bool_op),
      .o_alu_cmp_eq       (alu_cmp_eq),
      .o_alu_cmp_sig      (alu_cmp_sig),
      .o_alu_rd_sel       (alu_rd_sel),
      //To mem IF
      .o_mem_cmd          (o_dbus_we),
      .o_mem_signed       (mem_signed),
      .o_mem_word         (mem_word),
      .o_mem_half         (mem_half),
      //To CSR
      .o_csr_en           (csr_en),
      .o_csr_addr         (csr_addr),
      .o_csr_mstatus_en   (csr_mstatus_en),
      .o_csr_mie_en       (csr_mie_en),
      .o_csr_mcause_en    (csr_mcause_en),
      .o_csr_source       (csr_source),
      .o_csr_d_sel        (csr_d_sel),
      .o_csr_imm_en       (csr_imm_en),
      .o_mtval_pc         (mtval_pc      ),
      //To top
      .o_immdec_ctrl      (immdec_ctrl),
      .o_immdec_en        (immdec_en),
      //To RF IF
      .o_rd_mem_en        (rd_mem_en),
      .o_rd_csr_en        (rd_csr_en),
      .o_rd_alu_en        (rd_alu_en));

   serv_immdec immdec
     (
      .i_clk        (clk),
      //State
      .i_cnt_en     (cnt_en),
      .i_cnt_done   (cnt_done),
      //Control
      .i_immdec_en        (immdec_en),
      .i_csr_imm_en (csr_imm_en),
      .i_ctrl       (immdec_ctrl),
      .o_rd_addr    (rd_addr),
      .o_rs1_addr   (rs1_addr),
      .o_rs2_addr   (rs2_addr),
      //Data
      .o_csr_imm    (csr_imm),
      .o_imm        (imm),
      //External
      .i_wb_en      (wb_ibus_ack),
      .i_wb_rdt     (i_wb_rdt[31:7]));

   serv_bufreg
      #(.MDU(MDU))
   bufreg
     (
      .i_clk    (clk),
      //State
      .i_cnt0   (cnt0),
      .i_cnt1   (cnt1),
      .i_en     (bufreg_en),
      .i_init   (init),
      .i_mdu_op (mdu_op),
      .o_lsb    (lsb),
      //Control
      .i_sh_signed (bufreg_sh_signed),
      .i_rs1_en    (bufreg_rs1_en),
      .i_imm_en    (bufreg_imm_en),
      .i_clr_lsb   (bufreg_clr_lsb),
      //Data
      .i_rs1    (rs1),
      .i_imm    (imm),
      .o_q      (bufreg_q),
      //External
      .o_dbus_adr (o_dbus_adr),
      .o_ext_rs1  (o_ext_rs1));

   serv_bufreg2 bufreg2
     (
      .i_clk        (clk),
      //State
      .i_en         (cnt_en),
      .i_init       (init),
      .i_cnt_done   (cnt_done),
      .i_lsb        (lsb),
      .i_byte_valid (byte_valid),
      .o_sh_done    (sh_done),
      .o_sh_done_r  (sh_done_r),
      //Control
      .i_op_b_sel   (op_b_sel),
      .i_shift_op   (shift_op),
      //Data
      .i_rs2        (rs2),
      .i_imm        (imm),
      .o_op_b       (op_b),
      .o_q          (bufreg2_q),
      //External
      .o_dat        (o_dbus_dat),
      .i_load       (dbus_ack),
      .i_dat        (dbus_rdt));

   serv_ctrl
     #(.RESET_PC (RESET_PC),
       .RESET_STRATEGY (RESET_STRATEGY),
       .WITH_CSR (WITH_CSR))
   ctrl
     (
      .clk        (clk),
      .i_rst      (i_rst),
      //State
      .i_pc_en    (ctrl_pc_en),
      .i_cnt12to31 (cnt12to31),
      .i_cnt0     (cnt0),
      .i_cnt1     (cnt1),
      .i_cnt2     (cnt2),
      //Control
      .i_jump     (jump),
      .i_jal_or_jalr (jal_or_jalr),
      .i_utype    (utype),
      .i_pc_rel   (pc_rel),
      .i_trap     (trap | mret),
      .i_iscomp    (iscomp),
      //Data
      .i_imm      (imm),
      .i_buf      (bufreg_q),
      .i_csr_pc   (csr_pc),
      .o_rd       (ctrl_rd),
      .o_bad_pc   (bad_pc),
      //External
      .o_ibus_adr (wb_ibus_adr));

   serv_alu alu
     (
      .clk        (clk),
      //State
      .i_en       (cnt_en),
      .i_cnt0     (cnt0),
      .o_cmp      (alu_cmp),
      //Control
      .i_sub      (alu_sub),
      .i_bool_op  (alu_bool_op),
      .i_cmp_eq   (alu_cmp_eq),
      .i_cmp_sig  (alu_cmp_sig),
      .i_rd_sel   (alu_rd_sel),
      //Data
      .i_rs1      (rs1),
      .i_op_b     (op_b),
      .i_buf      (bufreg_q),
      .o_rd       (alu_rd));

   serv_rf_if
     #(.WITH_CSR (WITH_CSR))
   rf_if
     (//RF interface
      .i_cnt_en    (cnt_en),
      .o_wreg0     (o_wreg0),
      .o_wreg1     (o_wreg1),
      .o_wen0      (o_wen0),
      .o_wen1      (o_wen1),
      .o_wdata0    (o_wdata0),
      .o_wdata1    (o_wdata1),
      .o_rreg0     (o_rreg0),
      .o_rreg1     (o_rreg1),
      .i_rdata0    (i_rdata0),
      .i_rdata1    (i_rdata1),

      //Trap interface
      .i_trap      (trap),
      .i_mret      (mret),
      .i_mepc      (wb_ibus_adr[0]),
      .i_mtval_pc  (mtval_pc),
      .i_bufreg_q  (bufreg_q),
      .i_bad_pc    (bad_pc),
      .o_csr_pc    (csr_pc),
      //CSR write port
      .i_csr_en    (csr_en),
      .i_csr_addr  (csr_addr),
      .i_csr       (csr_in),
      //RD write port
      .i_rd_wen    (rd_en),
      .i_rd_waddr  (rd_addr),
      .i_ctrl_rd   (ctrl_rd),
      .i_alu_rd    (alu_rd),
      .i_rd_alu_en (rd_alu_en),
      .i_csr_rd    (csr_rd),
      .i_rd_csr_en (rd_csr_en),
      .i_mem_rd    (mem_rd),
      .i_rd_mem_en (rd_mem_en),

      //RS1 read port
      .i_rs1_raddr (rs1_addr),
      .o_rs1       (rs1),
      //RS2 read port
      .i_rs2_raddr (rs2_addr),
      .o_rs2       (rs2),

      //CSR read port
      .o_csr       (rf_csr_out));

   serv_mem_if
     #(.WITH_CSR (WITH_CSR[0:0]))
   mem_if
     (
      .i_clk        (clk),
      //State
      .i_bytecnt    (mem_bytecnt),
      .i_lsb        (lsb),
      .o_byte_valid (byte_valid),
      .o_misalign   (mem_misalign),
      //Control
      .i_mdu_op     (mdu_op),
      .i_signed     (mem_signed),
      .i_word       (mem_word),
      .i_half       (mem_half),
      //Data
      .i_bufreg2_q  (bufreg2_q),
      .o_rd         (mem_rd),
      //External interface
      .o_wb_sel     (o_dbus_sel));

   generate
      if (|WITH_CSR) begin
	 serv_csr
	   #(.RESET_STRATEGY (RESET_STRATEGY))
	 csr
	   (
	    .i_clk        (clk),
	    .i_rst        (i_rst),
	    //State
	    .i_init       (init),
	    .i_en         (cnt_en),
	    .i_cnt0to3    (cnt0to3),
	    .i_cnt3       (cnt3),
	    .i_cnt7       (cnt7),
	    .i_cnt_done   (cnt_done),
	    .i_mem_op     (!mtval_pc),
	    .i_mtip       (i_timer_irq),
	    .i_trap       (trap),
	    .o_new_irq    (new_irq),
	    //Control
	    .i_e_op       (e_op),
	    .i_ebreak     (ebreak),
	    .i_mem_cmd    (o_dbus_we),
	    .i_mstatus_en (csr_mstatus_en),
	    .i_mie_en     (csr_mie_en    ),
	    .i_mcause_en  (csr_mcause_en ),
	    .i_csr_source (csr_source),
	    .i_mret       (mret),
	    .i_csr_d_sel  (csr_d_sel),
	    //Data
	    .i_rf_csr_out (rf_csr_out),
	    .o_csr_in     (csr_in),
	    .i_csr_imm    (csr_imm),
	    .i_rs1        (rs1),
	    .o_q          (csr_rd));
      end else begin
	 assign csr_in = 1'b0;
	 assign csr_rd = 1'b0;
	 assign new_irq = 1'b0;
      end
   endgenerate


`ifdef RISCV_FORMAL
   reg [31:0] 	 pc = RESET_PC;

   wire rs_en = two_stage_op ? init : ctrl_pc_en;

   always @(posedge clk) begin
      /* End of instruction */
      rvfi_valid <= cnt_done & ctrl_pc_en & !i_rst;
      rvfi_order <= rvfi_order + {63'd0,rvfi_valid};

      /* Get instruction word when it's fetched from ibus */
      if (wb_ibus_cyc & wb_ibus_ack)
	rvfi_insn <= i_wb_rdt;

      /* Store data written to rd */
      if (o_wen0)
        rvfi_rd_wdata <= {o_wdata0,rvfi_rd_wdata[31:1]};

      if (cnt_done & ctrl_pc_en) begin
         rvfi_pc_rdata <= pc;
	 if (!(rd_en & (|rd_addr))) begin
	   rvfi_rd_addr <= 5'd0;
	   rvfi_rd_wdata <= 32'd0;
	 end
      end
      rvfi_trap <= trap;
      if (rvfi_valid) begin
         rvfi_trap <= 1'b0;
         pc <= rvfi_pc_wdata;
      end

      /* Not used */
      rvfi_halt <= 1'b0;
      rvfi_intr <= 1'b0;
      rvfi_mode <= 2'd3;
      rvfi_ixl = 2'd1;

      /* RS1 not valid during J, U instructions (immdec_en[1]) */
      /* RS2 not valid during I, J, U instructions (immdec_en[2]) */
      if (i_rf_ready) begin
	 rvfi_rs1_addr <= !immdec_en[1] ? rs1_addr : 5'd0;
         rvfi_rs2_addr <= !immdec_en[2] /*rs2_valid*/ ? rs2_addr : 5'd0;
	 rvfi_rd_addr  <= rd_addr;
      end
      if (rs_en) begin
         rvfi_rs1_rdata <= {!immdec_en[1] & rs1,rvfi_rs1_rdata[31:1]};
         rvfi_rs2_rdata <= {!immdec_en[2] & rs2,rvfi_rs2_rdata[31:1]};
      end

      if (i_dbus_ack) begin
         rvfi_mem_addr <= o_dbus_adr;
         rvfi_mem_rmask <= o_dbus_we ? 4'b0000 : o_dbus_sel;
         rvfi_mem_wmask <= o_dbus_we ? o_dbus_sel : 4'b0000;
         rvfi_mem_rdata <= i_dbus_rdt;
         rvfi_mem_wdata <= o_dbus_dat;
      end
      if (wb_ibus_ack) begin
         rvfi_mem_rmask <= 4'b0000;
         rvfi_mem_wmask <= 4'b0000;
      end
   end
   /* verilator lint_off COMBDLY */
   always @(wb_ibus_adr)
     rvfi_pc_wdata <= wb_ibus_adr;
   /* verilator lint_on COMBDLY */


`endif

generate
  if (MDU) begin
    assign dbus_rdt = i_ext_ready ? i_ext_rd:i_dbus_rdt;
    assign dbus_ack = i_dbus_ack | i_ext_ready;
  end else begin
    assign dbus_rdt = i_dbus_rdt;
    assign dbus_ack = i_dbus_ack;
  end
  assign o_ext_rs2 = o_dbus_dat;
endgenerate

endmodule
`default_nettype wire
`default_nettype none

`ifdef SIM
	`include `CONFIG_PATH
`else
	`include "./config.txt"
`endif

module accelerator_if #(
	parameter WEIGHT_DEPTH_12 = 8192,
	parameter WEIGHT_DEPTH_34 = 8192,
	parameter CHANNELS = 16,
	parameter MAX_NEURONS = 128,
	parameter MAX_SYNAPSES = 128
)
(
	input wire 		   i_wb_clk,
	input wire		   i_wb_rst,

	//from servant_mux, when i_wb_adr[31:30] == 2'b01
	input wire 	[31:0] i_wb_adr,
	input wire 	[31:0] i_wb_dat,
	input wire 		   i_wb_we,
	input wire 		   i_wb_cyc,
	output reg 	[31:0] o_wb_rdt,
	output 		   o_wb_ack,

	// snn
	input wire		   i_snn_valid,
	output output_buffer_ren,
	output [7:0] output_buffer_addr,
	input [31:0] output_buffer_out,
	output wire [31:0] o_snn_adr_w1,
	output wire [31:0] o_snn_adr_w2,
	output wire [31:0] o_snn_adr_w3,
	output wire [31:0] o_snn_adr_w4,
	output wire [ 4:0] o_snn_we,
	output wire [15:0] o_snn_dat,
	output reg  [clogb2(MAX_SYNAPSES-1)-1:0] snn_input_channels, 
	output reg  [clogb2(MAX_NEURONS-1)-1:0] neuron_1, neuron_2, neuron_3, neuron_4, 
	/*neuron_5, neuron_6, neuron_7, neuron_8,*/
	output reg  [2:0] layers,

	// spi
	input  wire [ 7:0] i_spi_dat,
	output wire [23:0] o_spi_adr,
	output wire [31:0] o_spi_siz,

	// ctrl
	input wire		   i_ctrl_clr,
	input wire		   i_ctrl_load1,
	input wire		   i_ctrl_load2,
	input wire 		   i_ctrl_set0,
	input wire		   i_ctrl_snn_we,
	output wire		   o_ctrl_start,

	// uart
	input wire		   i_uart_ready,
	output reg  [ 7:0] o_uart_data,
	output reg		   o_uart_send, 
	output reg		   o_uart_wren,
	output reg 		   o_uart_hp,

	//spike mem 1 & 2
	input wire [7:0] i_spike_mem_dat,
	output wire [7:0] o_spike_mem_adr,
	output wire [1:0] o_spike_mem_rd_en,
	output wire [1:0] o_spike_mem_wr_en,
	output wire [3:0] o_spike_mem_dat,

	// sample mem
	input wire [15:0]  i_sample_mem_dat,	
	output wire [7:0]  o_sample_mem_adr,
	output wire        o_sample_mem_rd_en,
	output wire        o_sample_mem_wr_en,
	output wire [15:0] o_sample_mem_dat,
	
	// encoding bypass
	output reg o_encoding_bypass,

	// gate clocks
	output reg gate_spi, gate_snn, gate_enc, gate_serv, 
	output wire gate_general, 
	input wire timer_irq,
	
	output enable_next_debug
	);
	
	assign enable_next_debug = enable_next ;

	reg [ 7:0] data1, data2;
	reg [23:0] spi_address;
	reg [31:0] snn_address;
	reg [31:0] spi_read_size;
	reg [ 4:0] snn_write_enable;
	reg 	   spi_start;
	reg		   enable_next;
	reg		   uart_send_next;

	wire [31:0] snn_adr;

	reg gate_serv_armed;
	reg gate_general_int;
/*
	initial gate_spi = 0;
	initial gate_snn = 0;
	initial gate_enc = 0;
	initial gate_serv = 0;
	
	initial gate_serv_armed = 0;
	initial gate_general_int = 0;
	initial snn_valid_rst = 0;
	initial o_uart_hp = 0;
	initial o_uart_data = 0;
*/
	assign gate_general = ~(gate_serv & gate_general_int);

	// bram read requires an extra clock cycle (sample mem) or two (spike mem) 
	// => ack is delayed by 2 c.c if spike mems are accessed, and by 1 c.c. otherwise 
	reg o_wb_ack_int, o_wb_ack_d, o_wb_ack_dd; 
	reg [7:0] i_wb_adr_d;
	always @(posedge i_wb_clk) begin
			o_wb_ack_int <= 1'b0;
			o_wb_ack_d <= o_wb_ack_int;
			o_wb_ack_dd <= o_wb_ack_d;
			i_wb_adr_d <= i_wb_adr[27:20];
			spi_start <= enable_next;
		
		
	        	if (i_wb_cyc & !o_wb_ack & !o_wb_ack_d & !o_wb_ack_dd)
				o_wb_ack_int <= 1'b1;
				
			if (i_wb_rst) begin
				o_wb_ack_int <= 1'b0;
				o_wb_ack_d <= 1'b0;
				o_wb_ack_dd <= 1'b0;
				i_wb_adr_d <= 0;
				
				
				//aggiunti dopo 
				
				spi_start <= 0;
				
				gate_spi  <= 0;
				gate_snn  <= 0;
				gate_enc  <= 0;
				//gate_serv <= 0;
				//gate_serv_armed  <= 0;  //forse da reinserire da qualche altra parte 
				//gate_general_int <= 0;
				snn_valid_rst    <= 0;
				o_uart_hp        <= 0;
				o_uart_data      <= 0;
			end
   end
   
   wire rst_asinc_gate_serv;
   assign rst_asinc_gate_serv = timer_irq || i_wb_rst;
	
	always @(posedge i_wb_clk, posedge rst_asinc_gate_serv)
		if(rst_asinc_gate_serv)
			gate_serv <= 1'b0;
		else if(gate_serv_armed) 
				gate_serv <= 1'b1;

	assign o_wb_ack = (i_wb_adr_d == 8'h03 | i_wb_adr_d == 8'h04 | i_wb_adr_d == 8'h05 | i_wb_adr_d == 8'h01) ? o_wb_ack_d : o_wb_ack_int ;	

	assign o_snn_adr_w1 = snn_adr;
	assign o_snn_adr_w2 = snn_adr;
	assign o_snn_adr_w3 = snn_adr;
	assign o_snn_adr_w4 = snn_adr;
	reg snn_valid, snn_valid_rst;
	
	
	always @(posedge i_wb_clk) begin
		if(i_wb_rst)
			snn_valid <= 0;
		else if(i_snn_valid)
				 snn_valid <= i_snn_valid;
			 else if(snn_valid_rst)
					snn_valid <= 0;
	end

	assign o_snn_dat		= {data1, data2};
	assign o_spi_adr		= spi_address;
	assign o_spi_siz		= {spi_read_size, 3'b000}; // convert from bytes to bits
	assign o_ctrl_start		= spi_start;
	assign o_snn_we		= snn_write_enable;
	
		
	always @(posedge i_wb_clk)
		if(i_wb_rst)
			o_uart_wren <= 0;
		else
			o_uart_wren <= (i_wb_adr[27:16] == 12'h021) && (i_wb_cyc & i_wb_we & o_wb_ack); // && o_uart_hp

	`ifdef ACCESSIBILITY
		`ifdef SIM initial $display("ACCESSIBILITY IS DEFINED"); `endif

		assign o_spike_mem_adr = i_wb_adr[8:2];
	 	assign o_spike_mem_rd_en[0]  = (i_wb_adr[27:20] == 8'h03) && (i_wb_cyc); // spike mem 1
		assign o_spike_mem_rd_en[1]  = (i_wb_adr[27:20] == 8'h04) && (i_wb_cyc); // spike mem 2
		assign o_spike_mem_wr_en[0]  = (i_wb_adr[27:20] == 8'h03) && (i_wb_cyc && i_wb_we); // spike mem 1
		assign o_spike_mem_wr_en[1]  = (i_wb_adr[27:20] == 8'h04) && (i_wb_cyc && i_wb_we); // spike mem 2
		assign o_spike_mem_dat       = i_wb_dat[3:0];

		assign o_sample_mem_adr =     i_wb_adr[8:2];
		assign o_sample_mem_rd_en  = (i_wb_adr[27:20] == 8'h05) && (i_wb_cyc); // sample mem	
		assign o_sample_mem_wr_en  = (i_wb_adr[27:20] == 8'h05) && (i_wb_cyc && i_wb_we);
		assign o_sample_mem_dat    =  i_wb_dat[15:0];

		assign output_buffer_addr =   i_wb_adr[9:2];
		assign output_buffer_ren  = (i_wb_adr[27:16] == 12'h010) && (i_wb_cyc); // output buffer mem	
	`else
		assign o_spike_mem_rd_en = 0;	
		assign o_spike_mem_wr_en = 0;
		assign o_sample_mem_rd_en = 0;	
		assign o_sample_mem_wr_en = 0;
	`endif

	always @(posedge i_wb_clk) begin
		
		gate_serv_armed = 0; // auto reset after 1 c.c.
		case (i_wb_adr[27:20])
			//////// SPI ///////
			8'h00: begin								
				case (i_wb_adr[19:16])				
					4'h0: begin	o_wb_rdt <= {8'h0, spi_address};
						if (i_wb_we & i_wb_cyc) begin
							spi_address <= i_wb_dat;
						end
					end	
					4'h1: begin								// snn address
						o_wb_rdt <= snn_address;	
						if (i_wb_we & i_wb_cyc) begin
							snn_address <= i_wb_dat;
						end
					end
					4'h2: begin								// spi read size
						o_wb_rdt <= spi_read_size;
						if (i_wb_we & i_wb_cyc) begin
							spi_read_size <= i_wb_dat;
						end
					end
					4'h3: begin
						o_wb_rdt <= {31'h0, spi_start};		// spi start
					end
				endcase
			end
			//////// OUTPUT BUFFER ///////
			8'h01: begin			
				case (i_wb_adr[19:16])
					
					4'h0: begin							// v
						o_wb_rdt <= output_buffer_out;
					end
					/*
					4'h1: begin							// f1
						o_wb_rdt <= {16'h0, i_snn_f1};
					end
					4'h2: begin							// f2
						o_wb_rdt <= {16'h0, i_snn_f2};
					end
					4'h3: begin							// f3
						o_wb_rdt <= {16'h0, i_snn_f3};
					end
					4'h4: begin							// f4
						o_wb_rdt <= {16'h0, i_snn_f4};
					end
					*/
					4'hf: begin							// valid inference
						o_wb_rdt <= {16'h0, snn_valid}; 
					end
					4'he: begin							// valid inference reset
						o_wb_rdt <= {31'b0,snn_valid_rst};
						if (i_wb_cyc & o_wb_ack) begin
							snn_valid_rst <= i_wb_dat[0];
						end
					end
				endcase
			end
			///////////////////////////////////////////////////////////////////////			
			`ifndef UART_HP //////// UART ///////
			///////////////////////////////////////////////////////////////////////
			8'h02: begin			
				case (i_wb_adr[19:16])
					4'h0: begin										// o_uart_data
						o_wb_rdt <= {24'h0, o_uart_data};
						if (i_wb_cyc & i_wb_we) begin
							o_uart_data <= i_wb_dat;
						end
					end
					4'h1: begin
						o_wb_rdt <= {31'h0, o_uart_send};			// i_uart_send
					end
					4'h2: begin
						o_wb_rdt <= {31'h0, i_uart_ready};			// i_uart_ready
					end 
					4'h3: begin										// o_uart_hp high performance
						o_wb_rdt <= {31'h0, o_uart_hp};
						if (i_wb_cyc & i_wb_we) begin
							o_uart_hp <= i_wb_dat[0];
						end
					end
				endcase
			end

			`endif
		
			///////////////////////////////////////////////////////////////////////
			///////////////////////////////////////////////////////////////////////

			///////////////////////////////////////////////////////////////////////
			`ifdef ACCESSIBILITY
			///////////////////////////////////////////////////////////////////////

			8'h03: begin									// spike_mem_1
				o_wb_rdt <= {28'b0,i_spike_mem_dat[3:0]};	
			end
			8'h04: begin
				o_wb_rdt <= {28'b0,i_spike_mem_dat[7:4]};   // spike_mem_2
			end
			8'h05: begin
				o_wb_rdt <= {16'b0,i_sample_mem_dat};       // sample_mem
			end
			
			//////// ENCODING SETTINGS ///////
			8'h06: begin			
				case (i_wb_adr[19:16])
					4'h0: begin
						if (i_wb_cyc & i_wb_we) 			// encoding bypass
							o_encoding_bypass <= i_wb_dat[0];			
					end
				endcase
			end
			
			`endif
		
			///////////////////////////////////////////////////////////////////////
			///////////////////////////////////////////////////////////////////////
			
			///////////////////////////////////////////////////////////////////////
			`ifdef CONFIGURABILITY
			///////////////////////////////////////////////////////////////////////

			//////// SNN SETTINGS ///////
			8'h07: begin			
				case (i_wb_adr[19:16])
					4'h0: begin
						if (i_wb_cyc & i_wb_we) 			// snn_input_channels
							snn_input_channels <= i_wb_dat[clogb2(MAX_SYNAPSES-1)-1:0];			
					end
					4'h1: begin
						if (i_wb_cyc & i_wb_we) 			// #neuron L1
							neuron_1 <= i_wb_dat[clogb2(MAX_NEURONS-1)-1:0];			
					end
					4'h2: begin
						if (i_wb_cyc & i_wb_we) 			// #neuron L2
							neuron_2 <= i_wb_dat[clogb2(MAX_NEURONS-1)-1:0];			
					end
					4'h3: begin
						if (i_wb_cyc & i_wb_we) 			// #neuron L3
							neuron_3 <= i_wb_dat[clogb2(MAX_NEURONS-1)-1:0];			
					end
					4'h4: begin
						if (i_wb_cyc & i_wb_we) 			// #neuron L4
							neuron_4 <= i_wb_dat[clogb2(MAX_NEURONS-1)-1:0];			
					end

					4'h9: begin
						if (i_wb_cyc & i_wb_we) 			// #layer
							layers <= i_wb_dat[2:0];			
					end			
				endcase
			end

			`endif
			
			///////////////////////////////////////////////////////////////////////
			///////////////////////////////////////////////////////////////////////
			
			///////////////////////////////////////////////////////////////////////
			`ifdef LOW_POWER
			///////////////////////////////////////////////////////////////////////

			//////// GATE CLOCK ///////
			8'h08: begin
					o_wb_rdt <= {27'b0,gate_general_int,gate_serv_armed,gate_enc,gate_snn,gate_spi};
					if (i_wb_cyc & i_wb_we) begin
							gate_spi <= i_wb_dat[0];
							gate_snn <= i_wb_dat[1];
							gate_enc <= i_wb_dat[2];	
							gate_serv_armed = i_wb_dat[3];
							gate_general_int <= i_wb_dat[4];
					end
			end

			`endif
			
			///////////////////////////////////////////////////////////////////////
			///////////////////////////////////////////////////////////////////////

			default: begin
				o_wb_rdt <= 32'h0;
			end

		endcase

		if (i_ctrl_load1) begin						// load data1
			data1 <= i_spi_dat;
		end	

		if (i_ctrl_load2) 							// load data2
			data2 <= i_spi_dat;		



		o_uart_send <= uart_send_next;

	end

	always @(*) begin
		if (i_ctrl_set0) begin							// reset spi_start
			enable_next = 0;
		end
		else if (i_wb_adr[27:16] == 12'h003 && i_wb_we && i_wb_cyc) begin
			enable_next = i_wb_dat[0];
		end
		else begin
			enable_next = spi_start;
		end

		if (i_wb_adr[27:16] == 12'h021 && i_wb_we && i_wb_cyc) begin
			uart_send_next = i_wb_dat;
		end
		else begin
			uart_send_next = 0;
		end
	end

	// combinatorial logic for write enables and addresses for snn
	always @(*) begin
		if (i_ctrl_snn_we) begin
			case (snn_address)
				1: begin
					snn_write_enable = 5'b00001;
				end
				2: begin
					snn_write_enable = 5'b00010;
				end
				3: begin
					snn_write_enable = 5'b00100;
				end
				4: begin
					snn_write_enable = 5'b01000;
				end
				5: begin
					snn_write_enable = 5'b10000;
				end
				default: begin
					snn_write_enable = 5'b00000;
				end
			endcase
		end
		else begin
			snn_write_enable = 5'b00000;
		end
	end

	snn_addr_counter #(
		.DEPTH(max3(WEIGHT_DEPTH_12, WEIGHT_DEPTH_34, CHANNELS))
	)
	snn_addr_counter
	(
		.clk	(i_wb_clk),
		.rst	(i_wb_rst),
		.clr	(i_ctrl_clr),
		.inc	(i_ctrl_snn_we),
		.addr	(snn_adr)
	);

	//  The following function calculates the address width based on specified RAM depth
	function integer clogb2;
	  input integer depth;
		for (clogb2=0; depth>0; clogb2=clogb2+1)
		  depth = depth >> 1;
	endfunction 

	function integer max3;
  		input integer a,b,c;
    		if (a>b)
      			if (a>c)
        			max3 = a;
      			else
        			max3 = c;
    		else if (b>c)
        		max3 = b;
      		else
        		max3 = c;
	endfunction 

endmodule
`default_nettype none
module accelerator_top #(
	parameter WEIGHT_DEPTH_12 = 8192,
	parameter WEIGHT_DEPTH_34 = 8192,
	parameter CHANNELS = 16,
	parameter MAX_NEURONS = 128,
	parameter MAX_SYNAPSES = 128,
	parameter pClockFrequency = 24000000,
	parameter DOUBLE_CLOCK = 0,
	parameter UART_QUEUE = 16
)
(
	// cpu
	input  wire         wb_clk,
	input  wire         spi_clk,
	input  wire         wb_rst,
	input  wire [31:0]  i_cpu_adr,
	input  wire [31:0]  i_cpu_dat,
	input  wire         i_cpu_we,
	input  wire         i_cpu_cyc,
	output wire [31:0]  o_cpu_rdt,
	output  wire 		o_cpu_ack,

	// flash
	output wire         o_flash_sck,
	output wire         o_flash_mosi,
	output wire         o_flash_ss,
	input  wire         i_flash_miso,

	// snn
	input wire         i_snn_valid,
	output             output_buffer_ren,
	output       [7:0] output_buffer_addr,
	input       [31:0] output_buffer_out,
	output wire [31:0] o_snn_adr_w1,
	output wire [31:0] o_snn_adr_w2,
	output wire [31:0] o_snn_adr_w3,
	output wire [31:0] o_snn_adr_w4,
	output wire [ 4:0] o_snn_we,
	output wire [15:0] o_snn_dat,
	output wire [clogb2(MAX_SYNAPSES-1)-1:0] snn_input_channels, 
	output wire [clogb2(MAX_NEURONS-1)-1:0] neuron_1, neuron_2, neuron_3, neuron_4, 
	output wire [2:0] layers,

	// uart
	output wire         o_txd,

	//spike mem 1 & 2
	input  wire [7:0] i_spike_mem_dat,
	output wire [7:0] o_spike_mem_adr,
	output wire [1:0] o_spike_mem_rd_en,
	output wire [1:0] o_spike_mem_wr_en,
	output wire [3:0] o_spike_mem_dat,

	// sample mem
	input wire  [15:0] i_sample_mem_dat,	
	output wire  [7:0] o_sample_mem_adr,
	output wire        o_sample_mem_rd_en, 
	output wire        o_sample_mem_wr_en,
	output wire [15:0] o_sample_mem_dat,

	output wire o_encoding_bypass,

	// gate clocks
	output wire gate_spi, gate_snn, gate_enc, gate_serv, 
	input  wire timer_irq, 
	output wire gate_general
    );
    
    wire [23:0] spi_if_adr;
    wire [31:0] spi_if_size;
    wire [ 7:0] spi_if_dat;
    wire        ctrl_if_start;
    wire        ctrl_if_clr;
    wire        ctrl_if_load1;
    wire        ctrl_if_load2;
    wire        ctrl_if_set0;
    wire        ctrl_if_snn_we;
    wire        ctrl_spi_valid;
    wire        ctrl_spi_end;
    wire        ctrl_spi_enable;
    wire        ctrl_spi_read_ack;
    wire        uart_if_ready;
    wire [ 7:0] uart_if_data;
    wire        uart_if_send;
	wire        uart_wren;
	wire 		o_uart_hp;

`ifdef PS_ACC_TOP

	
	//initial begin $deposit(ctrl_if_load1, 1'b1); end 
	//initial begin $deposit(ctrl_if_load2, 1'b1); end 

    accelerator_if_ps aif_ps(
	.i_wb_clk       (wb_clk),
	.i_wb_rst       (wb_rst),

	.i_wb_adr       (i_cpu_adr),
	.i_wb_dat       (i_cpu_dat),
	.i_wb_we        (i_cpu_we),
	.i_wb_cyc       (i_cpu_cyc),
	
	.o_wb_rdt       (o_cpu_rdt),
	.o_wb_ack	(o_cpu_ack),

	.i_snn_valid    (i_snn_valid),
	.output_buffer_ren(output_buffer_ren),
	.output_buffer_addr(output_buffer_addr),
	.output_buffer_out(output_buffer_out), 
	.o_snn_adr_w1   (o_snn_adr_w1),
	.o_snn_adr_w2   (o_snn_adr_w2),
	.o_snn_adr_w3   (o_snn_adr_w3),
	.o_snn_adr_w4   (o_snn_adr_w4),
	.o_snn_we       (o_snn_we),        
	.o_snn_dat      (o_snn_dat),
	.snn_input_channels(snn_input_channels), 
	.neuron_1(neuron_1), .neuron_2(neuron_2), .neuron_3(neuron_3), .neuron_4(neuron_4), 
	.layers(layers),

	.i_spi_dat      (spi_if_dat),
	.o_spi_adr      (spi_if_adr),
	.o_spi_siz      (spi_if_size),

	.i_ctrl_clr     (ctrl_if_clr),
	.i_ctrl_load1   (ctrl_if_load1),
	.i_ctrl_load2   (ctrl_if_load2),
	.i_ctrl_set0    (ctrl_if_set0),
	.i_ctrl_snn_we  (ctrl_if_snn_we),
	.o_ctrl_start   (ctrl_if_start),

	.i_uart_ready   (uart_if_ready),
	.o_uart_data    (uart_if_data),
	.o_uart_send    (uart_if_send),
	.o_uart_wren    (uart_wren),
	.o_uart_hp		(o_uart_hp),

	//spike mem 1 & 2
	.i_spike_mem_dat(i_spike_mem_dat),
	.o_spike_mem_adr(o_spike_mem_adr),
	.o_spike_mem_rd_en(o_spike_mem_rd_en),
	.o_spike_mem_wr_en(o_spike_mem_wr_en),
	.o_spike_mem_dat(o_spike_mem_dat),
	// sample mem
	.i_sample_mem_dat(i_sample_mem_dat),	
	.o_sample_mem_adr(o_sample_mem_adr),
	.o_sample_mem_rd_en(o_sample_mem_rd_en),
	.o_sample_mem_wr_en(o_sample_mem_wr_en),
	.o_sample_mem_dat(o_sample_mem_dat),

	.o_encoding_bypass(o_encoding_bypass),

	.gate_spi(gate_spi), .gate_snn(gate_snn), .gate_enc(gate_enc), .gate_serv(gate_serv), 
	.timer_irq(timer_irq), .gate_general(gate_general)
    );

`else 

    accelerator_if #(
	.WEIGHT_DEPTH_12(WEIGHT_DEPTH_12),
	.WEIGHT_DEPTH_34(WEIGHT_DEPTH_34),
	.CHANNELS       (CHANNELS),
	.MAX_NEURONS	(MAX_NEURONS),
	.MAX_SYNAPSES   (MAX_SYNAPSES)
    )
    aif(
	.i_wb_clk       (wb_clk),
	.i_wb_rst       (wb_rst),

	.i_wb_adr       (i_cpu_adr),
	.i_wb_dat       (i_cpu_dat),
	.i_wb_we        (i_cpu_we),
	.i_wb_cyc       (i_cpu_cyc),
	.o_wb_rdt       (o_cpu_rdt),
	.o_wb_ack		(o_cpu_ack),

	.i_snn_valid    (i_snn_valid),
	.output_buffer_ren(output_buffer_ren),
	.output_buffer_addr(output_buffer_addr),
	.output_buffer_out(output_buffer_out), 
	.o_snn_adr_w1   (o_snn_adr_w1),
	.o_snn_adr_w2   (o_snn_adr_w2),
	.o_snn_adr_w3   (o_snn_adr_w3),
	.o_snn_adr_w4   (o_snn_adr_w4),
	.o_snn_we       (o_snn_we),        
	.o_snn_dat      (o_snn_dat),
	.snn_input_channels(snn_input_channels), 
	.neuron_1(neuron_1), .neuron_2(neuron_2), .neuron_3(neuron_3), .neuron_4(neuron_4), 
	.layers(layers),

	.i_spi_dat      (spi_if_dat),
	.o_spi_adr      (spi_if_adr),
	.o_spi_siz      (spi_if_size),

	.i_ctrl_clr     (ctrl_if_clr),
	.i_ctrl_load1   (ctrl_if_load1),
	.i_ctrl_load2   (ctrl_if_load2),
	.i_ctrl_set0    (ctrl_if_set0),
	.i_ctrl_snn_we  (ctrl_if_snn_we),
	.o_ctrl_start   (ctrl_if_start),

	.i_uart_ready   (uart_if_ready),
	.o_uart_data    (uart_if_data),
	.o_uart_send    (uart_if_send),
	.o_uart_wren    (uart_wren),
	.o_uart_hp		(o_uart_hp),

	//spike mem 1 & 2
	.i_spike_mem_dat(i_spike_mem_dat),
	.o_spike_mem_adr(o_spike_mem_adr),
	.o_spike_mem_rd_en(o_spike_mem_rd_en),
	.o_spike_mem_wr_en(o_spike_mem_wr_en),
	.o_spike_mem_dat(o_spike_mem_dat),
	// sample mem
	.i_sample_mem_dat(i_sample_mem_dat),	
	.o_sample_mem_adr(o_sample_mem_adr),
	.o_sample_mem_rd_en(o_sample_mem_rd_en),
	.o_sample_mem_wr_en(o_sample_mem_wr_en),
	.o_sample_mem_dat(o_sample_mem_dat),

	.o_encoding_bypass(o_encoding_bypass),

	.gate_spi(gate_spi), .gate_snn(gate_snn), .gate_enc(gate_enc), .gate_serv(gate_serv), 
	.timer_irq(timer_irq), .gate_general(gate_general)
    );
 

`endif      
   
    
`ifdef PS_ACC_TOP  

//initial begin $deposit(ctrl_if_start, 1'b0); end 


    spi_acc_control_ps sac_ps(
        .wb_clk(spi_clk),
        .wb_rst(wb_rst),
        .i_if_start     (ctrl_if_start),
        .i_spi_valid    (ctrl_spi_valid),
        .i_spi_end      (ctrl_spi_end),
	.o_spi_en       (ctrl_spi_enable),
	.o_spi_read_ack (ctrl_spi_read_ack),
	.o_if_snn_we    (ctrl_if_snn_we),
	.o_if_clr       (ctrl_if_clr),
	.o_if_load1     (ctrl_if_load1),
	.o_if_load2     (ctrl_if_load2),
	.o_if_set0      (ctrl_if_set0)
    );

`else


    spi_acc_control #(.DOUBLE_CLOCK(DOUBLE_CLOCK)) sac(
        .wb_clk(spi_clk),
        .wb_rst(wb_rst),
        .i_if_start     (ctrl_if_start),
        .o_if_clr       (ctrl_if_clr),
        .o_if_load1     (ctrl_if_load1),
        .o_if_load2     (ctrl_if_load2),
        .o_if_set0      (ctrl_if_set0),
        .i_spi_valid    (ctrl_spi_valid),
        .i_spi_end      (ctrl_spi_end),
        .o_spi_en       (ctrl_spi_enable),
        .o_spi_read_ack (ctrl_spi_read_ack),
        .o_if_snn_we    (ctrl_if_snn_we)
    );


`endif

`ifdef PS_ACC_TOP 

    spi_master_ps spi_ps(
        .clk                (spi_clk),
        .reset              (wb_rst),
        .SPI_SCK            (o_flash_sck),
        .SPI_SS             (o_flash_ss),
        .SPI_MOSI           (o_flash_mosi),
        .SPI_MISO           (i_flash_miso),
        .en                 (ctrl_spi_enable),
        .addr               (spi_if_adr),
        .valid              (ctrl_spi_valid),
        .end_transaction    (ctrl_spi_end),
        .rd_ack             (ctrl_spi_read_ack),
        .rd_data            (spi_if_dat),
        .words_to_read      (spi_if_size),
        .read_req           (1'b1),
        .wr_data            (8'b0)
    );

`else

    spi_master spi(
        .clk                (spi_clk),
        .reset              (wb_rst),
        .SPI_SCK            (o_flash_sck),
        .SPI_SS             (o_flash_ss),
        .SPI_MOSI           (o_flash_mosi),
        .SPI_MISO           (i_flash_miso),
        .en                 (ctrl_spi_enable),
        .addr               (spi_if_adr),
        .valid              (ctrl_spi_valid),
        .end_transaction    (ctrl_spi_end),
        .rd_ack             (ctrl_spi_read_ack),
        .rd_data            (spi_if_dat),
        .words_to_read      (spi_if_size),
        .read_req           (1'b1),
        .wr_data            (8'b0)
    );


`endif

//////// UART ///////	
	
	wire uart_tx_go, uart_tx_go_hp;
	wire [7:0] uart_byte, uart_byte_hp;
	wire [clogb2(UART_QUEUE-1)-1:0] sel;
	wire hp_tx_start;

	assign hp_tx_start = uart_wren & o_uart_hp;

`ifdef PS_ACC_TOP  

	fsm_uart_tx_ps
	fsm_uart_tx_ps
		(
		.clk(wb_clk),
		.rst(wb_rst),
		.i_start(hp_tx_start),
		.i_continue(uart_if_ready),
		.o_sel(sel),
		.o_valid(uart_tx_go_hp)
		);

`else

	fsm_uart_tx #( .N(UART_QUEUE)) 
	fsm_uart_tx_i
		(
		.clk(wb_clk),
		.rst(wb_rst),
		.i_start(hp_tx_start),
		.i_continue(uart_if_ready),
		.o_sel(sel),
		.o_valid(uart_tx_go_hp)
		);
`endif

	assign uart_byte_hp =  (sel == 0)? output_buffer_out[7:0] : 
                           (sel == 1)? output_buffer_out[15:8]:
                           (sel == 2)? output_buffer_out[23:16] : 
                        	     	   output_buffer_out[31:24];
		
	assign uart_byte = o_uart_hp ? uart_byte_hp : uart_if_data;
	assign uart_tx_go = o_uart_hp ? uart_tx_go_hp : uart_wren;
	
`ifdef PS_ACC_TOP  
wire uart_if_ready_debug, o_txd_debug;

	SerialTransmitter_ps
	uart_transmitter_ps(
		.iClock (wb_clk),
		.iData  (uart_byte),
		.iSend  (uart_tx_go),
		.oReady (uart_if_ready),
		.oTxd   (o_txd),
		.iReset (wb_rst)
		); 
		

`else

	SerialTransmitter #(.pClockFrequency(pClockFrequency), .pBaudRate(4000000))
	uart_transmitter(
		.iClock (wb_clk),
		.iData  (uart_byte),
		.iSend  (uart_tx_go),
		.oReady (uart_if_ready),
		.oTxd   (o_txd),
		.iReset (wb_rst)
		); 

`endif






	//  The following function calculates the address width based on specified RAM depth
	function integer clogb2;
	  input integer depth;
		for (clogb2=0; depth>0; clogb2=clogb2+1)
		  depth = depth >> 1;
	endfunction 
    
endmodule



















module fsm_uart_tx #( parameter N = 16) (
	
	input  rst,clk,
	input  i_start, i_continue,
	output [clogb2(N-1)-1:0] o_sel,
	output o_valid
);

reg [clogb2(N-1):0] cnt;

always @(posedge clk)
	if (rst) begin
		cnt <= 0;
	end
	else if (cnt == N) begin
			cnt <= 0;
	end
	else if (cnt != 0 && i_continue) begin
		cnt <= cnt + 1'b1;
	end
	else if (cnt == 0 && i_start) begin
		cnt <= 1;
	end

reg continue_r;
always @(posedge clk)
	if (rst)
		continue_r <= 0;
	else if (cnt != 0)
			continue_r <= i_continue;

assign o_sel = cnt;
assign o_valid = (i_start && i_continue) || (i_continue && cnt != 0);

//////////////////////////////////////////////////
//   __                  _   _                  //
//  / _|_   _ _ __   ___| |_(_) ___  _ __  ___  //
// | |_| | | | '_ \ / __| __| |/ _ \| '_ \/ __| //
// |  _| |_| | | | | (__| |_| | (_) | | | \__ \ //
// |_|  \__,_|_| |_|\___|\__|_|\___/|_| |_|___/ //
//                                              //
//////////////////////////////////////////////////

function integer clogb2;
  input integer depth;
    for (clogb2=0; depth>0; clogb2=clogb2+1)
      depth = depth >> 1;
endfunction   

endmodule
/* This is a Glitch free clock Mux. The design is based on the description provided
at: https://vlsitutorials.com/glitch-free-clock-mux/

TBD: Need to contrain the locations of the various cells properly so they're close to each other to avoid glitches.
*/

module gfcm (
    input reset, // Async reset!
    input clk1,
    input clk2,
    input sel,
    output outclk
);
    // Select double register
    reg [1:0] sync1, sync2;

    wire i_and1, i_and2;
    wire o_and1, o_and2;

    assign i_and1 = ~sel & ~sync2[1];
    assign i_and2 =  sel & ~sync1[1];

    always @ (posedge clk1 or posedge reset)
    if (reset == 1'b1)
        sync1 <= 0;
    else
        sync1 <= {sync1[0], i_and1};

    always @ (posedge clk2 or posedge reset)
    if (reset == 1'b1)
        sync2 <= 0;
    else
        sync2 <= {sync2[0], i_and2};

    assign o_and1 = clk1 & sync1[1];
    assign o_and2 = clk2 & sync2[1];

    assign outclk = o_and1 | o_and2;
endmodule
`default_nettype none
// 011 gpio
// 010 accelerator

module gpio_accelerator_mux
  (input wire         i_wb_clk,
   input wire  [31:0] i_wb_adr,
   input wire  [31:0] i_wb_dat,
   input wire         i_wb_we,
   input wire         i_wb_cyc,
   output wire [31:0] o_wb_rdt,
   
   //output wire [31:0] o_wb_gpio_adr,
   output wire        o_wb_gpio_dat,
   output wire 	      o_wb_gpio_we,
   output wire 	      o_wb_gpio_cyc,
   input wire         i_wb_gpio_rdt,
   
   output wire [31:0] o_wb_acc_adr,
   output wire [31:0] o_wb_acc_dat,
   output wire 	      o_wb_acc_we,
   output wire 	      o_wb_acc_cyc,
   input wire  [31:0] i_wb_acc_rdt);

   wire s = i_wb_adr[29];

   assign o_wb_rdt = s ? {31'b0, i_wb_gpio_rdt} : i_wb_acc_rdt;

   //assign o_wb_gpio_adr = i_wb_adr;
   assign o_wb_gpio_dat = i_wb_dat[0];
   assign o_wb_gpio_we  = i_wb_we;

   assign o_wb_acc_adr = i_wb_adr;
   assign o_wb_acc_dat = i_wb_dat;
   assign o_wb_acc_we  = i_wb_we;

   assign o_wb_gpio_cyc = i_wb_cyc & s;
   assign o_wb_acc_cyc  = i_wb_cyc & ~s;

endmodule`default_nettype none
module servant(
	input  wire         wb_clk,
	input  wire         timer_clk,
	input  wire         wb_rst,
	output wire [3:0]   led,
	input  wire [2:0]   buttons,
	output wire 	    timer_irq,	

	output wire [31:0]  o_wb_acc_adr,
	output wire [31:0]  o_wb_acc_dat,
	output wire         o_wb_acc_we,
	output wire         o_wb_acc_cyc,
	input  wire [31:0]  i_wb_acc_rdt,
	input wire          i_wb_acc_ack,
	
	input wire enb_debug
);

    parameter memfile = "zephyr_hello.hex";
    parameter memsize = 8192;
    parameter reset_strategy = "MINI";
    parameter sim = 0;
    parameter with_csr = 1;
    parameter [0:0] compress = 0;
    parameter [0:0] align = compress;

    wire [31:0] wb_ibus_adr;
    wire 	    wb_ibus_cyc;
    wire [31:0] wb_ibus_rdt;
    wire 	    wb_ibus_ack;

    wire [31:0] wb_dbus_adr;
    wire [31:0] wb_dbus_dat;
    wire [3:0] 	wb_dbus_sel;
    wire 	    wb_dbus_we;
    wire 	    wb_dbus_cyc;
    wire [31:0] wb_dbus_rdt;
    wire 	    wb_dbus_ack;

    wire [31:0] wb_dmem_adr;
    wire [31:0] wb_dmem_dat;
    wire [ 3:0] wb_dmem_sel;
    wire 	    wb_dmem_we;
    wire 	    wb_dmem_cyc;
    wire [31:0] wb_dmem_rdt;
    wire 	    wb_dmem_ack;

    wire [31:0]	wb_mem_adr;
    wire [31:0] wb_mem_dat;
    wire [ 3:0] wb_mem_sel;
    wire 	    wb_mem_we;
    wire 	    wb_mem_cyc;
    wire [31:0] wb_mem_rdt;
    wire 	    wb_mem_ack;

    wire [31:0] wb_gamux_adr;
    wire [31:0]	wb_gamux_dat;
    wire        wb_gamux_we;
    wire 	    wb_gamux_cyc;
    wire [31:0]	wb_gamux_rdt;

	wire [31:0] wb_gpio_adr;
    wire [31:0] wb_gpio_dat;
    wire        wb_gpio_we;
    wire 	    wb_gpio_cyc;
    wire [31:0] wb_gpio_rdt;

    wire [31:0] wb_timer_adr;
    wire [31:0] wb_timer_dat;
    wire 	    wb_timer_we;
    wire 	    wb_timer_cyc;
    wire [31:0] wb_timer_rdt;

    wire [31:0] mdu_rs1;
    wire [31:0] mdu_rs2;
    wire [ 2:0] mdu_op;
    wire        mdu_valid;
    wire [31:0] mdu_rd;
    wire        mdu_ready;

    servant_arbiter arbiter(
        .i_wb_cpu_dbus_adr (wb_dmem_adr),
        .i_wb_cpu_dbus_dat (wb_dmem_dat),
        .i_wb_cpu_dbus_sel (wb_dmem_sel),
        .i_wb_cpu_dbus_we  (wb_dmem_we ),
        .i_wb_cpu_dbus_cyc (wb_dmem_cyc),
        .o_wb_cpu_dbus_rdt (wb_dmem_rdt),
        .o_wb_cpu_dbus_ack (wb_dmem_ack),

        .i_wb_cpu_ibus_adr (wb_ibus_adr),
        .i_wb_cpu_ibus_cyc (wb_ibus_cyc),
        .o_wb_cpu_ibus_rdt (wb_ibus_rdt),
        .o_wb_cpu_ibus_ack (wb_ibus_ack),

        .o_wb_cpu_adr (wb_mem_adr),
        .o_wb_cpu_dat (wb_mem_dat),
        .o_wb_cpu_sel (wb_mem_sel),
        .o_wb_cpu_we  (wb_mem_we ),
        .o_wb_cpu_cyc (wb_mem_cyc),
        .i_wb_cpu_rdt (wb_mem_rdt),
        .i_wb_cpu_ack (wb_mem_ack)
        );

   servant_mux #(sim) servant_mux
     (
      .i_clk (wb_clk),
      .i_rst (wb_rst & (reset_strategy != "NONE")),
      .i_wb_cpu_adr (wb_dbus_adr),
      .i_wb_cpu_dat (wb_dbus_dat),
      .i_wb_cpu_sel (wb_dbus_sel),
      .i_wb_cpu_we  (wb_dbus_we),
      .i_wb_cpu_cyc (wb_dbus_cyc),
      .o_wb_cpu_rdt (wb_dbus_rdt),
      .o_wb_cpu_ack (wb_dbus_ack),

      .o_wb_mem_adr (wb_dmem_adr),
      .o_wb_mem_dat (wb_dmem_dat),
      .o_wb_mem_sel (wb_dmem_sel),
      .o_wb_mem_we  (wb_dmem_we),
      .o_wb_mem_cyc (wb_dmem_cyc),
      .i_wb_mem_rdt (wb_dmem_rdt),

      .o_wb_gpio_adr (wb_gpio_adr),
      .o_wb_gpio_dat (wb_gpio_dat),
      .o_wb_gpio_we (wb_gpio_we),
      .o_wb_gpio_cyc (wb_gpio_cyc),
      .i_wb_gpio_rdt (wb_gpio_rdt), 

      .o_wb_acc_adr (o_wb_acc_adr),
      .o_wb_acc_dat (o_wb_acc_dat),
      .o_wb_acc_we (o_wb_acc_we),
      .o_wb_acc_cyc (o_wb_acc_cyc),
      .i_wb_acc_rdt (i_wb_acc_rdt),
	  .i_wb_acc_ack (i_wb_acc_ack),

      .o_wb_timer_adr (wb_timer_adr),
      .o_wb_timer_dat (wb_timer_dat),
      .o_wb_timer_we  (wb_timer_we),
      .o_wb_timer_cyc (wb_timer_cyc),
      .i_wb_timer_rdt (wb_timer_rdt));

   servant_ram
     #(.memfile (memfile),
       .depth (memsize),
       .RESET_STRATEGY (reset_strategy))
   ram
     (// Wishbone interface
      .i_wb_clk (wb_clk),
      .i_wb_rst (wb_rst),
      .i_wb_adr (wb_mem_adr[$clog2(memsize)-1:2]),
      .i_wb_cyc (wb_mem_cyc),
      .i_wb_we  (wb_mem_we) ,
      .i_wb_sel (wb_mem_sel),
      .i_wb_dat (wb_mem_dat),
      .o_wb_rdt (wb_mem_rdt),
      .o_wb_ack (wb_mem_ack),
      
      .enb_debug(enb_debug)
      );

	//`ifdef IEEG
		 servant_timer
		   #(.RESET_STRATEGY (reset_strategy),
			 .WIDTH (32))
		 timer
		   (.i_clk    (wb_clk), // always on clk
			.i_rst    (wb_rst),
			.o_irq    (),
			.i_wb_cyc (wb_timer_cyc),
			.i_wb_we  (wb_timer_we) ,
			.i_wb_dat (wb_timer_dat),
			.o_wb_rdt ());
	
	// EMG

wire timer_irq_debug;
wire wb_timer_rdt_debug;

`ifdef PS_SLOW_TIMER		
		 servant_slow_timer_ps

		 timer_slow_ps
		   (    .i_clk    (wb_clk), // serv stops gating stops with the interrupt
			.slow_clk (timer_clk),
			.i_rst    (wb_rst),
			.o_irq    (timer_irq_debug),
			.i_wb_cyc (wb_timer_cyc),
			.i_wb_we  (wb_timer_we) ,
			.i_wb_dat (wb_timer_dat),
			.o_wb_rdt (wb_timer_rdt_debug));
`else

		 servant_slow_timer_new
		   #(.RESET_STRATEGY (reset_strategy),
	             .WIDTH (32))
		 timer_slow_new
		   (.i_clk    (wb_clk), // serv stops gating stops with the interrupt
			.slow_clk (timer_clk),
			.i_rst    (wb_rst),
			.o_irq    (timer_irq),
			.i_wb_cyc (wb_timer_cyc),
			.i_wb_we  (wb_timer_we) ,
			.i_wb_dat (wb_timer_dat),
			.o_wb_rdt (wb_timer_rdt));
`endif
	
   servant_gpio gpio
     (.i_wb_clk (wb_clk),
      .i_wb_adr (wb_gpio_adr),            
      .i_wb_dat (wb_gpio_dat),
      .i_wb_we  (wb_gpio_we),
      .i_wb_cyc (wb_gpio_cyc),
      .o_wb_rdt (wb_gpio_rdt),
      .led   (led),
	  .buttons(buttons)); 

   serv_rf_top
     #(.RESET_PC (32'h0000_0000),
       .RESET_STRATEGY (reset_strategy),
  `ifdef MDU
       .MDU(1),
  `endif 
       .WITH_CSR (with_csr),
       .COMPRESSED(compress),
       .ALIGN(align))
   cpu
     (
      .clk      (wb_clk),
      .i_rst    (wb_rst),
      .i_timer_irq  (timer_irq),
`ifdef RISCV_FORMAL
      .rvfi_valid     (),
      .rvfi_order     (),
      .rvfi_insn      (),
      .rvfi_trap      (),
      .rvfi_halt      (),
      .rvfi_intr      (),
      .rvfi_mode      (),
      .rvfi_ixl       (),
      .rvfi_rs1_addr  (),
      .rvfi_rs2_addr  (),
      .rvfi_rs1_rdata (),
      .rvfi_rs2_rdata (),
      .rvfi_rd_addr   (),
      .rvfi_rd_wdata  (),
      .rvfi_pc_rdata  (),
      .rvfi_pc_wdata  (),
      .rvfi_mem_addr  (),
      .rvfi_mem_rmask (),
      .rvfi_mem_wmask (),
      .rvfi_mem_rdata (),
      .rvfi_mem_wdata (),
`endif

      .o_ibus_adr   (wb_ibus_adr),
      .o_ibus_cyc   (wb_ibus_cyc),
      .i_ibus_rdt   (wb_ibus_rdt),
      .i_ibus_ack   (wb_ibus_ack),

      .o_dbus_adr   (wb_dbus_adr),
      .o_dbus_dat   (wb_dbus_dat),
      .o_dbus_sel   (wb_dbus_sel),
      .o_dbus_we    (wb_dbus_we),
      .o_dbus_cyc   (wb_dbus_cyc),
      .i_dbus_rdt   (wb_dbus_rdt),
      .i_dbus_ack   (wb_dbus_ack),
      
      //Extension
      .o_ext_rs1    (mdu_rs1),
      .o_ext_rs2    (mdu_rs2),
      .o_ext_funct3 (mdu_op),
      .i_ext_rd     (mdu_rd),
      .i_ext_ready  (mdu_ready),
      //MDU
      .o_mdu_valid  (mdu_valid));

`ifdef MDU
    mdu_top mdu_serv
    (
     .i_clk(wb_clk),
     .i_rst(wb_rst),
     .i_mdu_rs1(mdu_rs1),
     .i_mdu_rs2(mdu_rs2),
     .i_mdu_op(mdu_op),
     .i_mdu_valid(mdu_valid),
     .o_mdu_ready(mdu_ready),
     .o_mdu_rd(mdu_rd));
`else
    assign mdu_ready = 1'b0;
    assign mdu_rd = 32'b0;
`endif

endmodule
/*
  Basic serial transmitter (UART)
  Copyright (c) 2020 Stanislav Jurny (github.com/STjurny) license MIT

  Serial data format is 8 data bits, without parity, one stop bit (8N1) without hardware flow control.
  Set parameters pClockFrequency and pBaudRate to requirements of your design (pBaudRate can be 
  max 1/3 of pClockFrequency). For high baud rates check values of parametrization report pInaccuracyPerFrame and 
  pInaccuracyThreshhold to ensure that ClockFrequency / BaudRate ratio generates acceptable inaccuracy of frame length.
  Generally pInaccuracyPerFrame have to be less than pInaccuracyThreshhold. For ideal ratio is pInaccuracyPerFrame = 0.

  For send a byte set iData to required value and set iSend to 1 for at least one clock cycle. The module
  takes over data into its own buffer and starts transmitting. The iData value has to be valid only for first tick
  after iSend was asserted. The signal oReady indicates readiness to take over next byte for send. The signal is
  set to 0 after take over byte to send and during transmitting the start and data bits. After last data bit sent
  the oReady signal is immediatelly set to 1 so a next byte to send can be pass already during transmitting
  stop bit of previous byte. Because of that there is not any delay before transmitting the next byte.
  
  Module supports automatic power on reset (after load bitstream to the FPGA), explicit reset over iReset signal or both 
  of them. Mode of reset is determined by preprocessor symbols GlobalReset and PowerOnReset. Edit the Global.inc file 
  to select reset modes.
*/

`define GlobalReset

  
module SerialTransmitter #(
  parameter pClockFrequency = 24000000,  
    //^ System clock frequency.
      
  parameter pBaudRate = 4000000     
    //^ Serial output baud rate (..., 9600, 115200, 2000000, ...)
    //^ Can be value from arbitrary low to max 1/3 of pClockFrequency.
)(
  input wire iClock,       
    //^ System clock with frequency specified in the parameter pClockFrequency.
      
  input wire [7:0] iData,  
    //^ Data to send (have to be valid first clock after set iSend to 1).
      
  input wire iSend,        
    //^ Set to 1 for at least one clock cycle for start the sending.
      
  output wire oReady,   
    //^ Signalizes readiness to take over next byte to send.
      
  output wire oTxd          
    //^ Serial data output with baudrate specified in the parameter pBaudRate.
    

  ,input wire iReset
    //^ Reset module to initial state (reset is synchronized with posedge, set to 1 for one clock is enough).
    //^ Module can begin transmit data in next clock tick after the iReset was set to 0.

);


localparam
  pTicksPerBit = pClockFrequency / pBaudRate,
  pBitTimerMsb = $clog2(pTicksPerBit) - 1,
  pLastTickOfBit = pTicksPerBit - 1;

localparam
  pTicksPerFrame = pClockFrequency * 10 / pBaudRate,
  pInaccuracyPerFrame = pTicksPerFrame - pTicksPerBit * 10,
  pInaccuracyThreshhold = pTicksPerBit / 2;

`ifdef SIM 

	initial  // parametrization report
	  begin
	    $display("%m|1|--");
	    
	    `ifdef GlobalReset
	      $display("%m|1|GlobalReset = yes");
	    `else
	      $display("%m|1|GlobalReset = no");
	    `endif
	    
	    `ifdef PowerOnReset
	      $display("%m|1|PowerOnReset = yes");
	    `else
	      $display("%m|1|PowerOnReset = no");
	    `endif
	    
	    $display("%m|1|pClockFrequency = '%d", pClockFrequency);
	    $display("%m|1|pBaudRate = '%d", pBaudRate);
	    $display("%m|1|--");
	    $display("%m|1|pTicksPerBit = '%d", pTicksPerBit);
	    $display("%m|1|pTicksPerFrame = '%d", pTicksPerFrame);    
	    $display("%m|1|--");
	    $display("%m|1|pInaccuracyPerFrame = '%d", pInaccuracyPerFrame);    
	    $display("%m|1|pInaccuracyThreshhold = '%d", pInaccuracyThreshhold);    
	    $display("%m|1|--");
	    $display("%m|1|pLastTickOfBit = '%d", pLastTickOfBit);
	    $display("%m|1|cBitTimer range = '%d:0", pBitTimerMsb);
	    
	    if (pTicksPerBit < 3) 
	      begin
		$display("%m|0|Error: Parameter pBaudrate can be max 1/3 of clock frequency.");
		$stop;
	      end
	  end

`endif

localparam // $State:2,st
  stIdle     = 0,
  stStartBit = 1,
  stDataBit  = 2,
  stStopBit  = 3;


reg [pBitTimerMsb:0] cBitTimer;
reg cBitSent;

reg [1:0] cState;
reg [7:0] cBuffer;
reg [2:0] cBitIndex;

reg cReady; 
assign oReady = cReady;

reg cnTxd; 
assign oTxd = ~cnTxd;  // negation because iCEcude2 can initialize registers after power on reset only to zero


`ifdef PowerOnReset
initial
  begin
    cBitTimer = 0;
    cBitSent = 0;

    cState = stIdle;
    cReady = 0;
    cBitIndex = 0;

    cnTxd = 0;
  end
`endif


always @(posedge iClock)  // serial bit output timer
  `ifdef GlobalReset
  if (iReset)
    begin
      cBitTimer <= 0;
      cBitSent <= 0;
    end
  else
  `endif
    begin
      if (cState == stIdle || cBitSent)
        cBitTimer <= 0;
      else
        cBitTimer <= cBitTimer + 1;

      // comparison is potentially complex so we do it separately one clock earlier
      cBitSent <= cBitTimer == (pLastTickOfBit[pBitTimerMsb:0] - 1);
    end


always @(posedge iClock)  // transmitter FSM
  `ifdef GlobalReset
  if (iReset)
    begin
      cState <= stIdle;
      cReady <= 0;
      cBitIndex <= 0;
    end
  else
  `endif
    case (cState) 
      stIdle:
        if (iSend)
          begin
            cBuffer <= iData;
            cReady <= 0;
            cState <= stStartBit;
          end
        else
          cReady <= 1;
          
      stStartBit: 
        if (cBitSent)
          cState <= stDataBit;
              
      stDataBit:
        if (cBitSent)
          begin
            cBuffer <= cBuffer >> 1;  
            cBitIndex <= cBitIndex + 1;

            if (cBitIndex == 7)
              begin
                cReady <= 1;
                cState <= stStopBit;
              end;
          end
          
      stStopBit:
        begin: stopBit
          reg nReady; 
          nReady = cReady;
          
          if (cReady && iSend)   // next byte to send can be passed before sending of stop bit is completed
            begin                // so there isn't any delay before beginning of sending next byte
              cBuffer <= iData;
              nReady = 0;      
            end

          if (cBitSent)
            if (~nReady)
              cState <= stStartBit;
            else
              cState <= stIdle;
        
          cReady <= nReady;
        end 
    endcase


always @(posedge iClock)  // registered serial output prevents glitches
  `ifdef GlobalReset
  if (iReset)
    cnTxd <= 0;
  else
  `endif
    cnTxd <= ~( 
      cState == stIdle ||
      cState == stStopBit ||
      cState == stDataBit && cBuffer[0]  // cBuffer LSB is a currently sending bit
    );
     
                
endmodule


















/* Arbitrates between dbus and ibus accesses.
 * Relies on the fact that not both masters are active at the same time
 */
module servant_arbiter
  (
   input wire [31:0]  i_wb_cpu_dbus_adr,
   input wire [31:0]  i_wb_cpu_dbus_dat,
   input wire [3:0]   i_wb_cpu_dbus_sel,
   input wire 	      i_wb_cpu_dbus_we,
   input wire 	      i_wb_cpu_dbus_cyc,
   output wire [31:0] o_wb_cpu_dbus_rdt,
   output wire 	      o_wb_cpu_dbus_ack,

   input wire [31:0]  i_wb_cpu_ibus_adr,
   input wire 	      i_wb_cpu_ibus_cyc,
   output wire [31:0] o_wb_cpu_ibus_rdt,
   output wire 	      o_wb_cpu_ibus_ack,

   output wire [31:0] o_wb_cpu_adr,
   output wire [31:0] o_wb_cpu_dat,
   output wire [3:0]  o_wb_cpu_sel,
   output wire 	      o_wb_cpu_we,
   output wire 	      o_wb_cpu_cyc,
   input wire [31:0]  i_wb_cpu_rdt,
   input wire 	      i_wb_cpu_ack);

   assign o_wb_cpu_dbus_rdt = i_wb_cpu_rdt;
   assign o_wb_cpu_dbus_ack = i_wb_cpu_ack & !i_wb_cpu_ibus_cyc;

   assign o_wb_cpu_ibus_rdt = i_wb_cpu_rdt;
   assign o_wb_cpu_ibus_ack = i_wb_cpu_ack & i_wb_cpu_ibus_cyc;

   assign o_wb_cpu_adr = i_wb_cpu_ibus_cyc ? i_wb_cpu_ibus_adr : i_wb_cpu_dbus_adr;
   assign o_wb_cpu_dat = i_wb_cpu_dbus_dat;
   assign o_wb_cpu_sel = i_wb_cpu_dbus_sel;
   assign o_wb_cpu_we  = i_wb_cpu_dbus_we & !i_wb_cpu_ibus_cyc;
   assign o_wb_cpu_cyc = i_wb_cpu_ibus_cyc | i_wb_cpu_dbus_cyc;

endmodule
`default_nettype none
module servant_clock_gen
  	(
	input wire  i_clk,
	input wire  i_rst,
	output wire o_clk,
	output wire o_half_clk,
	output wire o_slow_clk,
	output wire o_rst,
	output wire o_rst_gfcm,
	input wire bypass,
	input wire low_power_mode
	);

	parameter SIM = 0;
	parameter DOUBLE_CLOCK = 0;
	parameter DIVR = 4'b0000;
	parameter DIVF = 7'b0110100;
	parameter DIVQ = 7'b0110100;
	parameter HFOSC = "0'b01";

	localparam RESET_LENGTH = 12;
	reg [RESET_LENGTH-1:0] rst_reg = 0;
	always @(posedge o_half_clk)
		rst_reg <= {rst_reg[RESET_LENGTH-2:0],1'b1};
	assign o_rst = ~rst_reg[RESET_LENGTH-1];
	assign o_rst_gfcm = ~rst_reg[2];

	generate 
		if(SIM) begin
		
			if(DOUBLE_CLOCK)
				begin
					assign o_half_clk = i_clk | ~low_power_mode;

					reg spi_clk_reg = 0;
					always  #15.5 spi_clk_reg <= !spi_clk_reg | ~low_power_mode;
					assign o_clk = spi_clk_reg | ~low_power_mode;
				end
			else // single clock
				begin
					assign o_half_clk = i_clk | ~low_power_mode;
					assign o_clk      = i_clk | ~low_power_mode;
				end

			reg slow_clk_reg = 0;
			always #50000 slow_clk_reg <= !slow_clk_reg;
			assign o_slow_clk = slow_clk_reg;

		 end
		else begin // not sim

			if(DOUBLE_CLOCK) 
				begin
					SB_PLL40_2F_PAD
						pll
							(
							.PACKAGEPIN (i_clk),
							.PLLOUTCOREA(o_clk),
							.PLLOUTCOREB(o_half_clk),
							.RESETB(1'b1),
							.BYPASS(bypass),
							.LATCHINPUTVALUE(low_power_mode)
							);

							//\\ Fin=12, Fout=45;
							defparam pll.DIVR = DIVR;
							defparam pll.DIVF = DIVF;
							defparam pll.DIVQ = DIVQ;
							defparam pll.FILTER_RANGE = 3'b001;
							defparam pll.FEEDBACK_PATH = "SIMPLE";
							defparam pll.DELAY_ADJUSTMENT_MODE_FEEDBACK = "FIXED";
							defparam pll.FDA_FEEDBACK = 4'b0000;
							defparam pll.DELAY_ADJUSTMENT_MODE_RELATIVE = "FIXED";
							defparam pll.FDA_RELATIVE = 4'b0000;
							defparam pll.SHIFTREG_DIV_MODE = 2'b00;
							defparam pll.PLLOUT_SELECT_PORTA = "GENCLK";
							defparam pll.PLLOUT_SELECT_PORTB = "GENCLK_HALF";
							//defparam pll.PLLOUT_SELECT = "GENCLK";
							defparam pll.ENABLE_ICEGATE_PORTA = 1'b1;
							defparam pll.ENABLE_ICEGATE_PORTB = 1'b1;
							//defparam pll.ENABLE_ICEGATE = 1'b0;
					end
				else 
					begin // single clock	
						/*
						SB_PLL40_PAD
						pll
							(
							.PACKAGEPIN (i_clk),
							.PLLOUTCORE(o_clk),			
							.RESETB(1'b1),
							.BYPASS(bypass),
							.LATCHINPUTVALUE(low_power_mode)
							);
						
							assign o_half_clk = o_clk;

							//\\ Fin=12, Fout=45;
							defparam pll.DIVR = DIVR;
							defparam pll.DIVF = DIVF;
							defparam pll.DIVQ = DIVQ;
							defparam pll.FILTER_RANGE = 3'b001;
							defparam pll.FEEDBACK_PATH = "SIMPLE";
							defparam pll.DELAY_ADJUSTMENT_MODE_FEEDBACK = "FIXED";
							defparam pll.FDA_FEEDBACK = 4'b0000;
							defparam pll.DELAY_ADJUSTMENT_MODE_RELATIVE = "FIXED";
							defparam pll.FDA_RELATIVE = 4'b0000;
							defparam pll.SHIFTREG_DIV_MODE = 2'b00;
							defparam pll.PLLOUT_SELECT = "GENCLK";
							defparam pll.ENABLE_ICEGATE = 1'b1;
						*/
						
						SB_HFOSC 
						hfosc 
							( 
							.CLKHFEN(low_power_mode), // andrebbe a zero per 100 us ma se a 6 MHz funziona lo stesso
							.CLKHFPU(1'b1), 
							.CLKHF(o_clk) 
							); 

							// synthesis ROUTE_THROUGH_FABRIC= 1 
							//the value can be either 0 or 1 

							// Parameter CLKHF_DIV = "0b00" (default), "0b01", "0b10", "0b11" 
							// 0b00 = 48 MHz, 0b01 = 24 MHz, 0b10 = 12 MHz, 0b11 = 6 MHz		
							defparam hfosc.CLKHF_DIV = HFOSC; 			

							assign o_half_clk = o_clk;
							
					end
				
					SB_LFOSC  u_lf_osc(.CLKLFPU(1'b1), .CLKLFEN(1'b1), .CLKLF(o_slow_clk));

				end
	endgenerate

endmodule
module servant_gpio
  (input wire i_wb_clk,
   input wire [31:0] i_wb_adr,
   input wire [31:0] i_wb_dat,
   input wire i_wb_we,
   input wire i_wb_cyc,
   output reg [31:0] o_wb_rdt,
   output wire [3:0] led,
   input [2:0] buttons
   );

/*   always @(posedge i_wb_clk) begin
      o_wb_rdt <= {buttons,27'b0,o_gpio};
      if (i_wb_cyc & i_wb_we)
		o_gpio <= i_wb_dat[1:0];
   end*/

reg [3:0] o_gpio_reg;

always @(posedge i_wb_clk) begin
      o_wb_rdt <= {buttons,25'b0,o_gpio_reg};
      if (i_wb_cyc & i_wb_we)
		o_gpio_reg <= i_wb_dat[3:0];
   end

assign led = o_gpio_reg;

/*
always @(posedge i_wb_clk) begin
      o_wb_rdt <= {buttons,o_gpio[28:0]};
      if (i_wb_cyc & i_wb_we)
		o_gpio <= i_wb_dat;
   end
*/
endmodule
/*
 mem = 00
 gamux = 01
 timer = 10
 testcon = 11
 */
module servant_mux
  (
   input wire 	      i_clk,
   input wire 	      i_rst,
   input wire [31:0]  i_wb_cpu_adr,
   input wire [31:0]  i_wb_cpu_dat,
   input wire [3:0]   i_wb_cpu_sel,
   input wire 	      i_wb_cpu_we,
   input wire 	      i_wb_cpu_cyc,
   output wire [31:0] o_wb_cpu_rdt,
   output reg 	      o_wb_cpu_ack,

   output wire [31:0] o_wb_mem_adr,
   output wire [31:0] o_wb_mem_dat,
   output wire [3:0]  o_wb_mem_sel,
   output wire 	      o_wb_mem_we,
   output wire 	      o_wb_mem_cyc,
   input wire [31:0]  i_wb_mem_rdt,

   output wire [31:0] o_wb_gpio_adr,
   output wire [31:0]    o_wb_gpio_dat,
   output wire 	      o_wb_gpio_we,
   output wire 	      o_wb_gpio_cyc,
   input wire 	[31:0]      i_wb_gpio_rdt,

   output wire [31:0] o_wb_timer_adr,
   output wire [31:0] o_wb_timer_dat,
   output wire 	      o_wb_timer_we,
   output wire 	      o_wb_timer_cyc,
   input wire [31:0]  i_wb_timer_rdt,
   
   output wire [31:0] o_wb_acc_adr,
   output wire [31:0] o_wb_acc_dat,
   output wire 	      o_wb_acc_we,
   output wire 	      o_wb_acc_cyc,
   input wire [31:0]  i_wb_acc_rdt,
   input wire 		  i_wb_acc_ack
   );

   parameter sim = 0;

   wire [1:0] 	  s = i_wb_cpu_adr[31:30];

   assign o_wb_cpu_rdt = (s == 2'b11) ? i_wb_gpio_rdt :
						 (s == 2'b10) ? i_wb_timer_rdt :
						 (s == 2'b01) ? i_wb_acc_rdt : 
						 i_wb_mem_rdt;

   always @(posedge i_clk) begin
      o_wb_cpu_ack <= 1'b0;
      if (i_wb_cpu_cyc & !o_wb_cpu_ack & (s != 2'b01))
	      o_wb_cpu_ack <= 1'b1;
	  if (i_wb_cpu_cyc & !o_wb_cpu_ack & (s == 2'b01))	// bram read requires 1 extra clock-cycle
		  o_wb_cpu_ack <= i_wb_acc_ack;
      if (i_rst)
	      o_wb_cpu_ack <= 1'b0;
   end

   assign o_wb_mem_adr = i_wb_cpu_adr;
   assign o_wb_mem_dat = i_wb_cpu_dat;
   assign o_wb_mem_sel = i_wb_cpu_sel;
   assign o_wb_mem_we  = i_wb_cpu_we;
   assign o_wb_mem_cyc = i_wb_cpu_cyc & (s == 2'b00);

   assign o_wb_acc_adr = i_wb_cpu_adr;
   assign o_wb_acc_dat = i_wb_cpu_dat;
   assign o_wb_acc_we  = i_wb_cpu_we;
   assign o_wb_acc_cyc = i_wb_cpu_cyc & (s == 2'b01);

   assign o_wb_timer_adr = i_wb_cpu_adr;
   assign o_wb_timer_dat = i_wb_cpu_dat;
   assign o_wb_timer_we  = i_wb_cpu_we;
   assign o_wb_timer_cyc = i_wb_cpu_cyc & (s == 2'b10);

   assign o_wb_gpio_adr = i_wb_cpu_adr;
   assign o_wb_gpio_dat = i_wb_cpu_dat;
   assign o_wb_gpio_we  = i_wb_cpu_we;
   assign o_wb_gpio_cyc = i_wb_cpu_cyc & (s == 2'b11);

   generate
      if (sim) begin
	 wire sig_en = (i_wb_cpu_adr[31:28] == 4'h8) & i_wb_cpu_cyc & o_wb_cpu_ack;
	 wire halt_en = (i_wb_cpu_adr[31:28] == 4'h9) & i_wb_cpu_cyc & o_wb_cpu_ack;

	 reg [1023:0] signature_file;
	 integer      f = 0;

	 initial
       /* verilator lint_off WIDTH */
	   if ($value$plusargs("signature=%s", signature_file)) begin
	      $display("Writing signature to %0s", signature_file);
	      f = $fopen(signature_file, "w");
	   end
       /* verilator lint_on WIDTH */

	 always @(posedge i_clk)
	    if (sig_en & (f != 0))
	      $fwrite(f, "%c", i_wb_cpu_dat[7:0]);
	    else if(halt_en) begin
	       $display("Test complete");
	       $finish;
	    end
      end
   endgenerate
endmodule
`default_nettype none
module servant_ram
#(//Memory parameters
	parameter depth = 256,
	parameter aw    = $clog2(depth),
	parameter RESET_STRATEGY = "",
	parameter memfile = "")
(
	input wire 		i_wb_clk,
	input wire 		i_wb_rst,
	input wire [aw-1:2] i_wb_adr,
	input wire [31:0] 	i_wb_dat,
	input wire [3:0] 	i_wb_sel,
	input wire 		i_wb_we,
	input wire 		i_wb_cyc,
	output     [31:0] 	o_wb_rdt,
	output reg 		o_wb_ack,
	
	input wire enb_debug
);

	wire [3:0] we = {4{i_wb_we & i_wb_cyc}} & i_wb_sel;

	reg [31:0] mem [0:depth/4-1] /* verilator public */;

	wire [aw-3:0] addr = i_wb_adr[aw-1:2];

   always @(posedge i_wb_clk)
     if (i_wb_rst & (RESET_STRATEGY != "NONE"))
       o_wb_ack <= 1'b0;
     else
       o_wb_ack <= i_wb_cyc & !o_wb_ack;


	ihp_ram #(.memfile(memfile)) sevant_ram 
	(	
	.clk(i_wb_clk),
	.we(we),
	.addr(addr),
	.dina(i_wb_dat),
	.dout(o_wb_rdt),
	.enb_debug(enb_debug)	
	);
/*
   always @(posedge i_wb_clk) begin
      if (we[0]) mem[addr][7:0]   <= i_wb_dat[7:0];
      if (we[1]) mem[addr][15:8]  <= i_wb_dat[15:8];
      if (we[2]) mem[addr][23:16] <= i_wb_dat[23:16];
      if (we[3]) mem[addr][31:24] <= i_wb_dat[31:24];
      o_wb_rdt <= mem[addr];
   end



   initial
     if(|memfile) begin
`ifndef ISE
	$display("Preloading %m from %s", memfile);
`endif
	$readmemh(memfile, mem);
     end

*/

endmodule
`default_nettype none
module servant_slow_timer_new
  #(     
	 parameter WIDTH = 16,
	 parameter RESET_STRATEGY = "",
	 parameter DIVIDER = 0
   )
      
  (
  	input wire 	     i_clk, slow_clk,
	input wire 	     i_rst,
	output reg 	     o_irq,
	input wire [31:0]    i_wb_dat,
	input wire 	     i_wb_we,
	input wire 	     i_wb_cyc,
	output reg [31:0]    o_wb_rdt
  );

	localparam HIGH = WIDTH-1-DIVIDER;

	reg [WIDTH-1:0]   mtime;
	reg [HIGH:0]      mtimecmp;

	wire [HIGH:0]     mtimeslice = mtime[WIDTH-1:DIVIDER];

	always @(mtimeslice) begin
		o_wb_rdt = 32'd0;
		o_wb_rdt[HIGH:0] = mtimeslice;
	end

	always @(posedge i_clk) begin
		if (RESET_STRATEGY != "NONE")
			if (i_rst) begin
				mtimecmp <= 0;
			end
		if (i_wb_cyc & i_wb_we) begin
			mtimecmp <= i_wb_dat[HIGH:0];
		end

	end

	wire wr_en;
	assign wr_en = i_wb_cyc & i_wb_we;

	always @(posedge slow_clk, posedge wr_en, posedge i_rst) begin
			if (RESET_STRATEGY != "NONE")
				if (wr_en) 
					mtime <= 0;
				else if (i_rst)
						mtime <= 0;
					else if(mtimeslice <= mtimecmp)
							mtime <= mtime + 'd1;
						 else
							mtime <= 0;
	end


	always @(posedge slow_clk)
		o_irq <= (mtimeslice >= mtimecmp);

endmodule












`default_nettype none
module servant_timer
  #(parameter WIDTH = 16,
	 parameter RESET_STRATEGY = "",
	 parameter DIVIDER = 0)
  (input wire 	     i_clk,
	input wire 	     i_rst,
	output reg 	     o_irq,
	input wire [31:0] i_wb_dat,
	input wire 	     i_wb_we,
	input wire 	     i_wb_cyc,
	output reg [31:0] o_wb_rdt);

	localparam HIGH = WIDTH-1-DIVIDER;

	reg [WIDTH-1:0]   mtime;
	reg [HIGH:0]      mtimecmp;

	wire [HIGH:0]     mtimeslice = mtime[WIDTH-1:DIVIDER];

	always @(mtimeslice) begin
		o_wb_rdt = 32'd0;
		o_wb_rdt[HIGH:0] = mtimeslice;
	end

	always @(posedge i_clk) begin
		if (RESET_STRATEGY != "NONE")
			if (i_rst) begin
				mtime <= 0;
				mtimecmp <= 0;
			end
		if (i_wb_cyc & i_wb_we) begin
			mtimecmp <= i_wb_dat[HIGH:0];
			mtime <= 0;
		end
		else begin
			mtime <= mtime + 'd1;
		end
		o_irq <= (mtimeslice >= mtimecmp);
	end
endmodule
`default_nettype none

`ifdef SIM
	`include `CONFIG_PATH
`else
	`include "./config.txt"
`endif

module service_ihp #(
	parameter SIM = 1,
	parameter ENCODING_BYPASS = 0,
	parameter CHANNELS = `INPUT_CHANNELS,
	parameter ORDER = 2,
	parameter WINDOW = 8192,
	parameter REF_PERIOD = 1024,
	parameter DW = `DW,

	parameter WIDTH = 16,

	parameter MAX_NEURONS = 128,
	parameter MAX_SYNAPSES = 128,

	parameter INPUT_SPIKE_1 = `INPUT_SPIKE_1, 
	parameter NEURON_1 = `NEURON_1,  
	parameter WEIGHTS_FILE_1 = "weights_1.txt",
	parameter [13:0] current_decay_1 = `CURRENT_DECAY_1,
	parameter [13:0] voltage_decay_1 = `VOLTAGE_DECAY_1,
	parameter [WIDTH-1:0] threshold_1 = `THRESHOLD_1,

	parameter INPUT_SPIKE_2 = NEURON_1,
	parameter NEURON_2 = `NEURON_2,
	parameter WEIGHTS_FILE_2 = "weights_2.txt",
	parameter [13:0] current_decay_2 = `CURRENT_DECAY_2,
	parameter [13:0] voltage_decay_2 = `VOLTAGE_DECAY_2,
	parameter [WIDTH-1:0] threshold_2 = `THRESHOLD_2,

	parameter INPUT_SPIKE_3 = NEURON_2, 
	parameter NEURON_3 = `NEURON_3,  
	parameter WEIGHTS_FILE_3 = "weights_3.txt",
	parameter [13:0] current_decay_3 = `CURRENT_DECAY_3,
	parameter [13:0] voltage_decay_3 = `VOLTAGE_DECAY_3,
	parameter [WIDTH-1:0] threshold_3 = `THRESHOLD_3,

	parameter INPUT_SPIKE_4 = NEURON_3,
	parameter NEURON_4 = `NEURON_4,
	parameter WEIGHTS_FILE_4 = "weights_4.txt",
	parameter [13:0] current_decay_4 = `CURRENT_DECAY_4,
	parameter [13:0] voltage_decay_4 = `VOLTAGE_DECAY_4,
	parameter [WIDTH-1:0] threshold_4 = `THRESHOLD_4,

	parameter DOUBLE_CLOCK = 0, // if DOUBLE_CLOCK = 0 clk is generated from HFOSC, allowed freq are 48,24,12,6
	parameter pClockFrequency = 24_000_000/(DOUBLE_CLOCK+1),
	parameter DIVR = 4'b0000,
	parameter DIVF = 7'b1010100,
	parameter DIVQ = 3'b110,
	parameter HFOSC = "0b01", // "0b00" = 48 MHz, "0b01" = 24 MHz, "0b10" = 12 MHz, "0b11" = 6 MHz

	parameter memfile = "firmware/exe.hex",
	parameter memsize =  4096,
	parameter PLL = "NONE"
)
(
	output wire [3:0] led,
	input  wire [2:0] buttons,
	output wire o_flash_ss,
	output wire o_flash_sck,
	output wire o_flash_mosi,
	input wire  i_flash_miso,
	output wire o_txd,
	
	//input di servant_clk_gen   
	input wire wb_clk,   
	input wire wb_rst,
	
	output wire gate_general, gate_snn, gate_serv,	
	input  wire timer_clk,
	
	output output_buffer_wr_en_debug,
	output signed [WIDTH-1:0] p1, p2,
	input enb_debug	
			
);	
	
    localparam WEIGHT_DEPTH_12 = 8192;
    localparam WEIGHT_DEPTH_34 = 8192;


//////////////////////////////////////////////////////////////////////////////////////
//   ____  _____ ______     ___    _   _ _____                                      //
//  / ___|| ____|  _ \ \   / / \  | \ | |_   _|                                     //
//  \___ \|  _| | |_) \ \ / / _ \ |  \| | | |                                       //
//   ___) | |___|  _ < \ V / ___ \| |\  | | |                                       //
//  |____/|_____|_| \_\ \_/_/   \_\_| \_| |_|                                       //
//   ____  _____ ______     __  ____  ___ ____   ______     __  ____         ____   //
//  / ___|| ____|  _ \ \   / / |  _ \|_ _/ ___| / ___\ \   / / / ___|  ___  / ___|  //
//  \___ \|  _| | |_) \ \ / /  | |_) || |\___ \| |    \ \ / /  \___ \ / _ \| |      //
//   ___) | |___|  _ < \ V /   |  _ < | | ___) | |___  \ V /    ___) | (_) | |___   //
//  |____/|_____|_| \_\ \_/    |_| \_\___|____/ \____|  \_/    |____/ \___/ \____|  //
//                                                                                  //
//////////////////////////////////////////////////////////////////////////////////////

	wire [31:0] wb_acc_adr;
	wire [31:0] wb_acc_dat;
	wire        wb_acc_we;
	wire        wb_acc_cyc;
	wire [31:0] wb_acc_rdt;
	wire 	  	wb_acc_ack;

	wire        acc_snn_valid;
	wire output_buffer_ren;
	wire [7:0] output_buffer_addr;
	wire [31:0] output_buffer_out;
	wire [31:0] acc_snn_adr_w1;
	wire [31:0] acc_snn_adr_w2;
	wire [31:0] acc_snn_adr_w3;
	wire [31:0] acc_snn_adr_w4;
	wire [ 4:0] acc_snn_we;
	wire [15:0] acc_snn_dat;
	wire [clogb2(MAX_SYNAPSES-1)-1:0] snn_input_channels; 
	wire [clogb2(MAX_NEURONS-1)-1:0] neuron_1, neuron_2, neuron_3, neuron_4;
	wire [2:0] layers;
	wire [ 7:0] uart_byte;
	wire [ 3:0] sel;
	wire        uart_tx_go;
	wire        uart_tx_done;
	wire [7:0] o_spike_mem_dat;
	wire [7:0] i_spike_mem_adr;
	wire [1:0] i_spike_mem_rd_en;
	wire [1:0] i_spike_mem_wr_en;
	wire [3:0] i_spike_mem_dat;
	wire [15:0] o_sample_mem_dat;	
	wire [7:0] i_sample_mem_adr;
	wire       i_sample_mem_rd_en; 
	wire        i_sample_mem_wr_en;
	wire [15:0] i_sample_mem_dat; 
	wire encoding_bypass;
	// wire gate_spi, gate_snn, gate_enc, gate_serv, gate_general;
	wire gate_spi, gate_enc;
	wire timer_irq;


	servant #(
		.memfile (memfile)
	)
	
	servant(
		.wb_clk (wb_clk),
		.timer_clk(timer_clk),
		.wb_rst (wb_rst),
		
		.led      (led),
		.buttons(buttons),
		.timer_irq(timer_irq),

		.o_wb_acc_adr   (wb_acc_adr),
		.o_wb_acc_dat   (wb_acc_dat),
		.o_wb_acc_we    (wb_acc_we),
		.o_wb_acc_cyc   (wb_acc_cyc),
		.i_wb_acc_rdt   (wb_acc_rdt),
		.i_wb_acc_ack   (wb_acc_ack),
		
		.enb_debug(enb_debug)
	);

////////////////////////////////////////////////////////////////////////////////////////////////////
//   ____  _   _ ____    ___ _   _ _____ _____ ____   ____ ___  _   _ _   _ _____ ____ _____      //
//  | __ )| | | / ___|  |_ _| \ | |_   _| ____|  _ \ / ___/ _ \| \ | | \ | | ____/ ___|_   _|     //
//  |  _ \| | | \___ \   | ||  \| | | | |  _| | |_) | |  | | | |  \| |  \| |  _|| |     | |       //
//  | |_) | |_| |___) |  | || |\  | | | | |___|  _ <| |__| |_| | |\  | |\  | |__| |___  | |       //
//  |____/ \___/|____/  |___|_| \_| |_| |_____|_| \_\\____\___/|_| \_|_| \_|_____\____| |_|       //
//    __ _           _           _        __                                                      //
//   / _| | __ _ ___| |__       (_)_ __  / _| ___ _ __ ___ _ __   ___ ___                         //
//  | |_| |/ _` / __| '_ \      | | '_ \| |_ / _ \ '__/ _ \ '_ \ / __/ _ \                        //
//  |  _| | (_| \__ \ | | |  _  | | | | |  _|  __/ | |  __/ | | | (_|  __/  _                     //
//  |_| |_|\__,_|___/_| |_| ( ) |_|_| |_|_|  \___|_|  \___|_| |_|\___\___| ( )                    //
//                          |/ _                      _ _                  |/                     //
//   ___  __ _ _ __ ___  _ __ | | ___       ___ _ __ (_) | _____   _ __ ___   ___ _ __ ___  ___   //
//  / __|/ _` | '_ ` _ \| '_ \| |/ _ \     / __| '_ \| | |/ / _ \ | '_ ` _ \ / _ \ '_ ` _ \/ __|  //
//  \__ \ (_| | | | | | | |_) | |  __/  _  \__ \ |_) | |   <  __/ | | | | | |  __/ | | | | \__ \  //
//  |___/\__,_|_| |_| |_| .__/|_|\___| ( ) |___/ .__/|_|_|\_\___| |_| |_| |_|\___|_| |_| |_|___/  //
//                      |_|            |/      |_|                                                //
// 																								  //
////////////////////////////////////////////////////////////////////////////////////////////////////

	accelerator_top 
	acc_top(
	
	.wb_clk(wb_clk),
	.spi_clk(wb_clk),
	.wb_rst(wb_rst),

	.i_cpu_adr(wb_acc_adr),
	.i_cpu_dat(wb_acc_dat),
	.i_cpu_we(wb_acc_we),
	.i_cpu_cyc(wb_acc_cyc),
	.o_cpu_rdt(wb_acc_rdt),
	.o_cpu_ack(wb_acc_ack),

	.o_flash_sck(o_flash_sck),
	.o_flash_mosi(o_flash_mosi),
	.o_flash_ss(o_flash_ss),
	.i_flash_miso(i_flash_miso),

	.i_snn_valid(acc_snn_valid),
	.output_buffer_ren(output_buffer_ren),
	.output_buffer_addr(output_buffer_addr),
	.output_buffer_out(output_buffer_out),
	.o_snn_adr_w1(acc_snn_adr_w1),
	.o_snn_adr_w2(acc_snn_adr_w2),
	.o_snn_adr_w3(acc_snn_adr_w3),
	.o_snn_adr_w4(acc_snn_adr_w4),
	.o_snn_we(acc_snn_we),
	.o_snn_dat(acc_snn_dat),
	.snn_input_channels(snn_input_channels), 
	.neuron_1(neuron_1), .neuron_2(neuron_2), .neuron_3(neuron_3), .neuron_4(neuron_4), 
	.layers(layers),
	.o_txd(o_txd),
	.i_spike_mem_dat(o_spike_mem_dat),
	.o_spike_mem_adr(i_spike_mem_adr),
	.o_spike_mem_rd_en(i_spike_mem_rd_en),		
	.o_spike_mem_wr_en(i_spike_mem_wr_en),
	.o_spike_mem_dat(i_spike_mem_dat),
	.i_sample_mem_dat(o_sample_mem_dat),	
	.o_sample_mem_adr(i_sample_mem_adr),
	.o_sample_mem_rd_en(i_sample_mem_rd_en),
	.o_sample_mem_wr_en(i_sample_mem_wr_en),
	.o_sample_mem_dat(i_sample_mem_dat),
	.o_encoding_bypass(encoding_bypass),
	.gate_spi(gate_spi), .gate_snn(gate_snn), .gate_enc(gate_enc), .gate_serv(gate_serv), 
	.timer_irq(timer_irq), .gate_general(gate_general)
    );




///////////////////////////////////////////////////////////////////////////////////////
//   ____              _             _                                               //
//  / ___| _   _ _ __ | |_ _____   _| |_   _   _                                     //
//  \___ \| | | | '_ \| __|_  / | | | | | | | (_)                                    //
//   ___) | |_| | | | | |_ / /| |_| | | |_| |  _                                     //
//  |____/ \__, |_| |_|\__/___|\__,_|_|\__,_| (_)                                    //
//   __  __|___/                  _ _                  _ _ _                         //
//  |  \/  | ___  ___  __ _ _   _(_) |_ ___           | (_) | _____                  //
//  | |\/| |/ _ \/ __|/ _` | | | | | __/ _ \   _____  | | | |/ / _ \                 //
//  | |  | | (_) \__ \ (_| | |_| | | || (_) | |_____| | | |   <  __/                 //
//  |_|  |_|\___/|___/\__, |\__,_|_|\__\___/          |_|_|_|\_\___|                 //
//                       |_|                                                         //
//   _____ _       _     _                                   ____ ___ __  __ ____    //
//  | ____(_) __ _| |__ | |_          __      ____ _ _   _  / ___|_ _|  \/  |  _ \   //
//  |  _| | |/ _` | '_ \| __|  _____  \ \ /\ / / _` | | | | \___ \| || |\/| | | | |  //
//  | |___| | (_| | | | | |_  |_____|  \ V  V / (_| | |_| |  ___) | || |  | | |_| |  //
//  |_____|_|\__, |_| |_|\__|           \_/\_/ \__,_|\__, | |____/___|_|  |_|____/   //
//           |___/                                   |___/                           //
//   ____  _   _ _   _                                                               //
//  / ___|| \ | | \ | |  _ __  _ __ ___   ___ ___  ___ ___  ___  _ __                //
//  \___ \|  \| |  \| | | '_ \| '__/ _ \ / __/ _ \/ __/ __|/ _ \| '__|               //
//   ___) | |\  | |\  | | |_) | | | (_) | (_|  __/\__ \__ \ (_) | |                  //
//  |____/|_| \_|_| \_| | .__/|_|  \___/ \___\___||___/___/\___/|_|                  //
//                      |_|                                                          //
// 																					 //
///////////////////////////////////////////////////////////////////////////////////////

    Syntzulu 
     
    mosquito
    (
	.clk_enc    (wb_clk),
	.clk_snn    (wb_clk), 
	.rst        (wb_rst),
	
	.en         (acc_snn_we[4]),
	.data_in    (acc_snn_dat),
	.detect     (1'b1),

	.encoding_bypass(1'b0),

	.valid  (acc_snn_valid),

	.weight_mem_L1_wren     ({8{acc_snn_we[0]}}),
	.weight_mem_L1_wr_addr  (acc_snn_adr_w1),
	.weight_mem_L1_data_in  (acc_snn_dat),
	.weight_mem_L1_ena      (acc_snn_we[0]),

	.weight_mem_L2_wren     ({8{acc_snn_we[1]}}),
	.weight_mem_L2_wr_addr  (acc_snn_adr_w2),
	.weight_mem_L2_data_in  (acc_snn_dat),
	.weight_mem_L2_ena      (acc_snn_we[1]),

	.weight_mem_L3_wren     ({8{acc_snn_we[2]}}),
	.weight_mem_L3_wr_addr  (acc_snn_adr_w3),
	.weight_mem_L3_data_in  (acc_snn_dat),
	.weight_mem_L3_ena      (acc_snn_we[2]),

	.weight_mem_L4_wren     ({8{acc_snn_we[3]}}),
	.weight_mem_L4_wr_addr  (acc_snn_adr_w4),
	.weight_mem_L4_data_in  (acc_snn_dat),
	.weight_mem_L4_ena      (acc_snn_we[3]),

	// ACCESSIBILITY
	.o_spike_mem_dat(o_spike_mem_dat),
	.i_spike_mem_adr(i_spike_mem_adr),
	.i_spike_mem_rd_en(i_spike_mem_rd_en),
	.i_spike_mem_wr_en(i_spike_mem_wr_en),
	.i_spike_mem_dat(i_spike_mem_dat),
	.o_sample_mem_dat(o_sample_mem_dat),	
	.i_sample_mem_adr(i_sample_mem_adr),
	.i_sample_mem_rd_en(i_sample_mem_rd_en),
	.i_sample_mem_wr_en(i_sample_mem_wr_en),
	.i_sample_mem_dat(i_sample_mem_dat),

	// CONFIGURABILITY
	.snn_input_channels(snn_input_channels), 
	.neuron_1(neuron_1), .neuron_2(neuron_2), .neuron_3(neuron_3), .neuron_4(neuron_4),
	.layers(layers),

	// OUTPUT BUFFER ACCESS

	.output_buffer_ren(output_buffer_ren),
	.output_buffer_addr(output_buffer_addr),
	.output_buffer_out(output_buffer_out),
	
	.output_buffer_wr_en_debug(output_buffer_wr_en_debug),
	.p1(p1), 
	.p2(p2),
	
	.enb_debug(enb_debug)
    );
    

	//  The following function calculates the address width based on specified RAM depth
	function integer clogb2;
	  input integer depth;
		for (clogb2=0; depth>0; clogb2=clogb2+1)
		  depth = depth >> 1;
	endfunction   

endmodule
`default_nettype none

`define OPENROAD_CLKGATE

`ifdef SIM
	`include `CONFIG_PATH
`else
	`include "./config.txt"
`endif

module service_ihp_chip
(
	//output wire [3:0] led,  
	input  wire [2:0] buttons,    
	
	output wire o_flash_ss,      
	output wire o_flash_sck,     
	output wire o_flash_mosi,    
	input wire  i_flash_miso,
	
	//input di servant_clk_gen   
	input wire wb_clk,              
	input wire wb_rst,              
	
	//output wire gate_general,
	// output wire gate_snn, gate_serv,	  
	input  wire timer_clk,   
	
	//output wire output_buffer_wr_en_debug,
	//output wire signed [15:0] p1, p2,
	input  wire enb_debug
	
	//output wire o_txd
			
);	
	
       wire [2:0] buttons_i;
       wire [3:0] led_i;
       wire signed [15:0] p1_i, p2_i;
       
       wire wb_clk_i, wb_rst_i, enb_debug_i, timer_clk_i, i_flash_miso_i;
       wire o_flash_ss_i, o_flash_sck_i, o_flash_mosi_i;
       wire gate_general_i, gate_snn_i, gate_serv_i;
       wire output_buffer_wr_en_debug_i;
    
       wire o_txd_i;
    
       // sg13g2_IOPadIn        pad_wb_clk          (.pad(wb_clk),       .p2c(wb_clk_i));
       // sg13g2_IOPadIn        pad_wb_rst          (.pad(wb_rst),       .p2c(wb_rst_i));
       // sg13g2_IOPadIn        pad_enb_debug       (.pad(enb_debug),    .p2c(enb_debug_i));    
       // sg13g2_IOPadIn        pad_timer_clk       (.pad(timer_clk),    .p2c(timer_clk_i));
       
       // sg13g2_IOPadIn        pad_i_flash_miso    (.pad(i_flash_miso), .p2c(i_flash_miso_i));       
       // sg13g2_IOPadOut16mA   pad_o_flash_ss      (.pad(o_flash_ss),   .c2p(o_flash_ss_i));
       // sg13g2_IOPadOut16mA   pad_o_flash_sck     (.pad(o_flash_sck),  .c2p(o_flash_sck_i));
       // sg13g2_IOPadOut16mA   pad_o_flash_mosi    (.pad(o_flash_mosi), .c2p(o_flash_mosi_i));

       // sg13g2_IOPadIn        pad_buttons_0    (.pad(buttons[0]),    .p2c(buttons_i[0]));
       // sg13g2_IOPadIn        pad_buttons_1    (.pad(buttons[1]),    .p2c(buttons_i[1]));
       // sg13g2_IOPadIn        pad_buttons_2    (.pad(buttons[2]),    .p2c(buttons_i[2]));

       assign wb_clk_i     = wb_clk;
       assign wb_rst_i     = wb_rst;
       assign enb_debug_i  = enb_debug;
       assign timer_clk_i  = timer_clk;
       assign i_flash_miso_i = i_flash_miso;
       assign o_flash_ss   = o_flash_ss_i;
       assign o_flash_sck  = o_flash_sck_i;
       assign o_flash_mosi = o_flash_mosi_i;
       assign buttons_i[0] = buttons[0];
       assign buttons_i[1] = buttons[1];
       assign buttons_i[2] = buttons[2];  
       
       //sg13g2_IOPadOut16mA    pad_o_txd  (.pad(o_txd),   .c2p(o_txd_i));
         
       
       //sg13g2_IOPadOut16mA   pad_gate_general              (.pad(gate_general),              .c2p(gate_general_i));
       
/* 
       sg13g2_IOPadOut16mA   pad_gate_snn                  (.pad(gate_snn),                  .c2p(gate_snn_i));
       sg13g2_IOPadOut16mA   pad_gate_serv                 (.pad(gate_serv),                 .c2p(gate_serv_i));
       
         
       sg13g2_IOPadOut16mA pad_led_0 (.pad(led[0]), .c2p(led_i[0]));
       sg13g2_IOPadOut16mA pad_led_1 (.pad(led[1]), .c2p(led_i[1]));
       sg13g2_IOPadOut16mA pad_led_2 (.pad(led[2]), .c2p(led_i[2]));
       sg13g2_IOPadOut16mA pad_led_3 (.pad(led[3]), .c2p(led_i[3]));


       sg13g2_IOPadOut16mA   pad_output_buffer_wr_en_debug (.pad(output_buffer_wr_en_debug), .c2p(output_buffer_wr_en_debug_i));
       sg13g2_IOPadOut16mA pad_p1_0  (.pad(p1[0]),  .c2p(p1_i[0]));
       sg13g2_IOPadOut16mA pad_p1_1  (.pad(p1[1]),  .c2p(p1_i[1]));
       sg13g2_IOPadOut16mA pad_p1_2  (.pad(p1[2]),  .c2p(p1_i[2]));
       sg13g2_IOPadOut16mA pad_p1_3  (.pad(p1[3]),  .c2p(p1_i[3]));
       sg13g2_IOPadOut16mA pad_p1_4  (.pad(p1[4]),  .c2p(p1_i[4]));
       sg13g2_IOPadOut16mA pad_p1_5  (.pad(p1[5]),  .c2p(p1_i[5]));
       sg13g2_IOPadOut16mA pad_p1_6  (.pad(p1[6]),  .c2p(p1_i[6]));
       sg13g2_IOPadOut16mA pad_p1_7  (.pad(p1[7]),  .c2p(p1_i[7]));
       sg13g2_IOPadOut16mA pad_p1_8  (.pad(p1[8]),  .c2p(p1_i[8]));
       sg13g2_IOPadOut16mA pad_p1_9  (.pad(p1[9]),  .c2p(p1_i[9]));
       sg13g2_IOPadOut16mA pad_p1_10 (.pad(p1[10]), .c2p(p1_i[10]));
       sg13g2_IOPadOut16mA pad_p1_11 (.pad(p1[11]), .c2p(p1_i[11]));
       sg13g2_IOPadOut16mA pad_p1_12 (.pad(p1[12]), .c2p(p1_i[12]));
       sg13g2_IOPadOut16mA pad_p1_13 (.pad(p1[13]), .c2p(p1_i[13]));
       sg13g2_IOPadOut16mA pad_p1_14 (.pad(p1[14]), .c2p(p1_i[14]));
       sg13g2_IOPadOut16mA pad_p1_15 (.pad(p1[15]), .c2p(p1_i[15]));

       sg13g2_IOPadOut16mA pad_p2_0  (.pad(p2[0]),  .c2p(p2_i[0]));
       sg13g2_IOPadOut16mA pad_p2_1  (.pad(p2[1]),  .c2p(p2_i[1]));
       sg13g2_IOPadOut16mA pad_p2_2  (.pad(p2[2]),  .c2p(p2_i[2]));
       sg13g2_IOPadOut16mA pad_p2_3  (.pad(p2[3]),  .c2p(p2_i[3]));
       sg13g2_IOPadOut16mA pad_p2_4  (.pad(p2[4]),  .c2p(p2_i[4]));
       sg13g2_IOPadOut16mA pad_p2_5  (.pad(p2[5]),  .c2p(p2_i[5]));
       sg13g2_IOPadOut16mA pad_p2_6  (.pad(p2[6]),  .c2p(p2_i[6]));
       sg13g2_IOPadOut16mA pad_p2_7  (.pad(p2[7]),  .c2p(p2_i[7]));
       sg13g2_IOPadOut16mA pad_p2_8  (.pad(p2[8]),  .c2p(p2_i[8]));
       sg13g2_IOPadOut16mA pad_p2_9  (.pad(p2[9]),  .c2p(p2_i[9]));
       sg13g2_IOPadOut16mA pad_p2_10 (.pad(p2[10]), .c2p(p2_i[10]));
       sg13g2_IOPadOut16mA pad_p2_11 (.pad(p2[11]), .c2p(p2_i[11]));
       sg13g2_IOPadOut16mA pad_p2_12 (.pad(p2[12]), .c2p(p2_i[12]));
       sg13g2_IOPadOut16mA pad_p2_13 (.pad(p2[13]), .c2p(p2_i[13]));
       sg13g2_IOPadOut16mA pad_p2_14 (.pad(p2[14]), .c2p(p2_i[14]));
       sg13g2_IOPadOut16mA pad_p2_15 (.pad(p2[15]), .c2p(p2_i[15]));
*/

	wire gate_general, wb_clk_i_gated;
	
	OPENROAD_CLKGATE gating_cell (wb_clk_i, gate_general, wb_clk_i_gated);
	

	service_ihp  service_ihp(	        

		.buttons(buttons_i),

		.o_flash_ss(o_flash_ss_i),
		.o_flash_sck(o_flash_sck_i),
		.o_flash_mosi(o_flash_mosi_i),
		.i_flash_miso(i_flash_miso_i),
		//.o_txd(o_txd_i),

		.wb_clk    (wb_clk_i_gated  ),
		.wb_rst    (wb_rst_i  ),
		.timer_clk (timer_clk_i),

		.gate_general(gate_general),
		//.gate_snn       (gate_snn_i),
		//.gate_serv      (gate_serv_i),

		.enb_debug(enb_debug_i)
		
		
		//.output_buffer_wr_en_debug(output_buffer_wr_en_debug_i),
		//.p1(p1_i), .p2(p2_i)

	);	


	//  The following function calculates the address width based on specified RAM depth
	function integer clogb2;
	  input integer depth;
		for (clogb2=0; depth>0; clogb2=clogb2+1)
		  depth = depth >> 1;
	endfunction   

endmodule
`default_nettype none

`ifdef SIM
	`include `CONFIG_PATH
`else
	`include "./config.txt"
`endif

module service_ihp_top #(
	parameter SIM = 1,
	parameter ENCODING_BYPASS = 0,
	parameter CHANNELS = `INPUT_CHANNELS,
	parameter ORDER = 2,
	parameter WINDOW = 8192,
	parameter REF_PERIOD = 1024,
	parameter DW = `DW,

	parameter WIDTH = 16,

	parameter MAX_NEURONS = 128,
	parameter MAX_SYNAPSES = 128,

	parameter INPUT_SPIKE_1 = `INPUT_SPIKE_1, 
	parameter NEURON_1 = `NEURON_1,  
	parameter WEIGHTS_FILE_1 = "weights_1.txt",
	parameter [13:0] current_decay_1 = `CURRENT_DECAY_1,
	parameter [13:0] voltage_decay_1 = `VOLTAGE_DECAY_1,
	parameter [WIDTH-1:0] threshold_1 = `THRESHOLD_1,

	parameter INPUT_SPIKE_2 = NEURON_1,
	parameter NEURON_2 = `NEURON_2,
	parameter WEIGHTS_FILE_2 = "weights_2.txt",
	parameter [13:0] current_decay_2 = `CURRENT_DECAY_2,
	parameter [13:0] voltage_decay_2 = `VOLTAGE_DECAY_2,
	parameter [WIDTH-1:0] threshold_2 = `THRESHOLD_2,

	parameter INPUT_SPIKE_3 = NEURON_2, 
	parameter NEURON_3 = `NEURON_3,  
	parameter WEIGHTS_FILE_3 = "weights_3.txt",
	parameter [13:0] current_decay_3 = `CURRENT_DECAY_3,
	parameter [13:0] voltage_decay_3 = `VOLTAGE_DECAY_3,
	parameter [WIDTH-1:0] threshold_3 = `THRESHOLD_3,

	parameter INPUT_SPIKE_4 = NEURON_3,
	parameter NEURON_4 = `NEURON_4,
	parameter WEIGHTS_FILE_4 = "weights_4.txt",
	parameter [13:0] current_decay_4 = `CURRENT_DECAY_4,
	parameter [13:0] voltage_decay_4 = `VOLTAGE_DECAY_4,
	parameter [WIDTH-1:0] threshold_4 = `THRESHOLD_4,

	parameter DOUBLE_CLOCK = 0, // if DOUBLE_CLOCK = 0 clk is generated from HFOSC, allowed freq are 48,24,12,6
	parameter pClockFrequency = 24_000_000/(DOUBLE_CLOCK+1),
	parameter DIVR = 4'b0000,
	parameter DIVF = 7'b1010100,
	parameter DIVQ = 3'b110,
	parameter HFOSC = "0b01", // "0b00" = 48 MHz, "0b01" = 24 MHz, "0b10" = 12 MHz, "0b11" = 6 MHz

	parameter memfile = "firmware/exe.hex",
	parameter memsize =  4096,
	parameter PLL = "ICE40_PAD"
)
(
	input wire  i_clk, i_rst,
	output wire [3:0] led,
	input  wire [2:0] buttons,
	output wire o_flash_ss,
	output wire o_flash_sck,
	output wire o_flash_mosi,
	input wire  i_flash_miso,
	output wire o_txd	
);	
	
    localparam WEIGHT_DEPTH_12 = 8192;
    localparam WEIGHT_DEPTH_34 = 8192;

//////////////////////////////////////////////////////////////////////////////////
//   ____  _     _            ____ _     _  __               ____ _____ _   _   //
//  |  _ \| |   | |      _   / ___| |   | |/ /___           / ___| ____| \ | |  //
//  | |_) | |   | |     (_) | |   | |   | ' // __|  _____  | |  _|  _| |  \| |  //
//  |  __/| |___| |___   _  | |___| |___| . \\__ \ |_____| | |_| | |___| |\  |  //
//  |_|   |_____|_____| (_)  \____|_____|_|\_\___/          \____|_____|_| \_|  //
//                                                                              //
//////////////////////////////////////////////////////////////////////////////////

	wire      wb_clk;
	wire      wb_rst;
	wire      spi_clk;
	wire	  rst_gfcm;
	wire      slow_clk;
	wire      gate_general;


	servant_clock_gen #(.SIM(SIM), .DOUBLE_CLOCK(DOUBLE_CLOCK), .DIVR(DIVR), .DIVF(DIVF), .DIVQ(DIVQ), .HFOSC(HFOSC))
	clock_gen(
		.i_clk      (i_clk),
		.i_rst	    (i_rst),
		.o_clk      (spi_clk),   
		.o_half_clk (wb_clk),   
		.o_slow_clk (slow_clk), // 10 kHz
		.o_rst      (wb_rst),
		.o_rst_gfcm (rst_gfcm),
		.bypass     (1'b0),
		.low_power_mode(1'b1)  //mettere gate_general se si vuole il gating -- mettere 1'b1 se non si vuole il gating
	);
	
	wire timer_clk;
	wire gate_snn;
	wire gate_serv;
	wire rst;
	
	wire spi_clk_g;
	wire wb_clk_snn; 
	wire wb_clk_enc;
	wire wb_clk_serv;
	
	assign rst = wb_rst;
	
	
	`ifdef LOW_POWER
		assign spi_clk_g    = spi_clk;
		assign wb_clk_snn   = wb_clk;
		assign wb_clk_enc   = wb_clk;
		assign wb_clk_serv  = wb_clk;
		
	`else
		assign spi_clk_g    = spi_clk;
		assign wb_clk_snn   = wb_clk;
		assign wb_clk_enc   = wb_clk;
		assign wb_clk_serv  = wb_clk;
	`endif
	
	assign timer_clk = slow_clk;
	
	
	service_ihp_chip   

	service_ihp_chip(	        
	
				//.led(led),
				.buttons(buttons),
				
				.o_flash_ss(o_flash_ss),
				.o_flash_sck(o_flash_sck),
				.o_flash_mosi(o_flash_mosi),
				.i_flash_miso(i_flash_miso),
				
				.wb_clk    (i_clk  ),
				.wb_rst    (wb_rst ),
				.timer_clk (timer_clk),
				.enb_debug(1'b1)
				
				//.o_txd(o_txd)
				
				//.gate_general(gate_general)
				//.gate_snn       (gate_snn),
				//.gate_serv      (gate_serv),
				
			
			);	



	//  The following function calculates the address width based on specified RAM depth
	function integer clogb2;
	  input integer depth;
		for (clogb2=0; depth>0; clogb2=clogb2+1)
		  depth = depth >> 1;
	endfunction   

endmodule
`default_nettype none
module snn_addr_counter
#(
    parameter DEPTH = 8192
)
(
    input  wire clk,
    input  wire rst,
    input  wire clr,
    input  wire inc,
    output reg  [clogb2(DEPTH)-1:0] addr
);

    always @(posedge clk) begin
        if (rst | clr) begin
            addr <= 0;
        end
        else if (inc) begin
                addr <= addr + 1;
        end
    end

    function integer clogb2;
        input integer depth;
        for (clogb2=0; depth>0; clogb2=clogb2+1)
            depth = depth >> 1;
    endfunction   

endmodule`default_nettype none

module spi_acc_control #(parameter DOUBLE_CLOCK = 0) (
    input  wire wb_clk,
    input  wire wb_rst,

    input  wire i_if_start,
    output wire o_if_load1,
    output wire o_if_load2,
    output wire o_if_snn_we,
    output wire o_if_set0,
    output wire o_if_clr,

    input  wire i_spi_valid,
    input  wire i_spi_end,
    output wire o_spi_en,
    output wire o_spi_read_ack
    );

    reg [4:0] out;
    reg     if_load1_ff,    if_load2_ff,    if_snn_we_ff,   if_set0_ff, if_clr_ff;
    wire    if_load1,       if_load2,       if_snn_we,      if_set0,    if_clr;

    assign {o_spi_en, if_load1, if_load2, if_snn_we, if_set0} = out;
    assign if_clr = o_spi_en;
    assign o_spi_read_ack = if_snn_we;

    assign o_if_load1   = DOUBLE_CLOCK? (if_load1  | if_load1_ff)  : if_load1;
    assign o_if_load2   = DOUBLE_CLOCK? (if_load2  | if_load2_ff)  : if_load2;
    assign o_if_snn_we  = DOUBLE_CLOCK? (if_snn_we | if_snn_we_ff) : if_snn_we;
    assign o_if_set0    = DOUBLE_CLOCK? (if_set0   | if_set0_ff)   : if_set0;
    assign o_if_clr     = DOUBLE_CLOCK? (if_clr    | if_clr_ff)    : if_clr;
    
    parameter [2:0]
        IDLE = 0,
        ENABLE = 1,
        WAIT_DATA1 = 2,
        WAIT_DATA2 = 3,
        WRITE_DATA = 4,
        END_SET0 = 5,
        DUMMY = 6;
    
    reg [2:0] state, state_next;

    // state transition
    always @(posedge wb_clk) begin
        if (wb_rst) begin
            state        <= IDLE;
            if_load1_ff  <= 0;
            if_load2_ff  <= 0;
            if_snn_we_ff <= 0;
            if_set0_ff   <= 0;
            if_clr_ff    <= 0;
        end
        else begin
            state           <= state_next;
            if_load1_ff     <= if_load1;
            if_load2_ff     <= if_load2;
            if_snn_we_ff    <= if_snn_we;
            if_set0_ff      <= if_set0;
            if_clr_ff       <= if_clr;
        end
    end

    // next state and output logic
    always @(*) begin
        case (state)
            IDLE: begin
                out = 5'b0xx00;
                if (i_if_start) begin
                    state_next = ENABLE;
                end
                else begin
                    state_next = IDLE;
                end
            end
            ENABLE: begin
                out = 5'b1xx00;
                state_next = WAIT_DATA1;
            end
            WAIT_DATA1: begin
                out = 5'b01x00;
                if (i_spi_valid) begin
					state_next = WAIT_DATA2;                
				end
                else begin
                    state_next = WAIT_DATA1;
                end
            end
            WAIT_DATA2: begin
                out = 5'b00100;
                if (i_spi_valid) begin
                    state_next = DUMMY;
                end
                else begin
                    state_next = WAIT_DATA2;
                end
            end
            DUMMY: begin
                out = 5'b00000;
                state_next = WRITE_DATA;
            end
            WRITE_DATA: begin
                out = 5'b00010;
                if (i_spi_end) begin
                    state_next = END_SET0;
                end
                else begin
                    state_next = WAIT_DATA1;
                end
            end
            END_SET0: begin
                out = 5'b0xx01;
                state_next = IDLE;  
            end
            default: begin
                out = 5'b0xx0x;
                state_next = IDLE;
            end
        endcase
    end

endmodule
//spi master module for flash reading (N25Q032A)
module spi_master(
	 input wire clk,
	 input wire reset,
	 output reg SPI_SCK,
	 output SPI_SS,
	 output reg SPI_MOSI,
	 input wire SPI_MISO,
	 input en,
	 input [23:0] addr,
	 output reg valid,
	 output reg end_transaction,
	 input wire rd_ack, 
	 output reg [7:0] rd_data,
	 input wire [17:0] words_to_read,
	 input read_req,
	 input [7:0] wr_data
	);

	//states
	parameter [2:0] IDLE = 0, SEND_CMD = 1, SEND_ADDR= 2, READ_FLASH= 3, WAIT_ACK = 4, SEND_WREN_CMD = 5, WRITE_FLASH = 6;

	reg [2:0] counter_clk;
	reg [17:0] counter_send; //64 max
	reg [2:0] state;
	reg [23:0] read_addr_reg;
	reg [7:0] wr_data_reg;
	reg [7:0] read_cmd;
	reg [7:0] write_cmd;
	reg [7:0] write_en_cmd;
	reg [7:0] cmd;
	reg spi_ss_reg;
	reg read_req_r;
	reg [17:0] words_to_read_reg;
	reg [17:0] words_to_read_reg_sub0, words_to_read_reg_sub1;

	assign SPI_SS = spi_ss_reg;

	/*initial begin
		SPI_SCK = 0;
		valid = 0;

		counter_clk = 0;
		counter_send = 0;
		state = IDLE;
		read_addr_reg = 0;
		end_transaction <= 0;

		//bunch of commands to read status registers as well as the flash from the datasheet
		read_cmd = 8'h03; //read
		write_en_cmd = 8'h06; // page program
		write_cmd = 8'h02; // page program

		SPI_MOSI = 0;
		spi_ss_reg = 1; //active low
		rd_data = 0;
		
		words_to_read_reg <= 0;
	end*/

	always @(posedge clk)
	begin
		if(reset == 1) begin
			state <= IDLE;
		end else begin
			case (state)
				IDLE : begin //wait for an address to be written
					spi_ss_reg <= 1; //un select slave

					// signals from initial
					SPI_SCK <= 0;
					valid <= 0;
					counter_clk <= 0;
					counter_send <= 0;
					//read_addr_reg <= 0;
					end_transaction <= 0;
						//bunch of commands to read status registers as well as the flash from the datasheet
					read_cmd <= 8'h03; //read
					write_en_cmd <= 8'h06; // page program
					write_cmd <= 8'h02; // page program

					SPI_MOSI <= 0;
					spi_ss_reg <= 1; //active low
					rd_data <= 0;
					
					// words_to_read_reg <= 0;
					// end signals from initial

					if(en == 1) begin
						read_addr_reg <= addr;
						wr_data_reg <= wr_data;
						state <= read_req?SEND_CMD:SEND_WREN_CMD; //go directly to the sending of the READ command
						cmd <= read_req?read_cmd:write_cmd;
						read_req_r <= read_req;
						words_to_read_reg <= words_to_read;
					end
				end

				//send a wake up command to the flash, not needed when only reading the flash
				//skipped here
				SEND_WREN_CMD : begin
					counter_clk <= counter_clk + 1;
					spi_ss_reg <= 0;

					if(counter_clk == 3'b000)begin
						SPI_MOSI <= write_en_cmd[7]; //MSB
						SPI_SCK <= 0;
					end

					if(counter_clk >= 3'b001) begin
						SPI_SCK <= 1;
						write_en_cmd[7:0] <= {write_en_cmd[6:0], write_en_cmd[7]};
						counter_clk <= 0;
						counter_send <= counter_send + 1;
						if(counter_send == 7) begin
							spi_ss_reg <= 1;
							state <= SEND_CMD;
							counter_send <= 0;
						end
					end

				end

				//send the read command (8 bit)
				SEND_CMD : begin
					counter_clk <= counter_clk + 1;
					spi_ss_reg <= 0;

					if(counter_clk == 3'b000)begin
						SPI_SCK <= 0;
						SPI_MOSI <= cmd[7]; //MSB
					end

					if(counter_clk >= 3'b001) begin
						SPI_SCK <= 1;
						cmd[7:0] <= {cmd[6:0], cmd[7]};
						counter_clk <= 0;
						counter_send <= counter_send + 1;
						if(counter_send == 7) begin
							state <= SEND_ADDR;
							counter_send <= 0;
						end
					end

				end

				//send the 24bit address we want to read from
				SEND_ADDR : begin
					counter_clk <= counter_clk + 1;
					spi_ss_reg <= 0; //slave is selected

					if(counter_clk == 3'b000) begin
						SPI_MOSI <= read_addr_reg[23]; //MSB
						SPI_SCK <= 0;
					end

					if(counter_clk == 3'b001) begin
						SPI_SCK <= 1;
					end

					if(counter_clk == 3'b010) begin
						SPI_SCK <= 0;
						read_addr_reg[23:0] <= {read_addr_reg[22:0], read_addr_reg[23]};
						counter_clk <= 0;
						counter_send <= counter_send + 1;
						if(counter_send == 23) begin
							state <= read_req_r?READ_FLASH:WRITE_FLASH;
							words_to_read_reg_sub0 <= words_to_read_reg;
							counter_send <= 0;
							
						end
					end
				end

				//read the actual flash value (32bit)
				READ_FLASH: begin
					counter_clk <= counter_clk + 1;
					SPI_MOSI <= 0;
					spi_ss_reg <= 0; //slave is selected
					valid = 0; // init

					if(counter_clk == 3'b000) begin
						SPI_SCK <= 1;
						words_to_read_reg_sub1 <= words_to_read_reg_sub0-1;
						
					end

					if(counter_clk == 3'b001) begin
						SPI_SCK <= 0;
						rd_data[7:0] <= {rd_data[6:0], SPI_MISO};
						counter_clk <= 0;
						counter_send <= counter_send + 1;
						if(counter_send[2:0] == 7) begin
							valid <= 1;
							if(counter_send == /* words_to_read_reg-1 */words_to_read_reg_sub1) begin
								counter_send <= 0;
								state <= WAIT_ACK;
								spi_ss_reg <= 1; //un select slave
							end
						end
						else valid <= 0;
					end

				end
				


				//now that the data is saved, wait for the next read request
				WAIT_ACK: begin
					spi_ss_reg <= 1; //un select slave
					end_transaction <= 1;
					valid <= 0;
					if(rd_ack == 1) begin
						state <= IDLE;
						end_transaction <= 0;
					end
				end
				default: begin
					state <= IDLE;
				end
			endcase

		end
	end
endmodule
`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06.03.2024 16:14:13
// Design Name: 
// Module Name: delta_modulator_multichannel
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module delta_modulator_multichannel #(
	parameter CHANNELS = 16,    
	parameter WIDTH = 16
    )
(
  input wire clk,           // Clock input
  input wire rst,           // Reset input
  input wire en,
  input wire signed [WIDTH-1:0] samples, // Analog input samples (8-bit resolution)
  output reg pos_spike, neg_spike,     // Delta modulation output
  output reg valid
);

    reg signed [WIDTH-1:0] data_in_pipe;
	wire signed [WIDTH-1:0] delta;   

    reg [clogb2(CHANNELS-1)-1:0] channel_cnt, r_channel_cnt, rr_channel_cnt;
    always @(posedge clk)
        if (rst) begin
            channel_cnt <= 0;
            r_channel_cnt <= 0;
			rr_channel_cnt <= 0;
          end
        else begin
            if(en)
                channel_cnt <= channel_cnt + 1'b1;  
            r_channel_cnt <= channel_cnt;
			rr_channel_cnt <= r_channel_cnt;
          end
    
    wire signed [WIDTH-1:0] data_old; // old sample

    ihp_dualport_256x48_dualmem
    #(
      .RAM_WIDTH(WIDTH),        
      .RAM_DEPTH(CHANNELS),             
      .RAM_PERFORMANCE("LOW_LATENCY"), 
	  .INIT_FILE("")      
	)
    sample_mem
     (
      .addra(rr_channel_cnt), 
      .addrb(channel_cnt), 
      .dina(prev_sample),
      .clk(clk),
      .wea(en_dd), 
      .ena(en_dd),                   
      .enb(en),      
      .rst(rst),                    
      .regceb(1'b1),
      
      .doutb(data_old)
    );   

    ihp_single_port_256x48
    #(
      .RAM_WIDTH(WIDTH),        
      .RAM_DEPTH(CHANNELS),             
      .RAM_PERFORMANCE("LOW_LATENCY"), 
      .INIT_FILE("sim/mem/emg/delta.txt")      
	)
    delta_mem
     (
      .addra(), 
      .addrb(channel_cnt), 
      .dina(),
      .clk(clk),
      .wea(1'b0), 
      .ena(1'b0),                   
      .enb(en),      
      .rst(rst),                    
      .regceb(1'b1),
      
      .doutb(delta)
    ); 

  reg signed [WIDTH-1:0] prev_sample;    // next value to store
  reg signed [WIDTH-1:0] samples_d;
  always @(posedge clk) samples_d <= samples;


  always @(posedge clk ) begin
    if (rst) begin
      prev_sample <= 0;
      {pos_spike, neg_spike} <= 0;
    end else 
	begin
      if (samples_d < (data_old - delta))
		begin
			{pos_spike, neg_spike} <= 2'b01;
            prev_sample <= data_old-delta;
		end
      else if (samples_d > (data_old + delta))
			begin
				{pos_spike, neg_spike} <= 2'b10;
				prev_sample <= data_old+delta;
			end
		  else
			begin
				{pos_spike, neg_spike} <= 2'b00;
				prev_sample <= data_old;
			end
    end
  end
  
  reg en_d, en_dd;
  always @(posedge clk)
		begin
			en_d  <= en;
			en_dd <= en_d;
        	valid <= en_d;
		end

////////////////////////////
//  _               ____  //
// | | ___   __ _  |___ \ //
// | |/ _ \ / _` |   __)  //
// | | (_) | (_| |  / __/ //
// |_|\___/ \__, | |_____ //
//          |___/         //
////////////////////////////
   
//  The following function calculates the address width based on specified RAM depth
function integer clogb2;
  input integer depth;
    for (clogb2=0; depth>0; clogb2=clogb2+1)
      depth = depth >> 1;
endfunction 
  
endmodule
`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03.11.2022 10:58:43
// Design Name: 
// Module Name: fifo
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module fifo
#(
parameter DATA_WIDTH = 25, DEPTH = 256
)
(
input clk, rst,
input [DATA_WIDTH-1:0] DI,
input rden, wren,
output [DATA_WIDTH-1:0] DO
    );

reg [DATA_WIDTH-1:0] fifo [DEPTH-1:0];

integer i;
always @(posedge clk)
    if(rst) 
        for(i=0;i<DEPTH;i=i+1)
            fifo[i] = 0;
    else  
        if(wren) begin
            fifo[wr_pointer] <= DI;
           end

reg [clogb2(DEPTH-1)-1:0] rd_pointer;
always @(posedge clk)
    if(rst) 
		rd_pointer <= 0;
	else if(rden)
			if(rd_pointer<DEPTH-1)		
				rd_pointer <= rd_pointer + 1'b1;
			else
				rd_pointer <= 0;

reg [clogb2(DEPTH-1)-1:0] wr_pointer;
always @(posedge clk)
    if(rst) 
		wr_pointer <= 0;
	else if(wren)
			if(wr_pointer<DEPTH-1)
				wr_pointer <= wr_pointer + 1'b1;
			else
				wr_pointer <= 0;

assign DO = fifo[rd_pointer];

	//  The following function calculates the address width based on specified RAM depth
	function integer clogb2;
	  input integer depth;
		for (clogb2=0; depth>0; clogb2=clogb2+1)
		  depth = depth >> 1;
	endfunction 

endmodule
`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03.11.2022 11:06:53
// Design Name: 
// Module Name: stack
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module stack
#(
parameter DATA_WIDTH = 4,
parameter DEPTH = 24
)
(
input clk, rst,
input [DATA_WIDTH-1:0] din,
input wr_en, clear,
input stream_out,

output [DATA_WIDTH-1:0] dout,
output reg done,
output [clogb2(DEPTH-1)-1:0] active_entries,
output empty 
);

// shift register    
reg [DATA_WIDTH-1:0] shift [DEPTH-1:0];
integer i;
always@(posedge clk)
    if (rst)
       for(i=0;i<DEPTH;i=i+1)
            shift[i] <= 0;
    else    
        if(wr_en) begin
            shift[0] <= din;
            for(i=1;i<DEPTH;i=i+1)
                shift[i] <= shift[i-1];
        end
            
// entries counter
reg [clogb2(DEPTH-1):0] entries_cnt;    
always @(posedge clk)
    if(rst)
       entries_cnt <= 0;
    else
        if(wr_en)
            entries_cnt <= entries_cnt + 1'b1;     
        else if (clear)
            entries_cnt <= 0;

// stream counter
reg [clogb2(DEPTH-1)-1:0] stream_cnt;    
always @(posedge clk)
    if(rst)
       stream_cnt <= 0;
    else
        if(stream_out && (entries_cnt != 0) )
            stream_cnt <= entries_cnt - 1'b1;
        else if (stream_cnt != 0) 
            stream_cnt <= stream_cnt - 1'b1;

// output assignment 
assign dout = shift[stream_cnt];

always @(posedge clk)
    if (rst) 
        done = 0;
    else if (stream_cnt == 1 || ( stream_out && ( (entries_cnt == 1) || (entries_cnt == 0) ) ) )
            done <= 1;
         else
            done <= 0;

assign active_entries = entries_cnt == 0 ? 0 : entries_cnt - 1'b1;            
 
assign empty = entries_cnt == 0;
           
//  The following function calculates the address width based on specified RAM depth
function integer clogb2;
  input integer depth;
    for (clogb2=0; depth>0; clogb2=clogb2+1)
      depth = depth >> 1;
endfunction 
   
endmodule
