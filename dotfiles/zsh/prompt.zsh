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

SPACESHIP_PROMPT_ORDER=(
  user          # Username section
  host          # Hostname section
  dir           # Current directory section
  git           # Git section (git_branch + git_status)
  venv          # Python venv
  line_sep      # Line break
  char          # Prompt character
)

SPACESHIP_RPROMPT_ORDER=(
  exit_code
  vi_mode
)
