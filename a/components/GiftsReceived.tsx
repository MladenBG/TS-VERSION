import React, { useState } from 'react';
import { View, Text, FlatList, TouchableOpacity } from 'react-native';

interface Gift {
  id: string | number;
  gift_name?: string; 
  sender_name?: string; 
  senderName?: string; 
  icon?: string; 
  date?: string;
}

interface GiftsReceivedProps {
  gifts?: Gift[];
  isAdmin?: boolean;       
  isVip?: boolean;         
  isPublicView?: boolean; // 🚀 ADDED TO HIDE SENDER NAMES FROM PUBLIC
  setShowPaywall?: (show: boolean) => void; 
}

export const GiftsReceived = ({ 
  gifts = [], 
  isAdmin, 
  isVip, 
  isPublicView = false,
  setShowPaywall 
}: GiftsReceivedProps) => {
  const [currentPage, setCurrentPage] = useState(1);
  const ITEMS_PER_PAGE = 3; 
  
  // 🚀 VIP PAYWALL REMOVED - EVERYONE CAN SEE GIFTS 🚀

  const totalPages = Math.ceil(gifts.length / ITEMS_PER_PAGE) || 1;
  const currentGifts = gifts.slice(
    (currentPage - 1) * ITEMS_PER_PAGE, 
    currentPage * ITEMS_PER_PAGE
  );

  return (
    <View className="bg-white rounded-2xl shadow-sm border border-gray-100 p-4 mb-4">
      <Text className="text-xl font-black text-gray-800 mb-4">
        🎁 Received Gifts ({gifts.length})
      </Text>
      
      <FlatList 
        data={currentGifts}
        keyExtractor={(item, index) => item.id ? item.id.toString() : index.toString()}
        scrollEnabled={false}
        ListEmptyComponent={
          <Text className="text-gray-400 text-center py-4 font-bold">
            No gifts received yet.
          </Text>
        }
        renderItem={({ item }) => (
          <View className="flex-row items-center bg-gray-50 p-3 rounded-xl mb-2 border border-gray-100">
            <View className="w-12 h-12 bg-white rounded-full items-center justify-center border border-gray-200 shadow-sm mr-3">
              <Text className="text-2xl">
                {item.gift_name || item.icon || '🎁'}
              </Text>
            </View>
            <View className="flex-1">
              <Text className="font-black text-gray-800 text-sm">
                {/* 🚀 IF PUBLIC VIEW, SAYS "SOMEONE". IF USER VIEW, SHOWS NAME 🚀 */}
                {isPublicView ? "Someone" : (item.sender_name || item.senderName || 'Someone')} sent a {item.gift_name || 'gift'}
              </Text>
              <Text className="text-gray-400 text-xs font-bold mt-0.5">
                {item.date || 'Recently'}
              </Text>
            </View>
          </View>
        )}
      />

      {gifts.length > ITEMS_PER_PAGE && (
        <View className="flex-row justify-between items-center mt-2 border-t border-gray-100 pt-3">
          <TouchableOpacity 
            onPress={() => setCurrentPage(prev => Math.max(prev - 1, 1))} 
            className={`p-2 rounded-lg min-w-[80px] items-center ${
              currentPage === 1 ? 'bg-gray-300' : 'bg-green-500'
            }`}
            disabled={currentPage === 1}
          >
            <Text className="text-white font-bold text-xs">
              Prev
            </Text>
          </TouchableOpacity>
          
          <Text className="text-gray-600 font-bold text-xs">
            {currentPage} / {totalPages}
          </Text>
          
          <TouchableOpacity 
            onPress={() => setCurrentPage(prev => Math.min(prev + 1, totalPages))} 
            className={`p-2 rounded-lg min-w-[80px] items-center ${
              currentPage === totalPages ? 'bg-gray-300' : 'bg-green-500'
            }`}
            disabled={currentPage === totalPages}
          >
            <Text className="text-white font-bold text-xs">
              Next
            </Text>
          </TouchableOpacity>
        </View>
      )}
    </View>
  );
};