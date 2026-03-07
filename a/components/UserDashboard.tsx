import React, { useState } from 'react';
import { View, Text, TouchableOpacity, ScrollView, Image, ActivityIndicator, Alert } from 'react-native';
import * as ImagePicker from 'expo-image-picker';
import * as ImageManipulator from 'expo-image-manipulator';
import { Friends } from './Friends';
import { ImageGallery } from './ImageGallery';
import { GiftsReceived } from './GiftsReceived';

interface UserDashboardProps {
  myName: string;
  myCity: string;
  isVip: boolean;
  setShowPaywall: (show: boolean) => void;
  openEditProfile: () => void;
  receivedGifts: any[];
}

export const UserDashboard = ({ 
  myName, 
  myCity, 
  isVip, 
  setShowPaywall, 
  openEditProfile, 
  receivedGifts 
}: UserDashboardProps) => {

  // 🚀 NEW: State for your main profile picture
  const [profilePic, setProfilePic] = useState<string | null>(null);
  const [isUploadingPic, setIsUploadingPic] = useState(false);

  // STARTING BLANK: So you can upload your actual photos!
  const myImages: string[] = [];

  // DUMMY DATA FOR UI
  const myFriends = [
    { id: '1', name: 'Luka', town: 'Belgrade', image: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=200&q=80' },
    { id: '2', name: 'Elena', town: 'Novi Sad', image: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=200&q=80' }
  ];

  const defaultGifts = [
    { id: 'g1', senderName: 'Elena', giftName: 'Rose', icon: '🌹', date: 'Today, 10:45 AM' }
  ];

  const displayGifts = receivedGifts.length > 0 ? receivedGifts : defaultGifts;

  // 🚀 NEW: The Cloudflare Upload Logic for the Main Avatar
  const handleUploadProfilePic = async () => {
    const permissionResult = await ImagePicker.requestMediaLibraryPermissionsAsync();
    
    if (permissionResult.granted === false) {
      Alert.alert("Permission Required", "Allow access to photos to change your profile picture.");
      return;
    }

    const result = await ImagePicker.launchImageLibraryAsync({
      mediaTypes: ImagePicker.MediaTypeOptions.Images,
      allowsEditing: true,
      aspect: [1, 1], // Perfect square crop for the circle avatar
      quality: 1,
    });

    if (!result.canceled && result.assets && result.assets.length > 0) {
      setIsUploadingPic(true);
      try {
        // Squash to WebP
        const manipResult = await ImageManipulator.manipulateAsync(
          result.assets[0].uri,
          [{ resize: { width: 500 } }], // Smaller size for avatars
          { compress: 0.7, format: ImageManipulator.SaveFormat.WEBP }
        );

        // Get Cloudflare Ticket (Change 10.0.2.2 to your Wi-Fi IP if on real phone!)
        const response = await fetch('http://10.0.2.2:3000/api/get-upload-url');
        const { uploadUrl, publicUrl } = await response.json();

        // Upload to Cloudflare R2
        const imageResponse = await fetch(manipResult.uri);
        const blob = await imageResponse.blob();
        
        const uploadRes = await fetch(uploadUrl, {
          method: 'PUT',
          body: blob,
          headers: { 'Content-Type': 'image/webp' },
        });

        if (uploadRes.ok) {
          setProfilePic(publicUrl); // Update the UI instantly
          Alert.alert("Looking Good!", "Profile picture updated.");
        } else {
          throw new Error("Cloudflare rejected the upload");
        }
      } catch (error) {
        console.error("Profile Pic Upload Error:", error);
        Alert.alert("Upload Failed", "Could not update profile picture.");
      } finally {
        setIsUploadingPic(false);
      }
    }
  };

  return (
    <View className="flex-1 bg-gray-50">
      
      {/* 🟢 HEADER: Profile Info & Edit Button */}
      <View className="bg-white px-6 pt-10 pb-6 rounded-b-3xl shadow-sm border-b border-gray-100 mb-4 z-10">
        <View className="flex-row justify-between items-center">
          <View className="flex-row items-center">
            
            {/* 🚀 THE CLICKABLE AVATAR 🚀 */}
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
              
              {/* Little edit badge */}
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

      {/* 🟢 BODY */}
      <ScrollView className="flex-1 px-4" showsVerticalScrollIndicator={false} contentContainerStyle={{ paddingBottom: 40 }}>
        <ImageGallery initialImages={myImages} />
        <Friends friendsList={myFriends} />
        <GiftsReceived gifts={displayGifts} />
      </ScrollView>

    </View>
  );
};