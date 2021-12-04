# SPDX-FileCopyrightText: 2020 Efabless Corporation
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# SPDX-License-Identifier: Apache-2.0

set script_dir [file dirname [file normalize [info script]]]

set ::env(DESIGN_NAME) user_proj_example

set sboxfiles [glob $script_dir/../../verilog/rtl/des/sbox/*.v]
set desfiles [glob $script_dir/../../verilog/rtl/des/*.v]
set fifofiles [glob $script_dir/../../verilog/rtl/des/async_fifo/*.v]
set alldes [concat $sboxfiles $desfiles $fifofiles]
set ::env(VERILOG_FILES) "\
	$::env(CARAVEL_ROOT)/verilog/rtl/defines.v \
	$alldes
	$script_dir/../../verilog/rtl/user_proj_example.v"

set ::env(DESIGN_IS_CORE) 0

set ::env(CLOCK_PORT) "wb_clk_i"
#set ::env(CLOCK_NET) "des_top.clk"
# Long period
set ::env(CLOCK_PERIOD) "18" 

# FIXME: Test removing these, some config.tcls don't use these
#set ::env(FP_SIZING) absolute
#set ::env(DIE_AREA) "0 0 2920 3000"

set ::env(FP_PIN_ORDER_CFG) $script_dir/pin_order.cfg

set ::env(PL_BASIC_PLACEMENT) 0

set ::env(FP_CORE_UTIL) 40
set ::env(PL_TARGET_DENSITY) 0.45
#set ::env(PL_TARGET_DENSITY) 0.67

#set ::env(FP_CORE_UTIL) 60


# Maximum layer used for routing is metal 4.
# This is because this macro will be inserted in a top level (user_project_wrapper) 
# where the PDN is planned on metal 5. So, to avoid having shorts between routes
# in this macro and the top level metal 5 stripes, we have to restrict routes to metal4.  
set ::env(GLB_RT_MAXLAYER) 5

# You can draw more power domains if you need to 
set ::env(VDD_NETS) [list {vccd1}]
set ::env(GND_NETS) [list {vssd1}]

#set ::env(ROUTING_CORES) 4
set ::env(GLB_RT_ANT_ITERS) 10
set ::env(GLB_RT_MAX_DIODE_INS_ITERS) 10
set ::env(DIODE_INSERTION_STRATEGY) 3 

# Use Magic Antenna checker
set ::env(USE_ARC_ANTENNA_CHECK) 0

# If you're going to use multiple power domains, then disable cvc run.
set ::env(RUN_CVC) 1
