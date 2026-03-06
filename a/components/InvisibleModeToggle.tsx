import React from 'react';
import { View, Text, Switch, TouchableOpacity, Alert } from 'react-native';

export const InvisibleModeToggle = ({ isPrivate, toggleInvisibleMode, isVip, isAdmin, setShowPaywall }: any) => {
  
  const handleToggle = () => {
    // 🚀 HARD PAYWALL CHECK 🚀
    if (!isVip && !isAdmin) {
      Alert.alert("Premium Feature", "Invisible Mode is a VIP exclusive! Hide your profile from the public feed while you browse.");
      setShowPaywall(true);
      return;
    }
    toggleInvisibleMode(!isPrivate);
  };

  return (
    <TouchableOpacity 
      activeOpacity={0.9} 
      onPress={handleToggle}
      className="bg-white p-5 rounded-2xl border-2 border-gray-100 shadow-sm mt-4 flex-row justify-between items-center"
    >
      <View className="flex-row items-center">
        <Text className="text-[28px] mr-4">👻</Text>
        <View>
          <Text className="text-lg font-black text-gray-900 tracking-tight">Invisible Mode</Text>
          <Text className="text-[12px] text-gray-500 font-bold mt-1">Hide profile from Discovery feed</Text>
        </View>
      </View>
      
      {/* Visual lock for free users, functional switch for VIPs */}
      {!isVip && !isAdmin ? (
        <Text className="text-xl">🔒</Text>
      ) : (
        <Switch 
          trackColor={{ false: "#E5E7EB", true: "#4CAF50" }}
          thumbColor={"#ffffff"}
          onValueChange={handleToggle}
          value={isPrivate}
          style={{ transform: [{ scaleX: 1.1 }, { scaleY: 1.1 }] }}
        />
      )}
    </TouchableOpacity>
  );
};