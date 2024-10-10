// Copyright (c) 2023 Beijing Institute of Open Source Chip
// rcu is licensed under Mulan PSL v2.
// You can use this software according to the terms and conditions of the Mulan PSL v2.
// You may obtain a copy of Mulan PSL v2 at:
//             http://license.coscl.org.cn/MulanPSL2
// THIS SOFTWARE IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
// EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
// MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
// See the Mulan PSL v2 for more details.

`ifndef INC_RCU_DEF_SV
`define INC_RCU_DEF_SV

/* register mapping
 * RCU_CTRL:
 * BITS:   | 31:2 | 1:0  |
 * FIELDS: | RES  | TCLK |
 * PERMS:  | NONE | RW   |
 * --------------------------
 * RCU_RDIV:
 * BITS:   | 31:0 |
 * FIELDS: | RDIV |
 * PERMS:  | RW   |
 * --------------------------
 * RCU_STAT:
 * BITS:   | 31:1 | 0       |
 * FIELDS: | RES  | PLLSTRB |
 * PERMS:  | NONE | RO      |
 * --------------------------
*/

// verilog_format: off
`define RCU_CTRL 4'b0000 // BASEADDR + 0x00
`define RCU_RDIV 4'b0001 // BASEADDR + 0x04
`define RCU_STAT 4'b0010 // BASEADDR + 0x08


`define RCU_CTRL_ADDR {26'b0, `RCU_CTRL, 2'b00}
`define RCU_RDIV_ADDR {26'b0, `RCU_RDIV, 2'b00}
`define RCU_STAT_ADDR {26'b0, `RCU_STAT, 2'b00}

`define RCU_CTRL_WIDTH 2
`define RCU_RDIV_WIDTH 32
`define RCU_STAT_WIDTH 1

`define TCLK_LFOSC     2'b00
`define TCLK_HFOSC     2'b01
`define TCLK_AUDOSC    2'b10
`define TCLK_CORE_4DIV 2'b11

// [100M -> 800M]
`define RCU_CLK_CFG_WIDTH  3
`define RCU_CORE_SEL_WIDTH 5
`define RCU_CLK_MODE_WIDTH 8
// clk_o and rst_o
`define RCU_BYPASS_CLK  6'd0
`define RCU_CORE_CLK    6'd1
`define RCU_LF_PERI_CLK 6'd2
`define RCU_HF_PERI_CLK 6'd3
`define RCU_AUD_CLK     6'd4
`define RCU_RTC_CLK     6'd5
`define RCU_TEST_CLK    6'd6
// verilog_format: on

`define RCU_RDIV_MIN_VAL {{(`RCU_RDIV_WIDTH-2){1'b0}}, 2'd2}

interface rcu_if ();
  logic                           ext_lfosc_clk_i;
  logic                           ext_hfosc_clk_i;
  logic                           ext_audosc_clk_i;
  logic                           ext_rst_n_i;
  logic                           wdt_rst_n_i;
  logic                           pll_en_i;
  logic [ `RCU_CLK_CFG_WIDTH-1:0] clk_cfg_i;
  logic [`RCU_CORE_SEL_WIDTH-1:0] core_sel_i;
  logic [`RCU_CORE_SEL_WIDTH-1:0] core_sel_o;  // NOTE: now just bypass
  logic [`RCU_CLK_MODE_WIDTH-1:0] clk_o;
  logic [`RCU_CLK_MODE_WIDTH-1:0] rst_n_o;

  modport dut(
      input ext_lfosc_clk_i,
      input ext_hfosc_clk_i,
      input ext_audosc_clk_i,
      input ext_rst_n_i,
      input wdt_rst_n_i,
      input pll_en_i,
      input clk_cfg_i,
      input core_sel_i,
      output core_sel_o,
      output clk_o,
      output rst_n_o
  );

  modport tb(
      output ext_lfosc_clk_i,
      output ext_hfosc_clk_i,
      output ext_audosc_clk_i,
      output ext_rst_n_i,
      output wdt_rst_n_i,
      output pll_en_i,
      output clk_cfg_i,
      output core_sel_i,
      input core_sel_o,
      input clk_o,
      input rst_n_o
  );

endinterface

`endif
