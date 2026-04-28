# cargo compete new and zoxide add
ccnew() {
  local id="$1"
  if [[ -z "$id" ]]; then
    echo "usage: ccnew <abc441|arc190|agc067|ahc019|...>"
    return 2
  fi

  # execute cargo compete new
  cargo compete new "$id" || return $?

  # parse id
  local prefix="${id[1,3]}"   # abc/arc/agc/ahc
  local d1="${id[4,4]}"       # 4
  local d2="${id[4,5]}"       # 44

  local dest
  case "$prefix" in
    abc|arc|agc|ahc)
      dest="${prefix}${d1}xx/${prefix}${d2}x/${id}"
      ;;
    *)
      dest="${id}"
      ;;
  esac

  if [[ -d "$dest" ]]; then
    zoxide add "$(pwd)/$dest"
  else
    echo "warn: expected dir not found: $dest"
    return 1
  fi
}

# yazi as y
function y() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
	command yazi "$@" --cwd-file="$tmp"
	IFS= read -r -d '' cwd < "$tmp"
	[ "$cwd" != "$PWD" ] && [ -d "$cwd" ] && builtin cd -- "$cwd"
	rm -f -- "$tmp"
}
