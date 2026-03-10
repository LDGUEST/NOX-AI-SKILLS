# NOX Skill Evaluations

Evaluation test cases for NOX skills, following the [Anthropic Agent Skills best practices](https://platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices#build-evaluations-first).

## Format

Each `.json` file defines one test case:

```json
{
  "skills": ["skill-name"],
  "query": "Natural language prompt that should (or should not) trigger the skill",
  "files": ["optional/file/paths"],
  "expected_behavior": [
    "Specific behavior Claude should exhibit",
    "Another expected behavior"
  ],
  "should_trigger": true
}
```

- `should_trigger: true` — this prompt SHOULD activate the skill
- `should_trigger: false` — this prompt should NOT activate the skill (tests false-positive resistance)

## Running Evaluations

There is no built-in runner. Use these manually by loading the skill and testing the query:

```bash
# Load a skill and test a query
claude --skill-dir ~/.claude/commands/nox "$(cat evaluations/commit-basic.json | jq -r .query)"
```

## Coverage Status

| Skill | Should-trigger | Should-not-trigger | Total |
|-------|---------------|-------------------|-------|
| commit | 2 | 1 | 3 |
| review | 2 | 1 | 3 |
| architect | 2 | 1 | 3 |
| tdd | 2 | 1 | 3 |
| diagnose | 2 | 1 | 3 |
| security | 2 | 1 | 3 |
| deploy | 2 | 1 | 3 |
| refactor | 2 | 1 | 3 |
| scan | 2 | 1 | 3 |
| audit | 2 | 1 | 3 |
| *remaining 24* | — | — | 0 |

## Contributing Evaluations

For each skill, create at minimum:
- 2 should-trigger cases (obvious trigger, subtle trigger)
- 1 should-not-trigger case (similar domain but different intent)

File naming: `{skill-name}-{case-description}.json`
