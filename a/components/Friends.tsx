import React, { useState } from 'react';
import { 
  View, 
  Text, 
  FlatList, 
  Image, 
  TouchableOpacity, 
  Modal, 
  Alert 
} from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';

interface Friend {
  id: string | number;
  name: string;
  image: string;
  town?: string;
}

interface FriendsProps {
  friendsList?: Friend[];
  isEditable?: boolean; 
  onRemoveFriend?: (id: string) => void;
  onSelectFriend?: (friend: any) => void; // 🚀 ADDED TO MAKE FRIENDS CLICKABLE
  isAdmin?: boolean;       
  isVip?: boolean;         
  setShowPaywall?: (show: boolean) => void; 
}

export const Friends = ({ 
  friendsList = [], 
  isEditable = false, 
  onRemoveFriend,
  onSelectFriend,
  isAdmin,         
  isVip,           
  setShowPaywall   
}: FriendsProps) => {
  const [currentPage, setCurrentPage] = useState(1);
  const [showAllModal, setShowAllModal] = useState(false);

  const ITEMS_PER_PAGE = 4;
  
  const totalPages = Math.ceil(friendsList.length / ITEMS_PER_PAGE) || 1;
  
  const currentFriends = friendsList.slice(
    (currentPage - 1) * ITEMS_PER_PAGE, 
    currentPage * ITEMS_PER_PAGE
  );

  const handleDelete = (id: string | number, name: string) => {
    Alert.alert(
      "Remove Friend",
      `Are you sure you want to remove ${name} from your friends list?`,
      [
        { 
          text: "Cancel", 
          style: "cancel" 
        },
        { 
          text: "Remove", 
          style: "destructive", 
          onPress: () => {
            if (onRemoveFriend) {
              onRemoveFriend(id.toString());
            }
          } 
        }
      ]
    );
  };

  const FriendCard = ({ item }: { item: Friend }) => (
    <TouchableOpacity 
      activeOpacity={0.8}
      onPress={() => {
        if (onSelectFriend) {
          onSelectFriend(item);
        }
      }}
      className="w-[48%] bg-gray-50 rounded-xl overflow-hidden border border-gray-200 relative mb-2"
    >
      <Image 
        source={{ uri: item.image || 'https://via.placeholder.com/150' }} 
        className="w-full h-24 bg-gray-200" 
      />
      
      {isEditable && (
        <TouchableOpacity 
          className="absolute top-2 right-2 bg-red-500 w-6 h-6 rounded-full items-center justify-center border-2 border-white shadow-sm z-10"
          onPress={(e) => {
            e.stopPropagation(); 
            handleDelete(item.id, item.name);
          }}
        >
          <Text className="text-white text-xs font-bold">
            ✖
          </Text>
        </TouchableOpacity>
      )}

      <View className="p-2 items-center">
        <Text 
          className="font-bold text-gray-800 text-sm" 
          numberOfLines={1}
        >
          {item.name}
        </Text>
        <Text 
          className="text-gray-500 text-xs" 
          numberOfLines={1}
        >
          {item.town || 'Connected'}
        </Text>
      </View>
    </TouchableOpacity>
  );

  return (
    <View className="bg-white rounded-2xl shadow-sm border border-gray-100 p-4 mb-4">
      <View className="flex-row justify-between items-center mb-4">
        <Text className="text-xl font-black text-gray-800">
          🧑‍🤝‍🧑 Friends ({friendsList.length})
        </Text>
        {friendsList.length > 0 && (
          <TouchableOpacity 
            onPress={() => setShowAllModal(true)}
          >
            <Text className="text-green-600 font-bold">
              See All
            </Text>
          </TouchableOpacity>
        )}
      </View>
      
      <FlatList 
        data={currentFriends}
        keyExtractor={(item) => item.id.toString()}
        numColumns={2}
        scrollEnabled={false}
        columnWrapperStyle={{ 
          justifyContent: 'space-between', 
          marginBottom: 10 
        }}
        ListEmptyComponent={
          <Text className="text-gray-400 text-center py-4 font-bold">
            No friends added yet.
          </Text>
        }
        renderItem={({ item }) => (
          <FriendCard item={item} />
        )}
      />

      {friendsList.length > ITEMS_PER_PAGE && (
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

      <Modal 
        visible={showAllModal} 
        animationType="slide" 
        presentationStyle="pageSheet"
      >
        <SafeAreaView className="flex-1 bg-gray-50">
          <View className="flex-row justify-between items-center p-4 border-b border-gray-200 bg-white">
            <Text className="text-xl font-black text-gray-800">
              All Friends ({friendsList.length})
            </Text>
            <TouchableOpacity 
              onPress={() => setShowAllModal(false)} 
              className="p-2 bg-gray-100 rounded-full"
            >
              <Text className="font-bold text-gray-700">
                Close
              </Text>
            </TouchableOpacity>
          </View>
          
          <FlatList 
            data={friendsList}
            keyExtractor={(item) => item.id.toString()}
            numColumns={2}
            contentContainerStyle={{ 
              padding: 16 
            }}
            columnWrapperStyle={{ 
              justifyContent: 'space-between', 
              marginBottom: 16 
            }}
            renderItem={({ item }) => (
              <FriendCard item={item} />
            )}
          />
        </SafeAreaView>
      </Modal>

    </View>
  );
};