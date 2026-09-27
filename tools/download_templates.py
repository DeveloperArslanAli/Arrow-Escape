"""
Stream-download and extract Godot Android export templates directly from GitHub release archive
using HTTP byte ranges and raw deflate streaming.
"""
import os
import sys
import time
import zlib
import urllib.request

URL = "https://github.com/godotengine/godot/releases/download/4.7.2-stable/Godot_v4.7.2-stable_export_templates.tpz"

TARGET_DIR = os.path.expandvars(r"%APPDATA%\Godot\export_templates\4.7.2.stable")
os.makedirs(TARGET_DIR, exist_ok=True)

FILES = [
    {
        "name": "android_release.apk",
        "start": 125835048,
        "length": 103949600,
        "expected_uncomp": 104803333
    },
    {
        "name": "android_source.zip",
        "start": 229784734,
        "length": 214421853,
        "expected_uncomp": 214418211
    },
    {
        "name": "android_debug.apk",
        "start": 85,
        "length": 125834876,
        "expected_uncomp": 127260725
    }
]

def download_and_extract(target_file_info):
    fname = target_file_info["name"]
    dest_path = os.path.join(TARGET_DIR, fname)
    if os.path.exists(dest_path) and os.path.getsize(dest_path) == target_file_info["expected_uncomp"]:
        print(f"[*] {fname} already fully downloaded ({target_file_info['expected_uncomp']} bytes). Skipping.")
        return

    start_byte = target_file_info["start"]
    comp_len = target_file_info["length"]
    end_byte = start_byte + comp_len - 1

    print(f"\n[+] Streaming {fname} ({comp_len / 1024 / 1024:.2f} MB compressed)...")
    req = urllib.request.Request(
        URL,
        headers={
            "Range": f"bytes={start_byte}-{end_byte}",
            "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64)"
        }
    )

    t0 = time.time()
    downloaded = 0
    written = 0
    decompressor = zlib.decompressobj(-zlib.MAX_WBITS)
    chunk_size = 512 * 1024  # 512 KB per read

    temp_path = dest_path + ".tmp"
    with urllib.request.urlopen(req) as resp, open(temp_path, "wb") as out_f:
        while True:
            chunk = resp.read(chunk_size)
            if not chunk:
                break
            downloaded += len(chunk)
            decomp = decompressor.decompress(chunk)
            if decomp:
                out_f.write(decomp)
                written += len(decomp)

            elapsed = time.time() - t0
            speed = (downloaded / (1024 * 1024)) / elapsed if elapsed > 0 else 0
            pct = (downloaded / comp_len) * 100
            print(f"\r    Progress: {pct:5.1f}% | {downloaded / 1024 / 1024:6.2f} MB / {comp_len / 1024 / 1024:6.2f} MB | {speed:4.2f} MB/s | Written: {written / 1024 / 1024:6.2f} MB", end="", flush=True)

        final_bytes = decompressor.flush()
        if final_bytes:
            out_f.write(final_bytes)
            written += len(final_bytes)

    if os.path.exists(dest_path):
        os.remove(dest_path)
    os.rename(temp_path, dest_path)
    print(f"\n[✓] Finished {fname}: {written} bytes written in {time.time() - t0:.1f}s.")

if __name__ == "__main__":
    filter_name = sys.argv[1] if len(sys.argv) > 1 else None
    for item in FILES:
        if filter_name and item["name"] != filter_name:
            continue
        download_and_extract(item)
