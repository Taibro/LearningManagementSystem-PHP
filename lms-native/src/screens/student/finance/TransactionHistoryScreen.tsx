import React, { useState, useEffect, useCallback } from 'react';
import { View, Text, FlatList, StyleSheet, RefreshControl } from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import { AppHeader } from '../../../components/common/AppHeader';
import { Colors } from '../../../constants/colors';
import { Shadows } from '../../../constants/theme';
import { EmptyState, AppBadge } from '../../../components/ui';
import { studentApi } from '../../../api/studentApi';
import { Transaction } from '../../../types/student.types';
import { formatCurrency } from '../../../utils';
import { useRefresh } from '../../../hooks/useRefresh';

interface Props {
  onBack: () => void;
}

export const TransactionHistoryScreen: React.FC<Props> = ({ onBack }) => {
  const [transactions, setTransactions] = useState<Transaction[]>([]);

  const fetchTransactions = useCallback(async () => {
    try {
      const data = await studentApi.getTransactions();
      setTransactions(data);
    } catch (err) {
      console.warn('[TransactionHistoryScreen] Failed to fetch transactions:', err);
    }
  }, []);

  useEffect(() => {
    fetchTransactions();
  }, [fetchTransactions]);

  const { refreshing, onRefresh } = useRefresh(fetchTransactions);

  const renderTransactionItem = useCallback(
    ({ item: t }: { item: Transaction }) => {
      const isSuccess = t.status === 'SUCCESS';
      return (
        <View style={[styles.transCard, Shadows.sm]}>
          <View style={[styles.iconWrap, isSuccess ? styles.iconSuccess : styles.iconCancelled]}>
            <Ionicons
              name={isSuccess ? 'checkmark-circle-outline' : 'close-circle-outline'}
              size={22}
              color={isSuccess ? Colors.success : Colors.danger}
            />
          </View>

          <View style={styles.infoCol}>
            <Text style={styles.transType}>{t.type}</Text>
            <Text style={styles.transDate}>{t.dateTime}</Text>
          </View>

          <View style={styles.amountCol}>
            <Text style={[styles.transAmount, !isSuccess && styles.amountCancelled]}>
              {formatCurrency(t.amount)}
            </Text>
            <AppBadge
              label={isSuccess ? 'Thành công' : 'Đã hủy'}
              variant={isSuccess ? 'success' : 'danger'}
              size="sm"
            />
          </View>
        </View>
      );
    },
    []
  );

  const renderEmpty = () => (
    <EmptyState
      icon="swap-horizontal-outline"
      title="Chưa có giao dịch"
      description="Bạn chưa có lịch sử giao dịch thanh toán nào."
    />
  );

  return (
    <View style={styles.container}>
      <AppHeader title="Lịch sử giao dịch" onBack={onBack} />

      <FlatList
        data={transactions}
        keyExtractor={(t) => t.id}
        renderItem={renderTransactionItem}
        ListEmptyComponent={renderEmpty}
        contentContainerStyle={styles.scrollContent}
        showsVerticalScrollIndicator={false}
        initialNumToRender={8}
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
  scrollContent: {
    padding: 16,
    paddingBottom: 40,
  },
  transCard: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: Colors.card,
    borderRadius: 16,
    padding: 14,
    marginBottom: 10,
    borderWidth: 1,
    borderColor: Colors.borderLight,
  },
  iconWrap: {
    width: 42,
    height: 42,
    borderRadius: 21,
    alignItems: 'center',
    justifyContent: 'center',
    marginRight: 12,
  },
  iconSuccess: {
    backgroundColor: Colors.successLight,
  },
  iconCancelled: {
    backgroundColor: Colors.dangerLight,
  },
  infoCol: {
    flex: 1,
  },
  transType: {
    fontSize: 14,
    fontWeight: '700',
    color: Colors.text,
    marginBottom: 4,
  },
  transDate: {
    fontSize: 11,
    color: Colors.textMuted,
  },
  amountCol: {
    alignItems: 'flex-end',
  },
  transAmount: {
    fontSize: 14,
    fontWeight: '800',
    color: Colors.primary,
    marginBottom: 4,
  },
  amountCancelled: {
    color: Colors.textMuted,
    textDecorationLine: 'line-through',
  },
});


