#!/usr/bin/env -S nix shell nixpkgs#jq -c bash

set -euo pipefail
regex="^[0-9]\.[0-9]\.[0-9].*$"

info="info.json"
oldversion=$(jq -rc '.version' "$info")

# get 2 releases: the first will be twilight - the second will be the latest beta
url="https://api.github.com/repos/zen-browser/desktop/releases?per_page=2"
version="$(curl -s "$url" | jq -rc '.[1].tag_name')"

if [ "$oldversion" != "$version" ] && [[ "$version" =~ $regex ]]; then
	echo "Found new version $version"
	url="https://github.com/zen-browser/desktop/releases/download/${version}/zen.linux-x86_64.tar.bz2"

  # perform downloads in parallel
  echo "Prefetching files..."
  hash=$(nix store prefetch-file "$url" --log-format raw --json | jq -rc .hash)
	echo "hash found: $hash"

  echo '{"version":"'"$version"'","hash":"'"$hash"'","url":"'"$url"'"}' > "$info"
else
	echo "zen is up to date"
fi
