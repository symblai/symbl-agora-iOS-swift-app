# Symbl Agora iOS Swift Demo App

Symbl.ai is a Conversation Intelligence (CI) platform for developers to build and extend applications capable of understanding natural human conversations at scale. 
Our comprehensive suite of AI/ML products enable developers to easily build and deploy intelligent speech-to-text functionality, extract contextual insights, generate domain-specific insights and intelligence, and access advanced conversation analytics.

By using the Symbl APIs with the Agora iOS Video Call SDK capabilities you benefit from the following out-of-the-box Conversation Intelligence capabilities:

- **Transcription Plus**: Intelligent speech-to-text capabilities, converting speech from a live audio stream and/or video into text and transcripts.

- **Action Items**: Auto detect specific outcomes recognized in a conversation that requires one or more speakers to act on.

- **Follow-ups**: Auto detect follow ups — a type of action Item with connotations to follow up a request or a task (e.g. sending an email or making a phone call or booking an appointment or setting up a meeting).

- **Questions**: Auto detect and identify explicit questions or requests for information that comes up during the conversation.

- **Sentiment Analysis**: Easily conduct sentiment analysis on any conversation, at the sentence and topic levels.

- **Conversation Topics**: Auto extract and organize all your conversations by topics.

- **Custom Trackers**: Track the occurrences of unique and contextually similar keywords or phrases to identify emerging trends and insights specific to your business and use cases.

- **Conversation Analytics**: Analyze and measure speaker interaction and conversation patterns metrics such as: speaker ratio, talk time, silence, pace, overlap and more.

<hr />

This demo application enables you to quickly get started with Symbl while using the Agora Video Call iOS SDK.

With this demo application you will be able to:

- Start a video call between two users
- Join a communication channel
- Mute and unmute audio
- Enable and disable video
- Switch between the front and rear cameras
- Receive and show live transcriptions and insights from Symbl

## Prerequisites

- Xcode 13.x.
- Physical iOS device (iPhone or iPad).
- A valid [Agora account](https://console.agora.io/).
- A valid Agora project with an App Id and a temporary token. See [Get Started with Agora](https://docs.agora.io/en/Agora%20Platform/get_appid_token?platform=All%20Platforms) for details.
- A valid [Symbl account](https://platform.symbl.ai/#/signup).
- A valid Symbl App Id and App Secret. See [Get your API Credentials](https://docs.symbl.ai/docs/developer-tools/authentication/) for details.

The following steps will guide you through the set up, build and running the application instructions.

## Set up
1. Clone the project
```bash
git clone https://github.com/symblai/symbl-agora-iOS-swift-app.git
```

1. Open the project in Xcode.
1. Open the `AppSettings.swift` file and update it with the Agora App Id, temporary token, channel Id (project name), Symbl App Id, Symbl App Secret, user name and email.

1. There are two package dependencies required to be installed:
- AgoraRtcKit (https://github.com/AgoraIO/AgoraRtcEngine_iOS)
- Starscream (https://github.com/daltoniam/Starscream)
  
## Running the Demo Application
1. Connect your iOS device and run the project. Ensure a valid provisioning profile is applied to our project.

## Community

If you have any questions, feel free to reach out to us at devrelations@symbl.ai or thorugh our [Community Slack][slack] or our [developer community][developer_community]

This guide is actively developed, and we love to hear from you! Please feel free to [create an issue][issues] with your questions, comments, suggestions and feedback or [open a pull request][pulls] with your contributions.

This demo application is released under the [MIT License][license]

[license]: LICENSE
[developer_community]: https://community.symbl.ai/?_ga=2.134156042.526040298.1609788827-1505817196.1609788827
[slack]: https://join.slack.com/t/symbldotai/shared_invite/zt-4sic2s11-D3x496pll8UHSJ89cm78CA
[issues]: https://github.com/symblai/symbl-agora-iOS-swift-app/issues
[pulls]: https://github.com/symblai/symbl-agora-iOS-swift-app/pulls

