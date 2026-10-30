import React from 'react';
import { View, Text, Modal, TouchableOpacity, StyleSheet } from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import { Colors } from '../../constants/colors';
import { Shadows } from '../../constants/theme';
import { formatCurrency } from '../../utils';

interface Props {
  visible: boolean;
  onClose: () => void;
  onGoToReceipts: () => void;
  amount?: number | string;
  semesterName?: string;
  isPaid?: boolean;
}

export const PaymentBottomSheet: React.FC<Props> = ({
  visible,
  onClose,
  onGoToReceipts,
  amount = 17205000,
  semesterName = 'Học phí HK2 (2025 - 2026)',
  isPaid = true,
}) => {
  return (
    <Modal visible={visible} transparent animationType="slide" onRequestClose={onClose}>
      <View style={styles.overlay}>
        <View style={[styles.sheet, Shadows.lg]}>
          <View style={styles.indicator} />

          <View style={styles.header}>
            <Text style={styles.title}>Thanh toán học phí trực tuyến</Text>
            <TouchableOpacity onPress={onClose} style={styles.closeBtn}>
              <Ionicons name="close" size={20} color={Colors.textMuted} />
            </TouchableOpacity>
          </View>

          <View style={styles.amountBox}>
            <Text style={styles.amountLabel}>{semesterName}</Text>
            <Text style={styles.amountValue}>{formatCurrency(amount)}</Text>
            <View style={styles.statusRow}>
              <View style={[styles.dot, !isPaid && { backgroundColor: Colors.warning }]} />
              <Text style={[styles.statusText, !isPaid && { color: Colors.warning }]}>
                {isPaid ? 'Đã hoàn thành thanh toán' : 'Chưa hoàn tất thanh toán'}
              </Text>
            </View>
          </View>

          <Text style={styles.methodTitle}>Cổng thanh toán liên kết</Text>
          <View style={styles.methodCard}>
            <Ionicons name="card-outline" size={24} color={Colors.primary} />
            <View style={styles.methodInfo}>
              <Text style={styles.methodName}>Cổng thanh toán OCB / VNPAY</Text>
              <Text style={styles.methodSub}>Hỗ trợ thẻ ATM, Visa/Master, QR Code</Text>
            </View>
          </View>

          <TouchableOpacity style={styles.receiptBtn} onPress={onGoToReceipts} activeOpacity={0.8}>
            <Ionicons name="receipt-outline" size={18} color={Colors.primary} style={{ marginRight: 6 }} />
            <Text style={styles.receiptBtnText}>Xem phiếu thu & lịch sử giao dịch</Text>
          </TouchableOpacity>
        </View>
      </View>
    </Modal>
  );
};

const styles = StyleSheet.create({
  overlay: {
    flex: 1,
    backgroundColor: 'rgba(15, 23, 42, 0.45)',
    justifyContent: 'flex-end',
  },
  sheet: {
    backgroundColor: Colors.card,
    borderTopLeftRadius: 28,
    borderTopRightRadius: 28,
    paddingHorizontal: 20,
    paddingBottom: 34,
    paddingTop: 12,
  },
  indicator: {
    width: 44,
    height: 4,
    backgroundColor: Colors.border,
    borderRadius: 2,
    alignSelf: 'center',
    marginBottom: 16,
  },
  header: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 18,
  },
  title: {
    fontSize: 17,
    fontWeight: '800',
    color: Colors.text,
  },
  closeBtn: {
    padding: 4,
  },
  amountBox: {
    backgroundColor: Colors.bg,
    borderRadius: 16,
    padding: 16,
    borderWidth: 1,
    borderColor: Colors.borderLight,
    marginBottom: 18,
  },
  amountLabel: {
    fontSize: 12,
    color: Colors.textSecondary,
    marginBottom: 4,
    fontWeight: '600',
  },
  amountValue: {
    fontSize: 22,
    fontWeight: '800',
    color: Colors.primary,
    marginBottom: 8,
  },
  statusRow: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 6,
  },
  dot: {
    width: 8,
    height: 8,
    borderRadius: 4,
    backgroundColor: Colors.success,
  },
  statusText: {
    fontSize: 12,
    fontWeight: '600',
    color: Colors.success,
  },
  methodTitle: {
    fontSize: 13,
    fontWeight: '700',
    color: Colors.textSecondary,
    marginBottom: 8,
  },
  methodCard: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: Colors.card,
    borderRadius: 14,
    padding: 14,
    borderWidth: 1,
    borderColor: Colors.borderLight,
    marginBottom: 16,
  },
  methodInfo: {
    marginLeft: 12,
  },
  methodName: {
    fontSize: 14,
    fontWeight: '700',
    color: Colors.text,
    marginBottom: 2,
  },
  methodSub: {
    fontSize: 11,
    color: Colors.textMuted,
  },
  receiptBtn: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    backgroundColor: Colors.primaryLight,
    paddingVertical: 14,
    borderRadius: 14,
  },
  receiptBtnText: {
    fontSize: 14,
    fontWeight: '700',
    color: Colors.primary,
  },
});
