# PrismQuanta Ecosystem: Implementation and Testing Plan

## Introduction

This document provides a step-by-step guide for setting up a local development and testing workspace for the complete PrismQuanta ecosystem. The ecosystem is a collection of specialized `quanta_*` projects designed to work together as a cohesive, autonomous system.

Following this guide will allow you to download all necessary project repositories, configure the unified environment, build all components, and run integration tests to ensure the system is operating correctly.

## Prerequisites

Before you begin, ensure your development environment has the following tools installed and available in your system's PATH:

-   **Git:** For cloning the project repositories.
-   **C++ Compiler:** A modern C++ compiler (e.g., g++, Clang) that supports C++17.
-   **CMake:** For building the C++ components.
-   **Make:** Or another build automation tool compatible with CMake.
-   **Python:** Version 3.8 or higher, with `pip` and `venv`.
-   **R:** The R programming language interpreter (`Rscript`).
-   **PowerShell:** For running `quanta_occipita` and other utility scripts (if on a Windows environment).

## Step 1: Download the Project Ecosystem

All PrismQuanta projects are housed in a central location. The recommended way to acquire them is by using the `quanta_glia` repository manager, which is designed to bootstrap the entire ecosystem.

### Method A: Automated Setup via QuantaGlia (Recommended)

1.  **Clone QuantaGlia:**
    ```bash
    git clone https://github.com/prism-quanta/quanta_glia.git
    cd quanta_glia
    ```

2.  **Run the Bootstrap Script:**
    The `quanta_glia` project should contain a script to clone all other necessary repositories into a parent directory.
    ```bash
    ./scripts/bootstrap_ecosystem.sh
    ```
    This will create a `prismquanta` directory and clone all `quanta_*` projects inside it.

### Method B: Manual Download

If the bootstrap script is unavailable, you can clone each repository manually. Create a root workspace directory (e.g., `prismquanta`) and clone all the following projects into it.

```bash
# Create a workspace directory
mkdir prismquanta && cd prismquanta

# --- Core System ---
git clone https://github.com/prism-quanta/quanta_porto.git
git clone https://github.com/prism-quanta/quanta_sensa.git

# --- Agent Modules ---
git clone https://github.com/prism-quanta/quanta_ethos.git
git clone https://github.com/prism-quanta/quanta_dorsa.git
git clone https://github.com/prism-quanta/quanta_cogno.git

# --- Monitoring and Safety ---
git clone https://github.com/prism-quanta/quanta_quilida.git
git clone https://github.com/prism-quanta/quanta_alarma.git
git clone https://github.com/prism-quanta/quanta_pulsa.git

# --- Task Management ---
git clone https://github.com/prism-quanta/quanta_serene.git
git clone https://github.com/prism-quanta/quanta_lista.git

# --- Developer Tools ---
git clone https://github.com/prism-quanta/quanta_occipita.git
git clone https://github.com/prism-quanta/quanta_memora.git

# --- Visualization ---
git clone https://github.com/prism-quanta/quanta_retina.git
git clone https://github.com/prism-quanta/quanta_cerebra.git
git clone https://github.com/prism-quanta/alignment_map.git
git clone https://github.com/prism-quanta/multiple_viewer.git

# --- Knowledge Management ---
git clone https://github.com/prism-quanta/quanta_glia.git
```

## Step 2: Configure the Workspace

The entire ecosystem is configured through a central environment file at the root of the workspace.

1.  **Navigate to the root:**
    Make sure you are in the `prismquanta` directory that now contains all the project folders.

2.  **Create the Environment File:**
    Create a file named `prismquanta.env`. This file will define all shared paths for queues, logs, and other resources.

    ```bash
    touch prismquanta.env
    ```

3.  **Populate the `prismquanta.env` file:**
    Add the following content to the file. These paths are examples; adjust them if your workspace structure is different.

    ```ini
    # Root directory for the ecosystem
    PRISMQUANTA_ROOT=$(pwd)

    # Directories for file-based communication queues
    QUEUE_PENDING=${PRISMQUANTA_ROOT}/queue/pending
    QUEUE_IN_PROGRESS=${PRISMQUANTA_ROOT}/queue/in_progress
    QUEUE_COMPLETED=${PRISMQUANTA_ROOT}/queue/completed
    QUEUE_FAILED=${PRISMQUANTA_ROOT}/queue/failed
    QUEUE_HUMAN_APPROVAL=${PRISMQUANTA_ROOT}/queue/human_approval

    # Centralized logging
    LOG_DIR=${PRISMQUANTA_ROOT}/logs
    CENTRAL_EVENT_LOG=${LOG_DIR}/events.jsonl

    # Binary output directory
    BIN_DIR=${PRISMQUANTA_ROOT}/bin

    # LLM Model Paths
    ETHOS_MODEL_PATH=/path/to/your/llm/ethos_model.gguf
    PORTO_MODEL_PATH=/path/to/your/llm/porto_model.gguf
    GLIA_MODEL_PATH=/path/to/your/llm/glia_model.gguf
    ```
    **Note:** You must replace the `/path/to/your/llm/` placeholders with the actual paths to the local LLM models required by the system.

4.  **Create Queue Directories:**
    Create the directories specified in the configuration file.
    ```bash
    mkdir -p queue/pending queue/in_progress queue/completed queue/failed queue/human_approval logs
    ```

## Step 3: Build the Ecosystem

A unified build script should be present at the root of the workspace to compile all components.

1.  **Run the Build Script:**
    Execute the main build script. This script will iterate through all C++ projects, run `cmake` and `make`, and install Python dependencies for all Python projects into their own virtual environments.

    ```bash
    # Ensure the script is executable
    chmod +x build_all.sh

    # Run the build
    ./build_all.sh
    ```
    If a `Makefile` is provided instead, use `make all`.

2.  **Verify the Build:**
    After the script finishes, check the `bin/` directory. It should now be populated with executables from the C++ projects (e.g., `quanta-ethos`, `quanta-sensa`).

## Step 4: Run Integration Tests

A unified testing script allows you to verify the health and interoperability of the entire ecosystem.

1.  **Run the Test Script:**
    Execute the main test script. This will run unit tests for each module and then perform integration tests using mock components to ensure the communication pipeline is working.

    ```bash
    # Ensure the script is executable
    chmod +x test_all.sh

    # Run the tests
    ./test_all.sh
    ```

2.  **Review Test Results:**
    The script should output a summary of test results. If any tests fail, check the logs in the `logs/` directory for detailed error messages. All tests should pass before proceeding.

## Step 5: Launch the System

Once the ecosystem is built and has passed all tests, you can launch it using the master control script.

1.  **Source the Environment:**
    Before launching, source the environment file to load the configuration into your shell session.
    ```bash
    source prismquanta.env
    ```

2.  **Run the Start Script:**
    Execute the main start script. This will launch all necessary daemons and background processes in the correct order.
    ```bash
    # Ensure the script is executable
    chmod +x start_system.sh

    # Launch the ecosystem
    ./start_system.sh
    ```

3.  **Monitor the System:**
    The system should now be running. You can use monitoring tools like `quanta_pulsa` (if available) to observe the system's behavior or tail the central event log:
    ```bash
    tail -f $CENTRAL_EVENT_LOG
    ```

This completes the setup and launch of the PrismQuanta ecosystem. You can now interact with the system via the `quantalista-cli` tool to create and manage tasks.
