# Agent Notes

When working in this repo, preserve it as the source of truth for the Ubuntu desktop setup.

If the user asks for a system/app/config change on this machine, update the repo in the same turn whenever practical:

1. Make the requested system change.
2. Run `./scripts/snapshot-ubuntu.sh` from `~/dotfiles`.
3. Update `README.md` or `docs/system-overview.md` when the intent, workflow, or caveats changed.
4. Review `git diff` for secrets or accidental state before committing.

Do not add browser profile databases, SSH keys, tokens, CopyQ clipboard history, app caches, lock files, virtual environments, downloaded binaries, or project repositories.

Hardware-sensitive changes, especially NVIDIA/CUDA, VPN clients, firmware, battery charge thresholds, and dual-boot paths, should stay clearly documented and optional.
