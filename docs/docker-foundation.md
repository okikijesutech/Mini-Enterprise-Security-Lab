# Docker Foundation

## Purpose

Phase 1 establishes the Docker-based foundation for the Mini Enterprise Security Lab.

The goal is to provide lightweight, isolated workloads that can later support
the enterprise, attacker, and monitoring portions of the lab.

## Objective

Establish the containerized foundation of the Mini Enterprise Security Lab.

## Objectives

- Verify Docker installation
- Verify Docker Compose
- Create the initial Compose configuration
- Create isolated lab networking
- Deploy basic containers
- Verify container connectivity
- Validate Docker network configuration
- Capture evidence

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

## Docker Validation

### Docker Version

```bash
docker --version
```

### Docker Compose version

```bash
docker compose version
```

### Docker Information

```bash
docker info
```

### Compose Configuration

```bash
docker compose config
```

### Deployment

```bash
docker compose up -d
```

### Check running container

```bash
docker compose ps
```

### Network Validation

```bash
docker network ls
docker network inspect mel-enterprise
```

### Container connectivity

```bash
docker exec -it <container> ping <other-container>
```

## Evidence

Screenshots are in the screenshots/phase-1/
