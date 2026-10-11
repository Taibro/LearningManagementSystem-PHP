import React from 'react';
const Input = ({ label, type = "text", value, onChange, placeholder, options, readOnly, className = "", min, max, rows, defaultValue }) => {
  return (
    <div className={className}>
      {label && <label className="block text-sm font-medium text-gray-600 mb-1.5">{label}</label>}

      {type === 'select' ? (
        <select className="input-field" value={value} defaultValue={defaultValue} onChange={onChange} disabled={readOnly}>
          {options && options.map((opt, index) => (
            <option key={index} value={opt.value || opt}>{opt.label || opt}</option>
          ))}
        </select>
      ) : type === 'textarea' ? (
        <textarea
          className="input-field"
          rows={rows || 3}
          placeholder={placeholder}
          value={value}
          defaultValue={defaultValue}
          onChange={onChange}
          readOnly={readOnly}
        ></textarea>
      ) : (
        <input
          type={type}
          className="input-field"
          placeholder={placeholder}
          value={value}
          defaultValue={defaultValue}
          onChange={onChange}
          readOnly={readOnly}
          min={min}
          max={max}
        />
      )}
    </div>
  );
};
export default Input;