 #!/bin/bash
start_agent() {
  ssh-agent -s -a /var/www/pbtd/shared/tmp/sockets/ssh-agent-socket > /var/www/pbtd/shared/tmp/ssh/ssh-export-agent
  . /var/www/pbtd/shared/tmp/ssh/ssh-export-agent
  echo $SSH_AGENT_PID > /var/www/pbtd/shared/tmp/pids/ssh-agent.pid
}

if ! [  -S /var/www/pbtd/shared/tmp/sockets/ssh-agent-socket ]  ; then start_agent; fi
if [ -z $SSH_AGENT_PID ] ; then . /var/www/pbtd/shared/tmp/ssh/ssh-export-agent; fi

ssh-add -l > /dev/null 2>&1
if [ $? -ne 0 ]; then
  ssh-add /var/www/pbtd/shared/tmp/ssh/pbtd_key > /dev/null 2>&1
fi
