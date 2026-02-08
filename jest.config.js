export default {
  testEnvironment: 'node',
  coverageDirectory: 'coverage',
  collectCoverageFrom: ['src/**/*.js', '!src/**/*.test.js', '!src/index-mongodb-example.js'],
  testMatch: ['**/tests/**/*.test.js'],
  transform: {},
  moduleNameMapper: {
    '^(\\.\\.\\/.*)\\.js$': '$1',
  },
  coverageThreshold: {
    global: {
      branches: 0,
      functions: 15,
      lines: 8,
      statements: 8,
    },
  },
};
