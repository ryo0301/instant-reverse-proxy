#!/bin/bash

timer={{{timer}}}

ssh_estab=$(ss -H -o state established '( dport = :ssh or sport = :ssh )' | grep ssh | wc -l)

if (( $ssh_estab == 0 )); then
  job=$(atq)
  if [ -z "$job" ]; then
    at now+${timer}hour <<< 'shutdown now'
  fi
else
  jobid=$(atq | awk 'NR==1{print $1}')
  if [ -n "$jobid" ]; then
    atrm $jobid
  fi
fi
