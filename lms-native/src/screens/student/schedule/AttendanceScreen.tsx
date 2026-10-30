import React, { useState, useEffect } from 'react';
import { View, Text, ScrollView, TouchableOpacity, StyleSheet, Alert } from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import { AppHeader } from '../../../components/common/AppHeader';
import { Colors } from '../../../constants/colors';
import { Shadows } from '../../../constants/theme';
import { AppModal, AppTextInput, AppButton } from '../../../components/ui';
import { studentApi } from '../../../api/studentApi';
import { AttendanceCourseStat } from '../../../types/student.types';

interface Props {
  onBack?: () => void;
  onGoToStats?: () => void;
}

export const AttendanceScreen: React.FC<Props> = ({ onBack, onGoToStats }) => {
  const [courses, setCourses] = useState<AttendanceCourseStat[]>([]);
  const [showCodeModal, setShowCodeModal] = useState(false);
  const [attendanceCode, setAttendanceCode] = useState('');
  const [codeError, setCodeError] = useState('');

  useEffect(() => {
    studentApi.getAttendanceCourses().then(setCourses).catch(() => {});
  }, []);

  const totalSessions = courses.reduce((acc, c) => acc + c.total, 0);
  const totalAttended = courses.reduce((acc, c) => acc + c.attended, 0);
  const totalExcused = courses.reduce((acc, c) => acc + c.excused, 0);
  const totalAbsent = courses.reduce((acc, c) => acc + c.absent, 0);
  const overallRate = totalSessions > 0 ? ((totalAttended / totalSessions) * 100).toFixed(1) : '100';

  const handleScanQR = () => {
    Alert.alert('Quét mã QR', 'Mở camera quét mã điểm danh hiển thị trên màn chiếu của giảng viên.');
  };

  const handleConfirmCode = () => {
    if (!attendanceCode.trim() || attendanceCode.trim().length < 4) {
      setCodeError('Vui lòng nhập mã điểm danh hợp lệ (4 - 6 ký tự).');
      return;
    }
    const entered = attendanceCode.trim();
    setShowCodeModal(false);
    setAttendanceCode('');
    setCodeError('');
    Alert.alert('Thành công', `Đã ghi nhận mã điểm danh: ${entered}. Chuyên cần của bạn đã được cập nhật!`);
  };

  return (
    <View style={styles.container}>
      <AppHeader
        title="Thông tin điểm danh"
        onBack={onBack}
        rightAction={
          onGoToStats ? (
            <TouchableOpacity onPress={onGoToStats} style={styles.statsBtn}>
              <Ionicons name="bar-chart-outline" size={20} color={Colors.primary} />
            </TouchableOpacity>
          ) : null
        }
      />

      <ScrollView contentContainerStyle={styles.scrollContent} showsVerticalScrollIndicator={false}>
        {/* QR Check-in Card */}
        <View style={[styles.qrCard, Shadows.md]}>
          <View style={styles.qrIconWrap}>
            <Ionicons name="qr-code" size={36} color="#FFFFFF" />
          </View>
          <Text style={styles.qrTitle}>Điểm danh lớp học hôm nay</Text>
          <Text style={styles.qrSub}>Quét mã QR từ màn hình của giảng viên hoặc nhập mã 6 số để ghi nhận chuyên cần.</Text>

          <View style={styles.qrActionRow}>
            <TouchableOpacity style={styles.scanBtn} onPress={handleScanQR} activeOpacity={0.8}>
              <Ionicons name="camera" size={18} color="#FFFFFF" style={{ marginRight: 6 }} />
              <Text style={styles.scanBtnText}>Quét mã QR</Text>
            </TouchableOpacity>

            <TouchableOpacity
              style={styles.inputCodeBtn}
              onPress={() => setShowCodeModal(true)}
              activeOpacity={0.8}
            >
              <Text style={styles.inputCodeText}>Nhập mã số</Text>
            </TouchableOpacity>
          </View>
        </View>

        {/* Stats Summary Cards */}
        <Text style={styles.sectionTitle}>Tổng quan chuyên cần học kỳ</Text>
        <View style={styles.statsRow}>
          <View style={[styles.statBox, { backgroundColor: Colors.successLight }]}>
            <Text style={[styles.statNum, { color: Colors.success }]}>{totalAttended}</Text>
            <Text style={styles.statLabel}>Có mặt ({overallRate}%)</Text>
          </View>
          <View style={[styles.statBox, { backgroundColor: Colors.warningLight }]}>
            <Text style={[styles.statNum, { color: Colors.warning }]}>{totalExcused}</Text>
            <Text style={styles.statLabel}>Có phép</Text>
          </View>
          <View style={[styles.statBox, { backgroundColor: Colors.dangerLight }]}>
            <Text style={[styles.statNum, { color: Colors.danger }]}>{totalAbsent}</Text>
            <Text style={styles.statLabel}>Vắng</Text>
          </View>
        </View>

        {/* Attendance by Course */}
        <Text style={styles.sectionTitle}>Chi tiết theo môn học ({courses.length})</Text>
        {courses.map((item) => (
          <View key={item.code} style={[styles.courseCard, Shadows.sm]}>
            <View style={styles.courseHeader}>
              <View style={styles.courseLeft}>
                <Text style={styles.courseCode}>{item.code}</Text>
                <Text style={styles.courseName}>{item.name}</Text>
              </View>
              <Text style={[styles.percentBadge, item.percent >= 90 ? styles.percentHigh : styles.percentMedium]}>
                {item.percent}%
              </Text>
            </View>

            {/* Progress bar */}
            <View style={styles.progressBarBg}>
              <View style={[styles.progressBarFill, { width: `${item.percent}%`, backgroundColor: item.percent >= 90 ? Colors.success : Colors.warning }]} />
            </View>

            <View style={styles.courseFooter}>
              <Text style={styles.footerText}>Đã học: {item.total} buổi</Text>
              <Text style={styles.footerText}>• Có mặt: {item.attended}</Text>
              {item.excused > 0 && <Text style={[styles.footerText, { color: Colors.warning }]}>• Phép: {item.excused}</Text>}
              <Text style={[styles.footerText, item.absent > 0 && { color: Colors.danger, fontWeight: '700' }]}>
                • Vắng: {item.absent}
              </Text>
            </View>
          </View>
        ))}
      </ScrollView>

      {/* Cross-platform Modal for entering attendance code */}
      <AppModal
        visible={showCodeModal}
        title="Nhập mã điểm danh"
        onClose={() => {
          setShowCodeModal(false);
          setCodeError('');
        }}
      >
        <Text style={styles.modalSub}>
          Nhập mã 4 - 6 chữ số do giảng viên cung cấp trên lớp để xác nhận điểm danh:
        </Text>
        <AppTextInput
          placeholder="Ví dụ: 839201"
          value={attendanceCode}
          onChangeText={(txt) => {
            setAttendanceCode(txt);
            if (codeError) setCodeError('');
          }}
          keyboardType="number-pad"
          maxLength={8}
          autoFocus
          error={codeError}
        />
        <View style={styles.modalActions}>
          <AppButton
            title="Xác nhận"
            onPress={handleConfirmCode}
            variant="primary"
            size="md"
            style={{ flex: 1 }}
          />
          <AppButton
            title="Đóng"
            onPress={() => {
              setShowCodeModal(false);
              setCodeError('');
            }}
            variant="outline"
            size="md"
            style={{ flex: 1 }}
          />
        </View>
      </AppModal>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: Colors.bg,
  },
  statsBtn: {
    width: 36,
    height: 36,
    borderRadius: 18,
    backgroundColor: Colors.primaryLight,
    alignItems: 'center',
    justifyContent: 'center',
  },
  scrollContent: {
    padding: 16,
    paddingBottom: 100,
  },
  qrCard: {
    backgroundColor: Colors.primary,
    borderRadius: 20,
    padding: 20,
    alignItems: 'center',
    marginBottom: 20,
  },
  qrIconWrap: {
    width: 64,
    height: 64,
    borderRadius: 32,
    backgroundColor: 'rgba(255,255,255,0.2)',
    alignItems: 'center',
    justifyContent: 'center',
    marginBottom: 12,
  },
  qrTitle: {
    fontSize: 18,
    fontWeight: '800',
    color: '#FFFFFF',
    marginBottom: 6,
    textAlign: 'center',
  },
  qrSub: {
    fontSize: 13,
    color: 'rgba(255,255,255,0.85)',
    textAlign: 'center',
    lineHeight: 18,
    marginBottom: 16,
    paddingHorizontal: 8,
  },
  qrActionRow: {
    flexDirection: 'row',
    gap: 12,
    width: '100%',
  },
  scanBtn: {
    flex: 1,
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    backgroundColor: 'rgba(255,255,255,0.25)',
    paddingVertical: 12,
    borderRadius: 12,
  },
  scanBtnText: {
    fontSize: 14,
    fontWeight: '700',
    color: '#FFFFFF',
  },
  inputCodeBtn: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
    backgroundColor: '#FFFFFF',
    paddingVertical: 12,
    borderRadius: 12,
  },
  inputCodeText: {
    fontSize: 14,
    fontWeight: '700',
    color: Colors.primary,
  },
  sectionTitle: {
    fontSize: 15,
    fontWeight: '800',
    color: Colors.text,
    marginBottom: 12,
  },
  statsRow: {
    flexDirection: 'row',
    gap: 10,
    marginBottom: 20,
  },
  statBox: {
    flex: 1,
    paddingVertical: 14,
    paddingHorizontal: 10,
    borderRadius: 14,
    alignItems: 'center',
  },
  statNum: {
    fontSize: 20,
    fontWeight: '800',
    marginBottom: 2,
  },
  statLabel: {
    fontSize: 11,
    color: Colors.textSecondary,
    fontWeight: '600',
  },
  courseCard: {
    backgroundColor: Colors.card,
    borderRadius: 16,
    padding: 16,
    marginBottom: 12,
    borderWidth: 1,
    borderColor: Colors.borderLight,
  },
  courseHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'flex-start',
    marginBottom: 10,
  },
  courseLeft: {
    flex: 1,
    paddingRight: 10,
  },
  courseCode: {
    fontSize: 11,
    color: Colors.textMuted,
    fontWeight: '600',
    marginBottom: 2,
  },
  courseName: {
    fontSize: 14,
    fontWeight: '700',
    color: Colors.text,
  },
  percentBadge: {
    fontSize: 13,
    fontWeight: '800',
    paddingHorizontal: 8,
    paddingVertical: 4,
    borderRadius: 8,
  },
  percentHigh: {
    backgroundColor: Colors.successLight,
    color: Colors.success,
  },
  percentMedium: {
    backgroundColor: Colors.warningLight,
    color: Colors.warning,
  },
  progressBarBg: {
    height: 6,
    backgroundColor: Colors.borderLight,
    borderRadius: 3,
    overflow: 'hidden',
    marginBottom: 12,
  },
  progressBarFill: {
    height: '100%',
    borderRadius: 3,
  },
  courseFooter: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    gap: 4,
  },
  footerText: {
    fontSize: 11,
    color: Colors.textMuted,
    fontWeight: '500',
  },
  modalSub: {
    fontSize: 13,
    color: Colors.textSecondary,
    lineHeight: 18,
    marginBottom: 12,
  },
  modalActions: {
    flexDirection: 'row',
    gap: 10,
    marginTop: 8,
  },
});
