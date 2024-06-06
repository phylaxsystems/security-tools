# security-tools

Helpful security tools so that you don't get rekt


## address-hook.sh

This repository includes a pre-commit hook to prevent committing plaintext Ethereum addresses, Solana private keys, and Bitcoin private keys. This helps ensure sensitive information is not accidentally exposed in the codebase.

### How It Works

The pre-commit hook scans the files staged for commit and checks for the following patterns:

- Ethereum Address: Matches 0x followed by 40 hexadecimal characters.
- Solana Private Key: Matches base58 encoded strings of length 44 or 88.
- Bitcoin Private Key: Matches WIF (Wallet Import Format) private keys starting with '5', 'K', or 'L' and are 51 characters long.

If any of these patterns are found, the commit is aborted, and an error message is displayed.

### Forcing a Commit

In case of a false positive, you can force the commit by using the `--no-verify` flag, which bypasses the pre-commit hook checks.

### How to Use

1. Clone this repository: `git clone https://github.com/phylaxsystems/security-tools`
2. Copy `address-hook.sh` into the hooks directory of your git repo: `cp security-tools/address-hook.sh <project_path>/.git/hooks/address-hook.sh`
3. Make sure you have `grep` installed on your system. If not, go ahead and install `grep`.

Now, whenever you add a new commit to that git repository, the script will check that you aren't leaking any private keys.
