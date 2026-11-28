import { useState, useEffect, useCallback } from 'react';
import {
  API_BASE_URL,
  isCookieAuthMode,
  isValidTokenString,
} from '../config/apiConfig';

export default function useNotifications(tokenKey) {
  const [notifications, setNotifications] = useState([]);
  const [unreadCount, setUnreadCount] = useState(0);

  const buildRequestOptions = useCallback(
    (method = 'GET') => {
      const token = localStorage.getItem(tokenKey);
      const hasToken = isValidTokenString(token);
      const cookieMode = isCookieAuthMode();

      if (!hasToken && !cookieMode) {
        return null;
      }

      const headers = { Accept: 'application/json' };
      if (hasToken && !cookieMode) {
        headers.Authorization = `Bearer ${token}`;
      }

      return {
        method,
        credentials: 'include',
        headers,
      };
    },
    [tokenKey]
  );

  const fetchNotifications = useCallback(async () => {
    const options = buildRequestOptions('GET');
    if (!options) return;

    try {
      const res = await fetch(`${API_BASE_URL}/notifications/my-notifications`, options);
      if (res.ok) {
        const data = await res.json();
        setNotifications(data);
        setUnreadCount(data.filter((n) => !n.isRead).length);
      }
    } catch (e) {
      console.error('Lỗi fetch thông báo', e);
    }
  }, [buildRequestOptions]);

  const markAsRead = async (id) => {
    const options = buildRequestOptions('PUT');
    if (!options) return;

    try {
      await fetch(`${API_BASE_URL}/notifications/${id}/mark-read`, options);
      fetchNotifications();
    } catch {
      /* ignore */
    }
  };

  useEffect(() => {
    fetchNotifications();
    const interval = setInterval(fetchNotifications, 10000);
    return () => clearInterval(interval);
  }, [fetchNotifications]);

  return { notifications, unreadCount, markAsRead };
}
