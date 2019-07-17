#!/bin/bash

echo "Running apt-get install..."
apt-get update && apt-get install -y git vim bash bash-completion

cat <<EOF >> ~/.bashrc
if [ -f /usr/share/bash-completion/bash_completion ]; then
  . /usr/share/bash-completion/bash_completion
fi
EOF
