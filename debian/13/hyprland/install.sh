#!/bin/bash

# Hyprland Complete Installation Script
# Optimised for Debian-based systems with permission prompts and visual organisation

set -e

# Colour definitions
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly PURPLE='\033[0;35m'
readonly CYAN='\033[0;36m'
readonly WHITE='\033[1;37m'
readonly NC='\033[0m' # No Colour
readonly BOLD='\033[1m'

# Configuration
readonly BUILD_DIR="$HOME/hypr-build"
readonly PARALLEL_JOBS=$(nproc)
readonly WAYLAND_PROTOCOLS_VERSION="1.45"
readonly HYPRLAND_VERSION="v0.45.2"

# Utility functions
print_header() {
    echo -e "\n${PURPLE}${BOLD}╭─────────────────────────────────────────────────────────────╮${NC}"
    echo -e "${PURPLE}${BOLD}│${NC} ${WHITE}${BOLD}$1${NC}${PURPLE}${BOLD}│${NC}"
    echo -e "${PURPLE}${BOLD}╰─────────────────────────────────────────────────────────────╯${NC}\n"
}

print_step() {
    echo -e "${CYAN}${BOLD}→${NC} ${WHITE}$1${NC}"
}

print_success() {
    echo -e "${GREEN}${BOLD}✓${NC} ${GREEN}$1${NC}"
}

print_warning() {
    echo -e "${YELLOW}${BOLD}⚠${NC} ${YELLOW}$1${NC}"
}

print_error() {
    echo -e "${RED}${BOLD}✗${NC} ${RED}$1${NC}"
}

prompt_permission() {
    local message="$1"
    echo -e "\n${YELLOW}${BOLD}?${NC} ${WHITE}$message${NC}"
    echo -e "${BLUE}Continue? [Y/n]:${NC} \c"
    read -r response
    case "$response" in
        [nN][oO]|[nN])
            print_warning "Operation cancelled by user"
            exit 0
            ;;
        *)
            return 0
            ;;
    esac
}

cleanup_on_error() {
    print_error "Script failed. Cleaning up..."
    cd "$HOME" 2>/dev/null || true
    rm -rf "$BUILD_DIR" 2>/dev/null || true
    exit 1
}

# Set error trap
trap cleanup_on_error ERR

# Main installation functions
purge_old_installation() {
    print_header "PURGING OLD INSTALLATION"
    
    if [[ -d "$BUILD_DIR" ]]; then
        print_warning "Found existing build directory: $BUILD_DIR"
        prompt_permission "Remove existing build directory and start fresh?"
        
        print_step "Removing old build directory..."
        rm -rf "$BUILD_DIR"
        print_success "Old installation purged"
    else
        print_success "No previous installation found"
    fi
}

update_system() {
    print_header "SYSTEM UPDATE"
    prompt_permission "Update system packages? This may take several minutes."
    
    print_step "Updating package lists..."
    sudo apt update
    
    print_step "Upgrading system packages..."
    sudo apt upgrade -y
    
    print_success "System update completed"
}

install_dependencies() {
    print_header "INSTALLING DEPENDENCIES"
    prompt_permission "Install all required build dependencies? This will install ~50 packages."
    
    print_step "Installing core build tools..."
    sudo apt install -y \
        build-essential \
        cmake \
        meson \
        ninja-build \
        pkg-config \
        git \
        curl \
        wget \
        cppcheck
    
    print_step "Installing Wayland development libraries..."
    sudo apt install -y \
        libwayland-dev \
        wayland-protocols \
        libwayland-client0 \
        libwayland-cursor0 \
        libwayland-egl1 \
        libwayland-server0
    
    print_step "Installing graphics and input libraries..."
    sudo apt install -y \
        libegl1-mesa-dev \
        libgles2-mesa-dev \
        libdrm-dev \
        libgbm-dev \
        libinput-dev \
        libseat-dev \
        libpixman-1-dev \
        libdisplay-info-dev
    
    print_step "Installing X11 compatibility libraries..."
    sudo apt install -y \
        libxkbcommon-dev \
        libxkbcommon-x11-dev \
        libxcb-xkb-dev \
        libxcb-ewmh-dev \
        libxcb-icccm4-dev \
        libxcb-render-util0-dev \
        libxcb-xinput-dev \
        libxcb-dri3-dev \
        libxcb-present-dev \
        libxcb-glx0-dev \
        libxcb-xinerama0-dev \
        libxcb-randr0-dev \
        libxcb-composite0-dev \
        libxcb-res0-dev \
        libxcb-errors-dev \
        libxcb-util-dev \
        libxcb-cursor-dev
    
    print_step "Installing additional required libraries..."
    sudo apt install -y \
        libzip-dev \
        libcairo2-dev \
        librsvg2-dev \
        libtomlplusplus3 \
        hwdata \
        libpango-1.0-0 \
        libpangocairo-1.0-0 \
        libstartup-notification0-dev \
        libfontconfig1-dev \
        libfreetype6-dev \
        libharfbuzz-dev \
        libjpeg-dev \
        libwebp-dev \
        libmagick++-6.q16-dev \
        libhyprlang-dev 2>/dev/null || true
    
    print_success "All dependencies installed successfully"
}

setup_build_environment() {
    print_header "SETTING UP BUILD ENVIRONMENT"
    
    print_step "Creating build directory: $BUILD_DIR"
    mkdir -p "$BUILD_DIR"
    cd "$BUILD_DIR"
    
    print_success "Build environment ready"
}

build_wayland_protocols() {
    print_header "BUILDING WAYLAND-PROTOCOLS"
    prompt_permission "Build wayland-protocols from source?"
    
    print_step "Cloning wayland-protocols repository..."
    git clone --quiet https://gitlab.freedesktop.org/wayland/wayland-protocols.git
    cd wayland-protocols
    
    print_step "Checking out version $WAYLAND_PROTOCOLS_VERSION..."
    git checkout "$WAYLAND_PROTOCOLS_VERSION"
    
    print_step "Configuring build with Meson..."
    meson setup build --prefix=/usr --buildtype=release
    
    print_step "Building wayland-protocols..."
    ninja -C build
    
    print_step "Installing wayland-protocols..."
    sudo ninja -C build install
    
    cd ..
    rm -rf wayland-protocols
    
    print_success "wayland-protocols built and installed"
}

build_hypr_component() {
    local name="$1"
    local repo="$2"
    local build_type="${3:-Release}"
    
    print_header "BUILDING ${name^^}"
    prompt_permission "Build $name from source?"
    
    print_step "Cloning $name repository..."
    git clone --quiet "$repo" "$name"
    cd "$name"
    
    print_step "Configuring $name build..."
    cmake \
        -DCMAKE_BUILD_TYPE="$build_type" \
        -DCMAKE_INSTALL_PREFIX=/usr \
        -DCMAKE_EXPORT_COMPILE_COMMANDS=ON \
        -B ./build
    
    print_step "Building $name (using $PARALLEL_JOBS parallel jobs)..."
    cmake --build ./build --config "$build_type" --target all --parallel "$PARALLEL_JOBS"
    
    print_step "Installing $name..."
    sudo cmake --install ./build
    
    cd ..
    rm -rf "$name"
    
    print_success "$name built and installed successfully"
}

build_hyprland() {
    print_header "BUILDING HYPRLAND"
    prompt_permission "Build Hyprland $HYPRLAND_VERSION from source? This is the final step."
    
    print_step "Cloning Hyprland repository with submodules..."
    git clone --quiet --recursive https://github.com/hyprwm/Hyprland
    cd Hyprland
    
    print_step "Checking out version $HYPRLAND_VERSION..."
    git checkout "$HYPRLAND_VERSION"
    
    print_step "Configuring Hyprland build..."
    cmake \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX=/usr \
        -DCMAKE_CXX_STANDARD=23 \
        -DCMAKE_CXX_STANDARD_REQUIRED=ON \
        -DCMAKE_EXPORT_COMPILE_COMMANDS=ON \
        -DNO_XWAYLAND=OFF \
        -B ./build
    
    print_step "Building Hyprland (this may take 10-15 minutes)..."
    cd build
    make all -j"$PARALLEL_JOBS"
    
    print_step "Installing Hyprland..."
    sudo make install
    
    cd ../..
    
    print_success "Hyprland built and installed successfully"
}

post_installation() {
    print_header "POST-INSTALLATION SETUP"
    
    print_step "Updating library cache..."
    sudo ldconfig
    
    print_step "Creating Hyprland configuration directory..."
    mkdir -p "$HOME/.config/hypr"
    
    if [[ ! -f "$HOME/.config/hypr/hyprland.conf" ]]; then
        print_step "Creating basic Hyprland configuration..."
        cat > "$HOME/.config/hypr/hyprland.conf" << 'EOF'
# Basic Hyprland Configuration
# See https://wiki.hyprland.org/Configuring/Configuring-Hyprland/ for more

monitor=,preferred,auto,auto

exec-once = waybar & hyprpaper & firefox

input {
    kb_layout = gb
    kb_variant = 
    kb_model = 
    kb_options = 
    kb_rules = 

    follow_mouse = 1
    touchpad {
        natural_scroll = no
    }
    sensitivity = 0
}

general {
    gaps_in = 5
    gaps_out = 20
    border_size = 2
    col.active_border = rgba(33ccffee) rgba(00ff99ee) 45deg
    col.inactive_border = rgba(595959aa)
    layout = dwindle
}

decoration {
    rounding = 10
    blur {
        enabled = true
        size = 3
        passes = 1
    }
    drop_shadow = yes
    shadow_range = 4
    shadow_render_power = 3
    col.shadow = rgba(1a1a1aee)
}

animations {
    enabled = yes
    bezier = myBezier, 0.05, 0.9, 0.1, 1.05
    animation = windows, 1, 7, myBezier
    animation = windowsOut, 1, 7, default, popin 80%
    animation = border, 1, 10, default
    animation = borderangle, 1, 8, default
    animation = fade, 1, 7, default
    animation = workspaces, 1, 6, default
}

dwindle {
    pseudotile = yes
    preserve_split = yes
}

master {
    new_is_master = true
}

gestures {
    workspace_swipe = off
}

device:epic-mouse-v1 {
    sensitivity = -0.5
}

# Keybindings
$mainMod = SUPER

bind = $mainMod, Q, exec, kitty
bind = $mainMod, C, killactive, 
bind = $mainMod, M, exit, 
bind = $mainMod, E, exec, dolphin
bind = $mainMod, V, togglefloating, 
bind = $mainMod, R, exec, wofi --show drun
bind = $mainMod, P, pseudo,
bind = $mainMod, J, togglesplit,

# Move focus with mainMod + arrow keys
bind = $mainMod, left, movefocus, l
bind = $mainMod, right, movefocus, r
bind = $mainMod, up, movefocus, u
bind = $mainMod, down, movefocus, d

# Switch workspaces with mainMod + [0-9]
bind = $mainMod, 1, workspace, 1
bind = $mainMod, 2, workspace, 2
bind = $mainMod, 3, workspace, 3
bind = $mainMod, 4, workspace, 4
bind = $mainMod, 5, workspace, 5
bind = $mainMod, 6, workspace, 6
bind = $mainMod, 7, workspace, 7
bind = $mainMod, 8, workspace, 8
bind = $mainMod, 9, workspace, 9
bind = $mainMod, 0, workspace, 10

# Move active window to a workspace with mainMod + SHIFT + [0-9]
bind = $mainMod SHIFT, 1, movetoworkspace, 1
bind = $mainMod SHIFT, 2, movetoworkspace, 2
bind = $mainMod SHIFT, 3, movetoworkspace, 3
bind = $mainMod SHIFT, 4, movetoworkspace, 4
bind = $mainMod SHIFT, 5, movetoworkspace, 5
bind = $mainMod SHIFT, 6, movetoworkspace, 6
bind = $mainMod SHIFT, 7, movetoworkspace, 7
bind = $mainMod SHIFT, 8, movetoworkspace, 8
bind = $mainMod SHIFT, 9, movetoworkspace, 9
bind = $mainMod SHIFT, 0, movetoworkspace, 10

# Scroll through existing workspaces with mainMod + scroll
bind = $mainMod, mouse_down, workspace, e+1
bind = $mainMod, mouse_up, workspace, e-1

# Move/resize windows with mainMod + LMB/RMB and dragging
bindm = $mainMod, mouse:272, movewindow
bindm = $mainMod, mouse:273, resizewindow
EOF
        print_success "Basic configuration file created"
    else
        print_success "Configuration file already exists"
    fi
    
    print_success "Post-installation setup completed"
}

cleanup_build() {
    print_header "CLEANUP"
    prompt_permission "Remove build directory to save disk space? (Recommended)"
    
    cd "$HOME"
    rm -rf "$BUILD_DIR"
    
    print_success "Build directory cleaned up"
}

display_completion_message() {
    print_header "INSTALLATION COMPLETE"
    
    echo -e "${GREEN}${BOLD}✓ Hyprland has been successfully installed!${NC}\n"
    
    echo -e "${WHITE}${BOLD}Next Steps:${NC}"
    echo -e "${CYAN}1.${NC} Install a terminal emulator:"
    echo -e "   ${YELLOW}sudo apt install kitty${NC} or ${YELLOW}sudo apt install alacritty${NC}"
    
    echo -e "${CYAN}2.${NC} Install a launcher:"
    echo -e "   ${YELLOW}sudo apt install wofi${NC} or ${YELLOW}sudo apt install rofi-wayland${NC}"
    
    echo -e "${CYAN}3.${NC} Install additional tools (optional):"
    echo -e "   ${YELLOW}sudo apt install waybar hyprpaper dunst${NC}"
    
    echo -e "${CYAN}4.${NC} Start Hyprland:"
    echo -e "   ${YELLOW}Hyprland${NC} (from a TTY session)"
    
    echo -e "\n${WHITE}${BOLD}Configuration:${NC}"
    echo -e "Configuration file: ${YELLOW}~/.config/hypr/hyprland.conf${NC}"
    echo -e "Wiki: ${BLUE}https://wiki.hyprland.org/${NC}"
    
    echo -e "\n${GREEN}${BOLD}Installation completed successfully!${NC}"
}

# Main execution flow
main() {
    print_header "HYPRLAND COMPLETE INSTALLATION SCRIPT"
    echo -e "${WHITE}This script will install Hyprland and all dependencies from source.${NC}"
    echo -e "${WHITE}You will be prompted before each major step.${NC}\n"
    
    prompt_permission "Begin Hyprland installation?"
    
    purge_old_installation
    update_system
    install_dependencies
    setup_build_environment
    
    build_wayland_protocols
    build_hypr_component "hyprutils" "https://github.com/hyprwm/hyprutils.git"
    build_hypr_component "hyprwayland-scanner" "https://github.com/hyprwm/hyprwayland-scanner.git"
    build_hypr_component "hyprlang" "https://github.com/hyprwm/hyprlang.git"
    build_hypr_component "hyprcursor" "https://github.com/hyprwm/hyprcursor.git"
    build_hypr_component "hyprgraphics" "https://github.com/hyprwm/hyprgraphics.git"
    build_hypr_component "aquamarine" "https://github.com/hyprwm/aquamarine.git"
    
    build_hyprland
    post_installation
    cleanup_build
    display_completion_message
}

# Execute main function
main "$@"

