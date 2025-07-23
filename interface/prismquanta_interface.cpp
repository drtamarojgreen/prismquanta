// prismquanta_interface.cpp
// PrismQuanta - Offline Autonomous LLM Scheduler
// C++ polling-based interface to control bash-scripted LLM workflows with priority and rule tracking

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
const std::string LOG_DIR = "data/logs/";
const std::string PROMPT_FILE = "prompts/input_prompt.txt";
const std::string TIMEOUT_MARKER = ".timeout";
const std::string RULES_FILE = "config/rules.txt";
const std::string PRIORITY_FILE = "config/priorities.txt";
const int POLL_INTERVAL_SEC = 60;        // Poll every 60 seconds
const int TIMEOUT_DURATION_SEC = 7200;   // 2 hours

// Load priorities from file
std::map<std::string, int> load_priorities() {
    std::map<std::string, int> priorities;
    std::ifstream in(PRIORITY_FILE);
    std::string task;
    int priority;
    while (in >> task >> priority) {
        priorities[task] = priority;
    }
    return priorities;
}

// Load rules and consequences from file
std::vector<std::string> load_rules() {
    std::vector<std::string> rules;
    std::ifstream in(RULES_FILE);
    std::string line;
    while (std::getline(in, line)) {
        rules.push_back(line);
    }
    return rules;
}

// Utility to check if timeout marker exists
bool in_timeout() {
    if (!fs::exists(TIMEOUT_MARKER)) return false;
    auto last_modified = fs::last_write_time(TIMEOUT_MARKER);
    auto now = fs::file_time_type::clock::now();
    auto diff = std::chrono::duration_cast<std::chrono::seconds>(now - last_modified).count();
    return diff < TIMEOUT_DURATION_SEC;
}

// Utility to create or update timeout marker
void set_timeout() {
    std::ofstream out(TIMEOUT_MARKER);
    out << "timeout";
    out.close();
}

// Launches the full pipeline script
void run_pipeline() {
    std::cout << "[INFO] Running LLM pipeline...\n";
    int status = std::system("bash scripts/run_task.sh prompts/input_prompt.txt");
    if (status != 0) {
        std::cerr << "[ERROR] Pipeline script failed with exit code: " << status << "\n";
        set_timeout();
    } else {
        std::cout << "[SUCCESS] Pipeline completed.\n";
    }
}

int main() {
    std::cout << "PrismQuanta Task Manager Started.\n";

    auto rules = load_rules();
    auto priorities = load_priorities();

    std::cout << "[INFO] Loaded " << rules.size() << " rules and " << priorities.size() << " priority tasks.\n";

    while (true) {
        std::cout << "\n[STATUS] Checking task loop...\n";

        if (in_timeout()) {
            std::cout << "[WAIT] In timeout period. Skipping run.\n";
        } else {
            run_pipeline();
        }

        std::this_thread::sleep_for(std::chrono::seconds(POLL_INTERVAL_SEC));
    }

    return 0;
}
