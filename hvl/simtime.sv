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
// Working with simulation time and delays
//
//******************************************************************************

package simtime;

    //***************************************************************
    // Types
    //

    typedef enum {FS, PS, NS, US, MS, S} time_unit_e;

    typedef struct {
        real value;
        time_unit_e unit;
    } time_t;

    // Types
    //***************************************************************

    //***************************************************************
    // Internals
    //

    //--------------------------------------------------------------------------
    function automatic realtime _time_unit(time_unit_e tu);
        case (tu)
            FS: _time_unit = 1fs;
            PS: _time_unit = 1ps;
            NS: _time_unit = 1ns;
            US: _time_unit = 1us;
            MS: _time_unit = 1ms;
            S:  _time_unit = 1s;
        endcase
    endfunction

    //--------------------------------------------------------------------------
    function automatic longint _time_unit_in_fs(time_unit_e tu);
        case (tu)
            FS: _time_unit_in_fs = 64'd1;
            PS: _time_unit_in_fs = 64'd1_000;
            NS: _time_unit_in_fs = 64'd1_000_000;
            US: _time_unit_in_fs = 64'd1_000_000_000;
            MS: _time_unit_in_fs = 64'd1_000_000_000_000;
            S:  _time_unit_in_fs = 64'd1_000_000_000_000_000;
        endcase
    endfunction

    //--------------------------------------------------------------------------
    function automatic time_unit_e _time_unit_up(time_unit_e tu);
        return time_unit_e'(int'(tu) + 1);
    endfunction

    //--------------------------------------------------------------------------
    function automatic time_unit_e _time_unit_down(time_unit_e tu);
        return time_unit_e'(int'(tu) - 1);
    endfunction

    //--------------------------------------------------------------------------
    function automatic time_unit_e _global_time_unit_resolution();
        time_unit_e tu = FS;

        while (_time_unit(tu) == 0) begin
            tu = _time_unit_up(tu);
        end

        return tu;
    endfunction

    // Internals
    //***************************************************************

    //***************************************************************
    // Functions/tasks
    //

    //--------------------------------------------------------------------------
    // Converts time to scale when the value is at least 1 and less than 1000
    //
    function automatic time_t normalize(time_t t);
        time_t result = t;
        bit is_negative = 0;

        if (t.value == 0) begin
            return t;
        end

        if (t.value < 0) begin
            is_negative = 1;
            result.value = -t.value;
        end

        if (result.value < 1.0) begin
            while ((result.value < 1) && (result.unit != FS)) begin
                result.value *= 1e3;
                result.unit = _time_unit_down(result.unit);
            end
        end
        else if (result.value > 1000.0) begin
            while ((result.value > 1000.0) && (result.unit != S)) begin
                result.value *= 1e-3;
                result.unit = _time_unit_up(result.unit);
            end
        end

        return is_negative ? '{-result.value, result.unit} : result;
    endfunction

    //--------------------------------------------------------------------------
    // Convert time to the specified time unit
    //
    function automatic time_t convert(time_t t, time_unit_e unit);
        real t_fs = t.value * _time_unit_in_fs(t.unit);
        return '{t_fs / _time_unit_in_fs(unit), unit};
    endfunction

    //--------------------------------------------------------------------------
    // Returns current simulation time (normalized)
    //
    function automatic time_t now();
        time_unit_e tu = _global_time_unit_resolution();
        return normalize('{$realtime / _time_unit(tu), tu});
    endfunction

    //--------------------------------------------------------------------------
    // Time addition with normalization
    //
    function automatic time_t add(time_t a, time_t b);
        time_t _a = normalize(a);
        time_t _b = convert(b, _a.unit);
        assert (_a.unit == _b.unit);

        return normalize('{_a.value + _b.value, _a.unit});
    endfunction

    //--------------------------------------------------------------------------
    // Time subtraction with normalization
    //
    function automatic time_t sub(time_t a, time_t b);
        return add(a, '{-b.value, b.unit});
    endfunction

    //--------------------------------------------------------------------------
    // Converts time to string with specified decimal precision
    //
    function automatic string to_string(time_t t, int prec = 6);
        string unit_s;
        string format_s;

        case (t.unit)
            FS: unit_s = "fs";
            PS: unit_s = "ps";
            NS: unit_s = "ns";
            US: unit_s = "us";
            MS: unit_s = "ms";
            S: unit_s = "s";
        endcase

        format_s = $sformatf("%%.%0df %s", prec, unit_s);

        return $sformatf(format_s, t.value);
    endfunction

    //--------------------------------------------------------------------------
    // Delay with checking that the simulation step is sufficient to ensure
    // the specified accuracy of the delay value. If the accuracy is not
    // sufficient to ensure the specified delay, an fatal error occurs
    // (setting the 'raise_fatal' to 0 will change the error to a warning).
    //
    task automatic checked_delay(time_t delay, bit raise_fatal = 1);
        longint expected_delay_fs;
        longint actual_delay_fs;
        time_t t0;
        time_t t1;
        longint t0_fs;
        longint t1_fs;
        time_unit_e tu;

        assert (delay.value >= 0)
        else begin
            $warning("Negative delay value");
            delay.value = 0;
        end

        if (delay.value == 0) begin
            return;
        end

        delay = convert(delay, _global_time_unit_resolution());

        t0 = now();
        #(delay.value * _time_unit(delay.unit));
        t1 = now();

        t0_fs = longint'(convert(t0, FS).value);
        t1_fs = longint'(convert(t1, FS).value);

        expected_delay_fs = longint'(convert(delay, FS).value);
        actual_delay_fs = t1_fs - t0_fs;

        assert (actual_delay_fs == expected_delay_fs)
        else begin
            const time_t delta_t = '{real'(actual_delay_fs), FS};
            const string expected = to_string(normalize(delay));
            const string actual = to_string(normalize(delta_t));
            const string msg = $sformatf(
                {"Time precision is too low for the required accuracy. ",
                "Specified delay value is %s, but actual (simulated) is %s."},
                expected, actual);

            if (raise_fatal) begin
                $fatal(1, msg);
            end
            else begin
                $warning(msg);
            end
        end
    endtask: checked_delay

    // Functions/tasks
    //***************************************************************
endpackage: simtime
