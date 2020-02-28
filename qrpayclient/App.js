import React from 'react';
import { StyleSheet, Text, View } from 'react-native';
import QrScanner from './QrScanner';

export default function App() {
  return (
    <View style={styles.container}>
      <QrScanner/>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#fff',
    alignItems: 'center',
    justifyContent: 'center',
  },
});
