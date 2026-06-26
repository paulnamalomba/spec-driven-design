#!/usr/bin/env node

/**
 * example_script.cjs
 * 
 * A utility script to quickly scaffold the required output directory 
 * for the Code Analysis & Recommendations skill.
 * 
 * Usage: node example_script.cjs [month]
 */

const fs = require('fs');
const path = require('path');
const os = require('os');

const monthArgs = process.argv[2];
const defaultMonth = new Date().toLocaleString('default', { month: 'long' }).toLowerCase();
const month = monthArgs ? monthArgs.toLowerCase() : defaultMonth;

const baseDir = path.join(os.homedir(), 'Development', 'ecoride', 'docs', 'ideas', month);

try {
    if (!fs.existsSync(baseDir)) {
        fs.mkdirSync(baseDir, { recursive: true });
        console.log('✅ Created directory: ' + baseDir);
    } else {
        console.log('ℹ️ Directory already exists: ' + baseDir);
    }
} catch (error) {
    console.error('❌ Error creating directory: ' + error.message);
    process.exit(1);
}
