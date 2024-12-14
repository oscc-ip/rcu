// Copyright (c) 2023-2024 Miao Yuchi <miaoyuchi@ict.ac.cn>
// rcu is licensed under Mulan PSL v2.
// You can use this software according to the terms and conditions of the Mulan PSL v2.
// You may obtain a copy of Mulan PSL v2 at:
//             http://license.coscl.org.cn/MulanPSL2
// THIS SOFTWARE IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
// EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
// MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
// See the Mulan PSL v2 for more details.

`ifndef INC_RCU_TEST_SV
`define INC_RCU_TEST_SV

`include "apb4_master.sv"
`include "rcu_define.sv"

class RCUTest extends APB4Master;
  string                 name;
  int                    wr_val;
  virtual apb4_if.master apb4;
  virtual rcu_if.tb      rcu;

  extern function new(string name = "rcu_test", virtual apb4_if.master apb4, virtual rcu_if.tb rcu);
  extern task automatic test_reset_reg();
  extern task automatic test_wr_rd_reg(input bit [31:0] run_times = 1000);
  extern task automatic test_core_div();
  extern task automatic test_rtc_div();
endclass

function RCUTest::new(string name, virtual apb4_if.master apb4, virtual rcu_if.tb rcu);
  super.new("apb4_master", apb4);
  this.name   = name;
  this.wr_val = 0;
  this.apb4   = apb4;
  this.rcu    = rcu;
endfunction

task automatic RCUTest::test_reset_reg();
  super.test_reset_reg();
  // verilog_format: off
  this.rd_check(`RCU_CTRL_ADDR, "CTRL REG", 32'b0 & {`RCU_CTRL_WIDTH{1'b1}}, Helper::EQUL, Helper::INFO);
  this.rd_check(`RCU_STAT_ADDR, "STAT REG", 32'd0 & {`RCU_STAT_WIDTH{1'b1}}, Helper::EQUL, Helper::INFO);
  // verilog_format: on
endtask

task automatic RCUTest::test_wr_rd_reg(input bit [31:0] run_times = 1000);
  super.test_wr_rd_reg();
  // verilog_format: off
  for (int i = 0; i < run_times; i++) begin
    this.wr_rd_check(`RCU_CTRL_ADDR, "CTRL REG", $random & {`RCU_CTRL_WIDTH{1'b1}}, Helper::EQUL);
  end
  // verilog_format: on
endtask

task automatic RCUTest::test_core_div();
  bit [31:0] ctrl_val = '0;
  $display("%t === [test core div] ===", $time);
  repeat (400) @(posedge this.apb4.pclk);
  ctrl_val[1:0] = 2'd3;
  ctrl_val[3:2] = 2'd0;
  this.write(`RCU_CTRL_ADDR, ctrl_val);  // div4
  repeat (400) @(posedge this.apb4.pclk);

  ctrl_val[3:2] = 2'd1;
  this.write(`RCU_CTRL_ADDR, ctrl_val);  // div8
  repeat (400) @(posedge this.apb4.pclk);

  ctrl_val[3:2] = 2'd2;
  this.write(`RCU_CTRL_ADDR, ctrl_val);  // div16
  repeat (400) @(posedge this.apb4.pclk);

  ctrl_val[3:2] = 2'd3;
  this.write(`RCU_CTRL_ADDR, ctrl_val);  // div32
  repeat (400) @(posedge this.apb4.pclk);

endtask

task automatic RCUTest::test_rtc_div();
  bit [31:0] rdiv_val = '0;
  $display("%t === [test rtc div] ===", $time);
  repeat (400) @(posedge this.apb4.pclk);
  rdiv_val = 32'd7; // div4 org_clk: 12288K
  this.write(`RCU_RDIV_ADDR, rdiv_val);
  repeat (400) @(posedge this.apb4.pclk);
endtask

`endif
