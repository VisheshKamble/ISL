Place your licensed Google Sans font files here for exact app-wide rendering.

Required filenames (recommended):
- GoogleSans-Regular.ttf
- GoogleSans-Medium.ttf
- GoogleSans-Bold.ttf
- GoogleSans-Italic.ttf

After adding these files, update pubspec.yaml with:

flutter:
  uses-material-design: true
  fonts:
    - family: Google Sans
      fonts:
        - asset: assets/fonts/GoogleSans-Regular.ttf
        - asset: assets/fonts/GoogleSans-Medium.ttf
          weight: 500
        - asset: assets/fonts/GoogleSans-Bold.ttf
          weight: 700
        - asset: assets/fonts/GoogleSans-Italic.ttf
          style: italic
