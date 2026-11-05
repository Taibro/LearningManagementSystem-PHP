import React, { useState, useEffect, useCallback } from 'react';
import { View, Text, FlatList, TouchableOpacity, StyleSheet, Alert, RefreshControl } from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import { AppHeader } from '../../../components/common/AppHeader';
import { Colors } from '../../../constants/colors';
import { Shadows } from '../../../constants/theme';
import { EmptyState } from '../../../components/ui';
import { studentApi } from '../../../api/studentApi';
import { Receipt } from '../../../types/student.types';
import { formatCurrency } from '../../../utils';
import { useRefresh } from '../../../hooks/useRefresh';

interface Props {
  onBack: () => void;
  onGoToTransactions?: () => void;
}

export const ReceiptScreen: React.FC<Props> = ({ onBack, onGoToTransactions }) => {
  const [receipts, setReceipts] = useState<Receipt[]>([]);

  const fetchReceipts = useCallback(async () => {
    try {
      const data = await studentApi.getReceipts();
      setReceipts(data);
    } catch (err) {
      console.warn('[ReceiptScreen] Failed to fetch receipts:', err);
    }
  }, []);

  useEffect(() => {
    fetchReceipts();
  }, [fetchReceipts]);

  const { refreshing, onRefresh } = useRefresh(fetchReceipts);

  const totalPaid = receipts.reduce((sum, item) => sum + (item.amount || 0), 0);

  const renderReceiptItem = useCallback(
    ({ item }: { item: Receipt }) => (
      <View style={[styles.receiptCard, Shadows.sm]}>
        <View style={styles.cardHeader}>
          <View style={styles.iconTag}>
            <Ionicons name="receipt-outline" size={20} color={Colors.primary} />
          </View>
          <View style={styles.headerInfo}>
            <Text style={styles.receiptNum}>Số phiếu: {item.receiptNumber}</Text>
            <Text style={styles.dateTime}>{item.dateTime}</Text>
          </View>
          <Text style={styles.amountText}>{formatCurrency(item.amount)}</Text>
        </View>

        <View style={styles.divider} />

        <View style={styles.detailsRow}>
          <Text style={styles.detailsLabel}>Đơn vị thu:</Text>
          <Text style={styles.detailsVal}>{item.collector}</Text>
        </View>

        <View style={styles.actionsRow}>
          <TouchableOpacity
            style={styles.invoiceBtn}
            onPress={() =>
              Alert.alert(
                'Hóa đơn điện tử',
                `Mã tra cứu hóa đơn điện tử: HD-${item.receiptNumber}`
              )
            }
            activeOpacity={0.7}
          >
            <Ionicons
              name="document-text-outline"
              size={16}
              color={Colors.primary}
              style={{ marginRight: 4 }}
            />
            <Text style={styles.invoiceBtnText}>Xem hóa đơn điện tử</Text>
          </TouchableOpacity>
        </View>
      </View>
    ),
    []
  );

  const renderHeader = () => (
    <View>
      <View style={styles.summaryCard}>
        <Text style={styles.summaryLabel}>Tổng số tiền đã nộp (Các học kỳ)</Text>
        <Text style={styles.summaryAmount}>{formatCurrency(totalPaid)}</Text>
        <Text style={styles.summaryNote}>Tất cả các khoản thu đều có hóa đơn điện tử hợp lệ</Text>
      </View>

      <Text style={styles.listTitle}>Danh sách phiếu thu ({receipts.length})</Text>
    </View>
  );

  const renderEmpty = () => (
    <EmptyState
      icon="receipt-outline"
      title="Chưa có phiếu thu"
      description="Bạn chưa có phiếu thu học phí nào được ghi nhận trên hệ thống."
    />
  );

  return (
    <View style={styles.container}>
      <AppHeader
        title="Phiếu thu học phí"
        onBack={onBack}
        rightAction={
          onGoToTransactions ? (
            <TouchableOpacity onPress={onGoToTransactions} style={styles.historyBtn}>
              <Ionicons name="swap-horizontal" size={20} color={Colors.primary} />
            </TouchableOpacity>
          ) : null
        }
      />

      <FlatList
        data={receipts}
        keyExtractor={(item) => item.receiptNumber}
        renderItem={renderReceiptItem}
        ListHeaderComponent={renderHeader}
        ListEmptyComponent={renderEmpty}
        contentContainerStyle={styles.scrollContent}
        showsVerticalScrollIndicator={false}
        initialNumToRender={5}
        maxToRenderPerBatch={10}
        windowSize={5}
        removeClippedSubviews
        refreshControl={
          <RefreshControl refreshing={refreshing} onRefresh={onRefresh} colors={[Colors.primary]} />
        }
      />
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: Colors.bg,
  },
  historyBtn: {
    width: 36,
    height: 36,
    borderRadius: 18,
    backgroundColor: Colors.primaryLight,
    alignItems: 'center',
    justifyContent: 'center',
  },
  scrollContent: {
    padding: 16,
    paddingBottom: 40,
  },
  summaryCard: {
    backgroundColor: Colors.primary,
    borderRadius: 16,
    padding: 20,
    marginBottom: 20,
    alignItems: 'center',
  },
  summaryLabel: {
    fontSize: 12,
    color: 'rgba(255,255,255,0.8)',
    fontWeight: '600',
    marginBottom: 6,
    textTransform: 'uppercase',
  },
  summaryAmount: {
    fontSize: 24,
    fontWeight: '800',
    color: '#FFFFFF',
    marginBottom: 6,
  },
  summaryNote: {
    fontSize: 11,
    color: 'rgba(255,255,255,0.7)',
  },
  listTitle: {
    fontSize: 15,
    fontWeight: '700',
    color: Colors.text,
    marginBottom: 12,
  },
  receiptCard: {
    backgroundColor: Colors.card,
    borderRadius: 16,
    padding: 16,
    marginBottom: 12,
    borderWidth: 1,
    borderColor: Colors.borderLight,
  },
  cardHeader: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  iconTag: {
    width: 40,
    height: 40,
    borderRadius: 12,
    backgroundColor: Colors.primaryLight,
    alignItems: 'center',
    justifyContent: 'center',
    marginRight: 12,
  },
  headerInfo: {
    flex: 1,
  },
  receiptNum: {
    fontSize: 14,
    fontWeight: '700',
    color: Colors.text,
  },
  dateTime: {
    fontSize: 11,
    color: Colors.textMuted,
    marginTop: 2,
  },
  amountText: {
    fontSize: 14,
    fontWeight: '800',
    color: Colors.primary,
  },
  divider: {
    height: 1,
    backgroundColor: Colors.borderLight,
    marginVertical: 12,
  },
  detailsRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    marginBottom: 12,
  },
  detailsLabel: {
    fontSize: 12,
    color: Colors.textSecondary,
  },
  detailsVal: {
    fontSize: 12,
    color: Colors.text,
    fontWeight: '600',
  },
  actionsRow: {
    flexDirection: 'row',
    justifyContent: 'flex-end',
  },
  invoiceBtn: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingVertical: 6,
    paddingHorizontal: 12,
    borderRadius: 8,
    backgroundColor: Colors.primaryLight,
  },
  invoiceBtnText: {
    fontSize: 12,
    fontWeight: '600',
    color: Colors.primary,
  },
});


