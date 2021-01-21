# Symbl Agora iOS Swift App

This tutorial enables you to quickly get started with Adding Symbl.ai in your development efforts to create an iOS app with real-time video calls, voice calls, and interactive broadcasting using Agora.  

With this sample app you can:

- Start and end audio/visual communication between two users.
- Join a communication channel.
- Mute and unmute audio.
- Enable and disable video.
- Switch between the front and rear cameras.
- Receive and show live transcriptions and insights from Symbl

## Prerequisites

- Xcode 10.0+
- Physical iOS device (iPhone or iPad)
- iOS simulator is NOT supported
- Agora Account
- Symbl Account

## Quick Start

This section shows you how to prepare, build, and run the sample application.

### Obtain an App Id

To build and run the sample application, get an App Id:

1. Create a developer account at [agora.io](https://dashboard.agora.io/signin/). Once you finish the signup process, you will be redirected to the Dashboard.
2. Navigate in the Dashboard tree on the left to **Projects** > **Project List**.
3. Save the **App Id** from the Dashboard for later use.
4. Generate a temp **Access Token** (valid for 24 hours) from dashboard page with given channel name, save for later use.

5. Open `Agora iOS Tutorial.xcodeproj` and edit the `AppID.swift` file. In the `agoraKit` declaration, update `<#Your App Id#>` with your App Id, and assign the token variable with the temp Access Token generated from dashboard.

    ```Swift
    let AppID: String = <#Your App Id#>
    // assign Token to nil if you have not enabled app certificate
    let Token: String? = <#Temp Token#>
    ```
### Obtain Symbl App ID and App Secret

1. Create an account in the [Symbl Console](https://platform.symbl.ai) if you don't have one already.
2. After you login, you will find your appId and appSecret on the home page.
3. Store your appId and appSecret in the `.env` file in the root level of the application (example below).
4. 5. Open `Agora iOS Tutorial.xcodeproj` and edit the `AppID.swift` file. In there, update `symblAppId` and `symblAppSecret` that you see on Symbl console.
   
```Swift
let SymblAppId: String = "<#Your Symbl App Id#>"
let SymblAppSecret: String = "<#Your Symbl App Secret#>"
```
### Integrate Agora Video SDK 
1. Download the [Agora Video SDK](https://www.agora.io/en/download/). Unzip the downloaded SDK package and copy the following files from the SDK `libs` folder into the sample application `Agora iOS Tutorial Objective-C` folder.
   - `AograRtcEngineKit.framework`
   - `AgoraRtcCryptoLoader.framework`

2. Add [Starscream](https://github.com/daltoniam/Starscream) to your Xcode project as a package dependency.  
  
3. Connect your iPhone or iPad device and run the project. Ensure a valid provisioning profile is applied or your project will not run.

