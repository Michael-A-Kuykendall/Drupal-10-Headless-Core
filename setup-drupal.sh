#!/usr/bin/env bash
# setup-drupal.sh: Script to set up Drupal with DDEV for local development
# Usage: bash setup-drupal.sh

set -e

cd "$(dirname "$0")"

# Check for DDEV
if ! command -v ddev &> /dev/null; then
  echo "DDEV is not installed. Please install DDEV first: https://ddev.readthedocs.io/en/stable/#installation"
  exit 1
fi

cd drupal

# Initialize DDEV if not already configured
if [ ! -f ".ddev/config.yaml" ]; then
  ddev config --project-type=drupal10 --docroot=web --create-docroot --project-name=rootedinstrength
fi

# Start DDEV
ddev start

# Create Drupal project if composer.json is missing
if [ ! -f "composer.json" ]; then
  echo "No composer.json found, creating Drupal project..."
  ddev composer create "drupal/recommended-project:~10.0" .
fi

# Install Composer dependencies if composer.json exists
if [ -f "composer.json" ]; then
  echo "Installing Composer dependencies..."
  ddev composer install
else
  echo "composer.json still missing after create-project. Exiting."
  exit 1
fi

# Install Drupal site if settings.php is missing
if [ ! -f "web/sites/default/settings.php" ]; then
  ddev drush site:install --account-name=admin --account-pass=admin --site-name="Rooted In Strength"
fi

echo "Drupal setup complete! Access your site at: http://rootedinstrength.ddev.site"
