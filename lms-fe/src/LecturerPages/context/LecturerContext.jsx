import React, { createContext, useState, useContext } from 'react';

const LecturerContext = createContext();

export const LecturerProvider = ({ children }) => {
  const [classes, setClasses] = useState([]);
  const [activeClass, setActiveClass] = useState(null);

  // Hàm này dùng để nạp danh sách lớp vào (sẽ gọi ở ProgressSchedule hoặc Dashboard)
  const loadClasses = (classList) => {
    setClasses(classList);
    // Nếu chưa có lớp nào được chọn, tự động chọn lớp đầu tiên
    if (!activeClass && classList.length > 0) {
      setActiveClass(classList[0]);
    }
  };

  return (
    <LecturerContext.Provider value={{ classes, activeClass, setActiveClass, loadClasses }}>
      {children}
    </LecturerContext.Provider>
  );
};

export const useLecturerContext = () => useContext(LecturerContext);
