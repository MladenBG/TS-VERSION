import React, { useState, useEffect } from 'react';
import { View, Text, TouchableOpacity, ScrollView, Image, ActivityIndicator, Alert } from 'react-native';
import * as ImagePicker from 'expo-image-picker';
import * as ImageManipulator from 'expo-image-manipulator';
import { Friends } from './Friends';
import { ImageGallery } from './ImageGallery';
import { GiftsReceived } from './GiftsReceived';
import { FriendRequests } from './FriendRequests'; 

const API_URL = "http://10.0.2.2:3001"; 

interface UserDashboardProps {
  myId: string;
  myImage: string;
  setMyImage: (url: string) => void;
  myGalleryImages: string[];           
  setMyGalleryImages: React.Dispatch<React.SetStateAction<string[]>>; 
  myName: string;
  myCity: string;
  isVip: boolean;
  isAdmin: boolean;
  setShowPaywall: (show: boolean) => void;
  openEditProfile: () => void;
  receivedGifts: any[];
  onViewPublicProfile: () => void; // 🚀 ADDED TO VIEW OWN PUBLIC PROFILE
  onSelectUser: (user: any) => void; // 🚀 ADDED FOR FRIEND CLICKS
}

export const UserDashboard = ({ 
  myId,
  myImage,
  setMyImage,
  myName, 
  myCity, 
  isVip, 
  isAdmin, 
  setShowPaywall, 
  openEditProfile, 
  receivedGifts,
  onViewPublicProfile,
  onSelectUser
}: UserDashboardProps) => {

  const [profilePic, setProfilePic] = useState<string | null>(myImage || null);
  const [isUploadingPic, setIsUploadingPic] = useState(false);

  useEffect(() => {
    if (myImage) setProfilePic(myImage);
  }, [myImage]);

  const [myFriends, setMyFriends] = useState<any[]>([]);
  const [receivedRequests, setReceivedRequests] = useState<any[]>([]);
  const [sentRequests, setSentRequests] = useState<any[]>([]);

  const handleRemoveFriend = (friendId: string) => {
    setMyFriends(prevFriends => prevFriends.filter(f => f.id !== friendId));
  };
  const handleAcceptRequest = (id: string) => setReceivedRequests(prev => prev.filter(req => req.id !== id));
  const handleDeclineRequest = (id: string) => setReceivedRequests(prev => prev.filter(req => req.id !== id));
  const handleCancelRequest = (id: string) => setSentRequests(prev => prev.filter(req => req.id !== id));

  const displayGifts = receivedGifts.length > 0 ? receivedGifts : [];

  const handleUploadProfilePic = async () => {
    const permissionResult = await ImagePicker.requestMediaLibraryPermissionsAsync();
    
    if (permissionResult.granted === false) {
      Alert.alert("Permission Required", "Allow access to photos to change your profile picture.");
      return;
    }

    const result = await ImagePicker.launchImageLibraryAsync({
      mediaTypes: ['images'],
      allowsEditing: true,
      aspect: [1, 1], 
      quality: 1,
    });

    if (!result.canceled && result.assets && result.assets.length > 0) {
      setIsUploadingPic(true);
      try {
        const manipResult = await ImageManipulator.manipulateAsync(
          result.assets[0].uri,
          [{ resize: { width: 500 } }], 
          { compress: 0.7, format: ImageManipulator.SaveFormat.WEBP } 
        );

        const response = await fetch(`${API_URL}/api/get-upload-url`);
        
        if (!response.ok) {
          throw new Error(`Backend failed with status: ${response.status}`);
        }

        const data = await response.json();
        const uploadUrl = data.uploadUrl;
        const publicUrl = data.publicUrl;
        
        if (!uploadUrl) throw new Error("Backend did not return an uploadUrl");

        const imageResponse = await fetch(manipResult.uri);
        const blob = await imageResponse.blob();
        
        const uploadRes = await fetch(uploadUrl, {
          method: 'PUT',
          body: blob,
          headers: { 
            'Content-Type': 'image/webp' 
          },
        });

        if (uploadRes.ok) {
          setProfilePic(publicUrl); 
          if (setMyImage) setMyImage(publicUrl); 

          await fetch(`${API_URL}/api/users/update-image`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ userId: myId, imageUrl: publicUrl })
          });

          Alert.alert("Looking Good!", "Profile picture saved to database.");
        } else {
          Alert.alert("Upload Rejected", "Cloudflare blocked the file.");
        }
      } catch (error: any) {
        Alert.alert("Upload Failed", error.message || "Could not connect to server.");
      } finally {
        setIsUploadingPic(false);
      }
    }
  };

  return (
    <View className="flex-1 bg-gray-50">
      
      <View className="bg-white px-6 pt-10 pb-6 rounded-b-3xl shadow-sm border-b border-gray-100 mb-4 z-10">
        <View className="flex-row justify-between items-center">
          <View className="flex-row items-center">
            <TouchableOpacity 
              onPress={handleUploadProfilePic}
              disabled={isUploadingPic}
              className="w-20 h-20 bg-gray-200 rounded-full border-4 border-white shadow-md overflow-hidden mr-4 items-center justify-center relative"
            >
              {isUploadingPic ? (
                <ActivityIndicator color="#4CAF50" />
              ) : profilePic ? (
                <Image source={{ uri: profilePic }} className="w-full h-full" />
              ) : (
                <Text className="text-3xl text-gray-400">👤</Text>
              )}
              {!isUploadingPic && (
                <View className="absolute bottom-0 right-0 bg-black/50 w-full py-0.5 items-center">
                  <Text className="text-white text-[8px] font-bold tracking-widest uppercase">Edit</Text>
                </View>
              )}
            </TouchableOpacity>

            <View>
              <View className="flex-row items-center">
                <Text className="text-2xl font-black text-gray-800 tracking-tight">{myName}</Text>
                {isVip && (
                  <View className="bg-green-500 ml-2 px-2 py-0.5 rounded-full shadow-sm">
                    <Text className="text-white text-[10px] font-black uppercase tracking-wider">VIP</Text>
                  </View>
                )}
              </View>
              <Text className="text-gray-500 font-bold mt-1 text-sm">📍 {myCity}</Text>
            </View>
          </View>
        </View>

        <TouchableOpacity 
          onPress={openEditProfile}
          className="mt-6 bg-gray-100 border border-gray-200 py-3 rounded-xl items-center flex-row justify-center"
        >
          <Text className="text-lg mr-2">✏️</Text>
          <Text className="font-bold text-gray-700">Edit Profile Details</Text>
        </TouchableOpacity>

        {/* 🚀 NEW: VIEW PUBLIC PROFILE BUTTON */}
        <TouchableOpacity 
          onPress={onViewPublicProfile}
          className="mt-3 bg-blue-50 border border-blue-200 py-3 rounded-xl items-center flex-row justify-center"
        >
          <Text className="text-lg mr-2">👁️</Text>
          <Text className="font-bold text-blue-700">View Public Profile</Text>
        </TouchableOpacity>

        {!isVip && (
          <TouchableOpacity 
            onPress={() => setShowPaywall(true)}
            className="mt-3 bg-green-50 border border-green-200 py-3 rounded-xl items-center flex-row justify-center"
          >
            <Text className="text-lg mr-2">👑</Text>
            <Text className="font-bold text-green-700">Upgrade to VIP Status</Text>
          </TouchableOpacity>
        )}
      </View>

      <ScrollView className="flex-1 px-4" showsVerticalScrollIndicator={false} contentContainerStyle={{ paddingBottom: 40 }}>
        
        <ImageGallery initialImages={[]} isPublicView={false} userId={myId} />
        
        <FriendRequests 
          receivedRequests={receivedRequests}
          sentRequests={sentRequests}
          onAcceptRequest={handleAcceptRequest}
          onDeclineRequest={handleDeclineRequest}
          onCancelRequest={handleCancelRequest}
          isAdmin={isAdmin}
          isVip={isVip}
          setShowPaywall={setShowPaywall}
        />

        <Friends 
          friendsList={myFriends} 
          isEditable={true} 
          onRemoveFriend={handleRemoveFriend} 
          onSelectFriend={onSelectUser} // 🚀 PASSED CLICK LOGIC
          isAdmin={isAdmin}
          isVip={isVip}
          setShowPaywall={setShowPaywall}
        />
        
        <GiftsReceived 
          gifts={displayGifts} 
          isAdmin={isAdmin}
          isVip={isVip}
          isPublicView={false} // 🚀 USER SEES NAMES OF SENDER
          setShowPaywall={setShowPaywall}
        />
      </ScrollView>
    </View>
  );
};