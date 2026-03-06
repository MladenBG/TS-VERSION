import React from 'react';
import { View, Text, Image, TouchableOpacity, ScrollView } from 'react-native';
import { ReceivedGifts } from './ReceivedGifts'; 

export const UserDashboard = ({ myName, myCity, isVip, setShowPaywall, openEditProfile, receivedGifts }: any) => {
  return (
    <View className="flex-1 bg-gray-50">
      <ScrollView contentContainerStyle={{ paddingBottom: 40 }}>
        
        {/* HEADER SECTION */}
        <View className="bg-white rounded-b-[40px] pt-10 pb-8 items-center shadow-sm elevation-3 border-b border-gray-200">
          <View className="relative">
            <Image source={{uri: 'https://picsum.photos/200'}} className="w-[140px] h-[140px] rounded-full border-4 border-white shadow-lg bg-gray-200" />
            <TouchableOpacity className="absolute bottom-2 right-2 bg-green-500 w-[40px] h-[40px] rounded-full justify-center items-center border-4 border-white shadow-sm" onPress={openEditProfile}>
              <Text className="text-white text-[18px]">✏️</Text>
            </TouchableOpacity>
          </View>
          <Text className="text-[28px] font-black text-gray-900 mt-4">{myName}, 24</Text>
          <Text className="text-[14px] font-bold text-gray-400 mt-1">📍 {myCity}</Text>
        </View>

        {/* STATS SECTION */}
        <View className="flex-row px-5 mt-6 justify-between">
          <View className="flex-1 bg-white p-4 rounded-2xl mr-2 border border-gray-200 shadow-sm elevation-1 items-center">
            <Text className="text-[24px] font-black text-gray-900">42</Text>
            <Text className="text-[10px] font-bold text-gray-400 uppercase mt-1">Profile Views</Text>
          </View>
          <View className="flex-1 bg-white p-4 rounded-2xl mx-1 border border-gray-200 shadow-sm elevation-1 items-center">
            <Text className="text-[24px] font-black text-gray-900">18</Text>
            <Text className="text-[10px] font-bold text-gray-400 uppercase mt-1">Likes Received</Text>
          </View>
          <View className="flex-1 bg-white p-4 rounded-2xl ml-2 border border-gray-200 shadow-sm elevation-1 items-center">
            <Text className="text-[24px] font-black text-green-500">5</Text>
            <Text className="text-[10px] font-bold text-gray-400 uppercase mt-1">Matches</Text>
          </View>
        </View>

        {/* PRIVATE RECEIVED GIFTS TRAY */}
        <ReceivedGifts receivedGifts={receivedGifts} />

        {/* VIP BANNER SECTION */}
        <View className="px-5 mt-6">
          <TouchableOpacity className={`w-full p-6 rounded-3xl items-center shadow-md elevation-2 ${isVip ? 'bg-black' : 'bg-gradient-to-r from-green-400 to-green-600 bg-green-500'}`} onPress={() => setShowPaywall(true)}>
            <Text className="text-white text-[22px] font-black tracking-tight mb-1">{isVip ? '💎 VIP Active' : 'Get DateRoot PRO'}</Text>
            <Text className="text-white/80 text-[12px] font-bold text-center">{isVip ? 'Manage your premium subscription features.' : 'Unlock Radar, see who liked you, and more!'}</Text>
          </TouchableOpacity>
        </View>

        {/* SETTINGS MENU SECTION */}
        <View className="px-5 mt-6">
          <Text className="text-[14px] font-bold text-gray-800 uppercase tracking-wider mb-2 ml-2">Account Settings</Text>
          <View className="bg-white rounded-3xl border border-gray-200 shadow-sm overflow-hidden">
            
            <TouchableOpacity className="flex-row items-center justify-between p-5 border-b border-gray-100" onPress={openEditProfile}>
              <View className="flex-row items-center">
                <Text className="text-[20px] mr-4">👤</Text>
                <Text className="text-[16px] font-bold text-gray-900">Edit Profile Info</Text>
              </View>
              <Text className="text-gray-400 font-bold">›</Text>
            </TouchableOpacity>
            
            {/* 🚀 DELETED THE REDUNDANT "PRIVACY & SAFETY" BUTTON HERE 🚀 */}
            
            <TouchableOpacity className="flex-row items-center justify-between p-5">
              <View className="flex-row items-center">
                <Text className="text-[20px] mr-4">⚙️</Text>
                <Text className="text-[16px] font-bold text-gray-900">App Preferences</Text>
              </View>
              <Text className="text-gray-400 font-bold">›</Text>
            </TouchableOpacity>

          </View>
        </View>
        
      </ScrollView>
    </View>
  );
};