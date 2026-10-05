#!/bin/sh
# Mirrors a Git branch into a work tree. The git dir lives outside the work tree so that
# /config/www (served unauthenticated at /local/) never exposes repository history.
OPT=/data/options.json
REPO=$(jq -r .repository $OPT); BRANCH=$(jq -r .branch $OPT); EVERY=$(jq -r .interval $OPT)
TARGET=$(jq -r .target $OPT); GITDIR=$(jq -r .git_dir $OPT); KEY=$(jq -r .deploy_key $OPT)

[ -z "$REPO" ] && { echo "Option 'repository' is empty - set it and restart."; sleep 3600; exit 1; }
export GIT_SSH_COMMAND="ssh -i $KEY -o IdentitiesOnly=yes -o StrictHostKeyChecking=accept-new -o UserKnownHostsFile=$(dirname "$KEY")/known_hosts"
git config --global --add safe.directory '*'
G="git --git-dir=$GITDIR --work-tree=$TARGET"

if [ ! -d "$GITDIR" ]; then
  mkdir -p "$TARGET"
  git clone --separate-git-dir="$GITDIR" -b "$BRANCH" "$REPO" "$TARGET" || echo "initial clone failed"
fi

while true; do
  if $G fetch -q origin "$BRANCH"; then
    BEFORE=$($G rev-parse HEAD 2>/dev/null)
    $G reset -q --hard "origin/$BRANCH"
    AFTER=$($G rev-parse HEAD)
    [ "$BEFORE" != "$AFTER" ] && echo "$(date -Iseconds) updated ${BEFORE%${BEFORE#???????}}..${AFTER%${AFTER#???????}}"
  else
    echo "$(date -Iseconds) fetch failed"
  fi
  sleep "$EVERY"
done
