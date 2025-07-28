#!/usr/bin/env bash

change="$1"

case "$change" in
  inc|up)
    # Increase volume, limit to 100% (1.0)
    wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ 5%+ >/dev/null
    ;;
  dec|down)
    wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%- >/dev/null
    ;;
  mute|toggle)
    wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle >/dev/null
    ;;
  *)
    echo "Usage: $0 [inc|dec|mute]" >&2
    exit 1
    ;;
esac

# Query current volume and mute state
vol_raw=$(wpctl get-volume @DEFAULT_AUDIO_SINK@)
# Example outputs: "Volume: 0.53 [MUTED]" or "Volume: 0.33"

if [[ "$vol_raw" == *"[MUTED]"* ]]; then
    is_muted=true
else
    is_muted=false
fi
# Get just the fraction (the second word)
vol_frac=$(echo "$vol_raw" | awk '{print $2}')
vol_perc=$(awk "BEGIN { print int($vol_frac * 100) }")

if $is_muted; then
    icon="🔇"
    message="Volume: Muted"
else
    if [[ $vol_perc -ge 70 ]]; then
        icon="🔊"
    elif [[ $vol_perc -ge 30 ]]; then
        icon="🔉"
    elif [[ $vol_perc -gt 0 ]]; then
        icon="🔈"
    else
        icon="🔇"
    fi
    message="Volume: $vol_perc%"
fi

notify-send -e -u low \
  -h string:x-canonical-private-synchronous:volume \
  -h int:value:"$vol_perc" \
  "$icon $message"
