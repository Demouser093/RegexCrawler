#!/bin/bash

# Function to check for WordPress-related sensitive keywords using regex
check_for_wp_sensitive_keywords() {
    local url=$1
    local content=$2

    # Define regex patterns for WordPress-sensitive keywords
    declare -A regex_patterns=(
        ["Nonce Salt"]="define\\(\\s*['\"]NONCE_SALT['\"]\\s*,\\s*['\"]([^'\"]+)['\"]\\s*\\);"
        ["API Key"]="['\"](?:api|key|token)['\"]\\s*[:=]\\s*['\"]([a-zA-Z0-9\\-_]{32,})['\"]"
        ["WP Admin"]="wp-admin/"
        ["Plugins or Themes"]="/wp-content/(?:plugins|themes)/([^/\\s]+)"
        ["Href"]="\\bhref\\b"
    )

    for name in "${!regex_patterns[@]}"; do
        if [[ $content =~ ${regex_patterns[$name]} ]]; then
            echo "Sensitive keyword found: $name"
            echo "URL: $url"
            echo "Match: ${BASH_REMATCH[0]}"
            echo "========================"
        fi
    done
}

# Read the input file containing URLs
input_file="$1"

if [[ ! -f "$input_file" ]]; then
    echo "File not found: $input_file"
    exit 1
fi

# Loop through each URL in the file
while IFS= read -r url; do
    echo "Checking URL: $url"

    # Fetch the URL content
    content=$(curl -s "$url")

    # Check for WordPress-sensitive keywords
    check_for_wp_sensitive_keywords "$url" "$content"
done < "$input_file"
