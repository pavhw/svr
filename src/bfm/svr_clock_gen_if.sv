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
// Simple clock generator
//
//******************************************************************************

interface svr_clock_gen_if(output logic clock_o);
    real m_period_ns = 10e-6;
    bit m_clock_en = 0;

    //--------------------------------------------------------------------------
    function void configure_period(real period);
        assert (period > 0)
        else $fatal(1, "Negative or zero value of the clock period in '%m'.");

        m_period_ns = period * 1e9;
    endfunction

    //--------------------------------------------------------------------------
    function void configure_freq(real freq);
        assert (freq > 0)
        else $fatal(1, "Negative or zero value of the frequency in '%m'.");

        m_period_ns = 1e9 / freq;
    endfunction

    //--------------------------------------------------------------------------
    function void start();
        m_clock_en = 1;
    endfunction

    //--------------------------------------------------------------------------
    function void stop();
        m_clock_en = 0;
    endfunction

    //--------------------------------------------------------------------------
    function bit is_run();
        return m_clock_en;
    endfunction

    //--------------------------------------------------------------------------
    initial begin
        clock_o = 0;

        forever begin
            wait (m_clock_en);
            clock_o = ~clock_o;
            #(0.5ns * m_period_ns);
        end
    end
endinterface
