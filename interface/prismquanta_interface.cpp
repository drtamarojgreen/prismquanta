/**
 * @file prismquanta_interface.cpp
 * @brief The main entry point for the PrismQuanta C++ interface.
 *
 * This application serves as the core engine for the PrismQuanta framework,
 * handling task scheduling, LLM interaction, and rule enforcement.
 */

#include <iostream>
#include <filesystem>
#include "Config.h"

namespace fs = std::filesystem;

int main(int argc, char* argv[]) {
    std::cout << "PrismQuanta C++ Interface Initializing..." << std::endl;
    std::cout << "Assuming current working directory is the project root." << std::endl;

    Config config;
    if (!config.load("environment.txt")) {
        std::cerr << "Failed to load 'environment.txt'. Make sure the application is run from the project root directory." << std::endl;
        return 1;
    }

    std::cout << "Configuration loaded successfully." << std::endl;

    // --- Test: Retrieve and print some config values ---
    // The C++ app just reads the string values. The calling scripts are responsible for ensuring paths are correct.
    if (auto modelDir = config.getString("MODEL_DIRECTORY")) {
        std::cout << "Model Directory: " << *modelDir << std::endl;
    } else {
        std::cout << "Model Directory: Not found in config." << std::endl;
    }

    if (auto pollInterval = config.getInt("POLL_INTERVAL_SEC")) {
        std::cout << "Poll Interval: " << *pollInterval << " seconds" << std::endl;
    } else {
        std::cout << "Poll Interval: Not found or invalid." << std::endl;
    }

    return 0;
}
    const int POLL_INTERVAL_SEC = std::stoi(config["POLL_INTERVAL_SEC"]);
    const int TIMEOUT_DURATION_SEC = std::stoi(config["TIMEOUT_DURATION_SEC"]);

    std::cout << "PrismQuanta Task Manager Initialized.\n";
    write_log("Interface startup initiated.");

    // NOTE: The loaded rules and priorities are not currently used in the main loop.
    auto rules = load_rules();
    auto priorities = load_priorities();

    while (true) {
        write_log("Polling loop triggered.");

        if (in_timeout()) {
            write_log("System is in timeout. Awaiting next poll...");
        } else {
            run_pipeline();
        }

        std::this_thread::sleep_for(std::chrono::seconds(POLL_INTERVAL_SEC));
    }

    return 0;
}
