module cache_lru (
	clk,
	reset,
	fill_en,
	fill_set,
	fill_way,
	access_en,
	access_set,
	update_en,
	update_way
);
	reg _sv2v_0;
	parameter NUM_SETS = 1;
	parameter NUM_WAYS = 4;
	parameter SET_INDEX_WIDTH = $clog2(NUM_SETS);
	parameter WAY_INDEX_WIDTH = $clog2(NUM_WAYS);
	input clk;
	input reset;
	input fill_en;
	input [SET_INDEX_WIDTH - 1:0] fill_set;
	output reg [WAY_INDEX_WIDTH - 1:0] fill_way;
	input access_en;
	input [SET_INDEX_WIDTH - 1:0] access_set;
	input update_en;
	input [WAY_INDEX_WIDTH - 1:0] update_way;
	localparam LRU_FLAG_BITS = (NUM_WAYS == 1 ? 1 : (NUM_WAYS == 2 ? 1 : (NUM_WAYS == 4 ? 3 : 7)));
	wire [LRU_FLAG_BITS - 1:0] lru_flags;
	wire update_lru_en;
	reg [SET_INDEX_WIDTH - 1:0] update_set;
	reg [LRU_FLAG_BITS - 1:0] update_flags;
	wire [SET_INDEX_WIDTH - 1:0] read_set;
	wire read_en;
	reg was_fill;
	wire [WAY_INDEX_WIDTH - 1:0] new_mru;
	assign read_en = access_en || fill_en;
	assign read_set = (fill_en ? fill_set : access_set);
	assign new_mru = (was_fill ? fill_way : update_way);
	assign update_lru_en = was_fill || update_en;
	reg [LRU_FLAG_BITS - 1:0] pass_thru_dat;
	reg [LRU_FLAG_BITS - 1:0] mem;
	reg pass_through_en;
	always @(posedge clk) begin
		pass_through_en <= (update_lru_en && read_en) && (read_set == update_set);
		pass_thru_dat <= update_flags;
		if (update_lru_en)
			mem <= update_flags;
	end
	assign lru_flags = (pass_through_en ? pass_thru_dat : mem);
	generate
		case (NUM_WAYS)
			1: begin : genblk1
				wire [WAY_INDEX_WIDTH:1] sv2v_tmp_F4850;
				assign sv2v_tmp_F4850 = 0;
				always @(*) fill_way = sv2v_tmp_F4850;
				wire [LRU_FLAG_BITS:1] sv2v_tmp_6C66A;
				assign sv2v_tmp_6C66A = 0;
				always @(*) update_flags = sv2v_tmp_6C66A;
			end
			2: begin : genblk1
				wire [WAY_INDEX_WIDTH:1] sv2v_tmp_F4B2A;
				assign sv2v_tmp_F4B2A = !lru_flags[0];
				always @(*) fill_way = sv2v_tmp_F4B2A;
				wire [1:1] sv2v_tmp_0C2DF;
				assign sv2v_tmp_0C2DF = !new_mru;
				always @(*) update_flags[0] = sv2v_tmp_0C2DF;
			end
			4: begin : genblk1
				always @(*) begin
					if (_sv2v_0)
						;
					casez (lru_flags)
						3'b00z: fill_way = 0;
						3'b10z: fill_way = 1;
						3'bz10: fill_way = 2;
						3'bz11: fill_way = 3;
						default: fill_way = 1'sb0;
					endcase
				end
				always @(*) begin
					if (_sv2v_0)
						;
					case (new_mru)
						2'd0: update_flags = {2'b11, lru_flags[0]};
						2'd1: update_flags = {2'b01, lru_flags[0]};
						2'd2: update_flags = {lru_flags[2], 2'b01};
						2'd3: update_flags = {lru_flags[2], 2'b00};
						default: update_flags = 1'sb0;
					endcase
				end
			end
			8: begin : genblk1
				always @(*) begin
					if (_sv2v_0)
						;
					casez (lru_flags)
						7'b00z0zzz: fill_way = 0;
						7'b10z0zzz: fill_way = 1;
						7'bz100zzz: fill_way = 2;
						7'bz110zzz: fill_way = 3;
						7'bzzz100z: fill_way = 4;
						7'bzzz110z: fill_way = 5;
						7'bzzz1z10: fill_way = 6;
						7'bzzz1z11: fill_way = 7;
						default: fill_way = 1'sb0;
					endcase
				end
				always @(*) begin
					if (_sv2v_0)
						;
					case (new_mru)
						3'd0: update_flags = {2'b11, lru_flags[5], 1'b1, lru_flags[2:0]};
						3'd1: update_flags = {2'b01, lru_flags[5], 1'b1, lru_flags[2:0]};
						3'd2: update_flags = {lru_flags[6], 3'b011, lru_flags[2:0]};
						3'd3: update_flags = {lru_flags[6], 3'b001, lru_flags[2:0]};
						3'd4: update_flags = {lru_flags[6:4], 3'b011, lru_flags[0]};
						3'd5: update_flags = {lru_flags[6:4], 3'b001, lru_flags[0]};
						3'd6: update_flags = {lru_flags[6:4], 1'b0, lru_flags[2], 2'b01};
						3'd7: update_flags = {lru_flags[6:4], 1'b0, lru_flags[2], 2'b00};
						default: update_flags = 1'sb0;
					endcase
				end
			end
			default: begin : genblk1
				initial begin
					$display("%m invalid number of ways");
					$finish;
				end
			end
		endcase
	endgenerate
	always @(posedge clk) begin
		update_set <= read_set;
		was_fill <= fill_en;
	end
	initial _sv2v_0 = 0;
endmodule
module cam (
	clk,
	reset,
	lookup_key,
	lookup_idx,
	lookup_hit,
	update_en,
	update_key,
	update_idx,
	update_valid
);
	parameter NUM_ENTRIES = 2;
	parameter KEY_WIDTH = 32;
	parameter INDEX_WIDTH = $clog2(NUM_ENTRIES);
	input clk;
	input reset;
	input [KEY_WIDTH - 1:0] lookup_key;
	output wire [INDEX_WIDTH - 1:0] lookup_idx;
	output wire lookup_hit;
	input update_en;
	input [KEY_WIDTH - 1:0] update_key;
	input [INDEX_WIDTH - 1:0] update_idx;
	input update_valid;
	reg [KEY_WIDTH - 1:0] lookup_table [0:NUM_ENTRIES - 1];
	reg [NUM_ENTRIES - 1:0] entry_valid;
	wire [NUM_ENTRIES - 1:0] hit_oh;
	genvar _gv_test_index_1;
	generate
		for (_gv_test_index_1 = 0; _gv_test_index_1 < NUM_ENTRIES; _gv_test_index_1 = _gv_test_index_1 + 1) begin : lookup_gen
			localparam test_index = _gv_test_index_1;
			assign hit_oh[test_index] = entry_valid[test_index] && (lookup_table[test_index] == lookup_key);
		end
	endgenerate
	assign lookup_hit = |hit_oh;
	oh_to_idx #(.NUM_SIGNALS(NUM_ENTRIES)) oh_to_idx_hit(
		.one_hot(hit_oh),
		.index(lookup_idx)
	);
	always @(posedge clk or posedge reset)
		if (reset) begin : sv2v_autoblock_1
			reg signed [31:0] i;
			for (i = 0; i < NUM_ENTRIES; i = i + 1)
				entry_valid[i] <= 1'b0;
		end
		else if (update_en)
			entry_valid[update_idx] <= update_valid;
	always @(posedge clk)
		if (update_en)
			lookup_table[update_idx] <= update_key;
endmodule
module control_registers (
	clk,
	reset,
	interrupt_req,
	cr_eret_address,
	cr_mmu_en,
	cr_supervisor_en,
	cr_current_asid,
	cr_suspend_thread,
	cr_resume_thread,
	cr_interrupt_pending,
	cr_interrupt_en,
	dt_thread_idx,
	dd_creg_write_en,
	dd_creg_read_en,
	dd_creg_index,
	dd_creg_write_val,
	wb_trap,
	wb_eret,
	wb_trap_cause,
	wb_trap_pc,
	wb_trap_access_vaddr,
	wb_rollback_thread_idx,
	wb_trap_subcycle,
	wb_syscall_index,
	cr_creg_read_val,
	cr_eret_subcycle,
	cr_trap_handler,
	cr_tlb_miss_handler,
	cr_perf_event_select0,
	cr_perf_event_select1,
	perf_event_count0,
	perf_event_count1,
	ocd_data_from_host,
	ocd_data_update,
	cr_data_to_host
);
	parameter CORE_ID = 0;
	parameter NUM_INTERRUPTS = 16;
	parameter NUM_PERF_EVENTS = 8;
	parameter EVENT_IDX_WIDTH = $clog2(NUM_PERF_EVENTS);
	input clk;
	input reset;
	input [NUM_INTERRUPTS - 1:0] interrupt_req;
	output wire [127:0] cr_eret_address;
	output wire [0:3] cr_mmu_en;
	output wire [0:3] cr_supervisor_en;
	localparam defines_ASID_WIDTH = 8;
	output reg [31:0] cr_current_asid;
	localparam defines_TOTAL_THREADS = 4;
	output reg [3:0] cr_suspend_thread;
	output reg [3:0] cr_resume_thread;
	output wire [3:0] cr_interrupt_pending;
	output wire [3:0] cr_interrupt_en;
	input wire [1:0] dt_thread_idx;
	input dd_creg_write_en;
	input dd_creg_read_en;
	input wire [4:0] dd_creg_index;
	input wire [31:0] dd_creg_write_val;
	input wb_trap;
	input wb_eret;
	input wire [5:0] wb_trap_cause;
	input wire [31:0] wb_trap_pc;
	input wire [31:0] wb_trap_access_vaddr;
	input wire [1:0] wb_rollback_thread_idx;
	localparam defines_NUM_VECTOR_LANES = 16;
	input wire [3:0] wb_trap_subcycle;
	input wire [14:0] wb_syscall_index;
	output reg [31:0] cr_creg_read_val;
	output wire [15:0] cr_eret_subcycle;
	output reg [31:0] cr_trap_handler;
	output reg [31:0] cr_tlb_miss_handler;
	output reg [EVENT_IDX_WIDTH - 1:0] cr_perf_event_select0;
	output reg [EVENT_IDX_WIDTH - 1:0] cr_perf_event_select1;
	input [63:0] perf_event_count0;
	input [63:0] perf_event_count1;
	input wire [31:0] ocd_data_from_host;
	input ocd_data_update;
	output wire [31:0] cr_data_to_host;
	localparam TRAP_LEVELS = 3;
	reg [155:0] trap_state [0:3][0:2];
	reg [31:0] page_dir_base [0:3];
	reg [31:0] cycle_count;
	reg [NUM_INTERRUPTS - 1:0] interrupt_mask [0:3];
	wire [NUM_INTERRUPTS - 1:0] interrupt_pending [0:3];
	reg [NUM_INTERRUPTS - 1:0] interrupt_edge_latched [0:3];
	reg [NUM_INTERRUPTS - 1:0] int_trigger_type;
	reg [NUM_INTERRUPTS - 1:0] interrupt_req_prev;
	wire [NUM_INTERRUPTS - 1:0] interrupt_edge;
	reg [31:0] jtag_data;
	assign cr_data_to_host = jtag_data;
	function automatic [2:0] sv2v_cast_3;
		input reg [2:0] inp;
		sv2v_cast_3 = inp;
	endfunction
	function automatic [3:0] sv2v_cast_60D1B;
		input reg [3:0] inp;
		sv2v_cast_60D1B = inp;
	endfunction
	always @(posedge clk or posedge reset)
		if (reset) begin
			begin : sv2v_autoblock_1
				reg signed [31:0] thread_idx;
				for (thread_idx = 0; thread_idx < 4; thread_idx = thread_idx + 1)
					begin
						trap_state[thread_idx][0] <= 1'sb0;
						trap_state[thread_idx][0][155] <= 1'b1;
						cr_current_asid[(3 - thread_idx) * 8+:8] <= 1'sb0;
						page_dir_base[thread_idx] <= 1'sb0;
						interrupt_mask[thread_idx] <= 1'sb0;
					end
			end
			jtag_data <= 1'sb0;
			cr_tlb_miss_handler <= 1'sb0;
			cr_trap_handler <= 1'sb0;
			cycle_count <= 1'sb0;
			int_trigger_type <= 1'sb0;
			cr_suspend_thread <= 1'sb0;
			cr_resume_thread <= 1'sb0;
			cr_perf_event_select0 <= 1'sb0;
			cr_perf_event_select1 <= 1'sb0;
		end
		else begin
			cycle_count <= cycle_count + 1;
			if (wb_trap) begin
				begin : sv2v_autoblock_2
					reg signed [31:0] level;
					for (level = 0; level < 2; level = level + 1)
						trap_state[wb_rollback_thread_idx][level + 1] <= trap_state[wb_rollback_thread_idx][level];
				end
				trap_state[wb_rollback_thread_idx][0][88-:6] <= wb_trap_cause;
				trap_state[wb_rollback_thread_idx][0][82-:32] <= wb_trap_pc;
				trap_state[wb_rollback_thread_idx][0][50-:32] <= wb_trap_access_vaddr;
				trap_state[wb_rollback_thread_idx][0][14-:15] <= wb_syscall_index;
				trap_state[wb_rollback_thread_idx][0][18-:4] <= wb_trap_subcycle;
				trap_state[wb_rollback_thread_idx][0][153] <= 0;
				trap_state[wb_rollback_thread_idx][0][155] <= 1;
				if (wb_trap_cause[3-:4] == 4'd7)
					trap_state[wb_rollback_thread_idx][0][154] <= 0;
			end
			if (wb_eret) begin : sv2v_autoblock_3
				reg signed [31:0] level;
				for (level = 0; level < 2; level = level + 1)
					trap_state[wb_rollback_thread_idx][level] <= trap_state[wb_rollback_thread_idx][level + 1];
			end
			cr_suspend_thread <= 1'sb0;
			cr_resume_thread <= 1'sb0;
			if (dd_creg_write_en)
				(* full_case, parallel_case *)
				case (dd_creg_index)
					5'd4: trap_state[dt_thread_idx][0][155-:3] <= sv2v_cast_3(dd_creg_write_val);
					5'd8: trap_state[dt_thread_idx][1][155-:3] <= sv2v_cast_3(dd_creg_write_val);
					5'd2: trap_state[dt_thread_idx][0][82-:32] <= dd_creg_write_val;
					5'd1: cr_trap_handler <= dd_creg_write_val;
					5'd7: cr_tlb_miss_handler <= dd_creg_write_val;
					5'd11: trap_state[dt_thread_idx][0][152-:32] <= dd_creg_write_val;
					5'd12: trap_state[dt_thread_idx][0][120-:32] <= dd_creg_write_val;
					5'd13: trap_state[dt_thread_idx][0][18-:4] <= sv2v_cast_60D1B(dd_creg_write_val);
					5'd9: cr_current_asid[(3 - dt_thread_idx) * 8+:8] <= dd_creg_write_val[7:0];
					5'd10: page_dir_base[dt_thread_idx] <= dd_creg_write_val;
					5'd14: interrupt_mask[dt_thread_idx] <= dd_creg_write_val[NUM_INTERRUPTS - 1:0];
					5'd17: int_trigger_type <= dd_creg_write_val[NUM_INTERRUPTS - 1:0];
					5'd18: jtag_data <= dd_creg_write_val;
					5'd20: cr_suspend_thread <= dd_creg_write_val[3:0];
					5'd21: cr_resume_thread <= dd_creg_write_val[3:0];
					5'd22: cr_perf_event_select0 <= dd_creg_write_val[EVENT_IDX_WIDTH - 1:0];
					5'd23: cr_perf_event_select1 <= dd_creg_write_val[EVENT_IDX_WIDTH - 1:0];
					default:
						;
				endcase
			else if (ocd_data_update)
				jtag_data <= ocd_data_from_host;
		end
	always @(posedge clk or posedge reset)
		if (reset)
			interrupt_req_prev <= 1'sb0;
		else
			interrupt_req_prev <= interrupt_req;
	assign interrupt_edge = interrupt_req & ~interrupt_req_prev;
	genvar _gv_thread_idx_1;
	generate
		for (_gv_thread_idx_1 = 0; _gv_thread_idx_1 < 4; _gv_thread_idx_1 = _gv_thread_idx_1 + 1) begin : interrupt_gen
			localparam thread_idx = _gv_thread_idx_1;
			wire [NUM_INTERRUPTS - 1:0] interrupt_ack;
			wire do_interrupt_ack;
			assign do_interrupt_ack = ((dt_thread_idx == thread_idx) && dd_creg_write_en) && (dd_creg_index == 5'd15);
			assign interrupt_ack = {NUM_INTERRUPTS {do_interrupt_ack}} & dd_creg_write_val[NUM_INTERRUPTS - 1:0];
			assign cr_interrupt_en[thread_idx] = trap_state[thread_idx][0][153];
			assign cr_supervisor_en[thread_idx] = trap_state[thread_idx][0][155];
			assign cr_mmu_en[thread_idx] = trap_state[thread_idx][0][154];
			assign cr_eret_subcycle[(3 - thread_idx) * 4+:4] = trap_state[thread_idx][0][18-:4];
			assign cr_eret_address[(3 - thread_idx) * 32+:32] = trap_state[thread_idx][0][82-:32];
			always @(posedge clk or posedge reset)
				if (reset)
					interrupt_edge_latched[thread_idx] <= 1'sb0;
				else
					interrupt_edge_latched[thread_idx] <= (interrupt_edge_latched[thread_idx] & ~interrupt_ack) | interrupt_edge;
			assign interrupt_pending[thread_idx] = (int_trigger_type & interrupt_req) | (~int_trigger_type & interrupt_edge_latched[thread_idx]);
			assign cr_interrupt_pending[thread_idx] = |(interrupt_pending[thread_idx] & interrupt_mask[thread_idx]);
		end
	endgenerate
	function automatic [31:0] sv2v_cast_32;
		input reg [31:0] inp;
		sv2v_cast_32 = inp;
	endfunction
	always @(posedge clk)
		if (dd_creg_read_en)
			(* full_case, parallel_case *)
			case (dd_creg_index)
				5'd4: cr_creg_read_val <= sv2v_cast_32(trap_state[dt_thread_idx][0][155-:3]);
				5'd8: cr_creg_read_val <= sv2v_cast_32(trap_state[dt_thread_idx][1][155-:3]);
				5'd0: cr_creg_read_val <= sv2v_cast_32({CORE_ID, dt_thread_idx});
				5'd2: cr_creg_read_val <= trap_state[dt_thread_idx][0][82-:32];
				5'd3: cr_creg_read_val <= sv2v_cast_32(trap_state[dt_thread_idx][0][88-:6]);
				5'd1: cr_creg_read_val <= cr_trap_handler;
				5'd5: cr_creg_read_val <= trap_state[dt_thread_idx][0][50-:32];
				5'd7: cr_creg_read_val <= cr_tlb_miss_handler;
				5'd6: cr_creg_read_val <= cycle_count;
				5'd11: cr_creg_read_val <= trap_state[dt_thread_idx][0][152-:32];
				5'd12: cr_creg_read_val <= trap_state[dt_thread_idx][0][120-:32];
				5'd13: cr_creg_read_val <= sv2v_cast_32(trap_state[dt_thread_idx][0][18-:4]);
				5'd9: cr_creg_read_val <= sv2v_cast_32(cr_current_asid[(3 - dt_thread_idx) * 8+:8]);
				5'd10: cr_creg_read_val <= page_dir_base[dt_thread_idx];
				5'd16: cr_creg_read_val <= sv2v_cast_32(interrupt_pending[dt_thread_idx] & interrupt_mask[dt_thread_idx]);
				5'd14: cr_creg_read_val <= sv2v_cast_32(interrupt_mask[dt_thread_idx]);
				5'd17: cr_creg_read_val <= sv2v_cast_32(int_trigger_type);
				5'd18: cr_creg_read_val <= jtag_data;
				5'd19: cr_creg_read_val <= sv2v_cast_32(trap_state[dt_thread_idx][0][14-:15]);
				5'd24: cr_creg_read_val <= perf_event_count0[31:0];
				5'd25: cr_creg_read_val <= perf_event_count0[63:32];
				5'd26: cr_creg_read_val <= perf_event_count1[31:0];
				5'd27: cr_creg_read_val <= perf_event_count1[63:32];
				default: cr_creg_read_val <= 32'hffffffff;
			endcase
endmodule
module core (
	clk,
	reset,
	thread_en,
	interrupt_req,
	l2_ready,
	l2_response_valid,
	l2_response,
	l2i_request_valid,
	l2i_request,
	ii_ready,
	ii_response_valid,
	ii_response,
	ior_request_valid,
	ior_request,
	ocd_halt,
	ocd_thread,
	ocd_core,
	ocd_inject_inst,
	ocd_inject_en,
	injected_complete,
	injected_rollback,
	ocd_data_from_host,
	ocd_data_update,
	cr_data_to_host,
	cr_suspend_thread,
	cr_resume_thread
);
	parameter CORE_ID = 1'sb0;
	parameter RESET_PC = 1'sb0;
	parameter NUM_INTERRUPTS = 16;
	input clk;
	input reset;
	input wire [3:0] thread_en;
	input [NUM_INTERRUPTS - 1:0] interrupt_req;
	input l2_ready;
	input l2_response_valid;
	localparam defines_NUM_VECTOR_LANES = 16;
	localparam defines_CACHE_LINE_BYTES = 64;
	localparam defines_CACHE_LINE_BITS = 512;
	localparam defines_CACHE_LINE_OFFSET_WIDTH = 6;
	input wire [548:0] l2_response;
	output wire l2i_request_valid;
	output wire [611:0] l2i_request;
	input ii_ready;
	input ii_response_valid;
	input wire [37:0] ii_response;
	output wire ior_request_valid;
	output wire [66:0] ior_request;
	input ocd_halt;
	input wire [1:0] ocd_thread;
	input wire [3:0] ocd_core;
	input wire [31:0] ocd_inject_inst;
	input ocd_inject_en;
	output reg injected_complete;
	output reg injected_rollback;
	input wire [31:0] ocd_data_from_host;
	input ocd_data_update;
	output wire [31:0] cr_data_to_host;
	localparam defines_TOTAL_THREADS = 4;
	output wire [3:0] cr_suspend_thread;
	output wire [3:0] cr_resume_thread;
	localparam defines_CORE_PERF_EVENTS = 14;
	localparam EVENT_IDX_WIDTH = 4;
	localparam NUM_PERF_COUNTERS = 2;
	wire core_selected_debug;
	wire [13:0] perf_events;
	wire [7:0] perf_event_select;
	wire [31:0] cr_creg_read_val;
	localparam defines_ASID_WIDTH = 8;
	wire [31:0] cr_current_asid;
	wire [127:0] cr_eret_address;
	wire [15:0] cr_eret_subcycle;
	wire [3:0] cr_interrupt_en;
	wire [3:0] cr_interrupt_pending;
	wire [0:3] cr_mmu_en;
	wire [0:3] cr_supervisor_en;
	wire [31:0] cr_tlb_miss_handler;
	wire [31:0] cr_trap_handler;
	wire dd_cache_miss;
	wire [25:0] dd_cache_miss_addr;
	wire dd_cache_miss_sync;
	wire [1:0] dd_cache_miss_thread_idx;
	wire [4:0] dd_creg_index;
	wire dd_creg_read_en;
	wire dd_creg_write_en;
	wire [31:0] dd_creg_write_val;
	wire dd_dinvalidate_en;
	wire dd_flush_en;
	wire dd_iinvalidate_en;
	wire [141:0] dd_instruction;
	wire dd_instruction_valid;
	wire dd_io_access;
	wire [31:0] dd_io_addr;
	wire dd_io_read_en;
	wire [1:0] dd_io_thread_idx;
	wire dd_io_write_en;
	wire [31:0] dd_io_write_value;
	wire [15:0] dd_lane_mask;
	wire [511:0] dd_load_data;
	wire [3:0] dd_load_sync_pending;
	wire dd_membar_en;
	wire dd_perf_dcache_hit;
	wire dd_perf_dcache_miss;
	wire dd_perf_dtlb_miss;
	localparam defines_DCACHE_TAG_BITS = 20;
	wire [31:0] dd_request_vaddr;
	wire dd_rollback_en;
	wire [31:0] dd_rollback_pc;
	wire [25:0] dd_store_addr;
	wire [25:0] dd_store_bypass_addr;
	wire [1:0] dd_store_bypass_thread_idx;
	wire [511:0] dd_store_data;
	wire dd_store_en;
	wire [63:0] dd_store_mask;
	wire dd_store_sync;
	wire [1:0] dd_store_thread_idx;
	wire [3:0] dd_subcycle;
	wire dd_suspend_thread;
	wire [1:0] dd_thread_idx;
	wire dd_trap;
	wire [5:0] dd_trap_cause;
	wire dd_update_lru_en;
	wire [1:0] dd_update_lru_way;
	wire [1:0] dt_fill_lru;
	wire [141:0] dt_instruction;
	wire dt_instruction_valid;
	wire dt_invalidate_tlb_all_en;
	wire dt_invalidate_tlb_en;
	wire [15:0] dt_mask_value;
	wire [31:0] dt_request_paddr;
	wire [31:0] dt_request_vaddr;
	wire [79:0] dt_snoop_tag;
	wire [0:3] dt_snoop_valid;
	wire [511:0] dt_store_value;
	wire [3:0] dt_subcycle;
	wire [79:0] dt_tag;
	wire [1:0] dt_thread_idx;
	wire dt_tlb_hit;
	wire dt_tlb_present;
	wire dt_tlb_supervisor;
	wire dt_tlb_writable;
	wire [7:0] dt_update_itlb_asid;
	wire dt_update_itlb_en;
	wire dt_update_itlb_executable;
	wire dt_update_itlb_global;
	localparam defines_PAGE_SIZE = 'h1000;
	localparam defines_PAGE_NUM_BITS = 32 - $clog2('h1000);
	wire [defines_PAGE_NUM_BITS - 1:0] dt_update_itlb_ppage_idx;
	wire dt_update_itlb_present;
	wire dt_update_itlb_supervisor;
	wire [defines_PAGE_NUM_BITS - 1:0] dt_update_itlb_vpage_idx;
	wire [0:3] dt_valid;
	wire [127:0] fx1_add_exponent;
	wire [15:0] fx1_add_result_sign;
	wire [15:0] fx1_equal;
	wire [95:0] fx1_ftoi_lshift;
	wire [141:0] fx1_instruction;
	wire fx1_instruction_valid;
	wire [15:0] fx1_logical_subtract;
	wire [15:0] fx1_mask_value;
	wire [127:0] fx1_mul_exponent;
	wire [15:0] fx1_mul_sign;
	wire [15:0] fx1_mul_underflow;
	wire [511:0] fx1_multiplicand;
	wire [511:0] fx1_multiplier;
	wire [15:0] fx1_result_inf;
	wire [15:0] fx1_result_nan;
	wire [95:0] fx1_se_align_shift;
	wire [511:0] fx1_significand_le;
	wire [511:0] fx1_significand_se;
	wire [3:0] fx1_subcycle;
	wire [1:0] fx1_thread_idx;
	wire [127:0] fx2_add_exponent;
	wire [15:0] fx2_add_result_sign;
	wire [15:0] fx2_equal;
	wire [95:0] fx2_ftoi_lshift;
	wire [15:0] fx2_guard;
	wire [141:0] fx2_instruction;
	wire fx2_instruction_valid;
	wire [15:0] fx2_logical_subtract;
	wire [15:0] fx2_mask_value;
	wire [127:0] fx2_mul_exponent;
	wire [15:0] fx2_mul_sign;
	wire [15:0] fx2_mul_underflow;
	wire [15:0] fx2_result_inf;
	wire [15:0] fx2_result_nan;
	wire [15:0] fx2_round;
	wire [511:0] fx2_significand_le;
	wire [1023:0] fx2_significand_product;
	wire [511:0] fx2_significand_se;
	wire [15:0] fx2_sticky;
	wire [3:0] fx2_subcycle;
	wire [1:0] fx2_thread_idx;
	wire [127:0] fx3_add_exponent;
	wire [15:0] fx3_add_result_sign;
	wire [511:0] fx3_add_significand;
	wire [15:0] fx3_equal;
	wire [95:0] fx3_ftoi_lshift;
	wire [141:0] fx3_instruction;
	wire fx3_instruction_valid;
	wire [15:0] fx3_logical_subtract;
	wire [15:0] fx3_mask_value;
	wire [127:0] fx3_mul_exponent;
	wire [15:0] fx3_mul_sign;
	wire [15:0] fx3_mul_underflow;
	wire [15:0] fx3_result_inf;
	wire [15:0] fx3_result_nan;
	wire [1023:0] fx3_significand_product;
	wire [3:0] fx3_subcycle;
	wire [1:0] fx3_thread_idx;
	wire [127:0] fx4_add_exponent;
	wire [15:0] fx4_add_result_sign;
	wire [511:0] fx4_add_significand;
	wire [15:0] fx4_equal;
	wire [141:0] fx4_instruction;
	wire fx4_instruction_valid;
	wire [15:0] fx4_logical_subtract;
	wire [15:0] fx4_mask_value;
	wire [127:0] fx4_mul_exponent;
	wire [15:0] fx4_mul_sign;
	wire [15:0] fx4_mul_underflow;
	wire [95:0] fx4_norm_shift;
	wire [15:0] fx4_result_inf;
	wire [15:0] fx4_result_nan;
	wire [1023:0] fx4_significand_product;
	wire [3:0] fx4_subcycle;
	wire [1:0] fx4_thread_idx;
	wire [141:0] fx5_instruction;
	wire fx5_instruction_valid;
	wire [15:0] fx5_mask_value;
	wire [511:0] fx5_result;
	wire [3:0] fx5_subcycle;
	wire [1:0] fx5_thread_idx;
	wire [141:0] id_instruction;
	wire id_instruction_valid;
	wire [1:0] id_thread_idx;
	wire ifd_alignment_fault;
	wire ifd_cache_miss;
	wire [25:0] ifd_cache_miss_paddr;
	wire [1:0] ifd_cache_miss_thread_idx;
	wire ifd_executable_fault;
	wire ifd_inst_injected;
	wire [31:0] ifd_instruction;
	wire ifd_instruction_valid;
	wire ifd_near_miss;
	wire ifd_page_fault;
	wire [31:0] ifd_pc;
	wire ifd_perf_icache_hit;
	wire ifd_perf_icache_miss;
	wire ifd_perf_itlb_miss;
	wire ifd_supervisor_fault;
	wire [1:0] ifd_thread_idx;
	wire ifd_tlb_miss;
	wire ifd_update_lru_en;
	wire [1:0] ifd_update_lru_way;
	wire [1:0] ift_fill_lru;
	wire ift_instruction_requested;
	localparam defines_ICACHE_TAG_BITS = 20;
	wire [31:0] ift_pc_paddr;
	wire [31:0] ift_pc_vaddr;
	wire [79:0] ift_tag;
	wire [1:0] ift_thread_idx;
	wire ift_tlb_executable;
	wire ift_tlb_hit;
	wire ift_tlb_present;
	wire ift_tlb_supervisor;
	wire [0:3] ift_valid;
	wire [3:0] ior_pending;
	wire [31:0] ior_read_value;
	wire ior_rollback_en;
	wire [3:0] ior_wake_bitmap;
	wire [141:0] ix_instruction;
	wire ix_instruction_valid;
	wire [15:0] ix_mask_value;
	wire ix_perf_cond_branch_not_taken;
	wire ix_perf_cond_branch_taken;
	wire ix_perf_uncond_branch;
	wire ix_privileged_op_fault;
	wire [511:0] ix_result;
	wire ix_rollback_en;
	wire [31:0] ix_rollback_pc;
	wire [3:0] ix_subcycle;
	wire [1:0] ix_thread_idx;
	wire l2i_dcache_lru_fill_en;
	wire [5:0] l2i_dcache_lru_fill_set;
	wire [3:0] l2i_dcache_wake_bitmap;
	wire [511:0] l2i_ddata_update_data;
	wire l2i_ddata_update_en;
	wire [5:0] l2i_ddata_update_set;
	wire [1:0] l2i_ddata_update_way;
	wire [3:0] l2i_dtag_update_en_oh;
	wire [5:0] l2i_dtag_update_set;
	wire [19:0] l2i_dtag_update_tag;
	wire l2i_dtag_update_valid;
	wire l2i_icache_lru_fill_en;
	wire [5:0] l2i_icache_lru_fill_set;
	wire [3:0] l2i_icache_wake_bitmap;
	wire [511:0] l2i_idata_update_data;
	wire l2i_idata_update_en;
	wire [5:0] l2i_idata_update_set;
	wire [1:0] l2i_idata_update_way;
	wire [3:0] l2i_itag_update_en;
	wire [5:0] l2i_itag_update_set;
	wire [19:0] l2i_itag_update_tag;
	wire l2i_itag_update_valid;
	wire l2i_perf_store;
	wire l2i_snoop_en;
	wire [5:0] l2i_snoop_set;
	wire [141:0] of_instruction;
	wire of_instruction_valid;
	wire [15:0] of_mask_value;
	wire [511:0] of_operand1;
	wire [511:0] of_operand2;
	wire [511:0] of_store_value;
	wire [3:0] of_subcycle;
	wire [1:0] of_thread_idx;
	wire [127:0] perf_event_count;
	wire sq_rollback_en;
	wire [511:0] sq_store_bypass_data;
	wire [63:0] sq_store_bypass_mask;
	wire [3:0] sq_store_sync_pending;
	wire sq_store_sync_success;
	wire [3:0] ts_fetch_en;
	wire [141:0] ts_instruction;
	wire ts_instruction_valid;
	wire ts_perf_instruction_issue;
	wire [3:0] ts_subcycle;
	wire [1:0] ts_thread_idx;
	wire wb_eret;
	wire wb_inst_injected;
	wire wb_perf_instruction_retire;
	wire wb_perf_interrupt;
	wire wb_perf_store_rollback;
	wire wb_rollback_en;
	wire [31:0] wb_rollback_pc;
	wire [1:0] wb_rollback_pipeline;
	wire [3:0] wb_rollback_subcycle;
	wire [1:0] wb_rollback_thread_idx;
	wire [3:0] wb_suspend_thread_oh;
	wire [14:0] wb_syscall_index;
	wire wb_trap;
	wire [31:0] wb_trap_access_vaddr;
	wire [5:0] wb_trap_cause;
	wire [31:0] wb_trap_pc;
	wire [3:0] wb_trap_subcycle;
	wire wb_writeback_en;
	wire wb_writeback_last_subcycle;
	wire [15:0] wb_writeback_mask;
	wire [4:0] wb_writeback_reg;
	wire [1:0] wb_writeback_thread_idx;
	wire [511:0] wb_writeback_value;
	wire wb_writeback_vector;
	ifetch_tag_stage #(.RESET_PC(RESET_PC)) ifetch_tag_stage(
		.clk(clk),
		.reset(reset),
		.ifd_update_lru_en(ifd_update_lru_en),
		.ifd_update_lru_way(ifd_update_lru_way),
		.ifd_cache_miss(ifd_cache_miss),
		.ifd_near_miss(ifd_near_miss),
		.ifd_cache_miss_thread_idx(ifd_cache_miss_thread_idx),
		.ift_instruction_requested(ift_instruction_requested),
		.ift_pc_paddr(ift_pc_paddr),
		.ift_pc_vaddr(ift_pc_vaddr),
		.ift_thread_idx(ift_thread_idx),
		.ift_tlb_hit(ift_tlb_hit),
		.ift_tlb_present(ift_tlb_present),
		.ift_tlb_executable(ift_tlb_executable),
		.ift_tlb_supervisor(ift_tlb_supervisor),
		.ift_tag(ift_tag),
		.ift_valid(ift_valid),
		.l2i_icache_lru_fill_en(l2i_icache_lru_fill_en),
		.l2i_icache_lru_fill_set(l2i_icache_lru_fill_set),
		.l2i_itag_update_en(l2i_itag_update_en),
		.l2i_itag_update_set(l2i_itag_update_set),
		.l2i_itag_update_tag(l2i_itag_update_tag),
		.l2i_itag_update_valid(l2i_itag_update_valid),
		.l2i_icache_wake_bitmap(l2i_icache_wake_bitmap),
		.ift_fill_lru(ift_fill_lru),
		.cr_mmu_en(cr_mmu_en),
		.cr_current_asid(cr_current_asid),
		.dt_invalidate_tlb_en(dt_invalidate_tlb_en),
		.dt_invalidate_tlb_all_en(dt_invalidate_tlb_all_en),
		.dt_update_itlb_asid(dt_update_itlb_asid),
		.dt_update_itlb_vpage_idx(dt_update_itlb_vpage_idx),
		.dt_update_itlb_en(dt_update_itlb_en),
		.dt_update_itlb_supervisor(dt_update_itlb_supervisor),
		.dt_update_itlb_global(dt_update_itlb_global),
		.dt_update_itlb_present(dt_update_itlb_present),
		.dt_update_itlb_executable(dt_update_itlb_executable),
		.dt_update_itlb_ppage_idx(dt_update_itlb_ppage_idx),
		.wb_rollback_en(wb_rollback_en),
		.wb_rollback_thread_idx(wb_rollback_thread_idx),
		.wb_rollback_pc(wb_rollback_pc),
		.ts_fetch_en(ts_fetch_en),
		.ocd_halt(ocd_halt),
		.ocd_thread(ocd_thread)
	);
	ifetch_data_stage ifetch_data_stage(
		.clk(clk),
		.reset(reset),
		.ift_instruction_requested(ift_instruction_requested),
		.ift_pc_paddr(ift_pc_paddr),
		.ift_pc_vaddr(ift_pc_vaddr),
		.ift_thread_idx(ift_thread_idx),
		.ift_tlb_hit(ift_tlb_hit),
		.ift_tlb_present(ift_tlb_present),
		.ift_tlb_executable(ift_tlb_executable),
		.ift_tlb_supervisor(ift_tlb_supervisor),
		.ift_tag(ift_tag),
		.ift_valid(ift_valid),
		.ifd_update_lru_en(ifd_update_lru_en),
		.ifd_update_lru_way(ifd_update_lru_way),
		.ifd_near_miss(ifd_near_miss),
		.l2i_idata_update_en(l2i_idata_update_en),
		.l2i_idata_update_way(l2i_idata_update_way),
		.l2i_idata_update_set(l2i_idata_update_set),
		.l2i_idata_update_data(l2i_idata_update_data),
		.l2i_itag_update_en(l2i_itag_update_en),
		.l2i_itag_update_set(l2i_itag_update_set),
		.l2i_itag_update_tag(l2i_itag_update_tag),
		.ifd_cache_miss(ifd_cache_miss),
		.ifd_cache_miss_paddr(ifd_cache_miss_paddr),
		.ifd_cache_miss_thread_idx(ifd_cache_miss_thread_idx),
		.cr_supervisor_en(cr_supervisor_en),
		.ifd_instruction(ifd_instruction),
		.ifd_instruction_valid(ifd_instruction_valid),
		.ifd_pc(ifd_pc),
		.ifd_thread_idx(ifd_thread_idx),
		.ifd_alignment_fault(ifd_alignment_fault),
		.ifd_tlb_miss(ifd_tlb_miss),
		.ifd_supervisor_fault(ifd_supervisor_fault),
		.ifd_page_fault(ifd_page_fault),
		.ifd_executable_fault(ifd_executable_fault),
		.ifd_inst_injected(ifd_inst_injected),
		.wb_rollback_en(wb_rollback_en),
		.wb_rollback_thread_idx(wb_rollback_thread_idx),
		.ifd_perf_icache_hit(ifd_perf_icache_hit),
		.ifd_perf_icache_miss(ifd_perf_icache_miss),
		.ifd_perf_itlb_miss(ifd_perf_itlb_miss),
		.core_selected_debug(core_selected_debug),
		.ocd_halt(ocd_halt),
		.ocd_inject_inst(ocd_inject_inst),
		.ocd_inject_en(ocd_inject_en),
		.ocd_thread(ocd_thread)
	);
	instruction_decode_stage instruction_decode_stage(
		.clk(clk),
		.reset(reset),
		.ifd_instruction_valid(ifd_instruction_valid),
		.ifd_instruction(ifd_instruction),
		.ifd_inst_injected(ifd_inst_injected),
		.ifd_pc(ifd_pc),
		.ifd_thread_idx(ifd_thread_idx),
		.ifd_alignment_fault(ifd_alignment_fault),
		.ifd_supervisor_fault(ifd_supervisor_fault),
		.ifd_page_fault(ifd_page_fault),
		.ifd_executable_fault(ifd_executable_fault),
		.ifd_tlb_miss(ifd_tlb_miss),
		.dd_load_sync_pending(dd_load_sync_pending),
		.sq_store_sync_pending(sq_store_sync_pending),
		.id_instruction(id_instruction),
		.id_instruction_valid(id_instruction_valid),
		.id_thread_idx(id_thread_idx),
		.ior_pending(ior_pending),
		.cr_interrupt_en(cr_interrupt_en),
		.cr_interrupt_pending(cr_interrupt_pending),
		.ocd_halt(ocd_halt),
		.wb_rollback_en(wb_rollback_en),
		.wb_rollback_thread_idx(wb_rollback_thread_idx)
	);
	thread_select_stage thread_select_stage(
		.clk(clk),
		.reset(reset),
		.id_instruction(id_instruction),
		.id_instruction_valid(id_instruction_valid),
		.id_thread_idx(id_thread_idx),
		.ts_fetch_en(ts_fetch_en),
		.ts_instruction_valid(ts_instruction_valid),
		.ts_instruction(ts_instruction),
		.ts_thread_idx(ts_thread_idx),
		.ts_subcycle(ts_subcycle),
		.wb_writeback_en(wb_writeback_en),
		.wb_writeback_thread_idx(wb_writeback_thread_idx),
		.wb_writeback_vector(wb_writeback_vector),
		.wb_writeback_reg(wb_writeback_reg),
		.wb_writeback_last_subcycle(wb_writeback_last_subcycle),
		.wb_rollback_thread_idx(wb_rollback_thread_idx),
		.wb_rollback_en(wb_rollback_en),
		.wb_rollback_pipeline(wb_rollback_pipeline),
		.wb_rollback_subcycle(wb_rollback_subcycle),
		.thread_en(thread_en),
		.wb_suspend_thread_oh(wb_suspend_thread_oh),
		.l2i_dcache_wake_bitmap(l2i_dcache_wake_bitmap),
		.ior_wake_bitmap(ior_wake_bitmap),
		.ts_perf_instruction_issue(ts_perf_instruction_issue)
	);
	operand_fetch_stage operand_fetch_stage(
		.clk(clk),
		.reset(reset),
		.ts_instruction_valid(ts_instruction_valid),
		.ts_instruction(ts_instruction),
		.ts_thread_idx(ts_thread_idx),
		.ts_subcycle(ts_subcycle),
		.of_operand1(of_operand1),
		.of_operand2(of_operand2),
		.of_mask_value(of_mask_value),
		.of_store_value(of_store_value),
		.of_instruction(of_instruction),
		.of_instruction_valid(of_instruction_valid),
		.of_thread_idx(of_thread_idx),
		.of_subcycle(of_subcycle),
		.wb_rollback_en(wb_rollback_en),
		.wb_rollback_thread_idx(wb_rollback_thread_idx),
		.wb_writeback_en(wb_writeback_en),
		.wb_writeback_thread_idx(wb_writeback_thread_idx),
		.wb_writeback_vector(wb_writeback_vector),
		.wb_writeback_value(wb_writeback_value),
		.wb_writeback_mask(wb_writeback_mask),
		.wb_writeback_reg(wb_writeback_reg)
	);
	dcache_data_stage dcache_data_stage(
		.clk(clk),
		.reset(reset),
		.dd_load_sync_pending(dd_load_sync_pending),
		.dt_instruction_valid(dt_instruction_valid),
		.dt_instruction(dt_instruction),
		.dt_mask_value(dt_mask_value),
		.dt_thread_idx(dt_thread_idx),
		.dt_request_vaddr(dt_request_vaddr),
		.dt_request_paddr(dt_request_paddr),
		.dt_tlb_hit(dt_tlb_hit),
		.dt_tlb_present(dt_tlb_present),
		.dt_tlb_supervisor(dt_tlb_supervisor),
		.dt_tlb_writable(dt_tlb_writable),
		.dt_store_value(dt_store_value),
		.dt_subcycle(dt_subcycle),
		.dt_valid(dt_valid),
		.dt_tag(dt_tag),
		.dd_update_lru_en(dd_update_lru_en),
		.dd_update_lru_way(dd_update_lru_way),
		.dd_io_write_en(dd_io_write_en),
		.dd_io_read_en(dd_io_read_en),
		.dd_io_thread_idx(dd_io_thread_idx),
		.dd_io_addr(dd_io_addr),
		.dd_io_write_value(dd_io_write_value),
		.dd_instruction_valid(dd_instruction_valid),
		.dd_instruction(dd_instruction),
		.dd_lane_mask(dd_lane_mask),
		.dd_thread_idx(dd_thread_idx),
		.dd_request_vaddr(dd_request_vaddr),
		.dd_subcycle(dd_subcycle),
		.dd_rollback_en(dd_rollback_en),
		.dd_rollback_pc(dd_rollback_pc),
		.dd_load_data(dd_load_data),
		.dd_suspend_thread(dd_suspend_thread),
		.dd_io_access(dd_io_access),
		.dd_trap(dd_trap),
		.dd_trap_cause(dd_trap_cause),
		.cr_supervisor_en(cr_supervisor_en),
		.dd_creg_write_en(dd_creg_write_en),
		.dd_creg_read_en(dd_creg_read_en),
		.dd_creg_index(dd_creg_index),
		.dd_creg_write_val(dd_creg_write_val),
		.l2i_ddata_update_en(l2i_ddata_update_en),
		.l2i_ddata_update_way(l2i_ddata_update_way),
		.l2i_ddata_update_set(l2i_ddata_update_set),
		.l2i_ddata_update_data(l2i_ddata_update_data),
		.l2i_dtag_update_en_oh(l2i_dtag_update_en_oh),
		.l2i_dtag_update_set(l2i_dtag_update_set),
		.l2i_dtag_update_tag(l2i_dtag_update_tag),
		.dd_cache_miss(dd_cache_miss),
		.dd_cache_miss_addr(dd_cache_miss_addr),
		.dd_cache_miss_thread_idx(dd_cache_miss_thread_idx),
		.dd_cache_miss_sync(dd_cache_miss_sync),
		.dd_store_en(dd_store_en),
		.dd_flush_en(dd_flush_en),
		.dd_membar_en(dd_membar_en),
		.dd_iinvalidate_en(dd_iinvalidate_en),
		.dd_dinvalidate_en(dd_dinvalidate_en),
		.dd_store_mask(dd_store_mask),
		.dd_store_addr(dd_store_addr),
		.dd_store_data(dd_store_data),
		.dd_store_thread_idx(dd_store_thread_idx),
		.dd_store_sync(dd_store_sync),
		.dd_store_bypass_addr(dd_store_bypass_addr),
		.dd_store_bypass_thread_idx(dd_store_bypass_thread_idx),
		.wb_rollback_en(wb_rollback_en),
		.wb_rollback_thread_idx(wb_rollback_thread_idx),
		.wb_rollback_pipeline(wb_rollback_pipeline),
		.dd_perf_dcache_hit(dd_perf_dcache_hit),
		.dd_perf_dcache_miss(dd_perf_dcache_miss),
		.dd_perf_dtlb_miss(dd_perf_dtlb_miss)
	);
	dcache_tag_stage dcache_tag_stage(
		.clk(clk),
		.reset(reset),
		.of_operand1(of_operand1),
		.of_mask_value(of_mask_value),
		.of_store_value(of_store_value),
		.of_instruction_valid(of_instruction_valid),
		.of_instruction(of_instruction),
		.of_thread_idx(of_thread_idx),
		.of_subcycle(of_subcycle),
		.dd_update_lru_en(dd_update_lru_en),
		.dd_update_lru_way(dd_update_lru_way),
		.dt_instruction_valid(dt_instruction_valid),
		.dt_instruction(dt_instruction),
		.dt_mask_value(dt_mask_value),
		.dt_thread_idx(dt_thread_idx),
		.dt_request_vaddr(dt_request_vaddr),
		.dt_request_paddr(dt_request_paddr),
		.dt_tlb_hit(dt_tlb_hit),
		.dt_tlb_writable(dt_tlb_writable),
		.dt_store_value(dt_store_value),
		.dt_subcycle(dt_subcycle),
		.dt_valid(dt_valid),
		.dt_tag(dt_tag),
		.dt_tlb_supervisor(dt_tlb_supervisor),
		.dt_tlb_present(dt_tlb_present),
		.dt_invalidate_tlb_en(dt_invalidate_tlb_en),
		.dt_invalidate_tlb_all_en(dt_invalidate_tlb_all_en),
		.dt_update_itlb_en(dt_update_itlb_en),
		.dt_update_itlb_asid(dt_update_itlb_asid),
		.dt_update_itlb_vpage_idx(dt_update_itlb_vpage_idx),
		.dt_update_itlb_ppage_idx(dt_update_itlb_ppage_idx),
		.dt_update_itlb_present(dt_update_itlb_present),
		.dt_update_itlb_supervisor(dt_update_itlb_supervisor),
		.dt_update_itlb_global(dt_update_itlb_global),
		.dt_update_itlb_executable(dt_update_itlb_executable),
		.l2i_dcache_lru_fill_en(l2i_dcache_lru_fill_en),
		.l2i_dcache_lru_fill_set(l2i_dcache_lru_fill_set),
		.l2i_dtag_update_en_oh(l2i_dtag_update_en_oh),
		.l2i_dtag_update_set(l2i_dtag_update_set),
		.l2i_dtag_update_tag(l2i_dtag_update_tag),
		.l2i_dtag_update_valid(l2i_dtag_update_valid),
		.l2i_snoop_en(l2i_snoop_en),
		.l2i_snoop_set(l2i_snoop_set),
		.dt_snoop_valid(dt_snoop_valid),
		.dt_snoop_tag(dt_snoop_tag),
		.dt_fill_lru(dt_fill_lru),
		.cr_mmu_en(cr_mmu_en),
		.cr_supervisor_en(cr_supervisor_en),
		.cr_current_asid(cr_current_asid),
		.wb_rollback_en(wb_rollback_en),
		.wb_rollback_thread_idx(wb_rollback_thread_idx)
	);
	int_execute_stage int_execute_stage(
		.clk(clk),
		.reset(reset),
		.of_operand1(of_operand1),
		.of_operand2(of_operand2),
		.of_mask_value(of_mask_value),
		.of_instruction_valid(of_instruction_valid),
		.of_instruction(of_instruction),
		.of_thread_idx(of_thread_idx),
		.of_subcycle(of_subcycle),
		.wb_rollback_en(wb_rollback_en),
		.wb_rollback_thread_idx(wb_rollback_thread_idx),
		.ix_instruction_valid(ix_instruction_valid),
		.ix_instruction(ix_instruction),
		.ix_result(ix_result),
		.ix_mask_value(ix_mask_value),
		.ix_thread_idx(ix_thread_idx),
		.ix_rollback_en(ix_rollback_en),
		.ix_rollback_pc(ix_rollback_pc),
		.ix_subcycle(ix_subcycle),
		.ix_privileged_op_fault(ix_privileged_op_fault),
		.cr_eret_address(cr_eret_address),
		.cr_supervisor_en(cr_supervisor_en),
		.ix_perf_uncond_branch(ix_perf_uncond_branch),
		.ix_perf_cond_branch_taken(ix_perf_cond_branch_taken),
		.ix_perf_cond_branch_not_taken(ix_perf_cond_branch_not_taken)
	);
	fp_execute_stage1 fp_execute_stage1(
		.clk(clk),
		.reset(reset),
		.wb_rollback_en(wb_rollback_en),
		.wb_rollback_thread_idx(wb_rollback_thread_idx),
		.of_operand1(of_operand1),
		.of_operand2(of_operand2),
		.of_mask_value(of_mask_value),
		.of_instruction_valid(of_instruction_valid),
		.of_instruction(of_instruction),
		.of_thread_idx(of_thread_idx),
		.of_subcycle(of_subcycle),
		.fx1_instruction_valid(fx1_instruction_valid),
		.fx1_instruction(fx1_instruction),
		.fx1_mask_value(fx1_mask_value),
		.fx1_thread_idx(fx1_thread_idx),
		.fx1_subcycle(fx1_subcycle),
		.fx1_result_inf(fx1_result_inf),
		.fx1_result_nan(fx1_result_nan),
		.fx1_equal(fx1_equal),
		.fx1_ftoi_lshift(fx1_ftoi_lshift),
		.fx1_significand_le(fx1_significand_le),
		.fx1_significand_se(fx1_significand_se),
		.fx1_se_align_shift(fx1_se_align_shift),
		.fx1_add_exponent(fx1_add_exponent),
		.fx1_logical_subtract(fx1_logical_subtract),
		.fx1_add_result_sign(fx1_add_result_sign),
		.fx1_multiplicand(fx1_multiplicand),
		.fx1_multiplier(fx1_multiplier),
		.fx1_mul_exponent(fx1_mul_exponent),
		.fx1_mul_underflow(fx1_mul_underflow),
		.fx1_mul_sign(fx1_mul_sign)
	);
	fp_execute_stage2 fp_execute_stage2(
		.clk(clk),
		.reset(reset),
		.wb_rollback_en(wb_rollback_en),
		.wb_rollback_thread_idx(wb_rollback_thread_idx),
		.wb_rollback_pipeline(wb_rollback_pipeline),
		.fx1_mask_value(fx1_mask_value),
		.fx1_instruction_valid(fx1_instruction_valid),
		.fx1_instruction(fx1_instruction),
		.fx1_thread_idx(fx1_thread_idx),
		.fx1_subcycle(fx1_subcycle),
		.fx1_result_inf(fx1_result_inf),
		.fx1_result_nan(fx1_result_nan),
		.fx1_equal(fx1_equal),
		.fx1_ftoi_lshift(fx1_ftoi_lshift),
		.fx1_significand_le(fx1_significand_le),
		.fx1_significand_se(fx1_significand_se),
		.fx1_logical_subtract(fx1_logical_subtract),
		.fx1_se_align_shift(fx1_se_align_shift),
		.fx1_add_exponent(fx1_add_exponent),
		.fx1_add_result_sign(fx1_add_result_sign),
		.fx1_mul_exponent(fx1_mul_exponent),
		.fx1_mul_sign(fx1_mul_sign),
		.fx1_multiplicand(fx1_multiplicand),
		.fx1_multiplier(fx1_multiplier),
		.fx1_mul_underflow(fx1_mul_underflow),
		.fx2_instruction_valid(fx2_instruction_valid),
		.fx2_instruction(fx2_instruction),
		.fx2_mask_value(fx2_mask_value),
		.fx2_thread_idx(fx2_thread_idx),
		.fx2_subcycle(fx2_subcycle),
		.fx2_result_inf(fx2_result_inf),
		.fx2_result_nan(fx2_result_nan),
		.fx2_equal(fx2_equal),
		.fx2_ftoi_lshift(fx2_ftoi_lshift),
		.fx2_logical_subtract(fx2_logical_subtract),
		.fx2_add_result_sign(fx2_add_result_sign),
		.fx2_significand_le(fx2_significand_le),
		.fx2_significand_se(fx2_significand_se),
		.fx2_add_exponent(fx2_add_exponent),
		.fx2_guard(fx2_guard),
		.fx2_round(fx2_round),
		.fx2_sticky(fx2_sticky),
		.fx2_significand_product(fx2_significand_product),
		.fx2_mul_exponent(fx2_mul_exponent),
		.fx2_mul_underflow(fx2_mul_underflow),
		.fx2_mul_sign(fx2_mul_sign)
	);
	fp_execute_stage3 fp_execute_stage3(
		.clk(clk),
		.reset(reset),
		.fx2_mask_value(fx2_mask_value),
		.fx2_instruction_valid(fx2_instruction_valid),
		.fx2_instruction(fx2_instruction),
		.fx2_thread_idx(fx2_thread_idx),
		.fx2_subcycle(fx2_subcycle),
		.fx2_result_inf(fx2_result_inf),
		.fx2_result_nan(fx2_result_nan),
		.fx2_equal(fx2_equal),
		.fx2_ftoi_lshift(fx2_ftoi_lshift),
		.fx2_significand_le(fx2_significand_le),
		.fx2_significand_se(fx2_significand_se),
		.fx2_logical_subtract(fx2_logical_subtract),
		.fx2_add_exponent(fx2_add_exponent),
		.fx2_add_result_sign(fx2_add_result_sign),
		.fx2_guard(fx2_guard),
		.fx2_round(fx2_round),
		.fx2_sticky(fx2_sticky),
		.fx2_significand_product(fx2_significand_product),
		.fx2_mul_exponent(fx2_mul_exponent),
		.fx2_mul_underflow(fx2_mul_underflow),
		.fx2_mul_sign(fx2_mul_sign),
		.fx3_instruction_valid(fx3_instruction_valid),
		.fx3_instruction(fx3_instruction),
		.fx3_mask_value(fx3_mask_value),
		.fx3_thread_idx(fx3_thread_idx),
		.fx3_subcycle(fx3_subcycle),
		.fx3_result_inf(fx3_result_inf),
		.fx3_result_nan(fx3_result_nan),
		.fx3_equal(fx3_equal),
		.fx3_ftoi_lshift(fx3_ftoi_lshift),
		.fx3_add_significand(fx3_add_significand),
		.fx3_add_exponent(fx3_add_exponent),
		.fx3_add_result_sign(fx3_add_result_sign),
		.fx3_logical_subtract(fx3_logical_subtract),
		.fx3_significand_product(fx3_significand_product),
		.fx3_mul_exponent(fx3_mul_exponent),
		.fx3_mul_underflow(fx3_mul_underflow),
		.fx3_mul_sign(fx3_mul_sign)
	);
	fp_execute_stage4 fp_execute_stage4(
		.clk(clk),
		.reset(reset),
		.fx3_mask_value(fx3_mask_value),
		.fx3_instruction_valid(fx3_instruction_valid),
		.fx3_instruction(fx3_instruction),
		.fx3_thread_idx(fx3_thread_idx),
		.fx3_subcycle(fx3_subcycle),
		.fx3_result_inf(fx3_result_inf),
		.fx3_result_nan(fx3_result_nan),
		.fx3_equal(fx3_equal),
		.fx3_ftoi_lshift(fx3_ftoi_lshift),
		.fx3_add_significand(fx3_add_significand),
		.fx3_add_exponent(fx3_add_exponent),
		.fx3_add_result_sign(fx3_add_result_sign),
		.fx3_logical_subtract(fx3_logical_subtract),
		.fx3_significand_product(fx3_significand_product),
		.fx3_mul_exponent(fx3_mul_exponent),
		.fx3_mul_underflow(fx3_mul_underflow),
		.fx3_mul_sign(fx3_mul_sign),
		.fx4_instruction_valid(fx4_instruction_valid),
		.fx4_instruction(fx4_instruction),
		.fx4_mask_value(fx4_mask_value),
		.fx4_thread_idx(fx4_thread_idx),
		.fx4_subcycle(fx4_subcycle),
		.fx4_result_inf(fx4_result_inf),
		.fx4_result_nan(fx4_result_nan),
		.fx4_equal(fx4_equal),
		.fx4_add_exponent(fx4_add_exponent),
		.fx4_add_significand(fx4_add_significand),
		.fx4_add_result_sign(fx4_add_result_sign),
		.fx4_logical_subtract(fx4_logical_subtract),
		.fx4_norm_shift(fx4_norm_shift),
		.fx4_significand_product(fx4_significand_product),
		.fx4_mul_exponent(fx4_mul_exponent),
		.fx4_mul_underflow(fx4_mul_underflow),
		.fx4_mul_sign(fx4_mul_sign)
	);
	fp_execute_stage5 fp_execute_stage5(
		.clk(clk),
		.reset(reset),
		.fx4_mask_value(fx4_mask_value),
		.fx4_instruction_valid(fx4_instruction_valid),
		.fx4_instruction(fx4_instruction),
		.fx4_thread_idx(fx4_thread_idx),
		.fx4_subcycle(fx4_subcycle),
		.fx4_result_inf(fx4_result_inf),
		.fx4_result_nan(fx4_result_nan),
		.fx4_equal(fx4_equal),
		.fx4_add_exponent(fx4_add_exponent),
		.fx4_add_significand(fx4_add_significand),
		.fx4_add_result_sign(fx4_add_result_sign),
		.fx4_logical_subtract(fx4_logical_subtract),
		.fx4_norm_shift(fx4_norm_shift),
		.fx4_significand_product(fx4_significand_product),
		.fx4_mul_exponent(fx4_mul_exponent),
		.fx4_mul_underflow(fx4_mul_underflow),
		.fx4_mul_sign(fx4_mul_sign),
		.fx5_instruction_valid(fx5_instruction_valid),
		.fx5_instruction(fx5_instruction),
		.fx5_mask_value(fx5_mask_value),
		.fx5_thread_idx(fx5_thread_idx),
		.fx5_subcycle(fx5_subcycle),
		.fx5_result(fx5_result)
	);
	writeback_stage writeback_stage(
		.clk(clk),
		.reset(reset),
		.fx5_instruction_valid(fx5_instruction_valid),
		.fx5_instruction(fx5_instruction),
		.fx5_result(fx5_result),
		.fx5_mask_value(fx5_mask_value),
		.fx5_thread_idx(fx5_thread_idx),
		.fx5_subcycle(fx5_subcycle),
		.ix_instruction_valid(ix_instruction_valid),
		.ix_instruction(ix_instruction),
		.ix_result(ix_result),
		.ix_thread_idx(ix_thread_idx),
		.ix_mask_value(ix_mask_value),
		.ix_rollback_en(ix_rollback_en),
		.ix_rollback_pc(ix_rollback_pc),
		.ix_subcycle(ix_subcycle),
		.ix_privileged_op_fault(ix_privileged_op_fault),
		.dd_instruction_valid(dd_instruction_valid),
		.dd_instruction(dd_instruction),
		.dd_lane_mask(dd_lane_mask),
		.dd_thread_idx(dd_thread_idx),
		.dd_request_vaddr(dd_request_vaddr),
		.dd_subcycle(dd_subcycle),
		.dd_rollback_en(dd_rollback_en),
		.dd_rollback_pc(dd_rollback_pc),
		.dd_load_data(dd_load_data),
		.dd_suspend_thread(dd_suspend_thread),
		.dd_io_access(dd_io_access),
		.dd_trap(dd_trap),
		.dd_trap_cause(dd_trap_cause),
		.sq_store_bypass_mask(sq_store_bypass_mask),
		.sq_store_bypass_data(sq_store_bypass_data),
		.sq_store_sync_success(sq_store_sync_success),
		.sq_rollback_en(sq_rollback_en),
		.ior_read_value(ior_read_value),
		.ior_rollback_en(ior_rollback_en),
		.cr_creg_read_val(cr_creg_read_val),
		.cr_trap_handler(cr_trap_handler),
		.cr_tlb_miss_handler(cr_tlb_miss_handler),
		.cr_eret_subcycle(cr_eret_subcycle),
		.wb_trap(wb_trap),
		.wb_trap_cause(wb_trap_cause),
		.wb_trap_pc(wb_trap_pc),
		.wb_trap_access_vaddr(wb_trap_access_vaddr),
		.wb_trap_subcycle(wb_trap_subcycle),
		.wb_syscall_index(wb_syscall_index),
		.wb_eret(wb_eret),
		.wb_rollback_en(wb_rollback_en),
		.wb_rollback_thread_idx(wb_rollback_thread_idx),
		.wb_rollback_pc(wb_rollback_pc),
		.wb_rollback_pipeline(wb_rollback_pipeline),
		.wb_rollback_subcycle(wb_rollback_subcycle),
		.wb_writeback_en(wb_writeback_en),
		.wb_writeback_thread_idx(wb_writeback_thread_idx),
		.wb_writeback_vector(wb_writeback_vector),
		.wb_writeback_value(wb_writeback_value),
		.wb_writeback_mask(wb_writeback_mask),
		.wb_writeback_reg(wb_writeback_reg),
		.wb_writeback_last_subcycle(wb_writeback_last_subcycle),
		.wb_suspend_thread_oh(wb_suspend_thread_oh),
		.wb_inst_injected(wb_inst_injected),
		.wb_perf_instruction_retire(wb_perf_instruction_retire),
		.wb_perf_store_rollback(wb_perf_store_rollback),
		.wb_perf_interrupt(wb_perf_interrupt)
	);
	control_registers #(
		.CORE_ID(CORE_ID),
		.NUM_INTERRUPTS(NUM_INTERRUPTS),
		.NUM_PERF_EVENTS(defines_CORE_PERF_EVENTS)
	) control_registers(
		.cr_perf_event_select0(perf_event_select[0+:4]),
		.cr_perf_event_select1(perf_event_select[4+:4]),
		.perf_event_count0(perf_event_count[0+:64]),
		.perf_event_count1(perf_event_count[64+:64]),
		.clk(clk),
		.reset(reset),
		.interrupt_req(interrupt_req),
		.cr_eret_address(cr_eret_address),
		.cr_mmu_en(cr_mmu_en),
		.cr_supervisor_en(cr_supervisor_en),
		.cr_current_asid(cr_current_asid),
		.cr_suspend_thread(cr_suspend_thread),
		.cr_resume_thread(cr_resume_thread),
		.cr_interrupt_pending(cr_interrupt_pending),
		.cr_interrupt_en(cr_interrupt_en),
		.dt_thread_idx(dt_thread_idx),
		.dd_creg_write_en(dd_creg_write_en),
		.dd_creg_read_en(dd_creg_read_en),
		.dd_creg_index(dd_creg_index),
		.dd_creg_write_val(dd_creg_write_val),
		.wb_trap(wb_trap),
		.wb_eret(wb_eret),
		.wb_trap_cause(wb_trap_cause),
		.wb_trap_pc(wb_trap_pc),
		.wb_trap_access_vaddr(wb_trap_access_vaddr),
		.wb_rollback_thread_idx(wb_rollback_thread_idx),
		.wb_trap_subcycle(wb_trap_subcycle),
		.wb_syscall_index(wb_syscall_index),
		.cr_creg_read_val(cr_creg_read_val),
		.cr_eret_subcycle(cr_eret_subcycle),
		.cr_trap_handler(cr_trap_handler),
		.cr_tlb_miss_handler(cr_tlb_miss_handler),
		.ocd_data_from_host(ocd_data_from_host),
		.ocd_data_update(ocd_data_update),
		.cr_data_to_host(cr_data_to_host)
	);
	l1_l2_interface #(.CORE_ID(CORE_ID)) l1_l2_interface(
		.clk(clk),
		.reset(reset),
		.l2_ready(l2_ready),
		.l2_response_valid(l2_response_valid),
		.l2_response(l2_response),
		.l2i_request_valid(l2i_request_valid),
		.l2i_request(l2i_request),
		.l2i_icache_lru_fill_en(l2i_icache_lru_fill_en),
		.l2i_icache_lru_fill_set(l2i_icache_lru_fill_set),
		.l2i_itag_update_en(l2i_itag_update_en),
		.l2i_itag_update_set(l2i_itag_update_set),
		.l2i_itag_update_tag(l2i_itag_update_tag),
		.l2i_itag_update_valid(l2i_itag_update_valid),
		.sq_store_sync_pending(sq_store_sync_pending),
		.ift_fill_lru(ift_fill_lru),
		.ifd_cache_miss(ifd_cache_miss),
		.ifd_cache_miss_paddr(ifd_cache_miss_paddr),
		.ifd_cache_miss_thread_idx(ifd_cache_miss_thread_idx),
		.l2i_idata_update_en(l2i_idata_update_en),
		.l2i_idata_update_way(l2i_idata_update_way),
		.l2i_idata_update_set(l2i_idata_update_set),
		.l2i_idata_update_data(l2i_idata_update_data),
		.l2i_dcache_wake_bitmap(l2i_dcache_wake_bitmap),
		.l2i_icache_wake_bitmap(l2i_icache_wake_bitmap),
		.dt_snoop_valid(dt_snoop_valid),
		.dt_snoop_tag(dt_snoop_tag),
		.dt_fill_lru(dt_fill_lru),
		.l2i_snoop_en(l2i_snoop_en),
		.l2i_snoop_set(l2i_snoop_set),
		.l2i_dtag_update_en_oh(l2i_dtag_update_en_oh),
		.l2i_dtag_update_set(l2i_dtag_update_set),
		.l2i_dtag_update_tag(l2i_dtag_update_tag),
		.l2i_dtag_update_valid(l2i_dtag_update_valid),
		.l2i_dcache_lru_fill_en(l2i_dcache_lru_fill_en),
		.l2i_dcache_lru_fill_set(l2i_dcache_lru_fill_set),
		.dd_cache_miss(dd_cache_miss),
		.dd_cache_miss_addr(dd_cache_miss_addr),
		.dd_cache_miss_thread_idx(dd_cache_miss_thread_idx),
		.dd_cache_miss_sync(dd_cache_miss_sync),
		.dd_store_en(dd_store_en),
		.dd_flush_en(dd_flush_en),
		.dd_membar_en(dd_membar_en),
		.dd_iinvalidate_en(dd_iinvalidate_en),
		.dd_dinvalidate_en(dd_dinvalidate_en),
		.dd_store_mask(dd_store_mask),
		.dd_store_addr(dd_store_addr),
		.dd_store_data(dd_store_data),
		.dd_store_thread_idx(dd_store_thread_idx),
		.dd_store_sync(dd_store_sync),
		.dd_store_bypass_addr(dd_store_bypass_addr),
		.dd_store_bypass_thread_idx(dd_store_bypass_thread_idx),
		.l2i_ddata_update_en(l2i_ddata_update_en),
		.l2i_ddata_update_way(l2i_ddata_update_way),
		.l2i_ddata_update_set(l2i_ddata_update_set),
		.l2i_ddata_update_data(l2i_ddata_update_data),
		.sq_store_bypass_mask(sq_store_bypass_mask),
		.sq_store_sync_success(sq_store_sync_success),
		.sq_store_bypass_data(sq_store_bypass_data),
		.sq_rollback_en(sq_rollback_en),
		.l2i_perf_store(l2i_perf_store)
	);
	io_request_queue #(.CORE_ID(CORE_ID)) io_request_queue(
		.clk(clk),
		.reset(reset),
		.dd_io_write_en(dd_io_write_en),
		.dd_io_read_en(dd_io_read_en),
		.dd_io_thread_idx(dd_io_thread_idx),
		.dd_io_addr(dd_io_addr),
		.dd_io_write_value(dd_io_write_value),
		.ior_read_value(ior_read_value),
		.ior_rollback_en(ior_rollback_en),
		.ior_pending(ior_pending),
		.ior_wake_bitmap(ior_wake_bitmap),
		.ii_ready(ii_ready),
		.ii_response_valid(ii_response_valid),
		.ii_response(ii_response),
		.ior_request_valid(ior_request_valid),
		.ior_request(ior_request)
	);
	assign core_selected_debug = CORE_ID == ocd_core;
	always @(posedge clk) begin
		injected_complete <= wb_inst_injected & !wb_rollback_en;
		injected_rollback <= wb_inst_injected & wb_rollback_en;
	end
	assign perf_events = {ix_perf_cond_branch_not_taken, ix_perf_cond_branch_taken, ix_perf_uncond_branch, dd_perf_dtlb_miss, dd_perf_dcache_hit, dd_perf_dcache_miss, ifd_perf_itlb_miss, ifd_perf_icache_hit, ifd_perf_icache_miss, ts_perf_instruction_issue, wb_perf_instruction_retire, l2i_perf_store, wb_perf_store_rollback, wb_perf_interrupt};
	performance_counters #(
		.NUM_EVENTS(defines_CORE_PERF_EVENTS),
		.NUM_COUNTERS(2)
	) performance_counters(
		.clk(clk),
		.reset(reset),
		.perf_events(perf_events),
		.perf_event_select(perf_event_select),
		.perf_event_count(perf_event_count)
	);
endmodule
module dcache_data_stage (
	clk,
	reset,
	dd_load_sync_pending,
	dt_instruction_valid,
	dt_instruction,
	dt_mask_value,
	dt_thread_idx,
	dt_request_vaddr,
	dt_request_paddr,
	dt_tlb_hit,
	dt_tlb_present,
	dt_tlb_supervisor,
	dt_tlb_writable,
	dt_store_value,
	dt_subcycle,
	dt_valid,
	dt_tag,
	dd_update_lru_en,
	dd_update_lru_way,
	dd_io_write_en,
	dd_io_read_en,
	dd_io_thread_idx,
	dd_io_addr,
	dd_io_write_value,
	dd_instruction_valid,
	dd_instruction,
	dd_lane_mask,
	dd_thread_idx,
	dd_request_vaddr,
	dd_subcycle,
	dd_rollback_en,
	dd_rollback_pc,
	dd_load_data,
	dd_suspend_thread,
	dd_io_access,
	dd_trap,
	dd_trap_cause,
	cr_supervisor_en,
	dd_creg_write_en,
	dd_creg_read_en,
	dd_creg_index,
	dd_creg_write_val,
	l2i_ddata_update_en,
	l2i_ddata_update_way,
	l2i_ddata_update_set,
	l2i_ddata_update_data,
	l2i_dtag_update_en_oh,
	l2i_dtag_update_set,
	l2i_dtag_update_tag,
	dd_cache_miss,
	dd_cache_miss_addr,
	dd_cache_miss_thread_idx,
	dd_cache_miss_sync,
	dd_store_en,
	dd_flush_en,
	dd_membar_en,
	dd_iinvalidate_en,
	dd_dinvalidate_en,
	dd_store_mask,
	dd_store_addr,
	dd_store_data,
	dd_store_thread_idx,
	dd_store_sync,
	dd_store_bypass_addr,
	dd_store_bypass_thread_idx,
	wb_rollback_en,
	wb_rollback_thread_idx,
	wb_rollback_pipeline,
	dd_perf_dcache_hit,
	dd_perf_dcache_miss,
	dd_perf_dtlb_miss
);
	reg _sv2v_0;
	input clk;
	input reset;
	output reg [3:0] dd_load_sync_pending;
	input dt_instruction_valid;
	localparam defines_NUM_VECTOR_LANES = 16;
	input wire [141:0] dt_instruction;
	input wire [15:0] dt_mask_value;
	input wire [1:0] dt_thread_idx;
	localparam defines_CACHE_LINE_BYTES = 64;
	localparam defines_CACHE_LINE_OFFSET_WIDTH = 6;
	localparam defines_DCACHE_TAG_BITS = 20;
	input wire [31:0] dt_request_vaddr;
	input wire [31:0] dt_request_paddr;
	input dt_tlb_hit;
	input dt_tlb_present;
	input dt_tlb_supervisor;
	input dt_tlb_writable;
	input wire [511:0] dt_store_value;
	input wire [3:0] dt_subcycle;
	input [0:3] dt_valid;
	input wire [79:0] dt_tag;
	output wire dd_update_lru_en;
	output wire [1:0] dd_update_lru_way;
	output wire dd_io_write_en;
	output wire dd_io_read_en;
	output wire [1:0] dd_io_thread_idx;
	output wire [31:0] dd_io_addr;
	output wire [31:0] dd_io_write_value;
	output reg dd_instruction_valid;
	output reg [141:0] dd_instruction;
	output reg [15:0] dd_lane_mask;
	output reg [1:0] dd_thread_idx;
	output reg [31:0] dd_request_vaddr;
	output reg [3:0] dd_subcycle;
	output reg dd_rollback_en;
	output reg [31:0] dd_rollback_pc;
	localparam defines_CACHE_LINE_BITS = 512;
	output wire [511:0] dd_load_data;
	output reg dd_suspend_thread;
	output reg dd_io_access;
	output reg dd_trap;
	output reg [5:0] dd_trap_cause;
	input wire [0:3] cr_supervisor_en;
	output wire dd_creg_write_en;
	output wire dd_creg_read_en;
	output wire [4:0] dd_creg_index;
	output wire [31:0] dd_creg_write_val;
	input l2i_ddata_update_en;
	input wire [1:0] l2i_ddata_update_way;
	input wire [5:0] l2i_ddata_update_set;
	input wire [511:0] l2i_ddata_update_data;
	input [3:0] l2i_dtag_update_en_oh;
	input wire [5:0] l2i_dtag_update_set;
	input wire [19:0] l2i_dtag_update_tag;
	output wire dd_cache_miss;
	output wire [25:0] dd_cache_miss_addr;
	output wire [1:0] dd_cache_miss_thread_idx;
	output wire dd_cache_miss_sync;
	output wire dd_store_en;
	output wire dd_flush_en;
	output wire dd_membar_en;
	output wire dd_iinvalidate_en;
	output wire dd_dinvalidate_en;
	output wire [63:0] dd_store_mask;
	output wire [25:0] dd_store_addr;
	output reg [511:0] dd_store_data;
	output wire [1:0] dd_store_thread_idx;
	output wire dd_store_sync;
	output wire [25:0] dd_store_bypass_addr;
	output wire [1:0] dd_store_bypass_thread_idx;
	input wire wb_rollback_en;
	input wire [1:0] wb_rollback_thread_idx;
	input wire [1:0] wb_rollback_pipeline;
	output reg dd_perf_dcache_hit;
	output reg dd_perf_dcache_miss;
	output reg dd_perf_dtlb_miss;
	wire memory_access_req;
	wire cached_access_req;
	wire cached_load_req;
	wire cached_store_req;
	wire creg_access_req;
	wire io_access_req;
	wire sync_access_req;
	wire cache_control_req;
	wire tlb_update_req;
	wire flush_req;
	wire iinvalidate_req;
	wire dinvalidate_req;
	wire membar_req;
	wire addr_in_io_region;
	reg unaligned_address;
	wire supervisor_fault;
	wire alignment_fault;
	wire privileged_op_fault;
	wire write_fault;
	wire tlb_miss;
	wire page_fault;
	wire any_fault;
	reg [15:0] word_store_mask;
	reg [3:0] byte_store_mask;
	localparam defines_CACHE_LINE_WORDS = 16;
	wire [3:0] cache_lane_idx;
	wire [511:0] endian_twiddled_data;
	wire [31:0] lane_store_value;
	wire [15:0] cache_lane_mask;
	wire [15:0] subcycle_mask;
	wire [3:0] way_hit_oh;
	wire [1:0] way_hit_idx;
	wire cache_hit;
	wire [31:0] dcache_request_addr;
	wire squash_instruction;
	wire cache_near_miss;
	wire [3:0] scgath_lane;
	reg tlb_read;
	wire fault_store_flag;
	wire lane_enabled;
	assign squash_instruction = (wb_rollback_en && (wb_rollback_thread_idx == dt_thread_idx)) && (wb_rollback_pipeline == 2'd0);
	assign scgath_lane = ~dt_subcycle;
	idx_to_oh #(
		.NUM_SIGNALS(defines_CACHE_LINE_WORDS),
		.DIRECTION("LSB0")
	) idx_to_oh_subcycle(
		.one_hot(subcycle_mask),
		.index(dt_subcycle)
	);
	assign lane_enabled = (!dt_instruction[19] || (dt_instruction[18-:4] != 4'b1110)) || ((dt_mask_value & subcycle_mask) != 0);
	assign addr_in_io_region = (dt_request_paddr | 32'h0000ffff) == 32'hffffffff;
	assign sync_access_req = dt_instruction[18-:4] == 4'b0101;
	assign memory_access_req = (((dt_instruction_valid && !squash_instruction) && dt_instruction[19]) && (dt_instruction[18-:4] != 4'b0110)) && lane_enabled;
	assign io_access_req = memory_access_req && addr_in_io_region;
	assign cached_access_req = memory_access_req && !addr_in_io_region;
	assign cached_load_req = cached_access_req && dt_instruction[14];
	assign cached_store_req = cached_access_req && !dt_instruction[14];
	assign cache_control_req = (dt_instruction_valid && !squash_instruction) && dt_instruction[3];
	assign flush_req = (cache_control_req && (dt_instruction[2-:3] == 3'b010)) && !addr_in_io_region;
	assign iinvalidate_req = (cache_control_req && (dt_instruction[2-:3] == 3'b011)) && !addr_in_io_region;
	assign dinvalidate_req = (cache_control_req && (dt_instruction[2-:3] == 3'b001)) && !addr_in_io_region;
	assign membar_req = cache_control_req && (dt_instruction[2-:3] == 3'b100);
	assign tlb_update_req = cache_control_req && ((((dt_instruction[2-:3] == 3'b000) || (dt_instruction[2-:3] == 3'b111)) || (dt_instruction[2-:3] == 3'b101)) || (dt_instruction[2-:3] == 3'b110));
	assign creg_access_req = ((dt_instruction_valid && !squash_instruction) && dt_instruction[19]) && (dt_instruction[18-:4] == 4'b0110);
	always @(*) begin
		if (_sv2v_0)
			;
		tlb_read = 0;
		if (dt_instruction_valid && !squash_instruction) begin
			if (dt_instruction[19])
				tlb_read = (dt_instruction[18-:4] != 4'b0110) && lane_enabled;
			else if (dt_instruction[3])
				tlb_read = (dt_instruction[2-:3] == 3'b010) || (dt_instruction[2-:3] == 3'b001);
		end
	end
	assign tlb_miss = tlb_read && !dt_tlb_hit;
	always @(*) begin
		if (_sv2v_0)
			;
		(* full_case, parallel_case *)
		case (dt_instruction[18-:4])
			4'b0010, 4'b0011: unaligned_address = dt_request_paddr[0];
			4'b0100, 4'b0101, 4'b1101, 4'b1110: unaligned_address = |dt_request_paddr[1:0];
			4'b0111, 4'b1000: unaligned_address = dt_request_paddr[5-:defines_CACHE_LINE_OFFSET_WIDTH] != 0;
			default: unaligned_address = 0;
		endcase
	end
	assign alignment_fault = (cached_access_req || io_access_req) && unaligned_address;
	assign privileged_op_fault = ((creg_access_req || tlb_update_req) || dinvalidate_req) && !cr_supervisor_en[dt_thread_idx];
	assign page_fault = (memory_access_req && dt_tlb_hit) && !dt_tlb_present;
	assign supervisor_fault = (((memory_access_req && dt_tlb_hit) && dt_tlb_present) && dt_tlb_supervisor) && !cr_supervisor_en[dt_thread_idx];
	assign write_fault = ((((cached_store_req || (io_access_req && !dt_instruction[14])) && dt_tlb_hit) && dt_tlb_present) && !supervisor_fault) && !dt_tlb_writable;
	assign any_fault = (((alignment_fault || privileged_op_fault) || page_fault) || supervisor_fault) || write_fault;
	assign dd_store_en = (cached_store_req && !tlb_miss) && !any_fault;
	assign dcache_request_addr = {dt_request_paddr[31:defines_CACHE_LINE_OFFSET_WIDTH], {defines_CACHE_LINE_OFFSET_WIDTH {1'b0}}};
	assign cache_lane_idx = dt_request_paddr[5:2];
	assign dd_store_bypass_addr = dt_request_paddr[31:defines_CACHE_LINE_OFFSET_WIDTH];
	assign dd_store_bypass_thread_idx = dt_thread_idx;
	assign dd_store_addr = dt_request_paddr[31:defines_CACHE_LINE_OFFSET_WIDTH];
	assign dd_store_sync = sync_access_req;
	assign dd_store_thread_idx = dt_thread_idx;
	assign dd_io_write_en = ((io_access_req && !dt_instruction[14]) && !tlb_miss) && !any_fault;
	assign dd_io_read_en = ((io_access_req && dt_instruction[14]) && !tlb_miss) && !any_fault;
	assign dd_io_write_value = dt_store_value[0+:32];
	assign dd_io_thread_idx = dt_thread_idx;
	assign dd_io_addr = {16'd0, dt_request_paddr[15:0]};
	assign dd_creg_write_en = (creg_access_req && !dt_instruction[14]) && !any_fault;
	assign dd_creg_read_en = (creg_access_req && dt_instruction[14]) && !any_fault;
	assign dd_creg_write_val = dt_store_value[0+:32];
	assign dd_creg_index = dt_instruction[8-:5];
	assign dd_flush_en = (((flush_req && dt_tlb_hit) && dt_tlb_present) && !io_access_req) && !any_fault;
	assign dd_iinvalidate_en = (((iinvalidate_req && dt_tlb_hit) && dt_tlb_present) && !io_access_req) && !any_fault;
	assign dd_dinvalidate_en = (((dinvalidate_req && dt_tlb_hit) && dt_tlb_present) && !io_access_req) && !any_fault;
	assign dd_membar_en = membar_req && (dt_instruction[2-:3] == 3'b100);
	genvar _gv_way_idx_1;
	generate
		for (_gv_way_idx_1 = 0; _gv_way_idx_1 < 4; _gv_way_idx_1 = _gv_way_idx_1 + 1) begin : hit_check_gen
			localparam way_idx = _gv_way_idx_1;
			assign way_hit_oh[way_idx] = (dt_request_paddr[31-:20] == dt_tag[(3 - way_idx) * defines_DCACHE_TAG_BITS+:defines_DCACHE_TAG_BITS]) && dt_valid[way_idx];
		end
	endgenerate
	assign cache_hit = (|way_hit_oh && (!sync_access_req || dd_load_sync_pending[dt_thread_idx])) && dt_tlb_hit;
	idx_to_oh #(
		.NUM_SIGNALS(defines_CACHE_LINE_WORDS),
		.DIRECTION("LSB0")
	) idx_to_oh_cache_lane(
		.one_hot(cache_lane_mask),
		.index(cache_lane_idx)
	);
	always @(*) begin
		if (_sv2v_0)
			;
		word_store_mask = 0;
		(* full_case, parallel_case *)
		case (dt_instruction[18-:4])
			4'b0111, 4'b1000: word_store_mask = dt_mask_value;
			4'b1101, 4'b1110:
				if ((dt_mask_value & subcycle_mask) != 0)
					word_store_mask = cache_lane_mask;
				else
					word_store_mask = 0;
			default: word_store_mask = cache_lane_mask;
		endcase
	end
	genvar _gv_swap_word_1;
	generate
		for (_gv_swap_word_1 = 0; _gv_swap_word_1 < 16; _gv_swap_word_1 = _gv_swap_word_1 + 1) begin : swap_word_gen
			localparam swap_word = _gv_swap_word_1;
			assign endian_twiddled_data[swap_word * 32+:8] = dt_store_value[(swap_word * 32) + 24+:8];
			assign endian_twiddled_data[(swap_word * 32) + 8+:8] = dt_store_value[(swap_word * 32) + 16+:8];
			assign endian_twiddled_data[(swap_word * 32) + 16+:8] = dt_store_value[(swap_word * 32) + 8+:8];
			assign endian_twiddled_data[(swap_word * 32) + 24+:8] = dt_store_value[swap_word * 32+:8];
		end
	endgenerate
	assign lane_store_value = dt_store_value[scgath_lane * 32+:32];
	always @(*) begin
		if (_sv2v_0)
			;
		(* full_case, parallel_case *)
		case (dt_instruction[18-:4])
			4'b0000, 4'b0001: begin
				dd_store_data = {64 {dt_store_value[7-:8]}};
				case (dt_request_paddr[1:0])
					2'd0: byte_store_mask = 4'b1000;
					2'd1: byte_store_mask = 4'b0100;
					2'd2: byte_store_mask = 4'b0010;
					2'd3: byte_store_mask = 4'b0001;
					default: byte_store_mask = 4'b0000;
				endcase
			end
			4'b0010, 4'b0011: begin
				dd_store_data = {32 {dt_store_value[7-:8], dt_store_value[15-:8]}};
				if (dt_request_paddr[1] == 1'b0)
					byte_store_mask = 4'b1100;
				else
					byte_store_mask = 4'b0011;
			end
			4'b0100, 4'b0101: begin
				byte_store_mask = 4'b1111;
				dd_store_data = {defines_CACHE_LINE_WORDS {dt_store_value[7-:8], dt_store_value[15-:8], dt_store_value[23-:8], dt_store_value[31-:8]}};
			end
			4'b1101, 4'b1110: begin
				byte_store_mask = 4'b1111;
				dd_store_data = {defines_CACHE_LINE_WORDS {lane_store_value[7:0], lane_store_value[15:8], lane_store_value[23:16], lane_store_value[31:24]}};
			end
			default: begin
				byte_store_mask = 4'b1111;
				dd_store_data = endian_twiddled_data;
			end
		endcase
	end
	genvar _gv_mask_idx_1;
	generate
		for (_gv_mask_idx_1 = 0; _gv_mask_idx_1 < defines_CACHE_LINE_BYTES; _gv_mask_idx_1 = _gv_mask_idx_1 + 1) begin : store_mask_gen
			localparam mask_idx = _gv_mask_idx_1;
			assign dd_store_mask[mask_idx] = word_store_mask[((defines_CACHE_LINE_BYTES - mask_idx) - 1) / 4] & byte_store_mask[mask_idx & 3];
		end
	endgenerate
	oh_to_idx #(.NUM_SIGNALS(4)) encode_hit_way(
		.one_hot(way_hit_oh),
		.index(way_hit_idx)
	);
	fakeram_1r1w_512x256 #(
		.DATA_WIDTH(defines_CACHE_LINE_BITS),
		.SIZE(256),
		.READ_DURING_WRITE("NEW_DATA")
	) l1d_data(
		.read_en(cache_hit && cached_load_req),
		.read_addr({way_hit_idx, dt_request_paddr[11-:6]}),
		.read_data(dd_load_data),
		.write_en(l2i_ddata_update_en),
		.write_addr({l2i_ddata_update_way, l2i_ddata_update_set}),
		.write_data(l2i_ddata_update_data),
		.*
	);
	assign cache_near_miss = ((((((!cache_hit && dt_tlb_hit) && cached_load_req) && |l2i_dtag_update_en_oh) && (l2i_dtag_update_set == dt_request_paddr[11-:6])) && (l2i_dtag_update_tag == dt_request_paddr[31-:20])) && !sync_access_req) && !any_fault;
	assign dd_cache_miss = (((cached_load_req && !cache_hit) && dt_tlb_hit) && !cache_near_miss) && !any_fault;
	assign dd_cache_miss_addr = dcache_request_addr[31:defines_CACHE_LINE_OFFSET_WIDTH];
	assign dd_cache_miss_thread_idx = dt_thread_idx;
	assign dd_cache_miss_sync = sync_access_req;
	assign dd_update_lru_en = (cache_hit && cached_access_req) && !any_fault;
	assign dd_update_lru_way = way_hit_idx;
	genvar _gv_thread_idx_2;
	function automatic [1:0] sv2v_cast_2;
		input reg [1:0] inp;
		sv2v_cast_2 = inp;
	endfunction
	generate
		for (_gv_thread_idx_2 = 0; _gv_thread_idx_2 < 4; _gv_thread_idx_2 = _gv_thread_idx_2 + 1) begin : sync_pending_gen
			localparam thread_idx = _gv_thread_idx_2;
			always @(posedge clk or posedge reset)
				if (reset)
					dd_load_sync_pending[thread_idx] <= 0;
				else if ((cached_load_req && sync_access_req) && (dt_thread_idx == sv2v_cast_2(thread_idx)))
					dd_load_sync_pending[thread_idx] <= !dd_load_sync_pending[thread_idx];
		end
	endgenerate
	assign fault_store_flag = dt_instruction[19] && !dt_instruction[14];
	always @(posedge clk) begin
		dd_instruction <= dt_instruction;
		dd_lane_mask <= dt_mask_value;
		dd_thread_idx <= dt_thread_idx;
		dd_request_vaddr <= dt_request_vaddr;
		dd_subcycle <= dt_subcycle;
		dd_rollback_pc <= dt_instruction[141-:32];
		dd_io_access <= io_access_req;
		if (tlb_miss)
			dd_trap_cause <= {1'b1, fault_store_flag, 4'd7};
		else if (page_fault)
			dd_trap_cause <= {1'b1, fault_store_flag, 4'd6};
		else if (supervisor_fault)
			dd_trap_cause <= {1'b1, fault_store_flag, 4'd9};
		else if (alignment_fault)
			dd_trap_cause <= {1'b1, fault_store_flag, 4'd5};
		else if (privileged_op_fault)
			dd_trap_cause <= 6'h02;
		else
			dd_trap_cause <= 6'h38;
	end
	always @(posedge clk or posedge reset)
		if (reset) begin
			dd_instruction_valid <= 1'sb0;
			dd_perf_dcache_hit <= 1'sb0;
			dd_perf_dcache_miss <= 1'sb0;
			dd_perf_dtlb_miss <= 1'sb0;
			dd_rollback_en <= 1'sb0;
			dd_suspend_thread <= 1'sb0;
			dd_trap <= 1'sb0;
		end
		else begin
			dd_instruction_valid <= dt_instruction_valid && !squash_instruction;
			dd_rollback_en <= ((cached_load_req && !cache_hit) && dt_tlb_hit) && !any_fault;
			dd_suspend_thread <= (((cached_load_req && dt_tlb_hit) && !cache_hit) && !cache_near_miss) && !any_fault;
			dd_trap <= any_fault || tlb_miss;
			dd_perf_dcache_hit <= ((cached_load_req && !any_fault) && !tlb_miss) && cache_hit;
			dd_perf_dcache_miss <= ((cached_load_req && !any_fault) && !tlb_miss) && !cache_hit;
			dd_perf_dtlb_miss <= tlb_miss;
		end
	initial _sv2v_0 = 0;
endmodule
module dcache_tag_stage (
	clk,
	reset,
	of_operand1,
	of_mask_value,
	of_store_value,
	of_instruction_valid,
	of_instruction,
	of_thread_idx,
	of_subcycle,
	dd_update_lru_en,
	dd_update_lru_way,
	dt_instruction_valid,
	dt_instruction,
	dt_mask_value,
	dt_thread_idx,
	dt_request_vaddr,
	dt_request_paddr,
	dt_tlb_hit,
	dt_tlb_writable,
	dt_store_value,
	dt_subcycle,
	dt_valid,
	dt_tag,
	dt_tlb_supervisor,
	dt_tlb_present,
	dt_invalidate_tlb_en,
	dt_invalidate_tlb_all_en,
	dt_update_itlb_en,
	dt_update_itlb_asid,
	dt_update_itlb_vpage_idx,
	dt_update_itlb_ppage_idx,
	dt_update_itlb_present,
	dt_update_itlb_supervisor,
	dt_update_itlb_global,
	dt_update_itlb_executable,
	l2i_dcache_lru_fill_en,
	l2i_dcache_lru_fill_set,
	l2i_dtag_update_en_oh,
	l2i_dtag_update_set,
	l2i_dtag_update_tag,
	l2i_dtag_update_valid,
	l2i_snoop_en,
	l2i_snoop_set,
	dt_snoop_valid,
	dt_snoop_tag,
	dt_fill_lru,
	cr_mmu_en,
	cr_supervisor_en,
	cr_current_asid,
	wb_rollback_en,
	wb_rollback_thread_idx
);
	reg _sv2v_0;
	input clk;
	input reset;
	localparam defines_NUM_VECTOR_LANES = 16;
	input wire [511:0] of_operand1;
	input wire [15:0] of_mask_value;
	input wire [511:0] of_store_value;
	input of_instruction_valid;
	input wire [141:0] of_instruction;
	input wire [1:0] of_thread_idx;
	input wire [3:0] of_subcycle;
	input dd_update_lru_en;
	input wire [1:0] dd_update_lru_way;
	output reg dt_instruction_valid;
	output reg [141:0] dt_instruction;
	output reg [15:0] dt_mask_value;
	output reg [1:0] dt_thread_idx;
	localparam defines_CACHE_LINE_BYTES = 64;
	localparam defines_CACHE_LINE_OFFSET_WIDTH = 6;
	localparam defines_DCACHE_TAG_BITS = 20;
	output wire [31:0] dt_request_vaddr;
	output wire [31:0] dt_request_paddr;
	output reg dt_tlb_hit;
	output reg dt_tlb_writable;
	output reg [511:0] dt_store_value;
	output reg [3:0] dt_subcycle;
	output reg [0:3] dt_valid;
	output wire [79:0] dt_tag;
	output reg dt_tlb_supervisor;
	output reg dt_tlb_present;
	output wire dt_invalidate_tlb_en;
	output wire dt_invalidate_tlb_all_en;
	output wire dt_update_itlb_en;
	localparam defines_ASID_WIDTH = 8;
	output wire [7:0] dt_update_itlb_asid;
	localparam defines_PAGE_SIZE = 'h1000;
	localparam defines_PAGE_NUM_BITS = 32 - $clog2('h1000);
	output wire [defines_PAGE_NUM_BITS - 1:0] dt_update_itlb_vpage_idx;
	output wire [defines_PAGE_NUM_BITS - 1:0] dt_update_itlb_ppage_idx;
	output wire dt_update_itlb_present;
	output wire dt_update_itlb_supervisor;
	output wire dt_update_itlb_global;
	output wire dt_update_itlb_executable;
	input l2i_dcache_lru_fill_en;
	input wire [5:0] l2i_dcache_lru_fill_set;
	input [3:0] l2i_dtag_update_en_oh;
	input wire [5:0] l2i_dtag_update_set;
	input wire [19:0] l2i_dtag_update_tag;
	input l2i_dtag_update_valid;
	input l2i_snoop_en;
	input wire [5:0] l2i_snoop_set;
	output reg [0:3] dt_snoop_valid;
	output wire [79:0] dt_snoop_tag;
	output wire [1:0] dt_fill_lru;
	input [0:3] cr_mmu_en;
	input wire [0:3] cr_supervisor_en;
	input [31:0] cr_current_asid;
	input wire wb_rollback_en;
	input wire [1:0] wb_rollback_thread_idx;
	wire [31:0] request_addr_nxt;
	wire cache_load_en;
	wire instruction_valid;
	wire [3:0] scgath_lane;
	wire [defines_PAGE_NUM_BITS - 1:0] tlb_ppage_idx;
	wire tlb_hit;
	reg [defines_PAGE_NUM_BITS - 1:0] ppage_idx;
	reg [31:0] fetched_addr;
	wire tlb_lookup_en;
	wire valid_cache_control;
	wire update_dtlb_en;
	wire tlb_writable;
	wire tlb_present;
	wire tlb_supervisor;
	wire [(defines_PAGE_NUM_BITS + (32 - (defines_PAGE_NUM_BITS + 5))) + 4:0] new_tlb_value;
	assign instruction_valid = (of_instruction_valid && (!wb_rollback_en || (wb_rollback_thread_idx != of_thread_idx))) && (of_instruction[21-:2] == 2'd0);
	assign valid_cache_control = instruction_valid && of_instruction[3];
	assign cache_load_en = ((instruction_valid && (of_instruction[18-:4] != 4'b0110)) && of_instruction[19]) && of_instruction[14];
	assign scgath_lane = ~of_subcycle;
	assign request_addr_nxt = of_operand1[scgath_lane * 32+:32] + of_instruction[58-:32];
	assign new_tlb_value = of_store_value[0+:32];
	assign dt_invalidate_tlb_en = (valid_cache_control && (of_instruction[2-:3] == 3'b101)) && cr_supervisor_en[of_thread_idx];
	assign dt_invalidate_tlb_all_en = (valid_cache_control && (of_instruction[2-:3] == 3'b110)) && cr_supervisor_en[of_thread_idx];
	assign update_dtlb_en = (valid_cache_control && (of_instruction[2-:3] == 3'b000)) && cr_supervisor_en[of_thread_idx];
	assign dt_update_itlb_en = (valid_cache_control && (of_instruction[2-:3] == 3'b111)) && cr_supervisor_en[of_thread_idx];
	assign dt_update_itlb_supervisor = new_tlb_value[3];
	assign dt_update_itlb_global = new_tlb_value[4];
	assign dt_update_itlb_present = new_tlb_value[0];
	assign tlb_lookup_en = (((instruction_valid && (of_instruction[18-:4] != 4'b0110)) && !update_dtlb_en) && !dt_invalidate_tlb_en) && !dt_invalidate_tlb_all_en;
	assign dt_update_itlb_vpage_idx = of_operand1[31-:defines_PAGE_NUM_BITS];
	assign dt_update_itlb_ppage_idx = new_tlb_value[defines_PAGE_NUM_BITS + (36 - (defines_PAGE_NUM_BITS + 5))-:((defines_PAGE_NUM_BITS + (36 - (defines_PAGE_NUM_BITS + 5))) >= (37 - (defines_PAGE_NUM_BITS + 5)) ? ((defines_PAGE_NUM_BITS + (36 - (defines_PAGE_NUM_BITS + 5))) - (37 - (defines_PAGE_NUM_BITS + 5))) + 1 : ((37 - (defines_PAGE_NUM_BITS + 5)) - (defines_PAGE_NUM_BITS + (36 - (defines_PAGE_NUM_BITS + 5)))) + 1)];
	assign dt_update_itlb_executable = new_tlb_value[2];
	assign dt_update_itlb_asid = cr_current_asid[(3 - of_thread_idx) * 8+:8];
	genvar _gv_way_idx_2;
	generate
		for (_gv_way_idx_2 = 0; _gv_way_idx_2 < 4; _gv_way_idx_2 = _gv_way_idx_2 + 1) begin : way_tag_gen
			localparam way_idx = _gv_way_idx_2;
			reg line_valid [0:63];
			fakeram_2r1w_20x64 #(
				.DATA_WIDTH(defines_DCACHE_TAG_BITS),
				.SIZE(64),
				.READ_DURING_WRITE("NEW_DATA")
			) sram_tags(
				.read1_en(cache_load_en),
				.read1_addr(request_addr_nxt[11-:6]),
				.read1_data(dt_tag[(3 - way_idx) * defines_DCACHE_TAG_BITS+:defines_DCACHE_TAG_BITS]),
				.read2_en(l2i_snoop_en),
				.read2_addr(l2i_snoop_set),
				.read2_data(dt_snoop_tag[(3 - way_idx) * defines_DCACHE_TAG_BITS+:defines_DCACHE_TAG_BITS]),
				.write_en(l2i_dtag_update_en_oh[way_idx]),
				.write_addr(l2i_dtag_update_set),
				.write_data(l2i_dtag_update_tag),
				.*
			);
			always @(posedge clk or posedge reset)
				if (reset) begin : sv2v_autoblock_1
					reg signed [31:0] set_idx;
					for (set_idx = 0; set_idx < 64; set_idx = set_idx + 1)
						line_valid[set_idx] <= 0;
				end
				else if (l2i_dtag_update_en_oh[way_idx])
					line_valid[l2i_dtag_update_set] <= l2i_dtag_update_valid;
			always @(posedge clk) begin
				if (cache_load_en) begin
					if (l2i_dtag_update_en_oh[way_idx] && (l2i_dtag_update_set == request_addr_nxt[11-:6]))
						dt_valid[way_idx] <= l2i_dtag_update_valid;
					else
						dt_valid[way_idx] <= line_valid[request_addr_nxt[11-:6]];
				end
				if (l2i_snoop_en) begin
					if (l2i_dtag_update_en_oh[way_idx] && (l2i_dtag_update_set == l2i_snoop_set))
						dt_snoop_valid[way_idx] <= l2i_dtag_update_valid;
					else
						dt_snoop_valid[way_idx] <= line_valid[l2i_snoop_set];
				end
			end
		end
	endgenerate
	tlb #(
		.NUM_ENTRIES(64),
		.NUM_WAYS(4)
	) dtlb(
		.lookup_en(tlb_lookup_en),
		.update_en(update_dtlb_en),
		.invalidate_en(dt_invalidate_tlb_en),
		.invalidate_all_en(dt_invalidate_tlb_all_en),
		.request_vpage_idx(request_addr_nxt[31-:defines_PAGE_NUM_BITS]),
		.request_asid(cr_current_asid[(3 - of_thread_idx) * 8+:8]),
		.update_ppage_idx(new_tlb_value[defines_PAGE_NUM_BITS + (36 - (defines_PAGE_NUM_BITS + 5))-:((defines_PAGE_NUM_BITS + (36 - (defines_PAGE_NUM_BITS + 5))) >= (37 - (defines_PAGE_NUM_BITS + 5)) ? ((defines_PAGE_NUM_BITS + (36 - (defines_PAGE_NUM_BITS + 5))) - (37 - (defines_PAGE_NUM_BITS + 5))) + 1 : ((37 - (defines_PAGE_NUM_BITS + 5)) - (defines_PAGE_NUM_BITS + (36 - (defines_PAGE_NUM_BITS + 5)))) + 1)]),
		.update_present(new_tlb_value[0]),
		.update_exe_writable(new_tlb_value[1]),
		.update_supervisor(new_tlb_value[3]),
		.update_global(new_tlb_value[4]),
		.lookup_ppage_idx(tlb_ppage_idx),
		.lookup_hit(tlb_hit),
		.lookup_present(tlb_present),
		.lookup_exe_writable(tlb_writable),
		.lookup_supervisor(tlb_supervisor),
		.clk(clk),
		.reset(reset)
	);
	always @(*) begin
		if (_sv2v_0)
			;
		if (cr_mmu_en[dt_thread_idx]) begin
			dt_tlb_hit = tlb_hit;
			dt_tlb_writable = tlb_writable;
			dt_tlb_present = tlb_present;
			dt_tlb_supervisor = tlb_supervisor;
			ppage_idx = tlb_ppage_idx;
		end
		else begin
			dt_tlb_hit = 1;
			dt_tlb_writable = 1;
			dt_tlb_present = 1;
			dt_tlb_supervisor = 0;
			ppage_idx = fetched_addr[31-:defines_PAGE_NUM_BITS];
		end
	end
	cache_lru #(
		.NUM_WAYS(4),
		.NUM_SETS(64)
	) lru(
		.fill_en(l2i_dcache_lru_fill_en),
		.fill_set(l2i_dcache_lru_fill_set),
		.fill_way(dt_fill_lru),
		.access_en(instruction_valid),
		.access_set(request_addr_nxt[11-:6]),
		.update_en(dd_update_lru_en),
		.update_way(dd_update_lru_way),
		.clk(clk),
		.reset(reset)
	);
	always @(posedge clk) begin
		dt_instruction <= of_instruction;
		dt_mask_value <= of_mask_value;
		dt_thread_idx <= of_thread_idx;
		dt_store_value <= of_store_value;
		dt_subcycle <= of_subcycle;
		fetched_addr <= request_addr_nxt;
	end
	always @(posedge clk or posedge reset)
		if (reset)
			dt_instruction_valid <= 1'sb0;
		else
			dt_instruction_valid <= instruction_valid;
	assign dt_request_paddr = {ppage_idx, fetched_addr[31 - defines_PAGE_NUM_BITS:0]};
	assign dt_request_vaddr = fetched_addr;
	initial _sv2v_0 = 0;
endmodule
module fp_execute_stage1 (
	clk,
	reset,
	wb_rollback_en,
	wb_rollback_thread_idx,
	of_operand1,
	of_operand2,
	of_mask_value,
	of_instruction_valid,
	of_instruction,
	of_thread_idx,
	of_subcycle,
	fx1_instruction_valid,
	fx1_instruction,
	fx1_mask_value,
	fx1_thread_idx,
	fx1_subcycle,
	fx1_result_inf,
	fx1_result_nan,
	fx1_equal,
	fx1_ftoi_lshift,
	fx1_significand_le,
	fx1_significand_se,
	fx1_se_align_shift,
	fx1_add_exponent,
	fx1_logical_subtract,
	fx1_add_result_sign,
	fx1_multiplicand,
	fx1_multiplier,
	fx1_mul_exponent,
	fx1_mul_underflow,
	fx1_mul_sign
);
	reg _sv2v_0;
	input clk;
	input reset;
	input wire wb_rollback_en;
	input wire [1:0] wb_rollback_thread_idx;
	localparam defines_NUM_VECTOR_LANES = 16;
	input wire [511:0] of_operand1;
	input wire [511:0] of_operand2;
	input wire [15:0] of_mask_value;
	input of_instruction_valid;
	input wire [141:0] of_instruction;
	input wire [1:0] of_thread_idx;
	input wire [3:0] of_subcycle;
	output reg fx1_instruction_valid;
	output reg [141:0] fx1_instruction;
	output reg [15:0] fx1_mask_value;
	output reg [1:0] fx1_thread_idx;
	output reg [3:0] fx1_subcycle;
	output reg [15:0] fx1_result_inf;
	output reg [15:0] fx1_result_nan;
	output reg [15:0] fx1_equal;
	output reg [95:0] fx1_ftoi_lshift;
	output reg [511:0] fx1_significand_le;
	output reg [511:0] fx1_significand_se;
	output reg [95:0] fx1_se_align_shift;
	output reg [127:0] fx1_add_exponent;
	output reg [15:0] fx1_logical_subtract;
	output reg [15:0] fx1_add_result_sign;
	output reg [511:0] fx1_multiplicand;
	output reg [511:0] fx1_multiplier;
	output reg [127:0] fx1_mul_exponent;
	output reg [15:0] fx1_mul_underflow;
	output reg [15:0] fx1_mul_sign;
	wire fmul;
	wire imul;
	wire ftoi;
	wire itof;
	wire compare;
	assign fmul = of_instruction[70-:6] == 6'b100010;
	assign imul = ((of_instruction[70-:6] == 6'b000111) || (of_instruction[70-:6] == 6'b001000)) || (of_instruction[70-:6] == 6'b011111);
	assign ftoi = of_instruction[70-:6] == 6'b011011;
	assign itof = of_instruction[70-:6] == 6'b101010;
	assign compare = (((((of_instruction[70-:6] == 6'b101100) || (of_instruction[70-:6] == 6'b101110)) || (of_instruction[70-:6] == 6'b101101)) || (of_instruction[70-:6] == 6'b101111)) || (of_instruction[70-:6] == 6'b110000)) || (of_instruction[70-:6] == 6'b110001);
	genvar _gv_lane_idx_1;
	localparam defines_FLOAT32_EXP_WIDTH = 8;
	localparam defines_FLOAT32_SIG_WIDTH = 23;
	function automatic [5:0] sv2v_cast_6;
		input reg [5:0] inp;
		sv2v_cast_6 = inp;
	endfunction
	function automatic [31:0] sv2v_cast_32;
		input reg [31:0] inp;
		sv2v_cast_32 = inp;
	endfunction
	generate
		for (_gv_lane_idx_1 = 0; _gv_lane_idx_1 < defines_NUM_VECTOR_LANES; _gv_lane_idx_1 = _gv_lane_idx_1 + 1) begin : lane_logic_gen
			localparam lane_idx = _gv_lane_idx_1;
			wire [31:0] fop1;
			wire [31:0] fop2;
			wire [defines_FLOAT32_SIG_WIDTH:0] full_significand1;
			wire [defines_FLOAT32_SIG_WIDTH:0] full_significand2;
			wire op1_hidden_bit;
			wire op2_hidden_bit;
			wire op1_larger;
			wire [7:0] exp_difference;
			wire subtract;
			wire [7:0] mul_exponent;
			wire fop1_inf;
			wire fop1_nan;
			wire fop2_inf;
			wire fop2_nan;
			reg logical_subtract;
			reg result_nan;
			wire equal;
			wire mul_exponent_underflow;
			wire mul_exponent_carry;
			reg [5:0] ftoi_rshift;
			reg [5:0] ftoi_lshift_nxt;
			assign fop1 = of_operand1[lane_idx * 32+:32];
			assign fop2 = of_operand2[lane_idx * 32+:32];
			assign op1_hidden_bit = fop1[30-:8] != 0;
			assign op2_hidden_bit = fop2[30-:8] != 0;
			assign full_significand1 = {op1_hidden_bit, fop1[22-:defines_FLOAT32_SIG_WIDTH]};
			assign full_significand2 = {op2_hidden_bit, fop2[22-:defines_FLOAT32_SIG_WIDTH]};
			assign subtract = of_instruction[70-:6] != 6'b100000;
			assign fop1_inf = (fop1[30-:8] == 8'hff) && (fop1[22-:defines_FLOAT32_SIG_WIDTH] == 0);
			assign fop1_nan = (fop1[30-:8] == 8'hff) && (fop1[22-:defines_FLOAT32_SIG_WIDTH] != 0);
			assign fop2_inf = (fop2[30-:8] == 8'hff) && (fop2[22-:defines_FLOAT32_SIG_WIDTH] == 0);
			assign fop2_nan = (fop2[30-:8] == 8'hff) && (fop2[22-:defines_FLOAT32_SIG_WIDTH] != 0);
			always @(*) begin
				if (_sv2v_0)
					;
				if (fop2[30-:8] < 8'd118) begin
					ftoi_rshift = 6'd32;
					ftoi_lshift_nxt = 0;
				end
				else if (fop2[30-:8] < 8'd150) begin
					ftoi_rshift = sv2v_cast_6(8'd150 - fop2[30-:8]);
					ftoi_lshift_nxt = 0;
				end
				else begin
					ftoi_rshift = 6'd0;
					ftoi_lshift_nxt = sv2v_cast_6(fop2[30-:8] - 8'd150);
				end
			end
			always @(*) begin
				if (_sv2v_0)
					;
				if (itof)
					logical_subtract = of_operand2[(lane_idx * 32) + 31];
				else if (ftoi)
					logical_subtract = fop2[31];
				else
					logical_subtract = (fop1[31] ^ fop2[31]) ^ subtract;
			end
			always @(*) begin
				if (_sv2v_0)
					;
				if (itof)
					result_nan = 0;
				else if (fmul)
					result_nan = ((fop1_nan || fop2_nan) || (fop1_inf && (of_operand2[lane_idx * 32+:32] == 0))) || (fop2_inf && (of_operand1[lane_idx * 32+:32] == 0));
				else if (ftoi)
					result_nan = (fop2_nan || fop2_inf) || (fop2[30-:8] >= 8'd159);
				else if (compare)
					result_nan = fop1_nan || fop2_nan;
				else
					result_nan = (fop1_nan || fop2_nan) || ((fop1_inf && fop2_inf) && logical_subtract);
			end
			assign equal = ((fop1_inf && fop2_inf) && (fop1[31] == fop2[31])) || ((!fop1_inf && !fop2_inf) && (fop1 == fop2));
			assign {mul_exponent_underflow, mul_exponent_carry, mul_exponent} = ({2'd0, fop1[30-:8]} + {2'd0, fop2[30-:8]}) - 10'd127;
			assign op1_larger = (fop1[30-:8] > fop2[30-:8]) || ((fop1[30-:8] == fop2[30-:8]) && (full_significand1 >= full_significand2));
			assign exp_difference = (op1_larger ? fop1[30-:8] - fop2[30-:8] : fop2[30-:8] - fop1[30-:8]);
			always @(posedge clk) begin
				fx1_result_nan[lane_idx] <= result_nan;
				fx1_result_inf[lane_idx] <= (!itof && !result_nan) && ((fop1_inf || fop2_inf) || ((fmul && mul_exponent_carry) && !mul_exponent_underflow));
				fx1_equal[lane_idx] <= equal;
				fx1_mul_underflow[lane_idx] <= mul_exponent_underflow;
				if ((op1_larger || ftoi) || itof) begin
					if (ftoi || itof)
						fx1_significand_le[lane_idx * 32+:32] <= 0;
					else
						fx1_significand_le[lane_idx * 32+:32] <= sv2v_cast_32(full_significand1);
					if (itof) begin
						fx1_significand_se[lane_idx * 32+:32] <= of_operand2[lane_idx * 32+:32];
						fx1_add_exponent[lane_idx * 8+:8] <= 8'd127 + 8'd23;
						fx1_add_result_sign[lane_idx] <= of_operand2[(lane_idx * 32) + 31];
					end
					else begin
						fx1_significand_se[lane_idx * 32+:32] <= sv2v_cast_32(full_significand2);
						fx1_add_exponent[lane_idx * 8+:8] <= fop1[30-:8];
						fx1_add_result_sign[lane_idx] <= fop1[31];
					end
				end
				else begin
					fx1_significand_le[lane_idx * 32+:32] <= sv2v_cast_32(full_significand2);
					fx1_significand_se[lane_idx * 32+:32] <= sv2v_cast_32(full_significand1);
					fx1_add_exponent[lane_idx * 8+:8] <= fop2[30-:8];
					fx1_add_result_sign[lane_idx] <= fop2[31] ^ subtract;
				end
				fx1_logical_subtract[lane_idx] <= logical_subtract;
				if (itof)
					fx1_se_align_shift[lane_idx * 6+:6] <= 0;
				else if (ftoi)
					fx1_se_align_shift[lane_idx * 6+:6] <= ftoi_rshift[5:0];
				else
					fx1_se_align_shift[lane_idx * 6+:6] <= (exp_difference < 8'd27 ? sv2v_cast_6(exp_difference) : 6'd27);
				fx1_ftoi_lshift[lane_idx * 6+:6] <= ftoi_lshift_nxt;
				if (imul) begin
					fx1_multiplicand[lane_idx * 32+:32] <= of_operand1[lane_idx * 32+:32];
					fx1_multiplier[lane_idx * 32+:32] <= of_operand2[lane_idx * 32+:32];
				end
				else begin
					fx1_multiplicand[lane_idx * 32+:32] <= sv2v_cast_32(full_significand1);
					fx1_multiplier[lane_idx * 32+:32] <= sv2v_cast_32(full_significand2);
				end
				fx1_mul_exponent[lane_idx * 8+:8] <= mul_exponent;
				fx1_mul_sign[lane_idx] <= fop1[31] ^ fop2[31];
			end
		end
	endgenerate
	always @(posedge clk) begin
		fx1_instruction <= of_instruction;
		fx1_mask_value <= of_mask_value;
		fx1_thread_idx <= of_thread_idx;
		fx1_subcycle <= of_subcycle;
	end
	always @(posedge clk or posedge reset)
		if (reset)
			fx1_instruction_valid <= 1'sb0;
		else
			fx1_instruction_valid <= (of_instruction_valid && (!wb_rollback_en || (wb_rollback_thread_idx != of_thread_idx))) && (of_instruction[21-:2] == 2'd2);
	initial _sv2v_0 = 0;
endmodule
module fp_execute_stage2 (
	clk,
	reset,
	wb_rollback_en,
	wb_rollback_thread_idx,
	wb_rollback_pipeline,
	fx1_mask_value,
	fx1_instruction_valid,
	fx1_instruction,
	fx1_thread_idx,
	fx1_subcycle,
	fx1_result_inf,
	fx1_result_nan,
	fx1_equal,
	fx1_ftoi_lshift,
	fx1_significand_le,
	fx1_significand_se,
	fx1_logical_subtract,
	fx1_se_align_shift,
	fx1_add_exponent,
	fx1_add_result_sign,
	fx1_mul_exponent,
	fx1_mul_sign,
	fx1_multiplicand,
	fx1_multiplier,
	fx1_mul_underflow,
	fx2_instruction_valid,
	fx2_instruction,
	fx2_mask_value,
	fx2_thread_idx,
	fx2_subcycle,
	fx2_result_inf,
	fx2_result_nan,
	fx2_equal,
	fx2_ftoi_lshift,
	fx2_logical_subtract,
	fx2_add_result_sign,
	fx2_significand_le,
	fx2_significand_se,
	fx2_add_exponent,
	fx2_guard,
	fx2_round,
	fx2_sticky,
	fx2_significand_product,
	fx2_mul_exponent,
	fx2_mul_underflow,
	fx2_mul_sign
);
	input clk;
	input reset;
	input wire wb_rollback_en;
	input wire [1:0] wb_rollback_thread_idx;
	input wire [1:0] wb_rollback_pipeline;
	localparam defines_NUM_VECTOR_LANES = 16;
	input wire [15:0] fx1_mask_value;
	input fx1_instruction_valid;
	input wire [141:0] fx1_instruction;
	input wire [1:0] fx1_thread_idx;
	input wire [3:0] fx1_subcycle;
	input [15:0] fx1_result_inf;
	input [15:0] fx1_result_nan;
	input [15:0] fx1_equal;
	input [95:0] fx1_ftoi_lshift;
	input wire [511:0] fx1_significand_le;
	input wire [511:0] fx1_significand_se;
	input [15:0] fx1_logical_subtract;
	input [95:0] fx1_se_align_shift;
	input [127:0] fx1_add_exponent;
	input [15:0] fx1_add_result_sign;
	input [127:0] fx1_mul_exponent;
	input [15:0] fx1_mul_sign;
	input [511:0] fx1_multiplicand;
	input [511:0] fx1_multiplier;
	input [15:0] fx1_mul_underflow;
	output reg fx2_instruction_valid;
	output reg [141:0] fx2_instruction;
	output reg [15:0] fx2_mask_value;
	output reg [1:0] fx2_thread_idx;
	output reg [3:0] fx2_subcycle;
	output reg [15:0] fx2_result_inf;
	output reg [15:0] fx2_result_nan;
	output reg [15:0] fx2_equal;
	output reg [95:0] fx2_ftoi_lshift;
	output reg [15:0] fx2_logical_subtract;
	output reg [15:0] fx2_add_result_sign;
	output reg [511:0] fx2_significand_le;
	output reg [511:0] fx2_significand_se;
	output reg [127:0] fx2_add_exponent;
	output reg [15:0] fx2_guard;
	output reg [15:0] fx2_round;
	output reg [15:0] fx2_sticky;
	output reg [1023:0] fx2_significand_product;
	output reg [127:0] fx2_mul_exponent;
	output reg [15:0] fx2_mul_underflow;
	output reg [15:0] fx2_mul_sign;
	wire imulhs;
	assign imulhs = fx1_instruction[70-:6] == 6'b011111;
	genvar _gv_lane_idx_2;
	generate
		for (_gv_lane_idx_2 = 0; _gv_lane_idx_2 < defines_NUM_VECTOR_LANES; _gv_lane_idx_2 = _gv_lane_idx_2 + 1) begin : lane_logic_gen
			localparam lane_idx = _gv_lane_idx_2;
			wire [31:0] aligned_significand;
			wire guard;
			wire round;
			wire [24:0] sticky_bits;
			wire sticky;
			wire [63:0] sext_multiplicand;
			wire [63:0] sext_multiplier;
			assign {aligned_significand, guard, round, sticky_bits} = {fx1_significand_se[lane_idx * 32+:32], 27'd0} >> fx1_se_align_shift[lane_idx * 6+:6];
			assign sticky = |sticky_bits;
			assign sext_multiplicand = {{32 {fx1_multiplicand[(lane_idx * 32) + 31] && imulhs}}, fx1_multiplicand[lane_idx * 32+:32]};
			assign sext_multiplier = {{32 {fx1_multiplier[(lane_idx * 32) + 31] && imulhs}}, fx1_multiplier[lane_idx * 32+:32]};
			always @(posedge clk) begin
				fx2_significand_le[lane_idx * 32+:32] <= fx1_significand_le[lane_idx * 32+:32];
				fx2_significand_se[lane_idx * 32+:32] <= aligned_significand;
				fx2_add_exponent[lane_idx * 8+:8] <= fx1_add_exponent[lane_idx * 8+:8];
				fx2_logical_subtract[lane_idx] <= fx1_logical_subtract[lane_idx];
				fx2_add_result_sign[lane_idx] <= fx1_add_result_sign[lane_idx];
				fx2_guard[lane_idx] <= guard;
				fx2_round[lane_idx] <= round;
				fx2_sticky[lane_idx] <= sticky;
				fx2_mul_exponent[lane_idx * 8+:8] <= fx1_mul_exponent[lane_idx * 8+:8];
				fx2_mul_underflow[lane_idx] <= fx1_mul_underflow[lane_idx];
				fx2_mul_sign[lane_idx] <= fx1_mul_sign[lane_idx];
				fx2_result_inf[lane_idx] <= fx1_result_inf[lane_idx];
				fx2_result_nan[lane_idx] <= fx1_result_nan[lane_idx];
				fx2_equal[lane_idx] <= fx1_equal[lane_idx];
				fx2_ftoi_lshift[lane_idx * 6+:6] <= fx1_ftoi_lshift[lane_idx * 6+:6];
				fx2_significand_product[lane_idx * 64+:64] <= sext_multiplicand * sext_multiplier;
			end
		end
	endgenerate
	always @(posedge clk) begin
		fx2_instruction <= fx1_instruction;
		fx2_mask_value <= fx1_mask_value;
		fx2_thread_idx <= fx1_thread_idx;
		fx2_subcycle <= fx1_subcycle;
	end
	always @(posedge clk or posedge reset)
		if (reset)
			fx2_instruction_valid <= 1'sb0;
		else
			fx2_instruction_valid <= fx1_instruction_valid && ((!wb_rollback_en || (wb_rollback_thread_idx != fx1_thread_idx)) || (wb_rollback_pipeline != 2'd0));
endmodule
module fp_execute_stage3 (
	clk,
	reset,
	fx2_mask_value,
	fx2_instruction_valid,
	fx2_instruction,
	fx2_thread_idx,
	fx2_subcycle,
	fx2_result_inf,
	fx2_result_nan,
	fx2_equal,
	fx2_ftoi_lshift,
	fx2_significand_le,
	fx2_significand_se,
	fx2_logical_subtract,
	fx2_add_exponent,
	fx2_add_result_sign,
	fx2_guard,
	fx2_round,
	fx2_sticky,
	fx2_significand_product,
	fx2_mul_exponent,
	fx2_mul_underflow,
	fx2_mul_sign,
	fx3_instruction_valid,
	fx3_instruction,
	fx3_mask_value,
	fx3_thread_idx,
	fx3_subcycle,
	fx3_result_inf,
	fx3_result_nan,
	fx3_equal,
	fx3_ftoi_lshift,
	fx3_add_significand,
	fx3_add_exponent,
	fx3_add_result_sign,
	fx3_logical_subtract,
	fx3_significand_product,
	fx3_mul_exponent,
	fx3_mul_underflow,
	fx3_mul_sign
);
	input clk;
	input reset;
	localparam defines_NUM_VECTOR_LANES = 16;
	input wire [15:0] fx2_mask_value;
	input fx2_instruction_valid;
	input wire [141:0] fx2_instruction;
	input wire [1:0] fx2_thread_idx;
	input wire [3:0] fx2_subcycle;
	input [15:0] fx2_result_inf;
	input [15:0] fx2_result_nan;
	input [15:0] fx2_equal;
	input [95:0] fx2_ftoi_lshift;
	input wire [511:0] fx2_significand_le;
	input wire [511:0] fx2_significand_se;
	input [15:0] fx2_logical_subtract;
	input [127:0] fx2_add_exponent;
	input [15:0] fx2_add_result_sign;
	input [15:0] fx2_guard;
	input [15:0] fx2_round;
	input [15:0] fx2_sticky;
	input [1023:0] fx2_significand_product;
	input [127:0] fx2_mul_exponent;
	input [15:0] fx2_mul_underflow;
	input [15:0] fx2_mul_sign;
	output reg fx3_instruction_valid;
	output reg [141:0] fx3_instruction;
	output reg [15:0] fx3_mask_value;
	output reg [1:0] fx3_thread_idx;
	output reg [3:0] fx3_subcycle;
	output reg [15:0] fx3_result_inf;
	output reg [15:0] fx3_result_nan;
	output reg [15:0] fx3_equal;
	output reg [95:0] fx3_ftoi_lshift;
	output reg [511:0] fx3_add_significand;
	output reg [127:0] fx3_add_exponent;
	output reg [15:0] fx3_add_result_sign;
	output reg [15:0] fx3_logical_subtract;
	output reg [1023:0] fx3_significand_product;
	output reg [127:0] fx3_mul_exponent;
	output reg [15:0] fx3_mul_underflow;
	output reg [15:0] fx3_mul_sign;
	wire ftoi;
	assign ftoi = fx2_instruction[70-:6] == 6'b011011;
	genvar _gv_lane_idx_3;
	generate
		for (_gv_lane_idx_3 = 0; _gv_lane_idx_3 < defines_NUM_VECTOR_LANES; _gv_lane_idx_3 = _gv_lane_idx_3 + 1) begin : lane_logic_gen
			localparam lane_idx = _gv_lane_idx_3;
			wire carry_in;
			wire [31:0] unnormalized_sum;
			wire sum_odd;
			wire round_up;
			wire round_tie;
			wire do_round;
			wire _unused;
			assign sum_odd = fx2_significand_le[lane_idx * 32] ^ fx2_significand_se[lane_idx * 32];
			assign round_tie = fx2_guard[lane_idx] && !(fx2_round[lane_idx] || fx2_sticky[lane_idx]);
			assign round_up = fx2_guard[lane_idx] && (fx2_round[lane_idx] || fx2_sticky[lane_idx]);
			assign do_round = round_up || (sum_odd && round_tie);
			assign carry_in = fx2_logical_subtract[lane_idx] ^ (do_round && !ftoi);
			assign {unnormalized_sum, _unused} = {fx2_significand_le[lane_idx * 32+:32], 1'b1} + {fx2_significand_se[lane_idx * 32+:32] ^ {32 {fx2_logical_subtract[lane_idx]}}, carry_in};
			always @(posedge clk) begin
				fx3_result_inf[lane_idx] <= fx2_result_inf[lane_idx];
				fx3_result_nan[lane_idx] <= fx2_result_nan[lane_idx];
				fx3_equal[lane_idx] <= fx2_equal[lane_idx];
				fx3_equal[lane_idx] <= fx2_equal[lane_idx];
				fx3_ftoi_lshift[lane_idx * 6+:6] <= fx2_ftoi_lshift[lane_idx * 6+:6];
				fx3_add_significand[lane_idx * 32+:32] <= unnormalized_sum;
				fx3_add_exponent[lane_idx * 8+:8] <= fx2_add_exponent[lane_idx * 8+:8];
				fx3_logical_subtract[lane_idx] <= fx2_logical_subtract[lane_idx];
				fx3_add_result_sign[lane_idx] <= fx2_add_result_sign[lane_idx];
				fx3_significand_product[lane_idx * 64+:64] <= fx2_significand_product[lane_idx * 64+:64];
				fx3_mul_exponent[lane_idx * 8+:8] <= fx2_mul_exponent[lane_idx * 8+:8];
				fx3_mul_underflow[lane_idx] <= fx2_mul_underflow[lane_idx];
				fx3_mul_sign[lane_idx] <= fx2_mul_sign[lane_idx];
			end
		end
	endgenerate
	always @(posedge clk) begin
		fx3_instruction <= fx2_instruction;
		fx3_mask_value <= fx2_mask_value;
		fx3_thread_idx <= fx2_thread_idx;
		fx3_subcycle <= fx2_subcycle;
	end
	always @(posedge clk or posedge reset)
		if (reset)
			fx3_instruction_valid <= 1'sb0;
		else
			fx3_instruction_valid <= fx2_instruction_valid;
endmodule
module fp_execute_stage4 (
	clk,
	reset,
	fx3_mask_value,
	fx3_instruction_valid,
	fx3_instruction,
	fx3_thread_idx,
	fx3_subcycle,
	fx3_result_inf,
	fx3_result_nan,
	fx3_equal,
	fx3_ftoi_lshift,
	fx3_add_significand,
	fx3_add_exponent,
	fx3_add_result_sign,
	fx3_logical_subtract,
	fx3_significand_product,
	fx3_mul_exponent,
	fx3_mul_underflow,
	fx3_mul_sign,
	fx4_instruction_valid,
	fx4_instruction,
	fx4_mask_value,
	fx4_thread_idx,
	fx4_subcycle,
	fx4_result_inf,
	fx4_result_nan,
	fx4_equal,
	fx4_add_exponent,
	fx4_add_significand,
	fx4_add_result_sign,
	fx4_logical_subtract,
	fx4_norm_shift,
	fx4_significand_product,
	fx4_mul_exponent,
	fx4_mul_underflow,
	fx4_mul_sign
);
	reg _sv2v_0;
	input clk;
	input reset;
	localparam defines_NUM_VECTOR_LANES = 16;
	input wire [15:0] fx3_mask_value;
	input fx3_instruction_valid;
	input wire [141:0] fx3_instruction;
	input wire [1:0] fx3_thread_idx;
	input wire [3:0] fx3_subcycle;
	input [15:0] fx3_result_inf;
	input [15:0] fx3_result_nan;
	input [15:0] fx3_equal;
	input [95:0] fx3_ftoi_lshift;
	input wire [511:0] fx3_add_significand;
	input [127:0] fx3_add_exponent;
	input [15:0] fx3_add_result_sign;
	input [15:0] fx3_logical_subtract;
	input [1023:0] fx3_significand_product;
	input [127:0] fx3_mul_exponent;
	input [15:0] fx3_mul_underflow;
	input [15:0] fx3_mul_sign;
	output reg fx4_instruction_valid;
	output reg [141:0] fx4_instruction;
	output reg [15:0] fx4_mask_value;
	output reg [1:0] fx4_thread_idx;
	output reg [3:0] fx4_subcycle;
	output reg [15:0] fx4_result_inf;
	output reg [15:0] fx4_result_nan;
	output reg [15:0] fx4_equal;
	output reg [127:0] fx4_add_exponent;
	output reg [511:0] fx4_add_significand;
	output reg [15:0] fx4_add_result_sign;
	output reg [15:0] fx4_logical_subtract;
	output reg [95:0] fx4_norm_shift;
	output reg [1023:0] fx4_significand_product;
	output reg [127:0] fx4_mul_exponent;
	output reg [15:0] fx4_mul_underflow;
	output reg [15:0] fx4_mul_sign;
	wire ftoi;
	assign ftoi = fx3_instruction[70-:6] == 6'b011011;
	genvar _gv_lane_idx_4;
	generate
		for (_gv_lane_idx_4 = 0; _gv_lane_idx_4 < defines_NUM_VECTOR_LANES; _gv_lane_idx_4 = _gv_lane_idx_4 + 1) begin : lane_logic_gen
			localparam lane_idx = _gv_lane_idx_4;
			reg [5:0] leading_zeroes;
			always @(*) begin
				if (_sv2v_0)
					;
				leading_zeroes = 0;
				(* full_case, parallel_case *)
				casez (fx3_add_significand[lane_idx * 32+:32])
					32'b1zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz: leading_zeroes = 0;
					32'b01zzzzzzzzzzzzzzzzzzzzzzzzzzzzzz: leading_zeroes = 1;
					32'b001zzzzzzzzzzzzzzzzzzzzzzzzzzzzz: leading_zeroes = 2;
					32'b0001zzzzzzzzzzzzzzzzzzzzzzzzzzzz: leading_zeroes = 3;
					32'b00001zzzzzzzzzzzzzzzzzzzzzzzzzzz: leading_zeroes = 4;
					32'b000001zzzzzzzzzzzzzzzzzzzzzzzzzz: leading_zeroes = 5;
					32'b0000001zzzzzzzzzzzzzzzzzzzzzzzzz: leading_zeroes = 6;
					32'b00000001zzzzzzzzzzzzzzzzzzzzzzzz: leading_zeroes = 7;
					32'b000000001zzzzzzzzzzzzzzzzzzzzzzz: leading_zeroes = 8;
					32'b0000000001zzzzzzzzzzzzzzzzzzzzzz: leading_zeroes = 9;
					32'b00000000001zzzzzzzzzzzzzzzzzzzzz: leading_zeroes = 10;
					32'b000000000001zzzzzzzzzzzzzzzzzzzz: leading_zeroes = 11;
					32'b0000000000001zzzzzzzzzzzzzzzzzzz: leading_zeroes = 12;
					32'b00000000000001zzzzzzzzzzzzzzzzzz: leading_zeroes = 13;
					32'b000000000000001zzzzzzzzzzzzzzzzz: leading_zeroes = 14;
					32'b0000000000000001zzzzzzzzzzzzzzzz: leading_zeroes = 15;
					32'b00000000000000001zzzzzzzzzzzzzzz: leading_zeroes = 16;
					32'b000000000000000001zzzzzzzzzzzzzz: leading_zeroes = 17;
					32'b0000000000000000001zzzzzzzzzzzzz: leading_zeroes = 18;
					32'b00000000000000000001zzzzzzzzzzzz: leading_zeroes = 19;
					32'b000000000000000000001zzzzzzzzzzz: leading_zeroes = 20;
					32'b0000000000000000000001zzzzzzzzzz: leading_zeroes = 21;
					32'b00000000000000000000001zzzzzzzzz: leading_zeroes = 22;
					32'b000000000000000000000001zzzzzzzz: leading_zeroes = 23;
					32'b0000000000000000000000001zzzzzzz: leading_zeroes = 24;
					32'b00000000000000000000000001zzzzzz: leading_zeroes = 25;
					32'b000000000000000000000000001zzzzz: leading_zeroes = 26;
					32'b0000000000000000000000000001zzzz: leading_zeroes = 27;
					32'b00000000000000000000000000001zzz: leading_zeroes = 28;
					32'b000000000000000000000000000001zz: leading_zeroes = 29;
					32'b0000000000000000000000000000001z: leading_zeroes = 30;
					32'b00000000000000000000000000000001: leading_zeroes = 31;
					32'b00000000000000000000000000000000: leading_zeroes = 32;
					default: leading_zeroes = 0;
				endcase
			end
			always @(posedge clk) begin
				fx4_add_significand[lane_idx * 32+:32] <= fx3_add_significand[lane_idx * 32+:32];
				fx4_norm_shift[lane_idx * 6+:6] <= (ftoi ? fx3_ftoi_lshift[lane_idx * 6+:6] : leading_zeroes);
				fx4_add_exponent[lane_idx * 8+:8] <= fx3_add_exponent[lane_idx * 8+:8];
				fx4_add_result_sign[lane_idx] <= fx3_add_result_sign[lane_idx];
				fx4_logical_subtract[lane_idx] <= fx3_logical_subtract[lane_idx];
				fx4_significand_product[lane_idx * 64+:64] <= fx3_significand_product[lane_idx * 64+:64];
				fx4_mul_exponent[lane_idx * 8+:8] <= fx3_mul_exponent[lane_idx * 8+:8];
				fx4_mul_underflow[lane_idx] <= fx3_mul_underflow[lane_idx];
				fx4_mul_sign[lane_idx] <= fx3_mul_sign[lane_idx];
				fx4_result_inf[lane_idx] <= fx3_result_inf[lane_idx];
				fx4_result_nan[lane_idx] <= fx3_result_nan[lane_idx];
				fx4_equal[lane_idx] <= fx3_equal[lane_idx];
			end
		end
	endgenerate
	always @(posedge clk) begin
		fx4_instruction <= fx3_instruction;
		fx4_mask_value <= fx3_mask_value;
		fx4_thread_idx <= fx3_thread_idx;
		fx4_subcycle <= fx3_subcycle;
	end
	always @(posedge clk or posedge reset)
		if (reset)
			fx4_instruction_valid <= 1'sb0;
		else
			fx4_instruction_valid <= fx3_instruction_valid;
	initial _sv2v_0 = 0;
endmodule
module fp_execute_stage5 (
	clk,
	reset,
	fx4_mask_value,
	fx4_instruction_valid,
	fx4_instruction,
	fx4_thread_idx,
	fx4_subcycle,
	fx4_result_inf,
	fx4_result_nan,
	fx4_equal,
	fx4_add_exponent,
	fx4_add_significand,
	fx4_add_result_sign,
	fx4_logical_subtract,
	fx4_norm_shift,
	fx4_significand_product,
	fx4_mul_exponent,
	fx4_mul_underflow,
	fx4_mul_sign,
	fx5_instruction_valid,
	fx5_instruction,
	fx5_mask_value,
	fx5_thread_idx,
	fx5_subcycle,
	fx5_result
);
	reg _sv2v_0;
	input clk;
	input reset;
	localparam defines_NUM_VECTOR_LANES = 16;
	input wire [15:0] fx4_mask_value;
	input fx4_instruction_valid;
	input wire [141:0] fx4_instruction;
	input wire [1:0] fx4_thread_idx;
	input wire [3:0] fx4_subcycle;
	input [15:0] fx4_result_inf;
	input [15:0] fx4_result_nan;
	input [15:0] fx4_equal;
	input [127:0] fx4_add_exponent;
	input wire [511:0] fx4_add_significand;
	input [15:0] fx4_add_result_sign;
	input [15:0] fx4_logical_subtract;
	input [95:0] fx4_norm_shift;
	input [1023:0] fx4_significand_product;
	input [127:0] fx4_mul_exponent;
	input [15:0] fx4_mul_underflow;
	input [15:0] fx4_mul_sign;
	output reg fx5_instruction_valid;
	output reg [141:0] fx5_instruction;
	output reg [15:0] fx5_mask_value;
	output reg [1:0] fx5_thread_idx;
	output reg [3:0] fx5_subcycle;
	output reg [511:0] fx5_result;
	wire fmul;
	wire imull;
	wire imulh;
	wire ftoi;
	assign fmul = fx4_instruction[70-:6] == 6'b100010;
	assign imull = fx4_instruction[70-:6] == 6'b000111;
	assign imulh = (fx4_instruction[70-:6] == 6'b001000) || (fx4_instruction[70-:6] == 6'b011111);
	assign ftoi = fx4_instruction[70-:6] == 6'b011011;
	genvar _gv_lane_idx_5;
	localparam defines_FLOAT32_EXP_WIDTH = 8;
	localparam defines_FLOAT32_SIG_WIDTH = 23;
	function automatic [7:0] sv2v_cast_8;
		input reg [7:0] inp;
		sv2v_cast_8 = inp;
	endfunction
	function automatic [22:0] sv2v_cast_23;
		input reg [22:0] inp;
		sv2v_cast_23 = inp;
	endfunction
	function automatic [31:0] sv2v_cast_32;
		input reg [31:0] inp;
		sv2v_cast_32 = inp;
	endfunction
	generate
		for (_gv_lane_idx_5 = 0; _gv_lane_idx_5 < defines_NUM_VECTOR_LANES; _gv_lane_idx_5 = _gv_lane_idx_5 + 1) begin : lane_logic_gen
			localparam lane_idx = _gv_lane_idx_5;
			wire [22:0] add_result_significand;
			wire [7:0] add_result_exponent;
			wire [7:0] adjusted_add_exponent;
			wire [31:0] shifted_significand;
			wire add_subnormal;
			reg [31:0] add_result;
			wire add_round;
			wire add_overflow;
			wire mul_normalize_shift;
			wire [22:0] mul_normalized_significand;
			wire [22:0] mul_rounded_significand;
			reg [31:0] fmul_result;
			reg [7:0] mul_exponent;
			wire mul_guard;
			wire mul_round;
			wire [21:0] mul_sticky_bits;
			wire mul_sticky;
			wire mul_round_tie;
			wire mul_round_up;
			wire mul_do_round;
			reg compare_result;
			wire sum_zero;
			wire mul_hidden_bit;
			wire mul_round_overflow;
			assign adjusted_add_exponent = (fx4_add_exponent[lane_idx * 8+:8] - sv2v_cast_8(fx4_norm_shift[lane_idx * 6+:6])) + 8'sd8;
			assign add_subnormal = (fx4_add_exponent[lane_idx * 8+:8] == 0) || (fx4_add_significand[lane_idx * 32+:32] == 0);
			assign shifted_significand = fx4_add_significand[lane_idx * 32+:32] << fx4_norm_shift[lane_idx * 6+:6];
			assign add_round = (shifted_significand[7] && shifted_significand[8]) && !fx4_logical_subtract[lane_idx];
			assign add_result_significand = (add_subnormal ? fx4_add_significand[(lane_idx * 32) + 22-:23] : shifted_significand[30:8] + sv2v_cast_23(add_round));
			assign add_result_exponent = (add_subnormal ? {8 {1'sb0}} : adjusted_add_exponent);
			assign add_overflow = (add_result_exponent == 8'hff) && !fx4_result_nan[lane_idx];
			always @(*) begin
				if (_sv2v_0)
					;
				if (fx4_result_inf[lane_idx] || add_overflow)
					add_result = {fx4_add_result_sign[lane_idx], 31'h7f800000};
				else if (fx4_result_nan[lane_idx])
					add_result = 32'h7fffffff;
				else if ((add_result_significand == 0) && add_subnormal)
					add_result = 0;
				else
					add_result = {fx4_add_result_sign[lane_idx], add_result_exponent, add_result_significand};
			end
			assign sum_zero = add_subnormal && (add_result_significand == 0);
			always @(*) begin
				if (_sv2v_0)
					;
				(* full_case, parallel_case *)
				case (fx4_instruction[70-:6])
					6'b101100: compare_result = (!fx4_add_result_sign[lane_idx] && !fx4_equal[lane_idx]) && !fx4_result_nan[lane_idx];
					6'b101101: compare_result = (!fx4_add_result_sign[lane_idx] || fx4_equal[lane_idx]) && !fx4_result_nan[lane_idx];
					6'b101110: compare_result = (fx4_add_result_sign[lane_idx] && !fx4_equal[lane_idx]) && !fx4_result_nan[lane_idx];
					6'b101111: compare_result = (fx4_add_result_sign[lane_idx] || fx4_equal[lane_idx]) && !fx4_result_nan[lane_idx];
					6'b110000: compare_result = fx4_equal[lane_idx] && !fx4_result_nan[lane_idx];
					6'b110001: compare_result = !fx4_equal[lane_idx] || fx4_result_nan[lane_idx];
					default: compare_result = 0;
				endcase
			end
			assign mul_normalize_shift = !fx4_significand_product[(lane_idx * 64) + 47];
			assign {mul_normalized_significand, mul_guard, mul_round, mul_sticky_bits} = (mul_normalize_shift ? {fx4_significand_product[(lane_idx * 64) + 45-:46], 1'b0} : fx4_significand_product[(lane_idx * 64) + 46-:47]);
			assign mul_sticky = |mul_sticky_bits;
			assign mul_round_tie = mul_guard && !(mul_round || mul_sticky);
			assign mul_round_up = mul_guard && (mul_round || mul_sticky);
			assign mul_do_round = mul_round_up || (mul_round_tie && mul_normalized_significand[0]);
			assign mul_rounded_significand = mul_normalized_significand + sv2v_cast_23(mul_do_round);
			assign mul_hidden_bit = (mul_normalize_shift ? fx4_significand_product[(lane_idx * 64) + 46] : 1'b1);
			assign mul_round_overflow = mul_do_round && (mul_rounded_significand == 0);
			always @(*) begin
				if (_sv2v_0)
					;
				if (!mul_hidden_bit)
					mul_exponent = 0;
				else if (mul_normalize_shift && !mul_round_overflow)
					mul_exponent = fx4_mul_exponent[lane_idx * 8+:8];
				else
					mul_exponent = fx4_mul_exponent[lane_idx * 8+:8] + 8'sd1;
			end
			always @(*) begin
				if (_sv2v_0)
					;
				if (fx4_result_inf[lane_idx])
					fmul_result = {fx4_mul_sign[lane_idx], 31'h7f800000};
				else if (fx4_result_nan[lane_idx])
					fmul_result = 32'h7fffffff;
				else
					fmul_result = {fx4_mul_sign[lane_idx], mul_exponent, mul_rounded_significand};
			end
			always @(posedge clk)
				if (ftoi) begin
					if (fx4_result_nan[lane_idx])
						fx5_result[lane_idx * 32+:32] <= 32'h80000000;
					else
						fx5_result[lane_idx * 32+:32] <= shifted_significand;
				end
				else if (fx4_instruction[13])
					fx5_result[lane_idx * 32+:32] <= sv2v_cast_32(compare_result);
				else if (imull)
					fx5_result[lane_idx * 32+:32] <= fx4_significand_product[(lane_idx * 64) + 31-:32];
				else if (imulh)
					fx5_result[lane_idx * 32+:32] <= fx4_significand_product[(lane_idx * 64) + 63-:32];
				else if (fmul)
					fx5_result[lane_idx * 32+:32] <= (fx4_mul_underflow[lane_idx] ? 32'h00000000 : fmul_result);
				else
					fx5_result[lane_idx * 32+:32] <= add_result;
		end
	endgenerate
	always @(posedge clk) begin
		fx5_instruction <= fx4_instruction;
		fx5_mask_value <= fx4_mask_value;
		fx5_thread_idx <= fx4_thread_idx;
		fx5_subcycle <= fx4_subcycle;
	end
	always @(posedge clk or posedge reset)
		if (reset)
			fx5_instruction_valid <= 1'sb0;
		else
			fx5_instruction_valid <= fx4_instruction_valid;
	initial _sv2v_0 = 0;
endmodule
module idx_to_oh (
	one_hot,
	index
);
	reg _sv2v_0;
	parameter NUM_SIGNALS = 4;
	parameter DIRECTION = "LSB0";
	parameter INDEX_WIDTH = $clog2(NUM_SIGNALS);
	output reg [NUM_SIGNALS - 1:0] one_hot;
	input [INDEX_WIDTH - 1:0] index;
	function automatic [31:0] sv2v_cast_32;
		input reg [31:0] inp;
		sv2v_cast_32 = inp;
	endfunction
	always @(*) begin : convert
		if (_sv2v_0)
			;
		one_hot = 0;
		if (DIRECTION == "LSB0")
			one_hot[index] = 1'b1;
		else
			one_hot[(NUM_SIGNALS - sv2v_cast_32(index)) - 1] = 1'b1;
	end
	initial _sv2v_0 = 0;
endmodule
module ifetch_data_stage (
	clk,
	reset,
	ift_instruction_requested,
	ift_pc_paddr,
	ift_pc_vaddr,
	ift_thread_idx,
	ift_tlb_hit,
	ift_tlb_present,
	ift_tlb_executable,
	ift_tlb_supervisor,
	ift_tag,
	ift_valid,
	ifd_update_lru_en,
	ifd_update_lru_way,
	ifd_near_miss,
	l2i_idata_update_en,
	l2i_idata_update_way,
	l2i_idata_update_set,
	l2i_idata_update_data,
	l2i_itag_update_en,
	l2i_itag_update_set,
	l2i_itag_update_tag,
	ifd_cache_miss,
	ifd_cache_miss_paddr,
	ifd_cache_miss_thread_idx,
	cr_supervisor_en,
	ifd_instruction,
	ifd_instruction_valid,
	ifd_pc,
	ifd_thread_idx,
	ifd_alignment_fault,
	ifd_tlb_miss,
	ifd_supervisor_fault,
	ifd_page_fault,
	ifd_executable_fault,
	ifd_inst_injected,
	wb_rollback_en,
	wb_rollback_thread_idx,
	ifd_perf_icache_hit,
	ifd_perf_icache_miss,
	ifd_perf_itlb_miss,
	core_selected_debug,
	ocd_halt,
	ocd_inject_inst,
	ocd_inject_en,
	ocd_thread
);
	input clk;
	input reset;
	input ift_instruction_requested;
	localparam defines_NUM_VECTOR_LANES = 16;
	localparam defines_CACHE_LINE_BYTES = 64;
	localparam defines_CACHE_LINE_OFFSET_WIDTH = 6;
	localparam defines_ICACHE_TAG_BITS = 20;
	input wire [31:0] ift_pc_paddr;
	input wire [31:0] ift_pc_vaddr;
	input wire [1:0] ift_thread_idx;
	input ift_tlb_hit;
	input ift_tlb_present;
	input ift_tlb_executable;
	input ift_tlb_supervisor;
	input wire [79:0] ift_tag;
	input [0:3] ift_valid;
	output wire ifd_update_lru_en;
	output wire [1:0] ifd_update_lru_way;
	output wire ifd_near_miss;
	input l2i_idata_update_en;
	input wire [1:0] l2i_idata_update_way;
	input wire [5:0] l2i_idata_update_set;
	localparam defines_CACHE_LINE_BITS = 512;
	input wire [511:0] l2i_idata_update_data;
	input [3:0] l2i_itag_update_en;
	input wire [5:0] l2i_itag_update_set;
	input wire [19:0] l2i_itag_update_tag;
	output wire ifd_cache_miss;
	output wire [25:0] ifd_cache_miss_paddr;
	output wire [1:0] ifd_cache_miss_thread_idx;
	input wire [0:3] cr_supervisor_en;
	output wire [31:0] ifd_instruction;
	output reg ifd_instruction_valid;
	output reg [31:0] ifd_pc;
	output reg [1:0] ifd_thread_idx;
	output reg ifd_alignment_fault;
	output reg ifd_tlb_miss;
	output reg ifd_supervisor_fault;
	output reg ifd_page_fault;
	output reg ifd_executable_fault;
	output reg ifd_inst_injected;
	input wb_rollback_en;
	input wire [1:0] wb_rollback_thread_idx;
	output reg ifd_perf_icache_hit;
	output reg ifd_perf_icache_miss;
	output reg ifd_perf_itlb_miss;
	input core_selected_debug;
	input ocd_halt;
	input wire [31:0] ocd_inject_inst;
	input wire ocd_inject_en;
	input wire [1:0] ocd_thread;
	wire cache_hit;
	wire [3:0] way_hit_oh;
	wire [1:0] way_hit_idx;
	wire [511:0] fetched_cache_line;
	wire [31:0] fetched_word;
	localparam defines_CACHE_LINE_WORDS = 16;
	wire [3:0] cache_lane_idx;
	wire alignment_fault;
	wire squash_instruction;
	reg ocd_halt_latched;
	assign squash_instruction = wb_rollback_en && (wb_rollback_thread_idx == ift_thread_idx);
	genvar _gv_way_idx_3;
	generate
		for (_gv_way_idx_3 = 0; _gv_way_idx_3 < 4; _gv_way_idx_3 = _gv_way_idx_3 + 1) begin : hit_check_gen
			localparam way_idx = _gv_way_idx_3;
			assign way_hit_oh[way_idx] = (ift_pc_paddr[31-:20] == ift_tag[(3 - way_idx) * defines_ICACHE_TAG_BITS+:defines_ICACHE_TAG_BITS]) && ift_valid[way_idx];
		end
	endgenerate
	assign cache_hit = |way_hit_oh && ift_tlb_hit;
	oh_to_idx #(.NUM_SIGNALS(4)) oh_to_idx_hit_way(
		.one_hot(way_hit_oh),
		.index(way_hit_idx)
	);
	assign ifd_near_miss = ((((!cache_hit && ift_tlb_hit) && ift_instruction_requested) && |l2i_itag_update_en) && (l2i_itag_update_set == ift_pc_paddr[11-:6])) && (l2i_itag_update_tag == ift_pc_paddr[31-:20]);
	assign ifd_cache_miss = (((!cache_hit && ift_tlb_hit) && ift_instruction_requested) && !ifd_near_miss) && !squash_instruction;
	assign ifd_cache_miss_paddr = {ift_pc_paddr[31-:20], ift_pc_paddr[11-:6]};
	assign ifd_cache_miss_thread_idx = ift_thread_idx;
	assign alignment_fault = ift_pc_paddr[1:0] != 0;
	fakeram_1r1w_512x256 #(
		.DATA_WIDTH(defines_CACHE_LINE_BITS),
		.SIZE(256),
		.READ_DURING_WRITE("NEW_DATA")
	) sram_l1i_data(
		.read_en(cache_hit && ift_instruction_requested),
		.read_addr({way_hit_idx, ift_pc_paddr[11-:6]}),
		.read_data(fetched_cache_line),
		.write_en(l2i_idata_update_en),
		.write_addr({l2i_idata_update_way, l2i_idata_update_set}),
		.write_data(l2i_idata_update_data),
		.*
	);
	assign cache_lane_idx = ~ifd_pc[5:2];
	assign fetched_word = fetched_cache_line[32 * cache_lane_idx+:32];
	assign ifd_instruction = (ocd_halt_latched ? ocd_inject_inst : {fetched_word[7:0], fetched_word[15:8], fetched_word[23:16], fetched_word[31:24]});
	assign ifd_update_lru_en = cache_hit && ift_instruction_requested;
	assign ifd_update_lru_way = way_hit_idx;
	always @(posedge clk) begin
		ifd_pc <= ift_pc_vaddr;
		ifd_thread_idx <= (ocd_halt ? ocd_thread : ift_thread_idx);
	end
	always @(posedge clk or posedge reset)
		if (reset) begin
			ifd_alignment_fault <= 1'sb0;
			ifd_executable_fault <= 1'sb0;
			ifd_inst_injected <= 1'sb0;
			ifd_instruction_valid <= 1'sb0;
			ifd_page_fault <= 1'sb0;
			ifd_perf_icache_hit <= 1'sb0;
			ifd_perf_icache_miss <= 1'sb0;
			ifd_perf_itlb_miss <= 1'sb0;
			ifd_supervisor_fault <= 1'sb0;
			ifd_tlb_miss <= 1'sb0;
			ocd_halt_latched <= 1'sb0;
		end
		else begin
			ocd_halt_latched <= ocd_halt;
			if (ocd_halt) begin
				ifd_instruction_valid <= ocd_inject_en && core_selected_debug;
				ifd_inst_injected <= 1;
				ifd_alignment_fault <= 0;
				ifd_supervisor_fault <= 0;
				ifd_tlb_miss <= 0;
				ifd_page_fault <= 0;
				ifd_executable_fault <= 0;
			end
			else begin
				ifd_instruction_valid <= ((ift_instruction_requested && !squash_instruction) && cache_hit) && ift_tlb_hit;
				ifd_inst_injected <= 0;
				ifd_alignment_fault <= (ift_instruction_requested && !squash_instruction) && alignment_fault;
				ifd_supervisor_fault <= ((((ift_instruction_requested && !squash_instruction) && ift_tlb_hit) && ift_tlb_present) && ift_tlb_supervisor) && !cr_supervisor_en[ift_thread_idx];
				ifd_tlb_miss <= (ift_instruction_requested && !squash_instruction) && !ift_tlb_hit;
				ifd_page_fault <= ((ift_instruction_requested && !squash_instruction) && ift_tlb_hit) && !ift_tlb_present;
				ifd_executable_fault <= (((ift_instruction_requested && !squash_instruction) && ift_tlb_hit) && ift_tlb_present) && !ift_tlb_executable;
				ifd_perf_icache_hit <= cache_hit && ift_instruction_requested;
				ifd_perf_icache_miss <= ((!cache_hit && ift_tlb_hit) && ift_instruction_requested) && !squash_instruction;
				ifd_perf_itlb_miss <= ift_instruction_requested && !ift_tlb_hit;
			end
		end
endmodule
module ifetch_tag_stage (
	clk,
	reset,
	ifd_update_lru_en,
	ifd_update_lru_way,
	ifd_cache_miss,
	ifd_near_miss,
	ifd_cache_miss_thread_idx,
	ift_instruction_requested,
	ift_pc_paddr,
	ift_pc_vaddr,
	ift_thread_idx,
	ift_tlb_hit,
	ift_tlb_present,
	ift_tlb_executable,
	ift_tlb_supervisor,
	ift_tag,
	ift_valid,
	l2i_icache_lru_fill_en,
	l2i_icache_lru_fill_set,
	l2i_itag_update_en,
	l2i_itag_update_set,
	l2i_itag_update_tag,
	l2i_itag_update_valid,
	l2i_icache_wake_bitmap,
	ift_fill_lru,
	cr_mmu_en,
	cr_current_asid,
	dt_invalidate_tlb_en,
	dt_invalidate_tlb_all_en,
	dt_update_itlb_asid,
	dt_update_itlb_vpage_idx,
	dt_update_itlb_en,
	dt_update_itlb_supervisor,
	dt_update_itlb_global,
	dt_update_itlb_present,
	dt_update_itlb_executable,
	dt_update_itlb_ppage_idx,
	wb_rollback_en,
	wb_rollback_thread_idx,
	wb_rollback_pc,
	ts_fetch_en,
	ocd_halt,
	ocd_thread
);
	reg _sv2v_0;
	parameter RESET_PC = 0;
	input clk;
	input reset;
	input ifd_update_lru_en;
	input wire [1:0] ifd_update_lru_way;
	input ifd_cache_miss;
	input ifd_near_miss;
	input wire [1:0] ifd_cache_miss_thread_idx;
	output reg ift_instruction_requested;
	localparam defines_NUM_VECTOR_LANES = 16;
	localparam defines_CACHE_LINE_BYTES = 64;
	localparam defines_CACHE_LINE_OFFSET_WIDTH = 6;
	localparam defines_ICACHE_TAG_BITS = 20;
	output wire [31:0] ift_pc_paddr;
	output wire [31:0] ift_pc_vaddr;
	output reg [1:0] ift_thread_idx;
	output reg ift_tlb_hit;
	output reg ift_tlb_present;
	output reg ift_tlb_executable;
	output reg ift_tlb_supervisor;
	output wire [79:0] ift_tag;
	output reg [0:3] ift_valid;
	input l2i_icache_lru_fill_en;
	input wire [5:0] l2i_icache_lru_fill_set;
	input [3:0] l2i_itag_update_en;
	input wire [5:0] l2i_itag_update_set;
	input wire [19:0] l2i_itag_update_tag;
	input l2i_itag_update_valid;
	input wire [3:0] l2i_icache_wake_bitmap;
	output wire [1:0] ift_fill_lru;
	input [0:3] cr_mmu_en;
	localparam defines_ASID_WIDTH = 8;
	input [31:0] cr_current_asid;
	input dt_invalidate_tlb_en;
	input dt_invalidate_tlb_all_en;
	input [7:0] dt_update_itlb_asid;
	localparam defines_PAGE_SIZE = 'h1000;
	localparam defines_PAGE_NUM_BITS = 32 - $clog2('h1000);
	input wire [defines_PAGE_NUM_BITS - 1:0] dt_update_itlb_vpage_idx;
	input dt_update_itlb_en;
	input dt_update_itlb_supervisor;
	input dt_update_itlb_global;
	input dt_update_itlb_present;
	input dt_update_itlb_executable;
	input wire [defines_PAGE_NUM_BITS - 1:0] dt_update_itlb_ppage_idx;
	input wb_rollback_en;
	input wire [1:0] wb_rollback_thread_idx;
	input wire [31:0] wb_rollback_pc;
	input wire [3:0] ts_fetch_en;
	input ocd_halt;
	input wire [1:0] ocd_thread;
	reg [31:0] next_program_counter [0:3];
	wire [1:0] selected_thread_idx;
	reg [31:0] last_selected_pc;
	wire [31:0] pc_to_fetch;
	wire [3:0] can_fetch_thread_bitmap;
	wire [3:0] selected_thread_oh;
	reg [3:0] last_selected_thread_oh;
	reg [3:0] icache_wait_threads;
	wire [3:0] icache_wait_threads_nxt;
	wire [3:0] cache_miss_thread_oh;
	wire [3:0] thread_sleep_mask_oh;
	wire cache_fetch_en;
	wire [defines_PAGE_NUM_BITS - 1:0] tlb_ppage_idx;
	reg [defines_PAGE_NUM_BITS - 1:0] ppage_idx;
	wire tlb_hit;
	wire tlb_supervisor;
	wire tlb_present;
	wire tlb_executable;
	reg [defines_PAGE_NUM_BITS - 1:0] request_vpage_idx;
	reg [7:0] request_asid;
	assign can_fetch_thread_bitmap = ts_fetch_en & ~icache_wait_threads;
	assign cache_fetch_en = (((|can_fetch_thread_bitmap && !dt_update_itlb_en) && !dt_invalidate_tlb_en) && !dt_invalidate_tlb_all_en) && !ocd_halt;
	rr_arbiter #(.NUM_REQUESTERS(4)) thread_select_arbiter(
		.request(can_fetch_thread_bitmap),
		.update_lru(cache_fetch_en),
		.grant_oh(selected_thread_oh),
		.clk(clk),
		.reset(reset)
	);
	oh_to_idx #(.NUM_SIGNALS(4)) oh_to_idx_selected_thread(
		.one_hot(selected_thread_oh),
		.index(selected_thread_idx)
	);
	genvar _gv_thread_idx_3;
	function automatic [1:0] sv2v_cast_2;
		input reg [1:0] inp;
		sv2v_cast_2 = inp;
	endfunction
	generate
		for (_gv_thread_idx_3 = 0; _gv_thread_idx_3 < 4; _gv_thread_idx_3 = _gv_thread_idx_3 + 1) begin : pc_logic_gen
			localparam thread_idx = _gv_thread_idx_3;
			always @(posedge clk or posedge reset)
				if (reset)
					next_program_counter[thread_idx] <= RESET_PC;
				else if (wb_rollback_en && (wb_rollback_thread_idx == sv2v_cast_2(thread_idx)))
					next_program_counter[thread_idx] <= wb_rollback_pc;
				else if ((ifd_cache_miss || ifd_near_miss) && last_selected_thread_oh[thread_idx])
					next_program_counter[thread_idx] <= next_program_counter[thread_idx] - 4;
				else if (selected_thread_oh[thread_idx] && cache_fetch_en)
					next_program_counter[thread_idx] <= next_program_counter[thread_idx] + 4;
		end
	endgenerate
	assign pc_to_fetch = next_program_counter[(ocd_halt ? ocd_thread : selected_thread_idx)];
	genvar _gv_way_idx_4;
	generate
		for (_gv_way_idx_4 = 0; _gv_way_idx_4 < 4; _gv_way_idx_4 = _gv_way_idx_4 + 1) begin : way_tag_gen
			localparam way_idx = _gv_way_idx_4;
			reg line_valid [0:63];
			fakeram_1r1w_20x64 #(
				.DATA_WIDTH(defines_ICACHE_TAG_BITS),
				.SIZE(64),
				.READ_DURING_WRITE("NEW_DATA")
			) sram_tags(
				.read_en(cache_fetch_en),
				.read_addr(pc_to_fetch[11-:6]),
				.read_data(ift_tag[(3 - way_idx) * defines_ICACHE_TAG_BITS+:defines_ICACHE_TAG_BITS]),
				.write_en(l2i_itag_update_en[way_idx]),
				.write_addr(l2i_itag_update_set),
				.write_data(l2i_itag_update_tag),
				.*
			);
			always @(posedge clk or posedge reset)
				if (reset) begin : sv2v_autoblock_1
					reg signed [31:0] set_idx;
					for (set_idx = 0; set_idx < 64; set_idx = set_idx + 1)
						line_valid[set_idx] <= 0;
				end
				else if (l2i_itag_update_en[way_idx])
					line_valid[l2i_itag_update_set] <= l2i_itag_update_valid;
			always @(posedge clk)
				if (l2i_itag_update_en[way_idx] && (l2i_itag_update_set == pc_to_fetch[11-:6]))
					ift_valid[way_idx] <= l2i_itag_update_valid;
				else
					ift_valid[way_idx] <= line_valid[pc_to_fetch[11-:6]];
		end
	endgenerate
	always @(*) begin
		if (_sv2v_0)
			;
		if (cache_fetch_en) begin
			request_vpage_idx = pc_to_fetch[31-:defines_PAGE_NUM_BITS];
			request_asid = cr_current_asid[(3 - selected_thread_idx) * 8+:8];
		end
		else begin
			request_vpage_idx = dt_update_itlb_vpage_idx;
			request_asid = dt_update_itlb_asid;
		end
	end
	tlb #(
		.NUM_ENTRIES(64),
		.NUM_WAYS(4)
	) itlb(
		.lookup_en(cache_fetch_en),
		.update_en(dt_update_itlb_en),
		.update_present(dt_update_itlb_present),
		.update_exe_writable(dt_update_itlb_executable),
		.update_supervisor(dt_update_itlb_supervisor),
		.update_global(dt_update_itlb_global),
		.invalidate_en(dt_invalidate_tlb_en),
		.invalidate_all_en(dt_invalidate_tlb_all_en),
		.update_ppage_idx(dt_update_itlb_ppage_idx),
		.lookup_ppage_idx(tlb_ppage_idx),
		.lookup_hit(tlb_hit),
		.lookup_exe_writable(tlb_executable),
		.lookup_present(tlb_present),
		.lookup_supervisor(tlb_supervisor),
		.clk(clk),
		.reset(reset),
		.request_vpage_idx(request_vpage_idx),
		.request_asid(request_asid)
	);
	always @(*) begin
		if (_sv2v_0)
			;
		if (cr_mmu_en[ift_thread_idx]) begin
			ift_tlb_hit = tlb_hit;
			ift_tlb_present = tlb_present;
			ift_tlb_executable = tlb_executable;
			ift_tlb_supervisor = tlb_supervisor;
			ppage_idx = tlb_ppage_idx;
		end
		else begin
			ift_tlb_hit = 1;
			ift_tlb_present = 1;
			ift_tlb_executable = 1;
			ift_tlb_supervisor = 0;
			ppage_idx = last_selected_pc[31-:defines_PAGE_NUM_BITS];
		end
	end
	cache_lru #(
		.NUM_WAYS(4),
		.NUM_SETS(64)
	) cache_lru(
		.fill_en(l2i_icache_lru_fill_en),
		.fill_set(l2i_icache_lru_fill_set),
		.fill_way(ift_fill_lru),
		.access_en(cache_fetch_en),
		.access_set(pc_to_fetch[11-:6]),
		.update_en(ifd_update_lru_en),
		.update_way(ifd_update_lru_way),
		.clk(clk),
		.reset(reset)
	);
	idx_to_oh #(.NUM_SIGNALS(4)) idx_to_oh_miss_thread(
		.one_hot(cache_miss_thread_oh),
		.index(ifd_cache_miss_thread_idx)
	);
	assign thread_sleep_mask_oh = cache_miss_thread_oh & {4 {ifd_cache_miss}};
	assign icache_wait_threads_nxt = (icache_wait_threads | thread_sleep_mask_oh) & ~l2i_icache_wake_bitmap;
	always @(posedge clk or posedge reset)
		if (reset) begin
			icache_wait_threads <= 1'sb0;
			ift_instruction_requested <= 1'sb0;
		end
		else begin
			icache_wait_threads <= icache_wait_threads_nxt;
			ift_instruction_requested <= (cache_fetch_en && !((ifd_cache_miss || ifd_near_miss) && (ifd_cache_miss_thread_idx == selected_thread_idx))) && !(wb_rollback_en && (wb_rollback_thread_idx == selected_thread_idx));
		end
	always @(posedge clk) begin
		last_selected_pc <= pc_to_fetch;
		ift_thread_idx <= selected_thread_idx;
		last_selected_thread_oh <= selected_thread_oh;
	end
	assign ift_pc_paddr = {ppage_idx, last_selected_pc[31 - defines_PAGE_NUM_BITS:0]};
	assign ift_pc_vaddr = last_selected_pc;
	initial _sv2v_0 = 0;
endmodule
module instruction_decode_stage (
	clk,
	reset,
	ifd_instruction_valid,
	ifd_instruction,
	ifd_inst_injected,
	ifd_pc,
	ifd_thread_idx,
	ifd_alignment_fault,
	ifd_supervisor_fault,
	ifd_page_fault,
	ifd_executable_fault,
	ifd_tlb_miss,
	dd_load_sync_pending,
	sq_store_sync_pending,
	id_instruction,
	id_instruction_valid,
	id_thread_idx,
	ior_pending,
	cr_interrupt_en,
	cr_interrupt_pending,
	ocd_halt,
	wb_rollback_en,
	wb_rollback_thread_idx
);
	reg _sv2v_0;
	input clk;
	input reset;
	input ifd_instruction_valid;
	input wire [31:0] ifd_instruction;
	input ifd_inst_injected;
	input wire [31:0] ifd_pc;
	input wire [1:0] ifd_thread_idx;
	input ifd_alignment_fault;
	input ifd_supervisor_fault;
	input ifd_page_fault;
	input ifd_executable_fault;
	input ifd_tlb_miss;
	input wire [3:0] dd_load_sync_pending;
	input wire [3:0] sq_store_sync_pending;
	localparam defines_NUM_VECTOR_LANES = 16;
	output reg [141:0] id_instruction;
	output reg id_instruction_valid;
	output reg [1:0] id_thread_idx;
	input wire [3:0] ior_pending;
	input wire [3:0] cr_interrupt_en;
	input wire [3:0] cr_interrupt_pending;
	input ocd_halt;
	input wb_rollback_en;
	input wire [1:0] wb_rollback_thread_idx;
	localparam T = 1'b1;
	localparam F = 1'b0;
	reg [20:0] dlut_out;
	reg [141:0] decoded_instr_nxt;
	wire nop;
	wire fmt_r;
	wire fmt_i;
	wire fmt_m;
	wire getlane;
	wire compare;
	reg [5:0] alu_op;
	wire [3:0] memory_access_type;
	reg [4:0] scalar_sel2;
	wire has_trap;
	wire syscall;
	wire breakpoint;
	wire raise_interrupt;
	wire [3:0] masked_interrupt_flags;
	wire unary_arith;
	always @(*) begin
		if (_sv2v_0)
			;
		(* full_case, parallel_case *)
		casez (ifd_instruction[31:25])
			7'b110000z: dlut_out = {F, F, T, 8'h11, F, F, F, F, 4'h2, F, F};
			7'b110001z: dlut_out = {F, T, T, 8'h11, T, F, F, T, 4'h2, F, F};
			7'b110010z: dlut_out = {F, T, T, 8'h09, T, F, F, T, 4'h0, F, F};
			7'b110100z: dlut_out = {F, T, T, 8'h08, T, T, F, T, 4'h6, F, F};
			7'b110101z: dlut_out = {F, T, T, 8'h12, T, T, F, T, 4'h5, F, F};
			7'b000zzzz: dlut_out = {F, F, T, 8'h50, F, F, F, F, 4'ha, F, F};
			7'b001zzzz: dlut_out = {F, T, T, 8'h50, T, F, F, T, 4'ha, F, F};
			7'b010zzzz: dlut_out = {F, F, T, 8'hf0, F, F, F, F, 4'ha, F, F};
			7'b011zzzz: dlut_out = {F, T, T, 8'h32, T, F, F, T, 4'h9, F, F};
			7'b1000000: dlut_out = {F, F, F, 8'h93, F, F, T, F, 4'ha, F, F};
			7'b1000001: dlut_out = {F, F, F, 8'h93, F, F, T, F, 4'ha, F, F};
			7'b1000010: dlut_out = {F, F, F, 8'h93, T, F, T, F, 4'ha, F, F};
			7'b1000011: dlut_out = {F, F, F, 8'h93, F, F, T, F, 4'ha, F, F};
			7'b1000100: dlut_out = {F, F, F, 8'h93, F, F, T, F, 4'ha, F, F};
			7'b1000101: dlut_out = {F, F, T, 8'h93, F, F, T, F, 4'ha, F, F};
			7'b1000110: dlut_out = {F, F, F, 8'h93, F, F, T, F, 4'ha, F, F};
			7'b1000111: dlut_out = {F, F, F, 8'h90, F, T, T, F, 4'ha, T, F};
			7'b1001000: dlut_out = {F, F, F, 8'h72, F, T, T, F, 4'h9, T, F};
			7'b1001101: dlut_out = {F, F, F, 8'h90, T, T, T, T, 4'ha, T, F};
			7'b1001110: dlut_out = {F, F, F, 8'h72, T, T, T, T, 4'h9, T, F};
			7'b1010000: dlut_out = {F, F, T, 8'h90, T, F, F, F, 4'ha, F, F};
			7'b1010001: dlut_out = {F, F, T, 8'h90, T, F, F, F, 4'ha, F, F};
			7'b1010010: dlut_out = {F, F, T, 8'h90, T, F, F, F, 4'ha, F, F};
			7'b1010011: dlut_out = {F, F, T, 8'h90, T, F, F, F, 4'ha, F, F};
			7'b1010100: dlut_out = {F, F, T, 8'h90, T, F, F, F, 4'ha, F, F};
			7'b1010101: dlut_out = {F, F, T, 8'h90, T, F, F, F, 4'ha, F, F};
			7'b1010110: dlut_out = {F, F, T, 8'h90, T, F, F, F, 4'ha, F, F};
			7'b1010111: dlut_out = {F, T, T, 8'h90, T, F, F, F, 4'ha, F, F};
			7'b1011000: dlut_out = {F, T, T, 8'h72, T, F, F, F, 4'h9, F, F};
			7'b1011101: dlut_out = {F, T, T, 8'h90, T, T, F, T, 4'ha, F, F};
			7'b1011110: dlut_out = {F, T, T, 8'h72, T, T, F, T, 4'h9, F, F};
			7'b1110000: dlut_out = {F, F, F, 8'h73, F, F, F, F, 4'ha, F, F};
			7'b1110001: dlut_out = {F, F, F, 8'h70, F, F, F, F, 4'ha, F, F};
			7'b1110010: dlut_out = {F, F, F, 8'h70, F, F, F, F, 4'ha, F, F};
			7'b1110011: dlut_out = {F, F, F, 8'h70, F, F, F, F, 4'ha, F, F};
			7'b1110100: dlut_out = {F, F, F, 8'h60, F, F, F, F, 4'ha, F, F};
			7'b1110101: dlut_out = {F, F, F, 8'h70, F, F, F, F, 4'ha, F, F};
			7'b1110110: dlut_out = {F, F, F, 8'h60, F, F, F, F, 4'ha, F, F};
			7'b1110111: dlut_out = {F, F, F, 8'h73, F, F, F, F, 4'ha, F, F};
			7'b1111000: dlut_out = {F, F, F, 8'hb0, F, F, F, F, 4'ha, F, F};
			7'b1111001: dlut_out = {F, F, F, 8'hb0, F, F, F, F, 4'ha, F, F};
			7'b1111010: dlut_out = {F, F, F, 8'hb0, F, F, F, F, 4'ha, F, F};
			7'b1111011: dlut_out = {F, F, F, 8'hc0, F, F, F, F, 4'ha, F, F};
			7'b1111100: dlut_out = {F, F, T, 8'hc0, F, F, F, F, 4'h2, F, T};
			7'b1111110: dlut_out = {F, F, T, 8'hb0, F, F, F, F, 4'h2, F, T};
			7'b1111111: dlut_out = {F, F, T, 8'hb0, F, F, F, F, 4'h2, F, F};
			default: dlut_out = {T, F, F, 8'h00, F, F, F, F, 4'ha, F, F};
		endcase
	end
	assign fmt_r = ifd_instruction[31:29] == 3'b110;
	assign fmt_i = ifd_instruction[31] == 1'b0;
	assign fmt_m = ifd_instruction[31:30] == 2'b10;
	assign getlane = (fmt_r || fmt_i) && (alu_op == 6'b011010);
	function automatic [5:0] sv2v_cast_6;
		input reg [5:0] inp;
		sv2v_cast_6 = inp;
	endfunction
	assign syscall = fmt_i && (sv2v_cast_6(ifd_instruction[28:24]) == 6'b000010);
	assign breakpoint = fmt_r && (ifd_instruction[25:20] == 6'b111110);
	localparam defines_INSTRUCTION_NOP = 32'd0;
	assign nop = ifd_instruction == defines_INSTRUCTION_NOP;
	assign has_trap = (((((ifd_instruction_valid && (((dlut_out[20] || syscall) || breakpoint) || raise_interrupt)) || ifd_alignment_fault) || ifd_tlb_miss) || ifd_supervisor_fault) || ifd_page_fault) || ifd_executable_fault;
	always @(*) begin
		if (_sv2v_0)
			;
		if (raise_interrupt)
			decoded_instr_nxt[107-:6] = 6'h03;
		else if (ifd_tlb_miss)
			decoded_instr_nxt[107-:6] = 6'h07;
		else if (ifd_page_fault)
			decoded_instr_nxt[107-:6] = 6'h06;
		else if (ifd_supervisor_fault)
			decoded_instr_nxt[107-:6] = 6'h09;
		else if (ifd_alignment_fault)
			decoded_instr_nxt[107-:6] = 6'h05;
		else if (ifd_executable_fault)
			decoded_instr_nxt[107-:6] = 6'h0a;
		else if (dlut_out[20])
			decoded_instr_nxt[107-:6] = 6'h01;
		else if (syscall)
			decoded_instr_nxt[107-:6] = 6'h04;
		else if (breakpoint)
			decoded_instr_nxt[107-:6] = 6'h0b;
		else
			decoded_instr_nxt[107-:6] = 6'h00;
	end
	wire [1:1] sv2v_tmp_B134F;
	assign sv2v_tmp_B134F = ifd_inst_injected;
	always @(*) decoded_instr_nxt[109] = sv2v_tmp_B134F;
	assign masked_interrupt_flags = (((cr_interrupt_pending & cr_interrupt_en) & ~ior_pending) & ~dd_load_sync_pending) & ~sq_store_sync_pending;
	assign raise_interrupt = masked_interrupt_flags[ifd_thread_idx] && !ocd_halt;
	wire [1:1] sv2v_tmp_C4036;
	assign sv2v_tmp_C4036 = has_trap;
	always @(*) decoded_instr_nxt[108] = sv2v_tmp_C4036;
	assign unary_arith = (fmt_r && ((((((((alu_op == 6'b001100) || (alu_op == 6'b001110)) || (alu_op == 6'b001111)) || (alu_op == 6'b011011)) || (alu_op == 6'b011100)) || (alu_op == 6'b011101)) || (alu_op == 6'b011110)) || (alu_op == 6'b101010))) && (dlut_out[3-:2] != 2'd0);
	wire [1:1] sv2v_tmp_B589F;
	assign sv2v_tmp_B589F = (((dlut_out[14-:2] != 2'd0) && !nop) && !has_trap) && !unary_arith;
	always @(*) decoded_instr_nxt[101] = sv2v_tmp_B589F;
	always @(*) begin
		if (_sv2v_0)
			;
		(* full_case, parallel_case *)
		case (dlut_out[14-:2])
			2'd1: decoded_instr_nxt[100-:5] = ifd_instruction[14:10];
			default: decoded_instr_nxt[100-:5] = ifd_instruction[4:0];
		endcase
	end
	wire [1:1] sv2v_tmp_D8F29;
	assign sv2v_tmp_D8F29 = ((dlut_out[12-:3] != 3'd0) && !nop) && !has_trap;
	always @(*) decoded_instr_nxt[95] = sv2v_tmp_D8F29;
	always @(*) begin
		if (_sv2v_0)
			;
		(* full_case, parallel_case *)
		case (dlut_out[12-:3])
			3'd2: scalar_sel2 = ifd_instruction[14:10];
			3'd1: scalar_sel2 = ifd_instruction[19:15];
			3'd3: scalar_sel2 = ifd_instruction[9:5];
			default: scalar_sel2 = 0;
		endcase
	end
	wire [5:1] sv2v_tmp_1FBF8;
	assign sv2v_tmp_1FBF8 = scalar_sel2;
	always @(*) decoded_instr_nxt[94-:5] = sv2v_tmp_1FBF8;
	wire [1:1] sv2v_tmp_A0273;
	assign sv2v_tmp_A0273 = (dlut_out[9] && !nop) && !has_trap;
	always @(*) decoded_instr_nxt[89] = sv2v_tmp_A0273;
	wire [5:1] sv2v_tmp_1F848;
	assign sv2v_tmp_1F848 = ifd_instruction[4:0];
	always @(*) decoded_instr_nxt[88-:5] = sv2v_tmp_1F848;
	wire [1:1] sv2v_tmp_1AA29;
	assign sv2v_tmp_1AA29 = (dlut_out[8] && !nop) && !has_trap;
	always @(*) decoded_instr_nxt[83] = sv2v_tmp_1AA29;
	always @(*) begin
		if (_sv2v_0)
			;
		if (dlut_out[7])
			decoded_instr_nxt[82-:5] = ifd_instruction[9:5];
		else
			decoded_instr_nxt[82-:5] = ifd_instruction[19:15];
	end
	wire [1:1] sv2v_tmp_EBF04;
	assign sv2v_tmp_EBF04 = (dlut_out[18] && !nop) && !has_trap;
	always @(*) decoded_instr_nxt[77] = sv2v_tmp_EBF04;
	wire [1:1] sv2v_tmp_C4837;
	assign sv2v_tmp_C4837 = (dlut_out[19] && !compare) && !getlane;
	always @(*) decoded_instr_nxt[76] = sv2v_tmp_C4837;
	localparam defines_REG_RA = 5'd31;
	wire [5:1] sv2v_tmp_245AC;
	assign sv2v_tmp_245AC = (dlut_out[0] ? defines_REG_RA : ifd_instruction[9:5]);
	always @(*) decoded_instr_nxt[75-:5] = sv2v_tmp_245AC;
	wire [1:1] sv2v_tmp_E98EC;
	assign sv2v_tmp_E98EC = dlut_out[0];
	always @(*) decoded_instr_nxt[22] = sv2v_tmp_E98EC;
	always @(*) begin
		if (_sv2v_0)
			;
		if (fmt_i)
			alu_op = sv2v_cast_6({1'b0, ifd_instruction[28:24]});
		else if (dlut_out[0])
			alu_op = 6'b001111;
		else
			alu_op = ifd_instruction[25:20];
	end
	wire [6:1] sv2v_tmp_78B01;
	assign sv2v_tmp_78B01 = alu_op;
	always @(*) decoded_instr_nxt[70-:6] = sv2v_tmp_78B01;
	wire [2:1] sv2v_tmp_990C6;
	assign sv2v_tmp_990C6 = dlut_out[3-:2];
	always @(*) decoded_instr_nxt[64-:2] = sv2v_tmp_990C6;
	wire [1:1] sv2v_tmp_C2D78;
	assign sv2v_tmp_C2D78 = dlut_out[1];
	always @(*) decoded_instr_nxt[59] = sv2v_tmp_C2D78;
	always @(*) begin
		if (_sv2v_0)
			;
		if (dlut_out[6])
			decoded_instr_nxt[62] = 1'd0;
		else
			decoded_instr_nxt[62] = 1'd1;
	end
	wire [2:1] sv2v_tmp_EE17C;
	assign sv2v_tmp_EE17C = dlut_out[5-:2];
	always @(*) decoded_instr_nxt[61-:2] = sv2v_tmp_EE17C;
	function automatic [31:0] sv2v_cast_32;
		input reg [31:0] inp;
		sv2v_cast_32 = inp;
	endfunction
	always @(*) begin
		if (_sv2v_0)
			;
		(* full_case, parallel_case *)
		case (dlut_out[17-:3])
			3'd7: decoded_instr_nxt[58-:32] = {ifd_instruction[23:10], ifd_instruction[4:0], 13'd0};
			3'd1: decoded_instr_nxt[58-:32] = sv2v_cast_32($signed(ifd_instruction[23:15]));
			3'd2: decoded_instr_nxt[58-:32] = sv2v_cast_32($signed(ifd_instruction[23:10]));
			3'd3: decoded_instr_nxt[58-:32] = sv2v_cast_32($signed(ifd_instruction[24:15]));
			3'd4: decoded_instr_nxt[58-:32] = sv2v_cast_32($signed(ifd_instruction[24:10]));
			3'd5: decoded_instr_nxt[58-:32] = sv2v_cast_32($signed({ifd_instruction[24:5], 2'b00}));
			3'd6: decoded_instr_nxt[58-:32] = sv2v_cast_32($signed({ifd_instruction[24:0], 2'b00}));
			default: decoded_instr_nxt[58-:32] = 0;
		endcase
	end
	wire [3:1] sv2v_tmp_1A26C;
	assign sv2v_tmp_1A26C = ifd_instruction[27:25];
	always @(*) decoded_instr_nxt[25-:3] = sv2v_tmp_1A26C;
	wire [1:1] sv2v_tmp_86CFB;
	assign sv2v_tmp_86CFB = (ifd_instruction[31:28] == 4'b1111) && !has_trap;
	always @(*) decoded_instr_nxt[26] = sv2v_tmp_86CFB;
	wire [32:1] sv2v_tmp_B397D;
	assign sv2v_tmp_B397D = ifd_pc;
	always @(*) decoded_instr_nxt[141-:32] = sv2v_tmp_B397D;
	always @(*) begin
		if (_sv2v_0)
			;
		if (has_trap)
			decoded_instr_nxt[21-:2] = 2'd1;
		else if (fmt_r || fmt_i) begin
			if ((((alu_op[5] || (alu_op == 6'b000111)) || (alu_op == 6'b001000)) || (alu_op == 6'b011111)) || (alu_op == 6'b011011))
				decoded_instr_nxt[21-:2] = 2'd2;
			else
				decoded_instr_nxt[21-:2] = 2'd1;
		end
		else if (ifd_instruction[31:28] == 4'b1111)
			decoded_instr_nxt[21-:2] = 2'd1;
		else
			decoded_instr_nxt[21-:2] = 2'd0;
	end
	assign memory_access_type = ifd_instruction[28:25];
	wire [4:1] sv2v_tmp_D35EA;
	assign sv2v_tmp_D35EA = memory_access_type;
	always @(*) decoded_instr_nxt[18-:4] = sv2v_tmp_D35EA;
	wire [1:1] sv2v_tmp_D0F69;
	assign sv2v_tmp_D0F69 = (ifd_instruction[31:30] == 2'b10) && !has_trap;
	always @(*) decoded_instr_nxt[19] = sv2v_tmp_D0F69;
	wire [1:1] sv2v_tmp_0C594;
	assign sv2v_tmp_0C594 = ifd_instruction[29] && fmt_m;
	always @(*) decoded_instr_nxt[14] = sv2v_tmp_0C594;
	wire [1:1] sv2v_tmp_0363D;
	assign sv2v_tmp_0363D = (ifd_instruction[31:28] == 4'b1110) && !has_trap;
	always @(*) decoded_instr_nxt[3] = sv2v_tmp_0363D;
	wire [3:1] sv2v_tmp_8C9C3;
	assign sv2v_tmp_8C9C3 = ifd_instruction[27:25];
	always @(*) decoded_instr_nxt[2-:3] = sv2v_tmp_8C9C3;
	function automatic [3:0] sv2v_cast_60D1B;
		input reg [3:0] inp;
		sv2v_cast_60D1B = inp;
	endfunction
	always @(*) begin
		if (_sv2v_0)
			;
		if ((ifd_instruction[31:30] == 2'b10) && ((memory_access_type == 4'b1101) || (memory_access_type == 4'b1110)))
			decoded_instr_nxt[12-:4] = sv2v_cast_60D1B(15);
		else
			decoded_instr_nxt[12-:4] = 0;
	end
	wire [5:1] sv2v_tmp_E1483;
	assign sv2v_tmp_E1483 = ifd_instruction[4:0];
	always @(*) decoded_instr_nxt[8-:5] = sv2v_tmp_E1483;
	assign compare = (fmt_r || fmt_i) && ((((((((((((((((alu_op == 6'b010000) || (alu_op == 6'b010001)) || (alu_op == 6'b010010)) || (alu_op == 6'b010011)) || (alu_op == 6'b010100)) || (alu_op == 6'b010101)) || (alu_op == 6'b010110)) || (alu_op == 6'b010111)) || (alu_op == 6'b011000)) || (alu_op == 6'b011001)) || (alu_op == 6'b101100)) || (alu_op == 6'b101110)) || (alu_op == 6'b101101)) || (alu_op == 6'b101111)) || (alu_op == 6'b110000)) || (alu_op == 6'b110001));
	wire [1:1] sv2v_tmp_DE7AB;
	assign sv2v_tmp_DE7AB = compare;
	always @(*) decoded_instr_nxt[13] = sv2v_tmp_DE7AB;
	always @(posedge clk) begin
		id_instruction <= decoded_instr_nxt;
		id_thread_idx <= ifd_thread_idx;
	end
	always @(posedge clk or posedge reset)
		if (reset)
			id_instruction_valid <= 1'sb0;
		else
			id_instruction_valid <= (ifd_instruction_valid || has_trap) && (!wb_rollback_en || (wb_rollback_thread_idx != ifd_thread_idx));
	initial _sv2v_0 = 0;
endmodule
module int_execute_stage (
	clk,
	reset,
	of_operand1,
	of_operand2,
	of_mask_value,
	of_instruction_valid,
	of_instruction,
	of_thread_idx,
	of_subcycle,
	wb_rollback_en,
	wb_rollback_thread_idx,
	ix_instruction_valid,
	ix_instruction,
	ix_result,
	ix_mask_value,
	ix_thread_idx,
	ix_rollback_en,
	ix_rollback_pc,
	ix_subcycle,
	ix_privileged_op_fault,
	cr_eret_address,
	cr_supervisor_en,
	ix_perf_uncond_branch,
	ix_perf_cond_branch_taken,
	ix_perf_cond_branch_not_taken
);
	reg _sv2v_0;
	input clk;
	input reset;
	localparam defines_NUM_VECTOR_LANES = 16;
	input wire [511:0] of_operand1;
	input wire [511:0] of_operand2;
	input wire [15:0] of_mask_value;
	input of_instruction_valid;
	input wire [141:0] of_instruction;
	input wire [1:0] of_thread_idx;
	input wire [3:0] of_subcycle;
	input wire wb_rollback_en;
	input wire [1:0] wb_rollback_thread_idx;
	output reg ix_instruction_valid;
	output reg [141:0] ix_instruction;
	output reg [511:0] ix_result;
	output reg [15:0] ix_mask_value;
	output reg [1:0] ix_thread_idx;
	output reg ix_rollback_en;
	output reg [31:0] ix_rollback_pc;
	output reg [3:0] ix_subcycle;
	output reg ix_privileged_op_fault;
	input wire [127:0] cr_eret_address;
	input [0:3] cr_supervisor_en;
	output reg ix_perf_uncond_branch;
	output reg ix_perf_cond_branch_taken;
	output reg ix_perf_cond_branch_not_taken;
	wire [511:0] vector_result;
	wire eret;
	wire privileged_op_fault;
	reg branch_taken;
	reg conditional_branch;
	wire valid_instruction;
	genvar _gv_lane_1;
	localparam defines_FLOAT32_EXP_WIDTH = 8;
	localparam defines_FLOAT32_SIG_WIDTH = 23;
	function automatic [31:0] sv2v_cast_32;
		input reg [31:0] inp;
		sv2v_cast_32 = inp;
	endfunction
	function automatic [7:0] sv2v_cast_8;
		input reg [7:0] inp;
		sv2v_cast_8 = inp;
	endfunction
	generate
		for (_gv_lane_1 = 0; _gv_lane_1 < defines_NUM_VECTOR_LANES; _gv_lane_1 = _gv_lane_1 + 1) begin : lane_alu_gen
			localparam lane = _gv_lane_1;
			wire [31:0] lane_operand1;
			wire [31:0] lane_operand2;
			reg [31:0] lane_result;
			wire [31:0] difference;
			wire borrow;
			wire negative;
			wire overflow;
			wire zero;
			wire signed_gtr;
			wire [5:0] lz;
			wire [5:0] tz;
			reg [31:0] reciprocal;
			wire [31:0] fp_operand;
			wire [5:0] reciprocal_estimate;
			wire shift_in_sign;
			wire [31:0] rshift;
			assign lane_operand1 = of_operand1[lane * 32+:32];
			assign lane_operand2 = of_operand2[lane * 32+:32];
			assign {borrow, difference} = {1'b0, lane_operand1} - {1'b0, lane_operand2};
			assign negative = difference[31];
			assign overflow = (lane_operand2[31] == negative) && (lane_operand1[31] != lane_operand2[31]);
			assign zero = difference == 0;
			assign signed_gtr = overflow == negative;
			function automatic [5:0] count_lz;
				input [31:0] val;
				integer i;
				reg found;
				begin
					count_lz = 32;
					found = 0;
					for (i = 31; i >= 0; i = i - 1)
						if (!found && val[i]) begin
							count_lz = 31 - i;
							found = 1;
						end
				end
			endfunction
			function automatic [5:0] count_tz;
				input [31:0] val;
				integer i;
				reg found;
				begin
					count_tz = 32;
					found = 0;
					for (i = 0; i < 32; i = i + 1)
						if (!found && val[i]) begin
							count_tz = i;
							found = 1;
						end
				end
			endfunction
			assign lz = count_lz(lane_operand2);
			assign tz = count_tz(lane_operand2);
			assign shift_in_sign = (of_instruction[70-:6] == 6'b001001 ? lane_operand1[31] : 1'd0);
			assign rshift = sv2v_cast_32({{32 {shift_in_sign}}, lane_operand1} >> lane_operand2[4:0]);
			assign fp_operand = lane_operand2;
			reciprocal_rom rom(
				.significand(fp_operand[22:17]),
				.reciprocal_estimate(reciprocal_estimate)
			);
			always @(*) begin
				if (_sv2v_0)
					;
				if (fp_operand[30-:8] == 0)
					reciprocal = {fp_operand[31], 31'h7f800000};
				else if (fp_operand[30-:8] == 8'hff) begin
					if (fp_operand[22-:defines_FLOAT32_SIG_WIDTH] != 0)
						reciprocal = 32'h7fffffff;
					else
						reciprocal = {fp_operand[31], 31'h00000000};
				end
				else
					reciprocal = {fp_operand[31], (8'd253 - fp_operand[30-:8]) + sv2v_cast_8(fp_operand[22:17] == 0), reciprocal_estimate, {17 {1'b0}}};
			end
			always @(*) begin
				if (_sv2v_0)
					;
				(* full_case, parallel_case *)
				case (of_instruction[70-:6])
					6'b001001, 6'b001010: lane_result = rshift;
					6'b001011: lane_result = lane_operand1 << lane_operand2[4:0];
					6'b001111: lane_result = lane_operand2;
					6'b000000: lane_result = lane_operand1 | lane_operand2;
					6'b001100: lane_result = sv2v_cast_32(lz);
					6'b001110: lane_result = sv2v_cast_32(tz);
					6'b000001: lane_result = lane_operand1 & lane_operand2;
					6'b000011: lane_result = lane_operand1 ^ lane_operand2;
					6'b000101: lane_result = lane_operand1 + lane_operand2;
					6'b000110: lane_result = difference;
					6'b010000: lane_result = {{31 {1'b0}}, zero};
					6'b010001: lane_result = {{31 {1'b0}}, !zero};
					6'b010010: lane_result = {{31 {1'b0}}, signed_gtr && !zero};
					6'b010011: lane_result = {{31 {1'b0}}, signed_gtr || zero};
					6'b010100: lane_result = {{31 {1'b0}}, !signed_gtr && !zero};
					6'b010101: lane_result = {{31 {1'b0}}, !signed_gtr || zero};
					6'b010110: lane_result = {{31 {1'b0}}, !borrow && !zero};
					6'b010111: lane_result = {{31 {1'b0}}, !borrow || zero};
					6'b011000: lane_result = {{31 {1'b0}}, borrow && !zero};
					6'b011001: lane_result = {{31 {1'b0}}, borrow || zero};
					6'b011101: lane_result = sv2v_cast_32($signed(lane_operand2[7:0]));
					6'b011110: lane_result = sv2v_cast_32($signed(lane_operand2[15:0]));
					6'b001101, 6'b011010: lane_result = of_operand1[~lane_operand2 * 32+:32];
					6'b011100: lane_result = reciprocal;
					default: lane_result = 0;
				endcase
			end
			assign vector_result[lane * 32+:32] = lane_result;
		end
	endgenerate
	assign valid_instruction = (of_instruction_valid && (!wb_rollback_en || (wb_rollback_thread_idx != of_thread_idx))) && (of_instruction[21-:2] == 2'd1);
	assign eret = (valid_instruction && of_instruction[26]) && (of_instruction[25-:3] == 3'b111);
	assign privileged_op_fault = eret && !cr_supervisor_en[of_thread_idx];
	always @(*) begin
		if (_sv2v_0)
			;
		branch_taken = 0;
		conditional_branch = 0;
		if ((valid_instruction && of_instruction[26]) && !privileged_op_fault)
			(* full_case, parallel_case *)
			case (of_instruction[25-:3])
				3'b001: begin
					branch_taken = of_operand1[0+:32] == 0;
					conditional_branch = 1;
				end
				3'b010: begin
					branch_taken = of_operand1[0+:32] != 0;
					conditional_branch = 1;
				end
				3'b011, 3'b100, 3'b110, 3'b000, 3'b111: branch_taken = 1;
				default:
					;
			endcase
	end
	always @(posedge clk) begin
		ix_instruction <= of_instruction;
		ix_result <= vector_result;
		ix_mask_value <= of_mask_value;
		ix_thread_idx <= of_thread_idx;
		ix_subcycle <= of_subcycle;
		(* full_case, parallel_case *)
		case (of_instruction[25-:3])
			3'b110, 3'b000: ix_rollback_pc <= of_operand1[0+:32];
			3'b111: ix_rollback_pc <= cr_eret_address[(3 - of_thread_idx) * 32+:32];
			default: ix_rollback_pc <= of_instruction[141-:32] + of_instruction[58-:32];
		endcase
	end
	always @(posedge clk or posedge reset)
		if (reset) begin
			ix_instruction_valid <= 1'sb0;
			ix_perf_cond_branch_not_taken <= 1'sb0;
			ix_perf_cond_branch_taken <= 1'sb0;
			ix_perf_uncond_branch <= 1'sb0;
			ix_privileged_op_fault <= 1'sb0;
			ix_rollback_en <= 1'sb0;
		end
		else begin
			if (valid_instruction) begin
				ix_instruction_valid <= 1;
				ix_privileged_op_fault <= privileged_op_fault;
				ix_rollback_en <= branch_taken;
			end
			else begin
				ix_instruction_valid <= 0;
				ix_rollback_en <= 0;
			end
			ix_perf_uncond_branch <= !conditional_branch && branch_taken;
			ix_perf_cond_branch_taken <= conditional_branch && branch_taken;
			ix_perf_cond_branch_not_taken <= conditional_branch && !branch_taken;
		end
	initial _sv2v_0 = 0;
endmodule
module io_request_queue (
	clk,
	reset,
	dd_io_write_en,
	dd_io_read_en,
	dd_io_thread_idx,
	dd_io_addr,
	dd_io_write_value,
	ior_read_value,
	ior_rollback_en,
	ior_pending,
	ior_wake_bitmap,
	ii_ready,
	ii_response_valid,
	ii_response,
	ior_request_valid,
	ior_request
);
	parameter CORE_ID = 0;
	input clk;
	input reset;
	input dd_io_write_en;
	input dd_io_read_en;
	input wire [1:0] dd_io_thread_idx;
	input wire [31:0] dd_io_addr;
	input wire [31:0] dd_io_write_value;
	output reg [31:0] ior_read_value;
	output reg ior_rollback_en;
	output wire [3:0] ior_pending;
	output wire [3:0] ior_wake_bitmap;
	input ii_ready;
	input ii_response_valid;
	input wire [37:0] ii_response;
	output wire ior_request_valid;
	output wire [66:0] ior_request;
	reg [66:0] pending_request [0:3];
	wire [3:0] wake_thread_oh;
	wire [3:0] send_request;
	wire [3:0] send_grant_oh;
	wire [1:0] send_grant_idx;
	genvar _gv_thread_idx_4;
	function automatic [1:0] sv2v_cast_2;
		input reg [1:0] inp;
		sv2v_cast_2 = inp;
	endfunction
	generate
		for (_gv_thread_idx_4 = 0; _gv_thread_idx_4 < 4; _gv_thread_idx_4 = _gv_thread_idx_4 + 1) begin : io_request_gen
			localparam thread_idx = _gv_thread_idx_4;
			assign send_request[thread_idx] = pending_request[thread_idx][66] && !pending_request[thread_idx][65];
			assign ior_pending[thread_idx] = (pending_request[thread_idx][66] && pending_request[thread_idx][65]) || send_grant_oh[thread_idx];
			always @(posedge clk or posedge reset)
				if (reset)
					pending_request[thread_idx] <= 0;
				else begin
					if ((dd_io_write_en | dd_io_read_en) && (dd_io_thread_idx == sv2v_cast_2(thread_idx))) begin
						if (pending_request[thread_idx][66])
							pending_request[thread_idx][66] <= 0;
						else begin
							pending_request[thread_idx][66] <= 1;
							pending_request[thread_idx][64] <= dd_io_write_en;
							pending_request[thread_idx][63-:32] <= dd_io_addr;
							pending_request[thread_idx][31-:32] <= dd_io_write_value;
							pending_request[thread_idx][65] <= 0;
						end
					end
					if ((ii_response_valid && (ii_response[37-:4] == CORE_ID)) && (ii_response[33-:2] == sv2v_cast_2(thread_idx)))
						pending_request[thread_idx][31-:32] <= ii_response[31-:32];
					if ((ii_ready && |send_grant_oh) && (send_grant_idx == sv2v_cast_2(thread_idx)))
						pending_request[thread_idx][65] <= 1;
				end
		end
	endgenerate
	rr_arbiter #(.NUM_REQUESTERS(4)) request_arbiter(
		.request(send_request),
		.update_lru(1'b1),
		.grant_oh(send_grant_oh),
		.clk(clk),
		.reset(reset)
	);
	oh_to_idx #(.NUM_SIGNALS(4)) oh_to_idx_send_thread(
		.one_hot(send_grant_oh),
		.index(send_grant_idx)
	);
	idx_to_oh #(.NUM_SIGNALS(4)) idx_to_oh_wake_thread(
		.index(ii_response[33-:2]),
		.one_hot(wake_thread_oh)
	);
	assign ior_wake_bitmap = (ii_response_valid && (ii_response[37-:4] == CORE_ID) ? wake_thread_oh : 4'd0);
	assign ior_request_valid = |send_request;
	assign ior_request[66] = pending_request[send_grant_idx][64];
	assign ior_request[63-:32] = pending_request[send_grant_idx][63-:32];
	assign ior_request[31-:32] = pending_request[send_grant_idx][31-:32];
	assign ior_request[65-:2] = send_grant_idx;
	always @(posedge clk or posedge reset)
		if (reset)
			ior_rollback_en <= 1'sb0;
		else if ((dd_io_write_en || dd_io_read_en) && !pending_request[dd_io_thread_idx][66])
			ior_rollback_en <= 1;
		else
			ior_rollback_en <= 0;
	always @(posedge clk) ior_read_value <= pending_request[dd_io_thread_idx][31-:32];
endmodule
module l1_l2_interface (
	clk,
	reset,
	l2_ready,
	l2_response_valid,
	l2_response,
	l2i_request_valid,
	l2i_request,
	l2i_icache_lru_fill_en,
	l2i_icache_lru_fill_set,
	l2i_itag_update_en,
	l2i_itag_update_set,
	l2i_itag_update_tag,
	l2i_itag_update_valid,
	sq_store_sync_pending,
	ift_fill_lru,
	ifd_cache_miss,
	ifd_cache_miss_paddr,
	ifd_cache_miss_thread_idx,
	l2i_idata_update_en,
	l2i_idata_update_way,
	l2i_idata_update_set,
	l2i_idata_update_data,
	l2i_dcache_wake_bitmap,
	l2i_icache_wake_bitmap,
	dt_snoop_valid,
	dt_snoop_tag,
	dt_fill_lru,
	l2i_snoop_en,
	l2i_snoop_set,
	l2i_dtag_update_en_oh,
	l2i_dtag_update_set,
	l2i_dtag_update_tag,
	l2i_dtag_update_valid,
	l2i_dcache_lru_fill_en,
	l2i_dcache_lru_fill_set,
	dd_cache_miss,
	dd_cache_miss_addr,
	dd_cache_miss_thread_idx,
	dd_cache_miss_sync,
	dd_store_en,
	dd_flush_en,
	dd_membar_en,
	dd_iinvalidate_en,
	dd_dinvalidate_en,
	dd_store_mask,
	dd_store_addr,
	dd_store_data,
	dd_store_thread_idx,
	dd_store_sync,
	dd_store_bypass_addr,
	dd_store_bypass_thread_idx,
	l2i_ddata_update_en,
	l2i_ddata_update_way,
	l2i_ddata_update_set,
	l2i_ddata_update_data,
	sq_store_bypass_mask,
	sq_store_sync_success,
	sq_store_bypass_data,
	sq_rollback_en,
	l2i_perf_store
);
	reg _sv2v_0;
	parameter CORE_ID = 0;
	input clk;
	input reset;
	input l2_ready;
	input l2_response_valid;
	localparam defines_NUM_VECTOR_LANES = 16;
	localparam defines_CACHE_LINE_BYTES = 64;
	localparam defines_CACHE_LINE_BITS = 512;
	localparam defines_CACHE_LINE_OFFSET_WIDTH = 6;
	input wire [548:0] l2_response;
	output reg l2i_request_valid;
	output reg [611:0] l2i_request;
	output wire l2i_icache_lru_fill_en;
	output wire [5:0] l2i_icache_lru_fill_set;
	output wire [3:0] l2i_itag_update_en;
	output wire [5:0] l2i_itag_update_set;
	localparam defines_ICACHE_TAG_BITS = 20;
	output wire [19:0] l2i_itag_update_tag;
	output wire l2i_itag_update_valid;
	output wire [3:0] sq_store_sync_pending;
	input wire [1:0] ift_fill_lru;
	input wire ifd_cache_miss;
	input wire [25:0] ifd_cache_miss_paddr;
	input wire [1:0] ifd_cache_miss_thread_idx;
	output reg l2i_idata_update_en;
	output reg [1:0] l2i_idata_update_way;
	output reg [5:0] l2i_idata_update_set;
	output reg [511:0] l2i_idata_update_data;
	output wire [3:0] l2i_dcache_wake_bitmap;
	output wire [3:0] l2i_icache_wake_bitmap;
	input wire [0:3] dt_snoop_valid;
	localparam defines_DCACHE_TAG_BITS = 20;
	input wire [79:0] dt_snoop_tag;
	input wire [1:0] dt_fill_lru;
	output wire l2i_snoop_en;
	output wire [5:0] l2i_snoop_set;
	output wire [3:0] l2i_dtag_update_en_oh;
	output wire [5:0] l2i_dtag_update_set;
	output wire [19:0] l2i_dtag_update_tag;
	output wire l2i_dtag_update_valid;
	output wire l2i_dcache_lru_fill_en;
	output wire [5:0] l2i_dcache_lru_fill_set;
	input dd_cache_miss;
	input wire [25:0] dd_cache_miss_addr;
	input wire [1:0] dd_cache_miss_thread_idx;
	input dd_cache_miss_sync;
	input dd_store_en;
	input dd_flush_en;
	input dd_membar_en;
	input dd_iinvalidate_en;
	input dd_dinvalidate_en;
	input [63:0] dd_store_mask;
	input wire [25:0] dd_store_addr;
	input wire [511:0] dd_store_data;
	input wire [1:0] dd_store_thread_idx;
	input dd_store_sync;
	input wire [25:0] dd_store_bypass_addr;
	input wire [1:0] dd_store_bypass_thread_idx;
	output reg l2i_ddata_update_en;
	output reg [1:0] l2i_ddata_update_way;
	output reg [5:0] l2i_ddata_update_set;
	output reg [511:0] l2i_ddata_update_data;
	output wire [63:0] sq_store_bypass_mask;
	output wire sq_store_sync_success;
	output wire [511:0] sq_store_bypass_data;
	output wire sq_rollback_en;
	output reg l2i_perf_store;
	wire [3:0] snoop_hit_way_oh;
	wire [1:0] snoop_hit_way_idx;
	wire [3:0] ifill_way_oh;
	wire [3:0] dupdate_way_oh;
	reg [1:0] dupdate_way_idx;
	wire ack_for_me;
	wire icache_update_en;
	wire dcache_update_en;
	wire dcache_l2_response_valid;
	wire [1:0] dcache_l2_response_idx;
	wire icache_l2_response_valid;
	wire [1:0] icache_l2_response_idx;
	wire storebuf_l2_response_valid;
	wire [1:0] storebuf_l2_response_idx;
	wire [3:0] dcache_miss_wake_bitmap;
	reg storebuf_dequeue_ack;
	wire icache_dequeue_ready;
	reg icache_dequeue_ack;
	wire dcache_dequeue_ready;
	reg dcache_dequeue_ack;
	wire [25:0] dcache_dequeue_addr;
	wire dcache_dequeue_sync;
	wire [25:0] icache_dequeue_addr;
	wire [1:0] dcache_dequeue_idx;
	wire [1:0] icache_dequeue_idx;
	reg response_stage2_valid;
	reg [548:0] response_stage2;
	wire [5:0] dcache_set_stage1;
	wire [5:0] icache_set_stage1;
	wire [5:0] dcache_set_stage2;
	wire [5:0] icache_set_stage2;
	wire [19:0] dcache_tag_stage2;
	wire [19:0] icache_tag_stage2;
	wire storebuf_l2_sync_success;
	wire response_iinvalidate;
	wire response_dinvalidate;
	wire [25:0] sq_dequeue_addr;
	wire [511:0] sq_dequeue_data;
	wire sq_dequeue_dinvalidate;
	wire sq_dequeue_flush;
	wire [1:0] sq_dequeue_idx;
	wire sq_dequeue_iinvalidate;
	wire [63:0] sq_dequeue_mask;
	wire sq_dequeue_ready;
	wire sq_dequeue_sync;
	wire [3:0] sq_wake_bitmap;
	l1_store_queue l1_store_queue(
		.clk(clk),
		.reset(reset),
		.sq_store_sync_pending(sq_store_sync_pending),
		.dd_store_en(dd_store_en),
		.dd_flush_en(dd_flush_en),
		.dd_membar_en(dd_membar_en),
		.dd_iinvalidate_en(dd_iinvalidate_en),
		.dd_dinvalidate_en(dd_dinvalidate_en),
		.dd_store_addr(dd_store_addr),
		.dd_store_mask(dd_store_mask),
		.dd_store_data(dd_store_data),
		.dd_store_sync(dd_store_sync),
		.dd_store_thread_idx(dd_store_thread_idx),
		.dd_store_bypass_addr(dd_store_bypass_addr),
		.dd_store_bypass_thread_idx(dd_store_bypass_thread_idx),
		.sq_store_bypass_mask(sq_store_bypass_mask),
		.sq_store_bypass_data(sq_store_bypass_data),
		.sq_store_sync_success(sq_store_sync_success),
		.storebuf_dequeue_ack(storebuf_dequeue_ack),
		.storebuf_l2_response_valid(storebuf_l2_response_valid),
		.storebuf_l2_response_idx(storebuf_l2_response_idx),
		.storebuf_l2_sync_success(storebuf_l2_sync_success),
		.sq_dequeue_ready(sq_dequeue_ready),
		.sq_dequeue_addr(sq_dequeue_addr),
		.sq_dequeue_idx(sq_dequeue_idx),
		.sq_dequeue_mask(sq_dequeue_mask),
		.sq_dequeue_data(sq_dequeue_data),
		.sq_dequeue_sync(sq_dequeue_sync),
		.sq_dequeue_flush(sq_dequeue_flush),
		.sq_dequeue_iinvalidate(sq_dequeue_iinvalidate),
		.sq_dequeue_dinvalidate(sq_dequeue_dinvalidate),
		.sq_rollback_en(sq_rollback_en),
		.sq_wake_bitmap(sq_wake_bitmap)
	);
	l1_load_miss_queue l1_load_miss_queue_dcache(
		.cache_miss(dd_cache_miss),
		.cache_miss_addr(dd_cache_miss_addr),
		.cache_miss_thread_idx(dd_cache_miss_thread_idx),
		.cache_miss_sync(dd_cache_miss_sync),
		.dequeue_ready(dcache_dequeue_ready),
		.dequeue_ack(dcache_dequeue_ack),
		.dequeue_addr(dcache_dequeue_addr),
		.dequeue_idx(dcache_dequeue_idx),
		.dequeue_sync(dcache_dequeue_sync),
		.l2_response_valid(dcache_l2_response_valid),
		.l2_response_idx(dcache_l2_response_idx),
		.wake_bitmap(dcache_miss_wake_bitmap),
		.clk(clk),
		.reset(reset)
	);
	assign l2i_dcache_wake_bitmap = dcache_miss_wake_bitmap | sq_wake_bitmap;
	localparam [0:0] sv2v_uu_l1_load_miss_queue_icache_ext_cache_miss_sync_0 = 1'sb0;
	l1_load_miss_queue l1_load_miss_queue_icache(
		.cache_miss(ifd_cache_miss),
		.cache_miss_addr(ifd_cache_miss_paddr),
		.cache_miss_thread_idx(ifd_cache_miss_thread_idx),
		.cache_miss_sync(sv2v_uu_l1_load_miss_queue_icache_ext_cache_miss_sync_0),
		.dequeue_ready(icache_dequeue_ready),
		.dequeue_ack(icache_dequeue_ack),
		.dequeue_addr(icache_dequeue_addr),
		.dequeue_idx(icache_dequeue_idx),
		.dequeue_sync(),
		.l2_response_valid(icache_l2_response_valid),
		.l2_response_idx(icache_l2_response_idx),
		.wake_bitmap(l2i_icache_wake_bitmap),
		.clk(clk),
		.reset(reset)
	);
	assign dcache_set_stage1 = l2_response[517:512];
	assign icache_set_stage1 = l2_response[517:512];
	assign l2i_snoop_en = l2_response_valid && (l2_response[538] == 1'd1);
	assign l2i_snoop_set = dcache_set_stage1;
	assign l2i_dcache_lru_fill_en = ((l2_response_valid && (l2_response[538] == 1'd1)) && (l2_response[541-:3] == 3'd0)) && (l2_response[547-:4] == CORE_ID);
	assign l2i_dcache_lru_fill_set = dcache_set_stage1;
	assign l2i_icache_lru_fill_en = ((l2_response_valid && (l2_response[538] == 1'd0)) && (l2_response[541-:3] == 3'd0)) && (l2_response[547-:4] == CORE_ID);
	assign l2i_icache_lru_fill_set = icache_set_stage1;
	always @(posedge clk or posedge reset)
		if (reset)
			response_stage2_valid <= 0;
		else
			response_stage2_valid <= l2_response_valid;
	always @(posedge clk) response_stage2 <= l2_response;
	assign {icache_tag_stage2, icache_set_stage2} = response_stage2[537-:26];
	assign {dcache_tag_stage2, dcache_set_stage2} = response_stage2[537-:26];
	genvar _gv_way_idx_5;
	generate
		for (_gv_way_idx_5 = 0; _gv_way_idx_5 < 4; _gv_way_idx_5 = _gv_way_idx_5 + 1) begin : snoop_hit_check_gen
			localparam way_idx = _gv_way_idx_5;
			assign snoop_hit_way_oh[way_idx] = (dt_snoop_tag[(3 - way_idx) * defines_DCACHE_TAG_BITS+:defines_DCACHE_TAG_BITS] == dcache_tag_stage2) && dt_snoop_valid[way_idx];
		end
	endgenerate
	oh_to_idx #(.NUM_SIGNALS(4)) convert_snoop_request_pending(
		.index(snoop_hit_way_idx),
		.one_hot(snoop_hit_way_oh)
	);
	always @(*) begin
		if (_sv2v_0)
			;
		if (|snoop_hit_way_oh)
			dupdate_way_idx = snoop_hit_way_idx;
		else
			dupdate_way_idx = dt_fill_lru;
	end
	idx_to_oh #(.NUM_SIGNALS(4)) idx_to_oh_dfill_way(
		.index(dupdate_way_idx),
		.one_hot(dupdate_way_oh)
	);
	idx_to_oh #(.NUM_SIGNALS(4)) idx_to_oh_ifill_way(
		.index(ift_fill_lru),
		.one_hot(ifill_way_oh)
	);
	assign ack_for_me = response_stage2_valid && (response_stage2[547-:4] == CORE_ID);
	assign response_dinvalidate = response_stage2[541-:3] == 3'd4;
	assign dcache_update_en = (ack_for_me && (((response_stage2[541-:3] == 3'd0) && (response_stage2[538] == 1'd1)) || (response_stage2[541-:3] == 3'd1))) || ((response_stage2_valid && response_dinvalidate) && |snoop_hit_way_oh);
	assign l2i_dtag_update_en_oh = dupdate_way_oh & {4 {dcache_update_en}};
	assign l2i_dtag_update_tag = dcache_tag_stage2;
	assign l2i_dtag_update_set = dcache_set_stage2;
	assign l2i_dtag_update_valid = !response_dinvalidate;
	assign response_iinvalidate = response_stage2_valid && (response_stage2[541-:3] == 3'd3);
	assign icache_update_en = (ack_for_me && (response_stage2[538] == 1'd0)) || response_iinvalidate;
	assign l2i_itag_update_en = (response_iinvalidate ? {4 {1'b1}} : ifill_way_oh & {4 {icache_update_en}});
	assign l2i_itag_update_tag = icache_tag_stage2;
	assign l2i_itag_update_set = icache_set_stage2;
	assign l2i_itag_update_valid = !response_iinvalidate;
	assign icache_l2_response_valid = ack_for_me && (response_stage2[538] == 1'd0);
	assign dcache_l2_response_valid = (ack_for_me && (response_stage2[541-:3] == 3'd0)) && (response_stage2[538] == 1'd1);
	assign storebuf_l2_response_valid = ack_for_me && ((((response_stage2[541-:3] == 3'd1) || (response_stage2[541-:3] == 3'd2)) || (response_stage2[541-:3] == 3'd3)) || (response_stage2[541-:3] == 3'd4));
	assign dcache_l2_response_idx = response_stage2[543-:2];
	assign icache_l2_response_idx = response_stage2[543-:2];
	assign storebuf_l2_response_idx = response_stage2[543-:2];
	assign storebuf_l2_sync_success = response_stage2[548];
	always @(posedge clk) begin
		l2i_ddata_update_way <= dupdate_way_idx;
		l2i_ddata_update_set <= dcache_set_stage2;
		l2i_ddata_update_data <= response_stage2[511-:defines_CACHE_LINE_BITS];
		l2i_idata_update_way <= ift_fill_lru;
		l2i_idata_update_set <= icache_set_stage2;
		l2i_idata_update_data <= response_stage2[511-:defines_CACHE_LINE_BITS];
	end
	always @(posedge clk or posedge reset)
		if (reset) begin
			l2i_ddata_update_en <= 1'sb0;
			l2i_idata_update_en <= 1'sb0;
		end
		else begin
			l2i_ddata_update_en <= dcache_update_en || ((|snoop_hit_way_oh && response_stage2_valid) && (response_stage2[541-:3] == 3'd1));
			l2i_idata_update_en <= icache_update_en;
		end
	always @(*) begin
		if (_sv2v_0)
			;
		l2i_request_valid = 0;
		l2i_request = 0;
		storebuf_dequeue_ack = 0;
		icache_dequeue_ack = 0;
		dcache_dequeue_ack = 0;
		l2i_perf_store = 0;
		l2i_request[611-:4] = CORE_ID;
		if (dcache_dequeue_ready) begin
			l2i_request_valid = 1;
			l2i_request[605-:3] = (dcache_dequeue_sync ? 3'd1 : 3'd0);
			l2i_request[607-:2] = dcache_dequeue_idx;
			l2i_request[601-:26] = dcache_dequeue_addr;
			l2i_request[602] = 1'd1;
			if (l2_ready)
				dcache_dequeue_ack = 1;
		end
		else if (icache_dequeue_ready) begin
			l2i_request_valid = 1;
			l2i_request[605-:3] = 3'd0;
			l2i_request[607-:2] = icache_dequeue_idx;
			l2i_request[601-:26] = icache_dequeue_addr;
			l2i_request[602] = 1'd0;
			if (l2_ready)
				icache_dequeue_ack = 1;
		end
		else if (sq_dequeue_ready) begin
			l2i_request_valid = 1;
			if (sq_dequeue_flush)
				l2i_request[605-:3] = 3'd4;
			else if (sq_dequeue_sync)
				l2i_request[605-:3] = 3'd3;
			else if (sq_dequeue_iinvalidate)
				l2i_request[605-:3] = 3'd5;
			else if (sq_dequeue_dinvalidate)
				l2i_request[605-:3] = 3'd6;
			else
				l2i_request[605-:3] = 3'd2;
			l2i_request[607-:2] = sq_dequeue_idx;
			l2i_request[601-:26] = sq_dequeue_addr;
			l2i_request[511-:defines_CACHE_LINE_BITS] = sq_dequeue_data;
			l2i_request[575-:64] = sq_dequeue_mask;
			l2i_request[602] = 1'd1;
			if (l2_ready) begin
				storebuf_dequeue_ack = 1;
				l2i_perf_store = l2i_request[605-:3] == 3'd2;
			end
		end
	end
	initial _sv2v_0 = 0;
endmodule
module l1_load_miss_queue (
	clk,
	reset,
	cache_miss,
	cache_miss_addr,
	cache_miss_thread_idx,
	cache_miss_sync,
	dequeue_ready,
	dequeue_ack,
	dequeue_addr,
	dequeue_idx,
	dequeue_sync,
	l2_response_valid,
	l2_response_idx,
	wake_bitmap
);
	input clk;
	input reset;
	input cache_miss;
	localparam defines_NUM_VECTOR_LANES = 16;
	localparam defines_CACHE_LINE_BYTES = 64;
	localparam defines_CACHE_LINE_OFFSET_WIDTH = 6;
	input wire [25:0] cache_miss_addr;
	input wire [1:0] cache_miss_thread_idx;
	input cache_miss_sync;
	output wire dequeue_ready;
	input dequeue_ack;
	output wire [25:0] dequeue_addr;
	output wire [1:0] dequeue_idx;
	output wire dequeue_sync;
	input l2_response_valid;
	input wire [1:0] l2_response_idx;
	output wire [3:0] wake_bitmap;
	reg [32:0] pending_entries [0:3];
	wire [3:0] collided_miss_oh;
	wire [3:0] miss_thread_oh;
	wire request_unique;
	wire [3:0] send_grant_oh;
	wire [3:0] arbiter_request;
	wire [1:0] send_grant_idx;
	idx_to_oh #(.NUM_SIGNALS(4)) idx_to_oh_miss_thread(
		.index(cache_miss_thread_idx),
		.one_hot(miss_thread_oh)
	);
	rr_arbiter #(.NUM_REQUESTERS(4)) request_arbiter(
		.request(arbiter_request),
		.update_lru(1'b1),
		.grant_oh(send_grant_oh),
		.clk(clk),
		.reset(reset)
	);
	oh_to_idx #(.NUM_SIGNALS(4)) oh_to_idx_send_grant(
		.index(send_grant_idx),
		.one_hot(send_grant_oh)
	);
	assign dequeue_ready = |arbiter_request;
	assign dequeue_addr = pending_entries[send_grant_idx][26-:26];
	assign dequeue_idx = send_grant_idx;
	assign dequeue_sync = pending_entries[send_grant_idx][0];
	assign request_unique = !(|collided_miss_oh);
	assign wake_bitmap = (l2_response_valid ? pending_entries[l2_response_idx][30-:4] : 4'd0);
	genvar _gv_wait_entry_1;
	function automatic [1:0] sv2v_cast_2;
		input reg [1:0] inp;
		sv2v_cast_2 = inp;
	endfunction
	generate
		for (_gv_wait_entry_1 = 0; _gv_wait_entry_1 < 4; _gv_wait_entry_1 = _gv_wait_entry_1 + 1) begin : wait_logic_gen
			localparam wait_entry = _gv_wait_entry_1;
			assign collided_miss_oh[wait_entry] = ((pending_entries[wait_entry][32] && (pending_entries[wait_entry][26-:26] == cache_miss_addr)) && !pending_entries[wait_entry][0]) && !cache_miss_sync;
			assign arbiter_request[wait_entry] = pending_entries[wait_entry][32] && !pending_entries[wait_entry][31];
			always @(posedge clk or posedge reset)
				if (reset)
					pending_entries[wait_entry] <= 0;
				else begin
					if (dequeue_ack && send_grant_oh[wait_entry])
						pending_entries[wait_entry][31] <= 1;
					else if ((cache_miss && miss_thread_oh[wait_entry]) && request_unique) begin
						pending_entries[wait_entry][30-:4] <= miss_thread_oh;
						pending_entries[wait_entry][32] <= 1;
						pending_entries[wait_entry][26-:26] <= cache_miss_addr;
						pending_entries[wait_entry][31] <= 0;
						pending_entries[wait_entry][0] <= cache_miss_sync;
					end
					else if (l2_response_valid && (l2_response_idx == sv2v_cast_2(wait_entry)))
						pending_entries[wait_entry][32] <= 0;
					if (cache_miss && collided_miss_oh[wait_entry])
						pending_entries[wait_entry][30-:4] <= pending_entries[wait_entry][30-:4] | miss_thread_oh;
				end
		end
	endgenerate
endmodule
module l1_store_queue (
	clk,
	reset,
	sq_store_sync_pending,
	dd_store_en,
	dd_flush_en,
	dd_membar_en,
	dd_iinvalidate_en,
	dd_dinvalidate_en,
	dd_store_addr,
	dd_store_mask,
	dd_store_data,
	dd_store_sync,
	dd_store_thread_idx,
	dd_store_bypass_addr,
	dd_store_bypass_thread_idx,
	sq_store_bypass_mask,
	sq_store_bypass_data,
	sq_store_sync_success,
	storebuf_dequeue_ack,
	storebuf_l2_response_valid,
	storebuf_l2_response_idx,
	storebuf_l2_sync_success,
	sq_dequeue_ready,
	sq_dequeue_addr,
	sq_dequeue_idx,
	sq_dequeue_mask,
	sq_dequeue_data,
	sq_dequeue_sync,
	sq_dequeue_flush,
	sq_dequeue_iinvalidate,
	sq_dequeue_dinvalidate,
	sq_rollback_en,
	sq_wake_bitmap
);
	reg _sv2v_0;
	input clk;
	input reset;
	output wire [3:0] sq_store_sync_pending;
	input dd_store_en;
	input dd_flush_en;
	input dd_membar_en;
	input dd_iinvalidate_en;
	input dd_dinvalidate_en;
	localparam defines_NUM_VECTOR_LANES = 16;
	localparam defines_CACHE_LINE_BYTES = 64;
	localparam defines_CACHE_LINE_OFFSET_WIDTH = 6;
	input wire [25:0] dd_store_addr;
	input [63:0] dd_store_mask;
	localparam defines_CACHE_LINE_BITS = 512;
	input wire [511:0] dd_store_data;
	input dd_store_sync;
	input wire [1:0] dd_store_thread_idx;
	input wire [25:0] dd_store_bypass_addr;
	input wire [1:0] dd_store_bypass_thread_idx;
	output reg [63:0] sq_store_bypass_mask;
	output reg [511:0] sq_store_bypass_data;
	output reg sq_store_sync_success;
	input storebuf_dequeue_ack;
	input storebuf_l2_response_valid;
	input wire [1:0] storebuf_l2_response_idx;
	input storebuf_l2_sync_success;
	output wire sq_dequeue_ready;
	output wire [25:0] sq_dequeue_addr;
	output wire [1:0] sq_dequeue_idx;
	output wire [63:0] sq_dequeue_mask;
	output wire [511:0] sq_dequeue_data;
	output wire sq_dequeue_sync;
	output wire sq_dequeue_flush;
	output wire sq_dequeue_iinvalidate;
	output wire sq_dequeue_dinvalidate;
	output reg sq_rollback_en;
	output wire [3:0] sq_wake_bitmap;
	reg [610:0] pending_stores [0:3];
	reg [3:0] rollback;
	wire [3:0] send_request;
	wire [1:0] send_grant_idx;
	wire [3:0] send_grant_oh;
	rr_arbiter #(.NUM_REQUESTERS(4)) request_arbiter(
		.request(send_request),
		.update_lru(1'b1),
		.grant_oh(send_grant_oh),
		.clk(clk),
		.reset(reset)
	);
	oh_to_idx #(.NUM_SIGNALS(4)) oh_to_idx_send_grant(
		.index(send_grant_idx),
		.one_hot(send_grant_oh)
	);
	genvar _gv_thread_idx_5;
	function automatic [1:0] sv2v_cast_2;
		input reg [1:0] inp;
		sv2v_cast_2 = inp;
	endfunction
	generate
		for (_gv_thread_idx_5 = 0; _gv_thread_idx_5 < 4; _gv_thread_idx_5 = _gv_thread_idx_5 + 1) begin : thread_store_buf_gen
			localparam thread_idx = _gv_thread_idx_5;
			wire update_store_entry;
			wire can_write_combine;
			wire store_requested_this_entry;
			wire send_this_cycle;
			wire restarted_sync_request;
			wire got_response_this_entry;
			wire membar_requested_this_entry;
			wire enqueue_cache_control;
			assign send_request[thread_idx] = pending_stores[thread_idx][602] && !pending_stores[thread_idx][606];
			assign store_requested_this_entry = dd_store_en && (dd_store_thread_idx == sv2v_cast_2(thread_idx));
			assign membar_requested_this_entry = dd_membar_en && (dd_store_thread_idx == sv2v_cast_2(thread_idx));
			assign send_this_cycle = send_grant_oh[thread_idx] && storebuf_dequeue_ack;
			assign can_write_combine = (((((((((pending_stores[thread_idx][602] && (pending_stores[thread_idx][25-:26] == dd_store_addr)) && !pending_stores[thread_idx][609]) && !pending_stores[thread_idx][608]) && !pending_stores[thread_idx][607]) && !dd_store_sync) && !pending_stores[thread_idx][606]) && !send_this_cycle) && !dd_flush_en) && !dd_iinvalidate_en) && !dd_dinvalidate_en;
			assign restarted_sync_request = (pending_stores[thread_idx][602] && pending_stores[thread_idx][605]) && pending_stores[thread_idx][610];
			assign update_store_entry = (store_requested_this_entry && ((!pending_stores[thread_idx][602] || can_write_combine) || got_response_this_entry)) && !restarted_sync_request;
			assign got_response_this_entry = storebuf_l2_response_valid && (storebuf_l2_response_idx == sv2v_cast_2(thread_idx));
			assign sq_wake_bitmap[thread_idx] = got_response_this_entry && pending_stores[thread_idx][603];
			assign enqueue_cache_control = ((dd_store_thread_idx == sv2v_cast_2(thread_idx)) && (!pending_stores[thread_idx][602] || got_response_this_entry)) && ((dd_flush_en || dd_dinvalidate_en) || dd_iinvalidate_en);
			assign sq_store_sync_pending[thread_idx] = pending_stores[thread_idx][602] && pending_stores[thread_idx][610];
			always @(*) begin
				if (_sv2v_0)
					;
				rollback[thread_idx] = 0;
				if ((dd_store_thread_idx == sv2v_cast_2(thread_idx)) && (((dd_flush_en || dd_dinvalidate_en) || dd_iinvalidate_en) || dd_store_en)) begin
					if (dd_store_sync)
						rollback[thread_idx] = !restarted_sync_request;
					else if ((pending_stores[thread_idx][602] && !can_write_combine) && !got_response_this_entry)
						rollback[thread_idx] = 1;
				end
				else if ((membar_requested_this_entry && pending_stores[thread_idx][602]) && !got_response_this_entry)
					rollback[thread_idx] = 1;
			end
			always @(posedge clk or posedge reset)
				if (reset)
					pending_stores[thread_idx] <= 0;
				else begin
					if (((((dd_store_en || dd_flush_en) || dd_membar_en) || dd_iinvalidate_en) || dd_dinvalidate_en) && (dd_store_thread_idx == thread_idx))
						;
					if (((dd_store_en && (dd_store_thread_idx == thread_idx)) && pending_stores[thread_idx][610]) && pending_stores[thread_idx][602])
						;
					if (send_this_cycle)
						pending_stores[thread_idx][606] <= 1;
					if (update_store_entry) begin
						begin : sv2v_autoblock_1
							reg signed [31:0] byte_lane;
							for (byte_lane = 0; byte_lane < defines_CACHE_LINE_BYTES; byte_lane = byte_lane + 1)
								if (dd_store_mask[byte_lane])
									pending_stores[thread_idx][90 + (byte_lane * 8)+:8] <= dd_store_data[byte_lane * 8+:8];
						end
						if (can_write_combine)
							pending_stores[thread_idx][89-:64] <= pending_stores[thread_idx][89-:64] | dd_store_mask;
						else
							pending_stores[thread_idx][89-:64] <= dd_store_mask;
					end
					if (sq_wake_bitmap[thread_idx])
						pending_stores[thread_idx][603] <= 0;
					else if (rollback[thread_idx])
						pending_stores[thread_idx][603] <= 1;
					if (store_requested_this_entry) begin
						if (restarted_sync_request)
							pending_stores[thread_idx][602] <= 0;
						else if (update_store_entry && !can_write_combine) begin
							pending_stores[thread_idx][602] <= 1;
							pending_stores[thread_idx][25-:26] <= dd_store_addr;
							pending_stores[thread_idx][610] <= dd_store_sync;
							pending_stores[thread_idx][609] <= 0;
							pending_stores[thread_idx][608] <= 0;
							pending_stores[thread_idx][607] <= 0;
							pending_stores[thread_idx][606] <= 0;
							pending_stores[thread_idx][605] <= 0;
						end
					end
					else if (enqueue_cache_control) begin
						pending_stores[thread_idx][602] <= 1;
						pending_stores[thread_idx][25-:26] <= dd_store_addr;
						pending_stores[thread_idx][610] <= 0;
						pending_stores[thread_idx][609] <= dd_flush_en;
						pending_stores[thread_idx][608] <= dd_iinvalidate_en;
						pending_stores[thread_idx][607] <= dd_dinvalidate_en;
						pending_stores[thread_idx][606] <= 0;
						pending_stores[thread_idx][605] <= 0;
					end
					if ((got_response_this_entry && (!store_requested_this_entry || !update_store_entry)) && !enqueue_cache_control) begin
						if (pending_stores[thread_idx][610]) begin
							pending_stores[thread_idx][605] <= 1;
							pending_stores[thread_idx][604] <= storebuf_l2_sync_success;
						end
						else
							pending_stores[thread_idx][602] <= 0;
					end
				end
		end
	endgenerate
	assign sq_dequeue_ready = |send_grant_oh;
	assign sq_dequeue_idx = send_grant_idx;
	assign sq_dequeue_addr = pending_stores[send_grant_idx][25-:26];
	assign sq_dequeue_mask = pending_stores[send_grant_idx][89-:64];
	assign sq_dequeue_data = pending_stores[send_grant_idx][601-:512];
	assign sq_dequeue_sync = pending_stores[send_grant_idx][610];
	assign sq_dequeue_flush = pending_stores[send_grant_idx][609];
	assign sq_dequeue_iinvalidate = pending_stores[send_grant_idx][608];
	assign sq_dequeue_dinvalidate = pending_stores[send_grant_idx][607];
	always @(posedge clk) begin
		sq_store_bypass_data <= pending_stores[dd_store_bypass_thread_idx][601-:512];
		if (((((dd_store_bypass_addr == pending_stores[dd_store_bypass_thread_idx][25-:26]) && pending_stores[dd_store_bypass_thread_idx][602]) && !pending_stores[dd_store_bypass_thread_idx][609]) && !pending_stores[dd_store_bypass_thread_idx][608]) && !pending_stores[dd_store_bypass_thread_idx][607])
			sq_store_bypass_mask <= pending_stores[dd_store_bypass_thread_idx][89-:64];
		else
			sq_store_bypass_mask <= 0;
		sq_store_sync_success <= pending_stores[dd_store_thread_idx][604];
	end
	always @(posedge clk or posedge reset)
		if (reset)
			sq_rollback_en <= 1'sb0;
		else
			sq_rollback_en <= |rollback;
	initial _sv2v_0 = 0;
endmodule
module l2_cache_arb_stage (
	clk,
	reset,
	l2i_request_valid,
	l2i_request,
	l2_ready,
	l2a_request_valid,
	l2a_request,
	l2a_data_from_memory,
	l2a_l2_fill,
	l2a_restarted_flush,
	l2bi_request_valid,
	l2bi_request,
	l2bi_data_from_memory,
	l2bi_stall,
	l2bi_collided_miss
);
	input clk;
	input reset;
	input [0:0] l2i_request_valid;
	localparam defines_NUM_VECTOR_LANES = 16;
	localparam defines_CACHE_LINE_BYTES = 64;
	localparam defines_CACHE_LINE_BITS = 512;
	localparam defines_CACHE_LINE_OFFSET_WIDTH = 6;
	input wire [611:0] l2i_request;
	output wire [0:0] l2_ready;
	output reg l2a_request_valid;
	output reg [611:0] l2a_request;
	output reg [511:0] l2a_data_from_memory;
	output reg l2a_l2_fill;
	output reg l2a_restarted_flush;
	input l2bi_request_valid;
	input wire [611:0] l2bi_request;
	input wire [511:0] l2bi_data_from_memory;
	input l2bi_stall;
	input l2bi_collided_miss;
	wire can_accept_request;
	wire [611:0] grant_request;
	wire [0:0] grant_oh;
	wire restarted_flush;
	assign can_accept_request = !l2bi_request_valid && !l2bi_stall;
	assign restarted_flush = l2bi_request[605-:3] == 3'd4;
	genvar _gv_request_idx_2;
	generate
		for (_gv_request_idx_2 = 0; _gv_request_idx_2 < 1; _gv_request_idx_2 = _gv_request_idx_2 + 1) begin : handshake_gen
			localparam request_idx = _gv_request_idx_2;
			assign l2_ready[request_idx] = grant_oh[request_idx] && can_accept_request;
		end
	endgenerate
	localparam defines_CORE_ID_WIDTH = 0;
	generate
		if (1) begin : genblk2
			assign grant_oh[0] = l2i_request_valid[0];
			assign grant_request = l2i_request[0+:612];
		end
	endgenerate
	always @(posedge clk) begin
		l2a_data_from_memory <= l2bi_data_from_memory;
		if (l2bi_request_valid) begin
			l2a_request <= l2bi_request;
			l2a_l2_fill <= !l2bi_collided_miss && !restarted_flush;
			l2a_restarted_flush <= restarted_flush;
		end
		else begin
			l2a_request <= grant_request;
			l2a_l2_fill <= 0;
			l2a_restarted_flush <= 0;
		end
	end
	always @(posedge clk or posedge reset)
		if (reset)
			l2a_request_valid <= 0;
		else if (l2bi_request_valid)
			l2a_request_valid <= 1;
		else if (|l2i_request_valid && can_accept_request)
			l2a_request_valid <= 1;
		else
			l2a_request_valid <= 0;
endmodule
module l2_cache_pending_miss_cam (
	clk,
	reset,
	request_valid,
	request_addr,
	enqueue_fill_request,
	l2r_l2_fill,
	duplicate_request
);
	parameter QUEUE_SIZE = 16;
	parameter QUEUE_ADDR_WIDTH = $clog2(QUEUE_SIZE);
	input clk;
	input reset;
	input request_valid;
	localparam defines_NUM_VECTOR_LANES = 16;
	localparam defines_CACHE_LINE_BYTES = 64;
	localparam defines_CACHE_LINE_OFFSET_WIDTH = 6;
	input wire [25:0] request_addr;
	input enqueue_fill_request;
	input l2r_l2_fill;
	output wire duplicate_request;
	wire [QUEUE_ADDR_WIDTH - 1:0] cam_hit_entry;
	wire cam_hit;
	reg [QUEUE_SIZE - 1:0] empty_entries;
	wire [QUEUE_SIZE - 1:0] next_empty_oh;
	wire [QUEUE_ADDR_WIDTH - 1:0] next_empty;
	function automatic signed [QUEUE_SIZE - 1:0] sv2v_cast_C61BA_signed;
		input reg signed [QUEUE_SIZE - 1:0] inp;
		sv2v_cast_C61BA_signed = inp;
	endfunction
	assign next_empty_oh = empty_entries & ~(empty_entries - sv2v_cast_C61BA_signed(1));
	oh_to_idx #(.NUM_SIGNALS(QUEUE_SIZE)) oh_to_idx_next_empty(
		.one_hot(next_empty_oh),
		.index(next_empty)
	);
	assign duplicate_request = cam_hit && !l2r_l2_fill;
	cam #(
		.NUM_ENTRIES(QUEUE_SIZE),
		.KEY_WIDTH(26)
	) cam_pending_miss(
		.clk(clk),
		.reset(reset),
		.lookup_key(request_addr),
		.lookup_idx(cam_hit_entry),
		.lookup_hit(cam_hit),
		.update_en(request_valid && (cam_hit ? l2r_l2_fill : enqueue_fill_request)),
		.update_key(request_addr),
		.update_idx((cam_hit ? cam_hit_entry : next_empty)),
		.update_valid((cam_hit ? !l2r_l2_fill : enqueue_fill_request))
	);
	always @(posedge clk or posedge reset)
		if (reset)
			empty_entries <= {QUEUE_SIZE {1'b1}};
		else if (cam_hit & l2r_l2_fill)
			empty_entries[cam_hit_entry] <= 1'b1;
		else if (!cam_hit && enqueue_fill_request)
			empty_entries[next_empty] <= 1'b0;
endmodule
module l2_cache_read_stage (
	clk,
	reset,
	l2t_request_valid,
	l2t_request,
	l2t_valid,
	l2t_tag,
	l2t_dirty,
	l2t_l2_fill,
	l2t_restarted_flush,
	l2t_fill_way,
	l2t_data_from_memory,
	l2r_update_dirty_en,
	l2r_update_dirty_set,
	l2r_update_dirty_value,
	l2r_update_tag_en,
	l2r_update_tag_set,
	l2r_update_tag_valid,
	l2r_update_tag_value,
	l2r_update_lru_en,
	l2r_update_lru_hit_way,
	l2u_write_en,
	l2u_write_addr,
	l2u_write_data,
	l2r_request_valid,
	l2r_request,
	l2r_data,
	l2r_cache_hit,
	l2r_hit_cache_idx,
	l2r_l2_fill,
	l2r_restarted_flush,
	l2r_data_from_memory,
	l2r_store_sync_success,
	l2r_writeback_tag,
	l2r_needs_writeback,
	l2r_perf_l2_miss,
	l2r_perf_l2_hit
);
	input clk;
	input reset;
	input l2t_request_valid;
	localparam defines_NUM_VECTOR_LANES = 16;
	localparam defines_CACHE_LINE_BYTES = 64;
	localparam defines_CACHE_LINE_BITS = 512;
	localparam defines_CACHE_LINE_OFFSET_WIDTH = 6;
	input wire [611:0] l2t_request;
	input [0:7] l2t_valid;
	input wire [143:0] l2t_tag;
	input [0:7] l2t_dirty;
	input l2t_l2_fill;
	input l2t_restarted_flush;
	input wire [2:0] l2t_fill_way;
	input wire [511:0] l2t_data_from_memory;
	output wire [7:0] l2r_update_dirty_en;
	output wire [7:0] l2r_update_dirty_set;
	output wire l2r_update_dirty_value;
	output wire [7:0] l2r_update_tag_en;
	output wire [7:0] l2r_update_tag_set;
	output wire l2r_update_tag_valid;
	output wire [17:0] l2r_update_tag_value;
	output wire l2r_update_lru_en;
	output wire [2:0] l2r_update_lru_hit_way;
	input l2u_write_en;
	input [10:0] l2u_write_addr;
	input wire [511:0] l2u_write_data;
	output reg l2r_request_valid;
	output reg [611:0] l2r_request;
	output wire [511:0] l2r_data;
	output reg l2r_cache_hit;
	output reg [10:0] l2r_hit_cache_idx;
	output reg l2r_l2_fill;
	output reg l2r_restarted_flush;
	output reg [511:0] l2r_data_from_memory;
	output reg l2r_store_sync_success;
	output reg [17:0] l2r_writeback_tag;
	output reg l2r_needs_writeback;
	output reg l2r_perf_l2_miss;
	output reg l2r_perf_l2_hit;
	localparam defines_TOTAL_THREADS = 4;
	localparam GLOBAL_THREAD_IDX_WIDTH = 2;
	reg [25:0] load_sync_address [0:3];
	reg load_sync_address_valid [0:3];
	wire can_store_sync;
	wire [7:0] hit_way_oh;
	wire cache_hit;
	wire [2:0] hit_way_idx;
	wire [10:0] read_address;
	wire load;
	wire store;
	wire update_dirty;
	wire update_tag;
	wire flush_first_pass;
	wire [2:0] writeback_way;
	wire hit_or_miss;
	wire dinvalidate;
	wire [2:0] tag_update_way;
	wire [1:0] request_sync_slot;
	assign load = (l2t_request[605-:3] == 3'd0) || (l2t_request[605-:3] == 3'd1);
	assign store = (l2t_request[605-:3] == 3'd2) || (l2t_request[605-:3] == 3'd3);
	assign writeback_way = (l2t_request[605-:3] == 3'd4 ? hit_way_idx : l2t_fill_way);
	assign dinvalidate = l2t_request[605-:3] == 3'd6;
	genvar _gv_way_idx_6;
	generate
		for (_gv_way_idx_6 = 0; _gv_way_idx_6 < 8; _gv_way_idx_6 = _gv_way_idx_6 + 1) begin : hit_way_gen
			localparam way_idx = _gv_way_idx_6;
			assign hit_way_oh[way_idx] = (l2t_request[601-:18] == l2t_tag[0 + ((7 - way_idx) * 18)+:18]) && l2t_valid[way_idx];
		end
	endgenerate
	assign cache_hit = |hit_way_oh && l2t_request_valid;
	oh_to_idx #(.NUM_SIGNALS(8)) oh_to_idx_hit_way(
		.one_hot(hit_way_oh),
		.index(hit_way_idx)
	);
	assign read_address = {(l2t_l2_fill ? l2t_fill_way : hit_way_idx), l2t_request[583-:8]};
	fakeram_1r1w_512x2048 #(
		.DATA_WIDTH(defines_CACHE_LINE_BITS),
		.SIZE(2048),
		.READ_DURING_WRITE("NEW_DATA")
	) sram_l2_data(
		.read_en(l2t_request_valid && (cache_hit || l2t_l2_fill)),
		.read_addr(read_address),
		.read_data(l2r_data),
		.write_en(l2u_write_en),
		.write_addr(l2u_write_addr),
		.write_data(l2u_write_data),
		.*
	);
	assign flush_first_pass = (l2t_request[605-:3] == 3'd4) && !l2t_restarted_flush;
	assign update_dirty = l2t_request_valid && (l2t_l2_fill || (cache_hit && (store || flush_first_pass)));
	assign l2r_update_dirty_set = l2t_request[583-:8];
	assign l2r_update_dirty_value = store;
	genvar _gv_dirty_update_idx_1;
	function automatic [2:0] sv2v_cast_3;
		input reg [2:0] inp;
		sv2v_cast_3 = inp;
	endfunction
	generate
		for (_gv_dirty_update_idx_1 = 0; _gv_dirty_update_idx_1 < 8; _gv_dirty_update_idx_1 = _gv_dirty_update_idx_1 + 1) begin : dirty_update_gen
			localparam dirty_update_idx = _gv_dirty_update_idx_1;
			assign l2r_update_dirty_en[dirty_update_idx] = update_dirty && (l2t_l2_fill ? l2t_fill_way == sv2v_cast_3(dirty_update_idx) : hit_way_oh[dirty_update_idx]);
		end
	endgenerate
	assign update_tag = l2t_l2_fill || (cache_hit && dinvalidate);
	assign tag_update_way = (l2t_l2_fill ? l2t_fill_way : hit_way_idx);
	genvar _gv_tag_idx_1;
	generate
		for (_gv_tag_idx_1 = 0; _gv_tag_idx_1 < 8; _gv_tag_idx_1 = _gv_tag_idx_1 + 1) begin : tag_update_gen
			localparam tag_idx = _gv_tag_idx_1;
			assign l2r_update_tag_en[tag_idx] = update_tag && (tag_update_way == sv2v_cast_3(tag_idx));
		end
	endgenerate
	assign l2r_update_tag_set = l2t_request[583-:8];
	assign l2r_update_tag_valid = !dinvalidate;
	assign l2r_update_tag_value = l2t_request[601-:18];
	assign l2r_update_lru_en = cache_hit && (load || store);
	assign l2r_update_lru_hit_way = hit_way_idx;
	function automatic [1:0] sv2v_cast_2;
		input reg [1:0] inp;
		sv2v_cast_2 = inp;
	endfunction
	assign request_sync_slot = sv2v_cast_2({l2t_request[611-:4], l2t_request[607-:2]});
	assign can_store_sync = ((load_sync_address[request_sync_slot] == {l2t_request[601-:18], l2t_request[583-:8]}) && load_sync_address_valid[request_sync_slot]) && (l2t_request[605-:3] == 3'd3);
	assign hit_or_miss = (l2t_request_valid && (((l2t_request[605-:3] == 3'd2) || can_store_sync) || (l2t_request[605-:3] == 3'd0))) && !l2t_l2_fill;
	always @(posedge clk) begin
		l2r_request <= l2t_request;
		l2r_cache_hit <= cache_hit;
		l2r_l2_fill <= l2t_l2_fill;
		l2r_writeback_tag <= l2t_tag[0 + ((7 - writeback_way) * 18)+:18];
		l2r_needs_writeback <= l2t_dirty[writeback_way] && l2t_valid[writeback_way];
		l2r_data_from_memory <= l2t_data_from_memory;
		l2r_hit_cache_idx <= read_address;
		l2r_restarted_flush <= l2t_restarted_flush;
	end
	always @(posedge clk or posedge reset)
		if (reset) begin
			begin : sv2v_autoblock_1
				reg signed [31:0] i;
				for (i = 0; i < defines_TOTAL_THREADS; i = i + 1)
					begin
						load_sync_address_valid[i] <= 1'sb0;
						load_sync_address[i] <= 1'sb0;
					end
			end
			l2r_perf_l2_hit <= 1'sb0;
			l2r_perf_l2_miss <= 1'sb0;
			l2r_request_valid <= 1'sb0;
			l2r_store_sync_success <= 1'sb0;
		end
		else begin
			l2r_request_valid <= l2t_request_valid;
			if (l2t_request_valid && (cache_hit || l2t_l2_fill)) begin
				(* full_case, parallel_case *)
				case (l2t_request[605-:3])
					3'd1: begin
						load_sync_address[request_sync_slot] <= {l2t_request[601-:18], l2t_request[583-:8]};
						load_sync_address_valid[request_sync_slot] <= 1;
					end
					3'd2, 3'd3:
						if ((l2t_request[605-:3] == 3'd2) || can_store_sync) begin : sv2v_autoblock_2
							reg signed [31:0] entry_idx;
							for (entry_idx = 0; entry_idx < defines_TOTAL_THREADS; entry_idx = entry_idx + 1)
								if (load_sync_address[entry_idx] == {l2t_request[601-:18], l2t_request[583-:8]})
									load_sync_address_valid[entry_idx] <= 0;
						end
					default:
						;
				endcase
				l2r_store_sync_success <= can_store_sync;
			end
			else
				l2r_store_sync_success <= 0;
			l2r_perf_l2_miss <= hit_or_miss && !(|hit_way_oh);
			l2r_perf_l2_hit <= hit_or_miss && |hit_way_oh;
		end
endmodule
module l2_cache_tag_stage (
	clk,
	reset,
	l2a_request_valid,
	l2a_request,
	l2a_data_from_memory,
	l2a_l2_fill,
	l2a_restarted_flush,
	l2r_update_dirty_en,
	l2r_update_dirty_set,
	l2r_update_dirty_value,
	l2r_update_tag_en,
	l2r_update_tag_set,
	l2r_update_tag_valid,
	l2r_update_tag_value,
	l2r_update_lru_en,
	l2r_update_lru_hit_way,
	l2t_request_valid,
	l2t_request,
	l2t_valid,
	l2t_tag,
	l2t_dirty,
	l2t_l2_fill,
	l2t_fill_way,
	l2t_data_from_memory,
	l2t_restarted_flush
);
	input clk;
	input reset;
	input l2a_request_valid;
	localparam defines_NUM_VECTOR_LANES = 16;
	localparam defines_CACHE_LINE_BYTES = 64;
	localparam defines_CACHE_LINE_BITS = 512;
	localparam defines_CACHE_LINE_OFFSET_WIDTH = 6;
	input wire [611:0] l2a_request;
	input wire [511:0] l2a_data_from_memory;
	input l2a_l2_fill;
	input l2a_restarted_flush;
	input [7:0] l2r_update_dirty_en;
	input wire [7:0] l2r_update_dirty_set;
	input l2r_update_dirty_value;
	input [7:0] l2r_update_tag_en;
	input wire [7:0] l2r_update_tag_set;
	input l2r_update_tag_valid;
	input wire [17:0] l2r_update_tag_value;
	input l2r_update_lru_en;
	input wire [2:0] l2r_update_lru_hit_way;
	output reg l2t_request_valid;
	output reg [611:0] l2t_request;
	output reg [0:7] l2t_valid;
	output wire [143:0] l2t_tag;
	output wire [0:7] l2t_dirty;
	output reg l2t_l2_fill;
	output wire [2:0] l2t_fill_way;
	output reg [511:0] l2t_data_from_memory;
	output reg l2t_restarted_flush;
	cache_lru #(
		.NUM_SETS(256),
		.NUM_WAYS(8)
	) cache_lru(
		.fill_en(l2a_l2_fill),
		.fill_set(l2a_request[583-:8]),
		.fill_way(l2t_fill_way),
		.access_en(l2a_request_valid),
		.access_set(l2a_request[583-:8]),
		.update_en(l2r_update_lru_en),
		.update_way(l2r_update_lru_hit_way),
		.clk(clk),
		.reset(reset)
	);
	genvar _gv_way_idx_7;
	generate
		for (_gv_way_idx_7 = 0; _gv_way_idx_7 < 8; _gv_way_idx_7 = _gv_way_idx_7 + 1) begin : way_tags_gen
			localparam way_idx = _gv_way_idx_7;
			reg line_valid [0:255];
			fakeram_1r1w_18x256 #(
				.DATA_WIDTH(18),
				.SIZE(256),
				.READ_DURING_WRITE("NEW_DATA")
			) sram_tags(
				.read_en(l2a_request_valid),
				.read_addr(l2a_request[583-:8]),
				.read_data(l2t_tag[0 + ((7 - way_idx) * 18)+:18]),
				.write_en(l2r_update_tag_en[way_idx]),
				.write_addr(l2r_update_tag_set),
				.write_data(l2r_update_tag_value),
				.*
			);
			fakeram_1r1w_1x256 #(
				.DATA_WIDTH(1),
				.SIZE(256),
				.READ_DURING_WRITE("NEW_DATA")
			) sram_dirty_flags(
				.read_en(l2a_request_valid),
				.read_addr(l2a_request[583-:8]),
				.read_data(l2t_dirty[way_idx]),
				.write_en(l2r_update_dirty_en[way_idx]),
				.write_addr(l2r_update_dirty_set),
				.write_data(l2r_update_dirty_value),
				.*
			);
			always @(posedge clk or posedge reset)
				if (reset) begin : sv2v_autoblock_1
					reg signed [31:0] set_idx;
					for (set_idx = 0; set_idx < 256; set_idx = set_idx + 1)
						line_valid[set_idx] <= 0;
				end
				else if (l2r_update_tag_en[way_idx])
					line_valid[l2r_update_tag_set] <= l2r_update_tag_valid;
			always @(posedge clk)
				if (l2a_request_valid) begin
					if (l2r_update_tag_en[way_idx] && (l2r_update_tag_set == l2a_request[583-:8]))
						l2t_valid[way_idx] <= l2r_update_tag_valid;
					else
						l2t_valid[way_idx] <= line_valid[l2a_request[583-:8]];
				end
		end
	endgenerate
	always @(posedge clk) begin
		l2t_data_from_memory <= l2a_data_from_memory;
		l2t_request <= l2a_request;
		l2t_l2_fill <= l2a_l2_fill;
		l2t_restarted_flush <= l2a_restarted_flush;
	end
	always @(posedge clk or posedge reset)
		if (reset)
			l2t_request_valid <= 0;
		else
			l2t_request_valid <= l2a_request_valid;
endmodule
module l2_cache_update_stage (
	clk,
	reset,
	l2r_request_valid,
	l2r_request,
	l2r_data,
	l2r_cache_hit,
	l2r_hit_cache_idx,
	l2r_l2_fill,
	l2r_restarted_flush,
	l2r_data_from_memory,
	l2r_store_sync_success,
	l2r_needs_writeback,
	l2u_write_en,
	l2u_write_addr,
	l2u_write_data,
	l2_response_valid,
	l2_response
);
	reg _sv2v_0;
	input clk;
	input reset;
	input l2r_request_valid;
	localparam defines_NUM_VECTOR_LANES = 16;
	localparam defines_CACHE_LINE_BYTES = 64;
	localparam defines_CACHE_LINE_BITS = 512;
	localparam defines_CACHE_LINE_OFFSET_WIDTH = 6;
	input wire [611:0] l2r_request;
	input wire [511:0] l2r_data;
	input l2r_cache_hit;
	input wire [10:0] l2r_hit_cache_idx;
	input l2r_l2_fill;
	input l2r_restarted_flush;
	input wire [511:0] l2r_data_from_memory;
	input l2r_store_sync_success;
	input l2r_needs_writeback;
	output wire l2u_write_en;
	output wire [10:0] l2u_write_addr;
	output wire [511:0] l2u_write_data;
	output reg l2_response_valid;
	output reg [548:0] l2_response;
	wire [511:0] original_data;
	wire update_data;
	reg [2:0] response_type;
	wire completed_flush;
	assign original_data = (l2r_l2_fill ? l2r_data_from_memory : l2r_data);
	assign update_data = (l2r_request[605-:3] == 3'd2) || ((l2r_request[605-:3] == 3'd3) && l2r_store_sync_success);
	genvar _gv_byte_lane_1;
	generate
		for (_gv_byte_lane_1 = 0; _gv_byte_lane_1 < defines_CACHE_LINE_BYTES; _gv_byte_lane_1 = _gv_byte_lane_1 + 1) begin : lane_mask_gen
			localparam byte_lane = _gv_byte_lane_1;
			assign l2u_write_data[byte_lane * 8+:8] = (l2r_request[512 + byte_lane] && update_data ? l2r_request[0 + (byte_lane * 8)+:8] : original_data[byte_lane * 8+:8]);
		end
	endgenerate
	assign l2u_write_en = l2r_request_valid && (l2r_l2_fill || (l2r_cache_hit && ((l2r_request[605-:3] == 3'd2) || (l2r_request[605-:3] == 3'd3))));
	assign l2u_write_addr = l2r_hit_cache_idx;
	always @(*) begin
		if (_sv2v_0)
			;
		(* full_case, parallel_case *)
		case (l2r_request[605-:3])
			3'd0, 3'd1: response_type = 3'd0;
			3'd2, 3'd3: response_type = 3'd1;
			3'd4: response_type = 3'd2;
			3'd5: response_type = 3'd3;
			3'd6: response_type = 3'd4;
			default: response_type = 3'd0;
		endcase
	end
	assign completed_flush = (l2r_request[605-:3] == 3'd4) && ((l2r_restarted_flush || !l2r_cache_hit) || !l2r_needs_writeback);
	always @(posedge clk or posedge reset)
		if (reset)
			l2_response_valid <= 0;
		else if (l2r_request_valid && (((((l2r_cache_hit && (l2r_request[605-:3] != 3'd4)) || l2r_l2_fill) || completed_flush) || (l2r_request[605-:3] == 3'd6)) || (l2r_request[605-:3] == 3'd5)))
			l2_response_valid <= 1;
		else
			l2_response_valid <= 0;
	always @(posedge clk) begin
		l2_response[548] <= (l2r_request[605-:3] == 3'd3 ? l2r_store_sync_success : 1'b1);
		l2_response[547-:4] <= l2r_request[611-:4];
		l2_response[543-:2] <= l2r_request[607-:2];
		l2_response[541-:3] <= response_type;
		l2_response[538] <= l2r_request[602];
		l2_response[511-:defines_CACHE_LINE_BITS] <= l2u_write_data;
		l2_response[537-:26] <= l2r_request[601-:26];
	end
	initial _sv2v_0 = 0;
endmodule
module oh_to_idx (
	one_hot,
	index
);
	reg _sv2v_0;
	parameter NUM_SIGNALS = 4;
	parameter DIRECTION = "LSB0";
	parameter INDEX_WIDTH = $clog2(NUM_SIGNALS);
	input [NUM_SIGNALS - 1:0] one_hot;
	output reg [INDEX_WIDTH - 1:0] index;
	function automatic signed [INDEX_WIDTH - 1:0] sv2v_cast_BBE12_signed;
		input reg signed [INDEX_WIDTH - 1:0] inp;
		sv2v_cast_BBE12_signed = inp;
	endfunction
	always @(*) begin : convert
		if (_sv2v_0)
			;
		index = 0;
		begin : sv2v_autoblock_1
			reg signed [31:0] oh_index;
			for (oh_index = 0; oh_index < NUM_SIGNALS; oh_index = oh_index + 1)
				if (one_hot[oh_index]) begin
					if (DIRECTION == "LSB0")
						index = index | oh_index[INDEX_WIDTH - 1:0];
					else
						index = index | sv2v_cast_BBE12_signed((NUM_SIGNALS - oh_index) - 1);
				end
		end
	end
	initial _sv2v_0 = 0;
endmodule
module operand_fetch_stage (
	clk,
	reset,
	ts_instruction_valid,
	ts_instruction,
	ts_thread_idx,
	ts_subcycle,
	of_operand1,
	of_operand2,
	of_mask_value,
	of_store_value,
	of_instruction,
	of_instruction_valid,
	of_thread_idx,
	of_subcycle,
	wb_rollback_en,
	wb_rollback_thread_idx,
	wb_writeback_en,
	wb_writeback_thread_idx,
	wb_writeback_vector,
	wb_writeback_value,
	wb_writeback_mask,
	wb_writeback_reg
);
	reg _sv2v_0;
	input clk;
	input reset;
	input ts_instruction_valid;
	localparam defines_NUM_VECTOR_LANES = 16;
	input wire [141:0] ts_instruction;
	input wire [1:0] ts_thread_idx;
	input wire [3:0] ts_subcycle;
	output reg [511:0] of_operand1;
	output reg [511:0] of_operand2;
	output reg [15:0] of_mask_value;
	output wire [511:0] of_store_value;
	output reg [141:0] of_instruction;
	output reg of_instruction_valid;
	output reg [1:0] of_thread_idx;
	output reg [3:0] of_subcycle;
	input wb_rollback_en;
	input wire [1:0] wb_rollback_thread_idx;
	input wb_writeback_en;
	input wire [1:0] wb_writeback_thread_idx;
	input wb_writeback_vector;
	input wire [511:0] wb_writeback_value;
	input wire [15:0] wb_writeback_mask;
	input wire [4:0] wb_writeback_reg;
	wire [31:0] scalar_val1;
	wire [31:0] scalar_val2;
	wire [511:0] vector_val1;
	wire [511:0] vector_val2;
	fakeram_2r1w_32x128 #(
		.DATA_WIDTH(32),
		.SIZE(128),
		.READ_DURING_WRITE("DONT_CARE")
	) scalar_registers(
		.read1_en(ts_instruction_valid && ts_instruction[101]),
		.read1_addr({ts_thread_idx, ts_instruction[100-:5]}),
		.read1_data(scalar_val1),
		.read2_en(ts_instruction_valid && ts_instruction[95]),
		.read2_addr({ts_thread_idx, ts_instruction[94-:5]}),
		.read2_data(scalar_val2),
		.write_en(wb_writeback_en && !wb_writeback_vector),
		.write_addr({wb_writeback_thread_idx, wb_writeback_reg}),
		.write_data(wb_writeback_value[0+:32]),
		.*
	);
	genvar _gv_lane_2;
	generate
		for (_gv_lane_2 = 0; _gv_lane_2 < defines_NUM_VECTOR_LANES; _gv_lane_2 = _gv_lane_2 + 1) begin : vector_lane_gen
			localparam lane = _gv_lane_2;
			fakeram_2r1w_32x128 #(
				.DATA_WIDTH(32),
				.SIZE(128),
				.READ_DURING_WRITE("DONT_CARE")
			) vector_registers(
				.read1_en(ts_instruction[89]),
				.read1_addr({ts_thread_idx, ts_instruction[88-:5]}),
				.read1_data(vector_val1[lane * 32+:32]),
				.read2_en(ts_instruction[83]),
				.read2_addr({ts_thread_idx, ts_instruction[82-:5]}),
				.read2_data(vector_val2[lane * 32+:32]),
				.write_en((wb_writeback_en && wb_writeback_vector) && wb_writeback_mask[(defines_NUM_VECTOR_LANES - lane) - 1]),
				.write_addr({wb_writeback_thread_idx, wb_writeback_reg}),
				.write_data(wb_writeback_value[lane * 32+:32]),
				.*
			);
		end
	endgenerate
	always @(posedge clk or posedge reset)
		if (reset)
			of_instruction_valid <= 0;
		else
			of_instruction_valid <= ts_instruction_valid && (!wb_rollback_en || (wb_rollback_thread_idx != ts_thread_idx));
	always @(posedge clk) begin
		of_instruction <= ts_instruction;
		of_thread_idx <= ts_thread_idx;
		of_subcycle <= ts_subcycle;
	end
	assign of_store_value = (of_instruction[59] ? vector_val2 : {{15 {32'd0}}, scalar_val2});
	always @(*) begin
		if (_sv2v_0)
			;
		(* full_case, parallel_case *)
		case (of_instruction[62])
			1'd0: of_operand1 = vector_val1;
			default: of_operand1 = {defines_NUM_VECTOR_LANES {scalar_val1}};
		endcase
		(* full_case, parallel_case *)
		case (of_instruction[61-:2])
			2'd0: of_operand2 = {defines_NUM_VECTOR_LANES {scalar_val2}};
			2'd1: of_operand2 = vector_val2;
			default: of_operand2 = {defines_NUM_VECTOR_LANES {of_instruction[58-:32]}};
		endcase
		(* full_case, parallel_case *)
		case (of_instruction[64-:2])
			2'd0: of_mask_value = scalar_val1[15:0];
			2'd1: of_mask_value = scalar_val2[15:0];
			default: of_mask_value = {defines_NUM_VECTOR_LANES {1'b1}};
		endcase
	end
	initial _sv2v_0 = 0;
endmodule
module performance_counters (
	clk,
	reset,
	perf_events,
	perf_event_select,
	perf_event_count
);
	parameter NUM_EVENTS = 1;
	parameter EVENT_IDX_WIDTH = $clog2(NUM_EVENTS);
	parameter NUM_COUNTERS = 2;
	parameter COUNTER_IDX_WIDTH = $clog2(NUM_COUNTERS);
	input clk;
	input reset;
	input [NUM_EVENTS - 1:0] perf_events;
	input [(NUM_COUNTERS * EVENT_IDX_WIDTH) - 1:0] perf_event_select;
	output reg [(NUM_COUNTERS * 64) - 1:0] perf_event_count;
	always @(posedge clk or posedge reset) begin : update
		if (reset) begin : sv2v_autoblock_1
			reg signed [31:0] i;
			for (i = 0; i < NUM_COUNTERS; i = i + 1)
				perf_event_count[i * 64+:64] <= 0;
		end
		else begin : sv2v_autoblock_2
			reg signed [31:0] i;
			for (i = 0; i < NUM_COUNTERS; i = i + 1)
				if (perf_events[perf_event_select[i * EVENT_IDX_WIDTH+:EVENT_IDX_WIDTH]])
					perf_event_count[i * 64+:64] <= perf_event_count[i * 64+:64] + 1;
		end
	end
endmodule
module reciprocal_rom (
	significand,
	reciprocal_estimate
);
	reg _sv2v_0;
	input [5:0] significand;
	output reg [5:0] reciprocal_estimate;
	always @(*) begin
		if (_sv2v_0)
			;
		case (significand)
			6'h00: reciprocal_estimate = 6'h00;
			6'h01: reciprocal_estimate = 6'h3e;
			6'h02: reciprocal_estimate = 6'h3c;
			6'h03: reciprocal_estimate = 6'h3a;
			6'h04: reciprocal_estimate = 6'h38;
			6'h05: reciprocal_estimate = 6'h36;
			6'h06: reciprocal_estimate = 6'h35;
			6'h07: reciprocal_estimate = 6'h33;
			6'h08: reciprocal_estimate = 6'h31;
			6'h09: reciprocal_estimate = 6'h30;
			6'h0a: reciprocal_estimate = 6'h2e;
			6'h0b: reciprocal_estimate = 6'h2d;
			6'h0c: reciprocal_estimate = 6'h2b;
			6'h0d: reciprocal_estimate = 6'h2a;
			6'h0e: reciprocal_estimate = 6'h29;
			6'h0f: reciprocal_estimate = 6'h27;
			6'h10: reciprocal_estimate = 6'h26;
			6'h11: reciprocal_estimate = 6'h25;
			6'h12: reciprocal_estimate = 6'h23;
			6'h13: reciprocal_estimate = 6'h22;
			6'h14: reciprocal_estimate = 6'h21;
			6'h15: reciprocal_estimate = 6'h20;
			6'h16: reciprocal_estimate = 6'h1f;
			6'h17: reciprocal_estimate = 6'h1e;
			6'h18: reciprocal_estimate = 6'h1d;
			6'h19: reciprocal_estimate = 6'h1c;
			6'h1a: reciprocal_estimate = 6'h1b;
			6'h1b: reciprocal_estimate = 6'h1a;
			6'h1c: reciprocal_estimate = 6'h19;
			6'h1d: reciprocal_estimate = 6'h18;
			6'h1e: reciprocal_estimate = 6'h17;
			6'h1f: reciprocal_estimate = 6'h16;
			6'h20: reciprocal_estimate = 6'h15;
			6'h21: reciprocal_estimate = 6'h14;
			6'h22: reciprocal_estimate = 6'h13;
			6'h23: reciprocal_estimate = 6'h12;
			6'h24: reciprocal_estimate = 6'h11;
			6'h25: reciprocal_estimate = 6'h11;
			6'h26: reciprocal_estimate = 6'h10;
			6'h27: reciprocal_estimate = 6'h0f;
			6'h28: reciprocal_estimate = 6'h0e;
			6'h29: reciprocal_estimate = 6'h0e;
			6'h2a: reciprocal_estimate = 6'h0d;
			6'h2b: reciprocal_estimate = 6'h0c;
			6'h2c: reciprocal_estimate = 6'h0b;
			6'h2d: reciprocal_estimate = 6'h0b;
			6'h2e: reciprocal_estimate = 6'h0a;
			6'h2f: reciprocal_estimate = 6'h09;
			6'h30: reciprocal_estimate = 6'h09;
			6'h31: reciprocal_estimate = 6'h08;
			6'h32: reciprocal_estimate = 6'h07;
			6'h33: reciprocal_estimate = 6'h07;
			6'h34: reciprocal_estimate = 6'h06;
			6'h35: reciprocal_estimate = 6'h06;
			6'h36: reciprocal_estimate = 6'h05;
			6'h37: reciprocal_estimate = 6'h04;
			6'h38: reciprocal_estimate = 6'h04;
			6'h39: reciprocal_estimate = 6'h03;
			6'h3a: reciprocal_estimate = 6'h03;
			6'h3b: reciprocal_estimate = 6'h02;
			6'h3c: reciprocal_estimate = 6'h02;
			6'h3d: reciprocal_estimate = 6'h01;
			6'h3e: reciprocal_estimate = 6'h01;
			6'h3f: reciprocal_estimate = 6'h00;
			default: reciprocal_estimate = 6'h00;
		endcase
	end
	initial _sv2v_0 = 0;
endmodule
module rr_arbiter (
	clk,
	reset,
	request,
	update_lru,
	grant_oh
);
	reg _sv2v_0;
	parameter NUM_REQUESTERS = 4;
	input clk;
	input reset;
	input [NUM_REQUESTERS - 1:0] request;
	input update_lru;
	output reg [NUM_REQUESTERS - 1:0] grant_oh;
	wire [NUM_REQUESTERS - 1:0] priority_oh_nxt;
	reg [NUM_REQUESTERS - 1:0] priority_oh;
	localparam BIT_IDX_WIDTH = $clog2(NUM_REQUESTERS);
	always @(*) begin
		if (_sv2v_0)
			;
		begin : sv2v_autoblock_1
			reg signed [31:0] grant_idx;
			for (grant_idx = 0; grant_idx < NUM_REQUESTERS; grant_idx = grant_idx + 1)
				begin
					grant_oh[grant_idx] = 0;
					begin : sv2v_autoblock_2
						reg signed [31:0] priority_idx;
						for (priority_idx = 0; priority_idx < NUM_REQUESTERS; priority_idx = priority_idx + 1)
							begin : sv2v_autoblock_3
								reg granted;
								granted = request[grant_idx] & priority_oh[priority_idx];
								begin : sv2v_autoblock_4
									reg [BIT_IDX_WIDTH - 1:0] bit_idx;
									for (bit_idx = priority_idx[BIT_IDX_WIDTH - 1:0] % NUM_REQUESTERS; bit_idx != grant_idx[BIT_IDX_WIDTH - 1:0]; bit_idx = (bit_idx + 1) % NUM_REQUESTERS)
										granted = granted & !request[bit_idx];
								end
								grant_oh[grant_idx] = grant_oh[grant_idx] | granted;
							end
					end
				end
		end
	end
	assign priority_oh_nxt = {grant_oh[NUM_REQUESTERS - 2:0], grant_oh[NUM_REQUESTERS - 1]};
	always @(posedge clk or posedge reset)
		if (reset)
			priority_oh <= 1;
		else if ((request != 0) && update_lru)
			priority_oh <= priority_oh_nxt;
	initial _sv2v_0 = 0;
endmodule
module scoreboard (
	clk,
	reset,
	next_instruction,
	scoreboard_can_issue,
	will_issue,
	writeback_en,
	wb_writeback_vector,
	wb_writeback_reg,
	rollback_en,
	wb_rollback_pipeline
);
	reg _sv2v_0;
	input clk;
	input reset;
	localparam defines_NUM_VECTOR_LANES = 16;
	input wire [141:0] next_instruction;
	output wire scoreboard_can_issue;
	input will_issue;
	input writeback_en;
	input wb_writeback_vector;
	input wire [4:0] wb_writeback_reg;
	input rollback_en;
	input wire [1:0] wb_rollback_pipeline;
	localparam defines_NUM_REGISTERS = 32;
	localparam SCOREBOARD_ENTRIES = 64;
	localparam ROLLBACK_STAGES = 4;
	reg [3:0] has_writeback;
	reg [5:0] writeback_reg [0:3];
	reg [63:0] scoreboard_regs;
	wire [63:0] scoreboard_regs_nxt;
	reg [63:0] dest_bitmap;
	reg [63:0] dep_bitmap;
	reg [63:0] rollback_bitmap;
	reg [63:0] writeback_bitmap;
	wire [63:0] clear_bitmap;
	wire [63:0] set_bitmap;
	always @(*) begin
		if (_sv2v_0)
			;
		rollback_bitmap = 0;
		if (rollback_en) begin
			begin : sv2v_autoblock_1
				reg signed [31:0] i;
				for (i = 0; i < 3; i = i + 1)
					if (has_writeback[i])
						rollback_bitmap[writeback_reg[i]] = 1;
			end
			if (has_writeback[3] && (wb_rollback_pipeline == 2'd0))
				rollback_bitmap[writeback_reg[3]] = 1;
		end
	end
	always @(*) begin
		if (_sv2v_0)
			;
		dep_bitmap = 0;
		if (next_instruction[77]) begin
			if (next_instruction[76])
				dep_bitmap[{1'b1, next_instruction[75-:5]}] = 1;
			else
				dep_bitmap[{1'b0, next_instruction[75-:5]}] = 1;
		end
		if (next_instruction[101])
			dep_bitmap[{1'b0, next_instruction[100-:5]}] = 1;
		if (next_instruction[95])
			dep_bitmap[{1'b0, next_instruction[94-:5]}] = 1;
		if (next_instruction[89])
			dep_bitmap[{1'b1, next_instruction[88-:5]}] = 1;
		if (next_instruction[83])
			dep_bitmap[{1'b1, next_instruction[82-:5]}] = 1;
	end
	always @(*) begin
		if (_sv2v_0)
			;
		dest_bitmap = 0;
		if (next_instruction[77]) begin
			if (next_instruction[76])
				dest_bitmap[{1'b1, next_instruction[75-:5]}] = 1;
			else
				dest_bitmap[{1'b0, next_instruction[75-:5]}] = 1;
		end
	end
	always @(*) begin
		if (_sv2v_0)
			;
		writeback_bitmap = 0;
		if (writeback_en) begin
			if (wb_writeback_vector)
				writeback_bitmap[{1'b1, wb_writeback_reg}] = 1;
			else
				writeback_bitmap[{1'b0, wb_writeback_reg}] = 1;
		end
	end
	assign clear_bitmap = rollback_bitmap | writeback_bitmap;
	assign set_bitmap = dest_bitmap & {SCOREBOARD_ENTRIES {will_issue}};
	assign scoreboard_regs_nxt = (scoreboard_regs & ~clear_bitmap) | set_bitmap;
	assign scoreboard_can_issue = (scoreboard_regs & dep_bitmap) == 0;
	always @(posedge clk or posedge reset)
		if (reset) begin
			scoreboard_regs <= 1'sb0;
			has_writeback <= 1'sb0;
		end
		else begin
			scoreboard_regs <= scoreboard_regs_nxt;
			has_writeback <= {has_writeback[2:0], will_issue && next_instruction[77]};
		end
	always @(posedge clk) begin
		if (will_issue)
			writeback_reg[0] <= {next_instruction[76], next_instruction[75-:5]};
		begin : sv2v_autoblock_2
			reg signed [31:0] i;
			for (i = 1; i < ROLLBACK_STAGES; i = i + 1)
				writeback_reg[i] <= writeback_reg[i - 1];
		end
	end
	initial _sv2v_0 = 0;
endmodule
module sync_fifo (
	clk,
	reset,
	flush_en,
	full,
	almost_full,
	enqueue_en,
	enqueue_value,
	empty,
	almost_empty,
	dequeue_en,
	dequeue_value
);
	parameter WIDTH = 64;
	parameter SIZE = 4;
	parameter ALMOST_FULL_THRESHOLD = SIZE;
	parameter ALMOST_EMPTY_THRESHOLD = 1;
	input clk;
	input reset;
	input flush_en;
	output wire full;
	output wire almost_full;
	input enqueue_en;
	input [WIDTH - 1:0] enqueue_value;
	output wire empty;
	output wire almost_empty;
	input dequeue_en;
	output wire [WIDTH - 1:0] dequeue_value;
	localparam ADDR_WIDTH = $clog2(SIZE);
	reg [ADDR_WIDTH - 1:0] head;
	reg [ADDR_WIDTH - 1:0] tail;
	reg [ADDR_WIDTH:0] count;
	reg [WIDTH - 1:0] data [0:SIZE - 1];
	function automatic signed [((ADDR_WIDTH + 0) >= 0 ? ADDR_WIDTH + 1 : 1 - (ADDR_WIDTH + 0)) - 1:0] sv2v_cast_D7FEC_signed;
		input reg signed [((ADDR_WIDTH + 0) >= 0 ? ADDR_WIDTH + 1 : 1 - (ADDR_WIDTH + 0)) - 1:0] inp;
		sv2v_cast_D7FEC_signed = inp;
	endfunction
	assign almost_full = count >= sv2v_cast_D7FEC_signed(ALMOST_FULL_THRESHOLD);
	assign almost_empty = count <= sv2v_cast_D7FEC_signed(ALMOST_EMPTY_THRESHOLD);
	assign full = count == SIZE;
	assign empty = count == 0;
	assign dequeue_value = data[head];
	always @(posedge clk or posedge reset)
		if (reset) begin
			head <= 0;
			tail <= 0;
			count <= 0;
		end
		else if (flush_en) begin
			head <= 0;
			tail <= 0;
			count <= 0;
		end
		else begin
			if (enqueue_en) begin
				tail <= tail + 1;
				data[tail] <= enqueue_value;
			end
			if (dequeue_en)
				head <= head + 1;
			if (enqueue_en && !dequeue_en)
				count <= count + 1;
			else if (dequeue_en && !enqueue_en)
				count <= count - 1;
		end
endmodule
module synchronizer (
	clk,
	reset,
	data_o,
	data_i
);
	parameter WIDTH = 1;
	parameter RESET_STATE = 0;
	input clk;
	input reset;
	output reg [WIDTH - 1:0] data_o;
	input [WIDTH - 1:0] data_i;
	reg [WIDTH - 1:0] sync0;
	reg [WIDTH - 1:0] sync1;
	function automatic signed [WIDTH - 1:0] sv2v_cast_E6D93_signed;
		input reg signed [WIDTH - 1:0] inp;
		sv2v_cast_E6D93_signed = inp;
	endfunction
	always @(posedge clk or posedge reset)
		if (reset) begin
			sync0 <= sv2v_cast_E6D93_signed(RESET_STATE);
			sync1 <= sv2v_cast_E6D93_signed(RESET_STATE);
			data_o <= sv2v_cast_E6D93_signed(RESET_STATE);
		end
		else begin
			sync0 <= data_i;
			sync1 <= sync0;
			data_o <= sync1;
		end
endmodule
module thread_select_stage (
	clk,
	reset,
	id_instruction,
	id_instruction_valid,
	id_thread_idx,
	ts_fetch_en,
	ts_instruction_valid,
	ts_instruction,
	ts_thread_idx,
	ts_subcycle,
	wb_writeback_en,
	wb_writeback_thread_idx,
	wb_writeback_vector,
	wb_writeback_reg,
	wb_writeback_last_subcycle,
	wb_rollback_thread_idx,
	wb_rollback_en,
	wb_rollback_pipeline,
	wb_rollback_subcycle,
	thread_en,
	wb_suspend_thread_oh,
	l2i_dcache_wake_bitmap,
	ior_wake_bitmap,
	ts_perf_instruction_issue
);
	reg _sv2v_0;
	input clk;
	input reset;
	localparam defines_NUM_VECTOR_LANES = 16;
	input wire [141:0] id_instruction;
	input id_instruction_valid;
	input wire [1:0] id_thread_idx;
	output wire [3:0] ts_fetch_en;
	output reg ts_instruction_valid;
	output reg [141:0] ts_instruction;
	output reg [1:0] ts_thread_idx;
	output reg [3:0] ts_subcycle;
	input wb_writeback_en;
	input wire [1:0] wb_writeback_thread_idx;
	input wb_writeback_vector;
	input wire [4:0] wb_writeback_reg;
	input wb_writeback_last_subcycle;
	input wire [1:0] wb_rollback_thread_idx;
	input wb_rollback_en;
	input wire [1:0] wb_rollback_pipeline;
	input wire [3:0] wb_rollback_subcycle;
	input wire [3:0] thread_en;
	input wire [3:0] wb_suspend_thread_oh;
	input wire [3:0] l2i_dcache_wake_bitmap;
	input wire [3:0] ior_wake_bitmap;
	output reg ts_perf_instruction_issue;
	localparam THREAD_FIFO_SIZE = 8;
	localparam WRITEBACK_ALLOC_STAGES = 4;
	wire [141:0] thread_instr [0:3];
	wire [141:0] issue_instr;
	reg [3:0] thread_blocked;
	wire [3:0] can_issue_thread;
	wire [3:0] thread_issue_oh;
	wire [1:0] issue_thread_idx;
	reg [3:0] writeback_allocate;
	reg [3:0] writeback_allocate_nxt;
	reg [3:0] current_subcycle [0:3];
	wire issue_last_subcycle [0:3];
	genvar _gv_thread_idx_6;
	function automatic [1:0] sv2v_cast_2;
		input reg [1:0] inp;
		sv2v_cast_2 = inp;
	endfunction
	function automatic [3:0] sv2v_cast_60D1B;
		input reg [3:0] inp;
		sv2v_cast_60D1B = inp;
	endfunction
	generate
		for (_gv_thread_idx_6 = 0; _gv_thread_idx_6 < 4; _gv_thread_idx_6 = _gv_thread_idx_6 + 1) begin : thread_logic_gen
			localparam thread_idx = _gv_thread_idx_6;
			wire ififo_almost_full;
			wire ififo_empty;
			reg writeback_conflict;
			wire rollback_this_thread;
			wire enqueue_this_thread;
			wire writeback_this_thread;
			wire scoreboard_can_issue;
			assign enqueue_this_thread = id_instruction_valid && (id_thread_idx == sv2v_cast_2(thread_idx));
			sync_fifo #(
				.WIDTH(142),
				.SIZE(THREAD_FIFO_SIZE),
				.ALMOST_FULL_THRESHOLD(5)
			) instruction_fifo(
				.flush_en(rollback_this_thread),
				.full(),
				.almost_full(ififo_almost_full),
				.enqueue_en(enqueue_this_thread),
				.enqueue_value(id_instruction),
				.empty(ififo_empty),
				.almost_empty(),
				.dequeue_en(issue_last_subcycle[thread_idx]),
				.dequeue_value(thread_instr[thread_idx]),
				.clk(clk),
				.reset(reset)
			);
			assign writeback_this_thread = (wb_writeback_en && (wb_writeback_thread_idx == sv2v_cast_2(thread_idx))) && wb_writeback_last_subcycle;
			assign rollback_this_thread = wb_rollback_en && (wb_rollback_thread_idx == sv2v_cast_2(thread_idx));
			scoreboard scoreboard(
				.next_instruction(thread_instr[thread_idx]),
				.will_issue(thread_issue_oh[thread_idx]),
				.writeback_en(writeback_this_thread),
				.rollback_en(rollback_this_thread),
				.clk(clk),
				.reset(reset),
				.scoreboard_can_issue(scoreboard_can_issue),
				.wb_writeback_vector(wb_writeback_vector),
				.wb_writeback_reg(wb_writeback_reg),
				.wb_rollback_pipeline(wb_rollback_pipeline)
			);
			assign ts_fetch_en[thread_idx] = !ififo_almost_full && thread_en[thread_idx];
			always @(*) begin
				if (_sv2v_0)
					;
				(* full_case, parallel_case *)
				case (thread_instr[thread_idx][21-:2])
					2'd1: writeback_conflict = writeback_allocate[0];
					2'd0: writeback_conflict = writeback_allocate[1];
					default: writeback_conflict = 0;
				endcase
			end
			assign can_issue_thread[thread_idx] = ((((!ififo_empty && (scoreboard_can_issue || (current_subcycle[thread_idx] != 0))) && thread_en[thread_idx]) && !rollback_this_thread) && !writeback_conflict) && !thread_blocked[thread_idx];
			assign issue_last_subcycle[thread_idx] = thread_issue_oh[thread_idx] && (current_subcycle[thread_idx] == thread_instr[thread_idx][12-:4]);
			always @(posedge clk or posedge reset)
				if (reset)
					current_subcycle[thread_idx] <= 0;
				else if (wb_rollback_en && (wb_rollback_thread_idx == sv2v_cast_2(thread_idx)))
					current_subcycle[thread_idx] <= wb_rollback_subcycle;
				else if (issue_last_subcycle[thread_idx])
					current_subcycle[thread_idx] <= 0;
				else if (thread_issue_oh[thread_idx])
					current_subcycle[thread_idx] <= current_subcycle[thread_idx] + sv2v_cast_60D1B(1);
		end
	endgenerate
	always @(*) begin
		if (_sv2v_0)
			;
		writeback_allocate_nxt = {1'b0, writeback_allocate[3:1]};
		if (|thread_issue_oh)
			(* full_case, parallel_case *)
			case (issue_instr[21-:2])
				2'd2: writeback_allocate_nxt[3] = 1'b1;
				2'd0: writeback_allocate_nxt[0] = 1'b1;
				default:
					;
			endcase
	end
	rr_arbiter #(.NUM_REQUESTERS(4)) thread_select_arbiter(
		.request(can_issue_thread),
		.update_lru(1'b1),
		.grant_oh(thread_issue_oh),
		.clk(clk),
		.reset(reset)
	);
	oh_to_idx #(.NUM_SIGNALS(4)) thread_oh_to_idx(
		.one_hot(thread_issue_oh),
		.index(issue_thread_idx)
	);
	assign issue_instr = thread_instr[issue_thread_idx];
	always @(posedge clk) begin
		ts_instruction <= issue_instr;
		ts_thread_idx <= issue_thread_idx;
		ts_subcycle <= current_subcycle[issue_thread_idx];
	end
	always @(posedge clk or posedge reset)
		if (reset) begin
			thread_blocked <= 1'sb0;
			ts_instruction_valid <= 1'sb0;
			ts_perf_instruction_issue <= 1'sb0;
			writeback_allocate <= 1'sb0;
		end
		else begin
			ts_instruction_valid <= |thread_issue_oh;
			thread_blocked <= (thread_blocked | wb_suspend_thread_oh) & ~(l2i_dcache_wake_bitmap | ior_wake_bitmap);
			writeback_allocate <= writeback_allocate_nxt;
			ts_perf_instruction_issue <= |thread_issue_oh;
		end
	initial _sv2v_0 = 0;
endmodule
module tlb (
	clk,
	reset,
	lookup_en,
	update_en,
	invalidate_en,
	invalidate_all_en,
	request_vpage_idx,
	request_asid,
	update_ppage_idx,
	update_present,
	update_exe_writable,
	update_supervisor,
	update_global,
	lookup_ppage_idx,
	lookup_hit,
	lookup_present,
	lookup_exe_writable,
	lookup_supervisor
);
	reg _sv2v_0;
	parameter NUM_ENTRIES = 64;
	parameter NUM_WAYS = 4;
	input clk;
	input reset;
	input lookup_en;
	input update_en;
	input invalidate_en;
	input invalidate_all_en;
	localparam defines_PAGE_SIZE = 'h1000;
	localparam defines_PAGE_NUM_BITS = 32 - $clog2('h1000);
	input wire [defines_PAGE_NUM_BITS - 1:0] request_vpage_idx;
	localparam defines_ASID_WIDTH = 8;
	input [7:0] request_asid;
	input wire [defines_PAGE_NUM_BITS - 1:0] update_ppage_idx;
	input update_present;
	input update_exe_writable;
	input update_supervisor;
	input update_global;
	output reg [defines_PAGE_NUM_BITS - 1:0] lookup_ppage_idx;
	output wire lookup_hit;
	output reg lookup_present;
	output reg lookup_exe_writable;
	output reg lookup_supervisor;
	localparam NUM_SETS = NUM_ENTRIES / NUM_WAYS;
	localparam SET_INDEX_WIDTH = $clog2(NUM_SETS);
	localparam WAY_INDEX_WIDTH = $clog2(NUM_WAYS);
	wire [NUM_WAYS - 1:0] way_hit_oh;
	wire [defines_PAGE_NUM_BITS - 1:0] way_ppage_idx [0:NUM_WAYS - 1];
	wire way_present [0:NUM_WAYS - 1];
	wire way_exe_writable [0:NUM_WAYS - 1];
	wire way_supervisor [0:NUM_WAYS - 1];
	reg [defines_PAGE_NUM_BITS - 1:0] request_vpage_idx_latched;
	reg [defines_PAGE_NUM_BITS - 1:0] update_ppage_idx_latched;
	wire [SET_INDEX_WIDTH - 1:0] request_set_idx;
	wire [SET_INDEX_WIDTH - 1:0] update_set_idx;
	reg update_en_latched;
	wire update_valid;
	reg invalidate_en_latched;
	wire tlb_read_en;
	reg [NUM_WAYS - 1:0] way_update_oh;
	reg [NUM_WAYS - 1:0] next_way_oh;
	reg update_present_latched;
	reg update_exe_writable_latched;
	reg update_supervisor_latched;
	reg update_global_latched;
	reg [7:0] request_asid_latched;
	assign request_set_idx = request_vpage_idx[SET_INDEX_WIDTH - 1:0];
	assign update_set_idx = request_vpage_idx_latched[SET_INDEX_WIDTH - 1:0];
	assign tlb_read_en = (lookup_en || update_en) || invalidate_en;
	genvar _gv_way_idx_8;
	generate
		for (_gv_way_idx_8 = 0; _gv_way_idx_8 < NUM_WAYS; _gv_way_idx_8 = _gv_way_idx_8 + 1) begin : way_gen
			localparam way_idx = _gv_way_idx_8;
			wire [defines_PAGE_NUM_BITS - 1:0] way_vpage_idx;
			reg way_valid;
			reg entry_valid [0:NUM_SETS - 1];
			wire [7:0] way_asid;
			wire way_global;
			fakeram_1r1w_16x52 #(
				.SIZE(NUM_SETS),
				.DATA_WIDTH(((defines_PAGE_NUM_BITS * 2) + 4) + defines_ASID_WIDTH),
				.READ_DURING_WRITE("NEW_DATA")
			) tlb_paddr_sram(
				.read_en(tlb_read_en),
				.read_addr(request_set_idx),
				.read_data({way_vpage_idx, way_asid, way_ppage_idx[way_idx], way_present[way_idx], way_exe_writable[way_idx], way_supervisor[way_idx], way_global}),
				.write_en(way_update_oh[way_idx]),
				.write_addr(update_set_idx),
				.write_data({request_vpage_idx_latched, request_asid_latched, update_ppage_idx_latched, update_present_latched, update_exe_writable_latched, update_supervisor_latched, update_global_latched}),
				.*
			);
			always @(posedge clk or posedge reset)
				if (reset) begin : sv2v_autoblock_1
					reg signed [31:0] set_idx;
					for (set_idx = 0; set_idx < NUM_SETS; set_idx = set_idx + 1)
						entry_valid[set_idx] <= 0;
				end
				else if (invalidate_all_en) begin : sv2v_autoblock_2
					reg signed [31:0] set_idx;
					for (set_idx = 0; set_idx < NUM_SETS; set_idx = set_idx + 1)
						entry_valid[set_idx] <= 0;
				end
				else if (way_update_oh[way_idx])
					entry_valid[update_set_idx] <= update_valid;
			always @(posedge clk)
				if (!tlb_read_en)
					way_valid <= 0;
				else if (way_update_oh[way_idx] && (update_set_idx == request_set_idx))
					way_valid <= update_valid;
				else
					way_valid <= entry_valid[request_set_idx];
			assign way_hit_oh[way_idx] = (way_valid && (way_vpage_idx == request_vpage_idx_latched)) && (((way_asid == request_asid_latched) || way_global) || (update_en_latched && update_global_latched));
		end
	endgenerate
	always @(posedge clk) begin
		update_ppage_idx_latched <= update_ppage_idx;
		update_present_latched <= update_present;
		update_exe_writable_latched <= update_exe_writable;
		update_supervisor_latched <= update_supervisor;
		update_global_latched <= update_global;
		request_asid_latched <= request_asid;
		request_vpage_idx_latched <= request_vpage_idx;
	end
	always @(posedge clk or posedge reset)
		if (reset) begin
			invalidate_en_latched <= 1'sb0;
			update_en_latched <= 1'sb0;
		end
		else begin
			update_en_latched <= update_en;
			invalidate_en_latched <= invalidate_en;
		end
	assign lookup_hit = |way_hit_oh;
	always @(*) begin
		if (_sv2v_0)
			;
		lookup_ppage_idx = 0;
		lookup_present = 0;
		lookup_exe_writable = 0;
		lookup_supervisor = 0;
		begin : sv2v_autoblock_3
			reg signed [31:0] way;
			for (way = 0; way < NUM_WAYS; way = way + 1)
				if (way_hit_oh[way]) begin
					lookup_ppage_idx = lookup_ppage_idx | way_ppage_idx[way];
					lookup_present = lookup_present | way_present[way];
					lookup_exe_writable = lookup_exe_writable | way_exe_writable[way];
					lookup_supervisor = lookup_supervisor | way_supervisor[way];
				end
		end
	end
	always @(*) begin
		if (_sv2v_0)
			;
		if (update_en_latched || invalidate_en_latched) begin
			if (lookup_hit)
				way_update_oh = way_hit_oh;
			else
				way_update_oh = next_way_oh;
		end
		else
			way_update_oh = 1'sb0;
	end
	assign update_valid = update_en_latched;
	function automatic signed [NUM_WAYS - 1:0] sv2v_cast_5B59D_signed;
		input reg signed [NUM_WAYS - 1:0] inp;
		sv2v_cast_5B59D_signed = inp;
	endfunction
	always @(posedge clk or posedge reset)
		if (reset)
			next_way_oh <= sv2v_cast_5B59D_signed(1);
		else if (update_en)
			next_way_oh <= {next_way_oh[NUM_WAYS - 2:0], next_way_oh[NUM_WAYS - 1]};
	initial _sv2v_0 = 0;
endmodule
module writeback_stage (
	clk,
	reset,
	fx5_instruction_valid,
	fx5_instruction,
	fx5_result,
	fx5_mask_value,
	fx5_thread_idx,
	fx5_subcycle,
	ix_instruction_valid,
	ix_instruction,
	ix_result,
	ix_thread_idx,
	ix_mask_value,
	ix_rollback_en,
	ix_rollback_pc,
	ix_subcycle,
	ix_privileged_op_fault,
	dd_instruction_valid,
	dd_instruction,
	dd_lane_mask,
	dd_thread_idx,
	dd_request_vaddr,
	dd_subcycle,
	dd_rollback_en,
	dd_rollback_pc,
	dd_load_data,
	dd_suspend_thread,
	dd_io_access,
	dd_trap,
	dd_trap_cause,
	sq_store_bypass_mask,
	sq_store_bypass_data,
	sq_store_sync_success,
	sq_rollback_en,
	ior_read_value,
	ior_rollback_en,
	cr_creg_read_val,
	cr_trap_handler,
	cr_tlb_miss_handler,
	cr_eret_subcycle,
	wb_trap,
	wb_trap_cause,
	wb_trap_pc,
	wb_trap_access_vaddr,
	wb_trap_subcycle,
	wb_syscall_index,
	wb_eret,
	wb_rollback_en,
	wb_rollback_thread_idx,
	wb_rollback_pc,
	wb_rollback_pipeline,
	wb_rollback_subcycle,
	wb_writeback_en,
	wb_writeback_thread_idx,
	wb_writeback_vector,
	wb_writeback_value,
	wb_writeback_mask,
	wb_writeback_reg,
	wb_writeback_last_subcycle,
	wb_suspend_thread_oh,
	wb_inst_injected,
	wb_perf_instruction_retire,
	wb_perf_store_rollback,
	wb_perf_interrupt
);
	reg _sv2v_0;
	input clk;
	input reset;
	input fx5_instruction_valid;
	localparam defines_NUM_VECTOR_LANES = 16;
	input wire [141:0] fx5_instruction;
	input wire [511:0] fx5_result;
	input wire [15:0] fx5_mask_value;
	input wire [1:0] fx5_thread_idx;
	input wire [3:0] fx5_subcycle;
	input ix_instruction_valid;
	input wire [141:0] ix_instruction;
	input wire [511:0] ix_result;
	input wire [1:0] ix_thread_idx;
	input wire [15:0] ix_mask_value;
	input wire ix_rollback_en;
	input wire [31:0] ix_rollback_pc;
	input wire [3:0] ix_subcycle;
	input ix_privileged_op_fault;
	input dd_instruction_valid;
	input wire [141:0] dd_instruction;
	input wire [15:0] dd_lane_mask;
	input wire [1:0] dd_thread_idx;
	localparam defines_CACHE_LINE_BYTES = 64;
	localparam defines_CACHE_LINE_OFFSET_WIDTH = 6;
	localparam defines_DCACHE_TAG_BITS = 20;
	input wire [31:0] dd_request_vaddr;
	input wire [3:0] dd_subcycle;
	input dd_rollback_en;
	input wire [31:0] dd_rollback_pc;
	localparam defines_CACHE_LINE_BITS = 512;
	input wire [511:0] dd_load_data;
	input dd_suspend_thread;
	input dd_io_access;
	input wire dd_trap;
	input wire [5:0] dd_trap_cause;
	input [63:0] sq_store_bypass_mask;
	input wire [511:0] sq_store_bypass_data;
	input sq_store_sync_success;
	input sq_rollback_en;
	input wire [31:0] ior_read_value;
	input wire ior_rollback_en;
	input wire [31:0] cr_creg_read_val;
	input wire [31:0] cr_trap_handler;
	input wire [31:0] cr_tlb_miss_handler;
	input wire [15:0] cr_eret_subcycle;
	output reg wb_trap;
	output reg [5:0] wb_trap_cause;
	output reg [31:0] wb_trap_pc;
	output reg [31:0] wb_trap_access_vaddr;
	output reg [3:0] wb_trap_subcycle;
	output wire [14:0] wb_syscall_index;
	output reg wb_eret;
	output reg wb_rollback_en;
	output reg [1:0] wb_rollback_thread_idx;
	output reg [31:0] wb_rollback_pc;
	output reg [1:0] wb_rollback_pipeline;
	output reg [3:0] wb_rollback_subcycle;
	output reg wb_writeback_en;
	output reg [1:0] wb_writeback_thread_idx;
	output reg wb_writeback_vector;
	output reg [511:0] wb_writeback_value;
	output reg [15:0] wb_writeback_mask;
	output reg [4:0] wb_writeback_reg;
	output reg wb_writeback_last_subcycle;
	output wire [3:0] wb_suspend_thread_oh;
	output reg wb_inst_injected;
	output reg wb_perf_instruction_retire;
	output reg wb_perf_store_rollback;
	output reg wb_perf_interrupt;
	wire [31:0] mem_load_lane;
	localparam defines_CACHE_LINE_WORDS = 16;
	wire [3:0] mem_load_lane_idx;
	reg [7:0] byte_aligned;
	reg [15:0] half_aligned;
	wire [31:0] swapped_word_value;
	wire [3:0] memory_op;
	wire [511:0] endian_twiddled_data;
	wire [15:0] scycle_vcompare_result;
	wire [15:0] mcycle_vcompare_result;
	wire [15:0] dd_vector_lane_oh;
	wire [511:0] bypassed_read_data;
	wire [3:0] thread_dd_oh;
	wire last_subcycle_dd;
	wire last_subcycle_ix;
	wire last_subcycle_fx;
	reg writeback_en_nxt;
	reg [1:0] writeback_thread_idx_nxt;
	reg writeback_vector_nxt;
	reg [511:0] writeback_value_nxt;
	reg [15:0] writeback_mask_nxt;
	reg [4:0] writeback_reg_nxt;
	reg writeback_last_subcycle_nxt;
	always @(*) begin
		if (_sv2v_0)
			;
		wb_rollback_en = 0;
		wb_rollback_pc = 0;
		wb_rollback_thread_idx = 0;
		wb_rollback_pipeline = 2'd1;
		wb_trap = 0;
		wb_trap_cause = 6'h00;
		wb_rollback_subcycle = 0;
		wb_trap_pc = 0;
		wb_trap_access_vaddr = 0;
		wb_trap_subcycle = dd_subcycle;
		wb_eret = 0;
		if (ix_instruction_valid && (ix_instruction[108] || ix_privileged_op_fault)) begin
			wb_rollback_en = 1;
			if (ix_instruction[105-:4] == 4'd7)
				wb_rollback_pc = cr_tlb_miss_handler;
			else
				wb_rollback_pc = cr_trap_handler;
			wb_rollback_thread_idx = ix_thread_idx;
			wb_rollback_pipeline = 2'd1;
			wb_trap = 1;
			if (ix_privileged_op_fault)
				wb_trap_cause = 6'h02;
			else
				wb_trap_cause = ix_instruction[107-:6];
			wb_trap_pc = ix_instruction[141-:32];
			wb_trap_access_vaddr = ix_instruction[141-:32];
			wb_trap_subcycle = ix_subcycle;
		end
		else if (dd_instruction_valid && dd_trap) begin
			wb_rollback_en = 1'b1;
			if (dd_trap_cause[3-:4] == 4'd7)
				wb_rollback_pc = cr_tlb_miss_handler;
			else
				wb_rollback_pc = cr_trap_handler;
			wb_rollback_thread_idx = dd_thread_idx;
			wb_rollback_pipeline = 2'd0;
			wb_trap = 1;
			wb_trap_cause = dd_trap_cause;
			wb_trap_pc = dd_instruction[141-:32];
			wb_trap_access_vaddr = dd_request_vaddr;
		end
		else if (ix_instruction_valid && ix_rollback_en) begin
			wb_rollback_en = 1;
			wb_rollback_pc = ix_rollback_pc;
			wb_rollback_thread_idx = ix_thread_idx;
			wb_rollback_pipeline = 2'd1;
			if (ix_instruction[25-:3] == 3'b111) begin
				wb_eret = 1;
				wb_rollback_subcycle = cr_eret_subcycle[(3 - ix_thread_idx) * 4+:4];
			end
			else
				wb_rollback_subcycle = ix_subcycle;
		end
		else if (dd_instruction_valid && ((dd_rollback_en || sq_rollback_en) || ior_rollback_en)) begin
			wb_rollback_en = 1;
			wb_rollback_pc = dd_rollback_pc;
			wb_rollback_thread_idx = dd_thread_idx;
			wb_rollback_pipeline = 2'd0;
			wb_rollback_subcycle = dd_subcycle;
		end
	end
	function automatic [14:0] sv2v_cast_15;
		input reg [14:0] inp;
		sv2v_cast_15 = inp;
	endfunction
	assign wb_syscall_index = sv2v_cast_15(ix_instruction[58-:32]);
	always @(*) begin
		if (_sv2v_0)
			;
		if (ix_instruction_valid)
			wb_inst_injected = ix_instruction[109];
		else if (dd_instruction_valid)
			wb_inst_injected = dd_instruction[109];
		else if (fx5_instruction_valid)
			wb_inst_injected = fx5_instruction[109];
		else
			wb_inst_injected = 0;
	end
	idx_to_oh #(
		.NUM_SIGNALS(4),
		.DIRECTION("LSB0")
	) idx_to_oh_thread(
		.one_hot(thread_dd_oh),
		.index(dd_thread_idx)
	);
	assign wb_suspend_thread_oh = ((dd_suspend_thread || sq_rollback_en) || ior_rollback_en ? thread_dd_oh : 4'd0);
	genvar _gv_byte_lane_2;
	generate
		for (_gv_byte_lane_2 = 0; _gv_byte_lane_2 < defines_CACHE_LINE_BYTES; _gv_byte_lane_2 = _gv_byte_lane_2 + 1) begin : lane_bypass_gen
			localparam byte_lane = _gv_byte_lane_2;
			assign bypassed_read_data[byte_lane * 8+:8] = (sq_store_bypass_mask[byte_lane] ? sq_store_bypass_data[byte_lane * 8+:8] : dd_load_data[byte_lane * 8+:8]);
		end
	endgenerate
	assign memory_op = dd_instruction[18-:4];
	assign mem_load_lane_idx = ~dd_request_vaddr[2+:4];
	assign mem_load_lane = bypassed_read_data[mem_load_lane_idx * 32+:32];
	always @(*) begin
		if (_sv2v_0)
			;
		(* full_case, parallel_case *)
		case (dd_request_vaddr[1:0])
			2'd0: byte_aligned = mem_load_lane[31:24];
			2'd1: byte_aligned = mem_load_lane[23:16];
			2'd2: byte_aligned = mem_load_lane[15:8];
			2'd3: byte_aligned = mem_load_lane[7:0];
			default: byte_aligned = 1'sb0;
		endcase
	end
	always @(*) begin
		if (_sv2v_0)
			;
		(* full_case, parallel_case *)
		case (dd_request_vaddr[1])
			1'd0: half_aligned = {mem_load_lane[23:16], mem_load_lane[31:24]};
			1'd1: half_aligned = {mem_load_lane[7:0], mem_load_lane[15:8]};
			default: half_aligned = 1'sb0;
		endcase
	end
	assign swapped_word_value = {mem_load_lane[7:0], mem_load_lane[15:8], mem_load_lane[23:16], mem_load_lane[31:24]};
	genvar _gv_swap_word_2;
	generate
		for (_gv_swap_word_2 = 0; _gv_swap_word_2 < 16; _gv_swap_word_2 = _gv_swap_word_2 + 1) begin : swap_word_gen
			localparam swap_word = _gv_swap_word_2;
			assign endian_twiddled_data[swap_word * 32+:8] = bypassed_read_data[(swap_word * 32) + 24+:8];
			assign endian_twiddled_data[(swap_word * 32) + 8+:8] = bypassed_read_data[(swap_word * 32) + 16+:8];
			assign endian_twiddled_data[(swap_word * 32) + 16+:8] = bypassed_read_data[(swap_word * 32) + 8+:8];
			assign endian_twiddled_data[(swap_word * 32) + 24+:8] = bypassed_read_data[swap_word * 32+:8];
		end
	endgenerate
	genvar _gv_mask_lane_1;
	generate
		for (_gv_mask_lane_1 = 0; _gv_mask_lane_1 < defines_NUM_VECTOR_LANES; _gv_mask_lane_1 = _gv_mask_lane_1 + 1) begin : compare_result_gen
			localparam mask_lane = _gv_mask_lane_1;
			assign scycle_vcompare_result[mask_lane] = ix_result[((defines_NUM_VECTOR_LANES - mask_lane) - 1) * 32];
			assign mcycle_vcompare_result[mask_lane] = fx5_result[((defines_NUM_VECTOR_LANES - mask_lane) - 1) * 32];
		end
	endgenerate
	idx_to_oh #(
		.NUM_SIGNALS(defines_NUM_VECTOR_LANES),
		.DIRECTION("LSB0")
	) convert_dd_lane(
		.one_hot(dd_vector_lane_oh),
		.index(dd_subcycle)
	);
	assign last_subcycle_dd = dd_subcycle == dd_instruction[12-:4];
	assign last_subcycle_ix = ix_subcycle == ix_instruction[12-:4];
	assign last_subcycle_fx = fx5_subcycle == fx5_instruction[12-:4];
	function automatic [31:0] sv2v_cast_32;
		input reg [31:0] inp;
		sv2v_cast_32 = inp;
	endfunction
	always @(*) begin
		if (_sv2v_0)
			;
		writeback_en_nxt = 0;
		writeback_thread_idx_nxt = 0;
		writeback_mask_nxt = 0;
		writeback_value_nxt = 0;
		writeback_vector_nxt = 0;
		writeback_reg_nxt = 0;
		writeback_last_subcycle_nxt = 0;
		if (fx5_instruction_valid) begin
			if (fx5_instruction[77] && !wb_rollback_en)
				writeback_en_nxt = 1;
			writeback_thread_idx_nxt = fx5_thread_idx;
			writeback_mask_nxt = fx5_mask_value;
			if (fx5_instruction[13])
				writeback_value_nxt[0+:32] = {16'd0, mcycle_vcompare_result};
			else
				writeback_value_nxt = fx5_result;
			writeback_vector_nxt = fx5_instruction[76];
			writeback_reg_nxt = fx5_instruction[75-:5];
			writeback_last_subcycle_nxt = last_subcycle_fx;
		end
		else if (ix_instruction_valid) begin
			if (ix_instruction[26] && ((ix_instruction[25-:3] == 3'b100) || (ix_instruction[25-:3] == 3'b110)))
				writeback_en_nxt = 1;
			else if (ix_instruction[77] && !wb_rollback_en)
				writeback_en_nxt = 1;
			writeback_thread_idx_nxt = ix_thread_idx;
			writeback_mask_nxt = ix_mask_value;
			if (ix_instruction[22])
				writeback_value_nxt[0+:32] = ix_instruction[141-:32] + 32'd4;
			else if (ix_instruction[13])
				writeback_value_nxt[0+:32] = {16'd0, scycle_vcompare_result};
			else
				writeback_value_nxt = ix_result;
			writeback_vector_nxt = ix_instruction[76];
			writeback_reg_nxt = ix_instruction[75-:5];
			writeback_last_subcycle_nxt = last_subcycle_ix;
		end
		else if (dd_instruction_valid) begin
			writeback_en_nxt = dd_instruction[77] && !wb_rollback_en;
			writeback_thread_idx_nxt = dd_thread_idx;
			if (!dd_instruction[3]) begin
				if (dd_instruction[14])
					(* full_case, parallel_case *)
					case (memory_op)
						4'b0000: writeback_value_nxt[0+:32] = sv2v_cast_32(byte_aligned);
						4'b0001: writeback_value_nxt[0+:32] = sv2v_cast_32($signed(byte_aligned));
						4'b0010: writeback_value_nxt[0+:32] = sv2v_cast_32(half_aligned);
						4'b0011: writeback_value_nxt[0+:32] = sv2v_cast_32($signed(half_aligned));
						4'b0101: writeback_value_nxt[0+:32] = swapped_word_value;
						4'b0100:
							if (dd_io_access) begin
								writeback_mask_nxt = {defines_NUM_VECTOR_LANES {1'b1}};
								writeback_value_nxt[0+:32] = ior_read_value;
							end
							else begin
								writeback_mask_nxt = {defines_NUM_VECTOR_LANES {1'b1}};
								writeback_value_nxt[0+:32] = swapped_word_value;
							end
						4'b0110: begin
							writeback_mask_nxt = {defines_NUM_VECTOR_LANES {1'b1}};
							writeback_value_nxt[0+:32] = cr_creg_read_val;
						end
						4'b0111, 4'b1000: begin
							writeback_mask_nxt = dd_lane_mask;
							writeback_value_nxt = endian_twiddled_data;
						end
						default: begin
							writeback_mask_nxt = dd_vector_lane_oh & dd_lane_mask;
							writeback_value_nxt = {defines_NUM_VECTOR_LANES {swapped_word_value}};
						end
					endcase
				else if (memory_op == 4'b0101)
					writeback_value_nxt[0+:32] = sv2v_cast_32(sq_store_sync_success);
			end
			writeback_vector_nxt = dd_instruction[76];
			writeback_reg_nxt = dd_instruction[75-:5];
			writeback_last_subcycle_nxt = last_subcycle_dd;
		end
	end
	always @(posedge clk) begin
		wb_writeback_thread_idx <= writeback_thread_idx_nxt;
		wb_writeback_mask <= writeback_mask_nxt;
		wb_writeback_value <= writeback_value_nxt;
		wb_writeback_vector <= writeback_vector_nxt;
		wb_writeback_reg <= writeback_reg_nxt;
		wb_writeback_last_subcycle <= writeback_last_subcycle_nxt;
	end
	always @(posedge clk or posedge reset)
		if (reset)
			wb_writeback_en <= 0;
		else begin
			if (dd_instruction_valid && !dd_instruction[3]) begin
				if (dd_instruction[14]) begin
					if (((((((memory_op == 4'b0000) || (memory_op == 4'b0001)) || (memory_op == 4'b0010)) || (memory_op == 4'b0011)) || (memory_op == 4'b0101)) || (memory_op == 4'b0100)) || (memory_op == 4'b0110))
						;
				end
				else if (memory_op == 4'b0101)
					;
			end
			wb_writeback_en <= writeback_en_nxt;
			wb_perf_instruction_retire <= ((fx5_instruction_valid || ix_instruction_valid) || dd_instruction_valid) && (!wb_rollback_en || ((ix_instruction_valid && ix_instruction[26]) && !ix_privileged_op_fault));
			wb_perf_store_rollback <= sq_rollback_en;
			wb_perf_interrupt <= (ix_instruction_valid && ix_instruction[108]) && (ix_instruction[105-:4] == 4'd3);
		end
	initial _sv2v_0 = 0;
endmodule
module NyuziProcessor (
	clk,
	reset,
	m_aclk,
	m_aresetn,
	m_awaddr,
	m_awlen,
	m_awprot,
	m_awvalid,
	s_awready,
	m_wdata,
	m_wlast,
	m_wvalid,
	s_wready,
	s_bvalid,
	m_bready,
	m_araddr,
	m_arlen,
	m_arprot,
	m_arvalid,
	s_arready,
	s_rdata,
	s_rvalid,
	m_rready,
	io_write_en,
	io_read_en,
	io_address,
	io_write_data,
	io_read_data,
	jtag_tck,
	jtag_trst_n,
	jtag_tdi,
	jtag_tms,
	jtag_tdo,
	interrupt_req
);
	parameter signed [31:0] RESET_PC = 0;
	parameter signed [31:0] NUM_INTERRUPTS = 16;
	input wire clk;
	input wire reset;
	output wire m_aclk;
	output wire m_aresetn;
	localparam defines_AXI_ADDR_WIDTH = 32;
	output wire [31:0] m_awaddr;
	output wire [7:0] m_awlen;
	output wire [2:0] m_awprot;
	output wire m_awvalid;
	input wire s_awready;
	output wire [31:0] m_wdata;
	output wire m_wlast;
	output wire m_wvalid;
	input wire s_wready;
	input wire s_bvalid;
	output wire m_bready;
	output wire [31:0] m_araddr;
	output wire [7:0] m_arlen;
	output wire [2:0] m_arprot;
	output wire m_arvalid;
	input wire s_arready;
	input wire [31:0] s_rdata;
	input wire s_rvalid;
	output wire m_rready;
	output wire io_write_en;
	output wire io_read_en;
	output wire [31:0] io_address;
	output wire [31:0] io_write_data;
	input wire [31:0] io_read_data;
	input wire jtag_tck;
	input wire jtag_trst_n;
	input wire jtag_tdi;
	input wire jtag_tms;
	output wire jtag_tdo;
	input wire [NUM_INTERRUPTS - 1:0] interrupt_req;
	generate
		if (1) begin : axi_bus
			wire m_aclk;
			wire m_aresetn;
			localparam defines_AXI_ADDR_WIDTH = 32;
			reg [31:0] m_awaddr;
			wire [7:0] m_awlen;
			wire [2:0] m_awprot;
			reg m_awvalid;
			wire s_awready;
			reg [31:0] m_wdata;
			reg m_wlast;
			reg m_wvalid;
			wire s_wready;
			wire s_bvalid;
			wire m_bready;
			reg [31:0] m_araddr;
			wire [7:0] m_arlen;
			wire [2:0] m_arprot;
			reg m_arvalid;
			wire s_arready;
			wire [31:0] s_rdata;
			wire s_rvalid;
			reg m_rready;
		end
		if (1) begin : io_bus
			wire write_en;
			wire read_en;
			wire [31:0] address;
			wire [31:0] write_data;
			wire [31:0] read_data;
		end
		if (1) begin : jtag
			wire tck;
			wire trst_n;
			wire tdi;
			reg tdo;
			wire tms;
		end
	endgenerate
	assign m_aclk = axi_bus.m_aclk;
	assign m_aresetn = axi_bus.m_aresetn;
	assign m_awaddr = axi_bus.m_awaddr;
	assign m_awlen = axi_bus.m_awlen;
	assign m_awprot = axi_bus.m_awprot;
	assign m_awvalid = axi_bus.m_awvalid;
	assign axi_bus.s_awready = s_awready;
	assign m_wdata = axi_bus.m_wdata;
	assign m_wlast = axi_bus.m_wlast;
	assign m_wvalid = axi_bus.m_wvalid;
	assign axi_bus.s_wready = s_wready;
	assign axi_bus.s_bvalid = s_bvalid;
	assign m_bready = axi_bus.m_bready;
	assign m_araddr = axi_bus.m_araddr;
	assign m_arlen = axi_bus.m_arlen;
	assign m_arprot = axi_bus.m_arprot;
	assign m_arvalid = axi_bus.m_arvalid;
	assign axi_bus.s_arready = s_arready;
	assign axi_bus.s_rdata = s_rdata;
	assign axi_bus.s_rvalid = s_rvalid;
	assign m_rready = axi_bus.m_rready;
	assign io_write_en = io_bus.write_en;
	assign io_read_en = io_bus.read_en;
	assign io_address = io_bus.address;
	assign io_write_data = io_bus.write_data;
	assign io_bus.read_data = io_read_data;
	assign jtag.tck = jtag_tck;
	assign jtag.trst_n = jtag_trst_n;
	assign jtag.tdi = jtag_tdi;
	assign jtag.tms = jtag_tms;
	assign jtag_tdo = jtag.tdo;
	localparam _param_D9EB5_RESET_PC = RESET_PC;
	localparam _param_D9EB5_NUM_INTERRUPTS = NUM_INTERRUPTS;
	function automatic [6:0] sv2v_cast_7;
		input reg [6:0] inp;
		sv2v_cast_7 = inp;
	endfunction
	function automatic [31:0] sv2v_cast_32;
		input reg [31:0] inp;
		sv2v_cast_32 = inp;
	endfunction
	function automatic [3:0] sv2v_cast_4;
		input reg [3:0] inp;
		sv2v_cast_4 = inp;
	endfunction
	generate
		if (1) begin : u_nyuzi
			localparam RESET_PC = _param_D9EB5_RESET_PC;
			localparam NUM_INTERRUPTS = _param_D9EB5_NUM_INTERRUPTS;
			wire clk;
			wire reset;
			wire [NUM_INTERRUPTS - 1:0] interrupt_req;
			localparam defines_NUM_VECTOR_LANES = 16;
			localparam defines_CACHE_LINE_BYTES = 64;
			localparam defines_CACHE_LINE_BITS = 512;
			localparam defines_CACHE_LINE_OFFSET_WIDTH = 6;
			wire [611:0] l2i_request;
			wire [0:0] l2i_request_valid;
			wire [66:0] ior_request;
			wire [0:0] ior_request_valid;
			localparam defines_TOTAL_THREADS = 4;
			reg [3:0] thread_en;
			wire [31:0] cr_data_to_host [0:0];
			wire [31:0] data_to_host;
			wire [0:0] core_injected_complete;
			wire [0:0] core_injected_rollback;
			wire [3:0] core_suspend_thread;
			wire [3:0] core_resume_thread;
			reg [3:0] thread_suspend_mask;
			reg [3:0] thread_resume_mask;
			wire [0:0] ii_ready;
			wire [37:0] ii_response;
			wire ii_response_valid;
			wire [0:0] l2_ready;
			wire [548:0] l2_response;
			wire l2_response_valid;
			wire [3:0] ocd_core;
			wire [31:0] ocd_data_from_host;
			wire ocd_data_update;
			wire ocd_halt;
			wire ocd_inject_en;
			wire [31:0] ocd_inject_inst;
			wire [1:0] ocd_thread;
			localparam defines_CORE_ID_WIDTH = 0;
			always @(*) begin
				thread_suspend_mask = 1'sb0;
				thread_resume_mask = 1'sb0;
				begin : sv2v_autoblock_1
					reg signed [31:0] i;
					for (i = 0; i < 1; i = i + 1)
						begin
							thread_suspend_mask = thread_suspend_mask | core_suspend_thread[i * 4+:4];
							thread_resume_mask = thread_resume_mask | core_resume_thread[i * 4+:4];
						end
				end
			end
			always @(posedge clk or posedge reset)
				if (reset)
					thread_en <= 1;
				else
					thread_en <= (thread_en | thread_resume_mask) & ~thread_suspend_mask;
			if (1) begin : l2_cache
				wire clk;
				wire reset;
				wire [0:0] l2i_request_valid;
				localparam defines_NUM_VECTOR_LANES = 16;
				localparam defines_CACHE_LINE_BYTES = 64;
				localparam defines_CACHE_LINE_BITS = 512;
				localparam defines_CACHE_LINE_OFFSET_WIDTH = 6;
				wire [611:0] l2i_request;
				wire [0:0] l2_ready;
				wire l2_response_valid;
				wire [548:0] l2_response;
				localparam defines_L2_PERF_EVENTS = 3;
				wire [2:0] l2_perf_events;
				wire [511:0] l2a_data_from_memory;
				wire l2a_l2_fill;
				wire [611:0] l2a_request;
				wire l2a_request_valid;
				wire l2a_restarted_flush;
				wire l2bi_collided_miss;
				wire [511:0] l2bi_data_from_memory;
				wire l2bi_perf_l2_writeback;
				wire [611:0] l2bi_request;
				wire l2bi_request_valid;
				wire l2bi_stall;
				wire l2r_cache_hit;
				wire [511:0] l2r_data;
				wire [511:0] l2r_data_from_memory;
				wire [10:0] l2r_hit_cache_idx;
				wire l2r_l2_fill;
				wire l2r_needs_writeback;
				wire l2r_perf_l2_hit;
				wire l2r_perf_l2_miss;
				wire [611:0] l2r_request;
				wire l2r_request_valid;
				wire l2r_restarted_flush;
				wire l2r_store_sync_success;
				wire [7:0] l2r_update_dirty_en;
				wire [7:0] l2r_update_dirty_set;
				wire l2r_update_dirty_value;
				wire l2r_update_lru_en;
				wire [2:0] l2r_update_lru_hit_way;
				wire [7:0] l2r_update_tag_en;
				wire [7:0] l2r_update_tag_set;
				wire l2r_update_tag_valid;
				wire [17:0] l2r_update_tag_value;
				wire [17:0] l2r_writeback_tag;
				wire [511:0] l2t_data_from_memory;
				wire [0:7] l2t_dirty;
				wire [2:0] l2t_fill_way;
				wire l2t_l2_fill;
				wire [611:0] l2t_request;
				wire l2t_request_valid;
				wire l2t_restarted_flush;
				wire [143:0] l2t_tag;
				wire [0:7] l2t_valid;
				wire [10:0] l2u_write_addr;
				wire [511:0] l2u_write_data;
				wire l2u_write_en;
				l2_cache_arb_stage l2_cache_arb_stage(
					.clk(clk),
					.reset(reset),
					.l2i_request_valid(l2i_request_valid),
					.l2i_request(l2i_request),
					.l2_ready(l2_ready),
					.l2a_request_valid(l2a_request_valid),
					.l2a_request(l2a_request),
					.l2a_data_from_memory(l2a_data_from_memory),
					.l2a_l2_fill(l2a_l2_fill),
					.l2a_restarted_flush(l2a_restarted_flush),
					.l2bi_request_valid(l2bi_request_valid),
					.l2bi_request(l2bi_request),
					.l2bi_data_from_memory(l2bi_data_from_memory),
					.l2bi_stall(l2bi_stall),
					.l2bi_collided_miss(l2bi_collided_miss)
				);
				l2_cache_tag_stage l2_cache_tag_stage(
					.clk(clk),
					.reset(reset),
					.l2a_request_valid(l2a_request_valid),
					.l2a_request(l2a_request),
					.l2a_data_from_memory(l2a_data_from_memory),
					.l2a_l2_fill(l2a_l2_fill),
					.l2a_restarted_flush(l2a_restarted_flush),
					.l2r_update_dirty_en(l2r_update_dirty_en),
					.l2r_update_dirty_set(l2r_update_dirty_set),
					.l2r_update_dirty_value(l2r_update_dirty_value),
					.l2r_update_tag_en(l2r_update_tag_en),
					.l2r_update_tag_set(l2r_update_tag_set),
					.l2r_update_tag_valid(l2r_update_tag_valid),
					.l2r_update_tag_value(l2r_update_tag_value),
					.l2r_update_lru_en(l2r_update_lru_en),
					.l2r_update_lru_hit_way(l2r_update_lru_hit_way),
					.l2t_request_valid(l2t_request_valid),
					.l2t_request(l2t_request),
					.l2t_valid(l2t_valid),
					.l2t_tag(l2t_tag),
					.l2t_dirty(l2t_dirty),
					.l2t_l2_fill(l2t_l2_fill),
					.l2t_fill_way(l2t_fill_way),
					.l2t_data_from_memory(l2t_data_from_memory),
					.l2t_restarted_flush(l2t_restarted_flush)
				);
				l2_cache_read_stage l2_cache_read_stage(
					.clk(clk),
					.reset(reset),
					.l2t_request_valid(l2t_request_valid),
					.l2t_request(l2t_request),
					.l2t_valid(l2t_valid),
					.l2t_tag(l2t_tag),
					.l2t_dirty(l2t_dirty),
					.l2t_l2_fill(l2t_l2_fill),
					.l2t_restarted_flush(l2t_restarted_flush),
					.l2t_fill_way(l2t_fill_way),
					.l2t_data_from_memory(l2t_data_from_memory),
					.l2r_update_dirty_en(l2r_update_dirty_en),
					.l2r_update_dirty_set(l2r_update_dirty_set),
					.l2r_update_dirty_value(l2r_update_dirty_value),
					.l2r_update_tag_en(l2r_update_tag_en),
					.l2r_update_tag_set(l2r_update_tag_set),
					.l2r_update_tag_valid(l2r_update_tag_valid),
					.l2r_update_tag_value(l2r_update_tag_value),
					.l2r_update_lru_en(l2r_update_lru_en),
					.l2r_update_lru_hit_way(l2r_update_lru_hit_way),
					.l2u_write_en(l2u_write_en),
					.l2u_write_addr(l2u_write_addr),
					.l2u_write_data(l2u_write_data),
					.l2r_request_valid(l2r_request_valid),
					.l2r_request(l2r_request),
					.l2r_data(l2r_data),
					.l2r_cache_hit(l2r_cache_hit),
					.l2r_hit_cache_idx(l2r_hit_cache_idx),
					.l2r_l2_fill(l2r_l2_fill),
					.l2r_restarted_flush(l2r_restarted_flush),
					.l2r_data_from_memory(l2r_data_from_memory),
					.l2r_store_sync_success(l2r_store_sync_success),
					.l2r_writeback_tag(l2r_writeback_tag),
					.l2r_needs_writeback(l2r_needs_writeback),
					.l2r_perf_l2_miss(l2r_perf_l2_miss),
					.l2r_perf_l2_hit(l2r_perf_l2_hit)
				);
				l2_cache_update_stage l2_cache_update_stage(
					.clk(clk),
					.reset(reset),
					.l2r_request_valid(l2r_request_valid),
					.l2r_request(l2r_request),
					.l2r_data(l2r_data),
					.l2r_cache_hit(l2r_cache_hit),
					.l2r_hit_cache_idx(l2r_hit_cache_idx),
					.l2r_l2_fill(l2r_l2_fill),
					.l2r_restarted_flush(l2r_restarted_flush),
					.l2r_data_from_memory(l2r_data_from_memory),
					.l2r_store_sync_success(l2r_store_sync_success),
					.l2r_needs_writeback(l2r_needs_writeback),
					.l2u_write_en(l2u_write_en),
					.l2u_write_addr(l2u_write_addr),
					.l2u_write_data(l2u_write_data),
					.l2_response_valid(l2_response_valid),
					.l2_response(l2_response)
				);
				if (1) begin : l2_axi_bus_interface
					reg _sv2v_0;
					wire clk;
					wire reset;
					reg l2bi_request_valid;
					localparam defines_NUM_VECTOR_LANES = 16;
					localparam defines_CACHE_LINE_BYTES = 64;
					localparam defines_CACHE_LINE_BITS = 512;
					localparam defines_CACHE_LINE_OFFSET_WIDTH = 6;
					reg [611:0] l2bi_request;
					wire [511:0] l2bi_data_from_memory;
					wire l2bi_stall;
					wire l2bi_collided_miss;
					wire l2r_needs_writeback;
					wire [17:0] l2r_writeback_tag;
					wire [511:0] l2r_data;
					wire l2r_l2_fill;
					wire l2r_restarted_flush;
					wire l2r_cache_hit;
					wire l2r_request_valid;
					wire [611:0] l2r_request;
					reg l2bi_perf_l2_writeback;
					localparam FIFO_SIZE = 8;
					localparam L2REQ_LATENCY = 4;
					localparam BURST_BEATS = 16;
					localparam BURST_OFFSET_WIDTH = 4;
					wire [25:0] miss_addr;
					wire [25:0] writeback_address;
					wire enqueue_writeback_request;
					wire enqueue_fill_request;
					wire duplicate_request;
					wire [511:0] writeback_data;
					wire [31:0] writeback_lanes [0:15];
					wire writeback_fifo_empty;
					wire fill_queue_empty;
					wire fill_request_pending;
					wire writeback_pending;
					reg writeback_complete;
					wire writeback_fifo_almost_full;
					wire fill_queue_almost_full;
					reg [31:0] state_ff;
					reg [31:0] state_nxt;
					reg [3:0] burst_offset_ff;
					reg [3:0] burst_offset_nxt;
					reg [31:0] fill_buffer [0:15];
					reg restart_flush_request;
					reg fill_dequeue_en;
					wire [611:0] lmq_out_request;
					wire [544:0] writeback_fifo_in;
					wire [544:0] writeback_fifo_out;
					assign miss_addr = l2r_request[601-:26];
					assign enqueue_writeback_request = (l2r_request_valid && l2r_needs_writeback) && ((((l2r_request[605-:3] == 3'd4) && l2r_cache_hit) && !l2r_restarted_flush) || l2r_l2_fill);
					assign enqueue_fill_request = ((l2r_request_valid && !l2r_cache_hit) && !l2r_l2_fill) && ((((l2r_request[605-:3] == 3'd0) || (l2r_request[605-:3] == 3'd2)) || (l2r_request[605-:3] == 3'd1)) || (l2r_request[605-:3] == 3'd3));
					assign writeback_pending = !writeback_fifo_empty;
					assign fill_request_pending = !fill_queue_empty;
					l2_cache_pending_miss_cam l2_cache_pending_miss_cam(
						.request_valid(l2r_request_valid),
						.request_addr({miss_addr[25-:18], miss_addr[7-:8]}),
						.clk(clk),
						.reset(reset),
						.enqueue_fill_request(enqueue_fill_request),
						.l2r_l2_fill(l2r_l2_fill),
						.duplicate_request(duplicate_request)
					);
					assign writeback_fifo_in[544-:26] = {l2r_writeback_tag, miss_addr[7-:8]};
					assign writeback_fifo_in[518-:512] = l2r_data;
					assign writeback_fifo_in[6] = l2r_request[605-:3] == 3'd4;
					assign writeback_fifo_in[5-:4] = l2r_request[611-:4];
					assign writeback_fifo_in[1-:2] = l2r_request[607-:2];
					sync_fifo #(
						.WIDTH(545),
						.SIZE(FIFO_SIZE),
						.ALMOST_FULL_THRESHOLD(4)
					) pending_writeback_fifo(
						.clk(clk),
						.reset(reset),
						.flush_en(1'b0),
						.almost_full(writeback_fifo_almost_full),
						.enqueue_en(enqueue_writeback_request),
						.enqueue_value(writeback_fifo_in),
						.almost_empty(),
						.empty(writeback_fifo_empty),
						.dequeue_en(writeback_complete),
						.dequeue_value(writeback_fifo_out),
						.full()
					);
					assign writeback_address = writeback_fifo_out[544-:26];
					assign writeback_data = writeback_fifo_out[518-:512];
					sync_fifo #(
						.WIDTH(613),
						.SIZE(FIFO_SIZE),
						.ALMOST_FULL_THRESHOLD(4)
					) pending_fill_fifo(
						.clk(clk),
						.reset(reset),
						.flush_en(1'b0),
						.almost_full(fill_queue_almost_full),
						.enqueue_en(enqueue_fill_request),
						.enqueue_value({duplicate_request, l2r_request}),
						.empty(fill_queue_empty),
						.almost_empty(),
						.dequeue_en(fill_dequeue_en),
						.dequeue_value({l2bi_collided_miss, lmq_out_request}),
						.full()
					);
					assign l2bi_stall = fill_queue_almost_full || writeback_fifo_almost_full;
					assign NyuziProcessor.axi_bus.m_awlen = 8'sd15;
					assign NyuziProcessor.axi_bus.m_arlen = 8'sd15;
					assign NyuziProcessor.axi_bus.m_bready = 1'b1;
					assign NyuziProcessor.axi_bus.m_awprot = 3'b000;
					assign NyuziProcessor.axi_bus.m_arprot = 3'b000;
					assign NyuziProcessor.axi_bus.m_aclk = clk;
					assign NyuziProcessor.axi_bus.m_aresetn = !reset;
					genvar _gv_fill_buffer_idx_1;
					for (_gv_fill_buffer_idx_1 = 0; _gv_fill_buffer_idx_1 < BURST_BEATS; _gv_fill_buffer_idx_1 = _gv_fill_buffer_idx_1 + 1) begin : mem_lane_gen
						localparam fill_buffer_idx = _gv_fill_buffer_idx_1;
						assign l2bi_data_from_memory[fill_buffer_idx * 32+:32] = fill_buffer[(BURST_BEATS - fill_buffer_idx) - 1];
					end
					reg wait_axi_write_response;
					always @(*) begin
						if (_sv2v_0)
							;
						state_nxt = state_ff;
						fill_dequeue_en = 0;
						burst_offset_nxt = burst_offset_ff;
						writeback_complete = 0;
						restart_flush_request = 0;
						(* full_case, parallel_case *)
						case (state_ff)
							32'd0:
								if (writeback_pending) begin
									if (!wait_axi_write_response)
										state_nxt = 32'd1;
								end
								else if (fill_request_pending) begin
									if (l2bi_collided_miss || ((lmq_out_request[575-:64] == {defines_CACHE_LINE_BYTES {1'b1}}) && (lmq_out_request[605-:3] == 3'd2)))
										state_nxt = 32'd5;
									else
										state_nxt = 32'd3;
								end
							32'd1: begin
								burst_offset_nxt = 0;
								if (NyuziProcessor.axi_bus.s_awready)
									state_nxt = 32'd2;
							end
							32'd2:
								if (NyuziProcessor.axi_bus.s_wready) begin
									if (burst_offset_ff == {BURST_OFFSET_WIDTH {1'b1}}) begin
										writeback_complete = 1;
										restart_flush_request = writeback_fifo_out[6];
										state_nxt = 32'd0;
									end
									burst_offset_nxt = burst_offset_ff + 4'sd1;
								end
							32'd3: begin
								burst_offset_nxt = 0;
								if (NyuziProcessor.axi_bus.s_arready)
									state_nxt = 32'd4;
							end
							32'd4:
								if (NyuziProcessor.axi_bus.s_rvalid) begin
									if (burst_offset_ff == {BURST_OFFSET_WIDTH {1'b1}})
										state_nxt = 32'd5;
									burst_offset_nxt = burst_offset_ff + 4'sd1;
								end
							32'd5: begin
								state_nxt = 32'd0;
								fill_dequeue_en = 1'b1;
							end
						endcase
					end
					genvar _gv_writeback_lane_1;
					for (_gv_writeback_lane_1 = 0; _gv_writeback_lane_1 < BURST_BEATS; _gv_writeback_lane_1 = _gv_writeback_lane_1 + 1) begin : writeback_lane_gen
						localparam writeback_lane = _gv_writeback_lane_1;
						assign writeback_lanes[writeback_lane] = writeback_data[writeback_lane * 32+:32];
					end
					always @(*) begin
						if (_sv2v_0)
							;
						l2bi_request = lmq_out_request;
						if (restart_flush_request) begin
							l2bi_request_valid = 1'b1;
							l2bi_request[605-:3] = 3'd4;
							l2bi_request[611-:4] = writeback_fifo_out[5-:4];
							l2bi_request[607-:2] = writeback_fifo_out[1-:2];
							l2bi_request[602] = 1'd1;
						end
						else
							l2bi_request_valid = fill_dequeue_en;
					end
					always @(posedge clk or posedge reset) begin : update
						if (reset) begin
							state_ff <= 32'd0;
							NyuziProcessor.axi_bus.m_arvalid <= 1'sb0;
							NyuziProcessor.axi_bus.m_awvalid <= 1'sb0;
							NyuziProcessor.axi_bus.m_rready <= 1'sb0;
							NyuziProcessor.axi_bus.m_wlast <= 1'sb0;
							NyuziProcessor.axi_bus.m_wvalid <= 1'sb0;
							burst_offset_ff <= 1'sb0;
							l2bi_perf_l2_writeback <= 1'sb0;
							wait_axi_write_response <= 1'sb0;
						end
						else begin
							state_ff <= state_nxt;
							burst_offset_ff <= burst_offset_nxt;
							if (state_ff == 32'd1)
								wait_axi_write_response <= 1;
							else if (NyuziProcessor.axi_bus.s_bvalid)
								wait_axi_write_response <= 0;
							NyuziProcessor.axi_bus.m_arvalid <= state_nxt == 32'd3;
							NyuziProcessor.axi_bus.m_rready <= state_nxt == 32'd4;
							NyuziProcessor.axi_bus.m_awvalid <= state_nxt == 32'd1;
							NyuziProcessor.axi_bus.m_wvalid <= state_nxt == 32'd2;
							NyuziProcessor.axi_bus.m_wlast <= (state_nxt == 32'd2) && (burst_offset_nxt == 4'sd15);
							l2bi_perf_l2_writeback <= enqueue_writeback_request && !writeback_fifo_almost_full;
						end
					end
					always @(posedge clk) begin
						if ((state_ff == 32'd4) && NyuziProcessor.axi_bus.s_rvalid)
							fill_buffer[burst_offset_ff] <= NyuziProcessor.axi_bus.s_rdata;
						NyuziProcessor.axi_bus.m_araddr <= {l2bi_request[601-:26], {defines_CACHE_LINE_OFFSET_WIDTH {1'b0}}};
						NyuziProcessor.axi_bus.m_awaddr <= {writeback_address, {defines_CACHE_LINE_OFFSET_WIDTH {1'b0}}};
						NyuziProcessor.axi_bus.m_wdata <= writeback_lanes[~burst_offset_nxt];
					end
					initial _sv2v_0 = 0;
				end
				assign l2_axi_bus_interface.clk = clk;
				assign l2_axi_bus_interface.reset = reset;
				assign l2bi_request_valid = l2_axi_bus_interface.l2bi_request_valid;
				assign l2bi_request = l2_axi_bus_interface.l2bi_request;
				assign l2bi_data_from_memory = l2_axi_bus_interface.l2bi_data_from_memory;
				assign l2bi_stall = l2_axi_bus_interface.l2bi_stall;
				assign l2bi_collided_miss = l2_axi_bus_interface.l2bi_collided_miss;
				assign l2_axi_bus_interface.l2r_needs_writeback = l2r_needs_writeback;
				assign l2_axi_bus_interface.l2r_writeback_tag = l2r_writeback_tag;
				assign l2_axi_bus_interface.l2r_data = l2r_data;
				assign l2_axi_bus_interface.l2r_l2_fill = l2r_l2_fill;
				assign l2_axi_bus_interface.l2r_restarted_flush = l2r_restarted_flush;
				assign l2_axi_bus_interface.l2r_cache_hit = l2r_cache_hit;
				assign l2_axi_bus_interface.l2r_request_valid = l2r_request_valid;
				assign l2_axi_bus_interface.l2r_request = l2r_request;
				assign l2bi_perf_l2_writeback = l2_axi_bus_interface.l2bi_perf_l2_writeback;
				assign l2_perf_events = {l2r_perf_l2_hit, l2r_perf_l2_miss, l2bi_perf_l2_writeback};
			end
			assign l2_cache.clk = clk;
			assign l2_cache.reset = reset;
			assign l2_cache.l2i_request_valid = l2i_request_valid;
			assign l2_cache.l2i_request = l2i_request;
			assign l2_ready = l2_cache.l2_ready;
			assign l2_response_valid = l2_cache.l2_response_valid;
			assign l2_response = l2_cache.l2_response;
			if (1) begin : io_interconnect
				wire clk;
				wire reset;
				wire [0:0] ior_request_valid;
				wire [66:0] ior_request;
				wire [0:0] ii_ready;
				reg ii_response_valid;
				reg [37:0] ii_response;
				wire [3:0] grant_idx;
				wire [0:0] grant_oh;
				reg request_sent;
				reg [3:0] request_core;
				reg [1:0] request_thread_idx;
				wire [66:0] grant_request;
				genvar _gv_request_idx_1;
				for (_gv_request_idx_1 = 0; _gv_request_idx_1 < 1; _gv_request_idx_1 = _gv_request_idx_1 + 1) begin : handshake_gen
					localparam request_idx = _gv_request_idx_1;
					assign ii_ready[request_idx] = grant_oh[request_idx];
				end
				genvar _gv_grant_idx_bit_1;
				localparam defines_CORE_ID_WIDTH = 0;
				if (1) begin : genblk2
					assign grant_oh[0] = ior_request_valid[0];
					assign grant_idx = 0;
					assign grant_request = ior_request[0+:67];
				end
				assign NyuziProcessor.io_bus.write_en = |grant_oh && grant_request[66];
				assign NyuziProcessor.io_bus.read_en = |grant_oh && !grant_request[66];
				assign NyuziProcessor.io_bus.write_data = grant_request[31-:32];
				assign NyuziProcessor.io_bus.address = grant_request[63-:32];
				always @(posedge clk) begin
					ii_response[37-:4] <= request_core;
					ii_response[33-:2] <= request_thread_idx;
					ii_response[31-:32] <= NyuziProcessor.io_bus.read_data;
					if (|ior_request_valid) begin
						request_core <= grant_idx;
						request_thread_idx <= grant_request[65-:2];
					end
				end
				always @(posedge clk or posedge reset)
					if (reset) begin
						ii_response_valid <= 1'sb0;
						request_sent <= 1'sb0;
					end
					else begin
						request_sent <= |ior_request_valid;
						ii_response_valid <= request_sent;
					end
			end
			assign io_interconnect.clk = clk;
			assign io_interconnect.reset = reset;
			assign io_interconnect.ior_request_valid = ior_request_valid;
			assign io_interconnect.ior_request = ior_request;
			assign ii_ready = io_interconnect.ii_ready;
			assign ii_response_valid = io_interconnect.ii_response_valid;
			assign ii_response = io_interconnect.ii_response;
			if (1) begin : on_chip_debugger
				wire clk;
				wire reset;
				wire ocd_halt;
				wire [1:0] ocd_thread;
				wire [3:0] ocd_core;
				reg [31:0] ocd_inject_inst;
				wire ocd_inject_en;
				wire [31:0] ocd_data_from_host;
				wire ocd_data_update;
				wire [31:0] data_to_host;
				wire injected_complete;
				wire injected_rollback;
				localparam JTAG_IDCODE = 32'h4d20dffb;
				wire data_shift_val;
				reg [31:0] data_shift_reg;
				reg [6:0] control;
				reg [1:0] machine_inst_status;
				wire capture_dr;
				wire [3:0] jtag_instruction;
				wire shift_dr;
				wire update_dr;
				wire update_ir;
				assign ocd_halt = control[0];
				assign ocd_thread = control[2-:2];
				assign ocd_core = control[6-:4];
				localparam _param_C3F75_INSTRUCTION_WIDTH = 4;
				if (1) begin : jtag_tap_controller
					reg _sv2v_0;
					localparam INSTRUCTION_WIDTH = _param_C3F75_INSTRUCTION_WIDTH;
					wire clk;
					wire reset;
					wire data_shift_val;
					wire capture_dr;
					wire shift_dr;
					wire update_dr;
					reg [3:0] jtag_instruction;
					wire update_ir;
					reg signed [31:0] state_ff;
					reg signed [31:0] state_nxt;
					reg last_tck;
					wire tck_rising_edge;
					wire tck_falling_edge;
					wire tck_sync;
					wire tms_sync;
					wire tdi_sync;
					wire trst_sync_n;
					always @(*) begin
						if (_sv2v_0)
							;
						state_nxt = state_ff;
						(* full_case, parallel_case *)
						case (state_ff)
							32'sd1:
								if (tms_sync)
									state_nxt = 32'sd2;
							32'sd2:
								if (tms_sync)
									state_nxt = 32'sd9;
								else
									state_nxt = 32'sd3;
							32'sd3:
								if (tms_sync)
									state_nxt = 32'sd5;
								else
									state_nxt = 32'sd4;
							32'sd4:
								if (tms_sync)
									state_nxt = 32'sd5;
							32'sd5:
								if (tms_sync)
									state_nxt = 32'sd8;
								else
									state_nxt = 32'sd6;
							32'sd6:
								if (tms_sync)
									state_nxt = 32'sd7;
							32'sd7:
								if (tms_sync)
									state_nxt = 32'sd8;
								else
									state_nxt = 32'sd4;
							32'sd8: state_nxt = 32'sd1;
							32'sd9:
								if (tms_sync)
									state_nxt = 32'sd1;
								else
									state_nxt = 32'sd10;
							32'sd10:
								if (tms_sync)
									state_nxt = 32'sd12;
								else
									state_nxt = 32'sd11;
							32'sd11:
								if (tms_sync)
									state_nxt = 32'sd12;
							32'sd12:
								if (tms_sync)
									state_nxt = 32'sd15;
								else
									state_nxt = 32'sd13;
							32'sd13:
								if (tms_sync)
									state_nxt = 32'sd14;
							32'sd14:
								if (tms_sync)
									state_nxt = 32'sd15;
								else
									state_nxt = 32'sd11;
							32'sd15:
								if (tms_sync)
									state_nxt = 32'sd2;
								else
									state_nxt = 32'sd1;
							32'sd0:
								if (!tms_sync)
									state_nxt = 32'sd1;
							default: state_nxt = 32'sd0;
						endcase
					end
					synchronizer #(.WIDTH(4)) synchronizer(
						.data_i({NyuziProcessor.jtag.tck, NyuziProcessor.jtag.tms, NyuziProcessor.jtag.tdi, NyuziProcessor.jtag.trst_n}),
						.data_o({tck_sync, tms_sync, tdi_sync, trst_sync_n}),
						.clk(clk),
						.reset(reset)
					);
					assign tck_rising_edge = !last_tck && tck_sync;
					assign tck_falling_edge = last_tck && !tck_sync;
					assign update_ir = (state_ff == 32'sd15) && tck_rising_edge;
					assign capture_dr = (state_ff == 32'sd3) && tck_rising_edge;
					assign shift_dr = (state_ff == 32'sd4) && tck_rising_edge;
					assign update_dr = (state_ff == 32'sd8) && tck_rising_edge;
					always @(posedge clk or posedge reset)
						if (reset) begin
							state_ff <= 32'sd0;
							NyuziProcessor.jtag.tdo <= 1'sb0;
							jtag_instruction <= 1'sb0;
							last_tck <= 1'sb0;
						end
						else if (!trst_sync_n)
							state_ff <= 32'sd0;
						else begin
							if (state_ff == 32'sd0)
								jtag_instruction <= 1'sb0;
							last_tck <= tck_sync;
							if (tck_rising_edge) begin
								state_ff <= state_nxt;
								if (state_ff == 32'sd11)
									jtag_instruction <= {tdi_sync, jtag_instruction[3:1]};
							end
							else if (tck_falling_edge)
								NyuziProcessor.jtag.tdo <= (state_ff == 32'sd11 ? jtag_instruction[0] : data_shift_val);
						end
					initial _sv2v_0 = 0;
				end
				assign jtag_tap_controller.clk = clk;
				assign jtag_tap_controller.reset = reset;
				assign jtag_tap_controller.data_shift_val = data_shift_val;
				assign capture_dr = jtag_tap_controller.capture_dr;
				assign shift_dr = jtag_tap_controller.shift_dr;
				assign update_dr = jtag_tap_controller.update_dr;
				assign jtag_instruction = jtag_tap_controller.jtag_instruction;
				assign update_ir = jtag_tap_controller.update_ir;
				assign data_shift_val = data_shift_reg[0];
				assign ocd_inject_en = update_dr && (jtag_instruction == 4'd4);
				always @(posedge clk or posedge reset)
					if (reset) begin
						control <= 1'sb0;
						machine_inst_status <= 2'd0;
					end
					else begin
						if (update_dr && (jtag_instruction == 4'd3))
							control <= sv2v_cast_7(data_shift_reg);
						if (injected_rollback)
							machine_inst_status <= 2'd2;
						else if (injected_complete)
							machine_inst_status <= 2'd0;
						else if (update_dr && (jtag_instruction == 4'd4))
							machine_inst_status <= 2'd1;
					end
				assign ocd_data_from_host = data_shift_reg;
				assign ocd_data_update = update_dr && (jtag_instruction == 4'd5);
				always @(posedge clk)
					if (capture_dr)
						(* full_case, parallel_case *)
						case (jtag_instruction)
							4'd0: data_shift_reg <= JTAG_IDCODE;
							4'd3: data_shift_reg <= sv2v_cast_32(control);
							4'd5: data_shift_reg <= data_to_host;
							4'd6: data_shift_reg <= sv2v_cast_32(machine_inst_status);
							default: data_shift_reg <= 1'sb0;
						endcase
					else if (shift_dr)
						(* full_case, parallel_case *)
						case (jtag_instruction)
							4'd15: data_shift_reg <= sv2v_cast_32(NyuziProcessor.jtag.tdi);
							4'd3: data_shift_reg <= sv2v_cast_32({NyuziProcessor.jtag.tdi, data_shift_reg[6:1]});
							4'd6: data_shift_reg <= sv2v_cast_32({NyuziProcessor.jtag.tdi, data_shift_reg[1:1]});
							default: data_shift_reg <= sv2v_cast_32({NyuziProcessor.jtag.tdi, data_shift_reg[31:1]});
						endcase
					else if (update_dr) begin
						if (jtag_instruction == 4'd4)
							ocd_inject_inst <= data_shift_reg;
					end
			end
			assign on_chip_debugger.injected_complete = |core_injected_complete;
			assign on_chip_debugger.injected_rollback = |core_injected_rollback;
			assign on_chip_debugger.clk = clk;
			assign on_chip_debugger.reset = reset;
			assign ocd_halt = on_chip_debugger.ocd_halt;
			assign ocd_thread = on_chip_debugger.ocd_thread;
			assign ocd_core = on_chip_debugger.ocd_core;
			assign ocd_inject_inst = on_chip_debugger.ocd_inject_inst;
			assign ocd_inject_en = on_chip_debugger.ocd_inject_en;
			assign ocd_data_from_host = on_chip_debugger.ocd_data_from_host;
			assign ocd_data_update = on_chip_debugger.ocd_data_update;
			assign on_chip_debugger.data_to_host = data_to_host;
			if (1) begin : genblk1
				assign data_to_host = cr_data_to_host[0];
			end
			genvar _gv_core_idx_1;
			for (_gv_core_idx_1 = 0; _gv_core_idx_1 < 1; _gv_core_idx_1 = _gv_core_idx_1 + 1) begin : core_gen
				localparam core_idx = _gv_core_idx_1;
				core #(
					.CORE_ID(sv2v_cast_4(core_idx)),
					.NUM_INTERRUPTS(NUM_INTERRUPTS),
					.RESET_PC(RESET_PC)
				) core(
					.l2i_request_valid(l2i_request_valid[core_idx]),
					.l2i_request(l2i_request[core_idx * 612+:612]),
					.l2_ready(l2_ready[core_idx]),
					.thread_en(thread_en[core_idx * 4+:4]),
					.ior_request_valid(ior_request_valid[core_idx]),
					.ior_request(ior_request[core_idx * 67+:67]),
					.ii_ready(ii_ready[core_idx]),
					.ii_response(ii_response),
					.cr_data_to_host(cr_data_to_host[core_idx]),
					.injected_complete(core_injected_complete[core_idx]),
					.injected_rollback(core_injected_rollback[core_idx]),
					.cr_suspend_thread(core_suspend_thread[core_idx * 4+:4]),
					.cr_resume_thread(core_resume_thread[core_idx * 4+:4]),
					.clk(clk),
					.reset(reset),
					.interrupt_req(interrupt_req),
					.l2_response_valid(l2_response_valid),
					.l2_response(l2_response),
					.ii_response_valid(ii_response_valid),
					.ocd_halt(ocd_halt),
					.ocd_thread(ocd_thread),
					.ocd_core(ocd_core),
					.ocd_inject_inst(ocd_inject_inst),
					.ocd_inject_en(ocd_inject_en),
					.ocd_data_from_host(ocd_data_from_host),
					.ocd_data_update(ocd_data_update)
				);
			end
		end
	endgenerate
	assign u_nyuzi.clk = clk;
	assign u_nyuzi.reset = reset;
	assign u_nyuzi.interrupt_req = interrupt_req;
endmodule