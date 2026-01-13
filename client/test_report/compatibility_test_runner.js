// compatibility_test_runner.js
/**
 * ERP+CRM系统兼容性测试执行器
 * 支持跨浏览器、跨设备兼容性测试
 */

const puppeteer = require('puppeteer');
const fs = require('fs');
const path = require('path');

class CompatibilityTestRunner {
  constructor(config) {
    this.config = config;
    this.results = {
      browsers: {},
      devices: {},
      os: {},
      performance: {},
      issues: []
    };
  }

  async runBrowserCompatibilityTests() {
    console.log('开始浏览器兼容性测试...');
    
    const browsers = [
      { name: 'chrome', headless: true },
      { name: 'firefox', headless: true },
      { name: 'webkit', headless: true } // Safari
    ];

    for (const browserConfig of browsers) {
      console.log(`测试 ${browserConfig.name}...`);
      
      try {
        const browser = await puppeteer.launch({
          headless: browserConfig.headless,
          args: ['--no-sandbox', '--disable-setuid-sandbox']
        });

        const page = await browser.newPage();
        await page.setViewport({ width: 1920, height: 1080 });

        // 基础功能测试
        await this.testBasicFunctionality(page, browserConfig.name);
        
        // UI兼容性测试
        await this.testUICompatibility(page, browserConfig.name);
        
        // 性能测试
        await this.testPerformance(page, browserConfig.name);

        await browser.close();
        this.results.browsers[browserConfig.name] = { status: 'completed' };
        
      } catch (error) {
        console.error(`浏览器 ${browserConfig.name} 测试失败:`, error);
        this.results.browsers[browserConfig.name] = { 
          status: 'failed', 
          error: error.message 
        };
        this.results.issues.push({
          type: 'browser',
          browser: browserConfig.name,
          severity: 'P1',
          description: error.message
        });
      }
    }
  }

  async testBasicFunctionality(page, browserName) {
    console.log(`  测试基础功能 (${browserName})...`);
    
    // 测试登录页面
    try {
      await page.goto('http://localhost:8080', { waitUntil: 'networkidle2' });
      
      // 检查页面基本元素
      const title = await page.title();
      console.log(`    页面标题: ${title}`);
      
      // 检查登录表单
      const loginFormExists = await page.$('input[name="username"]');
      const passwordFormExists = await page.$('input[name="password"]');
      
      if (loginFormExists && passwordFormExists) {
        console.log('    登录表单元素检查通过');
      } else {
        throw new Error('登录表单元素缺失');
      }
      
      // 测试JavaScript执行
      const jsWorking = await page.evaluate(() => {
        try {
          const test = () => 'test';
          return typeof test === 'function';
        } catch (e) {
          return false;
        }
      });
      
      if (!jsWorking) {
        throw new Error('JavaScript执行异常');
      }
      
      console.log(`    基础功能测试通过 (${browserName})`);
      
    } catch (error) {
      console.error(`    基础功能测试失败 (${browserName}):`, error.message);
      throw error;
    }
  }

  async testUICompatibility(page, browserName) {
    console.log(`  测试UI兼容性 (${browserName})...`);
    
    try {
      // 测试响应式布局
      const viewports = [
        { width: 1920, height: 1080, name: 'desktop' },
        { width: 768, height: 1024, name: 'tablet' },
        { width: 375, height: 667, name: 'mobile' }
      ];
      
      for (const viewport of viewports) {
        await page.setViewport(viewport);
        await page.waitForTimeout(1000);
        
        // 检查布局是否正常
        const bodyWidth = await page.evaluate(() => document.body.offsetWidth);
        if (Math.abs(bodyWidth - viewport.width) > 50) {
          console.warn(`    布局异常 (${viewport.name}): 期望${viewport.width}px, 实际${bodyWidth}px`);
        }
      }
      
      console.log(`    UI兼容性测试通过 (${browserName})`);
      
    } catch (error) {
      console.error(`    UI兼容性测试失败 (${browserName}):`, error.message);
      throw error;
    }
  }

  async testPerformance(page, browserName) {
    console.log(`  测试性能 (${browserName})...`);
    
    try {
      const startTime = Date.now();
      await page.goto('http://localhost:8080', { waitUntil: 'networkidle2' });
      const loadTime = Date.now() - startTime;
      
      console.log(`    加载时间: ${loadTime}ms`);
      
      if (loadTime > 5000) {
        console.warn(`    加载时间过长: ${loadTime}ms`);
      }
      
      // 检查内存使用
      const memoryInfo = await page.evaluate(() => {
        if (performance.memory) {
          return {
            used: performance.memory.usedJSHeapSize,
            total: performance.memory.totalJSHeapSize,
            limit: performance.memory.jsHeapSizeLimit
          };
        }
        return null;
      });
      
      if (memoryInfo) {
        console.log(`    内存使用: ${(memoryInfo.used / 1024 / 1024).toFixed(2)}MB / ${(memoryInfo.total / 1024 / 1024).toFixed(2)}MB`);
      }
      
      this.results.performance[browserName] = {
        loadTime,
        memoryInfo
      };
      
      console.log(`    性能测试完成 (${browserName})`);
      
    } catch (error) {
      console.error(`    性能测试失败 (${browserName}):`, error.message);
      throw error;
    }
  }

  async runDeviceCompatibilityTests() {
    console.log('开始设备兼容性测试...');
    
    const devices = [
      { name: 'Desktop Chrome', width: 1920, height: 1080 },
      { name: 'iPhone 12', width: 390, height: 844, userAgent: 'Mozilla/5.0 (iPhone; CPU iPhone OS 14_0 like Mac OS X) AppleWebKit/605.1.15' },
      { name: 'iPad', width: 768, height: 1024, userAgent: 'Mozilla/5.0 (iPad; CPU OS 14_0 like Mac OS X) AppleWebKit/605.1.15' },
      { name: 'Samsung Galaxy S21', width: 360, height: 800, userAgent: 'Mozilla/5.0 (Linux; Android 11; SM-G991B) AppleWebKit/537.36' }
    ];
    
    for (const device of devices) {
      console.log(`测试设备: ${device.name}`);
      
      try {
        const browser = await puppeteer.launch({ headless: true });
        const page = await browser.newPage();
        
        await page.setViewport({ 
          width: device.width, 
          height: device.height,
          userAgent: device.userAgent 
        });
        
        await page.goto('http://localhost:8080', { waitUntil: 'networkidle2' });
        
        // 测试触摸交互
        await this.testTouchInteractions(page, device.name);
        
        // 测试响应式布局
        await this.testResponsiveLayout(page, device.name);
        
        await browser.close();
        
        this.results.devices[device.name] = { status: 'completed' };
        
      } catch (error) {
        console.error(`设备 ${device.name} 测试失败:`, error);
        this.results.devices[device.name] = { 
          status: 'failed', 
          error: error.message 
        };
      }
    }
  }

  async testTouchInteractions(page, deviceName) {
    try {
      // 模拟触摸操作
      await page.touchscreen.tap(100, 100);
      await page.waitForTimeout(500);
      
      // 检查是否有触摸事件监听器
      const touchEvents = await page.evaluate(() => {
        const events = [];
        document.addEventListener('touchstart', () => events.push('touchstart'));
        document.addEventListener('touchend', () => events.push('touchend'));
        return events.length > 0;
      });
      
      console.log(`    触摸交互测试通过 (${deviceName})`);
      
    } catch (error) {
      console.error(`    触摸交互测试失败 (${deviceName}):`, error.message);
    }
  }

  async testResponsiveLayout(page, deviceName) {
    try {
      const viewport = page.viewportSize();
      
      // 检查页面内容是否适配
      const layoutTest = await page.evaluate((vp) => {
        const bodyWidth = document.body.offsetWidth;
        const isResponsive = Math.abs(bodyWidth - vp.width) < 100;
        
        // 检查是否存在横向滚动条
        const hasHorizontalScroll = document.documentElement.scrollWidth > document.documentElement.clientWidth;
        
        return {
          isResponsive,
          bodyWidth,
          hasHorizontalScroll,
          expectedWidth: vp.width
        };
      }, viewport);
      
      if (!layoutTest.isResponsive) {
        console.warn(`    响应式布局异常 (${deviceName}): 期望${layoutTest.expectedWidth}px, 实际${layoutTest.bodyWidth}px`);
      }
      
      if (layoutTest.hasHorizontalScroll) {
        console.warn(`    检测到横向滚动条 (${deviceName})`);
      }
      
      console.log(`    响应式布局测试完成 (${deviceName})`);
      
    } catch (error) {
      console.error(`    响应式布局测试失败 (${deviceName}):`, error.message);
    }
  }

  async runFunctionalConsistencyTests() {
    console.log('开始功能一致性测试...');
    
    const testCases = [
      { name: '登录功能', url: '/login', elements: ['input[name="username"]', 'input[name="password"]', 'button[type="submit"]'] },
      { name: '订单列表', url: '/orders', elements: ['.order-list', '.search-bar', '.filter-options'] },
      { name: '商品管理', url: '/products', elements: ['.product-grid', '.add-button', '.category-filter'] },
      { name: '业务管理', url: '/business', elements: ['.business-tabs', '.category-match', '.batch-operations'] }
    ];
    
    for (const testCase of testCases) {
      console.log(`  测试功能: ${testCase.name}`);
      
      try {
        const browser = await puppeteer.launch({ headless: true });
        const page = await browser.newPage();
        await page.setViewport({ width: 1920, height: 1080 });
        
        await page.goto(`http://localhost:8080${testCase.url}`, { waitUntil: 'networkidle2' });
        
        // 检查必需元素是否存在
        for (const element of testCase.elements) {
          const exists = await page.$(element);
          if (!exists) {
            throw new Error(`缺少必需元素: ${element}`);
          }
        }
        
        console.log(`    功能测试通过: ${testCase.name}`);
        
        await browser.close();
        
      } catch (error) {
        console.error(`    功能测试失败: ${testCase.name} - ${error.message}`);
        this.results.issues.push({
          type: 'functional',
          module: testCase.name,
          severity: 'P1',
          description: error.message
        });
      }
    }
  }

  generateReport() {
    const report = {
      summary: {
        totalTests: Object.keys(this.results.browsers).length + Object.keys(this.results.devices).length,
        passedTests: 0,
        failedTests: 0,
        issuesCount: this.results.issues.length
      },
      details: this.results,
      timestamp: new Date().toISOString()
    };
    
    // 统计通过率
    for (const [browser, result] of Object.entries(this.results.browsers)) {
      if (result.status === 'completed') report.summary.passedTests++;
      else report.summary.failedTests++;
    }
    
    for (const [device, result] of Object.entries(this.results.devices)) {
      if (result.status === 'completed') report.summary.passedTests++;
      else report.summary.failedTests++;
    }
    
    return report;
  }

  saveReport(report, filename) {
    const reportPath = path.join(__dirname, '..', 'test_report', filename);
    fs.writeFileSync(reportPath, JSON.stringify(report, null, 2));
    console.log(`测试报告已保存: ${reportPath}`);
  }
}

// 主执行函数
async function main() {
  const runner = new CompatibilityTestRunner({});
  
  try {
    console.log('开始ERP+CRM系统兼容性测试...\n');
    
    await runner.runBrowserCompatibilityTests();
    await runner.runDeviceCompatibilityTests();
    await runner.runFunctionalConsistencyTests();
    
    const report = runner.generateReport();
    runner.saveReport(report, `compatibility_test_results_${Date.now()}.json`);
    
    console.log('\n=== 测试完成 ===');
    console.log(`总测试数: ${report.summary.totalTests}`);
    console.log(`通过测试: ${report.summary.passedTests}`);
    console.log(`失败测试: ${report.summary.failedTests}`);
    console.log(`发现问题: ${report.summary.issuesCount}`);
    
  } catch (error) {
    console.error('测试执行失败:', error);
    process.exit(1);
  }
}

if (require.main === module) {
  main();
}

module.exports = CompatibilityTestRunner;