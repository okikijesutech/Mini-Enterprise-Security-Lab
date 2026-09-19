# Docker Foundation

## Objective

Establish the containerized foundation of the Mini Enterprise Security Lab.

## Enviroment

- Host OS: Windows
- Container platform: Docker Desktop
- Orchestration: Docker Compose
- Container runtime: Docker
- Network driver: bridge

## Containers

| Container  | Image        | Purpose            |
| ---------- | ------------ | ------------------ |
| lab-linux  | Ubuntu 24.04 | Linux lab node     |
| lab-client | Alpine 3.20  | Lightweight client |

## Network

Network: mel-enterprise

## Storage

Volume: mel-lab-data

- [x] Docker installed
- [ ] Docker Compose working
- [ ] Containers start successfully
- [ ] Containers communicate
- [ ] Docker network verified
- [ ] Volume Persistence verified
- [ ] Compose configuration validated

## Evidence

Screenshots are in the screenshots/phase-1/
