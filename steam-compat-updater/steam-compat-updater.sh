#!/usr/bin/env bash
# Updater for Steam compatibility tools

set -eo pipefail

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

update_ge_proton() {
  # TODO download all missing releases between latest released and latest installed
  ge_latest="$(gh release -R GloriousEggroll/proton-ge-custom view --json tagName -q .tagName)"

  if [[ ! -d "$COMPAT_PATH/$ge_latest" ]]; then
    # TODO i18n
    gh release -R GloriousEggroll/proton-ge-custom download "$ge_latest" --dir "$tempdir" || die "Unable to download latest GE-Proton release."
    # TODO i18n
    (cd "$tempdir" && sha512sum -c "$tempdir/${ge_latest}.sha512sum") || die "GE-Proton package verification failed."
    # TODO i18n
    tar -C "$COMPAT_PATH" -xzf "$tempdir/${ge_latest}.tar.gz" || die "GE-Proton installation failed."
    # TODO i18n
    notify "GE-Proton updated to version ${ge_latest}."
  fi
}

update_ge_proton
