import React, { useState } from 'react';
import { View, Text, FlatList, Image, TouchableOpacity, Modal, Alert } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';

interface Friend {
  id: string;
  name: string;
  image: string;
  town: string;
}

interface FriendsProps {
  friendsList: Friend[];
  isEditable?: boolean; // If true, shows the delete button
  onRemoveFriend?: (id: string) => void;
  isAdmin?: boolean;       // 🚀 ADDED: To check roles
  isVip?: boolean;         // 🚀 ADDED: To check roles
  setShowPaywall?: (show: boolean) => void; // 🚀 ADDED: To open subscription screen
}

export const Friends = ({ 
  friendsList, 
  isEditable = false, 
  onRemoveFriend,
  isAdmin,         
  isVip,           
  setShowPaywall   
}: FriendsProps) => {
  const [currentPage, setCurrentPage] = useState(1);
  const [showAllModal, setShowAllModal] = useState(false);

  // 🚨 THE VIP PAYWALL LOCK 🚨
  // If they are not Admin and not VIP, show the lock screen instead of the friends!
  if (!isAdmin && !isVip) {
    return (
      <View className="bg-white rounded-2xl shadow-sm border border-gray-100 p-6 mb-4 items-center justify-center">
        <Text className="text-[50px] mb-3">🔒</Text>
        <Text className="text-xl font-black text-gray-900 mb-2 text-center">Premium Feature</Text>
        <Text className="text-sm text-gray-500 text-center mb-5 leading-5">
          Viewing and managing your friends network is locked. Upgrade to VIP to unlock all connections!
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

  // 👇 IF THEY ARE ADMIN OR VIP, SHOW THE NORMAL FRIENDS LIST 👇

  const ITEMS_PER_PAGE = 4;
  const totalPages = Math.ceil(friendsList.length / ITEMS_PER_PAGE) || 1;
  const currentFriends = friendsList.slice(
    (currentPage - 1) * ITEMS_PER_PAGE, 
    currentPage * ITEMS_PER_PAGE
  );

  const handleDelete = (id: string, name: string) => {
    Alert.alert(
      "Remove Friend",
      `Are you sure you want to remove ${name} from your friends list?`,
      [
        { text: "Cancel", style: "cancel" },
        { 
          text: "Remove", 
          style: "destructive", 
          onPress: () => onRemoveFriend && onRemoveFriend(id) 
        }
      ]
    );
  };

  // Reusable component for a single friend card
  const FriendCard = ({ item }: { item: Friend }) => (
    <View className="w-[48%] bg-gray-50 rounded-xl overflow-hidden border border-gray-200 relative mb-2">
      <Image source={{ uri: item.image }} className="w-full h-24 bg-gray-200" />
      
      {/* Delete Button (Only shows if isEditable is true) */}
      {isEditable && (
        <TouchableOpacity 
          className="absolute top-2 right-2 bg-red-500 w-6 h-6 rounded-full items-center justify-center border-2 border-white shadow-sm"
          onPress={() => handleDelete(item.id, item.name)}
        >
          <Text className="text-white text-xs font-bold">✖</Text>
        </TouchableOpacity>
      )}

      <View className="p-2 items-center">
        <Text className="font-bold text-gray-800 text-sm" numberOfLines={1}>{item.name}</Text>
        <Text className="text-gray-500 text-xs" numberOfLines={1}>{item.town}</Text>
      </View>
    </View>
  );

  return (
    <View className="bg-white rounded-2xl shadow-sm border border-gray-100 p-4 mb-4">
      
      {/* Header with Title and View All Button */}
      <View className="flex-row justify-between items-center mb-4">
        <Text className="text-xl font-black text-gray-800">🧑‍🤝‍🧑 Friends ({friendsList.length})</Text>
        {friendsList.length > 0 && (
          <TouchableOpacity onPress={() => setShowAllModal(true)}>
            <Text className="text-green-600 font-bold">See All</Text>
          </TouchableOpacity>
        )}
      </View>
      
      {/* Paginated List */}
      <FlatList 
        data={currentFriends}
        keyExtractor={(item) => item.id}
        numColumns={2}
        scrollEnabled={false}
        columnWrapperStyle={{ justifyContent: 'space-between', marginBottom: 10 }}
        ListEmptyComponent={
          <Text className="text-gray-400 text-center py-4 font-bold">No friends added yet.</Text>
        }
        renderItem={({ item }) => <FriendCard item={item} />}
      />

      {/* Pagination Controls */}
      {friendsList.length > ITEMS_PER_PAGE && (
        <View className="flex-row justify-between items-center mt-2 border-t border-gray-100 pt-3">
          <TouchableOpacity 
            onPress={() => setCurrentPage(prev => Math.max(prev - 1, 1))} 
            className={`p-2 rounded-lg min-w-[80px] items-center ${currentPage === 1 ? 'bg-gray-300' : 'bg-green-500'}`}
            disabled={currentPage === 1}
          >
            <Text className="text-white font-bold text-xs">Prev</Text>
          </TouchableOpacity>
          <Text className="text-gray-600 font-bold text-xs">{currentPage} / {totalPages}</Text>
          <TouchableOpacity 
            onPress={() => setCurrentPage(prev => Math.min(prev + 1, totalPages))} 
            className={`p-2 rounded-lg min-w-[80px] items-center ${currentPage === totalPages ? 'bg-gray-300' : 'bg-green-500'}`}
            disabled={currentPage === totalPages}
          >
            <Text className="text-white font-bold text-xs">Next</Text>
          </TouchableOpacity>
        </View>
      )}

      {/* VIEW ALL FRIENDS MODAL */}
      <Modal visible={showAllModal} animationType="slide" presentationStyle="pageSheet">
        <SafeAreaView className="flex-1 bg-gray-50">
          <View className="flex-row justify-between items-center p-4 border-b border-gray-200 bg-white">
            <Text className="text-xl font-black text-gray-800">All Friends ({friendsList.length})</Text>
            <TouchableOpacity onPress={() => setShowAllModal(false)} className="p-2 bg-gray-100 rounded-full">
              <Text className="font-bold text-gray-700">Close</Text>
            </TouchableOpacity>
          </View>
          
          <FlatList 
            data={friendsList}
            keyExtractor={(item) => item.id}
            numColumns={2}
            contentContainerStyle={{ padding: 16 }}
            columnWrapperStyle={{ justifyContent: 'space-between', marginBottom: 16 }}
            renderItem={({ item }) => <FriendCard item={item} />}
          />
        </SafeAreaView>
      </Modal>

    </View>
  );
};