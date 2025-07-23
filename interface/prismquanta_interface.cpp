// prismquanta_interface.cpp
// PrismQuanta - Offline Autonomous LLM Scheduler with Logging
// This C++ application acts as a high-level task scheduler for the PrismQuanta framework.
// It operates in a continuous loop, polling for tasks, checking for timeouts, and
// executing the LLM pipeline via shell scripts.

#include <iostream>
#include <fstream>
#include <filesystem>
#include <chrono>
#include <thread>
#include <cstdlib> // For std::system
#include <ctime>   // For std::ctime
#include <map>
#include <vector>
#include <string> // For std::string

namespace fs = std::filesystem;

// --- Configuration ---
// All paths are relative to the project root directory where the executable is run.

// Log file for this interface application.
const std::string LOG_FILE = "logs/interface.log";
// Default prompt file to use if no other is specified.
// NOTE: The pipeline is designed to use dynamically generated prompts via `generate_prompt.sh`.
const std::string PROMPT_FILE = "prompts/input_prompt.txt";
// A marker file to indicate the system is in a timeout period after a failure. Placed in logs/ to keep the root clean.
const std::string TIMEOUT_MARKER = "logs/.timeout";
// The XML file containing behavioral rules for the LLM.
// NOTE: The current load_rules() function reads plain text and must be updated to parse XML.
const std::string RULES_FILE = "rules/rules.xml";
// The file containing task priorities.
// NOTE: The current priorities.txt is a roadmap; the load_priorities() function expects a 'task priority' format.
const std::string PRIORITY_FILE = "priorities.txt";
// The interval in seconds for the main polling loop.
const int POLL_INTERVAL_SEC = 60;
// The duration in seconds for the timeout period after a script failure.
const int TIMEOUT_DURATION_SEC = 7200; // 2 hours

// --- Utility Functions ---

/**
 * @brief Writes a log entry to the LOG_FILE with a timestamp.
 *        Creates the log directory if it doesn't exist.
 * @param entry The string message to log.
 */
void write_log(const std::string& entry) {
    // Ensure the log directory exists before attempting to write.
    fs::path log_path(LOG_FILE);
    if (!fs::exists(log_path.parent_path())) {
        fs::create_directories(log_path.parent_path());
    }

    std::ofstream log(LOG_FILE, std::ios_base::app);
    auto now = std::chrono::system_clock::to_time_t(std::chrono::system_clock::now());
    // std::ctime adds a newline, so we remove it to keep the format clean.
    std::string time_str = std::ctime(&now);
    time_str.pop_back();
    log << "[" << time_str << "] " << entry << "\n";
}

/**
 * @brief Loads task priorities from the PRIORITY_FILE.
 * @note This function's logic assumes a 'task_name priority_level' format in the file,
 *       which does not match the current content of priorities.txt. This needs revision
 *       to align with the project's goals for scheduling.
 * @return A map of task names to their integer priority.
 */
std::map<std::string, int> load_priorities() {
    write_log("Loading priorities from " + PRIORITY_FILE + "...");
    std::map<std::string, int> priorities;
    std::ifstream in(PRIORITY_FILE);
    if (!in) {
        write_log("ERROR: Could not open priority file: " + PRIORITY_FILE);
        return priorities;
    }
    std::string task;
    int priority;
    // WARNING: This parsing logic is incompatible with the current `priorities.txt` format.
    while (in >> task >> priority) {
        priorities[task] = priority;
    }
    write_log("Loaded " + std::to_string(priorities.size()) + " priority items.");
    return priorities;
}

/**
 * @brief Loads behavioral rules from the RULES_FILE.
 * @note This function reads a plain text file line-by-line. It must be updated
 *       to parse the XML structure of rules.xml using a proper XML library.
 * @return A vector of strings, where each string is a line from the file.
 */
std::vector<std::string> load_rules() {
    write_log("Loading rules from " + RULES_FILE + "...");
    std::vector<std::string> rules;
    std::ifstream in(RULES_FILE);
    if (!in) {
        write_log("ERROR: Could not open rules file: " + RULES_FILE);
        return rules;
    }
    std::string line;
    // WARNING: This parsing logic is incorrect for an XML file.
    while (std::getline(in, line)) {
        rules.push_back(line);
    }
    write_log("Loaded " + std::to_string(rules.size()) + " rules.");
    return rules;
}

/**
 * @brief Checks if the system is currently in a timeout period.
 *        A timeout is active if the TIMEOUT_MARKER file exists and is recent.
 * @return True if in timeout, false otherwise.
 */
bool in_timeout() {
    if (!fs::exists(TIMEOUT_MARKER)) return false;

    auto last_modified = fs::last_write_time(TIMEOUT_MARKER);
    auto now = fs::file_time_type::clock::now();
    auto diff = std::chrono::duration_cast<std::chrono::seconds>(now - last_modified).count();

    bool timed_out = diff < TIMEOUT_DURATION_SEC;
    if (timed_out) {
        write_log("Timeout marker active. Skipping task execution.");
    } else {
        // If timeout has expired, remove the marker file.
        fs::remove(TIMEOUT_MARKER);
        write_log("Timeout expired. Removing marker file.");
    }
    return timed_out;
}

/**
 * @brief Creates or updates the timeout marker file to the current time.
 */
void set_timeout() {
    std::ofstream out(TIMEOUT_MARKER);
    out << "timeout";
    write_log("Timeout marker updated.");
}

/**
 * @brief Executes the main LLM pipeline script.
 * @note This is a placeholder implementation. The system call should be updated to
 *       dynamically select a task and chain the `generate_prompt.sh` and `run_llm.sh`
 *       scripts as per the project plan.
 */
void run_pipeline() {
    write_log("Running pipeline script...");
    // TODO: Replace this with a dynamic command.
    // Example of a future, more dynamic command:
    // std::string command = "echo 'Document content...' | ./scripts/generate_prompt.sh summarize-prismquanta | ./scripts/run_llm.sh";
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
