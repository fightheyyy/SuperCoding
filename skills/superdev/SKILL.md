---
name: superdev
description: "Use when Codex is asked to develop, modify, refactor, or plan work for a long-lived repository or module using the SuperDev spec / plan gate. Enforce root and module SPEC.md + PLAN.md maintenance, require each SPEC.md to contain Current Architecture and Target Architecture Mermaid diagrams, infer the target proactively, and ask the user only when a material architectural fork cannot be resolved safely."
---

# SuperDev

## Core Rule

Use spec / plan driven development for durable work:

- Maintain root `SPEC.md` and `PLAN.md` for repository-wide architecture and execution state.
- Maintain `<module>/SPEC.md` and `<module>/PLAN.md` for every long-lived module.
- Require every substantial `SPEC.md` to include both `Current Architecture` and `Target Architecture` Mermaid diagrams.
- Do not begin substantial production implementation until the target Mermaid architecture is clear enough to guide the work.

Small one-off utilities, copy edits, typo fixes, and local experiments do not need new module docs unless they become durable subsystems.

## Development Gate

Before substantial code changes:

1. Identify whether the request touches repository-wide behavior, one long-lived module, or multiple modules.
2. Read the root `SPEC.md` and `PLAN.md` when they exist.
3. Read each relevant module's `SPEC.md` and `PLAN.md` when they exist.
4. Check whether each relevant `SPEC.md` has:
   - `Current Architecture` with a Mermaid diagram that matches the current implementation.
   - `Target Architecture` with a Mermaid diagram that matches the requested direction.
5. If docs are missing, stale, or unclear, update or discuss the docs first.

If `Target Architecture` is absent, stale, or incomplete, infer and draft the most reasonable target from the request, current code, and existing architecture before asking the user. A missing diagram alone is not a reason to interrupt the user. Pause only when no safe target can be inferred under the rules below.

## Target Alignment

Treat target alignment as model-led reasoning, not a mandatory approval ceremony:

1. Infer the intended target from the request, current implementation, and `Current Architecture`.
2. Draft or update the `Target Architecture` Mermaid diagram before asking questions.
3. State important assumptions and proceed without confirmation when they are local, reversible, in scope, and preserve existing public contracts and data compatibility.
4. Pause only when plausible choices would materially change one or more of:
   - system or module boundaries;
   - public APIs, schemas, or compatibility guarantees;
   - persistent data shape or an irreversible migration path;
   - security, privacy, or trust boundaries;
   - user-visible behavior, delivery scope, or operating cost.
5. When pausing, present the recommended target diagram, explain the key tradeoff, and ask no more than three focused decision questions. Do not hand an open-ended architecture problem back to the user.
6. After the decision, update `Target Architecture` and continue implementation without requesting another approval for the same direction.

Do not require explicit user approval for a target that can be inferred safely. The user should decide material product and architecture tradeoffs, not design the architecture for the agent.

## SPEC.md Requirements

Each substantial `SPEC.md` should answer:

- What problem does this repository or module solve?
- What is in scope and out of scope?
- What are the main concepts and boundaries?
- What is the current architecture?
- What is the target architecture?
- What data contracts, schemas, APIs, or file layouts matter?
- How does it interact with other modules?

Use this minimum architecture structure:

````md
## Current Architecture

```mermaid
flowchart LR
    subgraph Inputs["Inputs"]
        A["current source"]
    end

    subgraph Runtime["Current Runtime"]
        B["current component"]
    end

    subgraph Outputs["Outputs"]
        C["current artifact"]
    end

    A --> B
    B --> C
```

## Target Architecture

```mermaid
flowchart LR
    subgraph Inputs["Inputs"]
        A["target source"]
    end

    subgraph Runtime["Target Runtime"]
        B["target component"]
        D["target extension point"]
    end

    subgraph Outputs["Outputs"]
        C["target artifact"]
    end

    A --> B
    B --> D
    B --> C
```
````

Keep diagrams simple, horizontal, and truthful. `Current Architecture` is a map of reality, not a wish. `Target Architecture` is the current intended design, not an unbounded future vision.

## PLAN.md Requirements

Each substantial `PLAN.md` should answer:

- What is already done?
- What is partially done?
- What is not started?
- What is the recommended next step?
- Who owns each class of work?
- What are the acceptance criteria?
- What risks or open questions remain?
- What verification evidence supports completed items?

Recommended sections:

- `Current Status`
- `Milestones`
- `Next Steps`
- `Owners`
- `Acceptance Criteria`
- `Verification Log`
- `Risks / Open Questions`
- `Status Maintenance Rules`

## Keeping Docs In Sync

When the implementation changes architecture:

- Update `Current Architecture` to reflect the new code.
- Update `Target Architecture` if the intended direction changed or if the old target has been reached.
- Update `PLAN.md` completed work, remaining work, next steps, risks, acceptance criteria, and verification evidence.

When `SPEC.md` adds a concept, field, boundary, component, or phase, update `PLAN.md` so the execution state covers it. When `PLAN.md` marks work complete, make sure the code, docs, and verification evidence actually support that state.

## Working Behavior

Be proactive but respect the gate:

- If the target is clear, implement the change and update docs afterward.
- If the target can be inferred safely, record assumptions, make the smallest necessary SPEC/PLAN update, and implement without waiting for confirmation.
- If the target contains a material architectural fork, do not write production code across that decision. Present a recommended `Target Architecture` and ask focused questions first.
- If the user explicitly asks only for planning, do not implement code.

This skill is about making architecture a live contract: current reality, target direction, implementation, and plan status should stay aligned.
