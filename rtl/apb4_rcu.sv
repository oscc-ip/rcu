// Copyright (c) 2023 Beijing Institute of Open Source Chip
// rcu is licensed under Mulan PSL v2.
// You can use this software according to the terms and conditions of the Mulan PSL v2.
// You may obtain a copy of Mulan PSL v2 at:
//             http://license.coscl.org.cn/MulanPSL2
// THIS SOFTWARE IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
// EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
// MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
// See the Mulan PSL v2 for more details.

`include "register.sv"
`include "rst_sync.sv"
`include "stdcell.sv"
`include "pll.sv"
`include "clk_int_div.sv"
`include "rcu_define.sv"

// core: 100M -> 800M
// peri: 100M
// aud:  12288K
// rtc:  10K
module apb4_rcu (
    apb4_if.slave apb4,
    rcu_if.dut    rcu
);

  logic [3:0] s_apb4_addr;
  logic [`RCU_CTRL_WIDTH-1:0] s_rcu_ctrl_d, s_rcu_ctrl_q;
  logic s_rcu_ctrl_en;
  logic [`RCU_RDIV_WIDTH-1:0] s_rcu_rdiv_d, s_rcu_rdiv_q;
  logic s_rcu_rdiv_en;
  logic [`RCU_STAT_WIDTH-1:0] s_rcu_stat_d, s_rcu_stat_q;
  logic [1:0] s_bit_tclk, s_bit_cdiv;
  logic s_bit_pllstrb;

  logic s_ext_lfosc_clk_buf, s_ext_hfosc_clk_buf, s_ext_audosc_clk_buf;
  logic s_rtc_clk, s_sys_rstn;
  logic s_pll_core_clk, s_pll_hf_peri_clk;
  logic s_core_4div_clk, s_core_div_clk;
  logic [7:0] s_core_div_val;

  assign s_apb4_addr     = apb4.paddr[5:2];
  assign s_apb4_wr_hdshk = apb4.psel && apb4.penable && apb4.pwrite;
  assign s_apb4_rd_hdshk = apb4.psel && apb4.penable && (~apb4.pwrite);
  assign apb4.pready     = 1'b1;
  assign apb4.pslverr    = 1'b0;

  assign s_bit_tclk      = s_rcu_ctrl_q[1:0];
  assign s_bit_cdiv      = s_rcu_ctrl_q[3:2];

  assign s_rcu_ctrl_en   = s_apb4_wr_hdshk && s_apb4_addr == `RCU_CTRL;
  assign s_rcu_ctrl_d    = apb4.pwdata[`RCU_CTRL_WIDTH-1:0];
  dffer #(`RCU_CTRL_WIDTH) u_rcu_ctrl_dffer (
      apb4.pclk,
      apb4.presetn,
      s_rcu_ctrl_en,
      s_rcu_ctrl_d,
      s_rcu_ctrl_q
  );

  assign s_rcu_rdiv_en = s_apb4_wr_hdshk && s_apb4_addr == `RCU_RDIV;
  assign s_rcu_rdiv_d  = apb4.pwdata[`RCU_RDIV_WIDTH-1:0];
  dfferh #(`RCU_RDIV_WIDTH) u_rcu_rdiv_dfferh (
      apb4.pclk,
      apb4.presetn,
      s_rcu_rdiv_en,
      s_rcu_rdiv_d,
      s_rcu_rdiv_q
  );

  always_comb begin
    s_rcu_stat_d    = s_rcu_stat_q;
    s_rcu_stat_d[0] = s_bit_pllstrb;
  end
  dffr #(`RCU_STAT_WIDTH) u_rcu_stat_dffr (
      apb4.pclk,
      apb4.presetn,
      s_rcu_stat_d,
      s_rcu_stat_q
  );

  always_comb begin
    apb4.prdata = '0;
    if (s_apb4_rd_hdshk) begin
      unique case (s_apb4_addr)
        `RCU_CTRL: apb4.prdata[`RCU_CTRL_WIDTH-1:0] = s_rcu_ctrl_q;
        `RCU_STAT: apb4.prdata[`RCU_STAT_WIDTH-1:0] = s_rcu_stat_q;
        default:   apb4.prdata = '0;
      endcase
    end
  end

  // gen clock and reset signal
  // verilog_format: off
  clk_buf u_ext_lfosc_clk_buf     (.clk_i(rcu.ext_lfosc_clk_i),  .clk_o(s_ext_lfosc_clk_buf));
  clk_buf u_ext_hfosc_clk_buf     (.clk_i(rcu.ext_hfosc_clk_i),  .clk_o(s_ext_hfosc_clk_buf));
  clk_buf u_ext_audosc_clk_buf    (.clk_i(rcu.ext_audosc_clk_i), .clk_o(s_ext_audosc_clk_buf));
  // pll core postdiv clk
  clk_mux2 u_core_clk_clk_mux2    (.clk_o(rcu.clk_o[`RCU_CORE_CLK]),    .clk1_i(s_ext_lfosc_clk_buf), .clk2_i(s_pll_core_clk),    .en_i(rcu.pll_en_i));
  clk_mux2 u_hf_peri_clk_clk_mux2 (.clk_o(rcu.clk_o[`RCU_HF_PERI_CLK]), .clk1_i(s_ext_lfosc_clk_buf), .clk2_i(s_pll_hf_peri_clk), .en_i(rcu.pll_en_i));
  // === add more pll core postdiv clk here ===
  // other clk
  clk_mux2 u_lf_peri_clk_clk_mux2 (.clk_o(rcu.clk_o[`RCU_LF_PERI_CLK]), .clk1_i(s_core_4div_clk), .clk2_i(s_ext_lfosc_clk_buf), .en_i(rcu.pll_en_i));
  // verilog_format: on

  assign rcu.clk_o[`RCU_BYPASS_CLK] = s_ext_lfosc_clk_buf;
  assign rcu.clk_o[`RCU_AUD_CLK]    = rcu.ext_audosc_clk_i;
  assign rcu.clk_o[`RCU_RTC_CLK]    = s_rtc_clk;
  assign s_sys_rstn                 = rcu.ext_rst_n_i | rcu.wdt_rst_n_i;

  // syn reset signal
  assign rcu.rst_n_o[0]             = '0;  // no used
  for (genvar i = 1; i < `RCU_CLK_MODE_WIDTH; i++) begin : RCU_RST_BLOCK
    // === add more pll core postdiv clk here ===
    if (i == `RCU_CORE_CLK || i == `RCU_HF_PERI_CLK) begin
      rst_sync #(4) u_rst_pllpost_sync (
          rcu.clk_o[i],
          rcu.pll_en_i ? s_bit_pllstrb : s_sys_rstn,
          rcu.rst_n_o[i]
      );
    end else begin
      rst_sync #(4) u_rst_freeclk_sync (
          rcu.clk_o[i],
          s_sys_rstn,
          rcu.rst_n_o[i]
      );
    end
  end

  rcu_core u_rcu_core (
      .ref_clk_i    (s_ext_lfosc_clk_buf),
      .pll_en_i     (rcu.pll_en_i),
      .clk_cfg_i    (rcu.clk_cfg_i),
      .pll_lock_o   (s_bit_pllstrb),
      .pll_clk_o    (s_pll_core_clk),
      .hf_peri_clk_o(s_pll_hf_peri_clk)
  );

  // rtc div
  clk_int_div_simple #(
      .DIV_VALUE_WIDTH (`RCU_RDIV_WIDTH),
      .DONE_DELAY_WIDTH(3)
  ) u_rtcdiv_clk_int_div_simple (
      .clk_i        (rcu.clk_o[`RCU_AUD_CLK]),
      .rst_n_i      (rcu.rst_n_o[`RCU_AUD_CLK]),
      .div_i        (s_rcu_rdiv_q),
      .clk_init_i   (1'b0),
      .div_valid_i  (s_rcu_rdiv_en),
      .div_ready_o  (),
      .div_done_o   (),
      .clk_cnt_o    (),
      .clk_fir_trg_o(),
      .clk_sec_trg_o(),
      .clk_o        (s_rtc_clk)
  );

  // core 4div
  clk_int_div_simple #(
      .DIV_VALUE_WIDTH (3),
      .DONE_DELAY_WIDTH(3)
  ) u_core4div_clk_int_div_simple (
      .clk_i        (rcu.clk_o[`RCU_CORE_CLK]),
      .rst_n_i      (rcu.rst_n_o[`RCU_CORE_CLK]),
      .div_i        (3'd3),
      .clk_init_i   (1'b0),
      .div_valid_i  (1'b0),
      .div_ready_o  (),
      .div_done_o   (),
      .clk_cnt_o    (),
      .clk_fir_trg_o(),
      .clk_sec_trg_o(),
      .clk_o        (s_core_4div_clk)
  );



  always_comb begin
    s_core_div_val = 8'd3;
    unique case (s_bit_cdiv)
      `TCLK_CDIV_4DIV:  s_core_div_val = 8'd3;
      `TCLK_CDIV_8DIV:  s_core_div_val = 8'd7;
      `TCLK_CDIV_16DIV: s_core_div_val = 8'd15;
      `TCLK_CDIV_32DIV: s_core_div_val = 8'd31;
    endcase
  end
  clk_int_div_simple #(
      .DIV_VALUE_WIDTH (8),
      .DONE_DELAY_WIDTH(3)
  ) u_core_clk_int_div_simple (
      .clk_i        (rcu.clk_o[`RCU_CORE_CLK]),
      .rst_n_i      (rcu.rst_n_o[`RCU_CORE_CLK]),
      .div_i        (s_core_div_val),
      .clk_init_i   (1'b0),
      .div_valid_i  (1'b0),
      .div_ready_o  (),
      .div_done_o   (),
      .clk_cnt_o    (),
      .clk_fir_trg_o(),
      .clk_sec_trg_o(),
      .clk_o        (s_core_div_clk)
  );

  // test clock out
  always_comb begin
    rcu.clk_o[`RCU_TEST_CLK] = rcu.ext_lfosc_clk_i;
    unique case (s_bit_tclk)
      `TCLK_LFOSC:    rcu.clk_o[`RCU_TEST_CLK] = rcu.ext_lfosc_clk_i;
      `TCLK_HFOSC:    rcu.clk_o[`RCU_TEST_CLK] = rcu.ext_hfosc_clk_i;
      `TCLK_AUDOSC:   rcu.clk_o[`RCU_TEST_CLK] = rcu.ext_audosc_clk_i;
      `TCLK_CORE_DIV: rcu.clk_o[`RCU_TEST_CLK] = s_core_div_clk;
      default:        rcu.clk_o[`RCU_TEST_CLK] = rcu.ext_lfosc_clk_i;
    endcase
  end

  // gen core sel signal
  assign rcu.core_sel_o = rcu.core_sel_i;

endmodule
