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
 * ----------------------------
 * RCU_STAT:
 * BITS:   | 31:1 | 0       |
 * FIELDS: | RES  | PLLSTRB |
 * PERMS:  | NONE | R       |
 * -------------------------------
*/

// verilog_format: off
`define RCU_CTRL 4'b0000 // BASEADDR + 0x00
`define RCU_STAT 4'b0001 // BASEADDR + 0x04


`define RCU_CTRL_ADDR {26'b0, `RCU_CTRL, 2'b00}
`define RCU_STAT_ADDR {26'b0, `RCU_STAT, 2'b00}

`define RCU_CTRL_WIDTH 2
`define RCU_STAT_WIDTH 1

`define TCLK_HFOSC     2'b00
`define TCLK_LFOSC     2'b01
`define TCLK_AUDOSC    2'b10
`define TCLK_CORE_4DIV 2'b11


// [100M -> 800M]
`define RCU_CLK_CFG_WIDTH  3
`define RCU_CORE_SEL_WIDTH 5

// verilog_format: on

interface rcu_if ();
  logic                           ext_hfosc_clk_i;
  logic                           ext_lfosc_clk_i;
  logic                           ext_audosc_clk_i;
  logic                           ext_rst_n_i;
  logic                           wdt_rst_n_i;
  logic                           pll_en_i;
  logic [ `RCU_CLK_CFG_WIDTH-1:0] clk_cfg_i;
  logic [`RCU_CORE_SEL_WIDTH-1:0] core_sel_i;
  logic                           core_clk_o;
  logic                           core_rst_n_o;
  logic                           aud_clk_o;
  logic                           aud_rst_n_o;
  logic                           rtc_clk_o;
  logic                           rtc_rst_n_o;
  logic                           test_clk_o;

  modport dut(
      input ext_hfosc_clk_i,
      input ext_lfosc_clk_i,
      input ext_audosc_clk_i,
      input ext_rst_n_i,
      input wdt_rst_n_i,
      input pll_en_i,
      input clk_cfg_i,
      input core_sel_i,
      output core_clk_o,
      output core_rst_n_o,
      output aud_clk_o,
      output aud_rst_n_o,
      output rtc_clk_o,
      output rtc_rst_n_o,
      output test_clk_o
  );

  modport tb(
      output ext_hfosc_clk_i,
      output ext_lfosc_clk_i,
      output ext_audosc_clk_i,
      output ext_rst_n_i,
      output wdt_rst_n_i,
      output pll_en_i,
      output clk_cfg_i,
      output core_sel_i,
      input core_clk_o,
      input core_rst_n_o,
      input aud_clk_o,
      input aud_rst_n_o,
      input rtc_clk_o,
      input rtc_rst_n_o,
      input test_clk_o
  );

endinterface

`endif
