---
title: The X axis that wasn't a frequency
date: 2026-05-06
tags: [gpib, scpi, delphi, spectrum-analyzer, keysight]
domain: rf
status: growing
---

## Context

Converting a legacy Delphi 6 control program from an Agilent E4405B to an E4407B
spectrum analyzer, over GPIB. Both instruments speak SCPI. The Y axis (amplitude)
marker read worked fine on the new hardware. The X axis (frequency) came back
empty or garbage. Nothing else in the code changed between the two instruments —
same GPIB wrapper, same query functions.

## The bug

Three separate issues stacked on top of each other, and each one alone would have
been enough to explain the symptom:

**1. Zero span returns time, not frequency.**
`:CALCulate:MARKer1:X?` doesn't always return Hz — if the instrument is in zero
span mode, X is a *time* value in seconds instead. The E4405B had apparently
defaulted to a non-zero span; the E4407B's preset state didn't. Parsing a stray
`0.00015` as if it were a frequency just looks like near-zero garbage, not an
obvious type error.

**2. The marker number was implicit, and the E4407B doesn't allow that.**
The old code queried `:CALCulate:MARKer:X?` with no marker number. Some E4405B
firmware quietly defaulted this to marker 1. The E4407B is stricter and expects
`:CALCulate:MARKer1:X?` explicitly — the un-numbered form just returns empty.

**3. The marker was never anchored to real data.**
Enabling a marker (`:CALCulate:MARKer1:STATe ON`) doesn't put it anywhere
meaningful by itself. Without a peak search (`:CALCulate:MARKer1:MAXimum`) or an
explicit placement, the marker sits on a trace with no valid value yet, and the
instrument returns the SCPI "not a number" sentinel `9.91E+37` instead of an error
you'd notice immediately.

## Why Y "worked" the whole time

This is the part worth remembering: Y wasn't actually more correct, it just failed
less visibly. Amplitude reads happened to pull stale-but-plausible values out of
the GPIB buffer from a previous read, so the numbers looked reasonable even though
the same structural issues applied to both axes. A working-looking output isn't
proof the read logic is correct — it can just mean the failure mode happens to
produce numbers that pass a sniff test.

## Fix

```pascal
gpibWrite('*CLS');
gpibWrite(':INITiate:CONTinuous OFF');
gpibWrite(':INITiate:IMMediate');
gpibQuery('*OPC?');                          // block until sweep completes

gpibWrite(':CALCulate:MARKer1:STATe ON');
gpibWrite(':CALCulate:MARKer1:MAXimum');     // anchor marker to real data

markerFreq := Trim(gpibQuery(':CALCulate:MARKer1:X?'));
markerVal  := Trim(gpibQuery(':CALCulate:MARKer1:Y?'));

if (markerVal = '') or (Pos('ERR', UpperCase(markerVal)) > 0)
   or (Pos('9.91E+37', markerVal) > 0) then
begin
  ShowMessage('Marker read failed - no valid data');
  Exit;
end;
```

## The general lesson

Instrument firmware differences rarely announce themselves as errors — they show
up as silently different *interpretations* of the same query. Same command, same
wire protocol, different meaning depending on internal state (span mode, marker
state, sweep completion) that the caller has to explicitly pin down rather than
assume carries over from one instrument generation to the next.