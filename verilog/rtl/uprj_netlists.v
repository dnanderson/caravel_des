// SPDX-FileCopyrightText: 2020 Efabless Corporation
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
// SPDX-License-Identifier: Apache-2.0

// Include caravel global defines for the number of the user project IO pads 
`include "defines.v"
`define USE_POWER_PINS

`ifdef GL
    // Assume default net type to be wire because GL netlists don't have the wire definitions
    `default_nettype wire
    `include "gl/user_project_wrapper.v"
    `include "gl/user_proj_example.v"
`else
    `include "user_project_wrapper.v"
    `include "user_proj_example.v"
    `include "sbox.v"
    `include "sbox1.v"
    `include "sbox2.v"
    `include "sbox3.v"
    `include "sbox4.v"
    `include "sbox5.v"
    `include "sbox6.v"
    `include "sbox7.v"
    `include "sbox8.v"
    `include "key_round.v"
    `include "feistel_function.v"
    `include "round.v"
    `include "des.v"
    `include "des_top.v"

    `include "async_fifo.v"
    `include "fifo_2mem.v"
    `include "fifomem_dp.v"
    `include "rptr_empty.v"
    `include "sync_ptr.v"
    `include "sync_r2w.v"
    `include "sync_w2r.v"
    `include "wptr_full.v"

`endif
