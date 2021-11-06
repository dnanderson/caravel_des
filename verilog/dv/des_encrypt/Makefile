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
#
# SPDX-License-Identifier: Apache-2.0


## Caravel Pointers
CARAVEL_ROOT ?= ../../../caravel
CARAVEL_PATH ?= $(CARAVEL_ROOT)
CARAVEL_FIRMWARE_PATH = $(CARAVEL_PATH)/verilog/dv/caravel
CARAVEL_VERILOG_PATH  = $(CARAVEL_PATH)/verilog
CARAVEL_RTL_PATH = $(CARAVEL_VERILOG_PATH)/rtl
CARAVEL_BEHAVIOURAL_MODELS = $(CARAVEL_VERILOG_PATH)/dv/caravel

## User Project Pointers
UPRJ_VERILOG_PATH ?= ../../../verilog
UPRJ_RTL_PATH = $(UPRJ_VERILOG_PATH)/rtl
UPRJ_BEHAVIOURAL_MODELS = ../
UPRJ_DES_PATH = $(UPRJ_VERILOG_PATH)/rtl/des
UPRJ_SBOX_PATH = $(UPRJ_VERILOG_PATH)/rtl/des/sbox

## Simulation mode: RTL/GL
SIM_DEFINES = -DFUNCTIONAL -DSIM
SIM?=RTL

SCRIPTS_DIR ?= ../../../scripts/

.SUFFIXES:

PATTERN = des_encrypt

all: vcd key_input.txt block_input.txt expected.txt

des_encrypt.vvp: des_encrypt_tb.v
	iverilog $(SIM_DEFINES) \
	-I $(CARAVEL_BEHAVIOURAL_MODELS) -I $(CARAVEL_RTL_PATH) \
	-I $(UPRJ_BEHAVIOURAL_MODELS)    -I $(UPRJ_RTL_PATH) \
	-I $(UPRJ_DES_PATH) -I $(UPRJ_SBOX_PATH) \
	$< -o $@ 

vcd: des_encrypt.vvp key_input.txt block_input.txt expected.txt
	vvp $<

key_input.txt block_input.txt expected.txt:
	python3 $(SCRIPTS_DIR)/descrypt.py

# ---- Clean ----

clean:
	rm -f *.vvp *.vcd *.txt

.PHONY: clean hex all vcd
