import React from 'react';
import { View, Text, TouchableOpacity, StyleSheet } from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { Ionicons } from '@expo/vector-icons';
import { Colors } from '../../constants/colors';
import { Shadows } from '../../constants/theme';

export type TabKey = 'home' | 'schedule' | 'attendance' | 'profile';

interface Props {
  activeTab: TabKey;
  onTabChange: (tab: TabKey) => void;
}

export const FloatingBottomNav: React.FC<Props> = ({ activeTab, onTabChange }) => {
  const insets = useSafeAreaInsets();
  const bottomInset = Math.max(insets.bottom, 12) + 6;

  const tabs: { key: TabKey; label: string; icon: keyof typeof Ionicons.glyphMap; activeIcon: keyof typeof Ionicons.glyphMap }[] = [
    { key: 'home', label: 'Trang chủ', icon: 'home-outline', activeIcon: 'home' },
    { key: 'schedule', label: 'Lịch học', icon: 'calendar-outline', activeIcon: 'calendar' },
    { key: 'attendance', label: 'Điểm danh', icon: 'checkbox-outline', activeIcon: 'checkbox' },
    { key: 'profile', label: 'Cá nhân', icon: 'person-outline', activeIcon: 'person' },
  ];

  return (
    <View style={[styles.wrapper, { bottom: bottomInset }]}>
      <View style={[styles.container, Shadows.lg]}>
        {tabs.map((tab) => {
          const isActive = activeTab === tab.key;
          return (
            <TouchableOpacity
              key={tab.key}
              style={styles.tabItem}
              onPress={() => onTabChange(tab.key)}
              activeOpacity={0.7}
            >
              <View style={[styles.iconWrap, isActive && styles.iconWrapActive]}>
                <Ionicons
                  name={isActive ? tab.activeIcon : tab.icon}
                  size={22}
                  color={isActive ? Colors.indigo : Colors.textMuted}
                />
              </View>
              <Text style={[styles.label, isActive && styles.labelActive]}>
                {tab.label}
              </Text>
            </TouchableOpacity>
          );
        })}
      </View>
    </View>
  );
};

const styles = StyleSheet.create({
  wrapper: {
    position: 'absolute',
    left: 20,
    right: 20,
    alignItems: 'center',
    zIndex: 99,
  },
  container: {
    width: '100%',
    maxWidth: 420,
    height: 68,
    backgroundColor: 'rgba(255, 255, 255, 0.94)',
    borderRadius: 34,
    borderWidth: 1.5,
    borderColor: '#FFFFFF',
    flexDirection: 'row',
    justifyContent: 'space-around',
    alignItems: 'center',
    paddingHorizontal: 8,
  },
  tabItem: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
    paddingVertical: 6,
  },
  iconWrap: {
    width: 38,
    height: 38,
    borderRadius: 19,
    alignItems: 'center',
    justifyContent: 'center',
    marginBottom: 2,
  },
  iconWrapActive: {
    backgroundColor: 'rgba(79, 70, 229, 0.1)',
  },
  label: {
    fontSize: 10,
    fontWeight: '500',
    color: Colors.textMuted,
  },
  labelActive: {
    fontWeight: '700',
    color: Colors.indigo,
  },
});
