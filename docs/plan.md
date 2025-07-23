# PrismQuanta Implementation Plan

This plan organizes tasks by directory and function, enabling modular implementation by autonomous agents. Each section includes the objective, implementation steps, and expected outputs.

---

## config/

### priorities.txt
- **Objective**: Define task priorities for LLM scheduling.
- **Tasks**:
  - Parse this file before prompt assignment.
  - Integrate priority selection logic in `interface/prismquanta_interface.cpp`.
- **Output**: Map<string, int> of tasks with priority levels.

### rules.txt
- **Objective**: Define enforcement logic for rule violations.
- **Tasks**:
  - Load and parse in `interface/prismquanta_interface.cpp`.
  - Match against logs or prompt outputs.
  - Trigger enforcement via `scripts/rule_enforcer.sh`.
- **Output**: Rule list used during consequence evaluation.

---

## docs/

### README.md
- **Objective**: Provide project overview and documentation anchor.
- **Tasks**:
  - Validate that all scripts, schemas, and workflows referenced are current.
  - Generate/update with planning and interface changes.
- **Output**: Human-readable documentation, bot validation target.

---

## interface/

### prismquanta_interface.cpp
- **Objective**: C++ scheduler and command interface for Bash-driven LLM workflows.
- **Tasks**:
  - Load rules and priorities.
  - Monitor timeout marker.
  - Launch pipeline via `run_task.sh`.
  - Log all decisions to `data/logs/interface.log`.
- **Output**: Logged execution events and dynamic prompt control.

---

## memory/

### development_lessons.txt
- **Objective**: Retain historical insights from development.
- **Tasks**:
  - Include references in `plan_code_tasks.sh` or `strategize_project.sh`.
  - Use for reflective validation loop.
- **Output**: Auxiliary knowledge injected into planning pipeline.

### test.txt
- **Objective**: Placeholder for experimental memory input/output.
- **Tasks**:
  - Use during pipeline testing or input simulation.
  - Replace with structured content in long-term memory planning.
- **Output**: Dynamic memory segment during experimentation.

---

## prompts/

### input_prompt.txt
- **Objective**: Active prompt loaded by LLM pipeline.
- **Tasks**:
  - Replace dynamically based on priority mapping.
  - Use by `run_task.sh` and `interface/prismquanta_interface.cpp`.
- **Output**: Prompt consumed by core execution engine.

---

## rules/

### pql.xsd
- **Objective**: Schema for validating PQL commands.
- **Tasks**:
  - Run via `parse_pql.sh` or `validation_loop.sh`.
  - Trigger enforcement if schema invalid.
- **Output**: Validation report on `pql_sample.xml`.

### pql_sample.xml
- **Objective**: Example command definition for testing.
- **Tasks**:
  - Test parsing and consequence triggering.
  - Include in unit tests.
- **Output**: Parsed task structure for pipeline initiation.

### rules.xsd
- **Objective**: Schema for validating structured rule definitions.
- **Tasks**:
  - Validate `rules.txt` structure if upgraded to XML.
  - Used by `validation_loop.sh`.
- **Output**: Rule format integrity report.

---

## scripts/

### define_requirements.sh
- **Objective**: Generate requirements.md from discussion or memory input.
- **Tasks**:
  - Pull latest input from memory.
  - Save to `memory/requirements.md`.
- **Output**: Fresh planning anchor for `plan_code_tasks.sh`.

### enhanced_task_manager.sh
- **Objective**: Advanced runner for scheduled tasks.
- **Tasks**:
  - Integrate priority logic.
  - Trigger prompts, evaluate results, log outcomes.
- **Output**: Logged task execution status.

### memory_review.sh
- **Objective**: Reflect on memory contents for strategy updates.
- **Tasks**:
  - Extract insights from `memory/*.txt`.
  - Feed into `strategize_project.sh`.
- **Output**: Summary of actionable development context.

### parse_pql.sh
- **Objective**: Validate and interpret PQL commands.
- **Tasks**:
  - Use `pql.xsd` to validate `pql_sample.xml`.
  - Parse tasks and route to engine.
- **Output**: Confirmed PQL command set.

### plan_code_tasks.sh
- **Objective**: Convert requirements.md into executable task plan.
- **Tasks**:
  - Read `memory/requirements.md`.
  - Use LLM via `llm_infer.sh` to generate prioritized tasks.
  - Flag ambiguous tasks and revise.
- **Output**: `memory/task_list_final.txt` and optional revisions.

### pql_test_and_punish.sh
- **Objective**: Check task outputs against rulebook and apply consequences.
- **Tasks**:
  - Run post-task validations.
  - Call `rule_enforcer.sh` if violations detected.
- **Output**: Log of rule enforcement decisions.

### rule_enforcer.sh
- **Objective**: Handle violations by redirecting task flow.
- **Tasks**:
  - Switch active prompts based on rule triggers.
  - Log action and violation type.
- **Output**: Updated `prompts/input_prompt.txt`.

### run_planner.sh
- **Objective**: End-to-end planner invoker.
- **Tasks**:
  - Run requirement parser, planner, validator, and scheduler.
- **Output**: Comprehensive updated task list and revised prompts.

### run_task.sh
- **Objective**: Main pipeline for executing task based on prompt.
- **Tasks**:
  - Read `input_prompt.txt`.
  - Feed prompt to engine.
  - Log result and analyze.
- **Output**: Task result stored or validated.

### self_chat_loop.sh
- **Objective**: Simulate looped reflective LLM dialog.
- **Tasks**:
  - Use chat-style memory for recursion.
  - Optimize via prompt transformation.
- **Output**: Output transcript saved to logs.

### strategize_project.sh
- **Objective**: Generate strategy from existing state.
- **Tasks**:
  - Analyze development lessons and active tasks.
  - Suggest improvement areas.
- **Output**: Strategy summary and updates to plan.

### task_manager.sh
- **Objective**: Task execution layer with routing logic.
- **Tasks**:
  - Dispatch tasks from final plan.
  - Monitor result status.
- **Output**: Execution metrics per task.

### validation_loop.sh
- **Objective**: Continuous validation of prompt, task, and memory artifacts.
- **Tasks**:
  - Check prompt structure, XML validity, and memory sync.
- **Output**: Diagnostic reports on engine readiness.

---

## Top-Level Artifacts

### .timeout
- **Objective**: Prevent retry after failed runs.
- **Tasks**:
  - Modified by `interface/prismquanta_interface.cpp` after failure.
- **Output**: Polling suspension signal.

### main
- **Objective**: Executable entry point or stub binary.
- **Tasks**:
  - Validate link to `interface/prismquanta_interface.cpp`.
- **Output**: Startup trigger for scheduling engine.

### prismquanta_interface
- **Objective**: Compiled binary for polling-based engine.
- **Tasks**:
  - Schedule pipeline runs via prompts and timeout logic.
- **Output**: Console logs, rule enforcement decisions.

### README.md
- **Objective**: Root-level documentation.
- **Tasks**:
  - Synchronize with `docs/README.md`.
- **Output**: User-facing overview.

