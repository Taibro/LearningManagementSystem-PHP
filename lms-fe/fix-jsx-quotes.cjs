const fs = require('fs');
const path = require('path');

function walk(dir) {
    let results = [];
    const list = fs.readdirSync(dir);
    list.forEach(file => {
        const fullPath = path.join(dir, file);
        const stat = fs.statSync(fullPath);
        if (stat && stat.isDirectory()) {
            results = results.concat(walk(fullPath));
        } else if (fullPath.endsWith('.jsx')) {
            results.push(fullPath);
        }
    });
    return results;
}

const files = walk('src');
let filesChanged = 0;

files.forEach(file => {
    let content = fs.readFileSync(file, 'utf8');
    let original = content;

    // Thay thế trường hợp chuỗi CHỈ chứa 1 icon: '<Icon className=... />' => <Icon className=... />
    content = content.replace(/'(<[A-Za-z0-9]+ className="[^"]+" \/>)'/g, '$1');
    content = content.replace(/"(<[A-Za-z0-9]+ className="[^"]+" \/>)"/g, '$1');

    // Thay thế trường hợp chuỗi chứa icon VÀ text: '<Icon ... /> Text' => <><Icon ... /> Text</>
    content = content.replace(/'(<[A-Za-z0-9]+ className="[^"]+" \/>[^']+)'/g, '<>$1</>');
    content = content.replace(/"(<[A-Za-z0-9]+ className="[^"]+" \/>[^"]+)"/g, '<>$1</>');

    // Thay thế trường hợp chuỗi chứa text VÀ icon: 'Text <Icon ... />' => <>Text <Icon ... /></>
    content = content.replace(/'([^']*(?:<[A-Za-z0-9]+ className="[^"]+" \/>)+[^']*)'/g, (match, p1) => {
        if (p1.includes('<') && p1.includes('className=')) return '<>' + p1 + '</>';
        return match;
    });
    content = content.replace(/"([^"]*(?:<[A-Za-z0-9]+ className="[^"]+" \/>)+[^"]*)"/g, (match, p1) => {
        if (p1.includes('<') && p1.includes('className=')) return '<>' + p1 + '</>';
        return match;
    });

    if (content !== original) {
        fs.writeFileSync(file, content, 'utf8');
        filesChanged++;
    }
});

console.log('Fixed quotes around JSX elements in ' + filesChanged + ' files.');
