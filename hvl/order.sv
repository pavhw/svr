//******************************************************************************
//
// SPDX-License-Identifier: Apache-2.0
//
// Copyright 2026 Anton Polstyankin
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
//******************************************************************************

//******************************************************************************
//
// Manipulation of bit, byte, and word order
//
//******************************************************************************

package order;
    //--------------------------------------------------------------------------
    function automatic bit [15:0] revert_byte_order_16(bit [15:0] value);
        return {value[7:0], value[15:8]};
    endfunction

    //--------------------------------------------------------------------------
    function automatic bit [31:0] revert_byte_order_32(bit [31:0] value);
        return {value[7:0], value[15:8], value[23:16], value[31:24]};
    endfunction

    //--------------------------------------------------------------------------
    function automatic bit [63:0] revert_byte_order_64(bit [63:0] value);
        return {
            value[7:0], value[15:8], value[23:16], value[31:24],
            value[39:32], value[47:40], value[55:48], value[63:56]
        };
    endfunction
endpackage: order
