// main.rs

use inputbot::KeybdKey;
use std::env;
use std::process::Command;
use std::sync::{Arc, Mutex};

fn main() {
    let target_sequence = vec![
        KeybdKey::RKey, KeybdKey::AKey, KeybdKey::TKey, KeybdKey::AKey,
        KeybdKey::TKey, KeybdKey::AKey, KeybdKey::TKey,
    ];

    let recent_keys = Arc::new(Mutex::new(Vec::<KeybdKey>::new()));

    let callback = move |key: KeybdKey| {
        // Use a block to ensure the lock is dropped before the command runs.
        let should_play = {
            // If the lock is poisoned, we recover by clearing the state.
            let mut keys = match recent_keys.lock() {
                Ok(guard) => guard,
                Err(poisoned) => {
                    eprintln!("Recovering from poisoned mutex");
                    poisoned.into_inner()
                }
            };
            keys.push(key);

            if keys.len() > target_sequence.len() {
                keys.remove(0);
            }
            
            println!("Current sequence: {:?}", *keys);

            if *keys == target_sequence {
                keys.clear();
                true // Signal that we should play the song
            } else {
                false
            }
        }; // Lock is dropped here

        if should_play {
            println!("'ratatat' sequence detected! Attempting to play song...");
            
            // Read the song path from an environment variable.
            let song_path = match env::var("RATATAT_SONG_PATH") {
                Ok(path) => path,
                Err(_) => {
                    eprintln!("Error: RATATAT_SONG_PATH environment variable not set.");
                    return; // Exit the callback if the path isn't set.
                }
            };

            // Handle the result of spawning the command gracefully.
            if let Err(e) = Command::new("mpg123")
                .arg(song_path) // Use the path from the environment variable.
                .spawn()
            {
                eprintln!("Failed to play song: {}", e);
            }
        }
    };

    KeybdKey::bind_all(callback);
    println!("Listener started. Type 'ratatat' to play a song.");
    inputbot::handle_input_events();
}

