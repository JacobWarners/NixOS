// main.rs

use inputbot::KeybdKey;
use std::process::Command;
use std::sync::{Arc, Mutex};

fn main() {
    // The target key sequence we are looking for.
    let target_sequence = vec![
        KeybdKey::RKey,
        KeybdKey::AKey,
        KeybdKey::TKey,
        KeybdKey::AKey,
        KeybdKey::TKey,
        KeybdKey::AKey,
        KeybdKey::TKey,
    ];

    // A thread-safe, mutable vector to store the most recent key presses.
    let recent_keys = Arc::new(Mutex::new(Vec::<KeybdKey>::new()));

    // We need to bind a callback to each key individually.
    // This closure will run every time any key is pressed.
    let callback = move |key: KeybdKey| {
        // Lock the mutex to get exclusive access to the recent_keys vector.
        let mut keys = recent_keys.lock().unwrap();
        keys.push(key);

        // To keep the vector from growing indefinitely, we'll only store
        // as many keys as are in our target sequence.
        if keys.len() > target_sequence.len() {
            keys.remove(0);
        }

        println!("Current sequence: {:?}", keys);

        // Check if the current sequence of keys matches our target.
        if *keys == target_sequence {
            println!("'ratatat' sequence detected!");

            // If it matches, play a song using 'mpg123'.
            // Make sure you have it installed and the path is correct.
            let _ = Command::new("mpg123")
                .arg("/path/to/your/song.mp3") // <-- IMPORTANT: Change this path
                .spawn()
                .expect("Failed to play song. Is mpg123 installed and is the path correct?");

            // Clear the sequence so it doesn't trigger repeatedly.
            keys.clear();
        }
    };

    // Bind the callback to all possible keyboard keys.
    KeybdKey::bind_all(callback);

    // Start the main event loop.
    println!("Listener started. Type 'ratatat' to play a song.");
    inputbot::handle_input_events();
}

