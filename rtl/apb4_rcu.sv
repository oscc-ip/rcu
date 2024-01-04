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
`include "pll.sv"
`include "clk_int_div.sv"
`include "rcu_define.sv"

// core: 200M -> 800M
// apb: 100M
// rtc: 32.768K
// vga: 200M
module apb4_rcu (
    apb4_if.slave apb4,
    rcu_if.dut    rcu
);

  logic [3:0] s_apb4_addr;
  logic [`RCU_CTRL_WIDTH-1:0] s_rcu_ctrl_d, s_rcu_ctrl_q;
  logic s_rcu_ctrl_en;
  logic [`RCU_STAT_WIDTH-1:0] s_rcu_stat_d, s_rcu_stat_q;
  logic [1:0] s_bit_tclk;
  logic       s_bit_pllstrb;
  logic s_pll_clk, s_core_clk, s_sys_rstn;

  assign s_apb4_addr     = apb4.paddr[5:2];
  assign s_apb4_wr_hdshk = apb4.psel && apb4.penable && apb4.pwrite;
  assign s_apb4_rd_hdshk = apb4.psel && apb4.penable && (~apb4.pwrite);
  assign apb4.pready     = 1'b1;
  assign apb4.pslverr    = 1'b0;

  assign s_bit_tclk      = s_rcu_ctrl_q[1:0];

  assign s_rcu_ctrl_en   = s_apb4_wr_hdshk && s_apb4_addr == `RCU_CTRL;
  assign s_rcu_ctrl_d    = s_rcu_ctrl_en ? apb4.pwdata[`RCU_CTRL_WIDTH-1:0] : s_rcu_ctrl_q;
  dffer #(`RCU_CTRL_WIDTH) u_rcu_ctrl_dffer (
      apb4.pclk,
      apb4.presetn,
      s_rcu_ctrl_en,
      s_rcu_ctrl_d,
      s_rcu_ctrl_q
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

  assign s_core_clk     = rcu.pll_en_i ? s_pll_clk : rcu.ext_hfosc_clk_i;
  assign rcu.core_clk_o = s_core_clk;
  assign rcu.rtc_clk_o  = rcu.ext_lfosc_clk_i;
  assign rcu.aud_clk_o  = rcu.ext_audosc_clk_i;
  assign s_sys_rstn     = rcu.ext_rst_n_i | rcu.wdt_rst_n_i;

  // reset gen
  rst_sync #(3) u_core_rst_sync (
      s_core_clk,
      s_sys_rstn,
      rcu.core_rst_n_o
  );

  rst_sync #(3) u_rtc_rst_sync (
      rcu.ext_lfosc_clk_i,
      s_sys_rstn,
      rcu.rtc_rst_n_o
  );

  rst_sync #(3) u_aud_rst_sync (
      rcu.ext_audosc_clk_i,
      s_sys_rstn,
      rcu.aud_rst_n_o
  );

  // USER CUSTOM AREA START

  // clock gen
  tech_pll u_tech_pll (
      .fref_i    (rcu.ext_hfosc_clk_i),
      .refdiv_i  (),
      .fbdiv_i   (),
      .postdiv1_i(),
      .postdiv2_i(),
      .pll_lock_o(s_bit_pllstrb),
      .pll_clk_o (s_pll_clk)
  );

  // USER CUSTOM AREA END

  // core 4div
  clk_int_even_div_simple #(
      .DIV_VALUE_WIDTH (3),
      .DONE_DELAY_WIDTH(3)
  ) u_clk_int_even_div_simple (
      .clk_i      (s_core_clk),
      .rst_n_i    (apb4.presetn),
      .div_i      (3'd4),
      .div_valid_i(1'b1),
      .div_ready_o(),
      .div_done_o (),
      .clk_o      (s_core_4div)
  );

  // clock out
  always_comb begin
    rcu.test_clk_o = rcu.ext_hfosc_clk_i;
    unique case (s_bit_tclk)
      `TCLK_HFOSC:     rcu.test_clk_o = rcu.ext_hfosc_clk_i;
      `TCLK_LFOSC:     rcu.test_clk_o = rcu.ext_lfosc_clk_i;
      `TCLK_AUDOSC:    rcu.test_clk_o = rcu.ext_audosc_clk_i;
      `TCLK_CORE_4DIV: rcu.test_clk_o = s_core_4div;
      default:         rcu.test_clk_o = rcu.ext_hfosc_clk_i;
    endcase
  end

endmodule
