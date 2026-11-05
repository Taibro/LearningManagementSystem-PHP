import React, { useState, useEffect } from 'react';
import { View, Text, ScrollView, TouchableOpacity, Image, StyleSheet, Modal } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { Ionicons } from '@expo/vector-icons';
import { AppHeader } from '../../../components/common/AppHeader';
import { EmptyState } from '../../../components/ui/EmptyState';
import { Colors } from '../../../constants/colors';
import { Shadows } from '../../../constants/theme';
import { studentApi } from '../../../api/studentApi';
import { NewsItem } from '../../../types/student.types';

interface Props {
  onBack: () => void;
}

export const NewsScreen: React.FC<Props> = ({ onBack }) => {
  const [newsList, setNewsList] = useState<NewsItem[]>([]);
  const [selectedCategory, setSelectedCategory] = useState('Tất cả');
  const [selectedArticle, setSelectedArticle] = useState<NewsItem | null>(null);

  const categories = ['Tất cả', 'Thông báo', 'Sự kiện', 'Sinh viên'];

  useEffect(() => {
    studentApi.getNews().then(setNewsList).catch(() => {});
  }, []);

  const filteredNews = newsList.filter((item) => {
    if (selectedCategory === 'Tất cả') return true;
    return item.category === selectedCategory;
  });

  return (
    <View style={styles.container}>
      <AppHeader title="Tin tức & Sự kiện" onBack={onBack} />

      {/* Category Pills */}
      <View style={styles.catBar}>
        <ScrollView horizontal showsHorizontalScrollIndicator={false} contentContainerStyle={styles.catScroll}>
          {categories.map((cat) => {
            const isSelected = selectedCategory === cat;
            return (
              <TouchableOpacity
                key={cat}
                style={[styles.catPill, isSelected && styles.catPillActive]}
                onPress={() => setSelectedCategory(cat)}
                activeOpacity={0.7}
              >
                <Text style={[styles.catText, isSelected && styles.catTextActive]}>{cat}</Text>
              </TouchableOpacity>
            );
          })}
        </ScrollView>
      </View>

      <ScrollView contentContainerStyle={styles.scrollContent} showsVerticalScrollIndicator={false}>
        {filteredNews.length === 0 ? (
          <EmptyState
            icon="newspaper-outline"
            title="Chưa có tin tức"
            description="Không tìm thấy bài viết nào trong danh mục này."
          />
        ) : (
          filteredNews.map((item) => (
            <TouchableOpacity
              key={item.id}
              style={[styles.newsCard, Shadows.sm]}
              activeOpacity={0.8}
              onPress={() => setSelectedArticle(item)}
            >
              <Image source={{ uri: item.imageUrl }} style={styles.image} />
              <View style={styles.content}>
                <View style={styles.tagRow}>
                  <View style={styles.catTag}>
                    <Text style={styles.catTagText}>{item.category}</Text>
                  </View>
                  <Text style={styles.dateText}>{item.date}</Text>
                </View>

                <Text style={styles.title} numberOfLines={2}>{item.title}</Text>
                {item.summary ? (
                  <Text style={styles.summary} numberOfLines={2}>{item.summary}</Text>
                ) : null}
              </View>
            </TouchableOpacity>
          ))
        )}
      </ScrollView>

      {/* Article Detail Modal */}
      {selectedArticle && (
        <Modal visible={true} animationType="slide" onRequestClose={() => setSelectedArticle(null)}>
          <SafeAreaView style={styles.modalContainer}>
            <View style={styles.modalHeader}>
              <TouchableOpacity onPress={() => setSelectedArticle(null)} style={styles.modalBackBtn}>
                <Ionicons name="arrow-back" size={22} color={Colors.text} />
              </TouchableOpacity>
              <Text style={styles.modalHeaderTitle} numberOfLines={1}>Chi tiết tin tức</Text>
              <View style={{ width: 36 }} />
            </View>

            <ScrollView contentContainerStyle={styles.modalScroll}>
              <Image source={{ uri: selectedArticle.imageUrl }} style={styles.modalImage} />
              <View style={styles.modalBody}>
                <View style={styles.tagRow}>
                  <View style={styles.catTag}>
                    <Text style={styles.catTagText}>{selectedArticle.category}</Text>
                  </View>
                  <Text style={styles.dateText}>Ngày đăng: {selectedArticle.date}</Text>
                </View>

                <Text style={styles.modalTitle}>{selectedArticle.title}</Text>
                <View style={styles.modalDivider} />
                <Text style={styles.modalContent}>
                  {selectedArticle.content || selectedArticle.summary}
                </Text>
              </View>
            </ScrollView>
          </SafeAreaView>
        </Modal>
      )}
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: Colors.bg,
  },
  catBar: {
    backgroundColor: Colors.card,
    paddingVertical: 10,
    borderBottomWidth: 1,
    borderBottomColor: Colors.borderLight,
  },
  catScroll: {
    paddingHorizontal: 16,
    gap: 8,
  },
  catPill: {
    paddingHorizontal: 16,
    paddingVertical: 6,
    borderRadius: 18,
    backgroundColor: Colors.bg,
    borderWidth: 1,
    borderColor: Colors.borderLight,
  },
  catPillActive: {
    backgroundColor: Colors.primary,
    borderColor: Colors.primary,
  },
  catText: {
    fontSize: 13,
    fontWeight: '600',
    color: Colors.textSecondary,
  },
  catTextActive: {
    color: '#FFFFFF',
    fontWeight: '700',
  },
  scrollContent: {
    padding: 16,
    paddingBottom: 40,
  },
  newsCard: {
    backgroundColor: Colors.card,
    borderRadius: 18,
    overflow: 'hidden',
    marginBottom: 16,
    borderWidth: 1,
    borderColor: Colors.borderLight,
  },
  image: {
    width: '100%',
    height: 160,
    backgroundColor: '#E2E8F0',
  },
  content: {
    padding: 14,
  },
  tagRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 8,
  },
  catTag: {
    backgroundColor: Colors.primaryLight,
    paddingHorizontal: 8,
    paddingVertical: 3,
    borderRadius: 6,
  },
  catTagText: {
    fontSize: 11,
    fontWeight: '700',
    color: Colors.primary,
    textTransform: 'uppercase',
  },
  dateText: {
    fontSize: 11,
    color: Colors.textMuted,
  },
  title: {
    fontSize: 15,
    fontWeight: '800',
    color: Colors.text,
    lineHeight: 20,
    marginBottom: 6,
  },
  summary: {
    fontSize: 13,
    color: Colors.textSecondary,
    lineHeight: 18,
  },
  modalContainer: {
    flex: 1,
    backgroundColor: Colors.bg,
  },
  modalHeader: {
    height: 56,
    backgroundColor: Colors.card,
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    paddingHorizontal: 16,
    borderBottomWidth: 1,
    borderBottomColor: Colors.borderLight,
  },
  modalBackBtn: {
    width: 36,
    height: 36,
    borderRadius: 18,
    backgroundColor: Colors.borderLight,
    alignItems: 'center',
    justifyContent: 'center',
  },
  modalHeaderTitle: {
    fontSize: 16,
    fontWeight: '700',
    color: Colors.text,
  },
  modalScroll: {
    paddingBottom: 40,
  },
  modalImage: {
    width: '100%',
    height: 220,
    backgroundColor: '#E2E8F0',
  },
  modalBody: {
    padding: 18,
  },
  modalTitle: {
    fontSize: 20,
    fontWeight: '800',
    color: Colors.text,
    lineHeight: 26,
    marginBottom: 12,
  },
  modalDivider: {
    height: 1,
    backgroundColor: Colors.borderLight,
    marginBottom: 14,
  },
  modalContent: {
    fontSize: 15,
    color: Colors.textSecondary,
    lineHeight: 24,
  },
});


