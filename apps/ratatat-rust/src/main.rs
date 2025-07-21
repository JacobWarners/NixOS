use inputbot::KeybdKey;
use std::env;
use std::process::Command;
use std::sync::{Arc, Mutex};

// Import our new module
mod sonic_counter;

fn main() {
    // --- State for "ratatat" player ---
    let play_sequence = vec![
        KeybdKey::RKey, KeybdKey::AKey, KeybdKey::TKey, KeybdKey::AKey,
        KeybdKey::TKey, KeybdKey::AKey, KeybdKey::TKey,
    ];
    let kill_sequence = vec![KeybdKey::EscapeKey, KeybdKey::EscapeKey, KeybdKey::EscapeKey];
    let recent_keys = Arc::new(Mutex::new(Vec::<KeybdKey>::new()));

    // --- State for our new Sonic Counter ---
    let sonic_state = Arc::new(Mutex::new(sonic_counter::SonicState::new()));
    
    // --- Initialize Systems ---
    sonic_counter::SonicState::initialize_files();

    // --- Unified Callback ---
    let callback = move |key: KeybdKey| {
        // First, let the sonic counter handle the key press.
        // We lock its state and pass it to the handler function.
        let mut sonic_s = sonic_state.lock().unwrap();
        if sonic_counter::handle_key_press(key, &mut sonic_s) {
            return; // The key was handled by the sonic counter, so we're done.
        }

        // If the sonic counter did NOT handle the key, proceed with "ratatat" logic.
        let (should_play, should_kill) = {
            let mut keys = recent_keys.lock().unwrap();
            keys.push(key);

            let max_len = play_sequence.len();
            if keys.len() > max_len {
                keys.remove(0);
            }
            
            println!("Current sequence: {:?}", *keys);

            if keys.ends_with(&play_sequence) {
                keys.clear();
                (true, false)
            } else if keys.ends_with(&kill_sequence) {
                keys.clear();
                (false, true)
            } else {
                (false, false)
            }
        };

        if should_play {
            println!("'ratatat' sequence detected! Attempting to play song...");
            if let Ok(song_path) = env::var("RATATAT_SONG_PATH") {
                if let Err(e) = Command::new("mpg123").arg(song_path).spawn() {
                    eprintln!("Failed to play song: {}", e);
                }
            } else {
                eprintln!("Error: RATATAT_SONG_PATH environment variable not set.");
            }
        }

        if should_kill {
            println!("Kill sequence detected! Stopping audio players...");
            if let Err(e) = Command::new("pkill").arg("mpg123").spawn() {
                eprintln!("Failed to run pkill on mpg123: {}", e);
            }
        }
    };

    // Bind the single, unified callback and start the listener.
    KeybdKey::bind_all(callback);
    println!("Listener started for Sonic Counter and Ratatat Player.");
    inputbot::handle_input_events();
}
