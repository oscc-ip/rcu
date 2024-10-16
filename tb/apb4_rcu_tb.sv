// Copyright (c) 2023 Beijing Institute of Open Source Chip
// rcu is licensed under Mulan PSL v2.
// You can use this software according to the terms and conditions of the Mulan PSL v2.
// You may obtain a copy of Mulan PSL v2 at:
//             http://license.coscl.org.cn/MulanPSL2
// THIS SOFTWARE IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
// EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
// MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
// See the Mulan PSL v2 for more details.

`include "apb4_if.sv"
`include "rcu_define.sv"

module apb4_rcu_tb ();
  localparam real OSC_CLK_25M_PEROID = 40;
  localparam real OSC_CLK_100M_PEROID = 10;
  localparam real OSC_CLK_12288K_PEROID = 81.38;

  logic rst_n_i, r_osc_25m_clk, r_osc_100m_clk, r_osc_12288k_clk;

  initial begin
    r_osc_25m_clk = 1'b0;
    forever begin
      #(OSC_CLK_25M_PEROID / 2) r_osc_25m_clk <= ~r_osc_25m_clk;
    end
  end

  initial begin
    r_osc_100m_clk = 1'b0;
    forever begin
      #(OSC_CLK_100M_PEROID / 2) r_osc_100m_clk <= ~r_osc_100m_clk;
    end
  end

  initial begin
    r_osc_12288k_clk = 1'b0;
    forever begin
      #(OSC_CLK_12288K_PEROID / 2) r_osc_12288k_clk <= ~r_osc_12288k_clk;
    end
  end

  task sim_reset(int delay);
    rst_n_i = 1'b0;
    repeat (delay) @(posedge r_osc_25m_clk);
    #1 rst_n_i = 1'b1;
  endtask

  initial begin
    sim_reset(40);
  end

  apb4_if u_apb4_if (
      r_osc_25m_clk,
      rst_n_i
  );

  rcu_if u_rcu_if ();

  assign u_rcu_if.ext_lfosc_clk_i  = r_osc_25m_clk;
  assign u_rcu_if.ext_hfosc_clk_i  = r_osc_100m_clk;
  assign u_rcu_if.ext_audosc_clk_i = r_osc_12288k_clk;
  assign u_rcu_if.ext_rst_n_i      = rst_n_i;
  assign u_rcu_if.wdt_rst_n_i      = '0;
  assign u_rcu_if.pll_en_i         = '0;
  assign u_rcu_if.clk_cfg_i        = '0;
  assign u_rcu_if.core_sel_i       = '0;

  test_top u_test_top (
      .apb4(u_apb4_if.master),
      .rcu (u_rcu_if.tb)
  );
  apb4_rcu u_apb4_rcu (
      .apb4(u_apb4_if.slave),
      .rcu (u_rcu_if.dut)
  );

endmodule
