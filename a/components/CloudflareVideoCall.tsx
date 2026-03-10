import React, { useEffect, useRef, useState } from 'react';
import { 
  View, 
  Text, 
  TouchableOpacity, 
  PermissionsAndroid, 
  Platform, 
  ActivityIndicator,
  Alert
} from 'react-native';
import { 
  RTCPeerConnection, 
  RTCSessionDescription, 
  mediaDevices, 
  RTCView,
  MediaStream
} from 'react-native-webrtc';
import { useNavigation, useRoute } from '@react-navigation/native';

// 🚀 YOUR REAL CLOUDFLARE KEYS 🚀
const CLOUDFLARE_APP_ID = "2fe18015-fff1-4368-beea-ac2bd81f0c7d";
const CLOUDFLARE_TOKEN = "ktdukLavACihcR4tnftWimCDDv-hvU5_kGzaeeD9";

export const CloudflareVideoCall = () => {
  const navigation = useNavigation<any>();
  const route = useRoute<any>();
  
  // 🚀 WE NOW EXTRACT isAdmin AND isVip FROM THE ROUTE PARAMETERS 🚀
  const { 
    chatUserName = 'Match', 
    remoteSessionId = null,
    isAdmin = false,
    isVip = false
  } = route.params || {};

  const [localStream, setLocalStream] = useState<MediaStream | null>(null);
  const [remoteStream, setRemoteStream] = useState<MediaStream | null>(null);
  const [isMuted, setIsMuted] = useState(false);
  const [isConnecting, setIsConnecting] = useState(true);

  const pc = useRef<RTCPeerConnection | null>(null);

  useEffect(() => {
    // 🚨 ONLY START THE CAMERA AND CALL IF THEY ARE VIP OR ADMIN 🚨
    if (isAdmin || isVip) {
      startCall();
    }

    return () => {
      if (localStream) {
        localStream.getTracks().forEach(t => t.stop());
      }
      if (pc.current) {
        pc.current.close();
      }
    };
  }, [isAdmin, isVip]);

  const startCall = async () => {
    try {
      if (Platform.OS === 'android') {
        const granted = await PermissionsAndroid.requestMultiple([
          PermissionsAndroid.PERMISSIONS.CAMERA,
          PermissionsAndroid.PERMISSIONS.RECORD_AUDIO,
        ]);
        if (
          granted['android.permission.CAMERA'] !== PermissionsAndroid.RESULTS.GRANTED ||
          granted['android.permission.RECORD_AUDIO'] !== PermissionsAndroid.RESULTS.GRANTED
        ) {
          Alert.alert('Error', 'Camera and Mic permissions are required.');
          navigation.goBack();
          return;
        }
      }

      const stream = await mediaDevices.getUserMedia({
        audio: true,
        video: { width: 1280, height: 720, facingMode: "user" }
      });
      setLocalStream(stream);

      // Cloudflare's dedicated STUN server
      pc.current = new RTCPeerConnection({
        iceServers: [{ urls: "stun:stun.cloudflare.com:3478" }],
        bundlePolicy: "max-bundle"
      });

      stream.getTracks().forEach(track => {
        pc.current?.addTrack(track, stream);
      });

      // Bypassing TypeScript to bind the video stream to the screen
      (pc.current as any).ontrack = (event: any) => {
        if (event.streams && event.streams[0]) {
          setRemoteStream(event.streams[0]);
          setIsConnecting(false);
        }
      };

      await connectToCloudflare();

    } catch (error) {
      console.error("Failed to start WebRTC:", error);
      Alert.alert("Connection Error", "Could not access the camera.");
    }
  };

  const connectToCloudflare = async () => {
    if (!pc.current) return;

    const offer = await pc.current.createOffer({});
    await pc.current.setLocalDescription(offer);

    const response = await fetch(
      `https://rtc.live.cloudflare.com/v1/apps/${CLOUDFLARE_APP_ID}/sessions/new`, 
      {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${CLOUDFLARE_TOKEN}`,
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({
          sessionDescription: {
            type: offer.type,
            sdp: offer.sdp
          }
        })
      }
    );

    const data = await response.json();

    if (data && data.sessionDescription) {
      await pc.current.setRemoteDescription(new RTCSessionDescription(data.sessionDescription));
    }
  };

  const toggleMute = () => {
    if (localStream) {
      localStream.getAudioTracks().forEach(track => {
        track.enabled = !track.enabled;
      });
      setIsMuted(!isMuted);
    }
  };

  const switchCamera = () => {
    if (localStream) {
      // @ts-ignore
      localStream.getVideoTracks().forEach(track => track._switchCamera());
    }
  };

  const hangUp = () => {
    if (localStream) {
      localStream.getTracks().forEach(track => track.stop());
    }
    if (pc.current) {
      pc.current.close();
    }
    navigation.goBack();
  };

  // 🚨 THE PAYWALL LOCK SCREEN 🚨
  if (!isAdmin && !isVip) {
    return (
      <View className="flex-1 justify-center items-center bg-gray-900 px-6">
        <Text className="text-[70px] mb-6">🔒</Text>
        <Text className="text-3xl font-black text-white mb-3 tracking-tight">Premium Feature</Text>
        <Text className="text-center text-gray-400 mb-10 text-base leading-6">
          High-definition video calls are strictly reserved for VIP members. Upgrade your account to instantly connect face-to-face!
        </Text>
        
        <TouchableOpacity 
          className="bg-[#F43F5E] px-8 py-4 rounded-full w-full items-center mb-4 shadow-lg shadow-rose-500/30"
          // Assuming your subscription screen route is named 'Subscription' or you manage paywall state via Context
          onPress={() => {
            navigation.goBack(); 
            // In App.tsx or your global state, you can trigger setShowPaywall(true) after navigating back
          }}
        >
          <Text className="text-white font-black text-lg tracking-widest uppercase">Go Back to Upgrade</Text>
        </TouchableOpacity>

        <TouchableOpacity onPress={() => navigation.goBack()} className="p-4 mt-2">
          <Text className="text-gray-500 font-bold">Cancel</Text>
        </TouchableOpacity>
      </View>
    );
  }

  // 👇 NORMAL VIDEO CALL UI FOR VIPS AND ADMINS 👇
  return (
    <View className="flex-1 bg-black">
      {remoteStream ? (
        <RTCView 
          streamURL={remoteStream.toURL()} 
          style={{ flex: 1 }} 
          objectFit="cover" 
        />
      ) : (
        <View className="flex-1 justify-center items-center bg-gray-900">
          <ActivityIndicator size="large" color="#4CAF50" className="mb-4" />
          <Text className="text-white text-lg font-bold">Waiting for {chatUserName}...</Text>
          <Text className="text-gray-400 text-sm mt-2">Connecting via Cloudflare Edge</Text>
        </View>
      )}

      {localStream && (
        <View className="absolute top-12 right-5 w-[100px] h-[150px] rounded-2xl overflow-hidden border-2 border-green-400 shadow-lg z-10 bg-black">
          <RTCView 
            streamURL={localStream.toURL()} 
            style={{ flex: 1 }} 
            objectFit="cover" 
            mirror={true} 
          />
        </View>
      )}

      <View className="absolute bottom-10 w-full flex-row justify-center items-center px-10 z-20">
        <View className="bg-black/60 rounded-full flex-row items-center p-2 border border-white/20">
          <TouchableOpacity 
            onPress={toggleMute}
            className={`w-14 h-14 rounded-full justify-center items-center mx-2 ${isMuted ? 'bg-red-500' : 'bg-gray-600/80'}`}
          >
            <Text className="text-2xl">{isMuted ? '🔇' : '🎤'}</Text>
          </TouchableOpacity>

          <TouchableOpacity 
            onPress={hangUp}
            className="w-16 h-16 rounded-full bg-red-600 justify-center items-center mx-4 shadow-lg shadow-red-500/50"
          >
            <Text className="text-3xl">☎️</Text>
          </TouchableOpacity>

          <TouchableOpacity 
            onPress={switchCamera}
            className="w-14 h-14 rounded-full bg-gray-600/80 justify-center items-center mx-2"
          >
            <Text className="text-2xl">🔄</Text>
          </TouchableOpacity>
        </View>
      </View>
    </View>
  );
};