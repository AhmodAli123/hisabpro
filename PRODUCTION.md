Production build and release checklist for HisabPro

1) App signing and AAB
- Generate a signing key (keystore) and keep it secret.
- Configure `key.properties` with `storePassword`, `keyPassword`, `keyAlias`, and `storeFile` and ensure it is added to `.gitignore`.
- Build an AAB locally:

```bash
flutter build appbundle --release
```

2) CI: example GitHub Actions (see .github/workflows/build.yml)
- Set secrets: `ANDROID_KEYSTORE_BASE64` (base64-encoded keystore), `KEYSTORE_PASSWORD`, `KEY_ALIAS`, `KEY_PASSWORD`, `SUPABASE_URL`, `SUPABASE_ANON_KEY`.
- The workflow decodes the keystore, writes `key.properties`, and builds an AAB.

3) Supabase env management
- Never commit `SUPABASE_ANON_KEY` to public repos.
- For mobile apps, use RLS and server-side functions when needing service-role access. Keep sensitive keys on server/CI only.

4) App metadata
- Set app name, applicationId, versionCode in `android/app/build.gradle` and update `AndroidManifest.xml` for permissions.
- Configure `res/mipmap-*/ic_launcher.png` for all densities (use `flutter_launcher_icons` package or manual assets).

5) Privacy & permissions
- Add `INTERNET`, `WRITE_EXTERNAL_STORAGE` (if needed), and camera/storage permissions to `AndroidManifest.xml`.
- Document privacy policy and provide a link in Play Console.

6) Testing
- Test notifications, image picker, and storage on real devices (Android 11+ scoped storage differences).
- Test account flows with Supabase and verify RLS policies restrict data access.

7) Rollout
- Upload AAB to Play Console; use staged rollout for the first release.

Notes
- The repo includes a sample GitHub Actions workflow at `.github/workflows/build.yml` to help with CI-based builds.
- I can add the workflow file and key handling if you want me to.