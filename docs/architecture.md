# Mini Enterprsie Security Lab Architecture

## Purpose

This document defines the architecture for a Mini Enterprise Security Lab

```mermaid
graph TB
KALI-Docker Container
MONITOR - Suricata
SCANNER - OpenVAS/Greenbone
DC01[DC01-AD/ DNS]
WIN01-Windows Client on-demand
LINUX01-Linux Server
JUCIE SHOP - Vulnerable App
KALI-DOcker Container -> DC01[DC01-AD/DNS]
```
