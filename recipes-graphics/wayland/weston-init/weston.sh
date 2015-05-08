[ "" != "${XDG_RUNTIME_DIR}" ] || XDG_RUNTIME_DIR="/run/user/${USER}"
#[ -e "${XDG_RUNTIME_DIR}" ] || mkdir -p "${XDG_RUNTIME_DIR}"
#export XDG_RUNTIME_DIR

[ "" != "${QT_QPA_PLATFORM}" ] || QT_QPA_PLATFORM="wayland"
export QT_QPA_PLATFORM
