set shell := ["nu", "-c"]

# Show available recipes.
default:
    just --list

# Refresh every upstream-managed skill from its source repository.
refresh-upstreams: refresh-stop-slop refresh-llm-wiki

# Copy every upstream-managed skill into skills/.
sync-upstreams: sync-stop-slop sync-llm-wiki

# Refresh upstream sources, then regenerate skills/.
update-upstreams: refresh-upstreams sync-upstreams

# Refresh hardikpandya/stop-slop from GitHub.
refresh-stop-slop:
    just --justfile upstreams/stop-slop/justfile --working-directory upstreams/stop-slop refresh

# Sync hardikpandya/stop-slop into the publishable skills directory.
sync-stop-slop:
    just --justfile upstreams/stop-slop/justfile --working-directory upstreams/stop-slop sync

# Refresh NousResearch/hermes-agent llm-wiki from GitHub.
refresh-llm-wiki:
    just --justfile upstreams/llm-wiki/justfile --working-directory upstreams/llm-wiki refresh

# Sync NousResearch/hermes-agent llm-wiki into the publishable skills directory.
sync-llm-wiki:
    just --justfile upstreams/llm-wiki/justfile --working-directory upstreams/llm-wiki sync
