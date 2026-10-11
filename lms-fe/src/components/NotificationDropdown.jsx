import React, { useState, useRef, useEffect } from 'react';
import { Bell } from 'lucide-react';
import useNotifications from '../hooks/useNotifications';

export default function NotificationDropdown({ tokenKey }) {
  const { notifications, unreadCount, markAsRead } = useNotifications(tokenKey);
  const [isOpen, setIsOpen] = useState(false);
  const dropdownRef = useRef(null);

  useEffect(() => {
    const handleClickOutside = (event) => {
      if (dropdownRef.current && !dropdownRef.current.contains(event.target)) {
        setIsOpen(false);
      }
    };
    document.addEventListener('mousedown', handleClickOutside);
    return () => document.removeEventListener('mousedown', handleClickOutside);
  }, []);

  return (
    <div className="relative" ref={dropdownRef}>
      <button 
        onClick={() => setIsOpen(!isOpen)}
        className="relative p-2 text-gray-500 hover:text-blue-600 transition-colors bg-gray-100 rounded-full hover:bg-blue-50"
      >
        <Bell className="w-5 h-5" />
        {unreadCount > 0 && (
          <span className="absolute top-0 right-0 w-4 h-4 bg-red-500 text-white text-[10px] font-bold flex items-center justify-center rounded-full border-2 border-white">
            {unreadCount > 9 ? '9+' : unreadCount}
          </span>
        )}
      </button>

      {isOpen && (
        <div className="absolute right-0 mt-2 w-80 bg-white rounded-lg shadow-xl border border-gray-100 z-50 overflow-hidden">
          <div className="px-4 py-3 border-b border-gray-100 bg-gray-50 flex justify-between items-center">
            <h3 className="font-bold text-gray-800 text-sm">Thông báo</h3>
            <span className="text-xs bg-blue-100 text-blue-700 px-2 py-1 rounded-full font-semibold">{unreadCount} mới</span>
          </div>
          <div className="max-h-[350px] overflow-y-auto">
            {notifications.length === 0 ? (
              <div className="p-4 text-center text-sm text-gray-500">Chưa có thông báo nào.</div>
            ) : (
              notifications.map((n) => (
                <div 
                  key={n.id} 
                  onClick={() => {
                    if (!n.isRead) markAsRead(n.id);
                  }}
                  className={`p-4 border-b border-gray-50 hover:bg-gray-50 cursor-pointer transition-colors ${!n.isRead ? 'bg-blue-50/50' : ''}`}
                >
                  <div className="flex justify-between items-start mb-1">
                    <h4 className={`text-sm ${!n.isRead ? 'font-bold text-gray-900' : 'font-semibold text-gray-700'}`}>
                      {n.title}
                    </h4>
                    {!n.isRead && <span className="w-2 h-2 rounded-full bg-blue-500 mt-1"></span>}
                  </div>
                  <p className="text-xs text-gray-600 line-clamp-2">{n.body}</p>
                  <span className="text-[10px] text-gray-400 mt-2 block">
                    {new Date(n.createdAt).toLocaleString('vi-VN')}
                  </span>
                </div>
              ))
            )}
          </div>
          <div className="p-2 border-t border-gray-100 bg-gray-50 text-center">
            <button className="text-xs text-blue-600 font-semibold hover:underline">Đánh dấu tất cả đã đọc</button>
          </div>
        </div>
      )}
    </div>
  );
}
