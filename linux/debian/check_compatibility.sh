#!/usr/bin/env bash
set -uo pipefail
IFS=$'\n\t'

echo "🔍 PopOS/Debian Compatibility Check"
echo "=================================="

# Check if running on supported distribution
check_distribution() {
    echo "📋 Checking Linux distribution..."

    if [[ -f /etc/os-release ]]; then
        # Safely read os-release without sourcing
        NAME=$(grep '^NAME=' /etc/os-release | cut -d= -f2 | tr -d '"')
        VERSION=$(grep '^VERSION=' /etc/os-release | cut -d= -f2 | tr -d '"')
        ID=$(grep '^ID=' /etc/os-release | cut -d= -f2 | tr -d '"')

        echo "   Distribution: $NAME"
        echo "   Version: $VERSION"

        case "$ID" in
            "pop")
                echo "   ✅ PopOS detected - Fully supported"
                ;;
            "ubuntu")
                echo "   ✅ Ubuntu detected - Supported (Debian-based)"
                ;;
            "debian")
                echo "   ✅ Debian detected - Supported"
                ;;
            *)
                echo "   ⚠️  Distribution '$ID' not explicitly tested"
                echo "   ℹ️  Script may work on Debian-based distributions"
                ;;
        esac
    else
        echo "   ❌ Cannot determine distribution"
        return 1
    fi
}

# Check for required commands
check_required_commands() {
    echo ""
    echo "🔧 Checking required commands..."

    local missing_commands=()

    # Essential commands
    for cmd in "curl" "wget" "apt"; do
        if ! command -v "$cmd" &> /dev/null; then
            missing_commands+=("$cmd")
            echo "   ❌ $cmd - Missing"
        else
            echo "   ✅ $cmd - Available"
        fi
    done

    if [[ ${#missing_commands[@]} -gt 0 ]]; then
        echo ""
        echo "❌ Missing required commands: ${missing_commands[*]}"
        echo "   Please install them first with:"
        echo "   sudo apt update && sudo apt install -y -qq ${missing_commands[*]}"
        return 1
    fi
}

# Check internet connectivity
check_connectivity() {
    echo ""
    echo "🌐 Checking internet connectivity..."

    if curl -s --max-time 5 https://github.com &> /dev/null; then
        echo "   ✅ Internet connection working"
    else
        echo "   ❌ No internet connection"
        echo "   ℹ️  Internet required for package downloads"
        return 1
    fi
}

# Main compatibility check
main() {
    local exit_code=0

    check_distribution || exit_code=1
    check_required_commands || exit_code=1
    check_connectivity || exit_code=1

    echo ""
    if [[ $exit_code -eq 0 ]]; then
        echo "✅ System compatibility check passed!"
        echo "🚀 Ready to run bootstrap script"
    else
        echo "❌ Compatibility issues found"
        echo "🔧 Please resolve the issues above before continuing"
    fi

    return $exit_code
}

# Run the check
main "$@"
