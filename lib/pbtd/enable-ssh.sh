#!/bin/bash
agent-socket=/var/www/pbtd/shared/tmp/sockets/ssh-agent-socket
agent-export=/var/www/pbtd/shared/tmp/ssh/ssh-export-agent
agent-pid=/var/www/pbtd/shared/tmp/pids/ssh-agent.pid
ssh-key=/var/www/pbtd/shared/tmp/ssh/pbtd_key

start_agent() {
  ssh-agent -s -a $agent-socket > $agent-export
  . $agent-export
  echo $SSH_AGENT_PID > $agent-pid
}

if [ -z "$SSH_AGENT_PID" ] ; then start_agent; fi

if !  ps -p $SSH_AGENT_PID > /dev/null; then
  start_agent;
fi

ssh-add -l > /dev/null 2>&1
if [ $? -ne 0 ]; then
 ssh-add $ssh-key > /dev/null 2>&1
fi
