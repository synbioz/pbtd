#!/bin/bash
export SSH_AUTH_SOCK=/tmp/ssh-agent-socket

start_agent() {
  ssh-agent -s -a $SSH_AUTH_SOCK > /tmp/ssh-export-agent
  . /tmp/ssh-export-agent
  echo $SSH_AGENT_PID > /tmp/ssh-agent.pid
}

if [ -z "$SSH_AGENT_PID" ] ; then start_agent; fi

if !  ps -p $SSH_AGENT_PID > /dev/null; then
  start_agent;
fi

ssh-add -l > /dev/null 2>&1
if [ $? -ne 0 ]; then
 ssh-add ~/ssh/my_key > /dev/null 2>&1
fi
