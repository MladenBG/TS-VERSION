import React from 'react';
import { Modal, View, Text, TouchableOpacity, FlatList } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { UserCard } from './UserCard';

export const OnlineMembers = ({ visible, onClose, profiles, onSelectUser, toggleLike, myId, onlineUserIds }: any) => {
  
  // 🚀 Filter profiles to only show those whose ID is currently online via Socket!
  const onlineProfiles = [...profiles].filter(p => p.id !== myId && !p.isBanned && onlineUserIds.includes(p.id));

  return (
    <Modal visible={visible} animationType="slide">
      <SafeAreaView className="flex-1 bg-gray-50">
        
        <View className="flex-row items-center justify-between p-5 border-b border-gray-200 bg-white">
          <TouchableOpacity onPress={onClose}>
            <Text className="text-green-500 font-bold text-lg">← Back</Text>
          </TouchableOpacity>
          <Text className="text-xl font-black text-black">Online Now 🟢</Text>
          <View style={{ width: 50 }} />
        </View>

        <FlatList
          data={onlineProfiles}
          keyExtractor={item => item.id.toString()}
          numColumns={2}
          contentContainerStyle={{ padding: 4, paddingBottom: 40 }}
          ListEmptyComponent={
            <Text className="text-center mt-10 text-gray-500 font-bold">
              No other users are currently online.
            </Text>
          }
          renderItem={({item}) => (
            <UserCard 
              item={item} 
              onSelect={(u: any) => {
                onClose(); 
                onSelectUser(u);
              }} 
              onToggleLike={toggleLike} 
              myId={myId} 
            />
          )}
        />

      </SafeAreaView>
    </Modal>
  );
};