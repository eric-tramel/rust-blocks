use std::io::{self, BufRead};
use serde::Serialize;

#[derive(Serialize)]
struct CodeBlock {
    content: String,
    syntax: Option<String>,
}

fn main() {
    let stdin = io::stdin();
    let mut blocks: Vec<CodeBlock> = Vec::new();

    let mut in_block = false;
    let mut current_syntax: Option<String> = None;
    let mut current_content = String::new();

    // We'll define a small helper function to check if a line is a fence line.
    // A fence line is a line that starts with "```" and may have a language after it.
    fn parse_fence(line: &str) -> Option<&str> {
        let trimmed = line.trim();
        if trimmed.starts_with("```") {
            // If there's more than just ``` on the line, consider the rest as syntax.
            let after = &trimmed[3..].trim();
            if after.is_empty() {
                Some("")
            } else {
                Some(after)
            }
        } else {
            None
        }
    }

    for line_res in stdin.lock().lines() {
        let line = match line_res {
            Ok(l) => l,
            Err(_) => break, // On error reading stdin, just stop.
        };

        if in_block {
            // We are currently inside a code block. Check if this line ends it.
            if let Some(_) = parse_fence(&line) {
                // This is the end of a code block
                // Store the block
                blocks.push(CodeBlock {
                    content: current_content,
                    syntax: current_syntax.clone().filter(|s| !s.is_empty()),
                });
                // Reset
                in_block = false;
                current_syntax = None;
                current_content = String::new();
            } else {
                // Just another line of code content
                if !current_content.is_empty() {
                    current_content.push('\n');
                }
                current_content.push_str(&line);
            }
        } else {
            // We are not currently inside a code block. Check if this line starts one.
            if let Some(syntax) = parse_fence(&line) {
                in_block = true;
                current_syntax = if syntax.is_empty() { None } else { Some(syntax.to_string()) };
                current_content = String::new();
            } else {
                // Just a normal line outside code blocks, ignore.
            }
        }
    }

    // Print the resulting JSON
    // If performance is extremely critical, we can manually format JSON.
    // But serde_json is quite efficient for this purpose.
    println!("{}", serde_json::to_string_pretty(&blocks).unwrap());
}

