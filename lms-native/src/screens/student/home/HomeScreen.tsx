import React, { useState, useEffect } from 'react';
import { View, Text, ScrollView, RefreshControl, TouchableOpacity, StyleSheet, Image } from 'react-native';
import { MeshBackground } from '../../../components/common/MeshBackground';
import { HomeHeader } from '../../../components/home/HomeHeader';
import { CurrentClassCard } from '../../../components/home/CurrentClassCard';
import { FunctionSection } from '../../../components/home/FunctionSection';
import { PaymentBottomSheet } from '../../../components/home/PaymentBottomSheet';
import { DraggableChatbotButton } from '../../../components/home/DraggableChatbotButton';
import { Colors } from '../../../constants/colors';
import { Shadows } from '../../../constants/theme';
import { studentApi } from '../../../api/studentApi';
import { StudentProfile, StudentOverview, ScheduleItem, NewsItem } from '../../../types/student.types';

interface Props {
  onNavigate: (screen: string) => void;
}

export const HomeScreen: React.FC<Props> = ({ onNavigate }) => {
  const [profile, setProfile] = useState<StudentProfile | null>(null);
  const [overview, setOverview] = useState<StudentOverview | null>(null);
  const [nextClass, setNextClass] = useState<ScheduleItem | null>(null);
  const [news, setNews] = useState<NewsItem[]>([]);
  const [refreshing, setRefreshing] = useState(false);
  const [showPayment, setShowPayment] = useState(false);

  const loadData = async () => {
    try {
      const [prof, over, nxt, nws] = await Promise.all([
        studentApi.getProfile(),
        studentApi.getOverview(),
        studentApi.getNextClass(),
        studentApi.getNews(),
      ]);
      setProfile(prof);
      setOverview(over);
      setNextClass(nxt);
      setNews(nws);
    } catch (e) {
      console.warn('Error loading home data', e);
    }
  };

  useEffect(() => {
    loadData();
  }, []);

  const onRefresh = async () => {
    setRefreshing(true);
    await loadData();
    setRefreshing(false);
  };

  const handleFeaturePress = (action: string) => {
    if (action === 'tuition') {
      setShowPayment(true);
    } else {
      onNavigate(action);
    }
  };

  if (!profile || !overview) {
    return (
      <MeshBackground>
        <View style={styles.loadingContainer}>
          <Text style={styles.loadingText}>Đang tải dữ liệu sinh viên...</Text>
        </View>
      </MeshBackground>
    );
  }

  return (
    <MeshBackground>
      <ScrollView
        contentContainerStyle={styles.scrollContent}
        showsVerticalScrollIndicator={false}
        refreshControl={
          <RefreshControl refreshing={refreshing} onRefresh={onRefresh} colors={[Colors.primary]} />
        }
      >
        {/* Header */}
        <HomeHeader
          profile={profile}
          onNotificationPress={() => onNavigate('news')}
          onProfilePress={() => onNavigate('profile')}
        />

        <View style={styles.contentBody}>
          {/* Quick Academic Overview Card */}
          <View style={[styles.overviewCard, Shadows.sm]}>
            <View style={styles.overviewItem}>
              <Text style={styles.overviewValue}>{overview.gpa4.toFixed(2)}</Text>
              <Text style={styles.overviewLabel}>Điểm TB tích lũy</Text>
            </View>
            <View style={styles.overviewDivider} />
            <View style={styles.overviewItem}>
              <Text style={styles.overviewValue}>{overview.creditsAccumulated} / {overview.creditsRequired}</Text>
              <Text style={styles.overviewLabel}>Tín chỉ tích lũy</Text>
            </View>
            <View style={styles.overviewDivider} />
            <View style={styles.overviewItem}>
              <Text style={[styles.overviewValue, { color: Colors.success }]}>{overview.classification}</Text>
              <Text style={styles.overviewLabel}>Xếp loại học tập</Text>
            </View>
          </View>

          {/* Next Class Today */}
          <CurrentClassCard
            nextClass={nextClass}
            onAttendancePress={() => onNavigate('attendance')}
          />

          {/* Grid Function Section */}
          <FunctionSection onFeaturePress={handleFeaturePress} />

          {/* Recent News Section */}
          <View style={styles.newsSection}>
            <View style={styles.sectionHeaderRow}>
              <Text style={styles.sectionTitle}>Tin tức & Thông báo mới</Text>
              <TouchableOpacity onPress={() => onNavigate('news')}>
                <Text style={styles.seeAllText}>Xem thêm</Text>
              </TouchableOpacity>
            </View>

            {news.slice(0, 2).map((item) => (
              <TouchableOpacity
                key={item.id}
                style={[styles.newsCard, Shadows.sm]}
                activeOpacity={0.8}
                onPress={() => onNavigate('news')}
              >
                <Image source={{ uri: item.imageUrl }} style={styles.newsThumb} />
                <View style={styles.newsContent}>
                  <View style={styles.newsTag}>
                    <Text style={styles.newsTagText}>{item.category}</Text>
                    <Text style={styles.newsDate}>{item.date}</Text>
                  </View>
                  <Text style={styles.newsTitle} numberOfLines={2}>
                    {item.title}
                  </Text>
                </View>
              </TouchableOpacity>
            ))}
          </View>
        </View>
      </ScrollView>

      {/* Floating AI Chatbot Button */}
      <DraggableChatbotButton onPress={() => onNavigate('chatbot')} />

      {/* Payment Sheet */}
      <PaymentBottomSheet
        visible={showPayment}
        onClose={() => setShowPayment(false)}
        onGoToReceipts={() => {
          setShowPayment(false);
          onNavigate('receipt');
        }}
      />
    </MeshBackground>
  );
};

const styles = StyleSheet.create({
  scrollContent: {
    paddingBottom: 110,
  },
  loadingContainer: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
  },
  loadingText: {
    fontSize: 14,
    color: Colors.textMuted,
    fontWeight: '500',
  },
  contentBody: {
    paddingHorizontal: 20,
    marginTop: 10,
  },
  overviewCard: {
    flexDirection: 'row',
    backgroundColor: Colors.card,
    borderRadius: 18,
    paddingVertical: 14,
    paddingHorizontal: 12,
    marginBottom: 16,
    borderWidth: 1,
    borderColor: Colors.borderLight,
    justifyContent: 'space-around',
    alignItems: 'center',
  },
  overviewItem: {
    alignItems: 'center',
    flex: 1,
  },
  overviewValue: {
    fontSize: 18,
    fontWeight: '800',
    color: Colors.primary,
    marginBottom: 2,
  },
  overviewLabel: {
    fontSize: 10,
    color: Colors.textMuted,
    fontWeight: '600',
  },
  overviewDivider: {
    width: 1,
    height: 28,
    backgroundColor: Colors.borderLight,
  },
  newsSection: {
    marginTop: 24,
  },
  sectionHeaderRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 12,
  },
  sectionTitle: {
    fontSize: 16,
    fontWeight: '800',
    color: Colors.text,
  },
  seeAllText: {
    fontSize: 13,
    fontWeight: '600',
    color: Colors.primary,
  },
  newsCard: {
    flexDirection: 'row',
    backgroundColor: Colors.card,
    borderRadius: 16,
    overflow: 'hidden',
    marginBottom: 12,
    borderWidth: 1,
    borderColor: Colors.borderLight,
  },
  newsThumb: {
    width: 96,
    height: 84,
    backgroundColor: '#E2E8F0',
  },
  newsContent: {
    flex: 1,
    padding: 10,
    justifyContent: 'center',
  },
  newsTag: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 4,
  },
  newsTagText: {
    fontSize: 10,
    fontWeight: '700',
    color: Colors.primary,
    textTransform: 'uppercase',
  },
  newsDate: {
    fontSize: 10,
    color: Colors.textMuted,
  },
  newsTitle: {
    fontSize: 13,
    fontWeight: '700',
    color: Colors.text,
    lineHeight: 18,
  },
});



