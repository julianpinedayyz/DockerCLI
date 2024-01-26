FROM ubuntu:latest

ENV TZ=America/Bogota
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
RUN apt update && apt upgrade -y && apt install -y tzdata \
  apt-utils \
  build-essential \
  python3 \
  python3-pip \
  python-is-python3 \
  git \
  sudo \
  curl \
  micro \
  bat \
  wget \
  zsh \
  tmux \
  libbz2-dev \
  libncurses5 \
  libffi-dev \
  libreadline-dev \
  libssl-dev \
  libsqlite3-dev \
  lzma \
  liblzma-dev \
  && rm -rf /var/lib/apt/lists/*

RUN pip3 install --upgrade pip
RUN pip install virtualenv bpython
RUN chsh -s /usr/bin/zsh
WORKDIR /root
RUN mkdir -p ~/.config
RUN mkdir -p ~/.config/micro/colorschemes
RUN touch ~/.config/starship.toml
RUN mkdir -p ~/Downloads
RUN cd ~/Downloads \
  && git clone https://github.com/dracula/micro.git
RUN cp -r ~/Downloads/micro/dracula.micro ~/.config/micro/colorschemes/dracula.micro
RUN <<EOF
  cat >> ~/.config/starship.toml <<'endmsg'
# Get editor completions based on the config schema
"$schema" = "https://starship.rs/config-schema.json"

format = """
$username\
$hostname\
$localip\
$shlvl\
$time\
$directory\
$git_branch\
$git_commit\
$git_state\
$git_metrics\
$git_status\
$hg_branch\
$docker_context\
$package\
$golang\
$nodejs\
$perl\
$php\
$python\
$ruby\
$rust\
$aws\
$gcloud\
$crystal\
$custom\
$sudo\
$cmd_duration\
$line_break\
$jobs\
$battery\
$status\
$container\
$shell\
$character
"""
# Inserts a blank line between shell prompts
add_newline = true

# Set "foo" as custom color palette
palette = "dracula"

# Define custom colors
[palettes.dracula]
# Define new color
magenta = "#ff79c6"
grey = "#6272a4"
purple = "#bd93f9"
green = "#50fa7b"
orange = "#ffb86c"
red = "#ff5555"
yellow = "#f1fa8c"
blue = "#8be9fd"
# Override existing color


# Replace the "❯" symbol in the prompt with "➜"
[character] # The name of the module we are configuring is "character"
success_symbol = "[➜](bold green)"
error_symbol = "[➜](bold red)"

# [cm_duration]
# min_time = 1000

[time]
disabled = false
format = "[$time](magenta) "

[directory]
read_only = " "

[docker_context]
symbol = " "

[git_commit]
tag_symbol = " "

[git_state]
rebase = " "
merge = " "
revert = "↲ "
cherry_pick = " "
bisect = " "
am = " "
am_or_rebase = " "


[git_branch]
symbol = " "

[git_status]
format = "([$all_status$ahead_behind](bold red) )"
# conflicted = "[ ${count}](yellow)"
conflicted = "[󰶯 ${count} ](yellow)"
# deleted = "[ ${count}](bold red)"
deleted = "[ ${count} ](bold red)"
# modified = "[ ${count}](bold red)"
modified = "[ ${count} ](bold red)"
# staged = "[ ${count}](bold green)"
staged = "[ ](bold green)"
# untracked = "[ ${count}](bold yellow)"
untracked = "[󰘦 ${count} ](bold yellow)"
# ahead = "[ ${count}](bold green)"
ahead = "[󰞔 ${count} ](bold green)"
# behind = "[ ${count}](bold red)"
behind = "[  ${count } ](bold red)"
diverged = "[ ](bold cyan)"
# renamed = "[ ${count}](bold yellow)"
renamed = "[󰷬 ${count} ](bold yellow)"
# stashed = "[ ${count}](bold pink)"
stashed = "[ ${count} ](bold pink)"


[hg_branch]
symbol = " "

[nodejs]
symbol = " "

[package]
symbol = " "
# Disable the package module, hiding it from the prompt completely
disabled = true

[python]
symbol = " "

[rust]
symbol = " "

[golang]
symbol = " "

[hostname]
ssh_symbol = " "

[localip]
ssh_only = true
format = "@[$localipv4](bold yellow) "
#disabled = false
EOF

RUN micro -plugin install nordcolors misspell detectindent autofmt editorconfig
RUN <<EOF
touch ~/.config/micro/settings.json
cat > ~/.config/micro/settings.json <<'endmsg'
{
    "colorscheme": "dracula",
    "savecursor": true
}
EOF

RUN curl -fsSL https://raw.githubusercontent.com/zimfw/install/master/install.zsh | zsh
RUN curl -sS https://starship.rs/install.sh | sh -s -- --yes

# Install eza
# https://github.com/eza-community/eza/blob/main/INSTALL.md
RUN <<EOF
  sudo mkdir -p /etc/apt/keyrings
  wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg
  echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | sudo tee /etc/apt/sources.list.d/gierens.list
  sudo chmod 644 /etc/apt/keyrings/gierens.gpg /etc/apt/sources.list.d/gierens.list
  sudo apt update
  sudo apt install -y eza
EOF

RUN <<EOF
  type -p curl >/dev/null || (sudo apt update && sudo apt install curl -y)
  curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg \
  && sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg \
  && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
  && sudo apt update \
  && sudo apt install gh -y
EOF

RUN <<EOF
cat >> ~/.zimrc <<'endmsg'
# https://zimfw.sh/docs/modules/
zmodule archive
zmodule zsh-users/zsh-completions
zmodule agkozak/zsh-z
zmodule joke/zim-github-cli

EOF

RUN curl https://pyenv.run | bash

RUN <<EOF
cat >> ~/.zshrc <<'endmsg'
export MICRO_TRUECOLOR=1

alias ls="eza"
alias las="eza -all"
alias zmicro="micro .zshrc"

update() { zimfw update && zimfw install && exec zsh -l }
tmicro() { touch $1 && micro $1 }

export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"

# Restart your shell for the changes to take effect.

# Load pyenv-virtualenv automatically by adding
# the following to ~/.bashrc:
eval "$(pyenv virtualenv-init -)"

eval "$(starship init zsh)"
EOF


CMD ["/bin/zsh"]