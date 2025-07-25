const fs = require('fs');
const path = require('path');

// 🔍 SCRIPT PARA DETECTAR Y ARREGLAR HEADERS DUPLICADOS

const flutterFiles = [
    '../lib/verification_code_page.dart',
    '../lib/verify_page.dart',
    '../lib/statistics_page.dart',
    '../lib/reset_password_pag.dart',
    '../lib/reset_password_page.dart',
    '../lib/recover_password_page.dart',
    '../lib/register_page.dart',
    '../lib/PetMatchTab.dart',
    '../lib/login_page.dart',
    '../lib/edit_profile_page.dart',
    '../lib/crud_page_new.dart',
    '../lib/crud_page.dart',
    '../lib/admin_panel.dart'
];

// 🔧 Función para arreglar headers duplicados
function fixDuplicateHeaders(filePath) {
    try {
        if (!fs.existsSync(filePath)) {
            console.log(`   ⚠️  ${path.basename(filePath)}: archivo no encontrado`);
            return { fixed: false, errors: 0 };
        }

        let content = fs.readFileSync(filePath, 'utf8');
        const originalContent = content;
        let errors = 0;

        // Detectar y arreglar headers duplicados
        const duplicateHeadersRegex = /Uri\.parse\([^)]+\),\s*headers:\s*\{[^}]*\},\s*headers:\s*\{[^}]*\},\s*headers:\s*\{[^}]*\}/g;
        const simpleHeadersRegex = /Uri\.parse\([^)]+\),\s*headers:\s*\{[^}]*\},\s*headers:\s*\{[^}]*\}/g;
        
        // Arreglar casos con 3 headers
        content = content.replace(duplicateHeadersRegex, (match) => {
            errors++;
            console.log(`   🔧 Arreglando header triplicado en ${path.basename(filePath)}`);
            // Extraer la URI y mantener solo un header
            const uriMatch = match.match(/Uri\.parse\([^)]+\)/);
            return uriMatch ? `${uriMatch[0]},\n        headers: {'Content-Type': 'application/json'}` : match;
        });

        // Arreglar casos con 2 headers
        content = content.replace(simpleHeadersRegex, (match) => {
            errors++;
            console.log(`   🔧 Arreglando header duplicado en ${path.basename(filePath)}`);
            // Extraer la URI y mantener solo un header
            const uriMatch = match.match(/Uri\.parse\([^)]+\)/);
            return uriMatch ? `${uriMatch[0]},\n        headers: {'Content-Type': 'application/json'}` : match;
        });

        // Arreglar headers en parámetros de URI
        const uriWithHeadersRegex = /Uri\.parse\(\s*['"`]([^'"`]+)['"`]\s*,\s*headers:\s*\{[^}]*\}/g;
        content = content.replace(uriWithHeadersRegex, (match, url) => {
            errors++;
            console.log(`   🔧 Arreglando header en URI en ${path.basename(filePath)}`);
            return `Uri.parse('${url}')`;
        });

        // Escribir el archivo si hubo cambios
        if (content !== originalContent) {
            fs.writeFileSync(filePath, content, 'utf8');
            console.log(`   ✅ ${path.basename(filePath)}: corregido (${errors} errores)`);
            return { fixed: true, errors };
        } else {
            console.log(`   ⚪ ${path.basename(filePath)}: sin errores`);
            return { fixed: false, errors: 0 };
        }

    } catch (error) {
        console.log(`   ❌ ${path.basename(filePath)}: error - ${error.message}`);
        return { fixed: false, errors: 0 };
    }
}

// 🚀 Función principal
function main() {
    console.log('🔍 Revisando y arreglando headers duplicados en archivos Dart');
    console.log('==========================================================');

    let totalFixed = 0;
    let totalErrors = 0;

    flutterFiles.forEach(file => {
        const result = fixDuplicateHeaders(file);
        if (result.fixed) totalFixed++;
        totalErrors += result.errors;
    });

    console.log('==========================================================');
    console.log('📊 Resumen:');
    console.log(`   - Archivos corregidos: ${totalFixed}`);
    console.log(`   - Total de errores arreglados: ${totalErrors}`);
    console.log('==========================================================');
    
    if (totalFixed > 0) {
        console.log('🎉 ¡Errores de headers duplicados corregidos!');
        console.log('🔄 Recuerda hacer hot reload en Flutter');
    } else {
        console.log('✅ No se encontraron errores de headers duplicados');
    }
}

// Ejecutar
main();
