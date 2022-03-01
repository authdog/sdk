const { resolve } = require('path');
require('dotenv').config({
  path: resolve(
    __dirname,
    `.env.${process.env.STAGE}`
  ),
});

const { TENANT_URI, SIGNIN_URI } = process.env;

/** @type {import('next').NextConfig} */
const nextConfig = {
  reactStrictMode: true,
  // images: {
  //   domains: ['res.cloudinary.com'],
  // },
    // Available only on server
    serverRuntimeConfig: {},
    // Will be available on both server and client
    publicRuntimeConfig: {
      TENANT_URI,
      SIGNIN_URI,
    }
};

module.exports = nextConfig;
