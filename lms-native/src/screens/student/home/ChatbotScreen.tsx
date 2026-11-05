import React, { useState, useRef, useEffect } from 'react';
import { View, Text, TextInput, TouchableOpacity, ScrollView, StyleSheet, KeyboardAvoidingView, Platform } from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import { AppHeader } from '../../../components/common/AppHeader';
import { Colors } from '../../../constants/colors';
import { Shadows } from '../../../constants/theme';
import { useAuth } from '../../../hooks/useAuth';
import { ChatMessage } from '../../../types/student.types';

interface Props {
  onBack: () => void;
}

export const ChatbotScreen: React.FC<Props> = ({ onBack }) => {
  const { user } = useAuth();
  const studentName = user?.fullName || 'bạn';

  const [messages, setMessages] = useState<ChatMessage[]>([
    {
      id: '1',
      text: `Xin chào ${studentName}! Mình là Trợ lý AI HUIT. Bạn cần giải đáp thắc mắc gì về lịch học, quy chế điểm rèn luyện hay học phí hôm nay?`,
      sender: 'bot',
      timestamp: '08:00',
    },
  ]);
  const [inputText, setInputText] = useState('');
  const scrollViewRef = useRef<any>(null);

  useEffect(() => {
    scrollViewRef.current?.scrollToEnd({ animated: true });
  }, [messages]);

  const quickPrompts = [
    'Lịch thi HK2 khi nào có?',
    'Cách tính điểm rèn luyện?',
    'Học phí nộp qua cổng nào?',
    'Quy định xét tốt nghiệp',
  ];

  const handleSend = (textToSend?: string) => {
    const text = textToSend || inputText;
    if (!text.trim()) return;

    const userMsg: ChatMessage = {
      id: Date.now().toString(),
      text: text.trim(),
      sender: 'user',
      timestamp: new Date().toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' }),
    };

    setMessages((prev) => [...prev, userMsg]);
    if (!textToSend) setInputText('');

    // Mock bot reply
    setTimeout(() => {
      let botReply = 'Cảm ơn bạn đã hỏi! Thông tin chi tiết đã được cập nhật trong mục Thông báo của trường hoặc bạn có thể liên hệ trực tiếp phòng Đào tạo HUIT để được giải quyết nhanh nhất.';
      if (text.includes('lịch thi')) {
        botReply = 'Lịch thi dự kiến của HK2 sẽ bắt đầu từ tuần thứ 16 (khoảng giữa tháng 6/2026). Bạn có thể kiểm tra danh sách ca thi cụ thể trong mục Lịch học nhé!';
      } else if (text.includes('rèn luyện')) {
        botReply = 'Điểm rèn luyện của bạn HK1 đạt 85 điểm (Loại Tốt). Điểm được tổng hợp từ 5 tiêu chí: Ý thức học tập, chấp hành nội quy, hoạt động Đoàn - Hội, v.v.';
      } else if (text.includes('học phí')) {
        botReply = 'Học phí có thể nộp trực tiếp qua Cổng thanh toán OCB/VNPAY liên kết trên ứng dụng tại mục "Học phí & Phiếu thu".';
      }

      const replyMsg: ChatMessage = {
        id: (Date.now() + 1).toString(),
        text: botReply,
        sender: 'bot',
        timestamp: new Date().toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' }),
      };
      setMessages((prev) => [...prev, replyMsg]);
    }, 600);
  };

  return (
    <KeyboardAvoidingView
      style={styles.container}
      behavior={Platform.OS === 'ios' ? 'padding' : undefined}
      keyboardVerticalOffset={Platform.OS === 'ios' ? 40 : 0}
    >
      <AppHeader title="Trợ lý AI HUIT" onBack={onBack} />

      {/* Messages ScrollView */}
      <ScrollView
        ref={scrollViewRef}
        contentContainerStyle={styles.messagesContainer}
        showsVerticalScrollIndicator={false}
      >
        {messages.map((m) => {
          const isUser = m.sender === 'user';
          return (
            <View key={m.id} style={[styles.bubbleWrap, isUser ? styles.bubbleWrapUser : styles.bubbleWrapBot]}>
              {!isUser && (
                <View style={styles.botAvatar}>
                  <Ionicons name="sparkles" size={16} color="#FFFFFF" />
                </View>
              )}
              <View style={[styles.bubble, isUser ? styles.bubbleUser : styles.bubbleBot, Shadows.sm]}>
                <Text style={[styles.bubbleText, isUser ? styles.bubbleTextUser : styles.bubbleTextBot]}>
                  {m.text}
                </Text>
                <Text style={[styles.timeText, isUser ? styles.timeTextUser : styles.timeTextBot]}>
                  {m.timestamp}
                </Text>
              </View>
            </View>
          );
        })}
      </ScrollView>

      {/* Quick Prompts */}
      <View style={styles.promptBar}>
        <ScrollView horizontal showsHorizontalScrollIndicator={false} contentContainerStyle={styles.promptScroll}>
          {quickPrompts.map((q) => (
            <TouchableOpacity key={q} style={styles.promptPill} onPress={() => handleSend(q)} activeOpacity={0.7}>
              <Text style={styles.promptText}>{q}</Text>
            </TouchableOpacity>
          ))}
        </ScrollView>
      </View>

      {/* Input bar */}
      <View style={styles.inputContainer}>
        <TextInput
          style={styles.input}
          placeholder="Hỏi AI bất kỳ điều gì về HUIT..."
          placeholderTextColor={Colors.textMuted}
          value={inputText}
          onChangeText={setInputText}
          onSubmitEditing={() => handleSend()}
        />
        <TouchableOpacity style={styles.sendBtn} onPress={() => handleSend()} activeOpacity={0.8}>
          <Ionicons name="send" size={18} color="#FFFFFF" />
        </TouchableOpacity>
      </View>
    </KeyboardAvoidingView>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: Colors.bg,
  },
  messagesContainer: {
    padding: 16,
    paddingBottom: 20,
  },
  bubbleWrap: {
    flexDirection: 'row',
    marginBottom: 14,
    alignItems: 'flex-end',
  },
  bubbleWrapUser: {
    justifyContent: 'flex-end',
  },
  bubbleWrapBot: {
    justifyContent: 'flex-start',
  },
  botAvatar: {
    width: 32,
    height: 32,
    borderRadius: 16,
    backgroundColor: Colors.primary,
    alignItems: 'center',
    justifyContent: 'center',
    marginRight: 8,
  },
  bubble: {
    maxWidth: '78%',
    padding: 14,
    borderRadius: 18,
  },
  bubbleUser: {
    backgroundColor: Colors.primary,
    borderBottomRightRadius: 4,
  },
  bubbleBot: {
    backgroundColor: Colors.card,
    borderBottomLeftRadius: 4,
    borderWidth: 1,
    borderColor: Colors.borderLight,
  },
  bubbleText: {
    fontSize: 14,
    lineHeight: 20,
  },
  bubbleTextUser: {
    color: '#FFFFFF',
  },
  bubbleTextBot: {
    color: Colors.text,
  },
  timeText: {
    fontSize: 10,
    marginTop: 4,
    textAlign: 'right',
  },
  timeTextUser: {
    color: 'rgba(255, 255, 255, 0.7)',
  },
  timeTextBot: {
    color: Colors.textMuted,
  },
  promptBar: {
    paddingVertical: 6,
    borderTopWidth: 1,
    borderTopColor: Colors.borderLight,
    backgroundColor: Colors.card,
  },
  promptScroll: {
    paddingHorizontal: 16,
    gap: 8,
  },
  promptPill: {
    backgroundColor: '#F1F5F9',
    paddingHorizontal: 12,
    paddingVertical: 6,
    borderRadius: 14,
    borderWidth: 1,
    borderColor: Colors.borderLight,
  },
  promptText: {
    fontSize: 12,
    color: Colors.primary,
    fontWeight: '600',
  },
  inputContainer: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingHorizontal: 16,
    paddingVertical: 10,
    backgroundColor: Colors.card,
    borderTopWidth: 1,
    borderTopColor: Colors.borderLight,
  },
  input: {
    flex: 1,
    height: 44,
    backgroundColor: '#F8FAFC',
    borderRadius: 22,
    paddingHorizontal: 16,
    fontSize: 14,
    color: Colors.text,
    borderWidth: 1,
    borderColor: Colors.borderLight,
    marginRight: 10,
  },
  sendBtn: {
    width: 44,
    height: 44,
    borderRadius: 22,
    backgroundColor: Colors.primary,
    alignItems: 'center',
    justifyContent: 'center',
  },
});



