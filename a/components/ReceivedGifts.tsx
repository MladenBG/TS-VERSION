import React from 'react';
import { View, Text, ScrollView, Image } from 'react-native';

export const ReceivedGifts = ({ receivedGifts }: any) => {
  if (!receivedGifts || receivedGifts.length === 0) {
    return (
      <View className="mt-6 px-5">
        <Text className="text-xl font-black text-gray-900 mb-1">🎁 Your Private Gifts</Text>
        <Text className="text-[13px] text-gray-400 font-bold">You haven't received any gifts yet.</Text>
      </View>
    );
  }

  return (
    <View className="mt-6 px-5">
      <Text className="text-xl font-black text-gray-900 mb-1">🎁 Your Private Gifts</Text>
      <Text className="text-[13px] text-gray-400 font-bold mb-4">Only you can see who sent these.</Text>
      
      <ScrollView horizontal showsHorizontalScrollIndicator={false}>
        {receivedGifts.map((gift: any) => (
          <View 
            key={gift.id} 
            className="bg-white p-4 rounded-3xl mr-3 items-center border border-gray-100 shadow-sm w-[110px]"
          >
            <Text className="text-[36px] mb-3">{gift.gift_name}</Text>
            <Image 
              source={{ uri: gift.sender_image }} 
              className="w-12 h-12 rounded-full mb-2 border-2 border-pink-100" 
            />
            <Text className="text-[11px] font-black text-gray-800 text-center" numberOfLines={1}>
              {gift.sender_name}
            </Text>
          </View>
        ))}
      </ScrollView>
    </View>
  );
};