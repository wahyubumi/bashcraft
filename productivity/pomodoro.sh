#!/bin/bash

# Set durations (in seconds)
WORK_DURATION=$((25 * 60))     # 25 minutes work (set to 5 seconds for testing)
SHORT_BREAK=$((5 * 60))       # 5 minutes break (set to 5 seconds for testing)
CYCLES=4                     # Number of Pomodoro cycles

# Function for countdown
countdown() {
    local seconds=$1
    while ((seconds > 0)); do
        printf "\r%02d:%02d" $((seconds / 60)) $((seconds % 60))
        sleep 1
        ((seconds--))
    done
    printf "\rTime's up!               \n"
}

# Function for rhythmic beep
pomodoro_beep() {
    local level=$1
    for ((beep_count = 1; beep_count <= level; beep_count++)); do
        for _ in {1..3}; do
            echo -ne "\a" && sleep 0.2
        done
        sleep 0.6
    done
}

# Main Pomodoro loop
i=1  # Initialize cycle counter
while ((i <= CYCLES)); do
    echo "Cycle $i: Work session starts now!"
    pomodoro_beep 2          # Two-level beep for work session start
    countdown $WORK_DURATION

    if ((i < CYCLES)); then
        echo "Take a short break."
        pomodoro_beep 3      # Three-level beep for short break start
        countdown $SHORT_BREAK
    fi

    ((i++))  # Increment cycle counter
done

echo "Pomodoro complete! Great job!"
pomodoro_beep 6              # Final three-level beep to indicate completion
