// Copyright (c) 2023 Beijing Institute of Open Source Chip
// rcu is licensed under Mulan PSL v2.
// You can use this software according to the terms and conditions of the Mulan PSL v2.
// You may obtain a copy of Mulan PSL v2 at:
//             http://license.coscl.org.cn/MulanPSL2
// THIS SOFTWARE IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
// EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
// MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
// See the Mulan PSL v2 for more details.

`include "rcu_define.sv"

// ====== USER CUSTOM CONTENT
module rcu_core (
    input  logic                          ref_clk_i,
    input  logic                          pll_en_i,
    input  logic [`RCU_CLK_CFG_WIDTH-1:0] clk_cfg_i,
    output logic                          pll_lock_o,
    output logic                          pll_core_clk_o,
    output logic                          pll_hf_peri_clk_o
);

  assign pll_lock_o        = 1'b0;
  assign pll_core_clk_o    = 1'b0;
  assign pll_hf_peri_clk_o = ref_clk_i;
  // clock gen
  //   tech_pll u_tech_pll ();

endmodule
