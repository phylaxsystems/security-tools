#!/bin/bash

TPUT_RESET=""
TPUT_WHITE=""
TPUT_BGRED=""
TPUT_RED=""
TPUT_GREEN=""
TPUT_BGGREEN=""
TPUT_BOLD=""
TPUT_DIM=""

# Is stderr on the terminal? If not, then fail
test -t 2 || return 1

if command -v tput > /dev/null 2>&1; then
  if [ $(($(tput colors 2> /dev/null))) -ge 8 ]; then
    # Enable colors
    TPUT_RESET="$(tput sgr 0)"
    TPUT_WHITE="$(tput setaf 7)"
    TPUT_BGRED="$(tput setab 1)"
    TPUT_BGGREEN="$(tput setab 2)"
# shellcheck disable=SC2034
    TPUT_GREEN="$(tput setaf 2)"
# shellcheck disable=SC2034
    TPUT_RED="$(tput setaf 1)"
    TPUT_BOLD="$(tput bold)"
# shellcheck disable=SC2034
    TPUT_DIM="$(tput dim)"
  fi
fi

warning(){
  echo
  printf "%s\n\n" "${TPUT_BGRED}${TPUT_WHITE}${TPUT_BOLD} WARNING ${TPUT_RESET} ${*}"
}

info(){
  echo
  printf "%s\n\n" "${TPUT_BGGREEN}${TPUT_WHITE}${TPUT_BOLD} INFO ${TPUT_RESET} ${*}"
}

# Regular expressions to match Ethereum addresses, Solana private keys, and Bitcoin private keys
ETH_ADDRESS_REGEX='0x[a-fA-F0-9]{40}'
SOL_PRIVATE_KEY_REGEX='^[1-9A-HJ-NP-Za-km-z]{44}$|^[1-9A-HJ-NP-Za-km-z]{88}$'
BTC_PRIVATE_KEY_REGEX='^[5KL][1-9A-HJ-NP-Za-km-z]{50}$'

# Check if the commit is being forced
FORCE_COMMIT=false
for arg in "$@"
do
  if [[ "$arg" == "--no-verify" ]]; then
    FORCE_COMMIT=true
  fi
done

# Get a list of files to be committed
FILES_TO_BE_COMMITTED=$(git diff --cached --name-only --diff-filter=ACM)

if [ "$FORCE_COMMIT" = false ]; then
  # Loop through the files
  for FILE in $FILES_TO_BE_COMMITTED; do
    # Check if the file contains a plaintext Ethereum address
    if grep -Eq "$ETH_ADDRESS_REGEX" "$FILE"; then
      warning "Error: File $FILE contains a plaintext Ethereum address."
      info "Commit aborted. Use '--no-verify' to override."
      exit 1
    fi

    # Check if the file contains a Solana private key
    if grep -Eq "$SOL_PRIVATE_KEY_REGEX" "$FILE"; then
      warning "Error: File $FILE contains a Solana private key."
      info "Commit aborted. Use '--no-verify' to override."
      exit 1
    fi

    # Check if the file contains a Bitcoin private key
    if grep -Eq "$BTC_PRIVATE_KEY_REGEX" "$FILE"; then
      warning "Error: File $FILE contains a Bitcoin private key."
      info "Commit aborted. Use '--no-verify' to override."
      exit 1
    fi
  done
fi

# If no matches are found, or if the commit is forced, allow the commit
exit 0
