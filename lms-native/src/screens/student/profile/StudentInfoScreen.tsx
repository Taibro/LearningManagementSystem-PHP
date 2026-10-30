import React, { useState, useEffect } from 'react';
import { View, Text, ScrollView, StyleSheet } from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import { AppHeader } from '../../../components/common/AppHeader';
import { SkeletonLoader } from '../../../components/ui/SkeletonLoader';
import { Colors } from '../../../constants/colors';
import { Shadows } from '../../../constants/theme';
import { studentApi } from '../../../api/studentApi';
import { StudentProfile } from '../../../types/student.types';

interface Props {
  onBack: () => void;
}

export const StudentInfoScreen: React.FC<Props> = ({ onBack }) => {
  const [profile, setProfile] = useState<StudentProfile | null>(null);

  useEffect(() => {
    studentApi.getProfile().then(setProfile).catch(() => {});
  }, []);

  if (!profile) {
    return (
      <View style={styles.container}>
        <AppHeader title="Thông tin sinh viên" onBack={onBack} />
        <View style={{ padding: 16 }}>
          <SkeletonLoader height={180} borderRadius={18} style={{ marginBottom: 16 }} />
          <SkeletonLoader height={180} borderRadius={18} style={{ marginBottom: 16 }} />
        </View>
      </View>
    );
  }

  const renderRow = (label: string, value: string, icon: keyof typeof Ionicons.glyphMap) => (
    <View style={styles.infoRow}>
      <View style={styles.iconTag}>
        <Ionicons name={icon} size={16} color={Colors.primary} />
      </View>
      <View style={styles.textCol}>
        <Text style={styles.rowLabel}>{label}</Text>
        <Text style={styles.rowValue}>{value}</Text>
      </View>
    </View>
  );

  return (
    <View style={styles.container}>
      <AppHeader title="Thông tin sinh viên" onBack={onBack} />

      <ScrollView contentContainerStyle={styles.scrollContent} showsVerticalScrollIndicator={false}>
        {/* Section 1: Thông tin cá nhân */}
        <Text style={styles.sectionTitle}>THÔNG TIN CÁ NHÂN</Text>
        <View style={[styles.card, Shadows.sm]}>
          {renderRow('Mã số sinh viên (MSSV)', profile.studentCode, 'card-outline')}
          <View style={styles.divider} />
          {renderRow('Họ và tên', profile.fullName, 'person-outline')}
          <View style={styles.divider} />
          {renderRow('Ngày sinh', profile.birthDate, 'calendar-outline')}
          <View style={styles.divider} />
          {renderRow('Giới tính', profile.gender === 'MALE' ? 'Nam' : 'Nữ', 'male-female-outline')}
          <View style={styles.divider} />
          {renderRow('Số CCCD / CMND', profile.idCard, 'finger-print-outline')}
          <View style={styles.divider} />
          {renderRow('Nơi sinh', profile.birthPlace, 'location-outline')}
        </View>

        {/* Section 2: Thông tin đào tạo */}
        <Text style={styles.sectionTitle}>THÔNG TIN HỌC VỤ & LỚP HỌC</Text>
        <View style={[styles.card, Shadows.sm]}>
          {renderRow('Lớp sinh hoạt', profile.className, 'people-outline')}
          <View style={styles.divider} />
          {renderRow('Chuyên ngành', profile.majorName, 'school-outline')}
          <View style={styles.divider} />
          {renderRow('Khoa quản lý', profile.facultyName, 'business-outline')}
          <View style={styles.divider} />
          {renderRow('Khóa tuyển sinh', profile.enrollmentYear, 'ribbon-outline')}
          <View style={styles.divider} />
          {renderRow('Thời gian đào tạo', `${profile.trainingDuration} năm (Chính quy)`, 'time-outline')}
        </View>

        {/* Section 3: Thông tin liên hệ */}
        <Text style={styles.sectionTitle}>THÔNG TIN LIÊN HỆ</Text>
        <View style={[styles.card, Shadows.sm]}>
          {renderRow('Email trường cấp', profile.email, 'mail-outline')}
          <View style={styles.divider} />
          {renderRow('Số điện thoại', profile.phone, 'call-outline')}
        </View>
      </ScrollView>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: Colors.bg,
  },
  scrollContent: {
    padding: 16,
    paddingBottom: 40,
  },
  sectionTitle: {
    fontSize: 12,
    fontWeight: '800',
    color: Colors.textMuted,
    marginBottom: 8,
    marginLeft: 4,
    letterSpacing: 0.5,
  },
  card: {
    backgroundColor: Colors.card,
    borderRadius: 18,
    padding: 14,
    marginBottom: 18,
    borderWidth: 1,
    borderColor: Colors.borderLight,
  },
  infoRow: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingVertical: 6,
  },
  iconTag: {
    width: 34,
    height: 34,
    borderRadius: 10,
    backgroundColor: Colors.primaryLight,
    alignItems: 'center',
    justifyContent: 'center',
    marginRight: 12,
  },
  textCol: {
    flex: 1,
  },
  rowLabel: {
    fontSize: 11,
    color: Colors.textMuted,
    fontWeight: '500',
  },
  rowValue: {
    fontSize: 14,
    fontWeight: '700',
    color: Colors.text,
    marginTop: 2,
  },
  divider: {
    height: 1,
    backgroundColor: Colors.borderLight,
    marginVertical: 4,
  },
});



