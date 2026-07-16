# SuperCoding Plan

## Current Status

- Parent SuperGoal contract is active.
- The three upstream repositories, installed copies, and visual prototype have been inventoried.
- The three authoritative skill packages have been assembled under `skills/` without semantic rewrites.
- The installer, validator, English/Chinese READMEs, SVG hero, and 1280 x 640 PNG social preview are complete.
- GitHub authentication is active for `fightheyyy`; `fightheyyy/SuperCoding` does not yet exist.

## Milestones

- Done: identify authoritative source commit for each skill.
- Done: define single-repository boundaries and non-goals.
- Done: assemble the three self-contained skill packages.
- Done: create the GitHub hero and social-preview assets.
- Done: write English and Chinese README files plus the installer.
- Done: validate isolated installation and skill metadata.
- Pending: create and publish `fightheyyy/SuperCoding` with description and topics.

## Next Steps

1. Run an independent final repository audit.
2. Commit the verified local repository.
3. Create and push `fightheyyy/SuperCoding`.
4. Apply description and topics, then run post-publish installation validation.

## Owners

- Parent Codex agent owns architecture, integration, publication, and final acceptance.
- Read-only child goals supplied repository inventory, packaging validation, and GitHub exposure guidance.
- The user owns future product positioning and any decision to archive the legacy repositories.

## Acceptance Criteria

- One public `fightheyyy/SuperCoding` repository contains three independently installable skills.
- The first README viewport shows the targeting ring, construction lattice, scanning frame, and central ASCII `SuperCoding` identity.
- Installation includes the SuperReview repair-agent registration step.
- English and Chinese READMEs explain the engineering loop, installation, usage, boundaries, provenance, and license.
- Repository description and topics use accurate, high-intent GitHub search terms without keyword stuffing.
- Local and post-publish installation smoke tests pass.

## Verification Log

- Passed: `gh auth status` reports active account `fightheyyy`.
- Passed: `gh repo view fightheyyy/SuperCoding` confirms the target repository does not yet exist.
- Passed: child inventory confirmed authoritative source paths and commits.
- Passed: child packaging audit validated all three source skill folders.
- Passed: imported skill directories are byte-identical to their pinned authoritative sources.
- Passed: official `quick_validate.py` returned `Skill is valid!` for all three skill packages.
- Passed: YAML and TOML metadata parse successfully; all required relative resources exist.
- Passed: `scripts/install.sh` completed an isolated install and registered the SuperReview repair agent.
- Passed: repeated installation stopped safely; `--force` created timestamped backups before updating.
- Passed: repeated `--force` runs within the same second created unique, non-nested backups.
- Passed: `scripts/validate.sh` structural and official-validator modes.
- Passed: `docs/social-preview.png` is 1280 x 640 and 292 KiB; the hero was visually checked at 1280 x 640 and 640 x 320.

## Dispatch Ledger

| Child goal | Scope | Goal lifecycle | Model fallback | Parent decision |
| --- | --- | --- | --- | --- |
| `repo_inventory2` | Read-only source, remote, and version inventory | Created and completed | Spawn API could not set requested model/effort; inherited runtime | Accepted with parent remote and branch verification |
| `skill_packaging2` | Read-only package resources and validation audit | Created and completed | Spawn API could not set requested model/effort; inherited runtime | Accepted with parent byte comparison and official validation |
| `github_exposure2` | Read-only README, cover, description, and Topics blueprint | Created and completed | Spawn API could not set requested model/effort; inherited runtime | Accepted with parent asset rendering and README implementation |
| `final_repo_audit` | Read-only release audit of packaging, install safety, docs, and cover | Created and completed | Spawn API could not set requested model/effort; inherited runtime | Accepted SR-001; fixed backup-name collisions and reran the regression |

## Risks / Open Questions

- SuperGoal's selected source is a published feature branch rather than its legacy `main`; the exact commit is pinned in `SPEC.md`.
- The legacy repositories remain public and may diverge unless they are archived or redirected in a later task.
- GitHub Social Preview upload may require a repository settings action after the PNG is published.

## Status Maintenance Rules

- Update the current architecture after the consolidated repository exists.
- Record only effective validation evidence, not raw command transcripts.
- Do not mark publication complete until the remote repository and install paths are verified from GitHub.
