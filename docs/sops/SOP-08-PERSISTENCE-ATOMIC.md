# SOP-08: Atomic Persistence, Save Integrity & Migrations
## Purpose & Scope
Governs persistent storage of player progress, unlocked levels, star achievements, and settings on local mobile storage. Guarantees zero data loss even during unexpected app kill or battery depletion.

---

## 1. SAVE FILE SCHEMA (JSON / USER DATA)

Target path: `user://arrow_escape_save.json`

```json
{
  "schema_version": 1,
  "last_updated": 1727376000,
  "highest_unlocked_level": 4,
  "completed_levels": {
    "1": { "stars": 3, "best_moves": 3, "completed_at": 1727375000 },
    "2": { "stars": 3, "best_moves": 4, "completed_at": 1727375120 },
    "3": { "stars": 2, "best_moves": 7, "completed_at": 1727375400 }
  },
  "settings": {
    "sound_enabled": true,
    "music_enabled": true,
    "haptics_enabled": true,
    "sfx_volume": 0.8,
    "music_volume": 0.6
  },
  "checksum": "a7b3...sha256"
}
```

---

## 2. ATOMIC WRITE PATTERN (PREVENTS CORRUPTION)

To prevent file truncation if the user swipes away the game mid-write:
```gdscript
func save_data_atomic() -> bool:
    var save_path = "user://arrow_escape_save.json"
    var temp_path = "user://arrow_escape_save.tmp"
    var backup_path = "user://arrow_escape_save.bak"
    
    var data_string = JSON.stringify(_build_save_dictionary(), "\t")
    
    # 1. Write completely to temp file
    var file = FileAccess.open(temp_path, FileAccess.WRITE)
    if file == null:
        push_error("Failed to open temp save file: %d" % FileAccess.get_open_error())
        return false
    file.store_string(data_string)
    file.close()
    
    # 2. Backup existing save if present
    if FileAccess.file_exists(save_path):
        DirAccess.copy_absolute(save_path, backup_path)
        
    # 3. Rename temp to real save (atomic operation on OS)
    var dir = DirAccess.open("user://")
    var err = dir.rename(temp_path, save_path)
    if err != OK:
        push_error("Failed to rename temp file to save: %d" % err)
        return false
        
    return true
```

---

## 3. CORRUPTION RECOVERY
If `arrow_escape_save.json` cannot be parsed on boot:
1. Attempt to load `arrow_escape_save.bak`.
2. If backup fails, create a fresh valid save with `highest_unlocked_level = 1`.
3. Log event to telemetry/console without crashing the app.
