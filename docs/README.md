# PrismQuanta

**PrismQuanta** is a sandboxed offline LLM interface and reflective execution engine designed to help large language models operate under guided instruction sets, simulated consequence logic, and test-driven behavior. It is written primarily in Bash and uses XML-based rule and prompt definitions.

## 🔍 Project Goals

- Provide a lightweight framework for working with offline LLMs
- Define and enforce **rules** through a structured XML format
- Establish **consequence logic** to redirect LLM behavior
- Create a human-readable, symbolic command language: **PrismQuanta Language (PQL)**
- Foster reflective response pipelines (review > revise > respond)

---

## 📁 Repository Structure

```
prismquanta/
├── pql/                    # PQL command and schema definitions
│   ├── pql-schema.xml
│   └── examples/
├── rules/                  # Rule and consequence system
│   └── rulebook.xml
├── prompts/                # Prompt templates and generators
├── logs/                   # Reflective logs and audit trails
├── scripts/                # Bash utilities
│   ├── task-runner.sh
│   ├── consequence-engine.sh
│   └── template-parser.sh
├── tests/                  # Unit tests for components
│   └── test-runner.sh
└── README.md               # Project documentation
```

---

## 📐 PrismQuanta Language (PQL)

PQL is a simplified, structured text-based command language used to guide LLM behavior.

### Example PQL Command:

```
DEFINE TASK "Summarize input text"
CONTEXT "Scientific article on quantum coherence"
REQUIRE REFLECTION
EXPECT "Bullet list of findings"
```

See `pql/pql-schema.xml` for a full specification.

---

## 🚦 Rules and Consequences

Rules are defined in `rules/rulebook.xml`:

```xml
<rules>
  <rule id="001">
    <description>No deletion of test files</description>
    <consequence>Reflective task substitution</consequence>
  </rule>
</rules>
```

The engine will analyze responses for violations and re-route prompt generation accordingly.

---

## 🧪 Testing

Run all tests:

```bash
bash tests/test-runner.sh
```

This includes:

- Rule schema validation
- Prompt generation correctness
- Reflection loop integrity

---

## 🧭 Roadmap

### Phase 1 — Core Engine (DONE / IN PROGRESS)

-

### Phase 2 — Testing and Validation

-

### Phase 3 — Reflective Execution

-

### Phase 4 — Interface

-

---

## 🤝 Contributing

This is a research-grade exploratory project. Contributions, suggestions, and forks are welcome. See `CONTRIBUTING.md` for guidelines (coming soon).

---

## 🧠 Author

**Dr. Tamaro Green**\
GitHub: [@drtamarojgreen](https://github.com/drtamarojgreen)

