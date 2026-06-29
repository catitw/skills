# catitw/skills

A collection of [Agent Skills](https://github.com/vercel-labs/skills) — modular
instruction sets that extend coding agents (Claude Code, Codex, Cursor, and 70+
others).

## Skills

| Skill | Description |
| ----- | ----------- |
| [`code-comments`](./skills/code-comments/SKILL.md) | Write high-signal, plain-language code comments for Rust — structure explains the *what*, comments explain the *why*, the *why-not*, the invariants, and the safety reasoning. |
| [`stop-slop`](./skills/stop-slop/SKILL.md) | Remove predictable AI writing patterns from prose, including filler phrases, formulaic structures, passive voice, vague declaratives, and other common AI tells. |

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

## Upstream sync

Some skills are managed from upstream repositories under `upstreams/` and copied
into `skills/` as real files for reliable CLI discovery and GitHub archive
support. Each upstream-managed skill is organized as a small sync unit:

```text
upstreams/<skill>/
├── justfile   # refresh/sync recipes for this upstream
└── source/    # complete upstream repository tree
```

The publishable `skills/<skill>/` directory is generated from `source/`; it is
not a symlink. The sync recipes use [`just`](https://github.com/casey/just),
[Nushell](https://www.nushell.sh/), `git`, and `rsync`.

```bash
# Copy upstream-managed skills into skills/
just sync-upstreams

# Pull upstream repositories, then copy into skills/
just update-upstreams
```

If GitHub access needs a proxy, set it for the command instead of committing it
to the repo:

```bash
https_proxy=http://127.0.0.1:7897 just update-upstreams
```

See the [skills CLI docs](https://github.com/vercel-labs/skills) for the full
option list and supported agents.
