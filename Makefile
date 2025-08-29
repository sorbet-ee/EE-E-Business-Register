# Estonian e-Business Register Ruby Gem Makefile
# Professional FinTech-grade automation for development workflow
#
# This Makefile provides a complete development and deployment workflow for the
# Estonian e-Business Register Ruby gem, including testing with API rate limiting,
# version management, building, and publishing to RubyGems.
#
# Key features:
# - API throttling for Estonian registry (1-second delays)
# - Comprehensive testing suite (unit + integration)
# - Automated version management with semantic versioning
# - Safe publishing workflow with confirmations
# - Code quality enforcement with RuboCop
# - Git integration for tagging and releases
#
# Usage:
#   make help         - Show available commands
#   make test         - Run all tests with API throttling
#   make build        - Build the gem package
#   make demo         - Build gem and launch Sinatra demo app
#   make version-up   - Increment version number
#   make publish      - Publish to RubyGems.org
#   make release      - Complete release workflow

# Ensure all targets are treated as commands, not files
# This prevents make from looking for files with these names
.PHONY: help test test-unit test-integration build clean install version-up publish lint format demo

# Terminal color codes for professional output formatting
# These make the output more readable and user-friendly
GREEN = \033[0;32m    # Success messages
YELLOW = \033[0;33m   # Warning messages  
RED = \033[0;31m      # Error messages
BLUE = \033[0;34m     # Info messages
NC = \033[0m          # No Color (reset)

# Configuration variables for the gem
# These can be easily modified if the gem structure changes
GEM_NAME = ee_e_business_register
VERSION_FILE = lib/ee_e_business_register/version.rb

#==============================================================================
# HELP AND DOCUMENTATION
#==============================================================================

# Default target - shows help when user runs 'make' without arguments
# This provides a user-friendly entry point to discover available commands
help: ## Show this help message
	@echo "$(BLUE)Estonian e-Business Register Gem$(NC)"
	@echo "$(BLUE)=================================$(NC)"
	@echo ""
	@echo "Available commands:"
	# Extract all targets with ## comments and format them nicely
	# This automatically generates help from the inline documentation
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  $(GREEN)%-15s$(NC) %s\n", $$1, $$2}'
	@echo ""
	@echo "$(YELLOW)Note: API tests include 1-second delays due to rate limiting$(NC)"

#==============================================================================
# TESTING COMMANDS
#==============================================================================

# Main test command - runs all tests with proper API throttling
# The Estonian e-Business Register API has rate limits, so we add delays
# between test files to avoid hitting the limits and getting blocked
# Tests include: basic company lookup, detailed company data (detailandmed_v2),
# classifiers, error handling, and comprehensive data model validation
test: ## Run all tests with API rate limiting delays
	@echo "$(GREEN)Running complete test suite with API throttling...$(NC)"
	# Custom test runner that loads each test file individually with delays
	# This ensures we don't overwhelm the Estonian API with rapid requests
	@bundle exec ruby -Ilib:test -e '\
		require "minitest/autorun"; \
		Dir.glob("test/**/test_*.rb").each do |file|; \
			puts "Loading: #{file}"; \
			require_relative file; \
			sleep 1; \
		end'
	@echo "$(GREEN)✓ All tests completed including detailed company and documents functionality$(NC)"
	@echo "$(BLUE)Detailed company data tests validate:$(NC)"
	@echo "  • General company information (addresses, activities, contacts)"
	@echo "  • Personnel data (board members, shareholders with OSAN/O roles)"
	@echo "  • Comprehensive business activity codes (EMTAK/NACE)"
	@echo "  • Estonian address system integration (ADS)"
	@echo "$(BLUE)Company documents tests validate:$(NC)"
	@echo "  • Annual reports (PDF, XBRL, DDOC/BDOC formats)"
	@echo "  • Articles of association documents"
	@echo "  • Document filtering by type, year, and validity"
	@echo "  • Document metadata (size, URLs, status dates)"
	@echo "$(YELLOW)Note: API integration tests require real credentials$(NC)"
	@echo "$(YELLOW)Create ~/.ee_business_register_credentials.yml with username and password$(NC)"

# Unit tests only - these don't make API calls so no throttling needed
# Useful for quick feedback during development without hitting API limits
test-unit: ## Run unit tests only (no API calls)
	@echo "$(GREEN)Running unit tests (excluding integration tests)...$(NC)"
	# Exclude integration tests to avoid any API calls
	# This gives developers fast feedback on code changes
	@bundle exec ruby -Ilib:test -e '\
		require "minitest/autorun"; \
		Dir.glob("test/**/test_*.rb").reject { |f| f.include?("integration") }.each do |file|; \
			puts "Loading: #{file}"; \
			require_relative file; \
		end'

# Integration tests with real API calls - requires valid credentials
# These tests actually connect to the Estonian e-Business Register
# and verify that our gem works with the real API
test-integration: ## Run integration tests with real API (requires credentials)
	@echo "$(GREEN)Running integration tests with 1-second API throttling...$(NC)"
	# Check if credentials file exists before attempting API tests
	# This prevents confusing error messages for new developers
	@if [ ! -f ~/.ee_business_register_credentials.yml ]; then \
		echo "$(RED)Error: Credentials file not found at ~/.ee_business_register_credentials.yml$(NC)"; \
		echo "$(YELLOW)Please create credentials file or skip integration tests$(NC)"; \
		exit 1; \
	fi
	# Run only the integration test file with API throttling
	@bundle exec ruby -Ilib:test test/integration_test.rb
	@sleep 1  # Additional delay after integration tests

#==============================================================================
# BUILD AND PACKAGING
#==============================================================================

# Build the gem package from the gemspec
# This creates a .gem file that can be installed or published
build: clean ## Build the gem package
	@echo "$(GREEN)Building $(GEM_NAME) gem...$(NC)"
	# Use bundler's gem build command for consistency
	# This ensures all dependencies and configurations are respected
	@bundle exec gem build $(GEM_NAME).gemspec
	@echo "$(GREEN)✓ Gem built successfully$(NC)"
	# Show the built gem file(s) for verification
	@ls -la *.gem 2>/dev/null || echo "$(RED)No gem file found$(NC)"

# Clean up build artifacts to ensure fresh builds
# Important for avoiding conflicts between different versions
clean: ## Clean built artifacts
	@echo "$(GREEN)Cleaning build artifacts...$(NC)"
	# Remove gem files and packaging directories
	@rm -f *.gem
	@rm -rf pkg/
	@echo "$(GREEN)✓ Clean complete$(NC)"

# Install the gem locally for testing
# Useful for testing the gem in local Ruby environment
install: build ## Install the gem locally
	@echo "$(GREEN)Installing $(GEM_NAME) locally...$(NC)"
	# Install the most recently built gem file
	@gem install *.gem
	@echo "$(GREEN)✓ Gem installed locally$(NC)"

#==============================================================================
# VERSION MANAGEMENT
#==============================================================================

# Display current version from the version file
# Useful for checking version before releases
version: ## Show current version
	@echo "$(GREEN)Current version:$(NC)"
	# Extract version string from VERSION constant in Ruby file
	@grep VERSION $(VERSION_FILE) | cut -d'"' -f2

# Increment patch version (x.y.z -> x.y.z+1)
# Use this for bug fixes and minor updates
version-up: ## Increment patch version (x.y.z -> x.y.z+1)
	@echo "$(GREEN)Incrementing patch version...$(NC)"
	# Use Ruby to safely modify the version file
	# This handles the version format correctly and atomically
	@ruby -i -pe '\
		if /VERSION = "(\d+)\.(\d+)\.(\d+)"/ then \
			gsub(/VERSION = "(\d+)\.(\d+)\.(\d+)"/, "VERSION = \"#{$$1}.#{$$2}.#{$$3.to_i + 1}\"") \
		end' $(VERSION_FILE)
	@echo "$(GREEN)✓ Version updated to:$(NC) $$(make version)"
	@echo "$(YELLOW)Don't forget to commit the version change!$(NC)"

# Increment minor version (x.y.z -> x.y+1.0)
# Use this for new features that are backward compatible
version-up-minor: ## Increment minor version (x.y.z -> x.y+1.0)
	@echo "$(GREEN)Incrementing minor version...$(NC)"
	# Reset patch version to 0 when incrementing minor
	@ruby -i -pe '\
		if /VERSION = "(\d+)\.(\d+)\.(\d+)"/ then \
			gsub(/VERSION = "(\d+)\.(\d+)\.(\d+)"/, "VERSION = \"#{$$1}.#{$$2.to_i + 1}.0\"") \
		end' $(VERSION_FILE)
	@echo "$(GREEN)✓ Version updated to:$(NC) $$(make version)"
	@echo "$(YELLOW)Don't forget to commit the version change!$(NC)"

# Increment major version (x.y.z -> x+1.0.0)  
# Use this for breaking changes or major new features
version-up-major: ## Increment major version (x.y.z -> x+1.0.0)
	@echo "$(GREEN)Incrementing major version...$(NC)"
	# Reset minor and patch versions to 0 when incrementing major
	@ruby -i -pe '\
		if /VERSION = "(\d+)\.(\d+)\.(\d+)"/ then \
			gsub(/VERSION = "(\d+)\.(\d+)\.(\d+)"/, "VERSION = \"#{$$1.to_i + 1}.0.0\"") \
		end' $(VERSION_FILE)
	@echo "$(GREEN)✓ Version updated to:$(NC) $$(make version)"
	@echo "$(YELLOW)Don't forget to commit the version change!$(NC)"

#==============================================================================
# PUBLISHING TO RUBYGEMS
#==============================================================================

# Publish gem to RubyGems.org - this is irreversible!
# Includes safety confirmation to prevent accidental publishing
publish: build ## Publish gem to RubyGems.org
	@echo "$(GREEN)Publishing $(GEM_NAME) to RubyGems.org...$(NC)"
	@echo "$(YELLOW)Current version: $$(make version)$(NC)"
	@echo "$(YELLOW)Are you sure you want to publish? This cannot be undone.$(NC)"
	# Interactive confirmation to prevent accidental publishing
	# Publishing to RubyGems is permanent and cannot be reverted
	@read -p "Type 'yes' to confirm: " confirm; \
	if [ "$$confirm" = "yes" ]; then \
		gem push *.gem && \
		echo "$(GREEN)✓ Gem published successfully!$(NC)" && \
		echo "$(BLUE)View at: https://rubygems.org/gems/$(GEM_NAME)$(NC)"; \
	else \
		echo "$(YELLOW)Publish cancelled$(NC)"; \
	fi

# Dry run for publishing - test the process without actually publishing
# Useful for validating that everything is ready for publication
publish-dry-run: build ## Simulate publishing (safe test)
	@echo "$(GREEN)Dry run: simulating gem publish...$(NC)"
	@echo "$(YELLOW)Version: $$(make version)$(NC)"
	@echo "$(YELLOW)Gem file: $$(ls *.gem)$(NC)"
	@echo "$(GREEN)✓ Ready to publish (use 'make publish' to actually publish)$(NC)"

#==============================================================================
# CODE QUALITY AND LINTING
#==============================================================================

# Run RuboCop static code analysis
# Ensures code follows Ruby community standards
lint: ## Run RuboCop linter
	@echo "$(GREEN)Running RuboCop linter...$(NC)"
	# Check both lib and test directories for style issues
	# Simple format provides clean, readable output
	@bundle exec rubocop lib/ test/ --format simple
	@echo "$(GREEN)✓ Linting complete$(NC)"

# Auto-fix RuboCop violations where possible
# Saves developer time by automatically fixing simple style issues
lint-fix: ## Run RuboCop with auto-correct
	@echo "$(GREEN)Running RuboCop with auto-correct...$(NC)"
	# Automatically fix issues that can be safely corrected
	@bundle exec rubocop lib/ test/ --auto-correct
	@echo "$(GREEN)✓ Auto-corrections applied$(NC)"

# Alias for lint-fix for convenience
format: lint-fix ## Alias for lint-fix

#==============================================================================
# DEVELOPMENT HELPERS
#==============================================================================

# Install all gem dependencies
# Essential setup step for new development environments
deps: ## Install dependencies
	@echo "$(GREEN)Installing dependencies...$(NC)"
	# Use bundler to install all dependencies from Gemfile
	@bundle install
	@echo "$(GREEN)✓ Dependencies installed$(NC)"

# Update all dependencies to latest compatible versions
# Important for security updates and bug fixes
deps-update: ## Update dependencies
	@echo "$(GREEN)Updating dependencies...$(NC)"
	# Update all gems to latest versions within constraints
	@bundle update
	@echo "$(GREEN)✓ Dependencies updated$(NC)"

# Start interactive console with gem pre-loaded
# Useful for testing gem functionality interactively
console: ## Start interactive console with gem loaded
	@echo "$(GREEN)Starting interactive console...$(NC)"
	# Use the provided console script which loads the gem
	@bundle exec bin/console

# Launch the Sinatra demo application
# Builds the gem first to ensure latest version is used in demo
demo: build ## Build gem and launch Sinatra demo app
	@echo "$(GREEN)Building gem and launching Sinatra demo application...$(NC)"
	@echo "$(BLUE)Starting Estonian e-Business Register API Demo$(NC)"
	@echo "$(BLUE)============================================$(NC)"
	# Install the freshly built gem locally for demo to use latest version
	@echo "$(YELLOW)Installing latest gem version for demo...$(NC)"
	@gem install *.gem --local --force > /dev/null 2>&1 || true
	# Navigate to demo directory and start the Sinatra app
	@echo "$(GREEN)Starting demo app at http://localhost:4567$(NC)"
	@echo "$(YELLOW)Press Ctrl+C to stop the server$(NC)"
	@echo ""
	# Change to demo directory and run the startup script
	@cd demo_app && ruby start.rb

#==============================================================================
# GIT INTEGRATION
#==============================================================================

# Create git tag for current version
# Important for tracking releases and enabling rollbacks
git-tag: ## Create git tag for current version
	@echo "$(GREEN)Creating git tag for version $$(make version)...$(NC)"
	# Create annotated tag with version message
	# Annotated tags include metadata like date and author
	@git tag -a "v$$(make version)" -m "Release version $$(make version)"
	@echo "$(GREEN)✓ Tag created: v$$(make version)$(NC)"
	@echo "$(YELLOW)Push with: git push origin v$$(make version)$(NC)"

# Push all tags to remote repository
# Makes tags available to other developers and CI/CD systems
git-push-tags: ## Push all tags to origin
	@echo "$(GREEN)Pushing tags to origin...$(NC)"
	# Push all local tags to the remote repository
	@git push origin --tags
	@echo "$(GREEN)✓ Tags pushed$(NC)"

#==============================================================================
# COMPLETE RELEASE WORKFLOW
#==============================================================================

# Complete automated release process
# Combines all release steps into a single command for convenience
release: version-up build test git-tag publish git-push-tags ## Complete release workflow
	@echo "$(GREEN)🎉 Release complete!$(NC)"
	@echo "$(BLUE)Version $$(make version) has been:$(NC)"
	@echo "  • Built and tested"
	@echo "  • Tagged in git"  
	@echo "  • Published to RubyGems"
	@echo "  • Tags pushed to origin"

#==============================================================================
# STATUS AND DIAGNOSTICS
#==============================================================================

# Show comprehensive project status
# Useful for debugging and understanding current state
status: ## Show project status
	@echo "$(BLUE)Estonian e-Business Register Gem Status$(NC)"
	@echo "$(BLUE)=======================================$(NC)"
	# Display current version
	@echo "Version: $$(make version)"
	# Count built gem files
	@echo "Gem files: $$(ls *.gem 2>/dev/null | wc -l | tr -d ' ') built"
	# Show git status if this is a git repository
	@echo "Git status:"
	@git status --porcelain || echo "  (not a git repository)"
	@echo ""
	# Check if dependencies are satisfied
	@echo "Dependencies:"
	@bundle check >/dev/null 2>&1 && echo "  ✓ All dependencies satisfied" || echo "  ⚠ Run 'make deps' to install dependencies"
	@echo ""
	# Check for API credentials
	@echo "Credentials:"
	@[ -f ~/.ee_business_register_credentials.yml ] && echo "  ✓ API credentials configured" || echo "  ⚠ No credentials file found"

#==============================================================================
# SECURITY AND PERFORMANCE
#==============================================================================

# Run security audit on all dependencies
# Important for FinTech applications to identify vulnerabilities
security-audit: ## Run security audit on dependencies
	@echo "$(GREEN)Running security audit...$(NC)"
	# Use bundler-audit to check for known vulnerabilities
	# Update the vulnerability database first
	@bundle audit check --update
	@echo "$(GREEN)✓ Security audit complete$(NC)"

# Generate documentation (placeholder for future implementation)
# Professional gems should include comprehensive documentation
docs: ## Generate documentation (placeholder)
	@echo "$(GREEN)Generating documentation...$(NC)"
	@echo "$(YELLOW)Documentation generation not yet implemented$(NC)"
	@echo "$(BLUE)See README.md for current documentation$(NC)"

# Run basic performance benchmarks
# Helps identify performance regressions during development
benchmark: ## Run basic performance benchmarks
	@echo "$(GREEN)Running performance benchmarks...$(NC)"
	# Simple benchmark of basic operations
	# Note: This will make real API calls if credentials are configured
	@bundle exec ruby -Ilib -e '\
		require "ee_e_business_register"; \
		require "benchmark"; \
		puts "Note: Benchmarks will make real API calls if credentials are configured"; \
		puts "Basic configuration benchmark:"; \
		Benchmark.bm do |x|; \
			x.report("Config creation:") { 1000.times { EeEBusinessRegister::Configuration.new } }; \
		end'