#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e

# Function to display usage information
usage() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -h, --help        Show this help message and exit"
    echo "  -n NUM_BLOCKS     Number of code blocks to generate (default: 10000)"
    echo "  -o OUTPUT_FILE    Output Markdown file name (default: large_input.md)"
    echo ""
    echo "Example:"
    echo "  $0 -n 20000 -o my_large_input.md"
}

# Default values
NUM_BLOCKS=100000
OUTPUT_FILE="large_input.md"

# Parse command-line arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
        -n|--num-blocks)
            NUM_BLOCKS="$2"
            shift 2
            ;;
        -o|--output)
            OUTPUT_FILE="$2"
            shift 2
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            echo "Unknown parameter passed: $1"
            usage
            exit 1
            ;;
    esac
done

# Function to generate a large Markdown file with multiple code blocks
generate_large_markdown() {
    local num_blocks=$1
    local output_file=$2

    echo "Generating Markdown file with $num_blocks code blocks..."
    
    LANGUAGES=("rust" "python" "javascript" "")
    
    # Truncate or create the output file
    echo "# Large Markdown File for Benchmarking" > "$output_file"
    
    for i in $(seq 1 "$num_blocks"); do
        LANG=${LANGUAGES[$(( (i - 1) % ${#LANGUAGES[@]} ))]}
        if [ -z "$LANG" ]; then
            echo '```' >> "$output_file"
        else
            # Using single quotes to print backticks literally, then appending the language
            echo '```'"$LANG" >> "$output_file"
        fi
        echo 'fn main() { println!("Hello, world!"); }' >> "$output_file"
        echo '```' >> "$output_file"
        echo "" >> "$output_file"
    done

    echo "Markdown file '$output_file' generated successfully."
}

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check for dependencies
check_dependencies() {
    echo "Checking for required dependencies..."

    # Check for bash
    if ! command_exists bash; then
        echo "Error: bash is not installed."
        exit 1
    fi

    # Check for hyperfine
    if ! command_exists hyperfine; then
        echo "Error: hyperfine is not installed."
        echo "You can install it via your package manager. For example:"
        echo "  - macOS: brew install hyperfine"
        echo "  - Linux: cargo install hyperfine"
        echo "  - Windows: choco install hyperfine"
        exit 1
    fi

    # Check for the Rust binary
    RUST_BINARY="./target/release/rust-blocks"
    if [ ! -f "$RUST_BINARY" ]; then
        echo "Error: Rust binary '$RUST_BINARY' not found."
        echo "Please build your Rust project in release mode:"
        echo "  cargo build --release"
        exit 1
    fi

    echo "All dependencies are satisfied."
}

# Function to run the benchmark using hyperfine
run_benchmark() {
    local input_file=$1
    local rust_binary=$2

    echo "Starting benchmark with hyperfine..."

    hyperfine --warmup 3 --runs 30 \
        "cat \"$input_file\" | \"$rust_binary\" > /dev/null"

    echo "Benchmark completed."
}

# Main script execution
main() {
    # Check dependencies
    check_dependencies

    # Generate the Markdown file
    generate_large_markdown "$NUM_BLOCKS" "$OUTPUT_FILE"

    # Run the benchmark
    run_benchmark "$OUTPUT_FILE" "$RUST_BINARY"
}

# Invoke main with all script arguments
main "$@"

