set shell := ["nu", "-c"]

# Show available recipes.
default:
    just --list

# Refresh every upstream-managed skill from its source repository.
refresh-upstreams: refresh-stop-slop

# Copy every upstream-managed skill into skills/.
sync-upstreams: sync-stop-slop

# Refresh upstream sources, then regenerate skills/.
update-upstreams: refresh-upstreams sync-upstreams

# Refresh hardikpandya/stop-slop from GitHub.
refresh-stop-slop:
    just --justfile upstreams/stop-slop/justfile --working-directory upstreams/stop-slop refresh

# Sync hardikpandya/stop-slop into the publishable skills directory.
sync-stop-slop:
    just --justfile upstreams/stop-slop/justfile --working-directory upstreams/stop-slop sync
