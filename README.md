# PrismQuanta

**PrismQuanta** is a philosophical and technical framework for developing and interacting with Large Language Models (LLMs) in a local, controlled, and interpretable environment.

> *“We didn’t just build a system. We raised a mind.”*

---

## 🌌 What is PrismQuanta?

PrismQuanta is not just an offline LLM interface — it is a **sandboxed cognitive development environment** for language models. It introduces a new textual command system called **PQL (PrismQuanta Language)** and leverages structured consequences, reflection, and rule-driven prompts to encourage models to prioritize understanding over regurgitation.

---


## 🧠 Core Concepts

### 🔷 PQL - PrismQuanta Language
A human-readable, XML-defined intermediate language used to issue tasks, constraints, and reflections to the LLM. Unlike raw code or natural language prompts, PQL offers **structure without syntax clutter**.

### 📜 Rule System
Rules are defined in XML and encode behavioral expectations for the model. Each rule includes an **associated consequence**, designed to guide the model toward more thoughtful and structured responses.

### 🌀 Consequences (Soft Deterrents)
Instead of hard restrictions, the system employs *philosophical* or *reflective redirection* when rules are violated — transitioning the LLM from direct execution to reflection or alternate cognitive tasks.

### 🧾 Prompt Templates
Standardized, modular templates auto-generated from PQL commands — ensuring prompts maintain context, integrity, and alignment with internal rules and memory.

### 📁 Local Autonomy
PrismQuanta runs entirely **offline**. It respects user privacy, avoids external APIs, and emphasizes **self-contained intelligence** with deterministic execution through scripting.

---

## 📂 Project Structure

```plaintext
PrismQuanta/
├── scripts/
│ ├── run_llm.sh # Launch script for the offline model
│ ├── enforce_rules.sh # Applies rules and consequences before response
│ ├── generate_prompt.sh # Parses PQL and generates prompt
│ ├── reflect_and_retry.sh # Handles recursive reflection loops
│
├── rules/
│ └── rules.xml # XML-based rule and consequence definitions
│
├── pql/
│ ├── schema.xsd # Schema definition for PQL
│ └── sample_commands.pql # Sample task flow in PQL
│
├── logs/
│ └── session.log # Execution and reflection logs
│
├── model/
│ └── ggml-model.bin # Local LLM model file (e.g., LLaMA, Mistral)
│
└── README.md # Project documentation
```

---

## ⚙️ Getting Started

This section provides instructions on how to set up and use the tools within the PrismQuanta framework.

### Dependencies

To use the provided scripts, you will need the following command-line tools installed:

*   **Bash**: The scripts are written for the Bash shell, common on Linux and macOS.
*   **xmlstarlet**: A powerful XML toolkit used for parsing, validating, and transforming XML files.

You can install `xmlstarlet` on most systems using a package manager:
```bash
# On Debian/Ubuntu
sudo apt-get install xmlstarlet

# On macOS (using Homebrew)
brew install xmlstarlet

# On Red Hat/CentOS
sudo yum install xmlstarlet
```

### Using the Parser

The `parse_pql.sh` script is your primary interface for interacting with `tasks.xml`. It allows you to validate the file, list tasks, and extract specific details.

Navigate to the `scripts` directory to run these commands:

```bash
# 1. Validate the tasks.xml file against its schema
./parse_pql.sh validate

# 2. List all available task IDs and their descriptions
./parse_pql.sh list

# 3. Get the specific commands for a task
./parse_pql.sh commands task-001
```

---

## 🤝 Contributing

Contributions are highly encouraged! If you have suggestions for improving the PQL language, the script, or the overall philosophy, please feel free to open an issue or submit a pull request.

## 📜 License

This project is licensed under the MIT License. See the `LICENSE` file for more details.
