import React from 'react';
import { View, TouchableOpacity, Image, Text, TextInput } from 'react-native';

const ICONS = {
  user: 'https://img.icons8.com/ios-glyphs/60/9CA3AF/user--v1.png',
  online: 'https://img.icons8.com/ios-glyphs/60/4CAF50/conference-call.png', // 🚀 NEW: Live Crowd
  newMembers: 'https://img.icons8.com/ios-glyphs/60/374151/user-group-man-man.png',
  bell: 'https://img.icons8.com/ios-glyphs/60/374151/bell.png', 
  mail: 'https://img.icons8.com/ios-glyphs/60/374151/new-post.png',
  logout: 'https://img.icons8.com/ios-glyphs/60/EF4444/exit.png',
  search: 'https://img.icons8.com/ios-glyphs/60/9CA3AF/search--v1.png',
  filter: 'https://img.icons8.com/ios-glyphs/60/374151/horizontal-settings-mixer--v1.png'
};

export const HeaderSwipe = ({ 
  logoImg, 
  myImage, 
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
  handleLogout,
  unreadNotifsCount, 
  onOpenNotifications, 
  onOpenNewMembers,
  onlineCount, 
  onOpenOnlineMembers 
}: any) => {
  return (
    <View className="p-4 border-b border-gray-200 bg-white pt-12">
      <View className="flex-row justify-between items-center mb-3">
        
        {/* LEFT SIDE: PROFILE PIC */}
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
            <View className="w-12 h-12 rounded-full bg-gray-200 border-2 border-gray-300 items-center justify-center shadow-sm overflow-hidden">
              <Image source={{ uri: ICONS.user }} style={{ width: 28, height: 28 }} resizeMode="contain" />
            </View>
          )}
          {isVip && (
            <View className="absolute -bottom-1 -right-1 bg-yellow-400 rounded-full w-5 h-5 items-center justify-center border-2 border-white">
              <Text className="text-[8px]">💎</Text>
            </View>
          )}
        </TouchableOpacity>

        {/* CENTER: LOGO */}
        <TouchableOpacity 
          onPress={() => {setTab('discover'); setDiscoveryMode('list');}} 
          style={{ flex: 1, alignItems: 'center' }} 
        >
          <Image source={logoImg} className="w-[100px] h-[50px]" resizeMode="contain" />
        </TouchableOpacity>
        
        {/* RIGHT SIDE: ACTIONS */}
        <View className="flex-row items-center">
          
          {/* 🚀 ONLINE USERS BUTTON (CHANGED mr-1 to mr-3 for spacing) 🚀 */}
          <TouchableOpacity 
            className="w-10 h-10 mr-2 relative left-[-17] justify-center items-center"
            onPress={onOpenOnlineMembers} 
            activeOpacity={0.7}
          >
            <Image source={{ uri: ICONS.online }} style={{ width: 28, height: 28 }} resizeMode="contain" />
            <View className="absolute top-0 right-0 bg-[#4CAF50] rounded-full px-1 border-2 border-white z-10">
              <Text className="text-white text-[8px] font-black">{onlineCount}</Text>
            </View>
          </TouchableOpacity>

          {/* 🚀 NEW MEMBERS BUTTON (CHANGED mr-1 to mr-3 for spacing) 🚀 */}
          <TouchableOpacity 
            className="w-10 h-10 mr-3 relative left-[-6] justify-center items-center"
            onPress={onOpenNewMembers} 
            activeOpacity={0.7}
          >
            <Image source={{ uri: ICONS.newMembers }} style={{ width: 28, height: 28 }} resizeMode="contain" />
            <View className="absolute top-0 right-0 bg-green-500 rounded-full px-1 border-2 border-white z-10">
              <Text className="text-white text-[8px] font-black">NEW</Text>
            </View>
          </TouchableOpacity>

          {/* 🚀 NOTIFICATION BELL ICON (CHANGED mr-1 to mr-3 for spacing) 🚀 */}
          <TouchableOpacity 
            className="w-10 h-10 mr-3 left-[-4] relative justify-center items-center"
            onPress={onOpenNotifications} 
            activeOpacity={0.7}
          >
            <Image source={{ uri: ICONS.bell }} style={{ width: 26, height: 26 }} resizeMode="contain" />
            {unreadNotifsCount > 0 && (
              <View className="absolute top-0 right-0 bg-red-500 rounded-full w-5 h-5 justify-center items-center border-2 border-white z-10">
                <Text className="text-white text-[10px] font-black">
                  {unreadNotifsCount > 9 ? '9+' : unreadNotifsCount}
                </Text>
              </View>
            )}
          </TouchableOpacity>

          {/* 🚀 INBOX BUTTON (CHANGED mr-1 to mr-3 for spacing) 🚀 */}
          <TouchableOpacity 
            className="w-10 h-10 mr-3 relative left-[-4] justify-center items-center"
            onPress={() => setTab('inbox')}
            activeOpacity={0.7}
          >
            <Image source={{ uri: ICONS.mail }} style={{ width: 26, height: 26 }} resizeMode="contain" />
            {unreadCount > 0 && (
              <View className="absolute top-0 right-0 bg-red-500 rounded-full w-5 h-5 justify-center items-center border-2 border-white">
                <Text className="text-white text-[8px] font-black">
                  {unreadCount > 9 ? '9+' : unreadCount}
                </Text>
              </View>
            )}
          </TouchableOpacity>

          {/* LOGOUT ICON (No margin needed here since it's the last icon on the right) */}
          <TouchableOpacity 
            className="w-10 h-10 justify-center items-center"
            onPress={handleLogout}
            activeOpacity={0.7}
          >
            <Image source={{ uri: ICONS.logout }} style={{ width: 24, height: 24 }} resizeMode="contain" />
          </TouchableOpacity>
        </View>
      </View>

      {/* DISCOVERY SEARCH AND MODES */}
      {tab === 'discover' && (
        <>
          <View className="flex-row items-center">
            <View className="flex-1 h-[45px] bg-gray-50 border border-gray-200 rounded-xl px-4 flex-row items-center shadow-sm">
              <Image source={{ uri: ICONS.search }} style={{ width: 20, height: 20 }} resizeMode="contain" />
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
              <Image source={{ uri: ICONS.filter }} style={{ width: 24, height: 24 }} resizeMode="contain" />
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