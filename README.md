# catitw/skills

A collection of [Agent Skills](https://github.com/vercel-labs/skills) — modular
instruction sets that extend coding agents (Claude Code, Codex, Cursor, and 70+
others).

## Skills

| Skill | Description |
| ----- | ----------- |
| [`code-comments`](./skills/code-comments/SKILL.md) | Write high-signal, plain-language code comments for Rust — structure explains the *what*, comments explain the *why*, the *why-not*, the invariants, and the safety reasoning. |

## Install

```bash
# Install all skills (interactive — prompts for agent + scope)
npx skills add catitw/skills

# Install a specific skill
npx skills add catitw/skills -s code-comments

# List available skills without installing
npx skills add catitw/skills --list
```

Install globally (`-g`) or to a specific agent (`-a`), non-interactively:

```bash
npx skills add catitw/skills -s code-comments -a claude-code -g -y
```

See the [skills CLI docs](https://github.com/vercel-labs/skills) for the full
option list and supported agents.
