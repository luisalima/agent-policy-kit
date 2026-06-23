---
name: sandbox
description: Use before installing dependencies or running untrusted or third-party code to confirm execution is isolated from the host, and when packaging runnable work so the user can run it without installing the toolchain on their own machine. Detect the environment, fall back to a container when the host is exposed, and stop and ask when neither is available.
---

# Sandbox

Untrusted code runs with your full privileges: dependency installs and their
lifecycle scripts, freshly fetched or cloned repos, build steps, and anything you
did not write and read. Before running it, confirm the host is protected.

## When to use

- Before `install`-class commands (npm, pip, cargo, go, gem, composer, etc.) or
  before running third-party or freshly fetched code.
- When handing over runnable work, to provide a container run path so the user
  need not install the toolchain on their own machine.

Do not ritualize this for trusted, read-only, or first-party commands you wrote
and reviewed. State why isolation is relevant, then proceed.

## Detect the environment (fail safe)

No single signal is reliable, so check several and treat any positive as a hint,
not proof:

- Files: `/.dockerenv`, `/run/.containerenv`.
- cgroups: `docker`, `lxc`, `kubepods`, or `containerd` in `/proc/1/cgroup` or
  `/proc/self/cgroup`.
- Provider env: `IS_SANDBOX`, `SANDBOX_VM_ID`, or the running agent's documented
  sandbox markers.

A container is not automatically isolated: a bind-mounted host filesystem,
`--privileged`, or a mounted `docker.sock` breaks the boundary. When signals
conflict or isolation is uncertain, assume the host is exposed — the unsafe
failure is a false "I'm safe."

## Decide how to run

1. Confirmed isolated sandbox: run normally inside it.
2. Host exposed, a container runtime is available: run the untrusted step in a
   throwaway container with no host mounts and least privilege; keep source on a
   working copy, not the host tree.
3. Host exposed, no runtime available: stop and ask. Offer running on the host
   with explicit consent, or setting up a VM or remote sandbox. Never silently
   run untrusted code on the host because isolation was inconvenient.

## Hand over a container run path

When delivering runnable work, prefer a reproducible container path so the user
runs it without polluting their host — even when you were sandboxed:

- Add or reuse a `Dockerfile` (and a compose file if the project is
  multi-service) that builds and runs the project.
- Pin the base image and document the exact build and run commands.
- Skip this where it does not fit — a published library, a static docs site, or
  a repo with an established non-container run path. Note why instead of forcing
  it.
