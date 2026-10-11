const fs = require('fs');
const path = require('path');

const emojiToIcon = {
  '📊': 'BarChart', '👥': 'Users', '🗓️': 'CalendarDays', '🗓': 'CalendarDays', '📝': 'FileText', '⚙️': 'Settings', '⚙': 'Settings', 
  '👤': 'User', '💰': 'DollarSign', '📁': 'FolderOpen', '✓': 'Check', '▼': 'ChevronDown',
  '📈': 'LineChart', '📅': 'Calendar', '🛑': 'StopCircle', '🔄': 'RefreshCw', '📉': 'TrendingDown',
  '📋': 'ClipboardList', '➕': 'Plus', '🗑️': 'Trash2', '🗑': 'Trash2', '✏️': 'Edit', '✏': 'Edit', '📖': 'BookOpen',
  '✅': 'CheckCircle2', '❌': 'XCircle', '✖': 'X', '🎓': 'GraduationCap', '🏢': 'Building', '🏫': 'School',
  '💳': 'CreditCard', '🔔': 'Bell', '🔍': 'Search', '🔑': 'Key', '⚠️': 'AlertTriangle', '⚠': 'AlertTriangle',
  'ℹ️': 'Info', 'ℹ': 'Info', '🔥': 'Flame', '⭐': 'Star', '🎉': 'PartyPopper', '🚀': 'Rocket',
  '🌐': 'Globe', '✉': 'Mail', '✉️': 'Mail', '🔒': 'Lock', '🙈': 'EyeOff', '👁': 'Eye', '👁️': 'Eye', '🔵': 'Circle',
  '📧': 'Mail', '📤': 'Upload', '🔐': 'Lock', '👋': 'Hand', '🛡': 'Shield', '🛡️': 'Shield', '⚡': 'Zap',
  '✕': 'X', '📍': 'MapPin', '🏛': 'Landmark', '🏛️': 'Landmark', '📆': 'CalendarDays', '📚': 'Library',
  '👨': 'User', '🧾': 'Receipt', '🏦': 'Landmark', '📱': 'Smartphone', '💵': 'Banknote', '🔓': 'Unlock',
  '💾': 'Save', '📄': 'File', '📥': 'Download', '✨': 'Sparkles', '✗': 'X', '🏅': 'Medal'
};

const dir = 'c:\\\\Users\\\\ntai8\\\\Documents\\\\Java\\\\LearningManagementSystem\\\\LearningManagementFrontend\\\\src';

function walk(currentDir) {
  const files = fs.readdirSync(currentDir);
  for (const file of files) {
    const fullPath = path.join(currentDir, file);
    if (fs.statSync(fullPath).isDirectory()) {
      walk(fullPath);
    } else if (fullPath.endsWith('.jsx')) {
      let content = fs.readFileSync(fullPath, 'utf8');
      
      const foundEmojis = new Set();
      
      for (const [emoji, icon] of Object.entries(emojiToIcon)) {
        if (content.includes(emoji)) {
          foundEmojis.add(icon);
          content = content.replaceAll(emoji, `<${icon} className="w-4 h-4 inline-block mr-2" />`);
        }
      }
      
      if (foundEmojis.size > 0) {
        const importRegex = /import\s+\{([^}]+)\}\s+from\s+['"]lucide-react['"];?/;
        const match = content.match(importRegex);
        
        if (match) {
          const existingImports = match[1].split(',').map(s => s.trim()).filter(Boolean);
          for (const icon of foundEmojis) {
            if (!existingImports.includes(icon)) {
              existingImports.push(icon);
            }
          }
          const newImportStr = `import { ${existingImports.join(', ')} } from 'lucide-react';`;
          content = content.replace(importRegex, newImportStr);
        } else {
          const newImport = `import { ${Array.from(foundEmojis).join(', ')} } from 'lucide-react';`;
          const lines = content.split('\n');
          let lastImportIdx = -1;
          for(let i = 0; i < lines.length; i++) {
              if (lines[i].startsWith('import ')) {
                  lastImportIdx = i;
              }
          }
          if (lastImportIdx >= 0) {
              lines.splice(lastImportIdx + 1, 0, newImport);
          } else {
              lines.splice(0, 0, newImport);
          }
          content = lines.join('\n');
        }
        
        fs.writeFileSync(fullPath, content, 'utf8');
        console.log('Updated:', fullPath.replace(dir, ''));
      }
    }
  }
}

walk(dir);
console.log('Done!');
