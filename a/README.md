This is a new [**React Native**](https://reactnative.dev) project, bootstrapped using [`@react-native-community/cli`](https://github.com/react-native-community/cli).

# Getting Started

> **Note**: Make sure you have completed the [Set Up Your Environment](https://reactnative.dev/docs/set-up-your-environment) guide before proceeding.

## Step 1: Start Metro

First, you will need to run **Metro**, the JavaScript build tool for React Native.

To start the Metro dev server, run the following command from the root of your React Native project:

```sh
# Using npm
npm start

# OR using Yarn
yarn start
```

## Step 2: Build and run your app

With Metro running, open a new terminal window/pane from the root of your React Native project, and use one of the following commands to build and run your Android or iOS app:

### Android

```sh
# Using npm
npm run android

# OR using Yarn
yarn android
```

### iOS

For iOS, remember to install CocoaPods dependencies (this only needs to be run on first clone or after updating native deps).

The first time you create a new project, run the Ruby bundler to install CocoaPods itself:

```sh
bundle install
```

Then, and every time you update your native dependencies, run:

```sh
bundle exec pod install
```

For more information, please visit [CocoaPods Getting Started guide](https://guides.cocoapods.org/using/getting-started.html).

```sh
# Using npm
npm run ios

# OR using Yarn
yarn ios
```

If everything is set up correctly, you should see your new app running in the Android Emulator, iOS Simulator, or your connected device.

This is one way to run your app — you can also build it directly from Android Studio or Xcode.

## Step 3: Modify your app

Now that you have successfully run the app, let's make changes!

Open `App.tsx` in your text editor of choice and make some changes. When you save, your app will automatically update and reflect these changes — this is powered by [Fast Refresh](https://reactnative.dev/docs/fast-refresh).

When you want to forcefully reload, for example to reset the state of your app, you can perform a full reload:

- **Android**: Press the <kbd>R</kbd> key twice or select **"Reload"** from the **Dev Menu**, accessed via <kbd>Ctrl</kbd> + <kbd>M</kbd> (Windows/Linux) or <kbd>Cmd ⌘</kbd> + <kbd>M</kbd> (macOS).
- **iOS**: Press <kbd>R</kbd> in iOS Simulator.

## Congratulations! :tada:

You've successfully run and modified your React Native App. :partying_face:

### Now what?

- If you want to add this new React Native code to an existing application, check out the [Integration guide](https://reactnative.dev/docs/integration-with-existing-apps).
- If you're curious to learn more about React Native, check out the [docs](https://reactnative.dev/docs/getting-started).

# Troubleshooting

If you're having issues getting the above steps to work, see the [Troubleshooting](https://reactnative.dev/docs/troubleshooting) page.

# Learn More

To learn more about React Native, take a look at the following resources:

- [React Native Website](https://reactnative.dev) - learn more about React Native.
- [Getting Started](https://reactnative.dev/docs/environment-setup) - an **overview** of React Native and how setup your environment.
- [Learn the Basics](https://reactnative.dev/docs/getting-started) - a **guided tour** of the React Native **basics**.
- [Blog](https://reactnative.dev/blog) - read the latest official React Native **Blog** posts.
- [`@facebook/react-native`](https://github.com/facebook/react-native) - the Open Source; GitHub **repository** for React Native.



npx react-native start



# 1. Initialize git (just in case)
git init

# 2. Add your GitHub as the destination
git remote add origin https://github.com/MladenBG/appandroid.git

# 3. Rename the branch to 'main'
git branch -M main
# 1. Prepare all files (except the ones in .gitignore)
git add .


# 2. Create the save point
git commit -m "Fixed C++ build errors and added Admin/Chat logic"

# 3. Push to GitHub
git push -u origin main
 to second repo
 git remote add second https://github.com/MladenBG/appad2.git
 git remote -v
 git push second main
git push second main --force




chat
npm install socket.io-client react-native-gifted-chat


for building card stack

npm install expo
npx expo install react-native-gesture-handler react-native-reanimated



when getting errors

# 1. Delete node_modules and the broken android folder
Remove-Item -Recurse -Force node_modules
Remove-Item -Recurse -Force android

# 2. Reinstall your packages (this fixes the 'ExpoModuleExtension' error)
npm install

# 3. Rebuild the native Android files
npx expo prebuild


npx expo prebuild

npx expo run:android

if that not fix than 

# This forces all packages to match the stable Expo version
npx expo install --fix

# This specifically ensures Reanimated is on a version that supports your React Native
npx expo install react-native-reanimated

cd android
./gradlew clean
cd ..

npx expo run:android
npx expo install --fix -- --force
npx expo run:android

npx expo start


or


npx expo start --clear


or

npx expo start --dev-client --clear


errors etc,,,,a
npm install babel-preset-expo --legacy-peer-deps



npm install react-native-worklets --legacy-peer-deps


checking errors

npx expo-doctor


other errors
npx expo install react-native-keyboard-controller -- --legacy-peer-deps

npm install --save-dev react-test-renderer@19.1.0 --legacy-peer-deps


cd C:\MyNewApp
# Clean out the old build attempts
rm -r -Force android/app/.cxx
rm -r -Force android/build
rm -r -Force android/app/build

# Run the build again
npx expo run:android




run 
npx expo start --dev-client


Rebuild after changes
npx expo start -c


for video chat not crash only once when building for agora nativac c++

npx expo run:android


adding icons and navigation

npx expo install @react-navigation/native @react-navigation/bottom-tabs react-native-vector-icons


kill ghost process
cd android
./gradlew --stop


for errors in androis studio in vs code type

npx expo start --clear

npx expo install --fix

npx expo prebuild --platform android --clean




run 
npx expo start --dev-client




or

npx expo start

or

npx expo start --no-dev


SEND TO REPO

github

# 1. Initialize git (just in case)
git init

# 2. Add your GitHub as the destination
git remote add origin https://github.com/MladenBG/appandroid.git
if you have remote origin if you save to repo

git remote set-url origin https://github.com/MladenBG/MYWEBSITEEE1.git

# 3. Rename the branch to 'main'
git branch -M main
# 1. Prepare all files (except the ones in .gitignore)
git add .

# 2. Create the save point
git commit -m "Fixed C++ build errors and added Admin/Chat logic"

# 3. Push to GitHub
git push -u origin main
git push -u origin main --force

git push -f origin main


to diferent repo 
git remote set-url origin https://github.com/MladenBG/Websiteeeeee.git
git remote -v
git add .
git commit -m "Transferring project to new repository"
git push -u origin main --force




UPDATING CHAGES TO GITHUB

git add .


Commit with a message: This saves those changes locally and labels them so you know what you changed.
bash

git commit -m "Update multiple files with new features"


Push to GitHub: This uploads your saved local changes to the online repository.
bash
git push origin main



npm install nativewind
npm install --save-dev tailwindcss@3.3.2
npx tailwindcss init


// UNCOMMENT THIS LINE WHEN YOUR GOOGLE PLAY ACCOUNT IS LINKED:
// const { customerInfo } = await Purchases.purchaseProduct(productId);

// For now, we simulate a successful Google Pay transaction and tell App.tsx to unlock VIP
handlePayment(planIdentifier);




ZEGO CLOUD video chat

npm install @zegocloud/zego-uikit-prebuilt-call-rn @zegocloud/zego-uikit-rn zego-express-engine-reactnative react-delegate-component


psql -U postgres


\c dateroot

\d users umesto \d profiles


npm install bcrypt
npm install -D @types/bcrypt

npx expo install expo-linear-gradient

npm install react-native-paper



for backend dateroot-backend


npm run dev