import commonjs from '@rollup/plugin-commonjs';
import resolve from '@rollup/plugin-node-resolve';
import nodePolyfills from 'rollup-plugin-node-polyfills';
import json from '@rollup/plugin-json';

export default {
    input: 'anchor/main.js',
    output: {
        file: 'bundle.js',
        format: 'es'
    },
    plugins: [
        commonjs(),
        nodePolyfills(),
        resolve({
            browser: true
        }),
        json()
    ]
};
