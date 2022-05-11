import UIKit
import AgoraRtcKit
import Starscream

struct User: Decodable {
    let userId: String?
    let name: String?
    let id: String?
}

struct Punctuated: Decodable {
    let transcript: String?
}

struct SymblMessage: Decodable {
    let type: String
    let isFinal: Bool?
    let punctuated: Punctuated?
    let user: User?
}

struct SymblResponse: Decodable {
    let type: String
    let message: SymblMessage?
}

struct AuthResponse: Decodable {
    let accessToken: String!
    let expiresIn: Int!
}

class VideoChatViewController: UIViewController, AgoraAudioDataPluginDelegate, WebSocketDelegate {
    @IBOutlet weak var localContainer: UIView!
    @IBOutlet weak var remoteContainer: UIView!
    @IBOutlet weak var remoteVideoMutedIndicator: UIImageView!
    @IBOutlet weak var localVideoMutedIndicator: UIView!
    @IBOutlet weak var micButton: UIButton!
    @IBOutlet weak var cameraButton: UIButton!
    
    weak var logVC: LogViewController?
    var agoraKit: AgoraRtcEngineKit!
    var agoraMediaDataPlugin: AgoraMediaDataPlugin!
    var localVideo: AgoraRtcVideoCanvas?
    var remoteVideo: AgoraRtcVideoCanvas?
    var socket: WebSocket!
    var isSymblConnected: Bool! = false
    
    var isRemoteVideoRender: Bool = true {
        didSet {
            if let it = localVideo, let view = it.view {
                if view.superview == localContainer {
                    remoteVideoMutedIndicator.isHidden = isRemoteVideoRender
                    remoteContainer.isHidden = !isRemoteVideoRender
                } else if view.superview == remoteContainer {
                    localVideoMutedIndicator.isHidden = isRemoteVideoRender
                }
            }
        }
    }
    
    var isLocalVideoRender: Bool = false {
        didSet {
            if let it = localVideo, let view = it.view {
                if view.superview == localContainer {
                    localVideoMutedIndicator.isHidden = isLocalVideoRender
                } else if view.superview == remoteContainer {
                    remoteVideoMutedIndicator.isHidden = isLocalVideoRender
                }
            }
        }
    }
    
    var isStartCalling: Bool = true {
        didSet {
            if isStartCalling {
                micButton.isSelected = false
            }
            micButton.isHidden = !isStartCalling
            cameraButton.isHidden = !isStartCalling
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // This is our usual steps for joining
        // a channel and starting a call.
        initializeAgoraEngine()
        setupVideo()
        setupLocalVideo()
        joinChannel()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier else {
            return
        }
        if identifier == "EmbedLogViewController",
            let vc = segue.destination as? LogViewController {
            self.logVC = vc
        }
    }
    
    func initializeAgoraEngine() {
        agoraKit = AgoraRtcEngineKit.sharedEngine(withAppId: AppID, delegate: self)
        let audioType:ObserverAudioType = ObserverAudioType(rawValue: ObserverAudioType.recordAudio.rawValue | ObserverAudioType.playbackAudioFrameBeforeMixing.rawValue | ObserverAudioType.mixedAudio.rawValue | ObserverAudioType.playbackAudio.rawValue);
        
        agoraMediaDataPlugin = AgoraMediaDataPlugin(agoraKit: agoraKit)
        agoraMediaDataPlugin.registerAudioRawDataObserver(audioType)
        agoraMediaDataPlugin.audioDelegate = self
    }
    
    func mediaDataPlugin(_ mediaDataPlugin: AgoraMediaDataPlugin, didRecord audioRawData: AgoraAudioRawData) -> AgoraAudioRawData {
        if (isSymblConnected) {
            let data = Data(bytes: audioRawData.buffer, count: Int(audioRawData.bufferSize))
            socket.write(data: data)
        }
      return audioRawData
    }
    
    func setupVideo() {
        // In simple use cases, we only need to enable video capturing
        // and rendering once at the initialization step.
        agoraKit.enableVideo()
        
        // Set video configuration
        agoraKit.setVideoEncoderConfiguration(AgoraVideoEncoderConfiguration(size: AgoraVideoDimension640x360,
            frameRate: .fps15,
            bitrate: AgoraVideoBitrateStandard,
            orientationMode: .adaptative))
    }
    
    func setupLocalVideo() {
        // This is used to set a local preview.
        // The steps setting local and remote view are very similar.
        // But note that if the local user do not have a uid or do
        // not care what the uid is, he can set his uid as ZERO.
        // The Agora server will assign one and return the uid via the block
        // callback (joinSuccessBlock) after joining the channel successfully.
        let view = UIView(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: localContainer.frame.size))
        localVideo = AgoraRtcVideoCanvas()
        localVideo!.view = view
        localVideo!.renderMode = .hidden
        localVideo!.uid = 0
        localContainer.addSubview(localVideo!.view!)
        agoraKit.setupLocalVideo(localVideo)
        agoraKit.startPreview()
    }
    
    func getSymblToken(completionHandler: @escaping (AuthResponse) -> Void) {
            let url = URL(string: "https://api.symbl.ai/oauth2/token:generate")!
            let bodyParameters = [
                "type": "application",
                "appId": SymblAppId,
                "appSecret": SymblAppSecret
            ]
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            
            do {
                request.httpBody = try JSONSerialization.data(withJSONObject: bodyParameters, options: .prettyPrinted)
            } catch let error {
                print(error.localizedDescription)
            }
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Accept")

            let task = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: {
                (data, response, error) in
              if let error = error {
                print("Error while authenticating with Symbl: \(error)")
                return
              }
              
              guard let httpResponse = response as? HTTPURLResponse,
                    (200...299).contains(httpResponse.statusCode) else {
                print("Error with the response, unexpected status code: \(response!)")
                return
              }
                do {
                    //create json object from data
                    let authResponse: AuthResponse = try JSONDecoder().decode(AuthResponse.self, from: data!)
                    completionHandler(authResponse);
                } catch let error {
                    print(error.localizedDescription)
                }
        })
        task.resume()
    }
    
    func joinChannel() {
        print("Joining channel")
        // Set audio route to speaker
        //agoraKit.setDefaultAudioRouteToSpeakerphone(true)
        // Sets the audio data format returned in onRecordAudioFrame
        //agoraKit.setRecordingAudioFrameParametersWithSampleRate(44100, channel: 1, mode: .readWrite, samplesPerCall: 4410)
        // Sets the audio data format returned in onMixedAudioFrame
        //agoraKit.setMixedAudioFrameParametersWithSampleRate(44100, samplesPerCall: 4410)
        // Sets the audio data format returned in onPlaybackAudioFrame
        //agoraKit.setPlaybackAudioFrameParametersWithSampleRate(44100, channel: 1, mode: .readWrite, samplesPerCall: 4410)
        // Users can only see each other after they join the
        // same channel successfully using the same app id.
        // One token is only valid for the channel name that
        // you use to generate this token.
        agoraKit?.joinChannel(byToken: Token,
                              channelId: channelId,
                              info: nil,
                              uid: 0) {
            (_, uid, _) -> Void in
            self.isLocalVideoRender = true
            self.logVC?.log(type: .info, content: "Joined channel")
            
            let randomInt = Int.random(in: 1...9999)
            let connectionId = String(randomInt)
            
            self.logVC?.log(type: .info, content: "Connecting to Symbl")
            self.getSymblToken { (authResponse: AuthResponse) in
               let url = "wss://api.symbl.ai/v1/realtime/insights/\(connectionId)?access_token=\(authResponse.accessToken!)"
                var request = URLRequest(url: URL(string: url)!)
                request.timeoutInterval = 5
                self.socket = WebSocket(request: request)
                self.socket.delegate = self
                self.socket.connect()
            }
        }
        isStartCalling = true
        UIApplication.shared.isIdleTimerDisabled = true
    }
    
    func sendStartRequest() {
        let startRequest: String = "{\"type\":\"start_request\",\"insightTypes\":[\"action_item\"],\"config\":{\"confidenceThreshold\":0.5,\"timezoneOffset\":420,\"languageCode\":\"en-US\",\"speechRecognition\":{\"encoding\":\"LINEAR16\",\"sampleRateHertz\":48000}},\"speaker\":{\"userId\":\"\(userEmail)\",\"name\":\"\(userName)\"}}";
        socket.write(string: startRequest) {
            self.isSymblConnected = true
            print("Connected to Symbl")
        }
    }
    
    func receivedResponse(response: String) {
        let symblResponse: SymblResponse = try! JSONDecoder().decode(SymblResponse.self, from: response.data(using: .utf8)!)
        let message = symblResponse.message
        var transcript = message?.punctuated?.transcript
        if (transcript == nil) {
            transcript = ""
        }
        var user = message?.user?.name
        if (user == nil) {
            user = ""
        }
        var isFinal = message?.isFinal
        if (isFinal == nil) {
            isFinal = false;
        }
        if (user == "" && transcript == "") {
            return;
        }
        let caption = "\(user!): \(transcript!)";
        print(caption)
        if (isFinal!) {
            logVC?.log(type: Log.ContentType.caption, content: caption)
        } else {
            logVC?.update(content: caption)
        }
    }
    
    func didReceive(event: WebSocketEvent, client: WebSocket) {
        switch event {
            case .connected(let headers):
                print("Websocket is connected. Sending start request.")
                sendStartRequest()
            case .disconnected(let reason, let code):
                isSymblConnected = false
                print("Websocket is disconnected: \(reason) with code: \(code)")
            case .text(let string):
                receivedResponse(response: string)
            case .binary(let data):
                print("Received data: \(data.count)")
            case .ping(_):
                break
            case .pong(_):
                break
            case .viabilityChanged(_):
                break
            case .reconnectSuggested(_):
                break
            case .cancelled:
                isSymblConnected = false
            case .error(let error):
                isSymblConnected = false
            self.logVC?.log(type: .error, content: "Error connecting to Symbl: \(String(describing: error))")
        }
    }

    func leaveChannel() {
        // leave channel and end chat
        agoraKit.leaveChannel(nil)
        isRemoteVideoRender = false
        isLocalVideoRender = false
        isStartCalling = false
        UIApplication.shared.isIdleTimerDisabled = false
        self.logVC?.log(type: .info, content: "Left channel")
        socket?.disconnect()
    }
    
    @IBAction func didClickHangUpButton(_ sender: UIButton) {
        sender.isSelected.toggle()
        if sender.isSelected {
            leaveChannel()
            removeFromParent(localVideo)
            localVideo = nil
            removeFromParent(remoteVideo)
            remoteVideo = nil
        } else {
            setupLocalVideo()
            joinChannel()
        }
    }
    
    @IBAction func didClickMuteButton(_ sender: UIButton) {
        sender.isSelected.toggle()
        // mute local audio
        agoraKit.muteLocalAudioStream(sender.isSelected)
    }
    
    @IBAction func didClickSwitchCameraButton(_ sender: UIButton) {
        sender.isSelected.toggle()
        agoraKit.switchCamera()
    }
    
    @IBAction func didClickLocalContainer(_ sender: Any) {
        switchView(localVideo)
        switchView(remoteVideo)
    }
    
    func removeFromParent(_ canvas: AgoraRtcVideoCanvas?) -> UIView? {
        if let it = canvas, let view = it.view {
            let parent = view.superview
            if parent != nil {
                view.removeFromSuperview()
                return parent
            }
        }
        return nil
    }
    
    func switchView(_ canvas: AgoraRtcVideoCanvas?) {
        let parent = removeFromParent(canvas)
        if parent == localContainer {
            canvas!.view!.frame.size = remoteContainer.frame.size
            remoteContainer.addSubview(canvas!.view!)
        } else if parent == remoteContainer {
            canvas!.view!.frame.size = localContainer.frame.size
            localContainer.addSubview(canvas!.view!)
        }
    }
}

extension VideoChatViewController: AgoraRtcEngineDelegate {
    
    /// Callback to handle the event when the first frame of a remote video stream is decoded on the device.
    /// - Parameters:
    ///   - engine: RTC engine instance
    ///   - uid: user id
    ///   - size: the height and width of the video frame
    ///   - elapsed: Time elapsed (ms) from the local user calling JoinChannel method until the SDK triggers this callback.
    func rtcEngine(_ engine: AgoraRtcEngineKit, firstRemoteVideoDecodedOfUid uid:UInt, size:CGSize, elapsed:Int) {
        isRemoteVideoRender = true
        var parent: UIView = remoteContainer
        if let it = localVideo, let view = it.view {
            if view.superview == parent {
                parent = localContainer
            }
        }
        
        // Only one remote video view is available for this
        // tutorial. Here we check if there exists a surface
        // view tagged as this uid.
        if remoteVideo != nil {
            return
        }
        let view = UIView(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: parent.frame.size))
        remoteVideo = AgoraRtcVideoCanvas()
        remoteVideo!.view = view
        remoteVideo!.renderMode = .hidden
        remoteVideo!.uid = uid
        parent.addSubview(remoteVideo!.view!)
        agoraKit.setupRemoteVideo(remoteVideo!)
    }
    
    /// Occurs when a remote user (Communication)/host (Live Broadcast) leaves a channel.
    /// - Parameters:
    ///   - engine: RTC engine instance
    ///   - uid: ID of the user or host who leaves a channel or goes offline.
    ///   - reason: Reason why the user goes offline
    func rtcEngine(_ engine: AgoraRtcEngineKit, didOfflineOfUid uid:UInt, reason:AgoraUserOfflineReason) {
        isRemoteVideoRender = false
        if let it = remoteVideo, it.uid == uid {
            removeFromParent(it)
            remoteVideo = nil
        }
    }
    /// Occurs when a remote user’s video stream playback pauses/resumes.
    /// - Parameters:
    ///   - engine: RTC engine instance
    ///   - muted: YES for paused, NO for resumed.
    ///   - byUid: User ID of the remote user.
    func rtcEngine(_ engine: AgoraRtcEngineKit, didVideoMuted muted:Bool, byUid:UInt) {
        isRemoteVideoRender = !muted
    }
    
    /// Reports a warning during SDK runtime.
    /// - Parameters:
    ///   - engine: RTC engine instance
    ///   - warningCode: Warning code
    func rtcEngine(_ engine: AgoraRtcEngineKit, didOccurWarning warningCode: AgoraWarningCode) {
        logVC?.log(type: .warning, content: "did occur warning, code: \(warningCode.rawValue)")
    }
    
    /// Reports an error during SDK runtime.
    /// - Parameters:
    ///   - engine: RTC engine instance
    ///   - errorCode: Error code
    func rtcEngine(_ engine: AgoraRtcEngineKit, didOccurError errorCode: AgoraErrorCode) {
        logVC?.log(type: .error, content: "Error occurred, code: \(errorCode.rawValue)")
    }
}
