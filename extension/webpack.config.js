/* eslint-disable @typescript-eslint/no-var-requires */
/* eslint-env node */
const path = require('path')
const HtmlWebPackPlugin = require('html-webpack-plugin')
const CopyPlugin = require('copy-webpack-plugin')
const { ProvidePlugin, SourceMapDevToolPlugin } = require('webpack')
const DotenvWebPack = require('dotenv-webpack')
const { EsbuildPlugin } = require('esbuild-loader')
const ForkTsCheckerWebpackPlugin = require('fork-ts-checker-webpack-plugin')

const htmlPlugin = new HtmlWebPackPlugin({
  template: './src/entries/UI/index.html',
  filename: './index.html',
  excludeChunks: ['background'],
})

const isProd = process.env.NODE_ENV === 'production'
const safeEnvVars = process.env.SAFE_ENV_VARS === 'true'

if (safeEnvVars) {
  console.log('Safe env vars enabled')
}

/**
 * @type {import('webpack').Configuration}
 */
module.exports = {
  entry: {
    main: './src/entries/UI',
    background: './src/entries/Background',
    content: './src/entries/Content/content.ts',
    contentScript: './src/entries/Content/index.ts',
  },
  performance: {
    hints: false,
  },
  mode: isProd ? 'production' : 'development',
  module: {
    rules: [
      {
        test: /\.svg$/,
        use: [
          {
            loader: '@svgr/webpack',
            options: {},
          },
        ],
      },
      {
        test: /\.(png|jpg|gif|txt)$/i,
        use: [
          {
            loader: 'url-loader',
            options: {
              limit: 8192,
            },
          },
        ],
      },
      {
        test: /\.tsx?$/,
        loader: 'esbuild-loader',
        options: {
          pure: isProd ? ['console.log', 'console.warn'] : [],
          target: 'es2020',
        },
      },
    ],
  },
  resolve: {
    extensions: ['.js', '.jsx', '.ts', '.tsx', '.css'],
    alias: {
      src: path.resolve(__dirname, './src/'),
    },
  },
  plugins: [
    htmlPlugin,

    new CopyPlugin({
      patterns: [
        { from: './src/favicon.ico', to: 'favicon.ico' },
        { from: `./src/manifest.json`, to: 'manifest.json' },
      ],
    }),

    new ProvidePlugin({
      React: 'react',
    }),

    isProd &&
      new SourceMapDevToolPlugin({
        filename: '../sourcemaps/[file].map',
        append: `\n//# sourceMappingURL=[file].map`,
      }), // For development, we use the devtool option instead

    new ForkTsCheckerWebpackPlugin(), // does the type checking in a separate process (non-blocking in dev) as esbuild is skipping type checking

    new DotenvWebPack({
      systemvars: true,
      safe: safeEnvVars,
    }),
  ].filter(Boolean),
  devtool: isProd ? false : 'inline-cheap-module-source-map',
  optimization: isProd
    ? {
        minimize: true,
        minimizer: [
          new EsbuildPlugin({
            loader: 'tsx',
            target: 'es2020',
          }),
        ],
        splitChunks: {
          chunks(chunk) {
            return chunk.name === 'main'
          },
        },
      }
    : undefined,
  output: {
    filename: '[name].js',
    path: path.resolve(__dirname, 'build'),
  },
}
