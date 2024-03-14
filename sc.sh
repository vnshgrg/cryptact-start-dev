#!/bin/bash

# Start a new tmux session
SESSION_NAME="CttDev"
SESSIONEXISTS="$(tmux list-sessions | grep "$SESSION_NAME")"
CMD="START"

BACKEND_PANE_INDEX="0"
CLIENT_PANE_INDEX="2"
PAULETTE_SCHEDULER_PANE_INDEX="1"
PAULETTE_CRAWLER_PANE_INDEX="3"

create_session() {
    echo "[DEV] [START] CREATING NEW SESSION"
    # Start a new session
    tmux new-session -d -s $SESSION_NAME

    # Split the window into four panes.
    tmux split-window -h
    tmux split-window -v
    tmux select-pane -t 0
    tmux split-window -v
    echo "[DEV] [COMPLETE] CREATING NEW SESSION"
}

attach_to_session() {
    echo "[DEV] [START] ATTACHING TO SESSION"
    # Attach to the session
    tmux attach-session -t $SESSION_NAME
    echo "[DEV] [COMPLETE] ATTACHING TO SESSION"
}

start_all() {
    echo "[DEV] STARTING ALL SERVICES"
    # Send commands to each pane
    # start backend
    tmux send-keys -t $SESSION_NAME:0.$BACKEND_PANE_INDEX "cd ~/Code/cryptact" C-m "pnpm start:backend" C-m
    # start client
    tmux send-keys -t $SESSION_NAME:0.$CLIENT_PANE_INDEX "cd ~/Code/cryptact" C-m "pnpm start:client" C-m
    # start paulette 
    tmux send-keys -t $SESSION_NAME:0.$PAULETTE_SCHEDULER_PANE_INDEX "cd ~/Code/paulette" C-m "make -C scheduler run" C-m
    tmux send-keys -t $SESSION_NAME:0.$PAULETTE_CRAWLER_PANE_INDEX "cd ~/Code/paulette" C-m "make -C crawler run" C-m
    echo "[DEV] ALL SERVICES STARTED"
}

stop() {
    tmux send-keys -t $SESSION_NAME:0.$1 C-c C-m
}

stop_all() {
    echo "[DEV] STOPPING ALL SERVICES"
    # Send commands to each pane
    # start backend
    tmux send-keys -t $SESSION_NAME:0.$BACKEND_PANE_INDEX C-c C-m
    tmux send-keys -t $SESSION_NAME:0.$CLIENT_PANE_INDEX C-c C-m
    tmux send-keys -t $SESSION_NAME:0.$PAULETTE_SCHEDULER_PANE_INDEX C-c C-m
    tmux send-keys -t $SESSION_NAME:0.$PAULETTE_CRAWLER_PANE_INDEX C-c C-m
    echo "[DEV] ALL SERVICES STOPPED"
}

exit_all() {
    echo "[DEV] EXITING ALL SERVICES"
    tmux send-keys -t $SESSION_NAME:0.$BACKEND_PANE_INDEX "exit" C-m
    tmux send-keys -t $SESSION_NAME:0.$CLIENT_PANE_INDEX "exit" C-m
    tmux send-keys -t $SESSION_NAME:0.$PAULETTE_SCHEDULER_PANE_INDEX "exit" C-m
    tmux send-keys -t $SESSION_NAME:0.$PAULETTE_CRAWLER_PANE_INDEX "exit" C-m
    echo "[DEV] ALL SERVICES EXITED"
}

start_session() {
    echo "[DEV] CHECKING IF SESSION ALREADY EXISTS"
    # Only create tmux session if it doesn't already exist
    if [ "$SESSIONEXISTS" = "" ]
    then 
        echo "[DEV] SESSION DOES NOT EXIST"
        # Create session and window
        create_session
        # Run backend, client and paulette
        start_all
        echo "[DEV] ATTACHING TO NEW SESSION"
    else
        echo "[DEV] SESSION EXISTS"
    fi
    attach_to_session
}

stop_session() {
    echo "[DEV] CHECKING IF SESSION ALREADY EXISTS"
    if [ "$SESSIONEXISTS" = "" ]
    then 
        echo "[DEV] SESSION DOES NOT EXIST"
    else
        stop_all
    fi
}

if [ "$1" = "start" ]; then
    start_session
elif [ "$1" = "stop" ]; then
    stop_session
    exit_all
elif [ "$1" = "restart" ]; then
    echo "[DEV] CHECKING IF SESSION EXISTS"
    if [ "$SESSIONEXISTS" = "" ]
    then 
        echo "[DEV] SESSION DOES NOT EXIST"
    else
        stop_all
        delay 5
    fi
    start_all
elif [ "$1" = "kill" ]; then
    if [ "$2" = "all" ]; then
        stop_session
        exit_all
    elif [ "$2" = "client" ]; then
        echo "[DEV] STOPPING CLIENT"
        stop $CLIENT_PANE_INDEX
        echo "[DEV] STOPPING CLIENT COMPLETED"
    elif [ "$2" = "backend" ]; then
        echo "[DEV] STOPPING BACKEND"
        stop $BACKEND_PANE_INDEX
        echo "[DEV] STOPPING BACKEND COMPLETED"
    elif [ "$2" = "paulette" ]; then
        echo "[DEV] STOPPING PAULETTE"
        stop $PAULETTE_SCHEDULER_PANE_INDEX
        stop $PAULETTE_CRAWLER_PANE_INDEX
        echo "[DEV] STOPPING PAULETTE COMPLETED"
    else
        echo "[DEV] INVALID COMMAND"
    fi
else
    echo "[DEV] INVALID COMMAND"
fi
