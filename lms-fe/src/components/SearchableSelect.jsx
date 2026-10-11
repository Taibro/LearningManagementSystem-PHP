import React, { useState, useRef, useEffect } from 'react';
import { Search, ChevronDown, ChevronUp } from 'lucide-react';

export default function SearchableSelect({ 
  options, 
  value, 
  onChange, 
  placeholder = "-- Chọn trường của bạn --", 
  hasError,
  style,
  className,
  triggerClassName = "",
  triggerStyle = {},
  icon = null
}) {
  const [isOpen, setIsOpen] = useState(false);
  const [search, setSearch] = useState('');
  const wrapperRef = useRef(null);

  useEffect(() => {
    function handleClickOutside(event) {
      if (wrapperRef.current && !wrapperRef.current.contains(event.target)) {
        setIsOpen(false);
      }
    }
    document.addEventListener("mousedown", handleClickOutside);
    return () => document.removeEventListener("mousedown", handleClickOutside);
  }, []);

  const filteredOptions = options.filter(opt => 
    opt.label.toLowerCase().includes(search.toLowerCase())
  );

  const selectedOption = options.find(opt => opt.value === value);

  return (
    <div ref={wrapperRef} className={className} style={{ position: 'relative', width: '100%', ...style }}>
      <div 
        className={triggerClassName}
        onClick={() => setIsOpen(!isOpen)}
        style={{ 
          display: 'flex', alignItems: 'center', justifyContent: 'space-between', 
          cursor: 'pointer', padding: '0 16px', height: '48px', 
          border: hasError ? '1px solid #ef4444' : '1px solid #e2e8f0', 
          borderRadius: '8px', background: '#f8fafc',
          color: selectedOption ? '#0f172a' : '#94A3B8',
          fontSize: '14px',
          transition: 'all 0.2s ease',
          outline: isOpen ? '2px solid #cbd5e1' : 'none',
          ...triggerStyle
        }}
      >
        <div style={{ display: 'flex', alignItems: 'center', gap: '8px', overflow: 'hidden' }}>
          {icon && <span style={{ color: '#94A3B8', display: 'flex' }}>{icon}</span>}
          <span style={{ overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap' }}>
            {selectedOption ? selectedOption.label : placeholder}
          </span>
        </div>
        {isOpen ? <ChevronUp className="w-4 h-4 text-slate-400 flex-shrink-0 ml-2" /> : <ChevronDown className="w-4 h-4 text-slate-400 flex-shrink-0 ml-2" />}
      </div>

      {isOpen && (
        <div style={{
          position: 'absolute', top: '100%', left: 0, right: 0, zIndex: 50,
          marginTop: '4px', background: '#fff', border: '1px solid #e2e8f0', 
          borderRadius: '8px', boxShadow: '0 10px 15px -3px rgba(0, 0, 0, 0.1)',
          maxHeight: '260px', display: 'flex', flexDirection: 'column',
          overflow: 'hidden'
        }}>
          <div style={{ padding: '8px', borderBottom: '1px solid #f1f5f9' }}>
            <div style={{ position: 'relative', display: 'flex', alignItems: 'center' }}>
              <Search className="w-4 h-4 text-slate-400 absolute left-3" />
              <input 
                type="text" 
                placeholder="Tìm kiếm trường..." 
                value={search}
                onChange={(e) => setSearch(e.target.value)}
                style={{
                  width: '100%', padding: '8px 12px 8px 32px', border: '1px solid #cbd5e1',
                  borderRadius: '6px', outline: 'none', fontSize: '13px',
                  background: '#f8fafc'
                }}
                autoFocus
              />
            </div>
          </div>
          <div style={{ overflowY: 'auto', flex: 1 }}>
            {filteredOptions.length > 0 ? filteredOptions.map(opt => (
              <div 
                key={opt.value}
                style={{
                  padding: '12px 16px', cursor: 'pointer', fontSize: '14px',
                  background: value === opt.value ? '#f1f5f9' : 'transparent',
                  color: value === opt.value ? '#0f172a' : '#334155',
                  fontWeight: value === opt.value ? '600' : '400',
                  transition: 'background 0.2s ease',
                  whiteSpace: 'nowrap', overflow: 'hidden', textOverflow: 'ellipsis'
                }}
                onMouseEnter={(e) => {
                  if (value !== opt.value) e.target.style.background = '#f8fafc';
                }}
                onMouseLeave={(e) => {
                  if (value !== opt.value) e.target.style.background = 'transparent';
                }}
                onClick={() => {
                  onChange(opt.value);
                  setIsOpen(false);
                  setSearch('');
                }}
              >
                {opt.label}
              </div>
            )) : (
              <div style={{ padding: '16px', color: '#94a3b8', fontSize: '13px', textAlign: 'center' }}>
                Không tìm thấy trường nào phù hợp
              </div>
            )}
          </div>
        </div>
      )}
    </div>
  );
}
