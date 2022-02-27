module.exports = {
    globals: {
      "ts-jest": {
        tsconfig: "tsconfig.json"
      }
    },
    moduleFileExtensions: ["ts", "js"],
    transform: {
      "^.+\\.(ts)$": "ts-jest"
    },
    testMatch: ["**/test/**/*.test.(ts|js)", "**/**/*.test.(ts|js)"],
    testPathIgnorePatterns: ["/node_modules/", "build"],
    testEnvironment: "node",
    rootDir: ".",
    collectCoverageFrom: [
      // "!<rootDir>/src/activity/*.ts",
      // "<rootDir>/src/db/**/*.ts",
      // "<rootDir>/src/jwks/**/*.ts",
      // "<rootDir>/src/oauth2/**/*.ts",
      // "<rootDir>/src/resolvers/**/*.ts",
      // "<rootDir>/src/schema/**/*.ts",
      // "<rootDir>/src/security/**/*.ts",
      // "<rootDir>/src/utils/**/*.ts",
      // "<rootDir>/src/vendors/**/*.ts"
    ]
  };