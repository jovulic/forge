# shellcheck shell=bash

# Color Configuration
COLOR_BLUE="\e[1;34m"
COLOR_GREEN="\e[1;32m"
COLOR_RED="\e[1;31m"
COLOR_RESET="\e[0m"

log_info() {
  echo -e "${COLOR_BLUE}==> $1${COLOR_RESET}"
}

log_success() {
  echo -e "${COLOR_GREEN}==> $1${COLOR_RESET}"
}

log_error() {
  echo -e "${COLOR_RED}Error: $1${COLOR_RESET}"
}

# Ensure the script is run as root
if [ "$EUID" -ne 0 ]; then
  log_error "This script must be run with root privileges to access the protected /var/cache/llama directory."
  echo "Please run: sudo llama-load"
  exit 1
fi

declare -A MODELS
MODELS["gemma4-9b"]="bartowski/google_gemma-4-E4B-it-GGUF:Q4_K_M"
MODELS["gemma4-12b"]="bartowski/gemma-4-12B-it-GGUF:Q4_K_M"
MODELS["gemma4-26b"]="bartowski/google_gemma-4-26B-A4B-it-GGUF:Q4_K_M"

download_model() {
  local name=$1
  local repo=$2
  log_info "Pre-loading model: $name ($repo)..."

  # Run the download directly as root using llama-completion with -no-cnv to skip custom template parsing and prevent crashes
  HF_HOME=/var/cache/llama/huggingface LLAMA_CACHE=/var/cache/llama/llama.cpp llama-completion -hf "$repo" -p "Hello" -n 1 -no-cnv

  # Set open permissions so the unprivileged llama-swap dynamic user can access them
  log_info "Setting permissions on cached files..."
  chmod -R ugo+rwX /var/cache/llama
}

target="${1:-all}"

if [ "$target" = "all" ]; then
  log_success "Pre-loading ALL configured models..."
  download_model "gemma4-9b" "${MODELS["gemma4-9b"]}"
  download_model "gemma4-12b" "${MODELS["gemma4-12b"]}"
  download_model "gemma4-26b" "${MODELS["gemma4-26b"]}"
  log_success "All models pre-loaded successfully!"
else
  if [ -n "${MODELS["$target"]:-}" ]; then
    download_model "$target" "${MODELS["$target"]}"
  else
    log_error "Unknown model '$target'."
    echo "Available models: gemma4-9b, gemma4-12b, gemma4-26b, all"
    exit 1
  fi
fi
