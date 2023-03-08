#! /usr/bin/env nix-shell
#! nix-shell -i bash -p nix-prefetch jq

# TODO:
# skip existing hashes
# offer flag to refetch everything.

LEAN_OWNER=leanprover-community
LEAN_REPOSITORY=lean
RELEASE_JSON_OUTPUT=./releases.json

function fetch_sha256() {
	nix-prefetch fetchFromGitHub --owner $LEAN_OWNER --repo $LEAN_REPOSITORY --rev $1 2>/dev/null
}

function fetch_emscripten_sha256() {
	local version="$1"
	nix-prefetch fetchzip --url "https://github.com/leanprover-community/lean/releases/download/v${version#v}/lean-${version#v}--browser.zip" 2>/dev/null
}

# Get all releases in array $releases
mapfile -t releases < <(curl "https://api.github.com/repos/$LEAN_OWNER/$LEAN_REPOSITORY/tags?per_page=100" | jq -c '.[] | {name: .name, githash: .commit.sha} | @base64')

[ -f $RELEASE_JSON_OUTPUT ] || (echo "{}" > $RELEASE_JSON_OUTPUT && echo "[!] No release file existed priorly, created")
for release_data in "${releases[@]}"
do
	release_data="${release_data%\"}"
	release_data="${release_data#\"}"
	_jq() {
		echo $release_data | base64 --decode | jq -r ${1}
	}
	release=$(_jq '.name')
	githash=$(_jq '.githash')
	echo "[?] Processing release $release (git hash: $githash)..."
	if [[ ! "$release" =~ ^v.* || "$release" == "v9.9.9" ]]; then
		echo "[?] Not a version. Ignoring."
		continue
	fi
	sha256=$(fetch_sha256 "$release")
	emscripten_sha256=$(fetch_emscripten_sha256 "$release")
	cat <<< $(jq ". + {\"$release\": {owner: \"$LEAN_OWNER\", repo: \"$LEAN_REPOSITORY\", sha256: \"$sha256\", emscripten_sha256: \"$emscripten_sha256\", rev: \"$release\", githash: \"$githash\"}}" $RELEASE_JSON_OUTPUT) > "$RELEASE_JSON_OUTPUT"
	echo "[+] Updated release $release (sha256: $sha256, emscripten sha256: $emscripten_sha256) in $RELEASE_JSON_OUTPUT"
done
