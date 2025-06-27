# .idx/dev.nix
#
# WHAT: This file defines the development environment for the SyncFreeBusy project.
# WHY:  It ensures that every developer has the exact same set of tools and dependencies,
#       guaranteeing a consistent and reproducible development experience. It is used
#       by Nix and development environments like Firebase Studio (Project IDX).

{ pkgs, ... }: {
  # Pin to a specific Nixpkgs channel for reproducibility.
  channel = "stable-25.05";

  # The 'pkgs' block defines system-level packages available in your workspace.
  packages = with pkgs; [
    # --- Project Automation ---
    # The primary tool for running all project commands defined in Taskfile.yml.
    go-task

    # A tool for creating beautiful, interactive command-line scripts and menus.
    # Useful for any scripts we add to the `factory/scripts` directory.
    gum

    # --- Apps Script & JavaScript Development ---
    # A recent LTS version of Node.js, essential for clasp, eslint, etc.
    nodejs_20

    # --- Code Quality & Linting ---
    # A static analysis tool for shell scripts to find bugs and potential issues.
    shellcheck

    # An auto-formatter for shell scripts to ensure consistent style.
    shfmt

    # A linter to check Markdown files for style and consistency.
    nodePackages.markdownlint-cli

    # --- Version Control & GitHub Integration ---
    # The distributed version control system.
    git

    # The official GitHub CLI for interacting with GitHub repositories.
    gh

    # --- Utilities & Data Processing ---
    # A command-line JSON processor. Essential for scripting with JSON outputs
    # from tools like clasp.
    jq

    # A command-line YAML/JSON processor. Useful for scripting around Taskfile.yml
    # and other YAML configuration.
    yq-go

    # A utility to display directory and file structures in a tree-like format.
    tree

    # A utility to determine the type of a file, often a dependency for other tools.
    file

    # --- Legacy/Optional Dependencies from Previous Project ---
    # The Go language toolchain. Required if you intend to use or develop
    # custom Go-based tooling like the 'contextvibes' CLI mentioned below.
    go

    # A command-line tool for downloading files. Required by the legacy
    # 'thea-manifest.json' fetching script below.
    wget
  ];

  # The 'env' block sets environment variables for the entire workspace.
  env = {
    # Example: MY_GLOBAL_VAR = "some_value";
  };

  # IDX-specific settings
  idx = {
    # VS Code extensions that will be automatically installed in the workspace.
    extensions = [
      # For JavaScript/Apps Script linting.
      "dbaeumer.vscode-eslint"
      # For automatic code formatting.
      "esbenp.prettier-vscode"
      # For managing pull requests and issues directly within the editor.
      "GitHub.vscode-pull-request-github"
    ];

    # Configuration for web previews. Not needed for this Apps Script project.
    previews = {
      enable = false;
    };

    # Workspace lifecycle hooks
    workspace = {
      # Runs only ONCE when the workspace is first created.
      onCreate = {
        # Installs the Google Apps Script CLI (clasp) using npx. This ensures
        # a specific version is used without polluting the global environment.
        install-clasp = "echo 'Installing @google/clasp globally using npx...'; npx -y @google/clasp";

        # --- Optional: Inherited from previous project ---
        # This block installs the 'contextvibes' CLI. If you do not need this
        # tool for the SyncFreeBusy project, you can safely delete this block.
        install-contextvibes-cli = ''
          echo "⏳ (Optional) Installing contextvibes CLI into ./bin..."
          LOCAL_BIN_DIR="$(pwd)/bin"
          mkdir -p "$LOCAL_BIN_DIR"
          if GOBIN="$LOCAL_BIN_DIR" go install github.com/contextvibes/cli/cmd/contextvibes@latest; then
            echo "✅ Successfully installed contextvibes to $LOCAL_BIN_DIR"
          else
            echo "❌ ERROR: Failed to install contextvibes."
          fi
        '';
      };

      # Runs EVERY TIME the workspace starts.
      onStart = {
        startup-script = ''
          echo "-----------------------------------------------------"
          echo "🚀 SyncFreeBusy Workspace Initializing..."
          echo "-----------------------------------------------------"
          
          echo "[1/3] 👋 Welcome back! Checking tool versions..."
          if command -v go &> /dev/null; then echo "Go version: $(go version)"; fi
          if command -v node &> /dev/null; then echo "Node version: $(node --version)"; fi
          if command -v clasp &> /dev/null; then echo "Clasp version: $(clasp --version)"; fi
          if command -v task &> /dev/null; then echo "Task version: $(task --version)"; fi
          echo "-----------------------------------------------------"

          echo "[2/3] 🔧 Adding local ./bin to PATH for any custom CLIs..."
          LOCAL_CLI_BIN_DIR="$(pwd)/bin"
          if [[ ":$PATH:" != *":$LOCAL_CLI_BIN_DIR:"* ]]; then
            if [ -d "$LOCAL_CLI_BIN_DIR" ]; then
              export PATH="$LOCAL_CLI_BIN_DIR:$PATH"
              echo "✔️  Local ./bin directory added to PATH."
            fi
          else
            echo "✔️  Local ./bin directory already in PATH."
          fi
          
          echo "-----------------------------------------------------"
          echo "[3/3] 🎉 Workspace setup complete!"
          echo "-----------------------------------------------------"

          # --- NOTE: The 'thea-manifest.json' fetch script from the original
          # --- project has been removed from this startup sequence.
          # --- If you need similar functionality, you can add it back here.
        '';
      };
    };
  };
}
