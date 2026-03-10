import React, { useState } from 'react';
import { View, Text, FlatList, TouchableOpacity } from 'react-native';

interface Gift {
  id: string;
  senderName: string;
  giftName: string;
  icon: string; // e.g., "🌹", "💎", "🐻"
  date: string;
}

interface GiftsReceivedProps {
  gifts: Gift[];
  isAdmin?: boolean;       // 🚀 ADDED: To check roles
  isVip?: boolean;         // 🚀 ADDED: To check roles
  setShowPaywall?: (show: boolean) => void; // 🚀 ADDED: To open subscription screen
}

export const GiftsReceived = ({ 
  gifts, 
  isAdmin, 
  isVip, 
  setShowPaywall 
}: GiftsReceivedProps) => {
  const [currentPage, setCurrentPage] = useState(1);
  const ITEMS_PER_PAGE = 3; // Keep the list short and clean
  
  // 🚨 THE VIP PAYWALL LOCK 🚨
  // If they are not Admin and not VIP, hide the gifts and show the lock screen!
  if (!isAdmin && !isVip) {
    return (
      <View className="bg-white rounded-2xl shadow-sm border border-gray-100 p-6 mb-4 items-center justify-center">
        <Text className="text-[50px] mb-3">🎁</Text>
        <Text className="text-xl font-black text-gray-900 mb-2 text-center">Hidden Gifts</Text>
        <Text className="text-sm text-gray-500 text-center mb-5 leading-5">
          Other users might be sending you private gifts! Upgrade to VIP to reveal who sent them and view your collection.
        </Text>
        <TouchableOpacity 
          onPress={() => setShowPaywall && setShowPaywall(true)}
          className="bg-[#F43F5E] py-3 px-8 rounded-[30px] shadow-sm"
        >
          <Text className="text-white font-black tracking-widest uppercase">Unlock VIP</Text>
        </TouchableOpacity>
      </View>
    );
  }

  // 👇 IF THEY ARE ADMIN OR VIP, SHOW THE NORMAL GIFTS LIST 👇

  const totalPages = Math.ceil(gifts.length / ITEMS_PER_PAGE) || 1;
  const currentGifts = gifts.slice(
    (currentPage - 1) * ITEMS_PER_PAGE, 
    currentPage * ITEMS_PER_PAGE
  );

  return (
    <View className="bg-white rounded-2xl shadow-sm border border-gray-100 p-4 mb-4">
      <Text className="text-xl font-black text-gray-800 mb-4">🎁 Received Gifts ({gifts.length})</Text>
      
      <FlatList 
        data={currentGifts}
        keyExtractor={(item) => item.id}
        scrollEnabled={false}
        ListEmptyComponent={
          <Text className="text-gray-400 text-center py-4 font-bold">No gifts received yet.</Text>
        }
        renderItem={({ item }) => (
          <View className="flex-row items-center bg-gray-50 p-3 rounded-xl mb-2 border border-gray-100">
            <View className="w-12 h-12 bg-white rounded-full items-center justify-center border border-gray-200 shadow-sm mr-3">
              <Text className="text-2xl">{item.icon}</Text>
            </View>
            <View className="flex-1">
              <Text className="font-black text-gray-800 text-sm">
                {item.senderName} sent a {item.giftName}
              </Text>
              <Text className="text-gray-400 text-xs font-bold mt-0.5">{item.date}</Text>
            </View>
          </View>
        )}
      />

      {gifts.length > ITEMS_PER_PAGE && (
        <View className="flex-row justify-between items-center mt-2 border-t border-gray-100 pt-3">
          <TouchableOpacity 
            onPress={() => setCurrentPage(prev => Math.max(prev - 1, 1))} 
            className={`p-2 rounded-lg min-w-[80px] items-center ${currentPage === 1 ? 'bg-gray-300' : 'bg-green-500'}`}
            disabled={currentPage === 1}
          >
            <Text className="text-white font-bold text-xs">Prev</Text>
          </TouchableOpacity>
          
          <Text className="text-gray-600 font-bold text-xs">
            {currentPage} / {totalPages}
          </Text>
          
          <TouchableOpacity 
            onPress={() => setCurrentPage(prev => Math.min(prev + 1, totalPages))} 
            className={`p-2 rounded-lg min-w-[80px] items-center ${currentPage === totalPages ? 'bg-gray-300' : 'bg-green-500'}`}
            disabled={currentPage === totalPages}
          >
            <Text className="text-white font-bold text-xs">Next</Text>
          </TouchableOpacity>
        </View>
      )}
    </View>
  );
};