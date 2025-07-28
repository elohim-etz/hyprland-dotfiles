#!/usr/bin/env bash

change="$1"
case "$change" in
  inc|up)
    brightnessctl set 5%+ >/dev/null
    ;;
  dec|down)
    brightnessctl set 5%- >/dev/null
    ;;
  *)
    echo "Usage: $0 [inc|dec]" >&2
    exit 1
    ;;
esac

max=$(brightnessctl max)
cur=$(brightnessctl get)
perc=$(( cur * 100 / max ))

notify-send -e -u low \
  -h string:x-canonical-private-synchronous:brightness \
  -h int:value:"$perc" \
  "☀ Brightness: $perc%"
