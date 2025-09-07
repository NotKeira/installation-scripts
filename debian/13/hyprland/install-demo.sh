#!/bin/bash

# Hyprland Complete Installation Script - DEMO MODE
# This version simulates the installation process without executing actual commands

# Demo mode flag
readonly DEMO_MODE=true

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

# Demo timing configuration
readonly QUICK_DELAY=0.5
readonly MEDIUM_DELAY=1.5
readonly LONG_DELAY=3.0
readonly BUILD_DELAY=5.0

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

print_demo_notice() {
    echo -e "${YELLOW}${BOLD}[DEMO]${NC} ${CYAN}$1${NC}"
}

simulate_progress() {
    local duration="$1"
    local message="$2"
    local steps=20
    local step_duration=$(echo "scale=2; $duration / $steps" | bc -l 2>/dev/null || echo "0.1")
    
    echo -e "${BLUE}$message${NC}"
    printf "["
    
    for ((i=1; i<=steps; i++)); do
        sleep "$step_duration"
        printf "█"
    done
    
    printf "] 100%%\n"
}

fake_sleep() {
    local delay="$1"
    sleep "$delay"
}

prompt_permission() {
    local message="$1"
    echo -e "\n${YELLOW}${BOLD}?${NC} ${WHITE}$message${NC}"
    echo -e "${BLUE}Continue? [Y/n]:${NC} \c"
    
    if [[ "$DEMO_MODE" == true ]]; then
        fake_sleep "$QUICK_DELAY"
        echo "Y"
        print_demo_notice "Auto-accepted in demo mode"
    else
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
    fi
}

fake_command() {
    local command="$1"
    local duration="${2:-$MEDIUM_DELAY}"
    local show_output="${3:-false}"
    
    print_demo_notice "Executing: $command"
    
    if [[ "$show_output" == "true" ]]; then
        simulate_progress "$duration" "Processing..."
    else
        fake_sleep "$duration"
    fi
}

fake_git_clone() {
    local repo="$1"
    local target="${2:-$(basename "$repo" .git)}"
    
    print_demo_notice "git clone $repo $target"
    simulate_progress 2.0 "Cloning repository..."
    fake_sleep "$QUICK_DELAY"
    print_success "Repository cloned successfully"
}

fake_build_process() {
    local project="$1"
    local duration="$2"
    
    print_demo_notice "Starting build process for $project"
    simulate_progress "$duration" "Compiling source code..."
    fake_sleep "$QUICK_DELAY"
    print_success "Build completed successfully"
}

# Main installation functions
purge_old_installation() {
    print_header "PURGING OLD INSTALLATION"
    
    print_demo_notice "Checking for existing installation..."
    fake_sleep "$QUICK_DELAY"
    
    if [[ -d "$BUILD_DIR" ]] || [[ "$DEMO_MODE" == true ]]; then
        print_warning "Found existing build directory: $BUILD_DIR"
        prompt_permission "Remove existing build directory and start fresh?"
        
        print_step "Removing old build directory..."
        fake_command "rm -rf $BUILD_DIR" "$MEDIUM_DELAY"
        print_success "Old installation purged"
    else
        print_success "No previous installation found"
    fi
}

update_system() {
    print_header "SYSTEM UPDATE"
    prompt_permission "Update system packages? This may take several minutes."
    
    print_step "Updating package lists..."
    fake_command "sudo apt update" "$MEDIUM_DELAY" true
    
    print_step "Upgrading system packages..."
    fake_command "sudo apt upgrade -y" "$BUILD_DELAY" true
    
    print_success "System update completed"
}

install_dependencies() {
    print_header "INSTALLING DEPENDENCIES"
    prompt_permission "Install all required build dependencies? This will install ~50 packages."
    
    local package_groups=(
        "core build tools"
        "Wayland development libraries" 
        "graphics and input libraries"
        "X11 compatibility libraries"
        "additional required libraries"
    )
    
    for group in "${package_groups[@]}"; do
        print_step "Installing $group..."
        fake_command "sudo apt install -y [packages]" "$LONG_DELAY" true
        fake_sleep "$QUICK_DELAY"
    done
    
    print_success "All dependencies installed successfully"
}

setup_build_environment() {
    print_header "SETTING UP BUILD ENVIRONMENT"
    
    print_step "Creating build directory: $BUILD_DIR"
    fake_command "mkdir -p $BUILD_DIR" "$QUICK_DELAY"
    
    print_step "Changing to build directory..."
    fake_command "cd $BUILD_DIR" "$QUICK_DELAY"
    
    print_success "Build environment ready"
}

build_wayland_protocols() {
    print_header "BUILDING WAYLAND-PROTOCOLS"
    prompt_permission "Build wayland-protocols from source?"
    
    print_step "Cloning wayland-protocols repository..."
    fake_git_clone "https://gitlab.freedesktop.org/wayland/wayland-protocols.git"
    
    print_step "Checking out version $WAYLAND_PROTOCOLS_VERSION..."
    fake_command "git checkout $WAYLAND_PROTOCOLS_VERSION" "$QUICK_DELAY"
    
    print_step "Configuring build with Meson..."
    fake_command "meson setup build --prefix=/usr --buildtype=release" "$MEDIUM_DELAY"
    
    print_step "Building wayland-protocols..."
    fake_build_process "wayland-protocols" "$LONG_DELAY"
    
    print_step "Installing wayland-protocols..."
    fake_command "sudo ninja -C build install" "$MEDIUM_DELAY"
    
    print_step "Cleaning up..."
    fake_command "rm -rf wayland-protocols" "$QUICK_DELAY"
    
    print_success "wayland-protocols built and installed"
}

build_hypr_component() {
    local name="$1"
    local repo="$2"
    local build_type="${3:-Release}"
    local build_duration="${4:-$LONG_DELAY}"
    
    print_header "BUILDING ${name^^}"
    prompt_permission "Build $name from source?"
    
    print_step "Cloning $name repository..."
    fake_git_clone "$repo" "$name"
    
    print_step "Configuring $name build..."
    fake_command "cmake -DCMAKE_BUILD_TYPE=$build_type -DCMAKE_INSTALL_PREFIX=/usr -B ./build" "$MEDIUM_DELAY"
    
    print_step "Building $name (using $PARALLEL_JOBS parallel jobs)..."
    fake_build_process "$name" "$build_duration"
    
    print_step "Installing $name..."
    fake_command "sudo cmake --install ./build" "$MEDIUM_DELAY"
    
    print_step "Cleaning up $name build..."
    fake_command "rm -rf $name" "$QUICK_DELAY"
    
    print_success "$name built and installed successfully"
}

build_hyprland() {
    print_header "BUILDING HYPRLAND"
    prompt_permission "Build Hyprland $HYPRLAND_VERSION from source? This is the final step."
    
    print_step "Cloning Hyprland repository with submodules..."
    fake_git_clone "https://github.com/hyprwm/Hyprland" "Hyprland"
    print_demo_notice "Initialising submodules..."
    fake_sleep "$MEDIUM_DELAY"
    
    print_step "Checking out version $HYPRLAND_VERSION..."
    fake_command "git checkout $HYPRLAND_VERSION" "$QUICK_DELAY"
    
    print_step "Configuring Hyprland build..."
    fake_command "cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_CXX_STANDARD=23 -B ./build" "$MEDIUM_DELAY"
    
    print_step "Building Hyprland (this may take 10-15 minutes)..."
    print_demo_notice "This is the most intensive build step"
    fake_build_process "Hyprland" 8.0
    
    print_step "Installing Hyprland..."
    fake_command "sudo make install" "$MEDIUM_DELAY"
    
    print_success "Hyprland built and installed successfully"
}

post_installation() {
    print_header "POST-INSTALLATION SETUP"
    
    print_step "Updating library cache..."
    fake_command "sudo ldconfig" "$QUICK_DELAY"
    
    print_step "Creating Hyprland configuration directory..."
    fake_command "mkdir -p $HOME/.config/hypr" "$QUICK_DELAY"
    
    print_step "Creating basic Hyprland configuration..."
    fake_command "cat > $HOME/.config/hypr/hyprland.conf << 'EOF'" "$MEDIUM_DELAY"
    print_demo_notice "Writing default configuration file..."
    fake_sleep "$MEDIUM_DELAY"
    print_success "Basic configuration file created"
    
    print_success "Post-installation setup completed"
}

cleanup_build() {
    print_header "CLEANUP"
    prompt_permission "Remove build directory to save disk space? (Recommended)"
    
    print_step "Removing build directory..."
    fake_command "rm -rf $BUILD_DIR" "$MEDIUM_DELAY"
    
    print_success "Build directory cleaned up"
}

display_completion_message() {
    print_header "INSTALLATION COMPLETE"
    
    echo -e "${GREEN}${BOLD}✓ Hyprland has been successfully installed!${NC}\n"
    
    if [[ "$DEMO_MODE" == true ]]; then
        print_demo_notice "This was a demonstration - no actual installation occurred"
        echo ""
    fi
    
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
    
    if [[ "$DEMO_MODE" == true ]]; then
        echo -e "\n${YELLOW}${BOLD}[DEMO MODE]${NC} ${GREEN}Demonstration completed successfully!${NC}"
        echo -e "${CYAN}To run the actual installation, use the production version of this script.${NC}"
    else
        echo -e "\n${GREEN}${BOLD}Installation completed successfully!${NC}"
    fi
}

# Main execution flow
main() {
    print_header "HYPRLAND COMPLETE INSTALLATION SCRIPT"
    
    if [[ "$DEMO_MODE" == true ]]; then
        print_demo_notice "Running in demonstration mode - no actual commands will be executed"
        echo ""
    fi
    
    echo -e "${WHITE}This script will install Hyprland and all dependencies from source.${NC}"
    echo -e "${WHITE}You will be prompted before each major step.${NC}\n"
    
    prompt_permission "Begin Hyprland installation?"
    
    purge_old_installation
    update_system
    install_dependencies
    setup_build_environment
    
    build_wayland_protocols
    build_hypr_component "hyprutils" "https://github.com/hyprwm/hyprutils.git" "Release" "$LONG_DELAY"
    build_hypr_component "hyprwayland-scanner" "https://github.com/hyprwm/hyprwayland-scanner.git" "Release" "$MEDIUM_DELAY"
    build_hypr_component "hyprlang" "https://github.com/hyprwm/hyprlang.git" "Release" "$LONG_DELAY"
    build_hypr_component "hyprcursor" "https://github.com/hyprwm/hyprcursor.git" "Release" "$MEDIUM_DELAY"
    build_hypr_component "hyprgraphics" "https://github.com/hyprwm/hyprgraphics.git" "Release" "$MEDIUM_DELAY"
    build_hypr_component "aquamarine" "https://github.com/hyprwm/aquamarine.git" "Release" "$LONG_DELAY"
    
    build_hyprland
    post_installation
    cleanup_build
    display_completion_message
}

# Execute main function
main "$@"

