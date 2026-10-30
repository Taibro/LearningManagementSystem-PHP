import React from 'react';
import { View, Text, TouchableOpacity, StyleSheet } from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { Ionicons } from '@expo/vector-icons';
import { Colors } from '../../constants/colors';
import { StudentProfile } from '../../types/student.types';

interface Props {
  profile: StudentProfile;
  onNotificationPress: () => void;
  onProfilePress: () => void;
}

export const HomeHeader: React.FC<Props> = ({ profile, onNotificationPress, onProfilePress }) => {
  const insets = useSafeAreaInsets();
  const getInitials = (name: string) => {
    const parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return (parts[parts.length - 2][0] + parts[parts.length - 1][0]).toUpperCase();
    }
    return name.slice(0, 2).toUpperCase();
  };

  return (
    <View style={[styles.container, { paddingTop: Math.max(insets.top, 12) }]}>
      <View style={styles.left}>
        <Text style={styles.schoolTitle}>TRƯỜNG ĐẠI HỌC CÔNG THƯƠNG TP.HCM</Text>
        <Text style={styles.greeting}>Chào {profile.fullName} 👋</Text>
        <Text style={styles.subtext}>MSSV: {profile.studentCode} • Lớp: {profile.className}</Text>
      </View>

      <View style={styles.right}>
        <TouchableOpacity style={styles.iconBtn} onPress={onNotificationPress} activeOpacity={0.7}>
          <Ionicons name="notifications-outline" size={22} color={Colors.text} />
          <View style={styles.badge}>
            <Text style={styles.badgeText}>3</Text>
          </View>
        </TouchableOpacity>

        <TouchableOpacity style={styles.avatarBtn} onPress={onProfilePress} activeOpacity={0.7}>
          <Text style={styles.avatarText}>{getInitials(profile.fullName)}</Text>
        </TouchableOpacity>
      </View>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    paddingHorizontal: 20,
    paddingTop: 12,
    paddingBottom: 8,
  },
  left: {
    flex: 1,
  },
  schoolTitle: {
    fontSize: 10,
    fontWeight: '800',
    color: Colors.primary,
    letterSpacing: 0.5,
    marginBottom: 2,
    textTransform: 'uppercase',
  },
  greeting: {
    fontSize: 19,
    fontWeight: '800',
    color: Colors.text,
  },
  subtext: {
    fontSize: 12,
    color: Colors.textMuted,
    marginTop: 2,
  },
  right: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 10,
  },
  iconBtn: {
    width: 40,
    height: 40,
    borderRadius: 20,
    backgroundColor: Colors.card,
    alignItems: 'center',
    justifyContent: 'center',
    borderWidth: 1,
    borderColor: Colors.borderLight,
    position: 'relative',
  },
  badge: {
    position: 'absolute',
    top: 4,
    right: 4,
    backgroundColor: Colors.danger,
    borderRadius: 8,
    minWidth: 16,
    height: 16,
    alignItems: 'center',
    justifyContent: 'center',
    paddingHorizontal: 3,
  },
  badgeText: {
    color: '#FFF',
    fontSize: 9,
    fontWeight: '700',
  },
  avatarBtn: {
    width: 42,
    height: 42,
    borderRadius: 21,
    backgroundColor: Colors.primary,
    alignItems: 'center',
    justifyContent: 'center',
    borderWidth: 2,
    borderColor: '#FFFFFF',
  },
  avatarText: {
    color: '#FFF',
    fontWeight: '800',
    fontSize: 14,
  },
});

