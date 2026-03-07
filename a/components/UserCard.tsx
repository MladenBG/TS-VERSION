import React from 'react';
import { View, Text, Image, TouchableOpacity, Dimensions } from 'react-native';
import { SafetyMenu } from './SafetyMenu'; // 🚀 IMPORTED HERE

const { width } = Dimensions.get('window');

export const UserCard = ({ item, onSelect, onToggleLike }: any) => {
  return (
    <View 
      className="h-[260px] m-[7px] rounded-[18px] overflow-hidden bg-gray-50 shadow-sm elevation-3"
      style={{ width: (width / 2) - 15 }}
    >
      <TouchableOpacity className="flex-1" onPress={() => onSelect(item)}>
        <Image source={{ uri: item.image }} className="w-full h-full" />
        <View className="absolute bottom-0 left-0 right-0 p-3 bg-black/50">
          <Text className="text-white font-bold text-[16px]">{item.name}, {item.age}</Text>
          <Text className="text-gray-200 text-[11px]">🌍 {item.town} • {item.sexuality}</Text>
        </View>
      </TouchableOpacity>

      {/* 🚀 THE NEW REPORT/BLOCK BUTTON (TOP LEFT) */}
      <View className="absolute top-2.5 left-2.5">
        <SafetyMenu viewedUserId={item.id} />
      </View>

      <TouchableOpacity 
        className="absolute top-2.5 right-2.5 bg-white/90 rounded-[20px] p-1.5" 
        onPress={() => onToggleLike(item.id)}
      >
        <Text className="text-[20px]">{item.isFavorite ? '❤️' : '🤍'}</Text>
      </TouchableOpacity>
    </View>
  );
};