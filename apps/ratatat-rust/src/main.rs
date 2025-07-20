// main.rs

use rdev::{listen, Event, EventType, Key};
use std::process::Command;
use std::sync::{Arc, Mutex};
use std::thread;

fn main() {
    // The target key sequence we are looking for.
    let target_sequence = vec![
        Key::KeyR,
        Key::KeyA,
        Key::KeyT,
        Key::KeyA,
        Key::KeyT,
        Key::KeyA,
        Key::KeyT,
    ];

    // A thread-safe, mutable vector to store the most recent key presses.
    // Arc (Atomically Referenced Counter) allows for shared ownership across threads,
    // and Mutex (Mutual Exclusion) ensures that only one thread can access the data at a time.
    let recent_keys = Arc::new(Mutex::new(Vec::<Key>::new()));

    // Clone the Arc-wrapped recent_keys vector for use in the listening thread.
    let recent_keys_clone = Arc::clone(&recent_keys);

    // Spawn a new thread to listen for keyboard events.
    // This prevents the main thread from being blocked.
    thread::spawn(move || {
        listen(move |event| {
            callback(event, &recent_keys_clone, &target_sequence);
        })
        .expect("Failed to listen for keyboard events");
    });

    // The main thread can continue running. Here, we just put it into a loop
    // to keep the program alive. In a real-world daemon, this might handle
    // other tasks or simply sleep.
    loop {
        thread::sleep(std::time::Duration::from_secs(1));
    }
}

/// This function is called every time a new keyboard event is received.
///
/// # Arguments
///
/// * `event` - The event received from the keyboard.
/// * `recent_keys_arc` - A thread-safe reference to the vector of recent key presses.
/// * `target_sequence` - The sequence of keys we are looking for.
fn callback(event: Event, recent_keys_arc: &Arc<Mutex<Vec<Key>>>, target_sequence: &[Key]) {
    // We are only interested in key press events, not releases.
    if let EventType::KeyPress(key) = event.event_type {
        // Lock the mutex to get exclusive access to the recent_keys vector.
        let mut keys = recent_keys_arc.lock().unwrap();

        // Add the newly pressed key to our vector.
        keys.push(key);

        // To keep the vector from growing indefinitely, we'll only store
        // as many keys as are in our target sequence.
        if keys.len() > target_sequence.len() {
            // Remove the oldest key.
            keys.remove(0);
        }
        
        println!("Current sequence: {:?}", keys);


        // Check if the current sequence of keys matches our target.
        if *keys == *target_sequence {
            println!("'ratatat' sequence detected!");

            // If it matches, play a song.
            // We're using 'mpg123' here, which is a popular command-line MP3 player.
            // Make sure you have it installed on your system (`pkgs.mpg123` in Nix).
            // You'll also need to replace "/path/to/your/song.mp3" with the actual
            // path to the music file you want to play.
            let _ = Command::new("mpg123")
                .arg("/home/jake/.config/scripts/ratatat-rust/Loud-pipes.mp3") // <-- IMPORTANT: Change this path
                .spawn()
                .expect("Failed to play song. Is mpg123 installed and is the path correct?");

            // Clear the sequence so it doesn't trigger repeatedly.
            keys.clear();
        }
    }
}

