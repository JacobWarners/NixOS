use serde::Serialize;
use std::thread;
use std::time::Duration;
// The SystemExt and ProcessExt traits are no longer needed,
// as their methods are now directly on the System and Process structs.
use sysinfo::{System, Process};

// A struct to represent the JSON output for Waybar.
// Using serde_json makes creating the correct format easy and reliable.
#[derive(Serialize)]
struct WaybarOutput {
    text: String,
    tooltip: String,
    class: String,
}

fn main() {
    let mut sys = System::new();

    // --- Get an Accurate CPU Reading ---
    // To get a non-zero CPU usage, we need to calculate the difference
    // over a short timeframe. We refresh, sleep for a short duration,
    // and refresh again.
    sys.refresh_cpu();
    // A small, fixed sleep duration is now recommended. 200ms is a safe value.
    thread::sleep(Duration::from_millis(200));
    sys.refresh_cpu();
    sys.refresh_processes();

    // --- Find the Top Process ---
    // We iterate through all processes once to find the one with the highest
    // current CPU usage. We only filter out the kernel's idle process.
    let top_process = sys
        .processes()
        .values()
        .filter(|p| p.name() != "idle")
        .max_by(|a, b| a.cpu_usage().total_cmp(&b.cpu_usage()));

    // --- Prepare and Print the Output ---
    // The previous check for > 0.01 CPU has been removed.
    // We will now always display the top process found.
    match top_process {
        Some(process) => {
            // Found a process, format it to match the desired output.
            let name = process.name();
            // Truncate the name to 15 characters to keep the bar clean.
            let truncated_name = if name.len() > 15 {
                &name[..15]
            } else {
                name
            };

            let output = WaybarOutput {
                // CORRECTED: The format now matches your screenshot.
                text: format!("🔥 {} - {:.1}% CPU", truncated_name, process.cpu_usage()),
                tooltip: format!(
                    "<b>Top Process</b>\nName: {}\nPID: {}\nCPU: {:.2}%",
                    process.name(),
                    process.pid(),
                    process.cpu_usage()
                ),
                class: "top-process".to_string(),
            };
            // Print the JSON string to stdout.
            println!("{}", serde_json::to_string(&output).unwrap());
        }
        None => {
            // This case is now very unlikely, only happening if no processes are running at all.
            let output = WaybarOutput {
                text: "🔥 No processes found".to_string(),
                tooltip: "Could not find any running processes.".to_string(),
                class: "error".to_string(),
            };
            println!("{}", serde_json::to_string(&output).unwrap());
        }
    }
}

