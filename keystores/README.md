# Keystore Information for Release Builds

- **File:** `release.keystore` (Excluded from git tracking for security)
- **Alias:** `arrowescape`
- **Keystore Password:** `ArrowEscapeRelease2026!`
- **Key Password:** `ArrowEscapeRelease2026!`
- **Algorithm:** RSA 2048-bit (SHA256withRSA)
- **Validity:** 10,000 Days

### Regenerating Keystore (if needed)
```powershell
& "C:\Program Files\Eclipse Adoptium\jdk-17.0.20.101-hotspot\bin\keytool.exe" -genkeypair -v -keystore "keystores\release.keystore" -alias "arrowescape" -keyalg RSA -keysize 2048 -validity 10000 -storepass "ArrowEscapeRelease2026!" -keypass "ArrowEscapeRelease2026!" -dname "CN=Developer Arslan Ali, OU=Games, O=Indie, C=PK"
```
