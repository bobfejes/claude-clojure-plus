#!/bin/bash
# Status line: "20/40/80% 2h15m Tue 09:30" = context used / 5-hour budget left /
# 7-day budget left, then the countdown to the 5-hour reset, then the local
# weekday and clock time the 7-day budget renews.
# context_window is null before the first API call and right after /compact;
# rate_limits only exists for Claude.ai subscribers after the first API response.
# resets_at is a Unix epoch in seconds. Missing percentages render as "?"; the
# countdown and the renewal stamp each drop out entirely when unknown.

jq -r '
  def used(x): if x == null then "?" else (x | round | tostring) end;
  def left(x): if x == null then "?" else (100 - x | round | tostring) end;
  def pad(n): "0\(n)" | .[-2:];
  def hm(t): ([t - now, 0] | max) as $s
             | "\($s / 3600 | floor)h\(pad($s / 60 | floor | . % 60))m";
  .context_window.used_percentage as $ctx
  | .rate_limits.five_hour as $h5
  | .rate_limits.seven_day as $d7
  | (if ($ctx // $h5.used_percentage // $d7.used_percentage) == null then ""
     else "\(used($ctx))/\(left($h5.used_percentage))/\(left($d7.used_percentage))%"
     end) as $pct
  | (if $h5.resets_at == null then "" else hm($h5.resets_at) end) as $eta
  | (if $d7.resets_at == null then ""
     else ($d7.resets_at | strflocaltime("%a %H:%M"))
     end) as $renew
  | [$pct, $eta, $renew] | map(select(. != "")) | join(" ")
  | if . == "" then empty else . end'
