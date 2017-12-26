const desktop = (browser) => {
  browser
    .url('http://localhost:4000')
    .waitForElementVisible('body');
}

const mobile = desktop;

const resize = (browser) => {
  browser.resizeWindow(450, 600);
}

export default { desktop, mobile, resize };
