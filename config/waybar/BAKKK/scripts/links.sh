#!/usr/bin/env bash

set -euo pipefail

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly LAST_SELECTED_FILE="/tmp/last_wofi_selection_${USER}"

declare -A LINKS=(
  ["⭐ Favorites"]="SUBMENU:favorite_links"
  ["📂 AI"]="SUBMENU:ai_links"
  ["📺 Media"]="SUBMENU:media_links"
  ["🌐 Social"]="SUBMENU:social_links"
  ["💻 Programs"]="SUBMENU:program_links"
  ["⚡ Swaylock"]="SUBMENU:power_menu"
  ["🔍 Web Search"]="ACTION:web_search"
  ["🎬 YT-DLP Downloader"]="ACTION:ytdlp_download"
  ["favorite_links:.config"]="SUBMENU:dot_config_links"
  ["favorite_links:❄️ NixOS"]="program:kitty sudo -E thunar /etc/nixos"
  ["favorite_links:💬 4chan"]="SUBMENU:fourchan_links"
  ["fourchan_links:🎞️ Anime & Manga (/a/)"]="https://boards.4chan.org/a/"
  ["fourchan_links:💻 Technology (/g/)"]="https://boards.4chan.org/g/"
  ["fourchan_links:📰 News (/news/)"]="https://boards.4chan.org/news/"
  ["fourchan_links:🎵 Music (/mu/)"]="https://boards.4chan.org/mu/"
  ["fourchan_links:📷 Photography (/p/)"]="https://boards.4chan.org/p/"
  ["fourchan_links:🖼️ Wallpapers (/w/)"]="https://boards.4chan.org/w/"
  ["fourchan_links:📽️ WebM (/wsg/)"]="https://boards.4chan.org/wsg/"
  ["ai_links:🤖 ChatGPT"]="https://chatgpt.com/"
  ["ai_links:🪐 Gemini"]="https://gemini.google.com"
  ["ai_links:⚡ Grok"]="https://grok.com/"
  ["ai_links:💡 Claude"]="https://claude.ai"
  ["ai_links:🚀 Qwen"]="https://chat.qwen.ai"
  ["ai_links:🔍 DeepSeek"]="https://www.deepseek.com/"
  ["ai_links:🤖 Perplexity"]="https://www.perplexity.ai"
  ["media_links:🎥 YouTube"]="https://youtube.com"
  ["media_links:🎶 YouTube Music"]="https://music.youtube.com"
  ["social_links:📘 Facebook"]="https://facebook.com"
  ["social_links:🔍 Reddit"]="https://reddit.com"
  ["social_links:🐦 Twitter"]="https://twitter.com"
  ["social_links:🎵 Last.fm"]="https://www.last.fm"
  ["social_links:🎬 Letterboxd"]="https://letterboxd.com"
  ["social_links:🎮 Discord"]="https://discord.com"
  ["social_links:📷 Pinterest"]="https://pinterest.com"
  ["social_links:🌐 Tumblr"]="https://tumblr.com"
  ["social_links:💬 4chan"]="SUBMENU:fourchan_links"
  ["program_links:🦊 Firefox"]="program:firefox"
  ["program_links:🐺 Librewolf"]="program:librewolf"
  ["program_links:🎞️ MPV"]="program:mpv"
  ["program_links:🎵 Spotify"]="program:spotify"
  ["program_links:📝 Mousepad"]="program:mousepad"
  ["program_links:🗃️ Thunar"]="program:thunar"
  ["program_links:🐱 Kitty"]="program:kitty"
  ["program_links:📨 Telegram"]="program:telegram-desktop"
  ["program_links:🗃️ Thunar (root)"]="program:kitty sudo -E thunar"
  ["dot_config_links:📟 Waybar"]="SUBMENU:waybar_config_links"
  ["dot_config_links:🌊 hyprland.conf"]="/home/ls/.config/hypr/hyprland.conf"
  ["dot_config_links:🐱 kitty.conf"]="/home/ls/.config/kitty/kitty.conf"
  ["waybar_config_links:⚙️ Config"]="/home/ls/.config/waybar/config"
  ["waybar_config_links:🎨 Style"]="/home/ls/.config/waybar/style.css"
  ["waybar_config_links:📦 Modules"]="SUBMENU:waybar_script_modules"
)

declare -a NAVIGATION_STACK=()

log_error() {
  echo "Error: $1" >&2
}

check_dependencies() {
  local deps=("wofi" "xdg-open" "mousepad" "nano" "kitty" "thunar" "swaylock" "yt-dlp")
  for dep in "${deps[@]}"; do
    command -v "$dep" &>/dev/null || { log_error "Dependency '$dep' not found"; exit 1; }
  done
}

get_last_selection() {
  [[ -f "$LAST_SELECTED_FILE" ]] && cat "$LAST_SELECTED_FILE" 2>/dev/null || echo ""
}

save_selection() {
  echo "$1" > "$LAST_SELECTED_FILE"
}

push_to_stack() {
  NAVIGATION_STACK+=("$1")
}

pop_from_stack() {
  if [[ ${#NAVIGATION_STACK[@]} -gt 0 ]]; then
    local last_index=$(( ${#NAVIGATION_STACK[@]} - 1 ))
    unset 'NAVIGATION_STACK[last_index]'
    NAVIGATION_STACK=("${NAVIGATION_STACK[@]}")
  fi
}

peek_stack() {
  [[ ${#NAVIGATION_STACK[@]} -gt 0 ]] && echo "${NAVIGATION_STACK[${#NAVIGATION_STACK[@]}-1]}" || echo ""
}

build_menu_options() {
  printf '%s\n' \
    "🔍 Web Search" \
    "🎬 YT-DLP Downloader" \
    "⭐ Favorites" \
    "💻 Programs" \
    "📺 Media" \
    "🌐 Social" \
    "⚡ Swaylock"
}

build_submenu_options() {
  local submenu_key="$1"
  local options=("⬅ Back")
  local items=()

  if [[ "$submenu_key" == "favorite_links" ]]; then
    items=(".config" "❄️ NixOS" "💬 4chan")
  elif [[ "$submenu_key" == "dot_config_links" ]]; then
    items=("📟 Waybar" "🌊 hyprland.conf" "🐱 kitty.conf")
  elif [[ "$submenu_key" == "power_menu" ]]; then
    items=("🔌 Shutdown" "🔄 Reboot" "🚪 Logout (Hyprland)" "😴 Suspend" "🔒 Lock Screen")
  elif [[ "$submenu_key" == "waybar_script_modules" ]]; then
    options+=("📁 Open Scripts Folder")
    local base_path="/home/ls/.config/waybar/scripts"
    if [[ -d "$base_path" ]]; then
      while IFS= read -r -d '' file; do
        file_name=$(basename "$file")
        case "$file_name" in
          battery-level.sh) items+=("🔋 $file_name");;
          battery-state.sh) items+=("⚡ $file_name");;
          brightness-control.sh) items+=("💡 $file_name");;
          links.sh) items+=("🔗 $file_name");;
          playerctl-status.sh) items+=("🎵 $file_name");;
          volume-control.sh) items+=("🔊 $file_name");;
          wifi-menu.sh) items+=("📶 $file_name");;
          wifi-status.sh) items+=("📡 $file_name");;
          *) items+=("📄 $file_name");;
        esac
      done < <(find "$base_path" -maxdepth 1 -type f -executable -print0)
    fi
  else
    for key in "${!LINKS[@]}"; do
      [[ "$key" == $submenu_key:* ]] && items+=("${key#$submenu_key:}")
    done
  fi

  if [[ "$submenu_key" == "waybar_config_links" ]]; then
    items=("⚙️ Config" "🎨 Style" "📦 Modules")
  elif [[ "$submenu_key" != "favorite_links" && "$submenu_key" != "dot_config_links" && "$submenu_key" != "power_menu" ]]; then
    IFS=$'\n' sorted=($(sort <<<"${items[*]}"))
    unset IFS
    items=("${sorted[@]}")
  fi

  options+=("${items[@]}")
  printf '%s\n' "${options[@]}"
}

confirm_action() {
  local prompt="$1"
  local confirmation
  confirmation=$(printf "No\nYes" | wofi --dmenu --prompt "$prompt" --height 130 --width 300)
  if [[ "$confirmation" == "Yes" ]]; then
    return 0
  else
    return 1
  fi
}

url_encode() {
    python3 -c "import urllib.parse; import sys; print(urllib.parse.quote_plus(sys.argv[1]))" "$1"
}

perform_web_search() {
    local query
    query=$(wofi --dmenu --prompt "Web Search")
    [[ -z "$query" ]] && return

    if [[ "$query" =~ ^(https?:\/\/)?([a-zA-Z0-9-]+\.)+[a-zA-Z]{2,}(.*)$ ]]; then
        url="$query"
        [[ ! "$url" =~ ^https?:\/\/ ]] && url="https://$url"
        xdg-open "$url" &
        return
    fi

    local prefix term search_url
    prefix=$(echo "$query" | awk '{print $1}')
    term=$(echo "$query" | awk '{$1=""; print $0}' | sed 's/^ *//')

    case "$prefix" in
        g)
            search_url="https://www.google.com"
            [[ -n "$term" ]] && search_url+="/search?q=$(url_encode "$term")"
            ;;
        yt)
            search_url="https://www.youtube.com"
            [[ -n "$term" ]] && search_url+="/results?search_query=$(url_encode "$term")"
            ;;
        ddg)
            search_url="https://duckduckgo.com"
            [[ -n "$term" ]] && search_url+="?q=$(url_encode "$term")"
            ;;
        *)
            search_url="https://duckduckgo.com/?q=$(url_encode "$query")"
            ;;
    esac

    xdg-open "$search_url" &
}

perform_ytdlp_download() {
    local url
    url=$(wofi --dmenu --prompt "Enter Video/Playlist Link")
    [[ -z "$url" ]] && return

    local is_playlist
    is_playlist=$(printf "No\nYes" | wofi --dmenu --prompt "Is this a playlist?" --height 130)
    [[ -z "$is_playlist" ]] && return

    local format_choice
    format_choice=$(printf "1080p (MP4)\n720p (MP4)\nBest Audio (MP3)" | wofi --dmenu --prompt "Select Format" --height 200)
    [[ -z "$format_choice" ]] && return

    local download_dir="$HOME/Downloads"
    mkdir -p "$download_dir"

    local output_template
    if [[ "$is_playlist" == "Yes" ]]; then
        output_template="%(playlist_index)s - %(title)s.%(ext)s"
    else
        output_template="%(title)s.%(ext)s"
    fi

    local ytdlp_args
    case "$format_choice" in
        "1080p (MP4)")
            ytdlp_args="-f 'bestvideo[height<=1080][ext=mp4]+bestaudio[ext=m4a]/best[height<=1080][ext=mp4]' --merge-output-format mp4"
            ;;
        "720p (MP4)")
            ytdlp_args="-f 'bestvideo[height<=720][ext=mp4]+bestaudio[ext=m4a]/best[height<=720][ext=mp4]' --merge-output-format mp4"
            ;;
        "Best Audio (MP3)")
            ytdlp_args="-x --audio-format mp3 -f bestaudio"
            ;;
    esac

    kitty sh -c "yt-dlp $ytdlp_args -P '$download_dir' -o '$output_template' '$url'; echo 'Download finished. Press Enter to close.'; read" &
}

handle_power_action() {
    local selection="$1"
    case "$selection" in
        "🔌 Shutdown")
            confirm_action "Shutdown system?" && systemctl poweroff
            ;;
        "🔄 Reboot")
            confirm_action "Reboot system?" && systemctl reboot
            ;;
        "🚪 Logout (Hyprland)")
            confirm_action "Logout?" && hyprctl dispatch exit
            ;;
        "😴 Suspend")
            systemctl suspend
            ;;
        "🔒 Lock Screen")
            swaylock -c 000000
            ;;
    esac
}

open_link() {
  local selected="$1"
  local value="${LINKS[$selected]:-}"

  if [[ "$value" == SUBMENU:* ]]; then
    push_to_stack "${value##*:}"
    run_submenu "${value##*:}" "${selected##*:}"
    return 0
  elif [[ "$value" == ACTION:* ]]; then
    local action="${value##*:}"
    case "$action" in
        web_search) perform_web_search ;;
        ytdlp_download) perform_ytdlp_download ;;
    esac
    return 0
  elif [[ -n "$value" ]]; then
    if [[ "$value" == program:* ]]; then
      ${value#program:} &
    else
      xdg-open "$value" &
    fi
    return 0
  fi
  return 1
}

open_dot_config_item() {
  local selected="$1"
  local value="${LINKS[dot_config_links:$selected]:-}"

  if [[ "$selected" == "📟 Waybar" ]]; then
    push_to_stack "waybar_config_links"
    run_submenu "waybar_config_links" "Waybar"
    return 0
  fi

  [[ -z "$value" ]] && return 1

  if [[ -f "$value" ]]; then
    kitty sudo -E thunar "$(dirname "$value")" &
  else
    xdg-open "$value" &
  fi
  return 0
}

open_waybar_config_item() {
  local selected="$1"
  local value="${LINKS[waybar_config_links:$selected]:-}"

  if [[ "$selected" == "📦 Modules" ]]; then
    push_to_stack "waybar_script_modules"
    run_submenu "waybar_script_modules" "Waybar Modules"
    return 0
  fi

  [[ -z "$value" ]] && return 1

  if [[ -f "$value" ]]; then
    kitty sudo -E thunar "$(dirname "$value")" &
  else
    xdg-open "$value" &
  fi
  return 0
}

open_waybar_script_module() {
  local selected_with_emoji="$1"
  local script_dir="/home/ls/.config/waybar/scripts"

  if [[ "$selected_with_emoji" == "📁 Open Scripts Folder" ]]; then
    kitty sudo -E thunar "$script_dir" &
    return 0
  fi
  
  local selected_filename="${selected_with_emoji#* }"
  local script_path="$script_dir/$selected_filename"

  if [[ -f "$script_path" ]]; then
    kitty sudo -E thunar "$script_dir" &
  else
    log_error "Script not found: $script_path"
  fi
}

run_submenu() {
  local submenu_key="$1"
  local prompt="$2"
  local wofi_args=(
    --dmenu
    --prompt "$prompt"
    --width 400
    --height $(( 100 + 50 * $(build_submenu_options "$submenu_key" | wc -l) ))
    --cache-file /dev/null
    --allow-markup
    --insensitive
    --matching fuzzy
    --style ~/.config/wofi/style.css
  )

  local selected
  selected=$(build_submenu_options "$submenu_key" | wofi "${wofi_args[@]}")

  [[ -z "$selected" ]] && return

  if [[ "$selected" == "⬅ Back" ]]; then
    pop_from_stack
    local prev_menu_key=$(peek_stack)
    if [[ -z "$prev_menu_key" ]]; then
      main
    elif [[ "$prev_menu_key" == "dot_config_links" ]]; then
      run_submenu "dot_config_links" ".config"
    elif [[ "$prev_menu_key" == "waybar_config_links" ]]; then
      run_submenu "waybar_config_links" "Waybar"
    else
      run_submenu "$prev_menu_key" "${prev_menu_key##*:}"
    fi
    return
  fi

  save_selection "$selected"

  case "$submenu_key" in
    power_menu)
      handle_power_action "$selected"
      ;;
    favorite_links|ai_links|media_links|social_links|program_links|fourchan_links)
      open_link "$submenu_key:$selected"
      ;;
    dot_config_links)
      open_dot_config_item "$selected"
      ;;
    waybar_config_links)
      open_waybar_config_item "$selected"
      ;;
    waybar_script_modules)
      open_waybar_script_module "$selected"
      ;;
    *)
      open_link "$submenu_key:$selected"
      ;;
  esac
}

main() {
  check_dependencies
  NAVIGATION_STACK=()

  local wofi_args=(
    --dmenu
    --prompt "󰍜 Launcher"
    --width 550
    --height 400
    --cache-file /dev/null
    --allow-markup
    --insensitive
    --matching fuzzy
    --style ~/.config/wofi/style.css
  )

  local selected
  selected=$(build_menu_options | wofi "${wofi_args[@]}")

  [[ -z "$selected" ]] && exit 0

  save_selection "$selected"

  open_link "$selected" || {
    log_error "Selection '$selected' not recognized"
    exit 1
  }
}

[[ "${BASH_SOURCE[0]}" == "${0}" ]] && main "$@"