// const { resolve } = require('path');

require('dotenv').config({ path: `.env.prod` })

// {
//   path: resolve(__dirname, `.env.prod`),
// }

const { TENANT_URI, SIGNIN_URI } = process.env;

/** @type {import('next').NextConfig} */
const nextConfig = {
  reactStrictMode: true,
  // Available only on server
  serverRuntimeConfig: {},
  // Will be available on both server and client
  publicRuntimeConfig: {
    TENANT_URI,
    SIGNIN_URI,
  },
};

module.exports = nextConfig;
