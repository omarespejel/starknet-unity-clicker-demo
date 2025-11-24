#!/bin/bash

#
# Description:
# This script generates a comprehensive prompt for an LLM by concatenating key source
# files from the Simple Clicker Game project, including Node.js backend, React frontend,
# Cairo contracts (Dojo), Unity SDK, and deployment configuration.
#
# Usage:
# ./generate-context.sh
#

# --- Configuration ---
# Get current date for the output filename (ISO 8601 format for best practices)
DATE=$(date '+%Y-%m-%d_%H-%M-%S_%Z')

# Output filename with descriptive name following best practices
OUTPUT_FILE="clicker-game-context-${DATE}.txt"

# --- Script Body ---
# Clean up any previous output file to start fresh
rm -f "$OUTPUT_FILE"

echo "🚀 Starting LLM prompt generation for the Simple Clicker Game project..."
echo "------------------------------------------------------------"
echo "Output will be saved to: $OUTPUT_FILE"
echo ""

# 1. Add a Preamble and Goal for the LLM
echo "Adding LLM preamble and goal..."
{
  echo "# Simple Clicker Game Project Context & Goal"
  echo ""
  echo "## Goal for the LLM"
  echo "You are an expert full-stack blockchain developer with deep expertise in:"
  echo "- Node.js/Express.js backend development"
  echo "- React frontend development"
  echo "- Starknet smart contracts (Cairo language)"
  echo "- Dojo framework for on-chain games"
  echo "- Cartridge Controller & Paymaster (gasless transactions)"
  echo "- Session key management"
  echo "- Unity game development (C#)"
  echo "- RESTful API design"
  echo "- Docker containerization"
  echo "- Scarb (Cairo package manager)"
  echo "- Starknet.js SDK integration"
  echo "- Torii GraphQL indexer"
  echo "- Real-time state synchronization"
  echo "- Cross-platform game development"
  echo ""
  echo "Your task is to analyze the complete context of this Simple Clicker Game project. The system features:"
  echo "- Express.js backend API server"
  echo "- React web frontend"
  echo "- Dojo on-chain game (Cairo contracts)"
  echo "- Cartridge Controller & Paymaster integration (gasless transactions)"
  echo "- Session key management for seamless UX"
  echo "- Unity SDK for game client integration"
  echo "- Torii GraphQL for real-time state queries"
  echo "- Docker compose setup"
  echo "- Render.com deployment configuration"
  echo ""
  echo "Please review the project structure, dependencies, source code, and configuration,"
  echo "then provide specific, actionable advice for improvement. Focus on:"
  echo "- Express.js API design and error handling"
  echo "- React component architecture and state management"
  echo "- Dojo system and model design"
  echo "- Cartridge Controller & Paymaster integration"
  echo "- Session key security and management"
  echo "- Gasless transaction implementation"
  echo "- Unity API integration patterns"
  echo "- Torii GraphQL query optimization"
  echo "- Real-time state synchronization"
  echo "- Error handling and retry logic"
  echo "- Type safety and validation"
  echo "- API design and RESTful conventions"
  echo "- Testing strategies (unit, integration, e2e)"
  echo "- Performance monitoring and metrics"
  echo "- Production deployment strategies"
  echo "- Security best practices (session keys, RPC authentication)"
  echo "- Cross-platform compatibility (web, Unity, mobile)"
  echo ""
  echo "---"
  echo ""
} >> "$OUTPUT_FILE"

# 2. Add the project's directory structure (cleaned up)
echo "Adding cleaned directory structure..."
echo "## Directory Structure" >> "$OUTPUT_FILE"
if command -v tree &> /dev/null; then
    echo "  -> Adding directory structure (tree -L 4)"
    # Exclude common noise from the tree view
    tree -L 4 -I "node_modules|dist|.git|.DS_Store|*.log|build|__pycache__|*.pyc|*.pyo|.pytest_cache|.mypy_cache|target|*.sierra|*.casm|Library|Temp|Logs|My project" >> "$OUTPUT_FILE"
else
    echo "  -> WARNING: 'tree' command not found. Using find instead."
    echo "NOTE: 'tree' command was not found. Directory listing:" >> "$OUTPUT_FILE"
    find . -maxdepth 3 -not -path '*/node_modules/*' -not -path '*/.git/*' -not -path '*/dist/*' -not -path '*/build/*' -not -path '*/target/*' -not -path '*/Library/*' -not -path '*/Temp/*' -not -path '*/Logs/*' | head -50 >> "$OUTPUT_FILE"
fi
echo "" >> "$OUTPUT_FILE"

# 3. Add Core Project and Configuration Files
echo "Adding core project and configuration files..."
CORE_FILES=(
  "README.md"
  "Scarb.toml"
  "dojo_sepolia.toml"
  "torii_sepolia.toml"
  ".gitignore"
  "$0" # This script itself
)

for file in "${CORE_FILES[@]}"; do
  if [ -f "$file" ]; then
    echo "  -> Adding $file"
    echo "## FILE: $file" >> "$OUTPUT_FILE"
    cat "$file" >> "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE"
    echo "---" >> "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE"
  else
    echo "  -> WARNING: $file not found. Skipping."
  fi
done

# 4. Add Backend Source Files
echo "Adding backend source files..."
if [ -d "backend/src" ]; then
  echo "  -> Found backend/src/ directory; adding its files"
  # Find all JavaScript files
  find "backend/src" -type f -name "*.js" \
    -not -path "*/node_modules/*" \
    | sort | while read -r src_file; do
      echo "  -> Adding backend file: $src_file"
      echo "## FILE: $src_file" >> "$OUTPUT_FILE"
      cat "$src_file" >> "$OUTPUT_FILE"
      echo "" >> "$OUTPUT_FILE"
      echo "---" >> "$OUTPUT_FILE"
      echo "" >> "$OUTPUT_FILE"
    done
else
  echo "  -> WARNING: backend/src/ directory not found."
fi

# Add backend package.json
if [ -f "backend/package.json" ]; then
  echo "  -> Adding backend/package.json"
  echo "## FILE: backend/package.json" >> "$OUTPUT_FILE"
  cat "backend/package.json" >> "$OUTPUT_FILE"
  echo "" >> "$OUTPUT_FILE"
  echo "---" >> "$OUTPUT_FILE"
  echo "" >> "$OUTPUT_FILE"
fi

# Add backend README and Cartridge setup
if [ -f "backend/README.md" ]; then
  echo "  -> Adding backend/README.md"
  echo "## FILE: backend/README.md" >> "$OUTPUT_FILE"
  cat "backend/README.md" >> "$OUTPUT_FILE"
  echo "" >> "$OUTPUT_FILE"
  echo "---" >> "$OUTPUT_FILE"
  echo "" >> "$OUTPUT_FILE"
fi

if [ -f "backend/CARTRIDGE_SETUP.md" ]; then
  echo "  -> Adding backend/CARTRIDGE_SETUP.md"
  echo "## FILE: backend/CARTRIDGE_SETUP.md" >> "$OUTPUT_FILE"
  cat "backend/CARTRIDGE_SETUP.md" >> "$OUTPUT_FILE"
  echo "" >> "$OUTPUT_FILE"
  echo "---" >> "$OUTPUT_FILE"
  echo "" >> "$OUTPUT_FILE"
fi

# 5. Add Frontend Source Files
echo "Adding frontend source files..."
if [ -d "frontend/src" ]; then
  echo "  -> Found frontend/src/ directory; adding its files"
  # Find all JavaScript/JSX files
  find "frontend/src" -type f \( -name "*.js" -o -name "*.jsx" -o -name "*.css" \) \
    -not -path "*/node_modules/*" \
    | sort | while read -r src_file; do
      echo "  -> Adding frontend file: $src_file"
      echo "## FILE: $src_file" >> "$OUTPUT_FILE"
      cat "$src_file" >> "$OUTPUT_FILE"
      echo "" >> "$OUTPUT_FILE"
      echo "---" >> "$OUTPUT_FILE"
      echo "" >> "$OUTPUT_FILE"
    done
else
  echo "  -> WARNING: frontend/src/ directory not found."
fi

# Add frontend package.json
if [ -f "frontend/package.json" ]; then
  echo "  -> Adding frontend/package.json"
  echo "## FILE: frontend/package.json" >> "$OUTPUT_FILE"
  cat "frontend/package.json" >> "$OUTPUT_FILE"
  echo "" >> "$OUTPUT_FILE"
  echo "---" >> "$OUTPUT_FILE"
  echo "" >> "$OUTPUT_FILE"
fi

# 6. Add Cairo Contracts (Dojo)
echo "Adding Cairo contracts (Dojo)..."
if [ -d "src" ]; then
  # Add Scarb.toml if not already added
  if [ -f "Scarb.toml" ]; then
    # Check if already added
    if ! grep -q "## FILE: Scarb.toml" "$OUTPUT_FILE"; then
      echo "  -> Adding Scarb.toml"
      echo "## FILE: Scarb.toml" >> "$OUTPUT_FILE"
      cat "Scarb.toml" >> "$OUTPUT_FILE"
      echo "" >> "$OUTPUT_FILE"
      echo "---" >> "$OUTPUT_FILE"
      echo "" >> "$OUTPUT_FILE"
    fi
  fi

  # Add all Cairo source files
  find "src" -type f -name "*.cairo" \
    -not -path "*/target/*" \
    | sort | while read -r contract_file; do
      echo "  -> Adding contract file: $contract_file"
      echo "## FILE: $contract_file" >> "$OUTPUT_FILE"
      cat "$contract_file" >> "$OUTPUT_FILE"
      echo "" >> "$OUTPUT_FILE"
      echo "---" >> "$OUTPUT_FILE"
      echo "" >> "$OUTPUT_FILE"
    done

  # Add test files if they exist
  if [ -d "src/tests" ]; then
    find "src/tests" -type f -name "*.cairo" | sort | while read -r test_file; do
      echo "  -> Adding contract test file: $test_file"
      echo "## FILE: $test_file" >> "$OUTPUT_FILE"
      cat "$test_file" >> "$OUTPUT_FILE"
      echo "" >> "$OUTPUT_FILE"
      echo "---" >> "$OUTPUT_FILE"
      echo "" >> "$OUTPUT_FILE"
    done
  fi
else
  echo "  -> No src directory found. Skipping."
fi

# 7. Add Unity SDK Files
echo "Adding Unity SDK files..."
if [ -d "unity-sdk" ]; then
  find "unity-sdk" -type f \( -name "*.cs" -o -name "*.md" \) \
    -not -path "*/Library/*" \
    -not -path "*/Temp/*" \
    | sort | while read -r unity_file; do
      echo "  -> Adding Unity file: $unity_file"
      echo "## FILE: $unity_file" >> "$OUTPUT_FILE"
      cat "$unity_file" >> "$OUTPUT_FILE"
      echo "" >> "$OUTPUT_FILE"
      echo "---" >> "$OUTPUT_FILE"
      echo "" >> "$OUTPUT_FILE"
    done
else
  echo "  -> No unity-sdk directory found. Skipping."
fi

# 8. Add Documentation Files
echo "Adding documentation files..."
if [ -d "docs" ]; then
  find "docs" -type f \( -name "*.md" -o -name "*.txt" \) \
    | sort | while read -r doc_file; do
      echo "  -> Adding documentation file: $doc_file"
      echo "## FILE: $doc_file" >> "$OUTPUT_FILE"
      cat "$doc_file" >> "$OUTPUT_FILE"
      echo "" >> "$OUTPUT_FILE"
      echo "---" >> "$OUTPUT_FILE"
      echo "" >> "$OUTPUT_FILE"
    done
else
  echo "  -> No docs directory found. Skipping."
fi

# 9. Add Deployment Configuration
echo "Adding deployment configuration..."
if [ -d "deployment" ]; then
  find "deployment" -type f \( -name "*.yaml" -o -name "*.yml" -o -name "*.sh" -o -name "*.md" \) \
    | sort | while read -r deploy_file; do
      echo "  -> Adding deployment file: $deploy_file"
      echo "## FILE: $deploy_file" >> "$OUTPUT_FILE"
      cat "$deploy_file" >> "$OUTPUT_FILE"
      echo "" >> "$OUTPUT_FILE"
      echo "---" >> "$OUTPUT_FILE"
      echo "" >> "$OUTPUT_FILE"
    done
else
  echo "  -> No deployment directory found. Skipping."
fi

# 10. Add Configuration Files (never include .env)
echo "Adding additional configuration files..."
# Never include .env to avoid secret exposure
if [ -f "backend/.env" ] || [ -f ".env" ]; then
  echo "  -> WARNING: .env detected but will NOT be included to avoid exposing secrets."
fi

CONFIG_FILES=(
  "backend/.env.example"
  ".env.example"
)

for config_file in "${CONFIG_FILES[@]}"; do
  if [ -f "$config_file" ]; then
    echo "  -> Adding config file: $config_file"
    echo "## FILE: $config_file" >> "$OUTPUT_FILE"
    cat "$config_file" >> "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE"
    echo "---" >> "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE"
  fi
done

# --- Completion Summary ---
echo ""
echo "-------------------------------------"
echo "✅ Prompt generation complete!"
echo "Generated on: $(date '+%A, %B %d, %Y at %I:%M:%S %p %Z')"
echo ""
echo "This context file now includes:"
echo "  ✓ A clear goal and preamble for the LLM"
echo "  ✓ A cleaned project directory structure"
echo "  ✓ Core project files (README.md, Scarb.toml, dojo_sepolia.toml)"
echo "  ✓ Backend source code (Express.js, Cartridge integration)"
echo "  ✓ Frontend source code (React components, API client)"
echo "  ✓ Cairo contracts (Dojo systems and models)"
echo "  ✓ Unity SDK (C# scripts)"
echo "  ✓ Documentation files"
echo "  ✓ Deployment configuration"
echo "  ✓ Configuration files (excluding .env)"
echo ""
echo "File size: $(du -h "$OUTPUT_FILE" | cut -f1)"
echo "Total lines: $(wc -l < "$OUTPUT_FILE" | xargs)"
echo ""
echo "You can now use the content of '$OUTPUT_FILE' as a context prompt for your LLM."
echo "Perfect for getting comprehensive code reviews, architecture advice, or feature suggestions!"
echo ""
echo "💡 Tip: This is especially useful for:"
echo "   - Express.js API optimization"
echo "   - React component architecture"
echo "   - Dojo system and model design"
echo "   - Cartridge Controller & Paymaster integration"
echo "   - Session key management"
echo "   - Gasless transaction implementation"
echo "   - Unity API integration patterns"
echo "   - Torii GraphQL optimization"
echo "   - Real-time state synchronization"
echo "   - Error handling and retry logic"
echo "   - Type safety improvements"
echo "   - API design and validation"
echo "   - Testing strategy recommendations"
echo "   - Production deployment readiness"
echo ""
echo "🎯 Key areas to focus on:"
echo "   - Cartridge Controller & Paymaster integration"
echo "   - Session key security and management"
echo "   - Gasless transaction reliability"
echo "   - Dojo system execution patterns"
echo "   - React state management"
echo "   - Unity API client implementation"
echo "   - Torii GraphQL query optimization"
echo "   - Error handling and logging strategies"
echo "   - Cross-platform compatibility"
echo "   - Production monitoring and metrics"
echo ""

