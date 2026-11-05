import React, { useRef } from 'react';
import {
  Animated,
  PanResponder,
  StyleSheet,
  Platform,
} from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import { Colors } from '../../constants/colors';
import { Shadows } from '../../constants/theme';

interface Props {
  onPress: () => void;
}

const BUTTON_SIZE = 56;

export const DraggableChatbotButton: React.FC<Props> = ({ onPress }) => {
  const pan = useRef(new Animated.ValueXY({ x: 0, y: 0 })).current;
  const isDragging = useRef(false);

  const panResponder = useRef(
    PanResponder.create({
      onStartShouldSetPanResponder: () => true,
      onMoveShouldSetPanResponder: (_, gestureState) => {
        return Math.abs(gestureState.dx) > 4 || Math.abs(gestureState.dy) > 4;
      },
      onPanResponderGrant: () => {
        isDragging.current = false;
        pan.setOffset({
          x: (pan.x as any)._value,
          y: (pan.y as any)._value,
        });
        pan.setValue({ x: 0, y: 0 });
      },
      onPanResponderMove: (_, gestureState) => {
        if (Math.abs(gestureState.dx) > 5 || Math.abs(gestureState.dy) > 5) {
          isDragging.current = true;
        }
        Animated.event([null, { dx: pan.x, dy: pan.y }], { useNativeDriver: false })(
          _,
          gestureState
        );
      },
      onPanResponderRelease: (_, gestureState) => {
        pan.flattenOffset();
        // Nếu không di chuyển đáng kể -> coi là Click/Tap
        if (!isDragging.current && Math.abs(gestureState.dx) < 6 && Math.abs(gestureState.dy) < 6) {
          onPress();
        }
      },
    })
  ).current;

  return (
    <Animated.View
      style={[
        styles.button,
        Shadows.lg,
        {
          transform: [{ translateX: pan.x }, { translateY: pan.y }],
        },
      ]}
      {...panResponder.panHandlers}
    >
      <Ionicons name="sparkles" size={24} color="#FFFFFF" />
    </Animated.View>
  );
};

const styles = StyleSheet.create({
  button: {
    position: 'absolute',
    right: 20,
    bottom: Platform.OS === 'ios' ? 104 : 96,
    width: BUTTON_SIZE,
    height: BUTTON_SIZE,
    borderRadius: BUTTON_SIZE / 2,
    backgroundColor: Colors.primary,
    alignItems: 'center',
    justifyContent: 'center',
    zIndex: 90,
    borderWidth: 2,
    borderColor: '#FFFFFF',
  },
});
