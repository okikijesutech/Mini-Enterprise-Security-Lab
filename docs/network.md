## Target Network Architecture

The complete lab will eventually use:

| Network                 | CIDR            | Purpose                 |
| ----------------------- | --------------- | ----------------------- |
| Enterprise              | `10.10.10.0/24` | Enterprise workloads    |
| Security / Attacker     | `10.10.20.0/24` | Security testing        |
| Monitoring / Management | `10.10.30.0/24` | Monitoring and scanning |

## Phase 1 Docker Network

Phase 1 establishes the initial Docker networking foundation.

The Docker network created during Phase 1 is an implementation foundation
and should not be interpreted as the final enterprise network segmentation.

Detailed routing, segmentation and security-zone enforcement will be
implemented in later phases.
