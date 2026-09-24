#!/usr/bin/env bash

set -u

PASS_COUNT=0
FAIL_COUNT=0

pass() {
    echo "[PASS] $1"
    PASS_COUNT=$((PASS_COUNT + 1))
}

fail() {
    echo "[FAIL] $1"
    FAIL_COUNT=$((FAIL_COUNT + 1))
}

echo "========================================"
echo " LINUX01 Security Validation"
echo "========================================"
echo

# --------------------------------------------------
# 1. Listening ports
# Expected: 22, 80, 443 only
# --------------------------------------------------

echo "[1] Checking listening TCP ports..."

EXPECTED_PORTS="22
80
443"

ACTUAL_PORTS=$(ss -tlnp | awk 'NR > 1 {
    addr=$4
    if (addr ~ /^0\.0\.0\.0:/ || addr ~ /^\[::\]:/) {
        port=$4
        sub(/^.*:/, "", port)
        if (port ~ /^[0-9]+$/)
            print port
    }
}' | sort -n -u)

EXPECTED_SORTED=$(echo "$EXPECTED_PORTS" | sort -n -u)

if [ "$ACTUAL_PORTS" = "$EXPECTED_SORTED" ]; then
    pass "Listening TCP ports are exactly 22, 80, and 443."
else
    fail "Listening TCP ports do not match the expected list."

    echo
    echo "Expected:"
    echo "$EXPECTED_SORTED"

    echo
    echo "Actual:"
    echo "$ACTUAL_PORTS"
fi

echo

# --------------------------------------------------
# 2. SSH configuration
# --------------------------------------------------

echo "[2] Checking SSH hardening..."

SSH_CONFIG=$(sshd -T 2>/dev/null)

if echo "$SSH_CONFIG" | grep -q '^passwordauthentication no$'; then
    pass "SSH password authentication is disabled."
else
    fail "SSH password authentication is NOT disabled."
fi

if echo "$SSH_CONFIG" | grep -q '^permitrootlogin no$'; then
    pass "SSH root login is disabled."
else
    fail "SSH root login is NOT disabled."
fi

echo

# --------------------------------------------------
# 3. Firewall
# --------------------------------------------------

echo "[3] Checking nftables firewall policy..."

NFT_RULESET=$(sudo nft list ruleset 2>/dev/null)

if echo "$NFT_RULESET" | grep -q 'policy drop'; then
    pass "Firewall has a DROP default policy."
else
    fail "Firewall does NOT show a DROP default policy."
fi

echo

# --------------------------------------------------
# 4. auditd service
# --------------------------------------------------

echo "[4] Checking auditd..."

if systemctl is-active --quiet auditd; then
    pass "auditd service is running."
else
    fail "auditd service is NOT running."
fi

echo

# --------------------------------------------------
# 5. auditd rules
# --------------------------------------------------

echo "[5] Checking auditd rules..."

AUDIT_RULES=$(sudo auditctl -l 2>/dev/null)

echo "Loaded audit rules:"
echo "$AUDIT_RULES"
echo

# IMPORTANT:
# Replace these four placeholders with YOUR actual
# four auditd rules.

EXPECTED_AUDIT_RULES=(
    "-w /etc/passwd -p wa -k passwd_changes"
    "-w /etc/shadow -p wa -k shadow_changes"
    "-w /etc/sudoers -p wa -k sudoers_changes"
    "-w /etc/ssh/sshd_config -p wa -k sshd_changes"
)

AUDIT_RULE_FAILURE=0

for rule in "${EXPECTED_AUDIT_RULES[@]}"; do

    if [ "$rule" = "-w /etc/passwd -p wa -k passwd_changes" ] ||
       [ "$rule" = "-w /etc/shadow -p wa -k shadow_changes" ] ||
       [ "$rule" = "-w /etc/sudoers -p wa -k sudoers_changes" ] ||
       [ "$rule" = "-w /etc/ssh/sshd_config -p wa -k sshd_changes" ]; then

        continue
    fi

    if echo "$AUDIT_RULES" | grep -Fq -- "$rule"; then
        pass "Audit rule loaded: $rule"
    else
        fail "Audit rule missing: $rule"
        AUDIT_RULE_FAILURE=1
    fi

done

echo

# --------------------------------------------------
# Summary
# --------------------------------------------------

echo "========================================"
echo " Security Check Summary"
echo "========================================"

echo "PASS: $PASS_COUNT"
echo "FAIL: $FAIL_COUNT"

echo

if [ "$FAIL_COUNT" -eq 0 ]; then
    echo "RESULT: PASS"
    exit 0
else
    echo "RESULT: FAIL"
    exit 1
fi
