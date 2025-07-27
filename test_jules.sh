#!/bin/bash

cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd

source setup_environment.sh

echo "Running enhanced_task_manager.sh..."
./scripts/enhanced_task_manager.sh

echo "Running code_analysis.sh..."
./scripts/code_analysis.sh

echo "Running define_requirements.sh..."
./scripts/define_requirements.sh

echo "Running ethics_bias_checker.sh..."
./scripts/ethics_bias_checker.sh

echo "Running ethics_monitor.sh..."
./scripts/ethics_monitor.sh

echo "Running plan_code_tasks.sh..."
./scripts/plan_code_tasks.sh

echo "Running remediation_tasks.sh..."
./scripts/remediation_tasks.sh

echo "Running rule_enforcer.sh..."
./scripts/rule_enforcer.sh

echo "Running run_planner.sh..."
./scripts/run_planner.sh

# echo "Running self_chat_loop.sh..."
# ./scripts/self_chat_loop.sh
