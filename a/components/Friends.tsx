import React, { useState } from 'react';
import { View, Text, FlatList, Image, TouchableOpacity } from 'react-native';

interface Friend {
  id: string;
  name: string;
  image: string;
  town: string;
}

interface FriendsProps {
  friendsList: Friend[];
}

export const Friends = ({ friendsList }: FriendsProps) => {
  const [currentPage, setCurrentPage] = useState(1);
  const ITEMS_PER_PAGE = 4;
  
  const totalPages = Math.ceil(friendsList.length / ITEMS_PER_PAGE) || 1;
  const currentFriends = friendsList.slice(
    (currentPage - 1) * ITEMS_PER_PAGE, 
    currentPage * ITEMS_PER_PAGE
  );

  return (
    <View className="bg-white rounded-2xl shadow-sm border border-gray-100 p-4 mb-4">
      <Text className="text-xl font-black text-gray-800 mb-4">🧑‍🤝‍🧑 Friends ({friendsList.length})</Text>
      
      <FlatList 
        data={currentFriends}
        keyExtractor={(item) => item.id}
        numColumns={2}
        scrollEnabled={false}
        columnWrapperStyle={{ justifyContent: 'space-between', marginBottom: 10 }}
        ListEmptyComponent={
          <Text className="text-gray-400 text-center py-4 font-bold">No friends added yet.</Text>
        }
        renderItem={({ item }) => (
          <View className="w-[48%] bg-gray-50 rounded-xl overflow-hidden border border-gray-200">
            <Image source={{ uri: item.image }} className="w-full h-24 bg-gray-200" />
            <View className="p-2 items-center">
              <Text className="font-bold text-gray-800 text-sm" numberOfLines={1}>{item.name}</Text>
              <Text className="text-gray-500 text-xs" numberOfLines={1}>{item.town}</Text>
            </View>
          </View>
        )}
      />

      {friendsList.length > ITEMS_PER_PAGE && (
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