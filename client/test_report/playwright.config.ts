// tests/config/playwright.config.ts
import { defineConfig, devices } from '@playwright/test';

export default defineConfig({
  testDir: './tests',
  fullyParallel: true,
  forbidOnly: !!process.env.CI,
  retries: process.env.CI ? 2 : 0,
  workers: process.env.CI ? 1 : undefined,
  reporter: [
    ['html', { outputFolder: 'test-results/playwright-report' }],
    ['json', { outputFile: 'test-results/results.json' }]
  ],
  use: {
    baseURL: 'http://localhost:8080',
    trace: 'on-first-retry',
    screenshot: 'only-on-failure',
    video: 'retain-on-failure',
  },
  projects: [
    // 桌面浏览器测试
    {
      name: 'chromium',
      use: { ...devices['Desktop Chrome'], channel: 'chrome' },
    },
    {
      name: 'firefox',
      use: { ...devices['Desktop Firefox'] },
    },
    {
      name: 'webkit',
      use: { ...devices['Desktop Safari'] },
    },
    
    // 浏览器版本兼容性测试
    {
      name: 'chrome-118',
      use: { ...devices['Desktop Chrome'], channel: 'chrome' },
    },
    {
      name: 'chrome-119',
      use: { ...devices['Desktop Chrome'], channel: 'chrome-beta' },
    },
    {
      name: 'firefox-119',
      use: { ...devices['Desktop Firefox'] },
    },
    {
      name: 'firefox-120',
      use: { ...devices['Desktop Firefox'] },
    },
    
    // 移动设备测试
    {
      name: 'iPhone 15',
      use: { ...devices['iPhone 15'] },
    },
    {
      name: 'iPhone 14',
      use: { ...devices['iPhone 14'] },
    },
    {
      name: 'Samsung Galaxy S24',
      use: { ...devices['Galaxy S24'] },
    },
    {
      name: 'Samsung Galaxy S21',
      use: { ...devices['Galaxy S21'] },
    },
    
    // 平板设备测试
    {
      name: 'iPad Pro',
      use: { ...devices['iPad Pro'] },
    },
    {
      name: 'iPad',
      use: { ...devices['iPad'] },
    },
    
    // 特殊分辨率测试
    {
      name: '1366x768',
      use: { 
        ...devices['Desktop Chrome'],
        viewport: { width: 1366, height: 768 }
      },
    },
    {
      name: '1280x720',
      use: { 
        ...devices['Desktop Chrome'],
        viewport: { width: 1280, height: 720 }
      },
    }
  ],
  
  webServer: {
    command: 'flutter run -d chrome --web-port=8080',
    port: 8080,
    reuseExistingServer: !process.env.CI,
    timeout: 120000,
  },
  
  globalSetup: require.resolve('./tests/setup/global-setup.ts'),
  globalTeardown: require.resolve('./tests/setup/global-teardown.ts'),
});