const { app, BrowserWindow } = require('electron');
const path = require('path');
const { spawn } = require('child_process');

let mainWindow;

function createWindow() {
  mainWindow = new BrowserWindow({
    width: 800,
    height: 600,
    webPreferences: {
      nodeIntegration: true,
      contextIsolation: false
    }
  });

  mainWindow.loadURL('http://localhost:8000');

  mainWindow.on('closed', function () {
    mainWindow = null;
  });
}

app.on('ready', () => {
  const appDir = path.join(__dirname, 'AppDir');
  
  // Start MongoDB
  spawn(path.join(appDir, 'usr', 'bin', 'mongod'), ['--fork', '--logpath', path.join(appDir, 'var', 'log', 'mongodb.log'), '--dbpath', path.join(appDir, 'data', 'db')]);

  // Start Redis
  spawn(path.join(appDir, 'usr', 'bin', 'redis-server'));

  // Wait for MongoDB and Redis to start
  setTimeout(() => {
    // Start the Sefaria server
    const pythonPath = path.join(appDir, 'python3.8.13-cp38-cp38-manylinux2010_x86_64.AppDir', 'opt', 'python3.8', 'bin', 'python3.8');
    const managePyPath = path.join(appDir, 'workspaces', 'Sefaria-Project', 'manage.py');
    spawn(pythonPath, [managePyPath, 'runserver']);

    // Create the Electron window
    createWindow();
  }, 5000);
});

app.on('window-all-closed', function () {
  if (process.platform !== 'darwin') app.quit();
});

app.on('activate', function () {
  if (mainWindow === null) createWindow();
});
