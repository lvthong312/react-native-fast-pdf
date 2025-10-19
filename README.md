# react-native-fast-pdf

Support for PDF

<p align="center">
  <img src="https://img.shields.io/npm/v/react-native-fast-pdf?color=green" alt="npm version" />
  <img src="https://img.shields.io/npm/dm/react-native-fast-pdf" alt="npm downloads" />
  <img src="https://img.shields.io/badge/react--native-0.70+-blue" alt="react-native" />
</p>


## Installation


```sh
npm install react-native-fast-pdf
```
At AndroidManifest.xml add 
```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">

    <uses-permission android:name="android.permission.INTERNET" />

    <application
        .....
      android:supportsRtl="true">

      <activity
         ...
        android:exported="true">
        <intent-filter>
          ...
        </intent-filter>
      </activity>

      <!-- ✅ Thêm FileProvider ở đây -->
      <provider
        android:name="androidx.core.content.FileProvider"
        android:authorities="${applicationId}.provider"
        android:exported="false"
        android:grantUriPermissions="true">
        <meta-data
          android:name="android.support.FILE_PROVIDER_PATHS"
          android:resource="@xml/provider_paths" />
      </provider>

    </application>

</manifest>
```

At android/app/src/main/res/xml/provider_paths.xml Add 

```xml
<?xml version="1.0" encoding="utf-8"?>
<paths xmlns:android="http://schemas.android.com/apk/res/android">
  <external-files-path name="external_files" path="." />
  <files-path name="internal_files" path="." />
  <cache-path name="cache" path="." />
</paths>
```

## For use DownloadPdf (optional)
At AndroidManifest.xml add 

```xml
    <uses-permission android:name="android.permission.INTERNET" />
    <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
    <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
```

At info.plist add 

```sh
<key>UIFileSharingEnabled</key>
<true/>
<key>LSSupportsOpeningDocumentsInPlace</key>
<true/>
```

## Usage


```js
import { Button, StyleSheet, View } from 'react-native';
import { downloadPdf, openPdf } from 'react-native-fast-pdf';

export default function App() {
  return (
    <View style={styles.container}>
      <Button
        title="Open PDF"
        onPress={async () => {
          try {
            const fileUri = await openPdf('https://....pdf');
            console.log('Opened File: ', fileUri);
          } catch (error) {
            console.log('Open failed: ', error);
          }
        }}
      />
      <Button
        title="Download PDF"
        onPress={async () => {
          try {
            const downloadUri = await downloadPdf('https://....pdf');
            console.log('Saved file: ', downloadUri);
            await openPdf(`file://${downloadUri}`);
          } catch (error) {
            console.log('Download Or Open Failed', error);
          }
        }}
      />
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
  },
});


```
| Tính năng                | Android | iOS |
| ------------------------ | :-----: | :-: |
| Mở PDF local (`file://`) |    ✅    | ✅  |
| Mở PDF online (URL)      |    ✅    | ✅  |
