# Spaceship Prompt
if [ $(whoami) = 'root' ]
then
    color='red'
elif [ ${SSH_TTY} ]
then
    color='yellow'
else
    color='green'
fi

SPACESHIP_USER_SHOW=always
SPACESHIP_USER_SUFFIX=""
SPACESHIP_USER_COLOR=$color
SPACESHIP_HOST_SHOW=always
SPACESHIP_HOST_PREFIX="%F{$color}@"
SPACESHIP_HOST_COLOR=$color
SPACESHIP_HOST_COLOR_SSH="yellow"
SPACESHIP_DIR_SHOW=always
SPACESHIP_DIR_PREFIX=""
SPACESHIP_DIR_COLOR="blue"
if [ "$IN_NIX_SHELL" = "" ]
then
	SPACESHIP_CHAR_SYMBOL="$"
else
	SPACESHIP_CHAR_SYMBOL=""
fi
SPACESHIP_CHAR_SYMBOL_ROOT="#"
SPACESHIP_CHAR_SUFFIX=" "
SPACESHIP_EXIT_CODE_SHOW=true
SPACESHIP_VENV_SYMBOL="🐍 "
SPACESHIP_KUBECTL_SHOW=true
SPACESHIP_KUBECTL_VERSION_SHOW=false

SPACESHIP_PROMPT_ORDER=(
  user          # Username section
  host          # Hostname section
  dir           # Current directory section
  exit_code
  git           # Git section (git_branch + git_status)
  venv          # Python venv
  kubectl       # Kubectl context
)

# Load custom sections from sections directory
if [[ -d ~/.config/zsh/sections ]]; then
  for section in ~/.config/zsh/sections/*.zsh
  do
    local 'section_name'
    source $section
    section_name=$(basename $section)
    SPACESHIP_PROMPT_ORDER+=(${section_name%.*})
  done
fi

SPACESHIP_PROMPT_ORDER+=(
  line_sep      # Line break
  char          # Prompt character
)
