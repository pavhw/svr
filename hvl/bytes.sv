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
// Working with byte sequences
//
//******************************************************************************

package bytes;

    //***************************************************************
    // Types
    //

    typedef byte bytes_t[];
    typedef byte bytes_q_t[$];

    // Types
    //***************************************************************

    //--------------------------------------------------------------------------
    function automatic bytes_t from_hex(string s);
        bytes_t result = new[s.len / 2];

        assert (s.len % 2 == 0)
        else $error("The number of characters in the string must be even");

        for (int i = 0; i < result.size; i++) begin
            string ch = s.substr(i * 2, i * 2 + 1);
            result[i] = ch.atohex();
        end

        return result;
    endfunction

    //--------------------------------------------------------------------------
    function automatic string to_hex(bytes_t bytes, string sep = "");
        string s = "";

        foreach (bytes[i]) begin
            if (i == bytes.size - 1) begin
                sep = "";
            end

            $sformat(s, "%s%x%s", s, bytes[i], sep);
        end

        return s;
    endfunction

    //--------------------------------------------------------------------------
    function automatic bytes_t replace(
            bytes_t value, byte old_byte, byte new_byte
    );
        foreach (value[i]) begin
            if (value[i] == old_byte) begin
                value[i] = new_byte;
            end
        end

        return value;
    endfunction

    //--------------------------------------------------------------------------
    function automatic bytes_t to_lower_case(bytes_t bytes);
        bytes_t result = new[bytes.size];

        foreach (bytes[i]) begin
            if ((bytes[i] >= 8'h41) && (bytes[i] <= 8'h5A)) begin
                result[i] = bytes[i] + 8'h20;
            end
            else begin
                result[i] = bytes[i];
            end
        end

        return result;
    endfunction

    //--------------------------------------------------------------------------
    function automatic bytes_t to_upper_case(bytes_t bytes);
        bytes_t result = new[bytes.size];

        foreach (bytes[i]) begin
            if ((bytes[i] >= 8'h61) && (bytes[i] <= 8'h7A)) begin
                result[i] = bytes[i] - 8'h20;
            end
            else begin
                result[i] = bytes[i];
            end
        end

        return result;
    endfunction
endpackage: bytes
