//------------------------------------------------------------------------------
//  Modified from NyuziProcessor: cache_lru.sv
//
// Copyright 2011-2015 Jeff Bush
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
//  Modifications:
//   - Split lru policy into a separate module from cache_lru
//   - Create multiple cache_lru modules based on the respective cache/ram size
//
//  Modified by: Benjamin Goldblatt 2025
//------------------------------------------------------------------------------
module lru_policy (
	lru_flags,
	new_mru,
	fill_way,
	update_flags
);
	reg _sv2v_0;
	parameter NUM_WAYS = 4;
	parameter WAY_INDEX_WIDTH = $clog2(NUM_WAYS);
	parameter LRU_FLAG_BITS = (NUM_WAYS == 1 ? 1 : (NUM_WAYS == 2 ? 1 : (NUM_WAYS == 4 ? 3 : 7)));
	input [LRU_FLAG_BITS - 1:0] lru_flags;
	input [WAY_INDEX_WIDTH - 1:0] new_mru;
	output reg [WAY_INDEX_WIDTH - 1:0] fill_way;
	output reg [LRU_FLAG_BITS - 1:0] update_flags;
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

	initial _sv2v_0 = 0;
endmodule
module cache_lru_8x256 (
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
	fakeram_1r1w_7x256 #(
		.DATA_WIDTH(7),
		.SIZE(256),
		.READ_DURING_WRITE("NEW_DATA")
	) lru_data(
		.read_en(read_en),
		.read_addr(read_set),
		.read_data(lru_flags),
		.write_en(update_lru_en),
		.write_addr(update_set),
		.write_data(update_flags),
		.*
	);
	lru_policy #(
		.NUM_WAYS(NUM_WAYS)
	) lru_policy_inst (
		.lru_flags(lru_flags),
		.new_mru(new_mru),
		.fill_way(fill_way),
		.update_flags(update_flags)
	);
	always @(posedge clk) begin
		update_set <= read_set;
		was_fill <= fill_en;
	end
	initial _sv2v_0 = 0;
endmodule
module cache_lru_4x64 (
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
	fakeram_1r1w_3x64 #(
		.DATA_WIDTH(3),
		.SIZE(64),
		.READ_DURING_WRITE("NEW_DATA")
	) lru_data(
		.read_en(read_en),
		.read_addr(read_set),
		.read_data(lru_flags),
		.write_en(update_lru_en),
		.write_addr(update_set),
		.write_data(update_flags),
		.*
	);
	lru_policy #(
		.NUM_WAYS(NUM_WAYS)
	) lru_policy_inst (
		.lru_flags(lru_flags),
		.new_mru(new_mru),
		.fill_way(fill_way),
		.update_flags(update_flags)
	);
	always @(posedge clk) begin
		update_set <= read_set;
		was_fill <= fill_en;
	end
	initial _sv2v_0 = 0;
endmodule