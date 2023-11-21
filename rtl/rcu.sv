// Copyright (c) 2023 Beijing Institute of Open Source Chip
// rcu is licensed under Mulan PSL v2.
// You can use this software according to the terms and conditions of the Mulan PSL v2.
// You may obtain a copy of Mulan PSL v2 at:
//             http://license.coscl.org.cn/MulanPSL2
// THIS SOFTWARE IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
// EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
// MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
// See the Mulan PSL v2 for more details.

module rcu (
    input  logic ext_hfosc_clk_i,
    input  logic ext_lfosc_clk_i,
    input  logic ext_audosc_clk_i,
    input  logic ext_rst_n_i,
    input  logic wdt_rst_n_i,
    output logic core_clk_o,
    output logic core_rst_n_o,
    output logic aud_clk_o,         // 12.288MHz
    output logic aud_rst_n_o,
    output logic rtc_clk_o,
    output logic rtc_rst_n_o,
    output logic test_clk1_o,
    output logic test_clk2_o
);

endmodule
