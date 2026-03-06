import React from 'react';
import { View, TouchableOpacity, Image, Text, TextInput } from 'react-native';
import { Feather } from '@expo/vector-icons';

export const HeaderSwipe = ({ 
  logoImg, isVip, setShowPaywall, tab, searchQuery, setSearchQuery, 
  setShowFilters, setTab, setDiscoveryMode, discoveryMode, setCurrentPage, unreadCount, handleLogout 
}: any) => {
  return (
    <View className="p-4 border-b border-gray-200 bg-white">
      <View className="flex-row justify-between items-center mb-3">
        <TouchableOpacity onPress={() => {setTab('discover'); setDiscoveryMode('list');}}>
          <Image source={logoImg} className="w-[140px] h-[60px]" resizeMode="contain" />
        </TouchableOpacity>
        
        <View className="flex-row items-center">
          
          {/* MODERN UI LOGOUT BUTTON */}
          <TouchableOpacity 
            className="flex-row items-center px-3 py-2.5 bg-gray-50 rounded-full mr-2 border border-gray-200 shadow-sm"
            onPress={handleLogout}
            activeOpacity={0.7}
          >
            <Feather name="power" size={14} color="#6B7280" />
            <Text className="text-gray-600 text-[10px] font-black uppercase tracking-wider ml-1.5">
              Logout
            </Text>
          </TouchableOpacity>

          {/* PROFESSIONAL INBOX BUTTON */}
          <TouchableOpacity 
            className="w-[40px] h-[40px] bg-gray-50 rounded-full justify-center items-center mr-3 relative border border-gray-200 shadow-sm"
            onPress={() => setTab('inbox')}
            activeOpacity={0.7}
          >
            <Feather name="mail" size={18} color="#374151" />
            {unreadCount > 0 && (
              <View className="absolute -top-1 -right-1 bg-red-500 rounded-full w-[20px] h-[20px] justify-center items-center border-2 border-white">
                <Text className="text-white text-[10px] font-black">
                  {unreadCount > 9 ? '9+' : unreadCount}
                </Text>
              </View>
            )}
          </TouchableOpacity>

          {/* VIP / GO PRO BUTTON */}
          <TouchableOpacity 
            className={`py-2.5 px-4 rounded-full shadow-sm ${isVip ? 'bg-yellow-400' : 'bg-green-500'}`} 
            onPress={() => setShowPaywall(true)}
            activeOpacity={0.8}
          >
            <Text className="text-white text-[11px] font-black tracking-wide">
              {isVip ? "💎 VIP" : "⚡ PRO"}
            </Text>
          </TouchableOpacity>
        </View>
      </View>

      {tab === 'discover' && (
        <>
          <View className="flex-row items-center">
            <View className="flex-1 h-[45px] bg-gray-50 border border-gray-200 rounded-xl px-4 flex-row items-center shadow-sm">
              <Feather name="search" size={18} color="#9CA3AF" />
              <TextInput 
                className="flex-1 ml-2 text-black font-bold h-full" 
                placeholder="Search Town, Name or Sexuality..." 
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