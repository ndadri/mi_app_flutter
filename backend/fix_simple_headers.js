const fs = require('fs');

console.log('🔧 Arreglando headers duplicados en archivos específicos...');

// Archivos específicos mencionados por el usuario
const files = [
    '../lib/crud_page.dart',
    '../lib/crud_page_new.dart',
    '../lib/my_pets_page.dart',
    '../lib/search_user_page.dart',
    '../lib/statistics_page.dart'
];

files.forEach(filePath => {
    try {
        if (!fs.existsSync(filePath)) {
            console.log(`⚠️  ${filePath}: No encontrado`);
            return;
        }

        let content = fs.readFileSync(filePath, 'utf8');
        let originalContent = content;
        let fixes = 0;

        // Arreglar headers duplicados básicos
        content = content.replace(
            /headers:\s*\{\s*'Content-Type':\s*'application\/json'\s*\}\s*',\s*},/g,
            "headers: {'Content-Type': 'application/json'},"
        );

        // Arreglar headers en URI con duplicados
        content = content.replace(
            /Uri\.parse\([^)]*\),\s*headers:\s*\{[^}]*\},\s*headers:\s*\{[^}]*\},/g,
            (match) => {
                const uriMatch = match.match(/Uri\.parse\([^)]*\)/);
                fixes++;
                return uriMatch ? `${uriMatch[0]},` : match;
            }
        );

        // Arreglar sintaxis incorrecta de headers
        content = content.replace(
            /headers:\s*\{\s*'Content-Type':\s*'application\/json'\s*\}'\s*,/g,
            "headers: {'Content-Type': 'application/json'},"
        );

        // Arreglar comas y llaves extra
        content = content.replace(
            /headers:\s*\{\s*'Content-Type':\s*'application\/json'\s*\}\s*',\s*\}/g,
            "headers: {'Content-Type': 'application/json'}"
        );

        if (content !== originalContent) {
            fs.writeFileSync(filePath, content, 'utf8');
            console.log(`✅ ${filePath}: Corregido`);
        } else {
            console.log(`⚪ ${filePath}: Sin cambios necesarios`);
        }

    } catch (error) {
        console.log(`❌ ${filePath}: Error - ${error.message}`);
    }
});

console.log('🎉 Corrección completada');
