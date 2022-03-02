module.exports = {
  globals: {
    'ts-jest': {
      tsconfig: 'tsconfig.json',
    },
  },
  moduleFileExtensions: ['ts', 'js'],
  modulePathIgnorePatterns: ["<rootDir>/dist/"],
  transform: {
    '^.+\\.(ts)$': 'ts-jest',
  },
  testMatch: ['**/test/**/*.test.(ts|js)', '**/**/*.test.(ts|js)'],
  testPathIgnorePatterns: ['/node_modules/', 'build'],
  testEnvironment: 'node',
  rootDir: '.',
  collectCoverageFrom: []
};
