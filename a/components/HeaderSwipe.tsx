import React from 'react';
import { View, TouchableOpacity, Image, Text, TextInput } from 'react-native';
import { Feather } from '@expo/vector-icons';

export const HeaderSwipe = ({ 
  logoImg, 
  myImage, // 🚀 YOUR REAL PICTURE PROP
  isVip, 
  setShowPaywall, 
  tab, 
  searchQuery, 
  setSearchQuery, 
  setShowFilters, 
  setTab, 
  setDiscoveryMode, 
  discoveryMode, 
  setCurrentPage, 
  unreadCount, 
  handleLogout 
}: any) => {
  return (
    <View className="p-4 border-b border-gray-200 bg-white pt-12">
      <View className="flex-row justify-between items-center mb-3">
        
        {/* 🚀 LEFT SIDE: YOUR PROFILE PICTURE 🚀 */}
        <TouchableOpacity 
          onPress={() => setTab('settings')}
          className="relative"
          activeOpacity={0.7}
        >
          {myImage ? (
            <Image 
              source={{ uri: myImage }} 
              className="w-12 h-12 rounded-full border-2 border-green-500 shadow-sm" 
            />
          ) : (
            <View className="w-12 h-12 rounded-full bg-gray-200 border-2 border-gray-300 items-center justify-center shadow-sm">
              <Feather name="user" size={20} color="#9CA3AF" />
            </View>
          )}
          {isVip && (
            <View className="absolute -bottom-1 -right-1 bg-yellow-400 rounded-full w-5 h-5 items-center justify-center border-2 border-white">
              <Text className="text-[8px]">💎</Text>
            </View>
          )}
        </TouchableOpacity>

        {/* CENTER: LOGO */}
        <TouchableOpacity onPress={() => {setTab('discover'); setDiscoveryMode('list');}}>
          <Image source={logoImg} className="w-[120px] h-[40px]" resizeMode="contain" />
        </TouchableOpacity>
        
        {/* RIGHT SIDE: ACTIONS */}
        <View className="flex-row items-center">
          
          {/* INBOX BUTTON */}
          <TouchableOpacity 
            className="w-10 h-10 bg-gray-50 rounded-full justify-center items-center mr-2 relative border border-gray-200 shadow-sm"
            onPress={() => setTab('inbox')}
            activeOpacity={0.7}
          >
            <Feather name="mail" size={18} color="#374151" />
            {unreadCount > 0 && (
              <View className="absolute -top-1 -right-1 bg-red-500 rounded-full w-5 h-5 justify-center items-center border-2 border-white">
                <Text className="text-white text-[8px] font-black">
                  {unreadCount > 9 ? '9+' : unreadCount}
                </Text>
              </View>
            )}
          </TouchableOpacity>

          {/* LOGOUT ICON */}
          <TouchableOpacity 
            className="w-10 h-10 bg-red-50 rounded-full justify-center items-center border border-red-100 shadow-sm"
            onPress={handleLogout}
            activeOpacity={0.7}
          >
            <Feather name="power" size={16} color="#EF4444" />
          </TouchableOpacity>
        </View>
      </View>

      {/* DISCOVERY SEARCH AND MODES */}
      {tab === 'discover' && (
        <>
          <View className="flex-row items-center">
            <View className="flex-1 h-[45px] bg-gray-50 border border-gray-200 rounded-xl px-4 flex-row items-center shadow-sm">
              <Feather name="search" size={18} color="#9CA3AF" />
              <TextInput 
                className="flex-1 ml-2 text-black font-bold h-full" 
                placeholder="Search Town, Name..." 
                placeholderTextColor="#9CA3AF"
                value={searchQuery}
                onChangeText={(t) => { setSearchQuery(t); setCurrentPage(1); }}
                autoCorrect={false}
              />
            </View>
            <TouchableOpacity 
              className="ml-2.5 w-[45px] h-[45px] bg-gray-50 border border-gray-200 rounded-xl justify-center items-center shadow-sm" 
              onPress={() => setShowFilters(true)}
              activeOpacity={0.7}
            >
              <Feather name="sliders" size={20} color="#374151" />
            </TouchableOpacity>
          </View>

          <View className="flex-row mt-4 bg-gray-100 rounded-lg p-1 border border-gray-200">
            {['list', 'swipe', 'radar'].map((m: any) => (
              <TouchableOpacity 
                key={m}
                className={`flex-1 py-2 items-center rounded-md ${discoveryMode === m ? 'bg-white shadow-sm elevation-2' : ''}`} 
                onPress={() => (m === 'list' || isVip) ? setDiscoveryMode(m) : setShowPaywall(true)}
              >
                <Text className={`text-[10px] font-black tracking-wide ${discoveryMode === m ? 'text-green-500' : 'text-gray-400'}`}>
                  {m.toUpperCase()}
                </Text>
              </TouchableOpacity>
            ))}
          </View>
        </>
      )}
    </View>
  );
};