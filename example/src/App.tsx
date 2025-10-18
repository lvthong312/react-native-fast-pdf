import { Button, StyleSheet, View } from 'react-native';
import { openPdf } from 'react-native-fast-pdf';

export default function App() {
  return (
    <View style={styles.container}>
      <Button
        title="Open PDF"
        onPress={async () => {
          const result = await openPdf('https://....pdf');
          console.log('result', result);
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
