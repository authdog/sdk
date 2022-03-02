const { resolve } = require('path');

require('dotenv').config({
    path: resolve(__dirname, `.env.${process.env.STAGE}`),
    debug: true
})

const { TENANT_URI, SIGNIN_URI } = process.env;

/** @type {import('next').NextConfig} */
const nextConfig = {
  reactStrictMode: true,
  serverRuntimeConfig: {},
  publicRuntimeConfig: {
    TENANT_URI,
    SIGNIN_URI,
  },
};

module.exports = nextConfig;
