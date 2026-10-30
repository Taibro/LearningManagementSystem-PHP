import React from 'react';
import { View, StyleSheet } from 'react-native';
import { Colors } from '../../constants/colors';

interface Props {
  children: React.ReactNode;
}

export const MeshBackground: React.FC<Props> = ({ children }) => {
  return (
    <View style={styles.container}>
      <View style={[styles.blob, styles.blobTopRight]} />
      <View style={[styles.blob, styles.blobBottomLeft]} />
      {children}
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: Colors.bg,
    position: 'relative',
    overflow: 'hidden',
  },
  blob: {
    position: 'absolute',
    borderRadius: 999,
    opacity: 0.45,
  },
  blobTopRight: {
    width: 320,
    height: 320,
    backgroundColor: '#E0E7FF', // soft indigo
    top: -100,
    right: -80,
  },
  blobBottomLeft: {
    width: 280,
    height: 280,
    backgroundColor: '#DBEAFE', // soft blue
    bottom: 50,
    left: -80,
  },
});

