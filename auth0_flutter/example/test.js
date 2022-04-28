const wdio = require('webdriverio');

const assert = require('assert');

const find = require('appium-flutter-finder');




const osSpecificOps = process.env.APPIUM_OS === 'android' ? {

  platformName: 'Android',

  deviceName: 'emulator-5554',

  app: __dirname +  '/build/app/outputs/flutter-apk/app-debug.apk',

}: process.env.APPIUM_OS === 'ios' ? {

  platformName: 'iOS',

  platformVersion: '12.2',

  deviceName: 'iPhone X',

  noReset: true,

  app: __dirname +  '/../ios/Runner.zip',




} : {};




const opts = {

  port: 4723,
  path: '/wd/hub/',

  capabilities: {

    ...osSpecificOps,

    automationName: 'Flutter'

  }

};




(async () => {

  console.log('Initial app testing')

  const driver = await wdio.remote(opts);

   assert.strictEqual(await driver.execute('flutter:checkHealth'), 'ok');




  //Enter login page

  await driver.execute('flutter:waitFor', find.byValueKey('webAuthLoginBtn'));

  await driver.elementClick(find.byValueKey('webAuthLoginBtn'));


  await driver.execute('flutter:waitFor', find.byType('input'));
  await driver.execute('flutter:waitFor', find.byType('input'));

  await driver.elementSendKeys(find.byType('input'), 'xyz@gmail.com');
  await driver.elementSendKeys(find.byType('input'), '123')

  await driver.execute('flutter:waitFor', find.byValueKey('webAuthLoginBtnz'));

  driver.deleteSession();

})();
