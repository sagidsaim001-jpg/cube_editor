# Cube Editor

Flutter Android app source. Pushes to `main` trigger the **Build APK** GitHub Actions workflow. The release APK is uploaded as the `cube-editor-apk` artifact.

## Build locally

```bash
flutter pub get
flutter build apk --release
```

## Current features
- 3D cube preview with drag rotation
- Add text to the visible face
- Choose face colors and fonts
- Browse device audio tracks (permission required)

## Notes
Draft persistence, video import/preview, and keyframe editing are not implemented yet.
