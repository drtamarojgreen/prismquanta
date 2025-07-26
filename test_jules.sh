#!/bin/bash

cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd

source setup_environment.sh

echo "Running enhanced_task_manager.sh..."
./scripts/enhanced_task_manager.sh

echo "Running code_analysis.sh..."
./scripts/code_analysis.sh
