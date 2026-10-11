import { useState, useEffect } from 'react';
import { API_BASE_URL } from '../config/apiConfig';


export default function useNotifications(tokenKey) {
  const [notifications, setNotifications] = useState([]);
  const [unreadCount, setUnreadCount] = useState(0);

  const fetchNotifications = async () => {
    const token = localStorage.getItem(tokenKey);
    if (!token) return;
    try {
      const res = await fetch(`${API_BASE_URL}/notifications/my-notifications`, {
        headers: { 'Authorization': `Bearer ${token}` }
      });
      if (res.ok) {
        const data = await res.json();
        setNotifications(data);
        setUnreadCount(data.filter(n => !n.isRead).length);
      }
    } catch (e) {
      console.error('Lỗi fetch thông báo', e);
    }
  };

  const markAsRead = async (id) => {
    const token = localStorage.getItem(tokenKey);
    if (!token) return;
    try {
      await fetch(`${API_BASE_URL}/notifications/${id}/mark-read`, {
        method: 'PUT',
        headers: { 'Authorization': `Bearer ${token}` }
      });
      fetchNotifications();
    } catch (e) {}
  };

  useEffect(() => {
    fetchNotifications();
    const interval = setInterval(fetchNotifications, 10000); // Polling 10s
    return () => clearInterval(interval);
  }, [tokenKey]);

  return { notifications, unreadCount, markAsRead };
}
