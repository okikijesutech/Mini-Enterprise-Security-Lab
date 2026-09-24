# Phase 2 — Linux Server Hardening

## Objective

Deploy LINUX01, harden it against a documented baseline, and produce
before/after evidence for every control applied.

## Build decision: VM, not container

LINUX01 was built as a standalone VirtualBox VM (Ubuntu Server 26.04.1 LTS)
rather than a container. A container can't meaningfully exercise host-level
controls — auditd depends on the kernel, and a container running on the
Docker host's shared kernel doesn't give a realistic hardening target.
A VM gives a real kernel, real systemd, and a real attack surface to
harden, at the cost of the host-only network living outside the Docker
bridges used elsewhere in the lab (reconciled in Phase 5).

## Network

- Adapter 1 (NAT, `enp0s3`): outbound internet access for `apt`, DHCP-assigned
- Adapter 2 (host-only, `enp0s8`): static `10.10.10.30/24`, the lab-facing interface

## SSH hardening

- Key-based authentication only (ed25519); password authentication disabled
- Root login disabled (`PermitRootLogin no`) — verified with a direct
  `ssh root@10.10.10.30` attempt, which is refused
- `AllowUsers` restricted to the single admin account
- `MaxAuthTries 3`, `X11Forwarding no`, `KbdInteractiveAuthentication no`
- Config lives in a drop-in (`/etc/ssh/sshd_config.d/01-hardening.conf`)
  rather than editing `sshd_config` directly, so it overrides Ubuntu's
  cloud-init default (`50-cloud-init.conf`) explicitly and visibly

Evidence: `sshd -T` output before/after, and a captured attempt at
password login being refused with `Permission denied (publickey)`.

## Web server (Nginx)

- `server_tokens off` — confirmed via `curl -I`, version string removed
  from both normal responses and 404 error pages
- HTTPS added on 443 with a self-signed certificate, `TLSv1.2`/`TLSv1.3`
  only (verified with an `ssl-enum-ciphers` Nmap scan — no legacy
  protocol versions offered)
- Port 80 changed from serving content to a 301 redirect to HTTPS

**Reasoning:** 80/tcp and 443/tcp were opened because they represent a
real business-facing web service — most production servers expose HTTP
and HTTPS, so hardening a live web stack (TLS config, header hygiene,
redirect behavior) is more representative than leaving the server
non-serving. 22/tcp stays open, restricted to the single admin source
address, because remote administration is a genuine operational need.
Every other port is default-dropped: an attacker fingerprinting open
ports is often the first step in reconnaissance, and unnecessary
exposure gives that reconnaissance more to work with for no operational
benefit.

## Firewall (nftables)

- `inet` table (IPv4 + IPv6 in one ruleset) rather than iptables/ip6tables
  separately, closing a gap where IPv6 would otherwise be unfiltered
- Default policy: drop, inbound
- Allowed: established/related traffic, loopback, ICMPv6 (required for
  IPv6 neighbor discovery — dropping it would break IPv6 entirely),
  DHCP replies on the NAT interface, SSH from the admin address only,
  and 80/443 from any source on the lab interface
- **DROP over REJECT**: chosen so unsolicited traffic is silently
  dropped rather than actively refused. Verified in the after-scan —
  the same ports that were "closed" (TCP RST) at baseline are now
  reported "filtered" (no response) — matching default-deny security
  posture, at the cost of a full-port scan taking substantially longer
  (18 seconds baseline vs. ~165 seconds after)
- Persisted via `/etc/nftables.conf` + `systemctl enable nftables`,
  confirmed to reload correctly after a reboot

**Known gap:** every test — SSH, HTTPS, the port-22 restriction — was
run from the one address the firewall allows (`10.10.10.1`, the admin
host). The rule was never tested from a _disallowed_ source, so the
source-IP restriction on port 22 is unverified in practice. This is
flagged for testing once Kali is available on a different network zone.

## auditd

Watch rules (`-p wa`, write + attribute changes) on:

- `/etc/passwd`, `/etc/shadow`, `/etc/sudoers`, `/etc/ssh/sshd_config`

Tested by creating and deleting a scratch user account and confirming
the events appear via `ausearch -k passwd_changes -i`, including the
syscalls, the `CREATE`/`DELETE` path events, and the `CONFIG_CHANGE`
entry logging the rule's own addition.

**Note:** `auditctl -l` reports "Old style watch rules are slower" —
`-w` rules use a less efficient kernel path than newer path-based
rules. They function correctly (confirmed by the test event above) but
this is a known limitation worth revisiting if performance becomes
relevant.

## Validation script

`scripts/bash/security-check.sh` checks real system state rather than
surface signals:

- Listening TCP ports match exactly 22/80/443 — filtered to addresses
  bound to `0.0.0.0`/`[::]` (network-reachable) so loopback-only
  services like the systemd-resolved DNS stub don't produce false
  positives
- `sshd -T` values for password auth and root login
- nftables default policy is `drop`
- auditd is running and all four watch rules are loaded

Exits non-zero on any failure so it's CI-reusable in a later phase.

## Evidence index

| Artifact                       | Path                                                                     |
| ------------------------------ | ------------------------------------------------------------------------ |
| Baseline Nmap scan             | `evidence/phase2/linux01-baseline.*`                                     |
| Post-hardening Nmap scan       | `evidence/phase2/linux01-after.*`                                        |
| Nmap diff                      | `evidence/phase2/ndiff-baseline-vs-after.txt`                            |
| SSH before/after (`sshd -T`)   | `evidence/phase2/sshd-before.txt`, `sshd-after.txt`                      |
| TLS cipher scan                | `evidence/phase2/linux01-tls.*`                                          |
| Firewall ruleset (post-reboot) | `evidence/phase2/nft-ruleset-after-reboot.txt`                           |
| auditd test event              | `evidence/phase2/audit-test-passwd.txt`                                  |
| Configs                        | `configs/ssh/`, `configs/nginx/`, `configs/firewall/`, `configs/auditd/` |
