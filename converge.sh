#!/usr/bin/env bash

show_help() {
  echo "Usage... $(basename $0) [-v] [-e] [-s scenario-name] [-h]"
}

verbosity=
extra_vars=

while getopts "s:hve:" opt; do
  case "$opt" in
    s)
      scenario="${OPTARG}"
      ;;
    v)
      verbosity="-vvv"
      ;;
    e)
      extra_vars="-e ${OPTARG}"
      ;;
    ?|h)
      show_help
      exit 0
      ;;
  esac
done

# No Argument has been passed to script:
if [ $OPTIND -eq 1 ];
then
  show_help
  exit 0
fi

scenario_folder="./molecule/${scenario}"
scenario_playbook="${scenario}.yml"
scenario_converge_playbook="converge.yml"
scenario_converge_full_path="${scenario_folder}/${scenario_converge_playbook}"

# Check scenario directory is available:
if [ ! -d "${scenario_folder}" ];
then
  echo "Scenario directory '${scenario_folder}' does not exist."
  exit 1;
fi

# Check converge playbook is available:
if [ ! -f "${scenario_converge_full_path}" ];
then
  echo "Scenario converge playbook '${scenario_converge_playbook}' does not exist."
  exit 1;
fi

# Install required roles
ansible-galaxy install -f -r ./roles/requirements.yml

env_file_path="${scenario_folder}/.env"

# Run Converge of scenario with env vars from .env file
export $(cat $env_file_path | xargs) && ansible-playbook $extra_vars $verbosity $scenario_converge_full_path



