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
`include "helper.sv"
`include "rcu_define.sv"

program automatic test_top (
    apb4_if.master apb4,
    rcu_if.tb   rcu
);

  string wave_name = "default.fsdb";
  task sim_config();
    $timeformat(-9, 1, "ns", 10);
    if ($test$plusargs("WAVE_ON")) begin
      $value$plusargs("WAVE_NAME=%s", wave_name);
      $fsdbDumpfile(wave_name);
      $fsdbDumpvars("+all");
    end
  endtask

  RCUTest rcu_hdl;

  initial begin
    Helper::start_banner();
    sim_config();
    @(posedge apb4.presetn);
    Helper::print("tb init done");
    rcu_hdl = new("rcu_test", apb4, rcu);
    rcu_hdl.init();
    rcu_hdl.test_reset_reg();
    rcu_hdl.test_wr_rd_reg();
    rcu_hdl.test_core_div();
    rcu_hdl.test_rtc_div();
    Helper::end_banner();
    #20000 $finish;
  end

endprogram
