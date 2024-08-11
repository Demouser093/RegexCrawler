#!/bin/bash

# Function to check for sensitive keywords using regex
check_for_sensitive_keywords() {
    local url=$1
    local content=$2
    local regex_file=$3

    # Load regex patterns from JSON file
    declare -A regex_patterns
    while IFS=": " read -r key value; do
        if [[ "$key" =~ ^\"(.*)\"$ ]]; then
            key="${BASH_REMATCH[1]}"
        fi
        if [[ "$value" =~ ^\"(.*)\"$ ]]; then
            value="${BASH_REMATCH[1]}"
            regex_patterns["$key"]="$value"
        fi
    done < <(jq -r 'to_entries[] | "\(.key): \(.value)"' "$regex_file")

    for name in "${!regex_patterns[@]}"; do
        local pattern="${regex_patterns[$name]}"
        echo "Checking with pattern: $name - $pattern"  # Debug output
        if [[ $content =~ $pattern ]]; then
            echo "Sensitive keyword found: $name"
            echo "URL: $url"
            echo "Match: ${BASH_REMATCH[0]}"
            echo "========================"
        fi
    done
}

# Print usage instructions
print_usage() {
    echo "Usage: $0 <url file> <regex.json file>"
    echo "  <url file>     : Path to the file containing URLs to check."
    echo "  <regex.json file>: Path to the JSON file containing regex patterns."
    exit 1
}

# Check the number of arguments and file existence
if [[ $# -ne 2 ]]; then
    echo "Error: Incorrect number of arguments."
    print_usage
elif [[ ! -f "$1" ]]; then
    echo "Error: URL file not found: $1"
    print_usage
elif [[ ! -f "$2" ]]; then
    echo "Error: Regex JSON file not found: $2"
    print_usage
fi

# Assign arguments to variables
input_file="$1"
regex_file="$2"

# Loop through each URL in the file
while IFS= read -r url; do
    echo "Checking URL: $url"

    # Fetch the URL content
    content=$(curl -s "$url")

    # Check for sensitive keywords
    check_for_sensitive_keywords "$url" "$content" "$regex_file"
done < "$input_file"
