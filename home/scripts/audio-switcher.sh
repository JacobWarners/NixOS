#!/usr/bin/env sh

sinks=$(wpctl status | awk '/Sinks:/, /Sink endpoints:/' | grep -vE 'Sink endpoints:|Sinks:' | sed -e 's/\[vol:.*\]//' -e 's/├//' -e 's/│//' -e 's/└//' -e 's/^\s\+//' -e 's/\*\s\+//')

chosen_sink=$(echo "$sinks" | rofi -dmenu -p "Select Audio Output")

if [ -n "$chosen_sink" ]; then
    sink_id=$(echo "$chosen_sink" | awk '{print $1}' | tr -d '.')
    wpctl set-default "$sink_id"
fi
