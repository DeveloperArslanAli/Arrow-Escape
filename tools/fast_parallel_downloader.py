"""
High-Speed Parallel Multi-Chunk Downloader using curl.exe and Deflate Extractor for Godot Android Templates.
"""
import os
import sys
import time
import zlib
import subprocess
from concurrent.futures import ThreadPoolExecutor, as_completed

BASE_URL = "https://github.com/godotengine/godot/releases/download/4.7.2-stable/Godot_v4.7.2-stable_export_templates.tpz"
TARGET_DIR = os.path.expandvars(r"%APPDATA%\Godot\export_templates\4.7.2.stable")
CHUNK_TEMP_DIR = os.path.join(os.path.dirname(__file__), "chunks")
os.makedirs(TARGET_DIR, exist_ok=True)
os.makedirs(CHUNK_TEMP_DIR, exist_ok=True)

TARGET_FILES = {
    "release": {
        "out_name": "android_release.apk",
        "start": 125835048,
        "comp_len": 103949600,
        "expected_uncomp": 104803333
    },
    "source": {
        "out_name": "android_source.zip",
        "start": 229784734,
        "comp_len": 214421853,
        "expected_uncomp": 214418211
    }
}

def download_chunk_curl(idx, chunk_start, chunk_end, chunk_path, max_retries=3):
    expected_bytes = chunk_end - chunk_start + 1
    if os.path.exists(chunk_path) and os.path.getsize(chunk_path) == expected_bytes:
        return idx, True, expected_bytes

    cmd = [
        "curl.exe", "-s",
        "-r", f"{chunk_start}-{chunk_end}",
        "-L", BASE_URL,
        "-o", chunk_path,
        "--retry", str(max_retries),
        "--retry-connrefused"
    ]
    res = subprocess.run(cmd)
    if res.returncode == 0 and os.path.exists(chunk_path) and os.path.getsize(chunk_path) == expected_bytes:
        return idx, True, expected_bytes
    return idx, False, 0

def process_file(key, num_chunks=8, max_workers=4):
    info = TARGET_FILES[key]
    out_name = info["out_name"]
    final_dest = os.path.join(TARGET_DIR, out_name)
    if os.path.exists(final_dest) and os.path.getsize(final_dest) == info["expected_uncomp"]:
        print(f"[OK] {out_name} already complete in {final_dest}.")
        return True

    print(f"\n==================================================")
    print(f"[*] Downloading {out_name} ({info['comp_len']/1024/1024:.2f} MB in {num_chunks} parallel chunks via curl)...")
    print(f"==================================================", flush=True)

    total_len = info["comp_len"]
    base_start = info["start"]
    chunk_size = (total_len + num_chunks - 1) // num_chunks

    tasks = []
    chunk_paths = []
    for i in range(num_chunks):
        c_start = base_start + i * chunk_size
        c_end = min(base_start + (i + 1) * chunk_size - 1, base_start + total_len - 1)
        c_path = os.path.join(CHUNK_TEMP_DIR, f"{key}_chunk_{i}.bin")
        chunk_paths.append(c_path)
        tasks.append((i, c_start, c_end, c_path))

    t0 = time.time()
    completed_chunks = 0
    total_bytes = 0
    with ThreadPoolExecutor(max_workers=max_workers) as executor:
        futures = {executor.submit(download_chunk_curl, *t): t[0] for t in tasks}
        for future in as_completed(futures):
            idx, success, nbytes = future.result()
            if success:
                completed_chunks += 1
                total_bytes += nbytes
                elapsed = time.time() - t0
                pct = (completed_chunks / num_chunks) * 100
                speed = (total_bytes / 1024 / 1024) / elapsed if elapsed > 0 else 0
                print(f"    [+] Chunk {idx+1:02d}/{num_chunks:02d} done ({pct:5.1f}%) | Speed: {speed:4.2f} MB/s | {elapsed:4.1f}s elapsed", flush=True)
            else:
                print(f"    [-] Chunk {idx+1} FAILED after retries!", flush=True)
                return False

    print(f"\n[*] All {num_chunks} chunks downloaded in {time.time() - t0:.1f}s. Decompressing raw deflate...", flush=True)
    decompressor = zlib.decompressobj(-zlib.MAX_WBITS)
    temp_final = final_dest + ".tmp"
    written_bytes = 0
    with open(temp_final, "wb") as out_f:
        for c_path in chunk_paths:
            with open(c_path, "rb") as cf:
                while True:
                    buf = cf.read(1024 * 1024)
                    if not buf:
                        break
                    decomp = decompressor.decompress(buf)
                    if decomp:
                        out_f.write(decomp)
                        written_bytes += len(decomp)
        tail = decompressor.flush()
        if tail:
            out_f.write(tail)
            written_bytes += len(tail)

    if os.path.exists(final_dest):
        os.remove(final_dest)
    os.rename(temp_final, final_dest)
    print(f"[OK] Successfully extracted {out_name} ({written_bytes} bytes).", flush=True)

    # Cleanup chunk files
    for cp in chunk_paths:
        try:
            os.remove(cp)
        except:
            pass
    return True

if __name__ == "__main__":
    target = sys.argv[1] if len(sys.argv) > 1 else "release"
    success = process_file(target)
    sys.exit(0 if success else 1)
