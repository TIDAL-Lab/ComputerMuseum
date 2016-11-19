ComputerMuseum
==============

Programming exhibit for the Computer History Museum


1. Install DART (https://www.dartlang.org/install/windows)

  * I recommend using Chocolatey and powershell
  * Make sure to install the optional packages (dart-sdk and dartium)

2. Install Google Chrome

3. Install the Kiosk app for Chrome (https://chrome.google.com/webstore/detail/kiosk/afhcomalholahplbjhnmahkoekoijban)

4. Install git (https://git-scm.com/downloads)

5. Install github Desktop app if desired (https://desktop.github.com/)

6. Clone the github repo (https://github.com/TIDAL-Lab/ComputerMuseum/tree/v2)

7. Go to your install directory in powershell and type:
```
cd <install directory>
pub get
pub build
```
  If that works, it should create a directory called `build` in the root of your install directory. 

8. Point Chrome to this URL to test:

  `file:///<GITHUB_ROOT>/ComputerMuseum/build/web/index.html`

9. Now you can configure the Chrome kiosk app to point to this URL. 