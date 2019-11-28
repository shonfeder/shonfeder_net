#!/usr/bin/env bash

# Runs the server, restarting it on file changes

source_dirs="lib bin"
args=${@:-"shonfeder_net"}
cmd="dune exec ${args}"

kill_running_jobs() {
  if [[ $(jobs -pr) != "" ]]
  then
    kill $(jobs -pr)
  fi
}

sigint_handler()
{
  kill_running_jobs
  exit
}

trap sigint_handler SIGINT

while true; do
  echo "running: $cmd"
  $cmd &
  inotifywait -e modify -e move -e create -e delete -e attrib -r $source_dirs
  echo "restarting..."
  kill_running_jobs
done
