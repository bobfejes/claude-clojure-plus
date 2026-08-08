#!/bin/bash
# Status line: "20/40/80%" = context used / 5-hour budget left / 7-day budget left.
# context_window is null before the first API call and right after /compact;
# rate_limits only exists for Claude.ai subscribers after the first API response.
# Missing values render as "?"; nothing prints until at least one is known.

jq -r '
  def used(x): if x == null then "?" else (x | round | tostring) end;
  def left(x): if x == null then "?" else (100 - x | round | tostring) end;
  .context_window.used_percentage as $ctx
  | .rate_limits.five_hour.used_percentage as $h5
  | .rate_limits.seven_day.used_percentage as $d7
  | if ($ctx // $h5 // $d7) == null then empty
    else "\(used($ctx))/\(left($h5))/\(left($d7))%"
    end'
