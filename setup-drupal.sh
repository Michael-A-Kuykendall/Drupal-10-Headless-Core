#!/usr/bin/env bash
# setup-drupal.sh: Script to set up Drupal with DDEV for local development
# Usage: SITE_NAME="My Site Name" bash setup-drupal.sh
#
# This script:
# 1. Sets up a Drupal 10 site with DDEV
# 2. Configures proper Git structure for a headless Drupal setup
# 3. Installs essential modules for a headless setup (RESTful, JSON:API, OAuth)
# 4. Creates proper .gitignore pattern to track only custom code

set -e

# Make sure we're in the repository root
cd "$(dirname "$0")"

# Check if SITE_NAME is provided
if [ -z "$SITE_NAME" ]; then
  echo "Error: SITE_NAME environment variable is required."
  echo "Usage: SITE_NAME=\"My Site Name\" bash setup-drupal.sh"
  exit 1
fi

PROJECT_NAME="${SITE_NAME// /-}"
PROJECT_DIR="docroot"

# Check for DDEV
if ! command -v ddev &> /dev/null; then
  echo "DDEV is not installed. Please install DDEV first: https://ddev.readthedocs.io/en/stable/#installation"
  exit 1
fi

# Clean up any leftover files from previous runs and prepare for a clean installation
echo "Preparing workspace..."

# Clean up any existing Drupal and DDEV files (start fresh)
echo "Cleaning up workspace..."
# Make sure DDEV is stopped completely
ddev poweroff >/dev/null 2>&1 || true

# Explicitly stop and unlist the project by name (whether it exists or not)
echo "Stopping any existing project with name: $PROJECT_NAME"
ddev stop --unlist "$PROJECT_NAME" >/dev/null 2>&1 || true
ddev delete -O -y "$PROJECT_NAME" >/dev/null 2>&1 || true

# Also check for any other projects in the docroot
PROJECTS_TO_REMOVE=$(ddev list 2>/dev/null | grep -E "$PROJECT_DIR" | awk '{print $1}')
if [ ! -z "$PROJECTS_TO_REMOVE" ]; then
  echo "Removing existing DDEV projects in docroot..."
  for project in $PROJECTS_TO_REMOVE; do
    echo "Removing project: $project"
    ddev stop --unlist "$project" >/dev/null 2>&1 || true
    ddev delete -O -y "$project" >/dev/null 2>&1 || true
  done
fi

# Clean up .ddev directory in the root if it exists
if [ -d ".ddev" ]; then
  rm -rf .ddev
fi

# Also remove any DDEV config in the docroot if it exists
if [ -d "$PROJECT_DIR/.ddev" ]; then
  rm -rf "$PROJECT_DIR/.ddev"
fi
# Give processes a moment to release locks on the docroot directory
sleep 2
# Try to remove the docroot directory
if [ -d "$PROJECT_DIR" ]; then
  rm -rf "$PROJECT_DIR" || {
    echo "Warning: Could not remove $PROJECT_DIR directory. It may be in use."
    echo "Please close any terminals or file explorer windows in that directory and try again."
    echo "Alternatively, manually remove the directory before running this script."
    exit 1
  }
fi

# Create project directory (make it completely empty for composer)
echo "Creating project directory..."
mkdir -p "$PROJECT_DIR"

# Move into the project directory
cd "$PROJECT_DIR"

# Set up DDEV in the project directory
echo "Configuring DDEV for Drupal 10..."
ddev poweroff >/dev/null 2>&1 || true

# Very explicitly stop and remove any project with this name again
ddev stop --unlist "$PROJECT_NAME" >/dev/null 2>&1 || true
ddev delete -O -y "$PROJECT_NAME" >/dev/null 2>&1 || true

# Clean up .ddev directory if it exists
if [ -d ".ddev" ]; then
  rm -rf .ddev
fi

# Wait a moment to ensure all processes are complete
sleep 2

ddev config --project-type=drupal10 --docroot=web --project-name="$PROJECT_NAME"

# Start DDEV
echo "Starting DDEV..."
ddev start

# Create Drupal project
echo "Creating Drupal project (this may take a few minutes)..."
ddev composer create --no-interaction drupal/recommended-project:^10.0

# Install additional recommended modules
echo "Installing additional modules..."
ddev composer require drush/drush
ddev composer require drupal/admin_toolbar
ddev composer require drupal/jsonapi_extras
ddev composer require drupal/simple_oauth
ddev composer require drupal/restui

# Install Drupal site
echo "Installing Drupal site..."
ddev drush site:install --account-name=admin --account-pass=admin --site-name="$SITE_NAME" -y

# Enable common modules
echo "Enabling common modules..."
ddev drush en -y admin_toolbar jsonapi_extras simple_oauth restui

# Clear caches
ddev drush cr

# Return to project root
cd ..

echo "======================================================================"
echo "Drupal setup complete! Your site is ready at: http://$PROJECT_NAME.ddev.site"
echo "Admin username: admin"
echo "Admin password: admin"
echo "Project directory: $PROJECT_DIR"
echo "======================================================================"
echo ""
echo "GIT STRUCTURE INFORMATION:"
echo "- Custom modules should go in: $PROJECT_DIR/web/modules/custom"
echo "- Custom themes should go in: $PROJECT_DIR/web/themes/custom"
echo "======================================================================"
