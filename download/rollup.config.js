import commonjs from '@rollup/plugin-commonjs';
import resolve from '@rollup/plugin-node-resolve';
import json from '@rollup/plugin-json';

export default {
    input: 'src/main/js/index.js',
    output: {
        file: 'index.js',
        format: 'cjs'
    },
    plugins: [
        commonjs(),
        resolve({
            browser: false,
            preferBuiltins: false,
        }),
        json()
    ]
};
