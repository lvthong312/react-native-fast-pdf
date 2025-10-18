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

## Usage


```js
import { Button, StyleSheet, View } from 'react-native';
import { openPdf } from 'react-native-fast-pdf';

export default function App() {
  return (
    <View style={styles.container}>
      <Button
        title="Open PDF"
        onPress={async () => {
          const result = await openPdf('https:// or file://');
          console.log('result', result)
        }}
      />
    </View>
  );read
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
