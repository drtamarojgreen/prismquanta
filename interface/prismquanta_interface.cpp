// prismquanta_interface.cpp
// PrismQuanta - Offline Autonomous LLM Scheduler with Logging

#include <iostream>
#include <fstream>
#include <filesystem>
#include <chrono>
#include <thread>
#include <cstdlib>
#include <ctime>
#include <map>
#include <vector>

namespace fs = std::filesystem;

// Configuration
const std::string LOG_FILE = "data/logs/interface.log";
const std::string PROMPT_FILE = "prompts/input_prompt.txt";
const std::string TIMEOUT_MARKER = ".timeout";
const std::string RULES_FILE = "rules/rules.txt";
const std::string PRIORITY_FILE = "rules/priorities.txt";
const int POLL_INTERVAL_SEC = 60;
const int TIMEOUT_DURATION_SEC = 7200;

// Logging utility
void write_log(const std::string& entry) {
    std::ofstream log(LOG_FILE, std::ios_base::app);
    auto now = std::chrono::system_clock::to_time_t(std::chrono::system_clock::now());
    log << "[" << std::ctime(&now) << "] " << entry << "\n";
}

// Load priorities
std::map<std::string, int> load_priorities() {
    write_log("Loading priorities...");
    std::map<std::string, int> priorities;
    std::ifstream in(PRIORITY_FILE);
    if (!in) {
        write_log("ERROR: Could not open priority file.");
        return priorities;
    }
    std::string task;
    int priority;
    while (in >> task >> priority) {
        priorities[task] = priority;
    }
    write_log("Loaded " + std::to_string(priorities.size()) + " priority items.");
    return priorities;
}

// Load rules
std::vector<std::string> load_rules() {
    write_log("Loading rules...");
    std::vector<std::string> rules;
    std::ifstream in(RULES_FILE);
    if (!in) {
        write_log("ERROR: Could not open rules file.");
        return rules;
    }
    std::string line;
    while (std::getline(in, line)) {
        rules.push_back(line);
    }
    write_log("Loaded " + std::to_string(rules.size()) + " rules.");
    return rules;
}

// Timeout check
bool in_timeout() {
    if (!fs::exists(TIMEOUT_MARKER)) return false;
    auto last_modified = fs::last_write_time(TIMEOUT_MARKER);
    auto now = fs::file_time_type::clock::now();
    auto diff = std::chrono::duration_cast<std::chrono::seconds>(now - last_modified).count();
    bool timed_out = diff < TIMEOUT_DURATION_SEC;
    if (timed_out)
        write_log("Timeout marker active. Skipping task execution.");
    return timed_out;
}

// Set timeout
void set_timeout() {
    std::ofstream out(TIMEOUT_MARKER);
    out << "timeout";
    write_log("Timeout marker updated.");
}

// Run pipeline
void run_pipeline() {
    write_log("Running pipeline script...");
    int status = std::system(("bash scripts/run_task.sh " + PROMPT_FILE).c_str());
    if (status != 0) {
        write_log("Pipeline execution failed. Exit code: " + std::to_string(status));
        set_timeout();
    } else {
        write_log("Pipeline executed successfully.");
    }
}

int main() {
    std::cout << "PrismQuanta Task Manager Initialized.\n";
    write_log("Interface startup initiated.");

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
