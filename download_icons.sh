#!/usr/bin/env bash
set -euo pipefail

mkdir -p assets/logos

# Map icon slug -> desired hex color (no #)
declare -A icons=(
  [python]=3776AB
  [r]=276DC3
  [mysql]=4479A1
  [tensorflow]=FF6F00
  [keras]=D00000
  [scikitlearn]=F7931E
  [pytorch]=EE4C2C
  [pandas]=150458
  [numpy]=013243
  [scipy]=8CAAE6
  [matplotlib]=11557C
  [seaborn]=3776AB
  [flask]=000000
  [docker]=2496ED
  [jupyter]=F37626
  [linkedin]=0A66C2
  [github]=181717
  [leetcode]=FFA116
  [geeksforgeeks]=0F9D58
  [stackoverflow]=FE7A16
  [codeforces]=2F74C0
  [codechef]=256B99
  [hackerrank]=2EC866
  [codolio]=181717
  [discord]=5865F2
  [gmail]=D14836
)

base_raw="https://raw.githubusercontent.com/simple-icons/simple-icons/develop/icons"

for name in "${!icons[@]}"; do
  color="${icons[$name]}"
  out="assets/logos/${name}.svg"
  echo "Fetching ${name} -> ${out} (color #${color})"

  # Try to download raw SVG from Simple Icons repo
  url="${base_raw}/${name}.svg"
  if ! curl -fsSL -o /tmp/${name}.svg "${url}"; then
    echo "Warning: failed to download ${name} from simple-icons raw. Trying CDN fallback..."
    # fallback to CDN (may 403)
    cdn_url="https://cdn.simpleicons.org/${name}/${color}"
    if ! curl -fsSL -o /tmp/${name}.svg "${cdn_url}"; then
      echo "Error: cannot fetch ${name} from either source. Skipping."
      continue
    fi
  fi

  # Ensure the svg tag has style fill with the color.
  # If the svg already contains fill or style, we still set style attribute to enforce color.
  # Insert or replace style attribute on the <svg ...> tag
  # Use perl to be safer with attributes
  perl -0777 -pe "s{<svg\b([^>]*)>}{my \$a=\$1; if(\$a=~m/style=){ \$a=~s/style=(['\"])(.*?)\\1/\"style=\\\"fill:#${color};\$2\\\"\"/e } else { \$a .= \" style=\\\"fill:#${color}\\\"\" } \"<svg\$a>\" }ge" /tmp/${name}.svg > "${out}" || {
    # fallback simple replacement
    sed "s/<svg /<svg style=\"fill:#${color}\" /" /tmp/${name}.svg > "${out}" || {
      echo "Failed to inject color for ${name}; copying raw file"
      cp /tmp/${name}.svg "${out}"
    }
  }

  # Basic cleanup: ensure file exists and is not empty
  if [[ -s "${out}" ]]; then
    echo "Saved ${out}"
  else
    echo "Error: ${out} empty or missing"
  fi
done

echo "Done. Created/updated files in assets/logos/"
