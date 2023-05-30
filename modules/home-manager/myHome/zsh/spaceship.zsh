local color
if [ ${SSH_TTY} ]
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
SPACESHIP_CHAR_SYMBOL="$"
SPACESHIP_CHAR_SYMBOL_ROOT="#"
SPACESHIP_CHAR_SYMBOL_SECONDARY="> "
SPACESHIP_CHAR_SUFFIX=" "
SPACESHIP_EXIT_CODE_SHOW=true
SPACESHIP_VENV_SYMBOL="🐍"
SPACESHIP_KUBECTL_SHOW=true
SPACESHIP_KUBECTL_VERSION_SHOW=false
SPACESHIP_KUBECTL_CONTEXT_SHOW_NAMESPACE=false

SPACESHIP_PROMPT_ORDER=(
  user
  host
  dir
  exit_code
  git
  nix_shell
  venv
  kubectl
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
  line_sep
  char
)
