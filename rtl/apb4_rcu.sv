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
`include "rcu_define.sv"


module apb4_rcu (
    apb4_if.slave apb4,
    rcu_if.dut    rcu
);

  logic [3:0] s_apb4_addr;
  logic [`RCU_CTRL_WIDTH-1:0] s_rcu_ctrl_d, s_rcu_ctrl_q;
  logic [`RCU_STAT_WIDTH-1:0] s_rcu_stat_d, s_rcu_stat_q;

  assign s_apb4_addr = apb4.paddr[5:2];
  assign s_apb4_wr_hdshk = apb4.psel && apb4.penable && apb4.pwrite;
  assign s_apb4_rd_hdshk = apb4.psel && apb4.penable && (~apb4.pwrite);
  assign apb4.pready = 1'b1;
  assign apb4.pslverr = 1'b0;


  assign s_rcu_ctrl_d = (s_apb4_wr_hdshk && s_apb4_addr == `RCU_CTRL) ? apb4.pwdata[`RCU_CTRL_WIDTH-1:0] : s_rcu_ctrl_q;
  dffr #(`RCU_CTRL_WIDTH) u_rcu_ctrl_dffr (
      apb4.pclk,
      apb4.presetn,
      s_rcu_ctrl_d,
      s_rcu_ctrl_q
  );

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
  // reset

  // clock gen


endmodule
