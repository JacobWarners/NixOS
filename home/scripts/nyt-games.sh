#!/bin/bash

# This script launches one instance of Google Chrome and two instances of Firefox.

# Launch Google Chrome in the background.
# The '&' symbol allows the script to continue executing without waiting for Chrome to close.
google-chrome-stable &

# Wait a moment for Chrome to start opening.
sleep 1

# Launch the FIRST Firefox window. This will likely appear behind the next one.
firefox &

# Wait another moment.
sleep 1

# Launch the SECOND Firefox window. Since it's the last application launched,
# it should open in front and have focus.
firefox &

