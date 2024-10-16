#!/usr/bin/env bash
# Updater for Steam compatibility tools

set -euo pipefail

COMPAT_PATH="$HOME/.local/share/Steam/compatibilitytools.d"

# ensure Steam compat tools directory exists
# TODO i18n
mkdir -p "$COMPAT_PATH" || die "Unable to create Steam compat tools directory."

tempdir="$(mktemp -d --tmpdir scupd.XXXXX)"

cleanup() {
  rm -fr "$tempdir"
}

trap cleanup EXIT

notify() {
  # critical notifications should stick until manual dismissal
  notify-send -i "${3:-steam}" -u "${4:-critical}" "${2:-Steam compat updater}" "$1"
}

die() {
  notify "$@"
  exit 1
}

# TODO download all missing releases between latest released and latest installed
update_ge_proton() {
  ge_repo_url="https://github.com/GloriousEggroll/proton-ge-custom"

  # credit goes to https://www.reddit.com/r/linux_gaming/comments/1cf1vkk/i_made_a_little_script_to_update_protonge_to_use/
  ge_latest_url="$(curl -Lsf -o /dev/null -w '%{url_effective}' "$ge_repo_url/releases/latest")"
  ge_latest="${ge_latest_url##*/}"

  if [[ ! -d "$COMPAT_PATH/$ge_latest" ]]; then
    ge_url_base="$ge_repo_url/releases/download/$ge_latest/$ge_latest"

    curl -Lsf -o "$tempdir/${ge_latest}.tar.gz" "${ge_url_base}.tar.gz" || die "Unable to download latest GE-Proton release."
    curl -Lsf -o "$tempdir/${ge_latest}.sha512sum" "${ge_url_base}.sha512sum" || die "Unable to download latest GE-Proton release."

    # TODO i18n
    (cd "$tempdir" && sha512sum -c "$tempdir/${ge_latest}.sha512sum") || die "GE-Proton package verification failed."
    # TODO i18n
    tar -C "$COMPAT_PATH" -xzf "$tempdir/${ge_latest}.tar.gz" || die "GE-Proton installation failed."
    # TODO i18n
    notify "Updated to version ${ge_latest}."
  fi
}

update_ge_proton
