use std::thread;
use std::time::Duration;
use sysinfo::{System, ProcessesToUpdate};

fn main() {
    let mut sys = System::new();

    // Refresh everything once to populate the data
    sys.refresh_all();
    // A small sleep isn't strictly necessary for memory but is good practice
    thread::sleep(Duration::from_millis(200));
    sys.refresh_all();


    // --- Get all processes and sort them by MEMORY usage ---
    let mut processes: Vec<_> = sys.processes().values().collect();
    // Note: We are sorting by `memory()` now, not `cpu_usage()`
    processes.sort_by(|a, b| b.memory().cmp(&a.memory()));

    // --- Print the Top 5 Processes by MEMORY for Debugging ---
    println!("\n--- Top 5 Processes by MEMORY ---\n");
    for (i, process) in processes.iter().take(5).enumerate() {
        // Memory is in kilobytes, so we divide by 1024 to get megabytes (MB)
        let memory_mb = process.memory() / 1024;
        println!(
            "{}. PID: {:<6} | MEM: {:<5} MB | Name: \"{}\"",
            i + 1,
            process.pid(),
            memory_mb,
            process.name().to_str().unwrap_or("<invalid UTF-8>")
        );
    }
    println!("\n-----------------------------------\n");
}
