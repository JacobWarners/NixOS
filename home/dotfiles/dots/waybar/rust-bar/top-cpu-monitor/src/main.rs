use std::collections::HashMap;
use std::thread;
use std::time::{Duration, Instant};
// FINAL CORRECTION: No extension traits are needed.
// All required methods are on the `System` and `Process` structs directly.
use sysinfo::System;

// --- Configuration ---
const POLL_DURATION_SECONDS: u64 = 10;
const ICON: &str = "🔥";

fn main() {
    let mut sys = System::new_all();
    let mut cpu_usage: HashMap<String, f32> = HashMap::new();
    let start_time = Instant::now();
    let poll_duration = Duration::from_secs(POLL_DURATION_SECONDS);

    while Instant::now().duration_since(start_time) < poll_duration {
        sys.refresh_cpu();
        sys.refresh_processes();

        // The `processes()` method returns a `HashMap<&Pid, &Process>`.
        // We iterate over its values.
        for process in sys.processes().values() {
            // The `cpu_usage()` and `name()` methods are directly available on `Process`.
            let cpu = process.cpu_usage();
            let comm = process.name().to_string();

            // Only track processes that are actively using the CPU.
            if cpu > 0.0 {
                // The `or_default()` method is a concise way to insert 0.0 if the key is new.
                *cpu_usage.entry(comm).or_default() += cpu;
            }
        }

        thread::sleep(Duration::from_secs(1));
    }

    // Find the command with the highest cumulative CPU usage.
    // `total_cmp` is used for comparing f32 values correctly.
    let top_process = cpu_usage.iter().max_by(|a, b| a.1.total_cmp(b.1));

    // --- Output for Waybar ---
    match top_process {
        Some((comm, &total_cpu)) => {
            // Calculate the average CPU usage over the polling interval.
            let avg_cpu = total_cpu / POLL_DURATION_SECONDS as f32;
            println!("{} {} - {:.1}% CPU", ICON, comm, avg_cpu);
        }
        None => {
            println!("{} No process found", ICON);
        }
    }
}
