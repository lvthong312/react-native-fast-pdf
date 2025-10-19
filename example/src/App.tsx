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
