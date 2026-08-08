#!/bin/bash
# Status line: "5% - 33% 3h16m - 11% Sun1:00p" = context used, then each budget's
# used share paired with when it comes back — the 5-hour as a countdown, the
# 7-day as the local weekday and clock time it renews. Any percentage at 90% or
# above is printed in red.
# context_window is null before the first API call and right after /compact;
# rate_limits only exists for Claude.ai subscribers after the first API response.
# resets_at is a Unix epoch in seconds. Missing percentages hold their slot as
# "?%"; a missing resets_at just drops that segment's time.

jq -r '
  def pct(x): x as $v
              | if $v == null then "?%"
                else ("\($v | round)%") as $s
                     | if $v >= 90 then "[31m\($s)[0m" else $s end
                end;
  def pad(n): "0\(n)" | .[-2:];
  def hm(t): ([t - now, 0] | max) as $s
             | "\($s / 3600 | floor)h\(pad($s / 60 | floor | . % 60))m";
  def stamp(t): (t | localtime) as $lt
                | $lt[3] as $h
                | "\($lt | strftime("%a"))\(if $h % 12 == 0 then 12 else $h % 12 end):\(pad($lt[4]))\(if $h < 12 then "a" else "p" end)";
  def when(t; f): if t == null then "" else " \(t | f)" end;
  .context_window.used_percentage as $ctx
  | .rate_limits.five_hour as $h5
  | .rate_limits.seven_day as $d7
  | if ($ctx // $h5.used_percentage // $d7.used_percentage) == null then empty
    else [ pct($ctx),
           "\(pct($h5.used_percentage))\(when($h5.resets_at; hm(.)))",
           "\(pct($d7.used_percentage))\(when($d7.resets_at; stamp(.)))"
         ] | join(" - ")
    end'
