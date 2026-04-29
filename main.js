const { app, BrowserWindow, Menu } = require('electron');
const path = require('path');

// ── PORTABILITY: Store database and settings in the same folder as the EXE ──
const portableDir = process.env.PORTABLE_EXECUTABLE_DIR || app.getPath('userData');
app.setPath('userData', path.join(portableDir, 'pafwa-data'));

function createWindow() {
  const win = new BrowserWindow({
    width: 1280,
    height: 800,
    minWidth: 1000,
    minHeight: 600,
    icon: path.join(__dirname, 'IMG-20260409-WA0035~3.ico'),
    webPreferences: {
      nodeIntegration: false,
      contextIsolation: true,
      preload: path.join(__dirname, 'preload.js') // We'll create this if needed, but for now standard web is fine
    },
    titleBarStyle: 'default',
    autoHideMenuBar: false
  });

  win.loadFile('index.html');

  // Custom Menu
  const template = [
    {
      label: 'File',
      submenu: [
        { role: 'quit' }
      ]
    },
    {
      label: 'Edit',
      submenu: [
        { role: 'undo' },
        { role: 'redo' },
        { type: 'separator' },
        { role: 'cut' },
        { role: 'copy' },
        { role: 'paste' }
      ]
    },
    {
      label: 'View',
      submenu: [
        { role: 'reload' },
        { role: 'toggledevtools' },
        { type: 'separator' },
        { role: 'resetzoom' },
        { role: 'zoomin' },
        { role: 'zoomout' },
        { type: 'separator' },
        { role: 'togglefullscreen' }
      ]
    },
    {
      label: 'Help',
      submenu: [
        {
          label: 'About PAFWA System',
          click: async () => {
            const { dialog } = require('electron');
            dialog.showMessageBox({
              type: 'info',
              title: 'About',
              message: 'PAFWA Inventory & Management System',
              detail: 'Version 1.0.0\nDeveloped for PAFWA APF PAC Kamra.'
            });
          }
        }
      ]
    }
  ];

  const menu = Menu.buildFromTemplate(template);
  Menu.setApplicationMenu(menu);
}

app.whenReady().then(() => {
  createWindow();

  app.on('activate', () => {
    if (BrowserWindow.getAllWindows().length === 0) {
      createWindow();
    }
  });
});

app.on('window-all-closed', () => {
  if (process.platform !== 'darwin') {
    app.quit();
  }
});
