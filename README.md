# Symbl Agora iOS Swift App

[![Websocket](https://img.shields.io/badge/symbl-websocket-brightgreen)](https://docs.symbl.ai/docs/streamingapi/overview/introduction)

Symbl's APIs empower developers to enable: 

- **Real-time** analysis of free-flowing discussions to automatically surface highly relevant summary discussion topics, contextual insights, suggestive action items, follow-ups, decisions, and questions.\
- **Voice APIs** that makes it easy to add AI-powered conversational intelligence to either [telephony][telephony] or [WebSocket][websocket] interfaces.
- **Conversation APIs** that provide a REST interface for managing and processing your conversation data.
- **Summary UI** with a fully customizable and editable reference experience that indexes a searchable transcript and shows generated actionable insights, topics, timecodes, and speaker information.

<hr />

## Symbl Agora iOS Swift App

<hr />

This tutorial enables you to quickly get started with adding Symbl.ai to an iOS app to enable real-time video calls, voice calls, or interactive broadcasting using Agora with a WebSocket.  

With your sample app you can:

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

## Community

If you have any questions, feel free to reach out to us at devrelations@symbl.ai or thorugh our [Community Slack][slack] or our [developer community][developer_community]

This guide is actively developed, and we love to hear from you! Please feel free to [create an issue][issues] or [open a pull request][pulls] with your questions, comments, suggestions and feedback.  If you liked our integration guide, please star our repo!

This library is released under the [MIT License][license]

[license]: LICENSE.txt
[telephony]: https://docs.symbl.ai/docs/telephony/overview/post-api
[websocket]: https://docs.symbl.ai/docs/streamingapi/overview/introduction
[developer_community]: https://community.symbl.ai/?_ga=2.134156042.526040298.1609788827-1505817196.1609788827
[slack]: https://join.slack.com/t/symbldotai/shared_invite/zt-4sic2s11-D3x496pll8UHSJ89cm78CA
[signup]: https://platform.symbl.ai/?_ga=2.63499307.526040298.1609788827-1505817196.1609788827
[issues]: https://github.com/symblai/symbl-for-zoom/issues
[pulls]: https://github.com/symblai/symbl-for-zoom/pulls

